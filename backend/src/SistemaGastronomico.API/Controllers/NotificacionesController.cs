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
}
