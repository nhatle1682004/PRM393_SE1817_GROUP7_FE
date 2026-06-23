using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EngagementService.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEngagementConsistencyFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "completed_at",
                schema: "engagement",
                table: "reward_transactions",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "failure_reason",
                schema: "engagement",
                table: "reward_transactions",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "reference_id",
                schema: "engagement",
                table: "reward_transactions",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "source_type",
                schema: "engagement",
                table: "reward_transactions",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "status",
                schema: "engagement",
                table: "reward_transactions",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "Pending");

            migrationBuilder.AddColumn<string>(
                name: "resolve_failure_reason",
                schema: "engagement",
                table: "feedbacks",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "resolved_at",
                schema: "engagement",
                table: "feedbacks",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_reward_transactions_source_type_reference_id_type",
                schema: "engagement",
                table: "reward_transactions",
                columns: new[] { "source_type", "reference_id", "type" },
                unique: true,
                filter: "reference_id IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_reward_transactions_source_type_reference_id_type",
                schema: "engagement",
                table: "reward_transactions");

            migrationBuilder.DropColumn(
                name: "completed_at",
                schema: "engagement",
                table: "reward_transactions");

            migrationBuilder.DropColumn(
                name: "failure_reason",
                schema: "engagement",
                table: "reward_transactions");

            migrationBuilder.DropColumn(
                name: "reference_id",
                schema: "engagement",
                table: "reward_transactions");

            migrationBuilder.DropColumn(
                name: "source_type",
                schema: "engagement",
                table: "reward_transactions");

            migrationBuilder.DropColumn(
                name: "status",
                schema: "engagement",
                table: "reward_transactions");

            migrationBuilder.DropColumn(
                name: "resolve_failure_reason",
                schema: "engagement",
                table: "feedbacks");

            migrationBuilder.DropColumn(
                name: "resolved_at",
                schema: "engagement",
                table: "feedbacks");
        }
    }
}
