namespace SistemaGastronomico.Application.Promociones.Commands.CreatePromocion;

using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Entities;

public record CreatePromocionCommand(
    Guid LocalId,
    Guid? PlatoId,
    string Titulo,
    string? Descripcion,
    decimal? PrecioOriginal,
    decimal PrecioPromocional,
    string? ImagenUrl,
    string? DiasValidos,
    DateTime FechaInicio,
    DateTime FechaFin
) : IRequest<PromocionDto>;

public class CreatePromocionCommandValidator : AbstractValidator<CreatePromocionCommand>
{
    public CreatePromocionCommandValidator()
    {
        RuleFor(v => v.LocalId)
            .NotEmpty().WithMessage("El ID del local es obligatorio.");

        RuleFor(v => v.Titulo)
            .NotEmpty().WithMessage("El título de la promoción es obligatorio.")
            .MaximumLength(100).WithMessage("El título no debe superar los 100 caracteres.")
            .Matches(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\'\(\)\+]+$").WithMessage("El título contiene caracteres no permitidos.");

        RuleFor(v => v.Descripcion)
            .MaximumLength(300).WithMessage("La descripción no debe superar los 300 caracteres.")
            .Matches(@"^[^<>=\$;]+$").WithMessage("La descripción contiene caracteres no permitidos.")
            .When(v => !string.IsNullOrEmpty(v.Descripcion));

        RuleFor(v => v.PrecioOriginal)
            .GreaterThanOrEqualTo(0).WithMessage("El precio original no puede ser menor a 0.")
            .When(v => v.PrecioOriginal.HasValue);

        RuleFor(v => v.PrecioPromocional)
            .GreaterThanOrEqualTo(0).WithMessage("El precio promocional no puede ser menor a 0.");

        RuleFor(v => v.FechaInicio)
            .GreaterThanOrEqualTo(DateTime.UtcNow.Date).WithMessage("La fecha de inicio no puede ser menor a la fecha actual.");

        RuleFor(v => v.FechaFin)
            .GreaterThan(v => v.FechaInicio).WithMessage("La fecha de fin debe ser posterior a la fecha de inicio.");
    }
}

public class CreatePromocionCommandHandler : IRequestHandler<CreatePromocionCommand, PromocionDto>
{
    private readonly IApplicationDbContext _context;

    public CreatePromocionCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PromocionDto> Handle(CreatePromocionCommand request, CancellationToken cancellationToken)
    {
        var localExiste = await _context.Locales
            .AnyAsync(l => l.Id == request.LocalId && l.IsActive, cancellationToken);

        if (!localExiste)
        {
            throw new NotFoundException("Local", request.LocalId);
        }

        var promo = new Promocion
        {
            LocalId = request.LocalId,
            PlatoId = request.PlatoId,
            Titulo = request.Titulo.Trim(),
            Descripcion = request.Descripcion?.Trim() ?? string.Empty,
            PrecioOriginal = request.PrecioOriginal,
            PrecioPromocional = request.PrecioPromocional,
            ImagenUrl = request.ImagenUrl,
            DiasValidos = request.DiasValidos,
            FechaInicio = request.FechaInicio.ToUniversalTime(),
            FechaFin = request.FechaFin.ToUniversalTime(),
            EstaActiva = true,
            IsActive = true
        };

        _context.Promociones.Add(promo);
        await _context.SaveChangesAsync(cancellationToken);

        return new PromocionDto(
            promo.Id,
            promo.LocalId,
            promo.PlatoId,
            promo.Titulo,
            promo.Descripcion,
            promo.PrecioOriginal,
            promo.PrecioPromocional,
            promo.ImagenUrl,
            promo.DiasValidos,
            promo.FechaInicio,
            promo.FechaFin,
            promo.EstaActiva
        );
    }
}
