using System.Net.Http.Json;
using System.Text.Json;

namespace DragonFruit.OnionFruit.Downloads;

public sealed class Aria2RpcClient : IDisposable
{
    private static readonly string[] Fields = ["gid", "status", "totalLength", "completedLength", "downloadSpeed", "files"];
    private readonly HttpClient _http = new() { Timeout = TimeSpan.FromSeconds(4) };
    private readonly string _endpoint;
    private readonly string _secret;
    private int _requestId;

    public Aria2RpcClient(int port, string secret)
    {
        _endpoint = $"http://127.0.0.1:{port}/jsonrpc";
        _secret = secret;
    }

    public async Task<JsonElement> CallAsync(string method, params object?[] args)
    {
        var parameters = new List<object?> { $"token:{_secret}" };
        parameters.AddRange(args);
        var payload = new { jsonrpc = "2.0", id = Interlocked.Increment(ref _requestId), method, @params = parameters };
        using var response = await _http.PostAsJsonAsync(_endpoint, payload).ConfigureAwait(false);
        response.EnsureSuccessStatusCode();
        await using var stream = await response.Content.ReadAsStreamAsync().ConfigureAwait(false);
        using var document = await JsonDocument.ParseAsync(stream).ConfigureAwait(false);
        var root = document.RootElement;
        if (root.TryGetProperty("error", out var error))
            throw new InvalidOperationException($"Download engine RPC error: {error.GetRawText()}");
        if (!root.TryGetProperty("result", out var result))
            throw new InvalidOperationException("The engine returned an invalid JSON-RPC response.");
        return result.Clone();
    }

    public Task<JsonElement> GetVersionAsync() => CallAsync("aria2.getVersion");
    public Task<JsonElement> AddUriAsync(string uri, string directory) =>
        CallAsync("aria2.addUri", new[] { uri }, new Dictionary<string, string> { ["dir"] = directory });

    public async Task<IReadOnlyList<JsonElement>> GetDownloadsAsync()
    {
        var active = await CallAsync("aria2.tellActive", (object)Fields).ConfigureAwait(false);
        var waiting = await CallAsync("aria2.tellWaiting", 0, 100, (object)Fields).ConfigureAwait(false);
        var stopped = await CallAsync("aria2.tellStopped", 0, 100, (object)Fields).ConfigureAwait(false);
        var all = new List<JsonElement>();
        AddArray(active, all);
        AddArray(waiting, all);
        AddArray(stopped, all);
        return all;
    }

    public Task<JsonElement> PauseAsync(string gid) => CallAsync("aria2.pause", gid);
    public Task<JsonElement> ResumeAsync(string gid) => CallAsync("aria2.unpause", gid);
    public Task<JsonElement> RemoveAsync(string gid) => CallAsync("aria2.remove", gid);
    public Task<JsonElement> RemoveResultAsync(string gid) => CallAsync("aria2.removeDownloadResult", gid);

    private static void AddArray(JsonElement source, ICollection<JsonElement> destination)
    {
        if (source.ValueKind != JsonValueKind.Array) return;
        foreach (var element in source.EnumerateArray()) destination.Add(element.Clone());
    }

    public void Dispose() => _http.Dispose();
}