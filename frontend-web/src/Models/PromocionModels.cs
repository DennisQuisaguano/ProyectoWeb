namespace src.Models;

using System.ComponentModel.DataAnnotations;

public class PromocionModel
{
    public Guid Id { get; set; }
    public Guid LocalId { get; set; }
    public Guid? PlatoId { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public decimal? PrecioOriginal { get; set; }
    public decimal PrecioPromocional { get; set; }
    public string? ImagenUrl { get; set; }
    public string? DiasValidos { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime FechaFin { get; set; }
    public bool EstaActiva { get; set; }
}

public class CreatePromocionModel : IValidatableObject
{
    public Guid Id { get; set; }
    public Guid LocalId { get; set; }
    public Guid? PlatoId { get; set; }

    [Required(ErrorMessage = "El título es obligatorio.")]
    [MaxLength(100, ErrorMessage = "El título no debe superar los 100 caracteres.")]
    [RegularExpression(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\'\(\)\+]+$", ErrorMessage = "El título contiene caracteres no permitidos.")]
    public string Titulo { get; set; } = string.Empty;

    [MaxLength(300, ErrorMessage = "La descripción no debe superar los 300 caracteres.")]
    [RegularExpression(@"^[^<>=\$;]+$", ErrorMessage = "La descripción contiene caracteres no permitidos.")]
    public string Descripcion { get; set; } = string.Empty;

    [Range(0.00, 9999.99, ErrorMessage = "El precio original no puede ser menor a 0.")]
    public decimal? PrecioOriginal { get; set; }

    [Required(ErrorMessage = "El precio promocional es obligatorio.")]
    [Range(0.00, 9999.99, ErrorMessage = "El precio promocional no puede ser menor a 0.")]
    public decimal PrecioPromocional { get; set; } = 2.00m;

    public string? ImagenUrl { get; set; }
    public string? DiasValidos { get; set; }

    public DateTime FechaInicio { get; set; } = DateTime.Today;
    public DateTime FechaFin { get; set; } = DateTime.Today.AddDays(7);

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (PrecioOriginal.HasValue && PrecioPromocional >= PrecioOriginal.Value)
        {
            yield return new ValidationResult("El precio de oferta debe ser menor que el precio original.", new[] { nameof(PrecioPromocional) });
        }
        if (FechaFin < FechaInicio)
        {
            yield return new ValidationResult("La fecha de fin debe ser posterior a la fecha de inicio.", new[] { nameof(FechaFin) });
        }
    }
}
