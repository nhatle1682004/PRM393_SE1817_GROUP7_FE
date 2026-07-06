# Backend migration report

This report summarizes the migration/refactor from `old/SWP391_G6/BackEnd` into the `new/BE` microservice backend.

## Services and projects touched

- `src/ApiGateway`: YARP gateway routes for public APIs and uploaded-file URLs.
- `src/Services/IdentityService`: authentication, user/profile management, OTP email, JWT, role/collector/enterprise logic.
- `src/Services/WasteReportService`: reports, waste types, districts, duplicate detection, PostGIS district resolution, dashboard report data.
- `src/Services/CollectionService`: collection requests, assignments, collection lifecycle, proof uploads, issue reporting.
- `src/Services/EngagementService`: notifications, rewards, feedback, dashboard aggregation.
- `src/Shared/Contracts`, `src/Shared/SharedKernel`: shared DTOs/primitives used by service clients.
- `tests/BackendBehavior.Tests`: behavior/regression coverage for the migrated backend flows.

## Old-to-new code mapping

| Old monolith area | New microservice target |
| --- | --- |
| `WasteCollectionPlatform/Controllers/AuthController.cs` | `IdentityService.Api` auth endpoints |
| `WasteCollectionPlatform/Controllers/UsersController.cs` | `IdentityService.Api` user/profile endpoints |
| `BusinessLogicLayer/Services/Implementation/AuthService.cs` | `IdentityService.Application/Services/AuthService.cs` |
| `BusinessLogicLayer/Services/Implementation/UserService.cs` | `IdentityService.Application/Services/UserService.cs` |
| `BusinessLogicLayer/Services/Implementation/EmailService.cs` | `IdentityService.Application/Services/EmailService.cs` |
| `DTOs/Auth`, `DTOs/User`, auth/user validators/cache/settings/templates | `IdentityService.Application` DTOs, validators, cache models, settings, email templates |
| `AuthController`, `UsersController` entities `User`, `Role`, `CollectorProfile`, `EnterpriseProfile` | `IdentityService.Domain` + `IdentityDbContext` |
| `WasteReportsController.cs` | `WasteReportService.Api` report endpoints |
| `WasteTypesController.cs` | `WasteReportService.Api` waste type endpoints |
| `DistrictsController.cs` | `WasteReportService.Api` district endpoints |
| `WasteReportService.cs`, `WasteTypeService.cs`, `DistrictService.cs` | `WasteReportService.Application/Services` |
| Waste report/type/district DTOs and entities | `WasteReportService.Application`, `WasteReportService.Domain`, `WasteReportDbContext` |
| `CollectionRequestsController.cs` | `CollectionService.Api` request endpoints |
| `AssignmentsController.cs` | `CollectionService.Api` assignment endpoints |
| `CollectionsController.cs` | `CollectionService.Api` collection lifecycle endpoints |
| Collection request/assignment/collection services, DTOs, entities | `CollectionService.Application`, `CollectionService.Domain`, `CollectionDbContext` |
| `NotificationsController.cs` | `EngagementService.Api` notification endpoints |
| `RewardsController.cs` | `EngagementService.Api` reward endpoints |
| `FeedbacksController.cs` | `EngagementService.Api` feedback endpoints |
| `DashboardController.cs` | `EngagementService.Api` dashboard endpoints |
| Notification/reward/feedback/dashboard services, DTOs, entities | `EngagementService.Application`, `EngagementService.Domain`, `EngagementDbContext` |

## Controller routing through the gateway

The frontend keeps one public base URL: `http://localhost:5000/api`.

| Public path | Target service |
| --- | --- |
| `/api/auth/**`, `/api/users/**` | IdentityService |
| `/api/waste-reports/**`, `/api/waste-types/**`, `/api/districts/**` | WasteReportService |
| `/api/collection-requests/**`, `/api/assignments/**`, `/api/collections/**` | CollectionService |
| `/api/notifications/**`, `/api/rewards/**`, `/api/feedbacks/**`, `/api/dashboard/**` | EngagementService |
| `/uploads/waste-reports/**` | WasteReportService static files |
| `/uploads/collection-proofs/**`, `/uploads/issue-proofs/**` | CollectionService static files |
| `/uploads/feedbacks/**` | EngagementService static files |

## Entity and table mapping

| Schema | Tables |
| --- | --- |
| `identity` | `users`, `roles`, `enterprise_profiles`, `collector_profiles`, `__EFMigrationsHistory` |
| `waste` | `waste_reports`, `waste_types`, `report_waste_types`, `districts`, `ai_waste_predictions`, `__EFMigrationsHistory` |
| `collection` | `collection_requests`, `collector_assignments`, `collection_confirmations`, `collection_details`, `__EFMigrationsHistory` |
| `engagement` | `notifications`, `rewards`, `reward_transactions`, `feedbacks`, `__EFMigrationsHistory` |

Each service owns its own DbContext and migration history table:

- `IdentityDbContext`
- `WasteReportDbContext`
- `CollectionDbContext`
- `EngagementDbContext`

The old whole-system `AppDbContext` / `PostgresContext` / shared `IUnitOfWork` pattern is not used as the new cross-service integration mechanism.

## Internal endpoints and clients

Cross-service database access was replaced with HTTP clients guarded by `X-Internal-Api-Key`:

- `IIdentityClient`: user/profile/enterprise/collector lookups and point/warning updates.
- `IWasteReportClient`: report status and report details from Collection/Engagement flows.
- `ICollectionClient`: collection request/assignment operations from WasteReport/Engagement flows.
- `IEngagementClient`: notifications and reward transactions from WasteReport/Collection flows.

## Preserved business logic

The migrated backend keeps the legacy behavior for:

- Citizen registration, OTP cache/verify, login/JWT, forgot/reset/change password, user CRUD/profile management, soft deactivate/reactivate, collector availability, role authorization, and OTP email template loading.
- Waste report image requirement, latitude/longitude validation, active waste type validation, duplicate detection within 30 meters, PostGIS district resolution, pending/accepted/rejected/cancelled status rules, enterprise district authorization, report update/cancel behavior, and collection request/notification creation on accept.
- Collection request assignment/reassignment/cancellation, assignment history, “one active trip per collector”, start/arrived/complete lifecycle, required before/after images, actual weight validation, collection confirmations/details, report/request/assignment status updates, reward transaction creation, user point update, and notifications.
- Legacy issue types: `WasteNotFound`, `WrongAddress`, `WasteTypeMismatch`, `CitizenUnavailable`, `Other`.
- Notifications, mark read/all read, reward catalog, point totals, transaction history, redeem reward with point deduction, feedback create/resolve/reject, collector warning/reward reversal/complaint reward behavior, and admin dashboard.

Two migration-hardening fixes were also added:

- Dashboard recent reports now resolve submitter names through `IIdentityClient`.
- Public voucher redemption uses a unique reference per redemption so two legitimate redemptions in the same minute are not treated as duplicates.

## File upload and persistence

Uploaded image URLs remain frontend-consumable through the gateway. Docker Compose persists upload folders with named volumes for:

- waste report images
- collection before/after proof images
- issue proof images
- feedback images

## Legacy database migration

Use `migrations-legacy-public-to-schemas.sql` to move an existing legacy `public` schema database into the per-service schema layout. The script:

- creates the four service schemas;
- enables PostGIS if needed;
- moves legacy tables into the matching service schema;
- aligns table names and service-owned migration history;
- adds current engagement consistency columns and idempotency index;
- aligns serial sequences after data movement.

For fresh databases, run EF migrations per service:

```powershell
dotnet ef database update --project src/Services/IdentityService/IdentityService.Infrastructure --startup-project src/Services/IdentityService/IdentityService.Api --context IdentityDbContext
dotnet ef database update --project src/Services/WasteReportService/WasteReportService.Infrastructure --startup-project src/Services/WasteReportService/WasteReportService.Api --context WasteReportDbContext
dotnet ef database update --project src/Services/CollectionService/CollectionService.Infrastructure --startup-project src/Services/CollectionService/CollectionService.Api --context CollectionDbContext
dotnet ef database update --project src/Services/EngagementService/EngagementService.Infrastructure --startup-project src/Services/EngagementService/EngagementService.Api --context EngagementDbContext
```

## How to run

Restore, build, and test:

```powershell
dotnet restore BackEnd-Microservices.sln
dotnet build BackEnd-Microservices.sln --no-restore
dotnet test tests/BackendBehavior.Tests/BackendBehavior.Tests.csproj --no-build
```

Run the full stack with Docker Compose:

```powershell
docker compose up --build
```

Default public entrypoint:

```text
http://localhost:5000/api
```

Individual service ports in local development:

- ApiGateway: `http://localhost:5000`
- IdentityService: `http://localhost:5001`
- WasteReportService: `http://localhost:5002`
- CollectionService: `http://localhost:5003`
- EngagementService: `http://localhost:5004`

SMTP credentials are intentionally not hard-coded. Configure them through `.env` or environment variables using `.env.example` as the template.

## Verification evidence

Final verification commands run for this migration:

- `dotnet restore BackEnd-Microservices.sln`
- `dotnet build BackEnd-Microservices.sln --no-restore`
- `dotnet test tests/BackendBehavior.Tests/BackendBehavior.Tests.csproj --no-build`
- `docker compose -f docker-compose.yml config --quiet`
- `docker compose -p wcpverify build`
- EF pending-model-change checks for all four service DbContexts
- Gateway and service smoke flows against a PostGIS-backed PostgreSQL container

The behavior test project covers OTP registration verification, waste report acceptance and dashboard submitter resolution, collection completion, issue type preservation, active-trip blocking, feedback reassignment/reward reversal, and reward transaction idempotency.

## Remaining errors / TODO

- No blocking backend build or behavior-test failures remain.
- Live email delivery still depends on valid SMTP environment variables.
- React-to-Flutter UI migration was intentionally not performed in this backend phase.
