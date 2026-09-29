namespace SistemaGastronomico.Application.Menus.Commands.CreatePlato;

using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Entities;
using SistemaGastronomico.Domain.Enums;

public record CreatePlatoCommand(
    Guid LocalId,
    string Nombre,
    string? Descripcion,
    decimal Precio,
    string? ImagenUrl,
    CategoriaPlato Categoria,
    bool EstaDisponible = true,
    bool EsPlatoDelDia = false
) : IRequest<PlatoDto>;

public class CreatePlatoCommandValidator : AbstractValidator<CreatePlatoCommand>
{
    public CreatePlatoCommandValidator()
    {
        RuleFor(v => v.LocalId)
            .NotEmpty().WithMessage("El ID del local es obligatorio.");

        RuleFor(v => v.Nombre)
            .NotEmpty().WithMessage("El nombre del plato es obligatorio.")
            .MaximumLength(100).WithMessage("El nombre no debe superar los 100 caracteres.")
            .Matches(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\'\(\)]+$").WithMessage("El nombre contiene caracteres no permitidos.");

        RuleFor(v => v.Descripcion)
            .MaximumLength(300).WithMessage("La descripción no debe superar los 300 caracteres.")
            .Matches(@"^[^<>=\$;]+$").WithMessage("La descripción contiene caracteres no permitidos.")
            .When(v => !string.IsNullOrEmpty(v.Descripcion));

        RuleFor(v => v.Precio)
            .GreaterThanOrEqualTo(0).WithMessage("El precio no puede ser menor a 0.");
    }
}

public class CreatePlatoCommandHandler : IRequestHandler<CreatePlatoCommand, PlatoDto>
{
    private readonly IApplicationDbContext _context;

    public CreatePlatoCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PlatoDto> Handle(CreatePlatoCommand request, CancellationToken cancellationToken)
    {
        var localExiste = await _context.Locales
            .AnyAsync(l => l.Id == request.LocalId && l.IsActive, cancellationToken);

        if (!localExiste)
        {
            throw new NotFoundException("Local", request.LocalId);
        }

        var plato = new Plato
        {
            LocalId = request.LocalId,
            Nombre = request.Nombre.Trim(),
            Descripcion = request.Descripcion?.Trim() ?? string.Empty,
            Precio = request.Precio,
            ImagenUrl = request.ImagenUrl,
            Categoria = request.Categoria,
            EstaDisponible = request.EstaDisponible,
            EsPlatoDelDia = request.EsPlatoDelDia,
            IsActive = true
        };

        _context.Platos.Add(plato);
        await _context.SaveChangesAsync(cancellationToken);

        return new PlatoDto(
            plato.Id,
            plato.LocalId,
            plato.Nombre,
            plato.Descripcion,
            plato.Categoria.ToString(),
            plato.Categoria,
            plato.Precio,
            plato.ImagenUrl,
            plato.EstaDisponible,
            plato.EsPlatoDelDia,
            plato.OrdenVisualizacion
        );
    }
}
