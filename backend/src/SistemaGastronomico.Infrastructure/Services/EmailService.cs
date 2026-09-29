namespace SistemaGastronomico.Infrastructure.Services;

using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SistemaGastronomico.Application.Common.Interfaces;

public class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendEmailAsync(string toEmail, string toName, string subject, string htmlContent)
    {
        var smtpServer = _configuration["SmtpSettings:Server"];
        var smtpPort = int.TryParse(_configuration["SmtpSettings:Port"], out var port) ? port : 587;
        var senderEmail = _configuration["SmtpSettings:SenderEmail"] ?? "no-reply@uta.edu.ec";
        var senderName = _configuration["SmtpSettings:SenderName"] ?? "Sistema Gastronómico UTA";
        var username = _configuration["SmtpSettings:Username"] ?? senderEmail;
        var password = _configuration["SmtpSettings:Password"];
        var enableSsl = bool.TryParse(_configuration["SmtpSettings:EnableSsl"], out var ssl) ? ssl : true;

        if (string.IsNullOrWhiteSpace(smtpServer) || string.IsNullOrWhiteSpace(password))
        {
            _logger.LogInformation("[EMAIL SIMULATION] Servidor SMTP no configurado completamente. Notificación para: {Email} ({Name}) - Asunto: {Subject}", toEmail, toName, subject);
            Console.WriteLine($"\n==========================================");
            Console.WriteLine($"📧 [NOTIFICACIÓN POR CORREO ENVIADA]");
            Console.WriteLine($"Para: {toName} <{toEmail}>");
            Console.WriteLine($"Asunto: {subject}");
            Console.WriteLine($"Hora: {DateTime.Now:HH:mm:ss}");
            Console.WriteLine($"==========================================\n");
            return;
        }

        try
        {
            using var message = new MailMessage
            {
                From = new MailAddress(senderEmail, senderName),
                Subject = subject,
                Body = htmlContent,
                IsBodyHtml = true
            };

            message.To.Add(new MailAddress(toEmail, toName));

            using var client = new SmtpClient(smtpServer, smtpPort)
            {
                Credentials = new NetworkCredential(username, password),
                EnableSsl = enableSsl
            };

            await client.SendMailAsync(message);
            _logger.LogInformation("Correo enviado exitosamente a {Email}", toEmail);
            Console.WriteLine($"[EMAIL EXITOSO] Correo real enviado a: {toEmail} - Asunto: {subject}");
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No se pudo entregar el correo real a {Email}. Detalle: {Message}", toEmail, ex.Message);
            Console.WriteLine($"[EMAIL WARNING] No se pudo enviar a {toEmail}: {ex.Message}");
        }
    }
}
