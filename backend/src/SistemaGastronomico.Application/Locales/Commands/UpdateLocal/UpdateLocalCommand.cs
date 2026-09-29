namespace SistemaGastronomico.Application.Locales.Commands.UpdateLocal;

using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Enums;

public record UpdateLocalCommand(
    Guid Id,
    string Nombre,
    string? Descripcion,
    string Direccion,
    string? Referencia,
    CampusUTA CampusCercano,
    CategoriaLocal Categoria,
    double Latitud,
    double Longitud,
    string? TelefonoContacto,
    string? WhatsApp,
    string? HorarioApertura,
    string? LogoUrl,
    string? PortadaUrl,
    bool EstaAbierto,
    string? CertificadoRucUrl = null
) : IRequest<LocalDto>;

public class UpdateLocalCommandValidator : AbstractValidator<UpdateLocalCommand>
{
    public UpdateLocalCommandValidator()
    {
        RuleFor(v => v.Id)
            .NotEmpty().WithMessage("El ID del local es obligatorio.");

        RuleFor(v => v.Nombre)
            .NotEmpty().WithMessage("El nombre del local es obligatorio.")
            .MaximumLength(100).WithMessage("El nombre no debe superar los 100 caracteres.")
            .Matches(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\'\(\)]+$").WithMessage("El nombre contiene caracteres no permitidos.");

        RuleFor(v => v.Descripcion)
            .MaximumLength(500).WithMessage("La descripción no debe superar los 500 caracteres.")
            .When(v => !string.IsNullOrEmpty(v.Descripcion));

        RuleFor(v => v.Direccion)
            .NotEmpty().WithMessage("La dirección es obligatoria.")
            .MaximumLength(250).WithMessage("La dirección no debe superar los 250 caracteres.")
            .Matches(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\'#]+$").WithMessage("La dirección contiene caracteres no permitidos.");

        RuleFor(v => v.Referencia)
            .MaximumLength(250).WithMessage("La referencia no debe superar los 250 caracteres.")
            .When(v => !string.IsNullOrEmpty(v.Referencia));

        RuleFor(v => v.CertificadoRucUrl)
            .NotEmpty().WithMessage("El documento del RUC es obligatorio.");

        RuleFor(v => v.TelefonoContacto)
            .Matches(@"^[0-9]{10}$").WithMessage("El teléfono de contacto debe contener exactamente 10 dígitos numéricos.")
            .MaximumLength(10)
            .When(v => !string.IsNullOrEmpty(v.TelefonoContacto));

        RuleFor(v => v.WhatsApp)
            .Matches(@"^[0-9]{10}$").WithMessage("El WhatsApp debe contener exactamente 10 dígitos numéricos.")
            .MaximumLength(10)
            .When(v => !string.IsNullOrEmpty(v.WhatsApp));

        RuleFor(v => v.HorarioApertura)
            .MaximumLength(100).WithMessage("El horario no debe superar los 100 caracteres.")
            .Matches(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.,\-\:\;]+$").WithMessage("El horario contiene caracteres no permitidos.")
            .When(v => !string.IsNullOrEmpty(v.HorarioApertura));
    }
}

public class UpdateLocalCommandHandler : IRequestHandler<UpdateLocalCommand, LocalDto>
{
    private readonly IApplicationDbContext _context;

    public UpdateLocalCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<LocalDto> Handle(UpdateLocalCommand request, CancellationToken cancellationToken)
    {
        var local = await _context.Locales
            .Include(l => l.Propietario)
            .Include(l => l.Coordenadas)
            .FirstOrDefaultAsync(l => l.Id == request.Id && l.IsActive, cancellationToken);

        if (local == null)
        {
            throw new NotFoundException("Local", request.Id);
        }

        local.Nombre = request.Nombre.Trim();
        local.Descripcion = request.Descripcion?.Trim() ?? string.Empty;
        local.Direccion = request.Direccion.Trim();
        local.Referencia = request.Referencia?.Trim();
        local.CampusCercano = request.CampusCercano;
        local.Categoria = request.Categoria;
        local.Latitud = request.Latitud;
        local.Longitud = request.Longitud;
        local.TelefonoContacto = request.TelefonoContacto?.Trim();
        local.WhatsApp = request.WhatsApp?.Trim();
        local.HorarioApertura = request.HorarioApertura?.Trim();
        local.LogoUrl = request.LogoUrl;
        local.PortadaUrl = request.PortadaUrl;
        local.EstaAbierto = request.EstaAbierto;
        local.UpdatedAt = DateTime.UtcNow;

        if (!string.IsNullOrWhiteSpace(request.CertificadoRucUrl))
        {
            local.CertificadoRucUrl = request.CertificadoRucUrl;
            // Si estaba rechazado y vuelve a subir el RUC, pasa a Pendiente de nuevo
            if (local.EstadoAprobacion == EstadoAprobacionLocal.Rechazado)
            {
                local.EstadoAprobacion = EstadoAprobacionLocal.Pendiente;
                local.MotivoRechazo = null;
            }
        }

        if (local.Coordenadas != null)
        {
            local.Coordenadas.Latitud = request.Latitud;
            local.Coordenadas.Longitud = request.Longitud;
            local.Coordenadas.DireccionReferencial = request.Referencia ?? request.Direccion;
            local.Coordenadas.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync(cancellationToken);

        return new LocalDto(
            local.Id,
            local.Nombre,
            local.Descripcion,
            local.Direccion,
            local.Referencia,
            local.CampusCercano,
            local.Categoria,
            local.EstaAbierto,
            local.Latitud,
            local.Longitud,
            local.TelefonoContacto,
            local.WhatsApp,
            local.HorarioApertura,
            local.LogoUrl,
            local.PortadaUrl,
            local.PropietarioId,
            local.Propietario?.NombreCompleto,
            local.EstadoAprobacion,
            local.CertificadoRucUrl,
            local.MotivoRechazo,
            local.Propietario?.Email
        );
    }
}
