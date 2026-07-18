# TÀI LIỆU DỰ ÁN: WASTE COLLECTION MANAGEMENT SYSTEM

# 1. Tổng quan dự án
- **Tên dự án:** Hệ thống Quản lý Thu gom Rác thải (Waste Collection Management System)
- **Mục đích:** Giúp cư dân báo cáo rác thải, doanh nghiệp quản lý thu gom, nhân viên thực hiện nhiệm vụ và quản trị viên giám sát toàn bộ hệ thống.
- **Công nghệ sử dụng:**
    - **Frontend:** Flutter (Dart)
    - **Backend:** C# .NET Core (Dựa trên cấu trúc API)
    - **Thư viện chính:** 
        - `dio`: Giao tiếp với API.
        - `flutter_secure_storage`: Lưu trữ Token đăng nhập an toàn.
        - `geolocator` & `flutter_map`: Xử lý vị trí và bản đồ.
        - `fl_chart`: Hiển thị biểu đồ thống kê.
- **Kiến trúc:** MVP (Model - View - Presenter). Việc tách biệt UI (View) và Logic (Presenter) giúp code dễ bảo trì và mở rộng.

# 2. Cấu trúc thư mục

Dưới đây là cách tổ chức code trong thư mục `lib/`:

- `lib/data/`:
    - `models/`: Chứa các lớp dữ liệu (User, Report, WasteType...) để chuyển đổi từ JSON sang đối tượng Dart.
    - `constants/`: Các hằng số dùng chung như ID của các quyền (Role ID).
- `lib/services/`:
    - Chứa các file xử lý logic kết nối server (API).
    - Ví dụ: `auth_service.dart` lo việc đăng nhập, `storage_service.dart` lo việc lưu Token.
- `lib/presentation/`:
    - Chia theo từng tính năng/màn hình.
    - Mỗi tính năng thường có 3 file: `_screen.dart` (UI), `_presenter.dart` (Logic), `_contract.dart` (Giao diện kết nối giữa UI và Logic).
- `lib/config/`:
    - `api_config.dart`: Lưu trữ tất cả URL và các đầu Endpoint của API.
- `lib/widgets/`:
    - Các thành phần giao diện dùng chung ở nhiều nơi (Button, TextField, Layout...).
- `main.dart`: File chạy chính của ứng dụng, kiểm tra trạng thái đăng nhập để chuyển hướng màn hình.

# 3. Danh sách màn hình (Screen/Page)

| Màn hình | File code | Chức năng | API sử dụng |
|---|---|---|---|
| **Đăng nhập** | `login_screen.dart` | Xác thực người dùng | `/auth/login` |
| **Đăng ký** | `register_screen.dart` | Tạo tài khoản cho cư dân | `/auth/register` |
| **Trang chủ Cư dân** | `home_screen.dart` | Xem thống kê, điểm thưởng | `/users/me/profile`, `/rewards/balance` |
| **Báo cáo rác** | `create_report_screen.dart` | Chụp ảnh, chọn vị trí rác | `/waste-reports`, `/waste-reports/predict` (AI) |
| **Lịch sử báo cáo** | `history_screen.dart` | Xem các báo cáo đã gửi | `/waste-reports` |
| **Doanh nghiệp** | `enterprise_screen.dart` | Quản lý báo cáo và phân công | `/waste-reports`, `/assignments` |
| **Nhân viên thu gom** | `collector_screen.dart` | Nhận nhiệm vụ, cập nhật trạng thái | `/assignments/my-assignments`, `/collections/{id}/complete` |
| **Quản trị viên** | `admin_screen.dart` | Xem biểu đồ, quản lý người dùng | `/dashboard/admin`, `/admin/users` |

# 4. Phân tích luồng hoạt động của màn hình chính

## Màn hình Báo cáo rác (Create Report)

**Luồng hoạt động:**
1. **Người dùng thấy gì?**: Thấy các nút chụp ảnh, chọn loại rác, bản đồ xác định vị trí và nút gửi.
2. **Code chạy như thế nào?**: 
    - Khi mở, `ReportPresenter` sẽ gọi API lấy danh sách loại rác (`/waste-types`).
    - Khi chụp ảnh, ảnh được gửi lên API AI (`/predict`) để tự động gợi ý loại rác.
    - Khi bấm "Gửi", Presenter sẽ thu thập ảnh, tọa độ và ghi chú để gửi lên Server.
3. **File gọi**: `report_presenter.dart` gọi `ApiService.post`.
4. **API trả về**: ID của báo cáo mới và thông báo thành công.
5. **Hiển thị**: UI hiển thị Dialog chúc mừng và xóa dữ liệu cũ trong form.

---

## Màn hình Nhân viên thu gom (Collector Screen)

**Luồng hoạt động:**
1. **Mở app**: `collector_presenter.dart` gọi API lấy danh sách nhiệm vụ được giao (`/assignments/my-assignments`).
2. **Nhận việc**: Collector bấm "Start", gọi API `/collections/{id}/start` để đổi trạng thái thành "Đang di chuyển".
3. **Hoàn thành**: Collector chụp ảnh rác đã dọn, bấm "Complete", gọi API `/complete`.
4. **Kết quả**: Nhiệm vụ chuyển sang trạng thái "Hoàn thành", hệ thống ghi nhận kết quả.

# 5. Danh sách API tiêu biểu

| Method | Endpoint | Mục đích | Màn hình |
|---|---|---|---|
| POST | `/auth/login` | Đăng nhập lấy Token | Login |
| GET | `/waste-reports` | Lấy danh sách báo cáo | History / Enterprise |
| POST | `/waste-reports` | Gửi báo cáo rác mới (Multipart ảnh) | Create Report |
| GET | `/dashboard/admin` | Lấy số liệu thống kê tổng quát | Admin Dashboard |
| PUT | `/assignments/{id}` | Phân công nhân viên thu gom | Enterprise |

# 6. Luồng nghiệp vụ chính

### Luồng Báo cáo và Thu gom:

**Cư dân (Citizen):**
Chụp ảnh rác → Chọn vị trí → Bấm Gửi → (Hệ thống lưu báo cáo ở trạng thái `Pending`)

↓

**Doanh nghiệp (Enterprise):**
Xem danh sách `Pending` → Phê duyệt → Chọn nhân viên thu gom (Collector) → (Hệ thống tạo `Assignment`)

↓

**Nhân viên (Collector):**
Nhận thông báo → Xem vị trí trên bản đồ → Đến nơi và dọn dẹp → Chụp ảnh hoàn thành → (Hệ thống đổi trạng thái thành `Completed`)

↓

**Hệ thống:**
Tặng điểm thưởng cho Cư dân đã báo cáo rác.

# 7. Các câu hỏi giảng viên có thể hỏi

- **Tại sao sử dụng MVP mà không viết hết vào Screen?**
  - *Trả lời:* Để tách biệt giao diện và logic. Giúp code gọn gàng, dễ tìm lỗi và có thể viết Unit Test cho phần Logic (Presenter) mà không cần chạy giao diện.

- **Dữ liệu được lưu trữ như thế nào khi tắt app?**
  - *Trả lời:* Ứng dụng dùng `flutter_secure_storage` để lưu JWT Token. Mỗi khi mở app, `main.dart` sẽ đọc token này, nếu còn hiệu lực sẽ tự động vào thẳng trang chủ.

- **Làm sao ứng dụng biết được vị trí của rác?**
  - *Trả lời:* Dùng thư viện `geolocator` để lấy GPS hiện tại của điện thoại và `flutter_map` để cho phép người dùng điều chỉnh vị trí chính xác trên bản đồ.

- **Xử lý lỗi API như thế nào?**
  - *Trả lời:* Trong Presenter, các lệnh gọi API được bọc trong khối `try-catch`. Nếu có lỗi (mất mạng, server lỗi), ứng dụng sẽ hiển thị thông báo (SnackBar/Toast) để người dùng biết thay vì bị treo app.
