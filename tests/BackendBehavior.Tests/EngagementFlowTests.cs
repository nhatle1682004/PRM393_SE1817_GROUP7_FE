using Contracts;
using EngagementService.Application.Clients;
using EngagementService.Application.DTOs.Feedback;
using EngagementService.Application.Repositories;
using EngagementService.Application.Services;
using EngagementService.Domain.Entities;
using Microsoft.Extensions.Logging.Abstractions;
using NSubstitute;
using Xunit;

namespace BackendBehavior.Tests;

public sealed class EngagementFlowTests
{
    [Fact]
    public async Task ResolveFeedback_ReassignsWarnsReversesAndRewardsThroughServiceClients()
    {
        var feedback = new Feedback { FeedbackId = 5, UserId = 10, ReportId = 20, Content = "missed", Status = "Pending" };
        var uow = Substitute.For<IEngagementUnitOfWork>();
        uow.Feedbacks.Returns(new[] { feedback }.AsQueryable());
        uow.RewardTransactions.Returns(new[]
        {
            new RewardTransaction { TransactionId = 1, UserId = 10, ReportId = 20, Points = 12, Type = "Earned", SourceType = "Collection", Status = "Completed" }
        }.AsQueryable());
        uow.Notifications.Returns(Array.Empty<Notification>().AsQueryable());
        uow.Rewards.Returns(Array.Empty<Reward>().AsQueryable());
        uow.SaveChangesAsync(Arg.Any<CancellationToken>()).Returns(1);
        uow.ExecuteInTransactionAsync(Arg.Any<Func<Task>>(), Arg.Any<CancellationToken>())
            .Returns(call => call.Arg<Func<Task>>()());

        var identity = Substitute.For<IIdentityClient>();
        identity.GetUserAsync(10).Returns(new UserDto { UserId = 10, FullName = "Citizen" });
        identity.AddCollectorWarningAsync(50, 2, Arg.Any<string>()).Returns(new CollectorProfileDto
        {
            CollectorId = 50,
            EnterpriseId = 30,
            WarningCount = 2,
            Status = "Active"
        });
        var waste = Substitute.For<IWasteReportClient>();
        waste.GetReportAsync(20).Returns(new WasteReportDto { ReportId = 20, SubmittedBy = 10, Status = "Collected" });
        waste.UpdateReportStatusAsync(20, "Accepted").Returns(Task.CompletedTask);
        var collection = Substitute.For<ICollectionClient>();
        collection.GetFeedbackContextByReportAsync(20).Returns(new CollectionFeedbackContextDto
        {
            RequestId = 40,
            EnterpriseId = 30,
            AssignmentId = 45,
            CollectorId = 50,
            AssignmentStatus = "Completed"
        });
        collection.CancelAssignmentForComplaintAsync(Arg.Any<CancelAssignmentForComplaintRequest>()).Returns(Task.CompletedTask);
        var notifications = Substitute.For<INotificationService>();
        notifications.CreateAsync(Arg.Any<CreateNotificationRequest>()).Returns(new NotificationDto());
        var rewards = Substitute.For<IRewardService>();
        var rewardRequests = new List<CreateRewardTransactionRequest>();
        rewards.CreateTransactionAsync(Arg.Do<CreateRewardTransactionRequest>(rewardRequests.Add))
            .Returns(new RewardTransactionDto { Status = "Completed" });

        var service = new FeedbackService(uow, identity, waste, collection, notifications, rewards, NullLogger<FeedbackService>.Instance);
        var result = await service.ResolveFeedbackAsync(feedback.FeedbackId, new ResolveFeedbackDto
        {
            Action = "reassign",
            AdminNote = "Valid complaint"
        });

        Assert.Equal("Resolved", result.Status);
        Assert.Equal("Valid complaint", result.ResolutionNote);
        await waste.Received(1).UpdateReportStatusAsync(20, "Accepted");
        await collection.Received(1).CancelAssignmentForComplaintAsync(Arg.Is<CancelAssignmentForComplaintRequest>(request =>
            request.AssignmentId == 45 && request.RequestId == 40 && request.RequestStatus == "Pending"));
        await identity.Received(1).AddCollectorWarningAsync(50, 2, "Valid complaint");
        Assert.Contains(rewardRequests, request => request.SourceType == "ComplaintReversal" && request.Points == -12);
        Assert.Contains(rewardRequests, request => request.SourceType == "ComplaintReward" && request.Points == 10);
    }

    [Fact]
    public async Task CompletedRewardTransaction_IsIdempotentForCollectionRetry()
    {
        var existing = new RewardTransaction
        {
            TransactionId = 8,
            UserId = 10,
            ReportId = 20,
            Points = 15,
            Type = "Earned",
            SourceType = "Collection",
            ReferenceId = "40",
            Status = "Completed"
        };
        var uow = Substitute.For<IEngagementUnitOfWork>();
        uow.RewardTransactions.Returns(new[] { existing }.AsQueryable());
        uow.Rewards.Returns(Array.Empty<Reward>().AsQueryable());
        uow.Notifications.Returns(Array.Empty<Notification>().AsQueryable());
        uow.Feedbacks.Returns(Array.Empty<Feedback>().AsQueryable());
        var identity = Substitute.For<IIdentityClient>();
        var service = new RewardService(uow, identity, Substitute.For<INotificationService>(), NullLogger<RewardService>.Instance);

        var result = await service.CreateTransactionAsync(new CreateRewardTransactionRequest
        {
            UserId = 10,
            ReportId = 20,
            Points = 15,
            Type = "Earned",
            SourceType = "Collection",
            ReferenceId = "40",
            AdjustUserPoints = true
        });

        Assert.Equal(existing.TransactionId, result.TransactionId);
        await identity.DidNotReceiveWithAnyArgs().AddPointsAsync(default, default, default!);
        await uow.DidNotReceiveWithAnyArgs().AddRewardTransactionAsync(default!);
    }
}
