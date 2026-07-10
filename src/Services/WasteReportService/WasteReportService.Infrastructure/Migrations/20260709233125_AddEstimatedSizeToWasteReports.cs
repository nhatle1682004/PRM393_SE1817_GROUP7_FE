using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WasteReportService.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEstimatedSizeToWasteReports : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "estimated_size",
                schema: "waste",
                table: "waste_reports",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "estimated_size",
                schema: "waste",
                table: "waste_reports");
        }
    }
}
