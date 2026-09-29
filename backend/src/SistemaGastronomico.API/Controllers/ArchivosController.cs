namespace SistemaGastronomico.API.Controllers;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaGastronomico.Application.Common.Interfaces;

public class ArchivosController : ApiControllerBase
{
    private readonly IFileStorageService _fileStorageService;

    public ArchivosController(IFileStorageService fileStorageService)
    {
        _fileStorageService = fileStorageService;
    }

    [HttpPost("subir-ruc")]
    [Authorize]
    [RequestSizeLimit(5 * 1024 * 1024)] // Límite de 5 MB
    public async Task<ActionResult> SubirRuc(IFormFile? file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("No se ha enviado ningún archivo.");
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (extension != ".pdf")
        {
            return BadRequest("El archivo debe ser un documento PDF válido (.pdf).");
        }

        if (file.Length > 5 * 1024 * 1024)
        {
            return BadRequest("El tamaño del archivo no debe exceder los 5 MB.");
        }

        using var stream = file.OpenReadStream();
        var relativeUrl = await _fileStorageService.SaveFileAsync(stream, file.FileName, "certificados");

        return Ok(new { url = relativeUrl, nombre = file.FileName, tamanoBytes = file.Length });
    }

    [HttpPost("subir-imagen")]
    [Authorize]
    [RequestSizeLimit(5 * 1024 * 1024)] // Límite de 5 MB
    public async Task<ActionResult> SubirImagen(IFormFile? file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("No se ha enviado ninguna imagen.");
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        var validExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };
        
        if (!validExtensions.Contains(extension))
        {
            return BadRequest("La imagen debe ser de formato JPG, PNG o WEBP.");
        }

        if (file.Length > 5 * 1024 * 1024)
        {
            return BadRequest("El tamaño de la imagen no debe exceder los 5 MB.");
        }

        using var stream = file.OpenReadStream();
        var relativeUrl = await _fileStorageService.SaveFileAsync(stream, file.FileName, "imagenes");

        return Ok(new { url = relativeUrl, nombre = file.FileName, tamanoBytes = file.Length });
    }
}
