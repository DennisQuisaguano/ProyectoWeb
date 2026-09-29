namespace SistemaGastronomico.Application.Promociones;

public record PromocionDto(
    Guid Id,
    Guid LocalId,
    Guid? PlatoId,
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
