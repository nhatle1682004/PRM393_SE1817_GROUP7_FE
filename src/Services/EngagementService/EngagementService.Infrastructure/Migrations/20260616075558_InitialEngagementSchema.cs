using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace EngagementService.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialEngagementSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "engagement");

            migrationBuilder.CreateTable(
                name: "feedbacks",
                schema: "engagement",
                columns: table => new
                {
                    feedback_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    user_id = table.Column<int>(type: "integer", nullable: false),
                    report_id = table.Column<int>(type: "integer", nullable: true),
                    content = table.Column<string>(type: "text", nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true, defaultValue: "Pending"),
                    image_url = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP"),
                    resolution_note = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("feedbacks_pkey", x => x.feedback_id);
                });

            migrationBuilder.CreateTable(
                name: "notifications",
                schema: "engagement",
                columns: table => new
                {
                    notification_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    user_id = table.Column<int>(type: "integer", nullable: false),
                    content = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    is_read = table.Column<bool>(type: "boolean", nullable: true, defaultValue: false),
                    created_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("notifications_pkey", x => x.notification_id);
                });

            migrationBuilder.CreateTable(
                name: "rewards",
                schema: "engagement",
                columns: table => new
                {
                    reward_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    points = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("rewards_pkey", x => x.reward_id);
                });

            migrationBuilder.CreateTable(
                name: "reward_transactions",
                schema: "engagement",
                columns: table => new
                {
                    transaction_id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    user_id = table.Column<int>(type: "integer", nullable: false),
                    reward_id = table.Column<int>(type: "integer", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp without time zone", nullable: true, defaultValueSql: "CURRENT_TIMESTAMP"),
                    type = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false, defaultValue: "redeem"),
                    points = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    description = table.Column<string>(type: "text", nullable: true),
                    report_id = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("reward_transactions_pkey", x => x.transaction_id);
                    table.ForeignKey(
                        name: "FK_reward_transactions_rewards_reward_id",
                        column: x => x.reward_id,
                        principalSchema: "engagement",
                        principalTable: "rewards",
                        principalColumn: "reward_id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_reward_transactions_reward_id",
                schema: "engagement",
                table: "reward_transactions",
                column: "reward_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "feedbacks",
                schema: "engagement");

            migrationBuilder.DropTable(
                name: "notifications",
                schema: "engagement");

            migrationBuilder.DropTable(
                name: "reward_transactions",
                schema: "engagement");

            migrationBuilder.DropTable(
                name: "rewards",
                schema: "engagement");
        }
    }
}
