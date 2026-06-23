# Hướng dẫn chạy BackEnd-Microservices

Tài liệu này dành cho project `BackEnd-Microservices` chạy bằng Docker Compose + PostgreSQL/PostGIS. Project dùng **1 database PostgreSQL** tên `waste_collection_platform`, nhưng tách bảng theo nhiều schema:

- `identity`
- `waste`
- `collection`
- `engagement`

## 1. Yêu cầu cài đặt

Cần cài sẵn:

- Docker Desktop
- .NET SDK 8
- EF Core CLI tool `dotnet-ef`
- pgAdmin 4 hoặc DBeaver nếu muốn xem database

Kiểm tra:

```cmd
docker --version
dotnet --version
dotnet ef --version
```

Nếu chưa có `dotnet ef`:

```cmd
dotnet tool install --global dotnet-ef
```

## 2. Vào thư mục project

```cmd
cd D:\Learning\refactor\BackEnd-Microservices
```

## 3. chạy dự án docker 

```cmd
docker compose up -d --build
```

## 4. Kiểm tra PostGIS

Chạy:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

Kiểm tra version:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "SELECT PostGIS_Version();"
```

Nếu ra version kiểu này là OK:

```txt
3.4 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
```

## 5. Chạy migration cho 4 service

Chạy lần lượt 4 lệnh dưới đây từ thư mục root `BackEnd-Microservices`.

### 5.1 IdentityService

```cmd
dotnet ef database update --project src\Services\IdentityService\IdentityService.Infrastructure\IdentityService.Infrastructure.csproj --startup-project src\Services\IdentityService\IdentityService.Api\IdentityService.Api.csproj --context IdentityDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"
```

Kiểm tra bảng Identity:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "SELECT to_regclass('identity.users');"
```

Kết quả đúng phải là:

```txt
identity.users
```

Nếu kết quả rỗng, nghĩa là migration chưa chạy vào đúng database container.

### 5.2 WasteReportService

```cmd
dotnet ef database update --project src\Services\WasteReportService\WasteReportService.Infrastructure\WasteReportService.Infrastructure.csproj --startup-project src\Services\WasteReportService\WasteReportService.Api\WasteReportService.Api.csproj --context WasteReportDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"
```

Kiểm tra schema waste:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dt waste.*"
```

### 5.3 CollectionService

```cmd
dotnet ef database update --project src\Services\CollectionService\CollectionService.Infrastructure\CollectionService.Infrastructure.csproj --startup-project src\Services\CollectionService\CollectionService.Api\CollectionService.Api.csproj --context CollectionDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"
```

Kiểm tra schema collection:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dt collection.*"
```

### 5.4 EngagementService

```cmd
dotnet ef database update --project src\Services\EngagementService\EngagementService.Infrastructure\EngagementService.Infrastructure.csproj --startup-project src\Services\EngagementService\EngagementService.Api\EngagementService.Api.csproj --context EngagementDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"
```

Kiểm tra schema engagement:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dt engagement.*"
```

## 6. Kiểm tra tất cả schema

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dn"
```

Nên thấy các schema:

```txt
identity
waste
collection
engagement
```

Kiểm tra tất cả bảng:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dt identity.*"
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dt waste.*"
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dt collection.*"
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "\dt engagement.*"
```

## 7. URL các service

Sau khi chạy Docker Compose:

```txt
ApiGateway:          http://localhost:5000
IdentityService:     http://localhost:5001
WasteReportService:  http://localhost:5002
CollectionService:   http://localhost:5003
EngagementService:   http://localhost:5004
PostgreSQL:          localhost:5433
```

Swagger trực tiếp từng service:

```txt
http://localhost:5001/swagger
http://localhost:5002/swagger
http://localhost:5003/swagger
http://localhost:5004/swagger
```

Frontend/Postman nên gọi qua Gateway:

```txt
http://localhost:5000/api/auth
http://localhost:5000/api/users
http://localhost:5000/api/waste-reports
http://localhost:5000/api/waste-types
http://localhost:5000/api/districts
http://localhost:5000/api/collection-requests
http://localhost:5000/api/assignments
http://localhost:5000/api/collections
http://localhost:5000/api/notifications
http://localhost:5000/api/rewards
http://localhost:5000/api/feedbacks
http://localhost:5000/api/dashboard
```

## 8. Kết nối pgAdmin 4 vào Docker PostgreSQL

Tạo server mới trong pgAdmin:

```txt
Host name/address: localhost
Port: 5433
Maintenance database: waste_collection_platform
Username: postgres
Password: 12345
```

Nếu pgAdmin đang connect `localhost:5432`, rất có thể bạn đang xem PostgreSQL local trên máy chứ không phải Docker. Khi đó có thể thấy bảng trong pgAdmin nhưng app Docker vẫn báo không có bảng.

Để chắc chắn app Docker thấy bảng hay không, luôn kiểm tra bằng lệnh:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "SELECT to_regclass('identity.users');"
```

## 9. Sau khi sửa code thì chạy lại Docker thế nào?

Nếu sửa code bất kỳ service nào:

```cmd
dotnet build BackEnd-Microservices.sln
docker compose up -d --build
```

Nếu muốn build sạch không dùng cache:

```cmd
docker compose build --no-cache
docker compose up -d
```

Nếu chỉ sửa một service, ví dụ `collection-service`:

```cmd
docker compose build collection-service --no-cache
docker compose up -d collection-service
```

## 10. Nếu sửa entity hoặc migration

Nếu bạn sửa entity và cần tạo migration mới, dùng lệnh `migrations add` tương ứng.

Ví dụ IdentityService:

```cmd
dotnet ef migrations add TenMigrationMoi --project src\Services\IdentityService\IdentityService.Infrastructure\IdentityService.Infrastructure.csproj --startup-project src\Services\IdentityService\IdentityService.Api\IdentityService.Api.csproj --context IdentityDbContext --output-dir Migrations
```

Sau đó apply migration:

```cmd
dotnet ef database update --project src\Services\IdentityService\IdentityService.Infrastructure\IdentityService.Infrastructure.csproj --startup-project src\Services\IdentityService\IdentityService.Api\IdentityService.Api.csproj --context IdentityDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"
```

Không nên sửa trực tiếp migration cũ nếu database đã apply migration đó. Hãy tạo migration mới.

## 11. Các lỗi thường gặp

### Lỗi 1: `No such host is known`

Ví dụ:

```txt
No such host is known.
```

Nguyên nhân: chạy `dotnet ef` từ Windows nhưng connection string dùng `Host=postgres`.

Cách sửa: khi chạy `dotnet ef` từ Windows, dùng:

```txt
Host=localhost;Port=5433
```

### Lỗi 2: `relation "identity.users" does not exist`

Ví dụ:

```txt
relation "identity.users" does not exist
```

Nguyên nhân: service đang connect đúng PostgreSQL nhưng database container chưa có bảng `identity.users`, hoặc bạn migrate nhầm vào PostgreSQL local.

Cách kiểm tra:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "SELECT to_regclass('identity.users');"
```

Nếu kết quả rỗng, chạy lại migration Identity với `Host=localhost;Port=5433`.

### Lỗi 3: pgAdmin thấy bảng nhưng Docker vẫn báo không có bảng

Nguyên nhân: pgAdmin đang xem PostgreSQL local khác với PostgreSQL container.

Cách sửa: pgAdmin phải connect:

```txt
Host: localhost
Port: 5433
Database: waste_collection_platform
```

Không dùng port `5432` nếu Docker đã map sang `5433`.

### Lỗi 4: `extension "postgis" is not available`

Nguyên nhân: đang connect vào PostgreSQL thường, không phải image PostGIS.

Cách kiểm tra:

```cmd
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "SELECT PostGIS_Version();"
```

Nếu không có version, kiểm tra image trong compose phải là:

```yaml
image: postgis/postgis:16-3.4
```

### Lỗi 5: `Exception while reading from stream`

Nếu xảy ra khi migration với `Port=5433`, kiểm tra `docker compose ps`.

Đúng phải là:

```txt
0.0.0.0:5433->5432/tcp
```

Nếu thấy:

```txt
0.0.0.0:5433->5433/tcp
```

thì sửa compose:

```yaml
ports:
  - "5433:5432"
```

## 12. Reset sạch database Docker

Chỉ dùng khi muốn xóa toàn bộ data cũ trong Docker database.

Cẩn thận: lệnh này xóa volume PostgreSQL.

```cmd
docker compose down -v
docker compose up -d postgres
```

Sau đó chạy lại toàn bộ migration ở mục 7.

## 13. Quy trình chạy nhanh từ đầu

Dùng khi clone project mới hoặc reset DB:

```cmd
cd D:\Learning\refactor\BackEnd-Microservices

docker compose up -d postgres

docker compose exec postgres psql -U postgres -d waste_collection_platform -c "CREATE EXTENSION IF NOT EXISTS postgis;"
docker compose exec postgres psql -U postgres -d waste_collection_platform -c "SELECT PostGIS_Version();"

dotnet restore BackEnd-Microservices.sln
dotnet build BackEnd-Microservices.sln

dotnet ef database update --project src\Services\IdentityService\IdentityService.Infrastructure\IdentityService.Infrastructure.csproj --startup-project src\Services\IdentityService\IdentityService.Api\IdentityService.Api.csproj --context IdentityDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"

dotnet ef database update --project src\Services\WasteReportService\WasteReportService.Infrastructure\WasteReportService.Infrastructure.csproj --startup-project src\Services\WasteReportService\WasteReportService.Api\WasteReportService.Api.csproj --context WasteReportDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"

dotnet ef database update --project src\Services\CollectionService\CollectionService.Infrastructure\CollectionService.Infrastructure.csproj --startup-project src\Services\CollectionService\CollectionService.Api\CollectionService.Api.csproj --context CollectionDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"

dotnet ef database update --project src\Services\EngagementService\EngagementService.Infrastructure\EngagementService.Infrastructure.csproj --startup-project src\Services\EngagementService\EngagementService.Api\EngagementService.Api.csproj --context EngagementDbContext --connection "Host=localhost;Port=5433;Database=waste_collection_platform;Username=postgres;Password=12345;Include Error Detail=true"

docker compose up -d --build

docker compose ps
```
