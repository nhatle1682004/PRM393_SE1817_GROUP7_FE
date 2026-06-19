using EngagementService.Application.Repositories;
using EngagementService.Infrastructure.Persistence;
using EngagementService.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace EngagementService.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddEngagementInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<EngagementDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection"),
                npgsql => npgsql.MigrationsHistoryTable("__EFMigrationsHistory", "engagement")));

        services.AddScoped<IEngagementUnitOfWork, EngagementUnitOfWork>();
        return services;
    }
}
