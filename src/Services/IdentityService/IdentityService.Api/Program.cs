using FluentValidation.AspNetCore;
using IdentityService.Application;
using IdentityService.Infrastructure;
using SharedKernel.Extensions;
using System.Globalization;

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

var builder = WebApplication.CreateBuilder(args);
CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture;
CultureInfo.DefaultThreadCurrentUICulture = CultureInfo.InvariantCulture;

builder.Services.AddMemoryCache();
builder.Services.AddControllers();
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddSharedCors();
builder.Services.AddSharedJwtAuthentication(builder.Configuration);
builder.Services.AddSharedSwagger("Identity Service");
builder.Services.AddIdentityApplication(builder.Configuration);
builder.Services.AddIdentityInfrastructure(builder.Configuration);

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
