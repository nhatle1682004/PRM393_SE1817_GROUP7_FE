using IdentityService.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Infrastructure.Persistence;

public sealed class IdentityDbContext : DbContext
{
    public IdentityDbContext(DbContextOptions<IdentityDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<EnterpriseProfile> EnterpriseProfiles => Set<EnterpriseProfile>();
    public DbSet<CollectorProfile> CollectorProfiles => Set<CollectorProfile>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("identity");

        modelBuilder.Entity<Role>(entity =>
        {
            entity.ToTable("roles", "identity");
            entity.HasKey(e => e.RoleId).HasName("roles_pkey");
            entity.HasIndex(e => e.RoleName).IsUnique();
            entity.Property(e => e.RoleId).HasColumnName("role_id");
            entity.Property(e => e.RoleName).HasMaxLength(30).HasColumnName("role_name");
            entity.Property(e => e.Description).HasMaxLength(255).HasColumnName("description");
        });

        modelBuilder.Entity<Role>().HasData(
            new Role
            {
                RoleId = 1,
                RoleName = "Citizen",
                Description = "Regular citizen user"
            },
            new Role
            {
                RoleId = 2,
                RoleName = "Collector",
                Description = "Waste collector"
            },
            new Role
            {
                RoleId = 3,
                RoleName = "Enterprise",
                Description = "Enterprise account"
            },
            new Role
            {
                RoleId = 4,
                RoleName = "Admin",
                Description = "System administrator"
            }
        );

        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users", "identity");
            entity.HasKey(e => e.UserId).HasName("users_pkey");
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Phone).IsUnique();
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.RoleId).HasColumnName("role_id");
            entity.Property(e => e.FullName).HasMaxLength(100).HasColumnName("full_name");
            entity.Property(e => e.Email).HasMaxLength(100).HasColumnName("email");
            entity.Property(e => e.Password).HasMaxLength(255).HasColumnName("password");
            entity.Property(e => e.Phone).HasMaxLength(20).HasColumnName("phone");
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Active").HasColumnName("status");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasDefaultValueSql("CURRENT_TIMESTAMP").HasColumnName("created_at");
            entity.Property(e => e.TotalPoints).HasDefaultValue(0).HasColumnName("total_points");
            entity.HasOne(e => e.Role).WithMany(r => r.Users).HasForeignKey(e => e.RoleId).OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<EnterpriseProfile>(entity =>
        {
            entity.ToTable("enterprise_profiles", "identity");
            entity.HasKey(e => e.EnterpriseId).HasName("enterprise_profiles_pkey");
            entity.Property(e => e.EnterpriseId).HasColumnName("enterprise_id");
            entity.Property(e => e.ManagedDistrictId).HasColumnName("managed_district_id");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasColumnName("created_at");
            entity.HasOne(e => e.Enterprise).WithOne(u => u.EnterpriseProfile).HasForeignKey<EnterpriseProfile>(e => e.EnterpriseId).OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<CollectorProfile>(entity =>
        {
            entity.ToTable("collector_profiles", "identity");
            entity.HasKey(e => e.CollectorId).HasName("collector_profiles_pkey");
            entity.Property(e => e.CollectorId).HasColumnName("collector_id");
            entity.Property(e => e.EnterpriseId).HasColumnName("enterprise_id");
            entity.Property(e => e.IsAvailable).HasColumnName("is_available");
            entity.Property(e => e.AvailabilityUpdatedAt).HasColumnType("timestamp with time zone").HasColumnName("availability_updated_at");
            entity.Property(e => e.WarningCount).HasDefaultValue(0).HasColumnName("warning_count");
            entity.Property(e => e.CreatedAt).HasColumnType("timestamp without time zone").HasColumnName("created_at");
            entity.HasOne(e => e.Collector).WithOne(u => u.CollectorProfile).HasForeignKey<CollectorProfile>(e => e.CollectorId).OnDelete(DeleteBehavior.ClientSetNull);
            entity.HasOne(e => e.EnterpriseProfile).WithMany(p => p.CollectorProfiles).HasForeignKey(e => e.EnterpriseId).HasPrincipalKey(p => p.EnterpriseId).OnDelete(DeleteBehavior.ClientSetNull);
        });
    }
}
