namespace SistemaGastronomico.Application.Admin;

using SistemaGastronomico.Domain.Enums;

public record LocalAdminDto(
    Guid Id,
    string Nombre,
    string Descripcion,
    string Direccion,
    string? Referencia,
    CampusUTA CampusCercano,
    CategoriaLocal Categoria,
    bool EstaAbierto,
    bool IsActive,
    double Latitud,
    double Longitud,
    string? TelefonoContacto,
    string? WhatsApp,
    string? HorarioApertura,
    string? LogoUrl,
    string? PortadaUrl,
    Guid PropietarioId,
    string? PropietarioNombre,
    string? PropietarioEmail,
    string? PropietarioTelefono,
    EstadoAprobacionLocal EstadoAprobacion,
    string? CertificadoRucUrl,
    string? MotivoRechazo,
    DateTime? FechaRevision,
    string? RevisadoPorNombre,
    double CalificacionPromedio,
    int TotalResenas,
    DateTime CreatedAt
);
