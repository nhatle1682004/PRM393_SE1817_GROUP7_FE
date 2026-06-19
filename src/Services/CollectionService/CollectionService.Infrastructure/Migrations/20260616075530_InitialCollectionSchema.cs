using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace CollectionService.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCollectionSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "collection");

            migrationBuilder.CreateTable(
                name: "collection_requests",
                schema: "collection",
                columns: table => new
                {
                    request_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    report_id = table.Column<int>(type: "integer", nullable: false),
                    enterprise_id = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true, defaultValue: "Pending"),
                    created_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP"),
                    note = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    issue_report = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    issue_reason = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    issue_image_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("collection_requests_pkey", x => x.request_id);
                });

            migrationBuilder.CreateTable(
                name: "collector_assignments",
                schema: "collection",
                columns: table => new
                {
                    assignment_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    request_id = table.Column<int>(type: "integer", nullable: false),
                    assigned_collector = table.Column<int>(type: "integer", nullable: false),
                    assigned_by = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true, defaultValue: "Assigned"),
                    assigned_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP"),
                    started_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    arrived_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    before_image_url = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("collector_assignments_pkey", x => x.assignment_id);
                    table.ForeignKey(
                        name: "FK_collector_assignments_collection_requests_request_id",
                        column: x => x.request_id,
                        principalSchema: "collection",
                        principalTable: "collection_requests",
                        principalColumn: "request_id");
                });

            migrationBuilder.CreateTable(
                name: "collection_confirmations",
                schema: "collection",
                columns: table => new
                {
                    confirmation_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    assignment_id = table.Column<int>(type: "integer", nullable: false),
                    note = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    confirmed_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP"),
                    before_image_url = table.Column<string>(type: "text", nullable: false),
                    after_image_url = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("collection_confirmations_pkey", x => x.confirmation_id);
                    table.ForeignKey(
                        name: "FK_collection_confirmations_collector_assignments_assignment_id",
                        column: x => x.assignment_id,
                        principalSchema: "collection",
                        principalTable: "collector_assignments",
                        principalColumn: "assignment_id");
                });

            migrationBuilder.CreateTable(
                name: "collection_details",
                schema: "collection",
                columns: table => new
                {
                    detail_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    confirmation_id = table.Column<int>(type: "integer", nullable: false),
                    waste_type_id = table.Column<int>(type: "integer", nullable: false),
                    actual_weight = table.Column<double>(type: "double precision", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("collection_details_pkey", x => x.detail_id);
                    table.ForeignKey(
                        name: "FK_collection_details_collection_confirmations_confirmation_id",
                        column: x => x.confirmation_id,
                        principalSchema: "collection",
                        principalTable: "collection_confirmations",
                        principalColumn: "confirmation_id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_collection_confirmations_assignment_id",
                schema: "collection",
                table: "collection_confirmations",
                column: "assignment_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_collection_details_confirmation_id",
                schema: "collection",
                table: "collection_details",
                column: "confirmation_id");

            migrationBuilder.CreateIndex(
                name: "IX_collection_requests_report_id",
                schema: "collection",
                table: "collection_requests",
                column: "report_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_collector_assignments_request_id",
                schema: "collection",
                table: "collector_assignments",
                column: "request_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "collection_details",
                schema: "collection");

            migrationBuilder.DropTable(
                name: "collection_confirmations",
                schema: "collection");

            migrationBuilder.DropTable(
                name: "collector_assignments",
                schema: "collection");

            migrationBuilder.DropTable(
                name: "collection_requests",
                schema: "collection");
        }
    }
}
