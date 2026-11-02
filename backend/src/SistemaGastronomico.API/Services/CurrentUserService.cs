namespace SistemaGastronomico.API.Services;

using System.Security.Claims;
using SistemaGastronomico.Application.Common.Interfaces;

public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid? UserId =>
        Guid.TryParse(_httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier), out var id)
            ? id
            : null;

    public bool IsAdmin => _httpContextAccessor.HttpContext?.User.IsInRole("Administrador") ?? false;
}
