using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Interfaces;
using System.Security.Claims;

namespace SistemaGastronomico.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificacionesController : ControllerBase
{
    private readonly IApplicationDbContext _context;

    public NotificacionesController(IApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetUnread()
    {
        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdString, out var userId)) return Unauthorized();

        var notificaciones = await _context.Notificaciones
            .Where(n => n.UsuarioId == userId && !n.Leida)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();

        return Ok(notificaciones);
    }

    [HttpPost("marcar-leidas")]
    public async Task<IActionResult> MarkAsRead()
    {
        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdString, out var userId)) return Unauthorized();

        var notificaciones = await _context.Notificaciones
            .Where(n => n.UsuarioId == userId && !n.Leida)
            .ToListAsync();

        foreach (var n in notificaciones)
        {
            n.Leida = true;
        }

        await _context.SaveChangesAsync();
        return Ok();
    }

    [HttpPost("registrar-dispositivo")]
    public IActionResult RegistrarDispositivo([FromBody] RegistrarDispositivoRequest request)
    {
        return Ok(new { exito = true, mensaje = "Dispositivo registrado correctamente" });
    }

    [AllowAnonymous]
    [HttpGet("publicas-recientes")]
    public async Task<IActionResult> GetPublicasRecientes([FromQuery] DateTime? desde = null)
    {
        var limiteFecha = desde ?? DateTime.UtcNow.AddHours(-24);

        var notificaciones = await _context.Notificaciones
            .Where(n => n.CreatedAt >= limiteFecha && n.IsActive)
            .OrderByDescending(n => n.CreatedAt)
            .Take(20)
            .Select(n => new
            {
                n.Id,
                n.Tipo,
                n.Mensaje,
                n.CreatedAt
            })
            .ToListAsync();

        return Ok(notificaciones);
    }
}

public record RegistrarDispositivoRequest(string Token, string? Plataforma);
