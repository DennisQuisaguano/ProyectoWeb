namespace SistemaGastronomico.API.Controllers;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaGastronomico.Application.Promociones;
using SistemaGastronomico.Application.Promociones.Commands.CreatePromocion;
using SistemaGastronomico.Application.Promociones.Commands.UpdatePromocion;
using SistemaGastronomico.Application.Promociones.Commands.TogglePromocion;
using SistemaGastronomico.Application.Promociones.Queries.GetPromocionesByLocal;
using SistemaGastronomico.Application.Promociones.Queries.GetPromocionesGlobales;
using SistemaGastronomico.Domain.Enums;

public class PromocionesController : ApiControllerBase
{
    /// <summary>
    /// Lista las promociones vigentes de forma global, filtrando opcionalmente por campus.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<PromocionGlobalDto>>> GetAll(
        [FromQuery] CampusUTA? campus,
        [FromQuery] bool? soloActivas = true)
    {
        var result = await Mediator.Send(new GetPromocionesGlobalesQuery(campus, soloActivas));
        return Ok(result);
    }

    [HttpGet("local/{localId:guid}")]
    public async Task<ActionResult<List<PromocionDto>>> GetByLocal(Guid localId, [FromQuery] bool? soloActivas)
    {
        var result = await Mediator.Send(new GetPromocionesByLocalQuery(localId, soloActivas));
        return Ok(result);
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<PromocionDto>> Create([FromBody] CreatePromocionCommand command)
    {
        var result = await Mediator.Send(command);
        return Ok(result);
    }

    [HttpPut("{id:guid}")]
    [Authorize]
    public async Task<ActionResult<PromocionDto>> Update(Guid id, [FromBody] UpdatePromocionCommand command)
    {
        if (id != command.Id)
        {
            return BadRequest();
        }
        var result = await Mediator.Send(command);
        return Ok(result);
    }

    [HttpPatch("{id:guid}/toggle")]
    [Authorize]
    public async Task<ActionResult> Toggle(Guid id)
    {
        var activa = await Mediator.Send(new TogglePromocionCommand(id));
        return Ok(new { promocionId = id, estaActiva = activa });
    }
}
