namespace SistemaGastronomico.Application.Locales.Commands.CreateLocal;

using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Entities;
using SistemaGastronomico.Domain.Enums;
using ValidationException = SistemaGastronomico.Application.Common.Exceptions.ValidationException;

public record CreateLocalCommand(
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
    Guid PropietarioId,
    string? CertificadoRucUrl = null
) : IRequest<LocalDto>;

public class CreateLocalCommandValidator : AbstractValidator<CreateLocalCommand>
{
    public CreateLocalCommandValidator()
    {
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

        RuleFor(v => v.PropietarioId)
            .NotEmpty().WithMessage("El identificador del propietario es obligatorio.");

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

public class CreateLocalCommandHandler : IRequestHandler<CreateLocalCommand, LocalDto>
{
    private readonly IApplicationDbContext _context;

    public CreateLocalCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<LocalDto> Handle(CreateLocalCommand request, CancellationToken cancellationToken)
    {
        var propietario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Id == request.PropietarioId && u.IsActive, cancellationToken);

        if (propietario == null)
        {
            throw new ValidationException(new[]
            {
                new FluentValidation.Results.ValidationFailure("PropietarioId", "El propietario especificado no existe.")
            });
        }

        var local = new Local
        {
            Nombre = request.Nombre.Trim(),
            Descripcion = request.Descripcion?.Trim() ?? string.Empty,
            Direccion = request.Direccion.Trim(),
            Referencia = request.Referencia?.Trim(),
            CampusCercano = request.CampusCercano,
            Categoria = request.Categoria,
            Latitud = request.Latitud,
            Longitud = request.Longitud,
            TelefonoContacto = request.TelefonoContacto?.Trim(),
            WhatsApp = request.WhatsApp?.Trim(),
            HorarioApertura = request.HorarioApertura?.Trim(),
            LogoUrl = request.LogoUrl,
            PortadaUrl = request.PortadaUrl,
            CertificadoRucUrl = request.CertificadoRucUrl,
            EstadoAprobacion = EstadoAprobacionLocal.Pendiente,
            EstaAbierto = false,
            PropietarioId = request.PropietarioId,
            IsActive = true
        };

        // Relación 1:1 con Coordenadas
        local.Coordenadas = new Coordenada
        {
            LocalId = local.Id,
            Latitud = request.Latitud,
            Longitud = request.Longitud,
            DireccionReferencial = request.Referencia ?? request.Direccion,
            IsActive = true
        };

        _context.Locales.Add(local);
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
            propietario.NombreCompleto,
            local.EstadoAprobacion,
            local.CertificadoRucUrl,
            local.MotivoRechazo,
            propietario.Email
        );
    }
}
