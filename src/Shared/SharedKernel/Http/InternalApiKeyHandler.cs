using Microsoft.Extensions.Configuration;

namespace SharedKernel.Http;

public sealed class InternalApiKeyHandler : DelegatingHandler
{
    private readonly IConfiguration _configuration;

    public InternalApiKeyHandler(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var key = _configuration["InternalApiKey"];
        if (!string.IsNullOrWhiteSpace(key))
        {
            request.Headers.Remove("X-Internal-Api-Key");
            request.Headers.Add("X-Internal-Api-Key", key);
        }

        return base.SendAsync(request, cancellationToken);
    }
}
