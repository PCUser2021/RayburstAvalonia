using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography;

namespace DragonFruit.OnionFruit.Downloads;

public sealed class EngineHost : IDisposable
{
    private Process? _process;
    private Aria2RpcClient? _rpc;
    private bool _disposed;
    public bool IsStarted => _process is { HasExited: false } && _rpc is not null;
    public Aria2RpcClient Rpc => _rpc ?? throw new InvalidOperationException("The download engine is not started.");

    public async Task StartAsync(string outputDirectory, CancellationToken cancellationToken = default)
    {
        if (IsStarted) return;
        var executable = Path.Combine(AppContext.BaseDirectory, "aria2-next.exe");
        if (!File.Exists(executable))
            throw new FileNotFoundException("aria2-next.exe was not found beside Rayburst. Use the CI installer or place the matching architecture binary beside the application.", executable);

        Directory.CreateDirectory(outputDirectory);
        var port = GetEphemeralLoopbackPort();
        var secret = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)).TrimEnd('=').Replace('+', '-').Replace('/', '_');
        Directory.CreateDirectory(App.StoragePath);
        var sessionFile = Path.Combine(App.StoragePath, "aria2-session.txt");
        if (!File.Exists(sessionFile)) await File.WriteAllTextAsync(sessionFile, string.Empty, cancellationToken).ConfigureAwait(false);

        var info = new ProcessStartInfo
        {
            FileName = executable,
            WorkingDirectory = AppContext.BaseDirectory,
            UseShellExecute = false,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden
        };
        string[] arguments =
        [
            "--enable-rpc=true", "--rpc-listen-all=false", $"--rpc-listen-port={port}", $"--rpc-secret={secret}",
            $"--dir={Path.GetFullPath(outputDirectory)}", $"--input-file={sessionFile}", $"--save-session={sessionFile}",
            "--save-session-interval=30", "--continue=true", "--max-concurrent-downloads=5",
            "--console-log-level=warn", "--summary-interval=0"
        ];
        foreach (var argument in arguments) info.ArgumentList.Add(argument);
        _process = new Process { StartInfo = info, EnableRaisingEvents = true };
        if (!_process.Start()) throw new InvalidOperationException("Could not start the download engine.");
        _rpc = new Aria2RpcClient(port, secret);

        Exception? lastError = null;
        for (var attempt = 0; attempt < 50; attempt++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (_process.HasExited) throw new InvalidOperationException($"The engine exited during startup (exit code {_process.ExitCode}).");
            try { await _rpc.GetVersionAsync().ConfigureAwait(false); return; }
            catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or InvalidOperationException)
            {
                lastError = ex;
                await Task.Delay(200, cancellationToken).ConfigureAwait(false);
            }
        }
        StopEngine();
        throw new InvalidOperationException("The engine's loopback RPC service did not become ready.", lastError);
    }

    private static int GetEphemeralLoopbackPort()
    {
        using var listener = new TcpListener(IPAddress.Loopback, 0);
        listener.Start();
        return ((IPEndPoint)listener.LocalEndpoint).Port;
    }

    private void StopEngine()
    {
        try
        {
            if (_process is { HasExited: false } && _rpc is not null)
                _rpc.CallAsync("aria2.shutdown").GetAwaiter().GetResult();
        }
        catch (Exception) { /* If RPC shutdown fails, terminate the child below. */ }
        _rpc?.Dispose();
        _rpc = null;
        try
        {
            if (_process is { HasExited: false } && !_process.WaitForExit(4000))
                _process.Kill(entireProcessTree: true);
        }
        catch (InvalidOperationException) { }
        catch (System.ComponentModel.Win32Exception) { }
        _process?.Dispose();
        _process = null;
    }

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;
        StopEngine();
        GC.SuppressFinalize(this);
    }
}