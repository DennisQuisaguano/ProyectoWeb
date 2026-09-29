namespace src.Models;

public class PendingPasswordResetModel
{
    public Guid Id { get; set; }
    public string NombreCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Telefono { get; set; }
    public DateTime? RequestedAt { get; set; }
}
