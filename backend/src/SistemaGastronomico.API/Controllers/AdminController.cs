namespace SistemaGastronomico.API.Controllers;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Admin.Commands.ToggleLocalEstadoOperativo;
using SistemaGastronomico.Application.Admin.Queries.GetAdminMetrics;
using SistemaGastronomico.Application.Admin.Queries.GetLocalesAdmin;
using SistemaGastronomico.Application.Admin.Queries.GetResenasByLocal;
using SistemaGastronomico.Application.Usuarios.Commands.ApprovePasswordReset;
using SistemaGastronomico.Application.Usuarios.Commands.RejectPasswordReset;
using SistemaGastronomico.Application.Usuarios.Queries.GetPendingPasswordResets;
using SistemaGastronomico.Domain.Enums;

[Authorize(Roles = "Administrador")]
[Route("api/[controller]")]
public class AdminController : ApiControllerBase
{
    /// <summary>
    /// Obtiene métricas globales y KPIs para el panel del Administrador UTA.
    /// </summary>
    [HttpGet("metrics")]
    public async Task<ActionResult<AdminDashboardMetricsDto>> GetMetrics()
    {
        var result = await Mediator.Send(new GetAdminMetricsQuery());
        return Ok(result);
    }

    /// <summary>
    /// Lista todos los locales con opciones avanzadas de filtrado y ordenamiento (por ejemplo, locales con menos estrellas).
    /// </summary>
    [HttpGet("locales")]
    public async Task<ActionResult<List<LocalAdminDto>>> GetLocales(
        [FromQuery] CampusUTA? campus,
        [FromQuery] CategoriaLocal? categoria,
        [FromQuery] EstadoAprobacionLocal? estadoAprobacion,
        [FromQuery] bool? soloBajaCalificacion,
        [FromQuery] bool? soloDeshabilitados,
        [FromQuery] string? search,
        [FromQuery] string? orderBy)
    {
        var result = await Mediator.Send(new GetLocalesAdminQuery(
            campus,
            categoria,
            estadoAprobacion,
            soloBajaCalificacion,
            soloDeshabilitados,
            search,
            orderBy
        ));
        return Ok(result);
    }

    /// <summary>
    /// Habilita o deshabilita (suspende) un local comercial con un motivo y notificación al dueño.
    /// </summary>
    [HttpPost("locales/{id:guid}/toggle-operativo")]
    public async Task<ActionResult<LocalAdminDto>> ToggleOperativo(Guid id, [FromBody] ToggleOperativoRequest request)
    {
        var result = await Mediator.Send(new ToggleLocalEstadoOperativoCommand(id, request.Habilitar, request.Motivo));
        return Ok(result);
    }

    /// <summary>
    /// Lista las reseñas y calificaciones que los estudiantes han dejado a un local.
    /// </summary>
    [HttpGet("locales/{id:guid}/resenas")]
    public async Task<ActionResult<List<ResenaDetalleDto>>> GetResenas(Guid id)
    {
        var result = await Mediator.Send(new GetResenasByLocalQuery(id));
        return Ok(result);
    }

    [HttpGet("claves-pendientes")]
    public async Task<ActionResult<List<PendingPasswordResetDto>>> GetPendingPasswordResets()
    {
        var result = await Mediator.Send(new GetPendingPasswordResetsQuery());
        return Ok(result);
    }

    [HttpPost("claves/{id:guid}/aprobar")]
    public async Task<ActionResult> ApprovePasswordReset(Guid id)
    {
        await Mediator.Send(new ApprovePasswordResetCommand(id));
        return Ok();
    }

    [HttpPost("claves/{id:guid}/rechazar")]
    public async Task<ActionResult> RejectPasswordReset(Guid id)
    {
        await Mediator.Send(new RejectPasswordResetCommand(id));
        return Ok();
    }
}

public record ToggleOperativoRequest(bool Habilitar, string? Motivo);
