using SharedKernel.Extensions;
using WasteReportService.Application.Clients;
using WasteReportService.Application.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace WasteReportService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddWasteReportApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<IWasteTypeService, WasteTypeService>();
        services.AddScoped<IWasteReportService, Services.WasteReportService>();
        services.AddScoped<IDistrictService, DistrictService>();
        services.AddInternalHttpClient<IIdentityClient, IdentityClient>(configuration, "IdentityService");
        services.AddInternalHttpClient<ICollectionClient, CollectionClient>(configuration, "CollectionService");
        services.AddInternalHttpClient<IEngagementClient, EngagementClient>(configuration, "EngagementService");
        return services;
    }
}
