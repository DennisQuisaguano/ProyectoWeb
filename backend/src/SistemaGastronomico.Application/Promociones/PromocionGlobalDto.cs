namespace SistemaGastronomico.Application.Promociones;

using SistemaGastronomico.Domain.Enums;

public record PromocionGlobalDto(
    Guid Id,
    Guid LocalId,
    string LocalNombre,
    string? LocalLogoUrl,
    CampusUTA CampusCercano,
    Guid? PlatoId,
    string? PlatoNombre,
    string Titulo,
    string Descripcion,
    decimal? PrecioOriginal,
    decimal PrecioPromocional,
    string? ImagenUrl,
    string? DiasValidos,
    DateTime FechaInicio,
    DateTime FechaFin,
    bool EstaActiva
);
