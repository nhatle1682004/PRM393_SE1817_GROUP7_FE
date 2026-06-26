using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace IdentityService.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedIdentityRoles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                schema: "identity",
                table: "roles",
                columns: new[] { "role_id", "description", "role_name" },
                values: new object[,]
                {
                    { 1, "Regular citizen user", "Citizen" },
                    { 2, "Waste collector", "Collector" },
                    { 3, "Enterprise account", "Enterprise" },
                    { 4, "System administrator", "Admin" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                schema: "identity",
                table: "roles",
                keyColumn: "role_id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                schema: "identity",
                table: "roles",
                keyColumn: "role_id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                schema: "identity",
                table: "roles",
                keyColumn: "role_id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                schema: "identity",
                table: "roles",
                keyColumn: "role_id",
                keyValue: 4);
        }
    }
}
