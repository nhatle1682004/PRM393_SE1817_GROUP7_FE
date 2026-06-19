using Contracts;

namespace CollectionService.Application.Clients;

public interface IEngagementClient
{
    Task CreateNotificationAsync(CreateNotificationRequest request);
    Task CreateRewardTransactionAsync(CreateRewardTransactionRequest request);
}
