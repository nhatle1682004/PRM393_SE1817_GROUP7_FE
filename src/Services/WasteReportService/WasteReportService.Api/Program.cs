using SharedKernel.Extensions;
using System.Globalization;
using WasteReportService.Application;
using WasteReportService.Infrastructure;

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

var builder = WebApplication.CreateBuilder(args);
CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture;
CultureInfo.DefaultThreadCurrentUICulture = CultureInfo.InvariantCulture;

builder.Services.AddControllers();
builder.Services.AddSharedCors();
builder.Services.AddSharedJwtAuthentication(builder.Configuration);
builder.Services.AddSharedSwagger("Waste Report Service");
builder.Services.AddWasteReportApplication(builder.Configuration);
builder.Services.AddWasteReportInfrastructure(builder.Configuration);

var app = builder.Build();
app.UseSharedRequestLocalization();
app.UseInternalApiKey();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowReactApp");
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
