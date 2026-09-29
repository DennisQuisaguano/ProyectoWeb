namespace src.Models;

public class AdminMetricsModel
{
    public int TotalLocales { get; set; }
    public int LocalesAprobados { get; set; }
    public int LocalesPendientes { get; set; }
    public int LocalesRechazados { get; set; }
    public int LocalesOperativos { get; set; }
    public int LocalesDeshabilitados { get; set; }
    public int LocalesEnRiesgoBajaCalificacion { get; set; }
    public double CalificacionPromedioGlobal { get; set; }
    public int TotalResenasGlobal { get; set; }
    public int TotalUsuariosRegistrados { get; set; }
    public int TotalComerciantes { get; set; }
    public int TotalEstudiantes { get; set; }
}

public class LocalAdminModel
{
    public Guid Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public string Direccion { get; set; } = string.Empty;
    public string? Referencia { get; set; }
    public CampusUTAModel CampusCercano { get; set; } = CampusUTAModel.Huachi;
    public CategoriaLocalModel Categoria { get; set; } = CategoriaLocalModel.Almuerzos;
    public bool EstaAbierto { get; set; }
    public bool IsActive { get; set; }
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public string? TelefonoContacto { get; set; }
    public string? WhatsApp { get; set; }
    public string? HorarioApertura { get; set; }
    public string? LogoUrl { get; set; }
    public string? PortadaUrl { get; set; }
    public Guid PropietarioId { get; set; }
    public string? PropietarioNombre { get; set; }
    public string? PropietarioEmail { get; set; }
    public string? PropietarioTelefono { get; set; }
    public EstadoAprobacionLocalModel EstadoAprobacion { get; set; } = EstadoAprobacionLocalModel.Pendiente;
    public string? CertificadoRucUrl { get; set; }
    public string? MotivoRechazo { get; set; }
    public DateTime? FechaRevision { get; set; }
    public string? RevisadoPorNombre { get; set; }
    public double CalificacionPromedio { get; set; }
    public int TotalResenas { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class ResenaDetalleModel
{
    public Guid Id { get; set; }
    public Guid LocalId { get; set; }
    public string LocalNombre { get; set; } = string.Empty;
    public Guid EstudianteId { get; set; }
    public string EstudianteNombre { get; set; } = string.Empty;
    public string? EstudianteEmail { get; set; }
    public int Calificacion { get; set; }
    public string? Comentario { get; set; }
    public DateTime Fecha { get; set; }
}
