 = Get-Content frontend-web\src\Pages\GestionPromociones.razor -Raw

# 1. Update the layout
 = '<div class="row g-4">\s*<Microsoft.AspNetCore.Components.Web.Virtualization.Virtualize Items="promociones" Context="promo">'
 = '<ul class="nav nav-pills mb-4">
        <li class="nav-item">
            <button class="nav-link @(mostrarActivas ? "active fw-bold shadow-sm" : "text-muted")" @onclick="() => mostrarActivas = true">
                <i class="bi bi-check-circle-fill me-1"></i> Activas
            </button>
        </li>
        <li class="nav-item ms-2">
            <button class="nav-link @(!mostrarActivas ? "active fw-bold shadow-sm bg-secondary text-white" : "text-muted")" @onclick="() => mostrarActivas = false">
                <i class="bi bi-pause-circle-fill me-1"></i> Pausadas / Vencidas
            </button>
        </li>
    </ul>

    <div class="row g-4">
        <Microsoft.AspNetCore.Components.Web.Virtualization.Virtualize Items="promocionesFiltradas" Context="promo">'
 = [regex]::Replace(, , )

# 2. Add variables to @code
 = '@code \{\s*private bool cargando = true;'
 = '@code {

    private bool mostrarActivas = true;
    private ICollection<PromocionModel> promocionesFiltradas => mostrarActivas 
        ? promociones.Where(p => p.EstaActiva).ToList() 
        : promociones.Where(p => !p.EstaActiva).ToList();

    private bool cargando = true;'
 = [regex]::Replace(, , )

Set-Content frontend-web\src\Pages\GestionPromociones.razor -Value 
