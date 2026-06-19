using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using WasteReportService.Application.Repositories;
using WasteReportService.Infrastructure.Persistence;
using WasteReportService.Infrastructure.Repositories;

namespace WasteReportService.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddWasteReportInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<WasteReportDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection"),
                npgsql => npgsql.MigrationsHistoryTable("__EFMigrationsHistory", "waste")));

        services.AddScoped<IWasteTypeRepository, WasteTypeRepository>();
        services.AddScoped<IWasteReportRepository, WasteReportRepository>();
        services.AddScoped<IWasteUnitOfWork, WasteUnitOfWork>();
        return services;
    }
}
