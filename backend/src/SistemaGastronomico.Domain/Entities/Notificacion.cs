namespace SistemaGastronomico.Domain.Entities;

using SistemaGastronomico.Domain.Common;
using System;

public class Notificacion : BaseEntity
{
    // Si es null, es una notificacion global o para administradores
    public Guid? UsuarioId { get; set; }
    public Usuario? Usuario { get; set; }

    public string Tipo { get; set; } = "info"; // "success", "error", "warning", "info"
    public string Mensaje { get; set; } = string.Empty;
    public bool Leida { get; set; } = false;
}
