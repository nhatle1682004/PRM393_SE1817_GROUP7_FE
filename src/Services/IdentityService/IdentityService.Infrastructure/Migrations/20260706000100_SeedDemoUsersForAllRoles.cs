using IdentityService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IdentityService.Infrastructure.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(IdentityDbContext))]
    [Migration("20260706000100_SeedDemoUsersForAllRoles")]
    public partial class SeedDemoUsersForAllRoles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
-- Người dùng mẫu. Mật khẩu tất cả tài khoản: Password123!
UPDATE identity.roles SET role_name = 'Citizen', description = 'Người dân' WHERE role_id = 1;
UPDATE identity.roles SET role_name = '__TEMP_COLLECTOR__' WHERE role_id = 2;
UPDATE identity.roles SET role_name = 'Collector', description = 'Nhân viên thu gom' WHERE role_id = 3;
UPDATE identity.roles SET role_name = 'Enterprise', description = 'Doanh nghiệp thu gom' WHERE role_id = 2;
UPDATE identity.roles SET role_name = 'Admin', description = 'Quản trị viên hệ thống' WHERE role_id = 4;

INSERT INTO identity.users (user_id, role_id, full_name, email, password, phone, status, created_at, total_points)
VALUES
  (9001, 1, 'Nguyễn Minh An', 'citizen@example.com', '$2a$10$/xxbO9TBUyJ3AgYeR4k/pO8Q372Rtfnw8SdkJbtuS3nKUOeaY6RDq', '0900000001', 'Active', TIMESTAMP '2026-01-01 00:00:00', 120),
  (9002, 2, 'Công ty Môi Trường Xanh', 'enterprise@example.com', '$2a$10$/xxbO9TBUyJ3AgYeR4k/pO8Q372Rtfnw8SdkJbtuS3nKUOeaY6RDq', '0900000002', 'Active', TIMESTAMP '2026-01-01 00:00:00', 0),
  (9003, 3, 'Trần Văn Thu Gom', 'collector@example.com', '$2a$10$/xxbO9TBUyJ3AgYeR4k/pO8Q372Rtfnw8SdkJbtuS3nKUOeaY6RDq', '0900000003', 'Active', TIMESTAMP '2026-01-01 00:00:00', 0),
  (9004, 4, 'Quản Trị Hệ Thống', 'admin@example.com', '$2a$10$/xxbO9TBUyJ3AgYeR4k/pO8Q372Rtfnw8SdkJbtuS3nKUOeaY6RDq', '0900000004', 'Active', TIMESTAMP '2026-01-01 00:00:00', 0)
ON CONFLICT (email) DO UPDATE SET
  role_id = EXCLUDED.role_id,
  full_name = EXCLUDED.full_name,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  status = EXCLUDED.status,
  total_points = EXCLUDED.total_points;

INSERT INTO identity.enterprise_profiles (enterprise_id, managed_district_id, created_at)
VALUES (9002, 13, TIMESTAMP '2026-01-01 00:00:00')
ON CONFLICT (enterprise_id) DO UPDATE SET managed_district_id = EXCLUDED.managed_district_id;

INSERT INTO identity.collector_profiles (collector_id, enterprise_id, is_available, availability_updated_at, warning_count, created_at)
VALUES (9003, 9002, TRUE, TIMESTAMPTZ '2026-01-01 00:00:00+00', 0, TIMESTAMP '2026-01-01 00:00:00')
ON CONFLICT (collector_id) DO UPDATE SET
  enterprise_id = EXCLUDED.enterprise_id,
  is_available = EXCLUDED.is_available,
  availability_updated_at = EXCLUDED.availability_updated_at,
  warning_count = EXCLUDED.warning_count;

SELECT setval(pg_get_serial_sequence('identity.users', 'user_id'), GREATEST((SELECT MAX(user_id) FROM identity.users), 9004), true);
""");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
DELETE FROM identity.collector_profiles WHERE collector_id = 9003;
DELETE FROM identity.enterprise_profiles WHERE enterprise_id = 9002;
DELETE FROM identity.users WHERE email IN ('citizen@example.com', 'enterprise@example.com', 'collector@example.com', 'admin@example.com');
UPDATE identity.roles SET role_name = '__TEMP_ENTERPRISE__' WHERE role_id = 2;
UPDATE identity.roles SET role_name = 'Enterprise', description = 'Enterprise account' WHERE role_id = 3;
UPDATE identity.roles SET role_name = 'Collector', description = 'Waste collector' WHERE role_id = 2;
""");
        }
    }
}



