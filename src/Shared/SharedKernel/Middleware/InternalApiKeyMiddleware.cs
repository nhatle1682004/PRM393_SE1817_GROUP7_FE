using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace SharedKernel.Middleware;

public sealed class InternalApiKeyMiddleware
{
    private const string HeaderName = "X-Internal-Api-Key";
    private readonly RequestDelegate _next;

    public InternalApiKeyMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, IConfiguration configuration)
    {
        if (!context.Request.Path.StartsWithSegments("/internal"))
        {
            await _next(context);
            return;
        }

        var expected = configuration["InternalApiKey"];
        if (string.IsNullOrWhiteSpace(expected))
        {
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await context.Response.WriteAsJsonAsync(new { message = "InternalApiKey is not configured" });
            return;
        }

        if (!context.Request.Headers.TryGetValue(HeaderName, out var provided)
            || !string.Equals(provided.ToString(), expected, StringComparison.Ordinal))
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsJsonAsync(new { message = "Invalid internal API key" });
            return;
        }

        await _next(context);
    }
}
