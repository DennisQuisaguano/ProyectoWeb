using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaGastronomico.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddManualPasswordReset : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsPasswordResetPending",
                table: "Usuarios",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordResetRequestedAt",
                table: "Usuarios",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PendingPasswordHash",
                table: "Usuarios",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsPasswordResetPending",
                table: "Usuarios");

            migrationBuilder.DropColumn(
                name: "PasswordResetRequestedAt",
                table: "Usuarios");

            migrationBuilder.DropColumn(
                name: "PendingPasswordHash",
                table: "Usuarios");
        }
    }
}
