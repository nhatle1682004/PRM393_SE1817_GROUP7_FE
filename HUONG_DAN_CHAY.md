# Hướng Dẫn Chạy BackEnd-Microservices

File này hướng dẫn chạy dự án `BackEnd-Microservices` trên Windows bằng PowerShell.

## 1. Yêu cầu trước khi chạy

Cần cài sẵn:

- .NET SDK 8
- Docker Desktop
- dotnet-ef

Kiểm tra:

```powershell
dotnet --version
docker --version
dotnet ef --version
```

Nếu chưa có `dotnet ef`, cài bằng lệnh:

```powershell
dotnet tool install --global dotnet-ef
```

Nếu đã cài nhưng lệnh `dotnet ef` chưa nhận, đóng PowerShell rồi mở lại.

## 2. Vào thư mục project

```powershell
cd D:\Learning\refactor\BackEnd-Microservices
```

## 3. Chạy PostgreSQL bằng Docker

Dự án dùng chung 1 PostgreSQL database và tách bảng theo 4 schema:

- `identity`
- `waste`
- `collection`
- `engagement`

Chạy database:

```powershell
docker compose up -d postgres
```

Kiểm tra container:

```powershell
docker ps
```

Database mặc định:

```txt
Host: localhost
Port: 5432
Database: waste_collection_platform
Username: postgres
Password: 12345
```

## 4. Restore và build solution

```powershell
dotnet restore .\BackEnd-Microservices.sln
dotnet build .\BackEnd-Microservices.sln
```

Build thành công khi thấy:

```txt
Build succeeded.
0 Error(s)
```

## 5. Tạo database schema bằng migration

Chạy lần lượt 4 lệnh sau sau khi PostgreSQL đã chạy.

### IdentityService

```powershell
dotnet ef database update --project .\src\Services\IdentityService\IdentityService.Infrastructure --startup-project .\src\Services\IdentityService\IdentityService.Api --context IdentityDbContext
```

### WasteReportService

```powershell
dotnet ef database update --project .\src\Services\WasteReportService\WasteReportService.Infrastructure --startup-project .\src\Services\WasteReportService\WasteReportService.Api --context WasteReportDbContext
```

### CollectionService

```powershell
dotnet ef database update --project .\src\Services\CollectionService\CollectionService.Infrastructure --startup-project .\src\Services\CollectionService\CollectionService.Api --context CollectionDbContext
```

### EngagementService

```powershell
dotnet ef database update --project .\src\Services\EngagementService\EngagementService.Infrastructure --startup-project .\src\Services\EngagementService\EngagementService.Api --context EngagementDbContext
```

## 6. Chạy từng service local

Mở 5 cửa sổ PowerShell riêng.

Ở mỗi cửa sổ, vào thư mục project:

```powershell
cd D:\Learning\refactor\BackEnd-Microservices
```

Sau đó chạy từng service.

### Terminal 1 - IdentityService

```powershell
dotnet run --project .\src\Services\IdentityService\IdentityService.Api --urls http://localhost:5001
```

Swagger:

```txt
http://localhost:5001/swagger
```

### Terminal 2 - WasteReportService

```powershell
dotnet run --project .\src\Services\WasteReportService\WasteReportService.Api --urls http://localhost:5002
```

Swagger:

```txt
http://localhost:5002/swagger
```

### Terminal 3 - CollectionService

```powershell
dotnet run --project .\src\Services\CollectionService\CollectionService.Api --urls http://localhost:5003
```

Swagger:

```txt
http://localhost:5003/swagger
```

### Terminal 4 - EngagementService

```powershell
dotnet run --project .\src\Services\EngagementService\EngagementService.Api --urls http://localhost:5004
```

Swagger:

```txt
http://localhost:5004/swagger
```

### Terminal 5 - ApiGateway

```powershell
dotnet run --project .\src\ApiGateway --urls http://localhost:5000
```

Gateway URL:

```txt
http://localhost:5000
```

## 7. Route qua ApiGateway

Khi gọi API từ frontend hoặc Postman, ưu tiên gọi qua gateway:

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

## 8. Chạy toàn bộ bằng Docker Compose

Cách này build và chạy toàn bộ service trong container:

```powershell
cd D:\Learning\refactor\BackEnd-Microservices
docker compose up --build
```

Các port:

```txt
ApiGateway:          http://localhost:5000
IdentityService:     http://localhost:5001
WasteReportService:  http://localhost:5002
CollectionService:   http://localhost:5003
EngagementService:   http://localhost:5004
PostgreSQL:          localhost:5432
```

Lưu ý: ứng dụng hiện không tự chạy migration khi start. Nếu chạy lần đầu, hãy chạy các lệnh migration ở mục 5 trước.

## 9. Dừng project

Nếu chạy local bằng `dotnet run`, nhấn:

```txt
Ctrl + C
```

trong từng terminal.

Nếu chạy Docker:

```powershell
docker compose down
```

Nếu muốn xóa luôn data PostgreSQL Docker volume:

```powershell
docker compose down -v
```

## 10. Lỗi thường gặp

### Lỗi port đã được sử dụng

Kiểm tra process đang dùng port:

```powershell
netstat -ano | findstr :5001
netstat -ano | findstr :5002
netstat -ano | findstr :5003
netstat -ano | findstr :5004
netstat -ano | findstr :5000
```

Tắt process hoặc đổi port khi chạy `dotnet run --urls`.

### Lỗi không connect được PostgreSQL

Kiểm tra container:

```powershell
docker ps
```

Nếu chưa chạy:

```powershell
docker compose up -d postgres
```

### Lỗi PostGIS hoặc geometry

`WasteReportService` dùng PostGIS để resolve district bằng cột `waste.districts.boundary`.

Docker Compose đã dùng image:

```txt
postgis/postgis:16-3.4
```

Nếu dùng PostgreSQL tự cài ngoài Docker, cần bật extension:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

### Lỗi 401 khi gọi service khác

Các public API vẫn dùng JWT. Hãy login ở IdentityService để lấy token, rồi gửi header:

```txt
Authorization: Bearer <token>
```

Các endpoint `/internal/*` dùng `X-Internal-Api-Key` cho service-to-service và không nên gọi trực tiếp từ frontend.

## 11. Thứ tự test nhanh

1. Mở `http://localhost:5001/swagger`
2. Register user
3. Verify OTP nếu flow yêu cầu
4. Login lấy JWT
5. Dùng JWT gọi API qua gateway `http://localhost:5000`
6. Tạo waste report
7. Enterprise accept report
8. Kiểm tra collection request được tạo
9. Assign collector
10. Complete collection
11. Kiểm tra notification và reward transaction

