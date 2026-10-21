namespace SistemaGastronomico.Application.Menus;

using SistemaGastronomico.Domain.Enums;

public record PlatoBusquedaDto(
    Guid Id,
    Guid LocalId,
    string LocalNombre,
    CampusUTA CampusCercano,
    string Nombre,
    string Descripcion,
    string CategoriaNombre,
    CategoriaPlato Categoria,
    decimal Precio,
    string? ImagenUrl,
    bool EstaDisponible,
    bool EsPlatoDelDia
);
