using CollectionService.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace CollectionService.Infrastructure.Persistence;

public sealed class CollectionDbContext : DbContext
{
    public CollectionDbContext(DbContextOptions<CollectionDbContext> options) : base(options)
    {
    }

    public DbSet<CollectionRequest> CollectionRequests => Set<CollectionRequest>();
    public DbSet<CollectorAssignment> CollectorAssignments => Set<CollectorAssignment>();
    public DbSet<CollectionConfirmation> CollectionConfirmations => Set<CollectionConfirmation>();
    public DbSet<CollectionDetail> CollectionDetails => Set<CollectionDetail>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("collection");

        modelBuilder.Entity<CollectionRequest>(entity =>
        {
            entity.ToTable("collection_requests", "collection");
            entity.HasKey(e => e.RequestId).HasName("collection_requests_pkey");
            entity.HasIndex(e => e.ReportId).IsUnique();
            entity.Property(e => e.RequestId).HasColumnName("request_id");
            entity.Property(e => e.ReportId).HasColumnName("report_id");
            entity.Property(e => e.EnterpriseId).HasColumnName("enterprise_id");
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Pending").HasColumnName("status");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("created_at");
            entity.Property(e => e.Note).HasMaxLength(500).HasColumnName("note");
            entity.Property(e => e.IssueReport).HasMaxLength(50).HasColumnName("issue_report");
            entity.Property(e => e.IssueReason).HasMaxLength(1000).HasColumnName("issue_reason");
            entity.Property(e => e.IssueImageUrl).HasMaxLength(500).HasColumnName("issue_image_url");
        });

        modelBuilder.Entity<CollectorAssignment>(entity =>
        {
            entity.ToTable("collector_assignments", "collection");
            entity.HasKey(e => e.AssignmentId).HasName("collector_assignments_pkey");
            entity.Property(e => e.AssignmentId).HasColumnName("assignment_id");
            entity.Property(e => e.RequestId).HasColumnName("request_id");
            entity.Property(e => e.AssignedCollector).HasColumnName("assigned_collector");
            entity.Property(e => e.AssignedBy).HasColumnName("assigned_by");
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Assigned").HasColumnName("status");
            entity.Property(e => e.AssignedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("assigned_at");
            entity.Property(e => e.StartedAt).HasColumnType("timestamp without time zone").HasColumnName("started_at");
            entity.Property(e => e.ArrivedAt).HasColumnType("timestamp without time zone").HasColumnName("arrived_at");
            entity.Property(e => e.BeforeImageUrl).HasColumnType("text").HasColumnName("before_image_url");
            entity.HasOne(e => e.Request).WithMany(r => r.CollectorAssignments).HasForeignKey(e => e.RequestId).OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<CollectionConfirmation>(entity =>
        {
            entity.ToTable("collection_confirmations", "collection");
            entity.HasKey(e => e.ConfirmationId).HasName("collection_confirmations_pkey");
            entity.HasIndex(e => e.AssignmentId).IsUnique();
            entity.Property(e => e.ConfirmationId).HasColumnName("confirmation_id");
            entity.Property(e => e.AssignmentId).HasColumnName("assignment_id");
            entity.Property(e => e.Note).HasMaxLength(255).HasColumnName("note");
            entity.Property(e => e.ConfirmedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("confirmed_at");
            entity.Property(e => e.BeforeImageUrl).HasColumnType("text").HasColumnName("before_image_url");
            entity.Property(e => e.AfterImageUrl).HasColumnType("text").HasColumnName("after_image_url");
            entity.HasOne(e => e.Assignment).WithOne(a => a.CollectionConfirmation).HasForeignKey<CollectionConfirmation>(e => e.AssignmentId).OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<CollectionDetail>(entity =>
        {
            entity.ToTable("collection_details", "collection");
            entity.HasKey(e => e.DetailId).HasName("collection_details_pkey");
            entity.Property(e => e.DetailId).HasColumnName("detail_id");
            entity.Property(e => e.ConfirmationId).HasColumnName("confirmation_id");
            entity.Property(e => e.WasteTypeId).HasColumnName("waste_type_id");
            entity.Property(e => e.ActualWeight).HasColumnName("actual_weight");
            entity.HasOne(e => e.Confirmation).WithMany(c => c.CollectionDetails).HasForeignKey(e => e.ConfirmationId).OnDelete(DeleteBehavior.ClientSetNull);
        });
    }
}
