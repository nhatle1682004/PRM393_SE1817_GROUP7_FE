namespace EventBus;

public sealed class InMemoryEventBusPlaceholder
{
    public Task PublishAsync(IIntegrationEvent integrationEvent, CancellationToken cancellationToken = default)
    {
        return Task.CompletedTask;
    }
}
