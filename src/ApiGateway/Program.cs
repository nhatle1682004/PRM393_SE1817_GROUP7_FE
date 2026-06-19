using SharedKernel.Extensions;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);
CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture;
CultureInfo.DefaultThreadCurrentUICulture = CultureInfo.InvariantCulture;

builder.Services.AddSharedCors();
builder.Services.AddReverseProxy().LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();
app.UseSharedRequestLocalization();
app.UseCors("AllowReactApp");
app.MapReverseProxy();
app.Run();
