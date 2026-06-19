using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Localization;
using SharedKernel.Middleware;
using System.Globalization;

namespace SharedKernel.Extensions;

public static class ApplicationBuilderExtensions
{
    public static IApplicationBuilder UseSharedRequestLocalization(this IApplicationBuilder app)
    {
        var invariantCulture = CultureInfo.InvariantCulture;
        return app.UseRequestLocalization(new RequestLocalizationOptions
        {
            DefaultRequestCulture = new RequestCulture(invariantCulture),
            SupportedCultures = new[] { invariantCulture },
            SupportedUICultures = new[] { invariantCulture }
        });
    }

    public static IApplicationBuilder UseInternalApiKey(this IApplicationBuilder app)
    {
        return app.UseMiddleware<InternalApiKeyMiddleware>();
    }
}
