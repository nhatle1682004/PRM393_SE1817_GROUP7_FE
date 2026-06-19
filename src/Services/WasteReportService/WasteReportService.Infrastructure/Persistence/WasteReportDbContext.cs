using Microsoft.EntityFrameworkCore;
using WasteReportService.Domain.Entities;

namespace WasteReportService.Infrastructure.Persistence;

public sealed class WasteReportDbContext : DbContext
{
    public WasteReportDbContext(DbContextOptions<WasteReportDbContext> options) : base(options)
    {
    }

    public DbSet<WasteReport> WasteReports => Set<WasteReport>();
    public DbSet<WasteType> WasteTypes => Set<WasteType>();
    public DbSet<District> Districts => Set<District>();
    public DbSet<AiWastePrediction> AiWastePredictions => Set<AiWastePrediction>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("waste");

        modelBuilder.Entity<WasteReport>(entity =>
        {
            entity.ToTable("waste_reports", "waste");
            entity.HasKey(e => e.ReportId).HasName("waste_reports_pkey");
            entity.Property(e => e.ReportId).HasColumnName("report_id");
            entity.Property(e => e.SubmittedBy).HasColumnName("submitted_by");
            entity.Property(e => e.ImageUrl).HasMaxLength(500).HasColumnName("image_url");
            entity.Property(e => e.Latitude).HasPrecision(10, 7).HasColumnName("latitude");
            entity.Property(e => e.Longitude).HasPrecision(10, 7).HasColumnName("longitude");
            entity.Property(e => e.Description).HasMaxLength(500).HasColumnName("description");
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Pending").HasColumnName("status");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("created_at");
            entity.Property(e => e.DistrictId).HasColumnName("district_id");
            entity.HasOne(e => e.District).WithMany(d => d.WasteReports).HasForeignKey(e => e.DistrictId);
            entity.HasMany(e => e.WasteTypes).WithMany(e => e.Reports).UsingEntity<Dictionary<string, object>>(
                "report_waste_types",
                r => r.HasOne<WasteType>().WithMany().HasForeignKey("waste_type_id"),
                l => l.HasOne<WasteReport>().WithMany().HasForeignKey("report_id"),
                j =>
                {
                    j.ToTable("report_waste_types", "waste");
                    j.IndexerProperty<int>("report_id").HasColumnName("report_id");
                    j.IndexerProperty<int>("waste_type_id").HasColumnName("waste_type_id");
                });
        });

        modelBuilder.Entity<WasteType>(entity =>
        {
            entity.ToTable("waste_types", "waste");
            entity.HasKey(e => e.WasteTypeId).HasName("waste_types_pkey");
            entity.Property(e => e.WasteTypeId).HasColumnName("waste_type_id");
            entity.Property(e => e.Name).HasMaxLength(50).HasColumnName("name");
            entity.Property(e => e.Description).HasMaxLength(255).HasColumnName("description");
            entity.Property(e => e.RewardPoints).HasDefaultValue(0).HasColumnName("reward_points");
            entity.Property(e => e.IsActive).HasDefaultValue(true).HasColumnName("is_active");
        });

        modelBuilder.Entity<District>(entity =>
        {
            entity.ToTable("districts", "waste");
            entity.HasKey(e => e.DistrictId).HasName("districts_pkey");
            entity.Property(e => e.DistrictId).HasColumnName("district_id");
            entity.Property(e => e.Name).HasMaxLength(100).HasColumnName("name");
            entity.Property(e => e.Code).HasMaxLength(20).HasColumnName("code");
            entity.Property(e => e.IsActive).HasDefaultValue(true).HasColumnName("is_active");
        });

        modelBuilder.Entity<AiWastePrediction>(entity =>
        {
            entity.ToTable("ai_waste_predictions", "waste");
            entity.HasKey(e => e.PredictionId).HasName("ai_waste_predictions_pkey");
            entity.Property(e => e.PredictionId).HasColumnName("prediction_id");
            entity.Property(e => e.ReportId).HasColumnName("report_id");
            entity.Property(e => e.SuggestedType).HasMaxLength(50).HasColumnName("suggested_type");
            entity.Property(e => e.Confidence).HasPrecision(5, 2).HasColumnName("confidence");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("created_at");
            entity.HasOne(e => e.Report).WithMany(r => r.AiWastePredictions).HasForeignKey(e => e.ReportId).OnDelete(DeleteBehavior.ClientSetNull);
        });
    }
}
