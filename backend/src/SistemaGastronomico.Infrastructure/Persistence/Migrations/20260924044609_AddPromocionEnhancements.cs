using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaGastronomico.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddPromocionEnhancements : Migration
    {
        /// <inheritdoc />
                protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DiasValidos",
                table: "Promociones",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "PlatoId",
                table: "Promociones",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Promociones_PlatoId",
                table: "Promociones",
                column: "PlatoId");

            migrationBuilder.AddForeignKey(
                name: "FK_Promociones_Platos_PlatoId",
                table: "Promociones",
                column: "PlatoId",
                principalTable: "Platos",
                principalColumn: "Id");
        }

                protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Promociones_Platos_PlatoId",
                table: "Promociones");

            migrationBuilder.DropIndex(
                name: "IX_Promociones_PlatoId",
                table: "Promociones");

            migrationBuilder.DropColumn(
                name: "DiasValidos",
                table: "Promociones");

            migrationBuilder.DropColumn(
                name: "PlatoId",
                table: "Promociones");
        }
    }
}
