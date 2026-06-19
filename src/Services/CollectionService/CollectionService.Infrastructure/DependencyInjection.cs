using CollectionService.Application.Repositories;
using CollectionService.Infrastructure.Persistence;
using CollectionService.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace CollectionService.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddCollectionInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<CollectionDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection"),
                npgsql => npgsql.MigrationsHistoryTable("__EFMigrationsHistory", "collection")));

        services.AddScoped<ICollectionRequestRepository, CollectionRequestRepository>();
        services.AddScoped<ICollectorAssignmentRepository, CollectorAssignmentRepository>();
        services.AddScoped<ICollectionUnitOfWork, CollectionUnitOfWork>();
        return services;
    }
}
