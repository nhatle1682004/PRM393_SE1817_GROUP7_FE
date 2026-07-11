using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using WasteReportService.Infrastructure.Persistence;

#nullable disable

namespace WasteReportService.Infrastructure.Migrations
{
    [DbContext(typeof(WasteReportDbContext))]
    [Migration("20260711000200_LocalizeWasteTypeSeedData")]
    public partial class LocalizeWasteTypeSeedData : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
UPDATE waste.waste_types SET name = 'Rác hữu cơ', description = 'Thức ăn thừa, lá cây và rác có thể phân hủy sinh học' WHERE waste_type_id = 1;
UPDATE waste.waste_types SET name = 'Nhựa', description = 'Chai nhựa, túi nilon, bao bì và hộp nhựa' WHERE waste_type_id = 2;
UPDATE waste.waste_types SET name = 'Giấy', description = 'Giấy, bìa carton, báo và thùng giấy' WHERE waste_type_id = 3;
UPDATE waste.waste_types SET name = 'Kim loại', description = 'Lon, sắt vụn và vật dụng kim loại nhỏ' WHERE waste_type_id = 4;
UPDATE waste.waste_types SET name = 'Thủy tinh', description = 'Chai lọ thủy tinh và kính vỡ đã được đóng gói an toàn' WHERE waste_type_id = 5;
UPDATE waste.waste_types SET name = 'Rác điện tử', description = 'Pin, dây cáp, thiết bị điện tử và linh kiện hỏng' WHERE waste_type_id = 6;
UPDATE waste.waste_types SET name = 'Rác nguy hại', description = 'Sơn, hóa chất, bóng đèn và rác thải nguy hại khác' WHERE waste_type_id = 7;
UPDATE waste.waste_types SET name = 'Khác', description = 'Các loại rác khác cần được kiểm tra thủ công' WHERE waste_type_id = 8;
""");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
UPDATE waste.waste_types SET name = 'Organic', description = 'Food scraps, leaves, and biodegradable waste' WHERE waste_type_id = 1;
UPDATE waste.waste_types SET name = 'Plastic', description = 'Plastic bottles, bags, packaging, and containers' WHERE waste_type_id = 2;
UPDATE waste.waste_types SET name = 'Paper', description = 'Paper, cardboard, newspapers, and carton' WHERE waste_type_id = 3;
UPDATE waste.waste_types SET name = 'Metal', description = 'Cans, scrap metal, and small metal items' WHERE waste_type_id = 4;
UPDATE waste.waste_types SET name = 'Glass', description = 'Glass bottles, jars, and broken glass packed safely' WHERE waste_type_id = 5;
UPDATE waste.waste_types SET name = 'E-Waste', description = 'Electronic waste such as batteries, cables, and devices' WHERE waste_type_id = 6;
UPDATE waste.waste_types SET name = 'Hazardous', description = 'Paint, chemicals, bulbs, and other hazardous waste' WHERE waste_type_id = 7;
UPDATE waste.waste_types SET name = 'Other', description = 'Other waste types that need manual review' WHERE waste_type_id = 8;
""");
        }
    }
}
