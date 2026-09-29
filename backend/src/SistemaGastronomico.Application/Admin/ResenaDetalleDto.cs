namespace SistemaGastronomico.Application.Admin;

public record ResenaDetalleDto(
    Guid Id,
    Guid LocalId,
    string LocalNombre,
    Guid EstudianteId,
    string EstudianteNombre,
    string? EstudianteEmail,
    int Calificacion,
    string? Comentario,
    DateTime Fecha
);
