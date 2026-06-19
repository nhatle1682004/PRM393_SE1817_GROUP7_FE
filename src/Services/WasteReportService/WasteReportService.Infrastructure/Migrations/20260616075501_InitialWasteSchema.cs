using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace WasteReportService.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialWasteSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("CREATE EXTENSION IF NOT EXISTS postgis;");

            migrationBuilder.EnsureSchema(
                name: "waste");

            migrationBuilder.CreateTable(
                name: "districts",
                schema: "waste",
                columns: table => new
                {
                    district_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("districts_pkey", x => x.district_id);
                });

            migrationBuilder.Sql("ALTER TABLE waste.districts ADD COLUMN IF NOT EXISTS boundary geometry;");

            migrationBuilder.CreateTable(
                name: "waste_types",
                schema: "waste",
                columns: table => new
                {
                    waste_type_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    description = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    reward_points = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("waste_types_pkey", x => x.waste_type_id);
                });

            migrationBuilder.CreateTable(
                name: "waste_reports",
                schema: "waste",
                columns: table => new
                {
                    report_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    submitted_by = table.Column<int>(type: "integer", nullable: false),
                    image_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    latitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    longitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true, defaultValue: "Pending"),
                    created_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP"),
                    district_id = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("waste_reports_pkey", x => x.report_id);
                    table.ForeignKey(
                        name: "FK_waste_reports_districts_district_id",
                        column: x => x.district_id,
                        principalSchema: "waste",
                        principalTable: "districts",
                        principalColumn: "district_id");
                });

            migrationBuilder.CreateTable(
                name: "ai_waste_predictions",
                schema: "waste",
                columns: table => new
                {
                    prediction_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    report_id = table.Column<int>(type: "integer", nullable: false),
                    suggested_type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    confidence = table.Column<decimal>(type: "numeric(5,2)", precision: 5, scale: 2, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("ai_waste_predictions_pkey", x => x.prediction_id);
                    table.ForeignKey(
                        name: "FK_ai_waste_predictions_waste_reports_report_id",
                        column: x => x.report_id,
                        principalSchema: "waste",
                        principalTable: "waste_reports",
                        principalColumn: "report_id");
                });

            migrationBuilder.CreateTable(
                name: "report_waste_types",
                schema: "waste",
                columns: table => new
                {
                    report_id = table.Column<int>(type: "integer", nullable: false),
                    waste_type_id = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_report_waste_types", x => new { x.report_id, x.waste_type_id });
                    table.ForeignKey(
                        name: "FK_report_waste_types_waste_reports_report_id",
                        column: x => x.report_id,
                        principalSchema: "waste",
                        principalTable: "waste_reports",
                        principalColumn: "report_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_report_waste_types_waste_types_waste_type_id",
                        column: x => x.waste_type_id,
                        principalSchema: "waste",
                        principalTable: "waste_types",
                        principalColumn: "waste_type_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ai_waste_predictions_report_id",
                schema: "waste",
                table: "ai_waste_predictions",
                column: "report_id");

            migrationBuilder.CreateIndex(
                name: "IX_report_waste_types_waste_type_id",
                schema: "waste",
                table: "report_waste_types",
                column: "waste_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_waste_reports_district_id",
                schema: "waste",
                table: "waste_reports",
                column: "district_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ai_waste_predictions",
                schema: "waste");

            migrationBuilder.DropTable(
                name: "report_waste_types",
                schema: "waste");

            migrationBuilder.DropTable(
                name: "waste_reports",
                schema: "waste");

            migrationBuilder.DropTable(
                name: "waste_types",
                schema: "waste");

            migrationBuilder.DropTable(
                name: "districts",
                schema: "waste");
        }
    }
}
