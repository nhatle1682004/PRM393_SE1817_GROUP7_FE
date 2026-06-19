using EngagementService.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace EngagementService.Infrastructure.Persistence;

public sealed class EngagementDbContext : DbContext
{
    public EngagementDbContext(DbContextOptions<EngagementDbContext> options) : base(options)
    {
    }

    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<Reward> Rewards => Set<Reward>();
    public DbSet<RewardTransaction> RewardTransactions => Set<RewardTransaction>();
    public DbSet<Feedback> Feedbacks => Set<Feedback>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("engagement");

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.ToTable("notifications", "engagement");
            entity.HasKey(e => e.NotificationId).HasName("notifications_pkey");
            entity.Property(e => e.NotificationId).HasColumnName("notification_id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Content).HasMaxLength(255).HasColumnName("content");
            entity.Property(e => e.IsRead).HasDefaultValue(false).HasColumnName("is_read");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("created_at");
        });

        modelBuilder.Entity<Reward>(entity =>
        {
            entity.ToTable("rewards", "engagement");
            entity.HasKey(e => e.RewardId).HasName("rewards_pkey");
            entity.Property(e => e.RewardId).HasColumnName("reward_id");
            entity.Property(e => e.Name).HasMaxLength(100).HasColumnName("name");
            entity.Property(e => e.Description).HasMaxLength(255).HasColumnName("description");
            entity.Property(e => e.Points).HasColumnName("points");
            entity.Property(e => e.Status).HasDefaultValue(true).HasColumnName("status");
        });

        modelBuilder.Entity<RewardTransaction>(entity =>
        {
            entity.ToTable("reward_transactions", "engagement");
            entity.HasKey(e => e.TransactionId).HasName("reward_transactions_pkey");
            entity.Property(e => e.TransactionId).HasColumnName("transaction_id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.RewardId).HasColumnName("reward_id");
            entity.Property(e => e.Type).HasMaxLength(10).HasDefaultValue("redeem").HasColumnName("type");
            entity.Property(e => e.Points).HasDefaultValue(0).HasColumnName("points");
            entity.Property(e => e.Description).HasColumnType("text").HasColumnName("description");
            entity.Property(e => e.ReportId).HasColumnName("report_id");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("created_at");
            entity.HasOne(e => e.Reward).WithMany(r => r.RewardTransactions).HasForeignKey(e => e.RewardId);
        });

        modelBuilder.Entity<Feedback>(entity =>
        {
            entity.ToTable("feedbacks", "engagement");
            entity.HasKey(e => e.FeedbackId).HasName("feedbacks_pkey");
            entity.Property(e => e.FeedbackId).HasColumnName("feedback_id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.ReportId).HasColumnName("report_id");
            entity.Property(e => e.Content).HasColumnName("content");
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Pending").HasColumnName("status");
            entity.Property(e => e.ImageUrl).HasColumnType("text").HasColumnName("image_url");
            entity.Property(e => e.ResolutionNote).HasColumnType("text").HasColumnName("resolution_note");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("created_at");
        });
    }
}
