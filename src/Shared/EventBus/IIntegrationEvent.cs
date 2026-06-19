namespace EventBus;

public interface IIntegrationEvent
{
    Guid EventId { get; }
    DateTime OccurredAtUtc { get; }
}
