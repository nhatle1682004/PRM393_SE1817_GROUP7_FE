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
        var password = smtp["Password"]?.Replace(" ", string.Empty);

        using var client = new SmtpClient(smtp["Host"], int.Parse(smtp["Port"]!))
        {
            Credentials = new NetworkCredential(smtp["Username"], password),
            EnableSsl = smtp.GetValue("EnableSsl", true)
        };

        using var mail = new MailMessage
        {
            From = new MailAddress(smtp["Username"]!, smtp["FromName"]),
            Subject = subject,
            Body = body,
            IsBodyHtml = isHtml
        };

        mail.To.Add(toEmail);
        await client.SendMailAsync(mail);
    }
}
