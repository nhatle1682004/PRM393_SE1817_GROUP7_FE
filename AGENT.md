# AGENT.md - Refactor WasteCollectionPlatform sang Microservice dùng 1 PostgreSQL DB nhiều schema

## 1. Mục tiêu

Refactor project hiện tại từ cấu trúc monolith/layered architecture:

```txt
BackEnd/
  WasteCollectionPlatform/        # API Controllers + Program.cs
  BusinessLogicLayer/             # DTOs, Services, Validators
  DataAccessLayer/                # AppDbContext, Models, Repositories, UnitOfWork
```

sang cấu trúc microservice gồm 4 service độc lập:

```txt
1. Identity/User Service
2. Waste Report Service
3. Collection/Assignment Service
4. Engagement Service
```

Yêu cầu bắt buộc:

- Không làm mất logic business hiện có.
- Không đổi behavior API nếu không cần thiết.
- Không xoá validation, authorization, status flow, notification, reward, feedback logic hiện tại.
- Vẫn dùng **1 PostgreSQL database duy nhất**.
- Mỗi service dùng **schema riêng** trong cùng database, không dùng nhiều database riêng.
- Mỗi service có `DbContext`, migration, repository/service riêng.
- Tách code theo domain, không để service này truy cập trực tiếp table/entity của service khác.
- Nếu cần dữ liệu từ service khác, dùng internal HTTP client hoặc event/integration interface.
- Ưu tiên refactor từng bước để project vẫn build được sau mỗi phase.

---

## 2. Kiến trúc mong muốn

Tạo solution mới hoặc restructure solution hiện tại thành dạng:

```txt
BackEnd-Microservices/
  WasteCollectionPlatform.sln

  src/
    BuildingBlocks/
      BuildingBlocks.Shared/
        Common/
        Contracts/
        Auth/
        Exceptions/
        FileStorage/
        Responses/

    ApiGateway/
      WasteCollection.ApiGateway/

    Services/
      Identity/
        Identity.Api/
        Identity.Application/
        Identity.Domain/
        Identity.Infrastructure/

      WasteReport/
        WasteReport.Api/
        WasteReport.Application/
        WasteReport.Domain/
        WasteReport.Infrastructure/

      Collection/
        Collection.Api/
        Collection.Application/
        Collection.Domain/
        Collection.Infrastructure/

      Engagement/
        Engagement.Api/
        Engagement.Application/
        Engagement.Domain/
        Engagement.Infrastructure/

  docker-compose.yml
  README.md
  AGENT.md
```

Nếu không muốn tạo quá nhiều project ngay, có thể dùng dạng đơn giản hơn:

```txt
src/
  Services/
    IdentityService/
    WasteReportService/
    CollectionService/
    EngagementService/
  Shared/
```

Nhưng vẫn phải đảm bảo mỗi service là một ASP.NET Core Web API riêng, chạy port riêng, có DI riêng, Swagger riêng, DbContext riêng.

---

## 3. Database design: 1 DB, 4 schema

Vẫn dùng chung connection string PostgreSQL hiện tại, ví dụ:

```json
"ConnectionStrings": {
  "DefaultConnection": "Host=localhost;Port=5432;Database=waste_collection_platform;Username=postgres;Password=your_password"
}
```

Tạo 4 schema:

```sql
create schema if not exists identity;
create schema if not exists waste;
create schema if not exists collection;
create schema if not exists engagement;
```

Mapping table sang schema:

### identity schema

```txt
identity.roles
identity.users
identity.enterprise_profiles
identity.collector_profiles
```

Service sở hữu: **Identity/User Service**

### waste schema

```txt
waste.wastereports
waste.wastetypes
waste.report_waste_types hoặc waste.ReportWastetype nếu đang dùng many-to-many implicit
waste.ai_waste_predictions
waste.districts
```

Service sở hữu: **Waste Report Service**

### collection schema

```txt
collection.collectionrequests
collection.collectorassignments
collection.collectionconfirmations
collection.collection_details
```

Service sở hữu: **Collection/Assignment Service**

### engagement schema

```txt
engagement.notifications
engagement.rewards
engagement.rewardtransactions
engagement.feedbacks
```

Service sở hữu: **Engagement Service**

Quan trọng:

- Không dùng `public` schema cho business tables nữa.
- Mỗi service có migration history riêng:

```csharp
options.UseNpgsql(connectionString, x =>
    x.MigrationsHistoryTable("__EFMigrationsHistory", "identity"));
```

Tương tự:

```txt
identity.__EFMigrationsHistory
waste.__EFMigrationsHistory
collection.__EFMigrationsHistory
engagement.__EFMigrationsHistory
```

---

## 4. Rule về foreign key và navigation property

Vì vẫn dùng chung database nên về kỹ thuật có thể tạo cross-schema FK. Tuy nhiên để đúng microservice boundary:

- Không để service này dùng EF navigation property sang entity của service khác.
- Không inject DbContext của service khác.
- Không dùng `Include()` sang bảng ngoài schema service.
- Không dùng chung `AppDbContext` cũ.
- Không dùng chung `IUnitOfWork` cũ cho toàn bộ hệ thống.

Thay vào đó:

- Lưu ID tham chiếu dạng primitive: `UserId`, `EnterpriseId`, `CollectorId`, `ReportId`, `RequestId`.
- Khi cần thông tin user/enterprise/collector, gọi `Identity Service` qua internal client.
- Khi cần thông tin report, gọi `Waste Report Service`.
- Khi cần tạo notification/reward/feedback, gọi `Engagement Service` hoặc publish event.

Trong phase đầu để tránh mất logic, có thể giữ cross-schema FK ở database nếu cần, nhưng application code không được phụ thuộc vào navigation property xuyên service.

---

## 5. Mapping code hiện tại sang service mới

### 5.1 Identity/User Service

Move các controller:

```txt
WasteCollectionPlatform/Controllers/AuthController.cs
WasteCollectionPlatform/Controllers/UsersController.cs
```

Move services:

```txt
BusinessLogicLayer/Services/Implementation/AuthService.cs
BusinessLogicLayer/Services/Implementation/UserService.cs
BusinessLogicLayer/Services/Implementation/EmailService.cs
```

Move interfaces:

```txt
IAuthService.cs
IUserService.cs
IEmailService.cs
```

Move DTOs:

```txt
DTOs/Auth/*
DTOs/User/*
```

Move validators/cache/settings:

```txt
Validators/RegisterRequestValidator.cs
Validators/CreateUserValidator.cs
CacheModels/RegisterCacheModel.cs
Identity/EmailSettings.cs
EmailTemplates/OtpVerification.html
```

Move models/entities:

```txt
Role.cs
User.cs
EnterpriseProfile.cs
CollectorProfile.cs
```

Tạo DbContext:

```csharp
public class IdentityDbContext : DbContext
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<EnterpriseProfile> EnterpriseProfiles => Set<EnterpriseProfile>();
    public DbSet<CollectorProfile> CollectorProfiles => Set<CollectorProfile>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("identity");
        modelBuilder.Entity<User>().ToTable("users", "identity");
        modelBuilder.Entity<Role>().ToTable("roles", "identity");
        modelBuilder.Entity<EnterpriseProfile>().ToTable("enterprise_profiles", "identity");
        modelBuilder.Entity<CollectorProfile>().ToTable("collector_profiles", "identity");
    }
}
```

Identity service phải giữ nguyên logic:

- Register citizen.
- Cache OTP.
- Verify OTP and create user.
- Login and JWT.
- Forgot password.
- Reset password.
- Change password.
- CRUD user.
- Soft delete/reactivate/delete user.
- Update collector availability.
- Update profile.
- Get collectors.
- Role-based authorization.

Expose internal endpoints cho service khác dùng:

```txt
GET /internal/users/{id}
GET /internal/users/{id}/role
GET /internal/collectors/{id}
GET /internal/collectors/by-enterprise/{enterpriseId}
GET /internal/enterprises/{id}
GET /internal/enterprises/by-district/{districtId}
PUT /internal/collectors/{collectorId}/availability
PUT /internal/collectors/{collectorId}/warning-count
PUT /internal/users/{userId}/points/add
PUT /internal/users/{userId}/points/deduct
```

Nếu muốn tách điểm thưởng khỏi Identity hoàn toàn, `TotalPoints` có thể chuyển sang Engagement. Nhưng để không mất logic nhanh, phase đầu có thể giữ `users.total_points` trong identity và Engagement gọi internal endpoint để cộng/trừ điểm.

---

### 5.2 Waste Report Service

Move controllers:

```txt
WasteReportsController.cs
WasteTypesController.cs
DistrictsController.cs
```

Move services:

```txt
WasteReportService.cs
WasteTypeService.cs
DistrictService.cs
```

Move interfaces:

```txt
IWasteReportService.cs
IWasteTypeService.cs
IDistrictService.cs
```

Move DTOs:

```txt
DTOs/WasteReport/*
DTOs/WasteType/*
DTOs/District/*
```

Move models/entities:

```txt
Wastereport.cs
Wastetype.cs
AiWastePrediction.cs
District.cs
```

Tạo DbContext:

```csharp
public class WasteReportDbContext : DbContext
{
    public DbSet<Wastereport> WasteReports => Set<Wastereport>();
    public DbSet<Wastetype> WasteTypes => Set<Wastetype>();
    public DbSet<AiWastePrediction> AiWastePredictions => Set<AiWastePrediction>();
    public DbSet<District> Districts => Set<District>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("waste");
        modelBuilder.Entity<Wastereport>().ToTable("wastereports", "waste");
        modelBuilder.Entity<Wastetype>().ToTable("wastetypes", "waste");
        modelBuilder.Entity<AiWastePrediction>().ToTable("ai_waste_predictions", "waste");
        modelBuilder.Entity<District>().ToTable("districts", "waste");
    }
}
```

Giữ nguyên logic WasteReportService hiện tại:

- Validate image bắt buộc.
- Validate latitude từ `-90` đến `90`.
- Validate longitude từ `-180` đến `180`.
- Validate phải có ít nhất một `WasteTypeId`.
- Validate waste type tồn tại và active.
- Detect duplicate report trong radius `30m`.
- Resolve district bằng PostGIS `st_contains(boundary, st_setsrid(st_point(@lng, @lat), 4326))`.
- Nếu nằm ngoài district support thì throw error.
- Create report status `Pending`.
- Accept report chỉ khi status `Pending`.
- Enterprise chỉ accept report thuộc district mình quản lý.
- Reject report chỉ khi status `Pending`.
- Update/cancel report phải giữ rule hiện tại.
- Get all/get by id giữ response format hiện tại.

Tách logic cross-service:

Hiện tại `AcceptAsync` đang tạo `Collectionrequest` và notification trực tiếp. Sau refactor:

```txt
WasteReportService.AcceptAsync(reportId, enterpriseId)
  1. Gọi Identity Service để lấy enterprise profile và managedDistrictId.
  2. Validate enterprise quản lý đúng district của report.
  3. Update report status = Accepted.
  4. Gọi Collection Service: POST /internal/collection-requests/from-report.
  5. Gọi Engagement Service: POST /internal/notifications.
```

Hoặc publish event:

```txt
WasteReportAcceptedEvent
{
  reportId,
  submittedByUserId,
  enterpriseId,
  districtId,
  latitude,
  longitude,
  description,
  wasteTypeIds,
  acceptedAt
}
```

Phase đầu có thể dùng HTTP internal client cho dễ, chưa cần RabbitMQ/Kafka.

Expose internal endpoints:

```txt
GET /internal/waste-reports/{reportId}
PUT /internal/waste-reports/{reportId}/status
GET /internal/waste-types/{wasteTypeId}
GET /internal/waste-types/batch?ids=1&ids=2
GET /internal/districts/{districtId}
```

---

### 5.3 Collection/Assignment Service

Move controllers:

```txt
CollectionRequestsController.cs
AssignmentsController.cs
CollectionsController.cs
```

Move services:

```txt
CollectionRequestService.cs
AssignmentService.cs
CollectionService.cs
```

Move interfaces:

```txt
ICollectionRequestService.cs
IAssignmentService.cs
ICollectionService.cs
```

Move DTOs:

```txt
DTOs/CollectionRequest/*
DTOs/Assignment/*
DTOs/Collection/*
```

Move models/entities:

```txt
Collectionrequest.cs
Collectorassignment.cs
Collectionconfirmation.cs
CollectionDetail.cs
```

Tạo DbContext:

```csharp
public class CollectionDbContext : DbContext
{
    public DbSet<Collectionrequest> CollectionRequests => Set<Collectionrequest>();
    public DbSet<Collectorassignment> CollectorAssignments => Set<Collectorassignment>();
    public DbSet<Collectionconfirmation> CollectionConfirmations => Set<Collectionconfirmation>();
    public DbSet<CollectionDetail> CollectionDetails => Set<CollectionDetail>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("collection");
        modelBuilder.Entity<Collectionrequest>().ToTable("collectionrequests", "collection");
        modelBuilder.Entity<Collectorassignment>().ToTable("collectorassignments", "collection");
        modelBuilder.Entity<Collectionconfirmation>().ToTable("collectionconfirmations", "collection");
        modelBuilder.Entity<CollectionDetail>().ToTable("collection_details", "collection");
    }
}
```

Giữ nguyên logic AssignmentService:

- Enterprise assign collector.
- Collector phải thuộc enterprise đó nếu code hiện tại đang validate như vậy.
- Không assign nếu request không hợp lệ.
- Reassign collector.
- Cancel assignment.
- Get assignment history by request.
- Get my assignments.
- Get assignment detail.

Giữ nguyên logic CollectionRequestService:

- Get collection requests by enterprise.
- Get collection request detail.
- Get all collection requests.
- Get assignment history by request.

Giữ nguyên logic CollectionService:

- Decline assignment.
- Start collection.
- Không cho collector start nhiều active trip cùng lúc.
- Start chỉ khi status `Assigned`.
- Start đổi assignment status `OnTheWay`, request status `OnTheWay`, set `StartedAt`.
- Arrived chỉ khi status `OnTheWay`.
- Arrived yêu cầu before image.
- Arrived đổi status `Arrived`, set `ArrivedAt`, lưu `BeforeImageUrl`, request status `Arrived`.
- Report issue chỉ khi status `OnTheWay` hoặc `Arrived`.
- Validate issue type trong danh sách hiện tại:
  - `WasteNotFound`
  - `WrongAddress`
  - `WasteTypeMismatch`
  - `CitizenUnavailable`
  - `Other`
- Report issue đổi assignment status `ReportedIssue`, request status `Issue`, lưu issue report/reason/image.
- Complete chỉ khi status `Arrived`.
- Complete yêu cầu before image đã tồn tại.
- Complete yêu cầu after image.
- Complete yêu cầu actual weights hợp lệ và `Weight > 0`.
- Complete tạo collection confirmation.
- Complete tạo collection details.
- Complete update assignment/request/report status giống logic cũ.
- Complete cộng reward points giống logic cũ.
- Complete tạo reward transaction giống logic cũ.
- Complete tạo notification giống logic cũ.

Tách logic cross-service:

- Không `Include(x => x.Request.Report.SubmittedByNavigation)` xuyên service.
- `Collectionrequest` chỉ lưu `ReportId`, `EnterpriseId`.
- `Collectorassignment` chỉ lưu `AssignedCollector`, `AssignedBy`.
- Khi cần report detail, gọi Waste Report Service.
- Khi cần collector/enterprise detail, gọi Identity Service.
- Khi complete collection:

```txt
Collection Service
  1. Validate assignment/request trong collection schema.
  2. Gọi Waste Report Service để lấy report/waste types nếu cần.
  3. Tạo confirmation + details.
  4. Update collection request + assignment.
  5. Gọi Waste Report Service: update report status = Collected.
  6. Gọi Engagement Service: add reward transaction + notification.
```

Expose internal endpoints:

```txt
POST /internal/collection-requests/from-report
GET /internal/collection-requests/by-report/{reportId}
GET /internal/assignments/{assignmentId}
PUT /internal/assignments/{assignmentId}/cancel
PUT /internal/collection-requests/{requestId}/status
```

---

### 5.4 Engagement Service

Move controllers:

```txt
NotificationsController.cs
RewardsController.cs
FeedbacksController.cs
DashboardController.cs
```

Move services:

```txt
NotificationService.cs
RewardService.cs
FeedbackService.cs
DashboardService.cs
```

Move interfaces:

```txt
INotificationService.cs
IRewardService.cs
IFeedbackService.cs
IDashboardService.cs
```

Move DTOs:

```txt
DTOs/Notification/*
DTOs/Reward/*
DTOs/Feedback/*
DTOs/Dashboard/*
```

Move models/entities:

```txt
Notification.cs
Reward.cs
Rewardtransaction.cs
Feedback.cs
```

Tạo DbContext:

```csharp
public class EngagementDbContext : DbContext
{
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<Reward> Rewards => Set<Reward>();
    public DbSet<Rewardtransaction> RewardTransactions => Set<Rewardtransaction>();
    public DbSet<Feedback> Feedbacks => Set<Feedback>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("engagement");
        modelBuilder.Entity<Notification>().ToTable("notifications", "engagement");
        modelBuilder.Entity<Reward>().ToTable("rewards", "engagement");
        modelBuilder.Entity<Rewardtransaction>().ToTable("rewardtransactions", "engagement");
        modelBuilder.Entity<Feedback>().ToTable("feedbacks", "engagement");
    }
}
```

Giữ nguyên logic NotificationService:

- Get user notifications.
- Mark as read.
- Mark all as read.

Giữ nguyên logic RewardService:

- Get user total points.
- Get available rewards.
- Get transaction history.
- Redeem reward.
- Validate đủ điểm khi redeem.
- Deduct points.
- Create reward transaction.

Giữ nguyên logic FeedbackService:

- Create feedback.
- Get feedback by report.
- Get all feedbacks.
- Get feedback detail.
- Resolve feedback.
- Reject feedback.
- Khi resolve phải giữ logic cũ:
  - Update feedback status.
  - Resolution note.
  - Xử lý assignment/report liên quan nếu có.
  - Warning collector nếu logic cũ có.
  - Revert/cộng/trừ reward nếu logic cũ có.
  - Notification cho user/collector/enterprise nếu logic cũ có.

Giữ nguyên logic DashboardService:

- Admin dashboard theo năm.
- Cache dashboard nếu code cũ đang dùng `IMemoryCache`.
- Không làm mất các chỉ số hiện có.

Tách logic cross-service:

- Feedback không được trực tiếp update report/assignment/user nữa.
- Khi resolve feedback:

```txt
Engagement Service
  1. Update feedback trong engagement schema.
  2. Gọi Collection Service để cancel/reopen/reassign assignment nếu cần.
  3. Gọi Waste Report Service để update report status nếu cần.
  4. Gọi Identity Service để tăng warning collector nếu cần.
  5. Gọi Identity Service để cộng/trừ total points nếu phase đầu vẫn giữ total_points trong users.
  6. Tạo notification trong engagement schema.
```

Expose internal endpoints:

```txt
POST /internal/notifications
POST /internal/rewards/transactions
POST /internal/rewards/add-points
POST /internal/rewards/deduct-points
POST /internal/feedbacks/from-report
```

---

## 6. Shared project

Tạo `BuildingBlocks.Shared` để chứa code dùng chung, không chứa business logic cụ thể.

Có thể đưa vào shared:

```txt
ApiResponse<T>
PagedResult<T> nếu có
CurrentUser/UserClaims helper
JWT authentication extension
Common exception classes
Global exception middleware
File upload helper
Constants cho roles/status nếu dùng chung
HTTP client base classes
Internal service DTO contracts
```

Không đưa vào shared:

```txt
Entity EF Core của từng service
DbContext của từng service
Repository của từng service
Business service của từng service
UnitOfWork dùng chung toàn hệ thống
```

---

## 7. Auth/JWT cho tất cả service

Identity Service phát JWT như hiện tại.

Các service còn lại chỉ validate JWT:

```txt
Waste Report Service
Collection Service
Engagement Service
ApiGateway nếu có
```

Tất cả service dùng chung config:

```json
"Jwt": {
  "Key": "...",
  "Issuer": "...",
  "Audience": "..."
}
```

Giữ nguyên role claim:

```csharp
RoleClaimType = ClaimTypes.Role
```

Các controller phải giữ `[Authorize]` và `[Authorize(Roles = "...")]` như code cũ.

---

## 8. API Gateway

Có thể dùng YARP làm API Gateway.

Gateway route đề xuất:

```txt
/api/auth/**                -> Identity Service
/api/users/**               -> Identity Service

/api/waste-reports/**       -> Waste Report Service
/api/waste-types/**         -> Waste Report Service
/api/districts/**           -> Waste Report Service

/api/collection-requests/** -> Collection Service
/api/assignments/**         -> Collection Service
/api/collections/**         -> Collection Service

/api/notifications/**       -> Engagement Service
/api/rewards/**             -> Engagement Service
/api/feedbacks/**           -> Engagement Service
/api/dashboard/**           -> Engagement Service
```

Trong phase đầu, nếu chưa làm gateway, vẫn có thể chạy trực tiếp từng service bằng port riêng:

```txt
Identity.Api     -> https://localhost:7101
WasteReport.Api  -> https://localhost:7102
Collection.Api   -> https://localhost:7103
Engagement.Api   -> https://localhost:7104
Gateway          -> https://localhost:7000
```

---

## 9. Internal communication

Phase 1 nên dùng HTTP client để dễ refactor, chưa cần message broker.

Tạo các client trong `BuildingBlocks.Shared` hoặc từng service application:

```txt
IIdentityClient
IWasteReportClient
ICollectionClient
IEngagementClient
```

Ví dụ:

```csharp
public interface IIdentityClient
{
    Task<UserSummaryDto?> GetUserAsync(int userId);
    Task<EnterpriseProfileDto?> GetEnterpriseProfileAsync(int enterpriseId);
    Task<CollectorProfileDto?> GetCollectorProfileAsync(int collectorId);
    Task AddUserPointsAsync(int userId, int points, string reason);
    Task DeductUserPointsAsync(int userId, int points, string reason);
}
```

```csharp
public interface IEngagementClient
{
    Task CreateNotificationAsync(int userId, string content);
    Task AddRewardTransactionAsync(AddRewardTransactionRequest request);
}
```

Không gọi database trực tiếp giữa service.

---

## 10. File upload/static files

Code hiện tại có upload folder:

```txt
wwwroot/uploads/waste-reports
wwwroot/uploads/collection-proofs
wwwroot/uploads/issue-proofs
```

Sau khi tách:

```txt
WasteReport.Api/wwwroot/uploads/waste-reports
Collection.Api/wwwroot/uploads/collection-proofs
Collection.Api/wwwroot/uploads/issue-proofs
```

Hoặc tốt hơn:

```txt
Shared upload root từ config:
FileStorage:RootPath
FileStorage:PublicBaseUrl
```

Không làm mất logic lưu ảnh hiện tại:

- Waste report image.
- Before image.
- After image.
- Issue proof image.
- Feedback image nếu có.

---

## 11. Thứ tự refactor an toàn

### Phase 0 - Backup và build baseline

1. Tạo branch mới:

```bash
git checkout -b refactor/microservices-schemas
```

2. Build project cũ để xác nhận baseline:

```bash
dotnet restore
dotnet build
```

3. Không sửa logic trước khi build xanh.

---

### Phase 1 - Tạo solution structure mới

1. Tạo 4 Web API projects.
2. Tạo shared project.
3. Copy cấu hình JWT, Swagger, CORS, localization từ `Program.cs` cũ sang từng service cần thiết.
4. Mỗi service có `Program.cs` riêng.
5. Mỗi service có `appsettings.json` riêng.
6. Mỗi service dùng chung connection string nhưng migration history khác schema.

---

### Phase 2 - Tách Identity Service trước

1. Move Auth/User code.
2. Tạo IdentityDbContext.
3. Tạo repositories riêng cho Identity.
4. Tạo migration cho identity schema.
5. Build Identity Service.
6. Test:
   - Register.
   - Verify OTP.
   - Login.
   - Change password.
   - Forgot/reset password.
   - Get user.
   - Update profile.
   - Collector availability.

Không làm các service khác trước khi Identity chạy ổn.

---

### Phase 3 - Tách Waste Report Service

1. Move WasteReports/WasteTypes/Districts.
2. Tạo WasteReportDbContext.
3. Tạo repositories riêng.
4. Thay direct access tới users/enterprise bằng `IIdentityClient`.
5. Thay direct create notification bằng `IEngagementClient` hoặc tạm stub nếu Engagement chưa xong.
6. Thay direct create collection request bằng `ICollectionClient` hoặc tạm stub nếu Collection chưa xong.
7. Build và test:
   - Create waste report.
   - Duplicate detection 30m.
   - District resolve bằng PostGIS.
   - Accept report.
   - Reject report.
   - Update/cancel report.

---

### Phase 4 - Tách Collection Service

1. Move CollectionRequests/Assignments/Collections.
2. Tạo CollectionDbContext.
3. Tạo repositories riêng.
4. Thay direct report access bằng `IWasteReportClient`.
5. Thay direct user/collector/enterprise access bằng `IIdentityClient`.
6. Thay direct notification/reward bằng `IEngagementClient`.
7. Build và test:
   - Create collection request from accepted report.
   - Assign collector.
   - Reassign collector.
   - Cancel assignment.
   - Get my assignments.
   - Start collection.
   - Arrived with before image.
   - Report issue.
   - Complete with after image and actual weights.

---

### Phase 5 - Tách Engagement Service

1. Move Notification/Reward/Feedback/Dashboard.
2. Tạo EngagementDbContext.
3. Tạo repositories riêng.
4. Thay direct report/assignment/user access bằng service clients.
5. Build và test:
   - Get notifications.
   - Mark read/read all.
   - Get rewards catalog.
   - Get balance.
   - Redeem reward.
   - Reward history.
   - Create feedback.
   - Resolve/reject feedback.
   - Admin dashboard.

---

### Phase 6 - Gateway và frontend compatibility

1. Thêm ApiGateway bằng YARP hoặc giữ direct route nếu chưa cần.
2. Đảm bảo frontend vẫn gọi path cũ:

```txt
/api/auth/login
/api/waste-reports
/api/collection-requests
/api/notifications
...
```

3. Nếu dùng gateway, frontend chỉ đổi base URL sang gateway.
4. Không bắt frontend phải gọi 4 base URL khác nhau nếu không cần.

---

## 12. Migration strategy từ public schema sang schema mới

Nếu database hiện tại đang có table ở `public`, cần tạo migration hoặc SQL move schema.

Option A - Move table sang schema mới:

```sql
alter table if exists public.roles set schema identity;
alter table if exists public.users set schema identity;
alter table if exists public.enterprise_profiles set schema identity;
alter table if exists public.collector_profiles set schema identity;

alter table if exists public.wastereports set schema waste;
alter table if exists public.wastetypes set schema waste;
alter table if exists public.ai_waste_predictions set schema waste;
alter table if exists public.districts set schema waste;

alter table if exists public.collectionrequests set schema collection;
alter table if exists public.collectorassignments set schema collection;
alter table if exists public.collectionconfirmations set schema collection;
alter table if exists public.collection_details set schema collection;

alter table if exists public.notifications set schema engagement;
alter table if exists public.rewards set schema engagement;
alter table if exists public.rewardtransactions set schema engagement;
alter table if exists public.feedbacks set schema engagement;
```

Nếu có join table many-to-many giữa report và waste type, tìm tên thật trong migration/database rồi move sang `waste` schema.

Option B - Tạo table mới rồi copy data:

Chỉ dùng nếu `alter table set schema` gây lỗi constraint hoặc muốn kiểm soát migration kỹ hơn.

Sau migration phải kiểm tra sequence/identity vẫn đúng:

```sql
select setval(pg_get_serial_sequence('identity.users', 'user_id'), coalesce(max(user_id), 1)) from identity.users;
```

Làm tương tự cho các bảng có serial/identity.

---

## 13. Các điểm dễ mất logic cần chú ý

Không được bỏ các logic sau:

### Waste report

- Check duplicate trong radius 30m.
- Validate tọa độ.
- Validate waste type active.
- Resolve district bằng PostGIS.
- Chỉ enterprise quản lý đúng district mới accept được report.
- Accept tạo collection request.
- Accept/reject tạo notification.

### Collection

- Collector chỉ thao tác assignment của mình.
- Không start nhiều active trip cùng lúc.
- Status flow:

```txt
Assigned -> OnTheWay -> Arrived -> Completed
Assigned/OnTheWay/Arrived -> Declined/ReportedIssue/Cancelled tùy logic cũ
```

- Arrived bắt buộc before image.
- Complete bắt buộc after image.
- Complete bắt buộc actual weights > 0.
- Complete tạo confirmation/details.
- Complete update request/report status.
- Complete cộng reward points và tạo transaction.
- Issue flow giữ đầy đủ issue type, description, proof image.

### Feedback

- Resolve/reject giữ nguyên status.
- Resolve giữ logic ảnh hưởng assignment/report/reward/warning/notification nếu có.
- Không bỏ warning collector.
- Không bỏ revert reward nếu code cũ có.

### Identity

- OTP cache.
- Email template.
- Password hashing/verification.
- JWT claims.
- Role authorization.
- User status Active/Inactive.
- Collector availability.
- Enterprise managed district.

### Dashboard

- Không bỏ cache nếu đang dùng.
- Không bỏ các số liệu admin dashboard.
- Nếu dashboard cần dữ liệu từ nhiều service, dùng HTTP clients hoặc tạm query read-only theo schema trong phase cuối. Nếu dùng query read-only trực tiếp, ghi rõ đây là temporary read model, không dùng cho write business logic.

---

## 14. Repository/UnitOfWork rule

Không dùng lại `IUnitOfWork` cũ toàn hệ thống.

Mỗi service có UnitOfWork riêng hoặc bỏ UnitOfWork và dùng DbContext trực tiếp.

Ví dụ:

```txt
IdentityUnitOfWork
WasteReportUnitOfWork
CollectionUnitOfWork
EngagementUnitOfWork
```

Không để `CollectionService` gọi `_uow.WasteReports` hoặc `_uow.Users` nữa.

Không để `WasteReportService` gọi `_uow.CollectionRequests` hoặc `_uow.Notifications` nữa.

Không để `FeedbackService` gọi trực tiếp assignment/report/user repository nữa.

---

## 15. Naming rule

Nên đổi tên entity cho chuẩn C# nhưng không bắt buộc trong phase đầu.

Nếu đổi thì map table rõ ràng:

```txt
Wastereport        -> WasteReport
Wastetype          -> WasteType
Collectionrequest  -> CollectionRequest
Collectorassignment -> CollectorAssignment
Collectionconfirmation -> CollectionConfirmation
Rewardtransaction -> RewardTransaction
```

Nếu đổi tên class, phải đảm bảo DTO mapping/controller response không bị đổi sai.

---

## 16. Build/test acceptance criteria

Sau refactor, các lệnh sau phải chạy được:

```bash
dotnet restore
dotnet build
```

Từng service chạy được Swagger:

```txt
Identity.Api/swagger
WasteReport.Api/swagger
Collection.Api/swagger
Engagement.Api/swagger
```

Các flow chính phải test được end-to-end:

### Flow 1 - Auth

```txt
Register citizen -> Verify OTP -> Login -> Get profile
```

### Flow 2 - Waste report

```txt
Citizen login -> Create waste report -> Enterprise accept -> Collection request được tạo
```

### Flow 3 - Collection

```txt
Enterprise assign collector -> Collector start -> Arrived upload before image -> Complete upload after image + actual weights
```

Expected:

```txt
assignment = Completed
collection request = Completed
waste report = Collected/Completed theo status cũ
reward transaction created
notification created
user points updated
```

### Flow 4 - Issue

```txt
Collector start/arrived -> Report issue -> request status Issue -> issue reason/image saved
```

### Flow 5 - Feedback

```txt
Citizen create feedback -> Admin resolve/reject -> related notification/reward/warning logic still works
```

### Flow 6 - Admin dashboard

```txt
Admin login -> Get dashboard by year -> data returned, no exception
```

---

## 17. Output mong muốn sau khi refactor

Sau khi hoàn thành, trả về summary gồm:

1. Danh sách project/service đã tạo.
2. Danh sách schema/table đã mapping.
3. Các endpoint public giữ nguyên.
4. Các endpoint internal mới.
5. Những logic đã preserve.
6. Những logic đã tách từ direct DB call sang HTTP client/event.
7. Cách chạy từng service.
8. Cách chạy migration.
9. Các lỗi còn lại nếu có.

---

## 18. Nguyên tắc quan trọng nhất

Không refactor bằng cách viết lại toàn bộ rồi bỏ logic cũ.

Cách làm đúng:

```txt
Move -> Compile -> Replace dependency -> Compile -> Test flow -> Then continue
```

Ưu tiên bảo toàn behavior trước, clean architecture sau.

Nếu gặp logic phụ thuộc nhiều bảng khác service, không xoá logic đó. Hãy chuyển thành:

```txt
HTTP internal client
hoặc Integration event
hoặc temporary adapter có TODO rõ ràng
```

Không được để project build lỗi ở cuối.
