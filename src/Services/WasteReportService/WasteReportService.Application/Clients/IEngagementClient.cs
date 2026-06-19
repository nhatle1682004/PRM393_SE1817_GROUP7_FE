using Contracts;

namespace WasteReportService.Application.Clients;

public interface IEngagementClient
{
    Task CreateNotificationAsync(CreateNotificationRequest request);
}
