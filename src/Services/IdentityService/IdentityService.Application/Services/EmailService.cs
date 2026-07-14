using Microsoft.Extensions.Configuration;
using System.Net;
using System.Net.Mail;

namespace IdentityService.Application.Services;

public sealed class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;

    public EmailService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public async Task SendEmailAsync(string toEmail, string subject, string body, bool isHtml = false)
    {
        var smtp = _configuration.GetSection("SmtpSettings");
        var host = smtp["Host"];
        var port = smtp["Port"];
        var username = smtp["Username"];
        var password = smtp["Password"]?.Replace(" ", string.Empty);
        var fromName = smtp["FromName"];

        if (string.IsNullOrWhiteSpace(toEmail))
            throw new InvalidOperationException("Recipient email is required.");

        if (string.IsNullOrWhiteSpace(host))
            throw new InvalidOperationException("SMTP host is not configured.");

        if (!int.TryParse(port, out var smtpPort))
            throw new InvalidOperationException("SMTP port is not configured correctly.");

        if (string.IsNullOrWhiteSpace(username))
            throw new InvalidOperationException("SMTP sender email is not configured.");

        using var client = new SmtpClient(host, smtpPort)
        {
            Credentials = new NetworkCredential(username, password),
            EnableSsl = smtp.GetValue("EnableSsl", true)
        };

        using var mail = new MailMessage
        {
            From = new MailAddress(username, fromName),
            Subject = subject,
            Body = body,
            IsBodyHtml = isHtml
        };

        mail.To.Add(toEmail);
        await client.SendMailAsync(mail);
    }
}
