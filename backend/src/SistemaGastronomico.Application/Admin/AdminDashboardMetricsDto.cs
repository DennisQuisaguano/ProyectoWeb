namespace SistemaGastronomico.Application.Admin;

public record AdminDashboardMetricsDto(
    int TotalLocales,
    int LocalesAprobados,
    int LocalesPendientes,
    int LocalesRechazados,
    int LocalesOperativos,
    int LocalesDeshabilitados,
    int LocalesEnRiesgoBajaCalificacion,
    double CalificacionPromedioGlobal,
    int TotalResenasGlobal,
    int TotalUsuariosRegistrados,
    int TotalComerciantes,
    int TotalEstudiantes
);
