using IdentityService.Application.Services;
using IdentityService.Application.Validators;
using FluentValidation;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace IdentityService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddIdentityApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddValidatorsFromAssemblyContaining<CreateUserValidator>();
        services.AddValidatorsFromAssemblyContaining<RegisterRequestValidator>();
        services.Configure<Identity.EmailSettings>(configuration.GetSection("EmailSettings"));
        return services;
    }
}
