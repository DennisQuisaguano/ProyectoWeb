namespace SistemaGastronomico.Application.Resenas.Commands.CreateResena;

using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Entities;

public record CreateResenaCommand(
    Guid LocalId,
    Guid EstudianteId,
    int Calificacion,
    string? Comentario
) : IRequest<ResenaDetalleDto>;

public class CreateResenaCommandValidator : AbstractValidator<CreateResenaCommand>
{
    public CreateResenaCommandValidator()
    {
        RuleFor(v => v.LocalId)
            .NotEmpty().WithMessage("El ID del local es obligatorio.");

        RuleFor(v => v.EstudianteId)
            .NotEmpty().WithMessage("El ID del estudiante es obligatorio.");

        RuleFor(v => v.Calificacion)
            .InclusiveBetween(1, 5).WithMessage("La calificación debe estar entre 1 y 5 estrellas.");

        RuleFor(v => v.Comentario)
            .MaximumLength(500).WithMessage("El comentario no debe exceder los 500 caracteres.")
            .When(v => !string.IsNullOrEmpty(v.Comentario));
    }
}

public class CreateResenaCommandHandler : IRequestHandler<CreateResenaCommand, ResenaDetalleDto>
{
    private readonly IApplicationDbContext _context;

    public CreateResenaCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ResenaDetalleDto> Handle(CreateResenaCommand request, CancellationToken cancellationToken)
    {
        var local = await _context.Locales
            .FirstOrDefaultAsync(l => l.Id == request.LocalId && l.IsActive, cancellationToken);

        if (local == null)
        {
            throw new NotFoundException("Local", request.LocalId);
        }

        var estudiante = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Id == request.EstudianteId && u.IsActive, cancellationToken);

        if (estudiante == null)
        {
            throw new NotFoundException("Usuario", request.EstudianteId);
        }

        var resena = new Resena
        {
            Id = Guid.NewGuid(),
            LocalId = request.LocalId,
            EstudianteId = request.EstudianteId,
            Calificacion = request.Calificacion,
            Comentario = string.IsNullOrWhiteSpace(request.Comentario) ? null : request.Comentario.Trim(),
            Fecha = DateTime.UtcNow,
            IsActive = true
        };

        _context.Resenas.Add(resena);
        await _context.SaveChangesAsync(cancellationToken);

        return new ResenaDetalleDto(
            resena.Id,
            local.Id,
            local.Nombre,
            estudiante.Id,
            estudiante.NombreCompleto,
            estudiante.Email,
            resena.Calificacion,
            resena.Comentario,
            resena.Fecha
        );
    }
}
