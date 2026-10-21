namespace SistemaGastronomico.API.Controllers;

using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaGastronomico.Application.Locales;
using SistemaGastronomico.Application.Locales.Commands.CreateLocal;
using SistemaGastronomico.Application.Locales.Commands.ToggleAperturaLocal;
using SistemaGastronomico.Application.Locales.Commands.UpdateLocal;
using SistemaGastronomico.Application.Locales.Queries.GetLocalById;
using SistemaGastronomico.Application.Locales.Queries.GetLocales;
using SistemaGastronomico.Application.Locales.Queries.GetLocalesByPropietario;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Admin.Queries.GetResenasByLocal;
using SistemaGastronomico.Application.Locales.Queries.GetResenasByPropietario;
using SistemaGastronomico.Application.Resenas.Commands.CreateResena;
using SistemaGastronomico.Domain.Enums;

public class LocalesController : ApiControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<LocalDto>>> GetAll(
        [FromQuery] CampusUTA? campus,
        [FromQuery] CategoriaLocal? categoria,
        [FromQuery] string? search)
    {
        var result = await Mediator.Send(new GetLocalesQuery(campus, categoria, search));
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<LocalDto>> GetById(Guid id)
    {
        var result = await Mediator.Send(new GetLocalByIdQuery(id));
        return Ok(result);
    }

    [HttpGet("mis-locales")]
    [Authorize]
    public async Task<ActionResult<List<LocalDto>>> GetMisLocales()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId))
        {
            return Unauthorized();
        }

        var result = await Mediator.Send(new GetLocalesByPropietarioQuery(userId));
        return Ok(result);
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<LocalDto>> Create([FromBody] CreateLocalCommand command)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (Guid.TryParse(userIdStr, out var userId) && command.PropietarioId == Guid.Empty)
        {
            command = command with { PropietarioId = userId };
        }

        var result = await Mediator.Send(command);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id:guid}")]
    [Authorize]
    public async Task<ActionResult<LocalDto>> Update(Guid id, [FromBody] UpdateLocalCommand command)
    {
        if (id != command.Id)
        {
            return BadRequest("El ID de la ruta no coincide con el cuerpo de la solicitud.");
        }

        var result = await Mediator.Send(command);
        return Ok(result);
    }

    [HttpPatch("{id:guid}/toggle-apertura")]
    [Authorize]
    public async Task<ActionResult<bool>> ToggleApertura(Guid id)
    {
        var result = await Mediator.Send(new ToggleAperturaLocalCommand(id));
        return Ok(new { localId = id, estaAbierto = result });
    }

    /// <summary>
    /// Lista de locales para el Administrador según su estado de aprobación.
    /// </summary>
    [HttpGet("pendientes")]
    [Authorize]
    public async Task<ActionResult<List<LocalDto>>> GetPendientes([FromQuery] EstadoAprobacionLocal? estado)
    {
        var result = await Mediator.Send(new SistemaGastronomico.Application.Locales.Queries.GetLocalesPendientes.GetLocalesPendientesQuery(estado));
        return Ok(result);
    }

    /// <summary>
    /// Aprueba un local comercial y notifica al dueño vía correo real.
    /// </summary>
    [HttpPost("{id:guid}/aprobar")]
    [Authorize]
    public async Task<ActionResult<LocalDto>> Aprobar(Guid id)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        _ = Guid.TryParse(userIdStr, out var adminId);

        var result = await Mediator.Send(new SistemaGastronomico.Application.Locales.Commands.AprobarLocal.AprobarLocalCommand(id, adminId));
        return Ok(result);
    }

    /// <summary>
    /// Rechaza la solicitud de un local comercial con un motivo y notifica vía correo real.
    /// </summary>
    [HttpPost("{id:guid}/rechazar")]
    [Authorize]
    public async Task<ActionResult<LocalDto>> Rechazar(Guid id, [FromBody] RechazarLocalRequest request)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        _ = Guid.TryParse(userIdStr, out var adminId);

        var result = await Mediator.Send(new SistemaGastronomico.Application.Locales.Commands.RechazarLocal.RechazarLocalCommand(id, adminId, request.Motivo));
        return Ok(result);
    }

    /// <summary>
    /// Consulta las opiniones y reseñas dejadas a un local comercial.
    /// </summary>
    [HttpGet("{id:guid}/resenas")]
    public async Task<ActionResult<List<ResenaDetalleDto>>> GetResenas(Guid id)
    {
        var result = await Mediator.Send(new GetResenasByLocalQuery(id));
        return Ok(result);
    }

    /// <summary>
    /// Registra la reseña y calificación (1 a 5 estrellas) de un estudiante autenticado.
    /// </summary>
    [HttpPost("{id:guid}/resenas")]
    [Authorize]
    public async Task<ActionResult<ResenaDetalleDto>> CreateResena(Guid id, [FromBody] CrearResenaRequest request)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId))
        {
            return Unauthorized("Usuario no identificado");
        }

        var command = new CreateResenaCommand(id, userId, request.Calificacion, request.Comentario);
        var result = await Mediator.Send(command);
        return Ok(result);
    }

    /// <summary>
    /// Consulta todas las opiniones y reseñas recibidas en los locales del propietario autenticado.
    /// </summary>
    [HttpGet("mis-resenas")]
    [Authorize]
    public async Task<ActionResult<List<ResenaDetalleDto>>> GetMisResenas()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId))
        {
            return Unauthorized("Usuario no identificado");
        }

        var result = await Mediator.Send(new GetResenasByPropietarioQuery(userId));
        return Ok(result);
    }
}

public record RechazarLocalRequest(string Motivo);
public record CrearResenaRequest(int Calificacion, string? Comentario);
