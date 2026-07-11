using EngagementService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EngagementService.Infrastructure.Migrations
{
    [DbContext(typeof(EngagementDbContext))]
    [Migration("20260711000100_SeedVietnameseRewards")]
    public partial class SeedVietnameseRewards : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
INSERT INTO engagement.rewards (reward_id, name, description, points, status)
VALUES
  (1, 'Voucher cà phê 20.000đ', 'Đổi điểm lấy voucher cà phê tại cửa hàng đối tác', 50, TRUE),
  (2, 'Túi vải tái sử dụng', 'Túi vải thân thiện môi trường cho sinh hoạt hằng ngày', 80, TRUE),
  (3, 'Voucher siêu thị 50.000đ', 'Phiếu mua hàng áp dụng tại hệ thống siêu thị liên kết', 150, TRUE),
  (4, 'Bình nước inox', 'Bình nước cá nhân giúp giảm rác thải nhựa dùng một lần', 220, TRUE)
ON CONFLICT (reward_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  points = EXCLUDED.points,
  status = EXCLUDED.status;

SELECT setval(pg_get_serial_sequence('engagement.rewards', 'reward_id'), GREATEST((SELECT MAX(reward_id) FROM engagement.rewards), 4), true);
""");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
DELETE FROM engagement.rewards WHERE reward_id BETWEEN 1 AND 4;
""");
        }
    }
}
