# BackEnd-Microservices

Refactor of the old `BackEnd` monolith into four ASP.NET Core services plus a YARP API gateway. The old folder is kept as reference and is not required at runtime.

## Services

- `IdentityService` owns `identity.users`, `identity.roles`, `identity.enterprise_profiles`, `identity.collector_profiles`.
- `WasteReportService` owns `waste.waste_reports`, `waste.waste_types`, `waste.report_waste_types`, `waste.districts`, `waste.ai_waste_predictions`.
- `CollectionService` owns `collection.collection_requests`, `collection.collector_assignments`, `collection.collection_confirmations`, `collection.collection_details`.
- `EngagementService` owns `engagement.notifications`, `engagement.rewards`, `engagement.reward_transactions`, `engagement.feedbacks`.

All services use the same PostgreSQL database and separate schemas. Cross-service references are stored as primitive IDs and resolved through internal HTTP clients protected by `X-Internal-Api-Key`.

## Run Locally

```powershell
dotnet restore .\BackEnd-Microservices.sln
dotnet build .\BackEnd-Microservices.sln
dotnet run --project .\src\Services\IdentityService\IdentityService.Api --urls http://localhost:5001
dotnet run --project .\src\Services\WasteReportService\WasteReportService.Api --urls http://localhost:5002
dotnet run --project .\src\Services\CollectionService\CollectionService.Api --urls http://localhost:5003
dotnet run --project .\src\Services\EngagementService\EngagementService.Api --urls http://localhost:5004
dotnet run --project .\src\ApiGateway --urls http://localhost:5000
```

Swagger endpoints are available at each service `/swagger`.

## Docker

```powershell
docker compose up --build
```

Gateway runs on `http://localhost:5000`; services run on ports `5001` to `5004`.

## Migrations

Each service has its own DbContext and migration history table:

```powershell
dotnet ef migrations add InitialIdentitySchema --project .\src\Services\IdentityService\IdentityService.Infrastructure --startup-project .\src\Services\IdentityService\IdentityService.Api --context IdentityDbContext
dotnet ef migrations add InitialWasteSchema --project .\src\Services\WasteReportService\WasteReportService.Infrastructure --startup-project .\src\Services\WasteReportService\WasteReportService.Api --context WasteReportDbContext
dotnet ef migrations add InitialCollectionSchema --project .\src\Services\CollectionService\CollectionService.Infrastructure --startup-project .\src\Services\CollectionService\CollectionService.Api --context CollectionDbContext
dotnet ef migrations add InitialEngagementSchema --project .\src\Services\EngagementService\EngagementService.Infrastructure --startup-project .\src\Services\EngagementService\EngagementService.Api --context EngagementDbContext
```

If migrating existing public-schema tables, move them into service schemas first and rename old table names to the new snake_case names where needed. Keep `waste.districts.boundary` as a PostGIS geometry column for district resolution.
