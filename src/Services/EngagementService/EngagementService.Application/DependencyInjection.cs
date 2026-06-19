using EngagementService.Application.Clients;
using EngagementService.Application.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SharedKernel.Extensions;

namespace EngagementService.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddEngagementApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IRewardService, RewardService>();
        services.AddScoped<IFeedbackService, FeedbackService>();
        services.AddScoped<IDashboardService, DashboardService>();
        services.AddInternalHttpClient<IIdentityClient, IdentityClient>(configuration, "IdentityService");
        services.AddInternalHttpClient<IWasteReportClient, WasteReportClient>(configuration, "WasteReportService");
        services.AddInternalHttpClient<ICollectionClient, CollectionClient>(configuration, "CollectionService");
        return services;
    }
}
