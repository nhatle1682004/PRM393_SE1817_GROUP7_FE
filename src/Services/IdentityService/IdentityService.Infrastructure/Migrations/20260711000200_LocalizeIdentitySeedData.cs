using IdentityService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IdentityService.Infrastructure.Migrations
{
    [DbContext(typeof(IdentityDbContext))]
    [Migration("20260711000200_LocalizeIdentitySeedData")]
    public partial class LocalizeIdentitySeedData : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
UPDATE identity.roles SET description = 'Người dân' WHERE role_id = 1;
UPDATE identity.roles SET description = 'Doanh nghiệp thu gom' WHERE role_id = 2;
UPDATE identity.roles SET description = 'Nhân viên thu gom' WHERE role_id = 3;
UPDATE identity.roles SET description = 'Quản trị viên hệ thống' WHERE role_id = 4;

UPDATE identity.users SET full_name = 'Nguyễn Minh An' WHERE email = 'citizen@example.com';
UPDATE identity.users SET full_name = 'Công ty Môi Trường Xanh' WHERE email = 'enterprise@example.com';
UPDATE identity.users SET full_name = 'Trần Văn Thu Gom' WHERE email = 'collector@example.com';
UPDATE identity.users SET full_name = 'Quản Trị Hệ Thống' WHERE email = 'admin@example.com';
""");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
UPDATE identity.roles SET description = 'Regular citizen user' WHERE role_id = 1;
UPDATE identity.roles SET description = 'Enterprise account' WHERE role_id = 2;
UPDATE identity.roles SET description = 'Waste collector' WHERE role_id = 3;
UPDATE identity.roles SET description = 'System administrator' WHERE role_id = 4;

UPDATE identity.users SET full_name = 'Demo Citizen' WHERE email = 'citizen@example.com';
UPDATE identity.users SET full_name = 'Demo Enterprise' WHERE email = 'enterprise@example.com';
UPDATE identity.users SET full_name = 'Demo Collector' WHERE email = 'collector@example.com';
UPDATE identity.users SET full_name = 'Demo Admin' WHERE email = 'admin@example.com';
""");
        }
    }
}
