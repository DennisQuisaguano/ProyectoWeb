using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Enums;

namespace SistemaGastronomico.Application.Usuarios.Queries.GetPendingPasswordResets;

public record PendingPasswordResetDto(Guid Id, string NombreCompleto, string Email, string? Telefono, DateTime? RequestedAt);

public record GetPendingPasswordResetsQuery() : IRequest<List<PendingPasswordResetDto>>;

public class GetPendingPasswordResetsQueryHandler : IRequestHandler<GetPendingPasswordResetsQuery, List<PendingPasswordResetDto>>
{
    private readonly IApplicationDbContext _context;

    public GetPendingPasswordResetsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<PendingPasswordResetDto>> Handle(GetPendingPasswordResetsQuery request, CancellationToken cancellationToken)
    {
        return await _context.Usuarios
            .Where(u => u.IsPasswordResetPending)
            .Select(u => new PendingPasswordResetDto(
                u.Id,
                u.NombreCompleto,
                u.Email,
                u.Telefono,
                u.PasswordResetRequestedAt))
            .ToListAsync(cancellationToken);
    }
}
