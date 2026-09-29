namespace src.Models;

using System.ComponentModel.DataAnnotations;

public enum CampusUTAModel
{
    Huachi = 1,
    Ingahurco = 2,
    Querochaca = 3
}

public enum CategoriaLocalModel
{
    Almuerzos = 1,
    ComidaRapida = 2,
    Cafeteria = 3,
    Pizzeria = 4,
    Panaderia = 5,
    Mariscos = 6,
    Asadero = 7,
    VegetarianoVegano = 8,
    Otro = 99
}

public enum EstadoAprobacionLocalModel
{
    Pendiente = 1,
    Aprobado = 2,
    Rechazado = 3
}

public class LocalModel
{
    public Guid Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public string Direccion { get; set; } = string.Empty;
    public string? Referencia { get; set; }
    public CampusUTAModel CampusCercano { get; set; } = CampusUTAModel.Huachi;
    public CategoriaLocalModel Categoria { get; set; } = CategoriaLocalModel.Almuerzos;
    public bool EstaAbierto { get; set; } = true;
    public double Latitud { get; set; }
    public double Longitud { get; set; }
    public string? TelefonoContacto { get; set; }
    public string? WhatsApp { get; set; }
    public string? HorarioApertura { get; set; }
    public string? LogoUrl { get; set; }
    public string? PortadaUrl { get; set; }
    public Guid PropietarioId { get; set; }
    public string? PropietarioNombre { get; set; }
    public EstadoAprobacionLocalModel EstadoAprobacion { get; set; } = EstadoAprobacionLocalModel.Pendiente;
    public string? CertificadoRucUrl { get; set; }
    public string? MotivoRechazo { get; set; }
    public string? PropietarioEmail { get; set; }
}

public class CreateOrUpdateLocalModel
{
    public Guid? Id { get; set; }

    [Required(ErrorMessage = "El nombre del local es requerido.")]
    [MaxLength(100, ErrorMessage = "El nombre no debe superar los 100 caracteres.")]
    [RegularExpression(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\'\(\)]+$", ErrorMessage = "El nombre contiene caracteres no permitidos.")]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(500, ErrorMessage = "La descripción no debe superar los 500 caracteres.")]
    public string Descripcion { get; set; } = string.Empty;

    [Required(ErrorMessage = "La dirección es requerida.")]
    [MaxLength(250, ErrorMessage = "La dirección no debe superar los 250 caracteres.")]
    [RegularExpression(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\'#]+$", ErrorMessage = "La dirección contiene caracteres no permitidos.")]
    public string Direccion { get; set; } = string.Empty;

    [MaxLength(250, ErrorMessage = "La referencia no debe superar los 250 caracteres.")]
    public string? Referencia { get; set; }
    public CampusUTAModel CampusCercano { get; set; } = CampusUTAModel.Huachi;
    public CategoriaLocalModel Categoria { get; set; } = CategoriaLocalModel.Almuerzos;
    public double Latitud { get; set; } = -1.2687; // Coordenadas de referencia UTA Huachi
    public double Longitud { get; set; } = -78.6254;

    [RegularExpression(@"^[0-9]{10}$", ErrorMessage = "El teléfono debe contener exactamente 10 dígitos numéricos.")]
    [MaxLength(10, ErrorMessage = "No puede exceder los 10 dígitos.")]
    public string? TelefonoContacto { get; set; }

    [RegularExpression(@"^[0-9]{10}$", ErrorMessage = "El WhatsApp debe contener exactamente 10 dígitos numéricos.")]
    [MaxLength(10, ErrorMessage = "No puede exceder los 10 dígitos.")]
    public string? WhatsApp { get; set; }

    [MaxLength(100, ErrorMessage = "El horario no debe superar los 100 caracteres.")]
    [RegularExpression(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\:\;]+$", ErrorMessage = "El horario contiene caracteres no permitidos.")]
    public string? HorarioApertura { get; set; } = "07:30 - 18:00";
    public string? LogoUrl { get; set; }
    public string? PortadaUrl { get; set; }
    public bool EstaAbierto { get; set; } = true;
    public Guid PropietarioId { get; set; }

    [Required(ErrorMessage = "El documento del RUC es obligatorio. Sube el PDF respectivo.")]
    public string? CertificadoRucUrl { get; set; }

    public EstadoAprobacionLocalModel EstadoAprobacion { get; set; } = EstadoAprobacionLocalModel.Pendiente;
    public string? MotivoRechazo { get; set; }
}
