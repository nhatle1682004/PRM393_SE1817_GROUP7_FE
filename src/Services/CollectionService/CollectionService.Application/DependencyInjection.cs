using CollectionService.Application.Clients;
using CollectionService.Application.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SharedKernel.Extensions;

namespace CollectionService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddCollectionApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<ICollectionRequestService, CollectionRequestService>();
        services.AddScoped<IAssignmentService, AssignmentService>();
        services.AddScoped<ICollectionService, Services.CollectionService>();
        services.AddInternalHttpClient<IIdentityClient, IdentityClient>(configuration, "IdentityService");
        services.AddInternalHttpClient<IWasteReportClient, WasteReportClient>(configuration, "WasteReportService");
        services.AddInternalHttpClient<IEngagementClient, EngagementClient>(configuration, "EngagementService");
        return services;
    }
}
