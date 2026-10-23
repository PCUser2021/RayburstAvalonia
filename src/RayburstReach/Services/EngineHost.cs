using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography;

namespace RayburstReach.Services;

public sealed class EngineHost : IDisposable
{
    private Process? _process;
    private Aria2RpcClient? _rpc;
    private int _port;
    private string _secret = string.Empty;
    private bool _disposed;

    public bool IsStarted => _process is { HasExited: false } && _rpc is not null;
    public Aria2RpcClient Rpc => _rpc ?? throw new InvalidOperationException("The download engine is not started.");

    public async Task StartAsync(string outputDirectory, CancellationToken cancellationToken = default)
    {
        if (IsStarted) return;
        var executable = Path.Combine(AppContext.BaseDirectory, "aria2-next.exe");
        if (!File.Exists(executable))
            throw new FileNotFoundException("aria2-next.exe was not found beside the application. Install the official package or run the repository's build workflow.", executable);

        Directory.CreateDirectory(outputDirectory);
        _port = GetEphemeralLoopbackPort();
        _secret = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)).TrimEnd('=').Replace('+', '-').Replace('/', '_');
        var stateDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "RayburstReach");
        Directory.CreateDirectory(stateDirectory);
        var sessionFile = Path.Combine(stateDirectory, "aria2-session.txt");
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
            "--enable-rpc=true",
            "--rpc-listen-all=false",
            $"--rpc-listen-port={_port}",
            $"--rpc-secret={_secret}",
            "--rpc-allow-origin-all=false",
            $"--dir={Path.GetFullPath(outputDirectory)}",
            $"--input-file={sessionFile}",
            $"--save-session={sessionFile}",
            "--save-session-interval=30",
            "--continue=true",
            "--max-concurrent-downloads=5",
            "--console-log-level=warn",
            "--summary-interval=0"
        ];
        foreach (var argument in arguments) info.ArgumentList.Add(argument);

        _process = new Process { StartInfo = info, EnableRaisingEvents = true };
        if (!_process.Start()) throw new InvalidOperationException("Could not start Aria2 Next.");
        _rpc = new Aria2RpcClient(_port, _secret);

        Exception? lastError = null;
        for (var attempt = 0; attempt < 50; attempt++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (_process.HasExited)
                throw new InvalidOperationException($"Aria2 Next exited during startup (exit code {_process.ExitCode}). Check the bundled engine binary and architecture.");
            try
            {
                await _rpc.GetVersionAsync().ConfigureAwait(false);
                return;
            }
            catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or InvalidOperationException)
            {
                lastError = ex;
                await Task.Delay(200, cancellationToken).ConfigureAwait(false);
            }
        }
        DisposeEngine();
        throw new InvalidOperationException("Aria2 Next did not start its loopback RPC service in time.", lastError);
    }

    private static int GetEphemeralLoopbackPort()
    {
        using var listener = new TcpListener(IPAddress.Loopback, 0);
        listener.Start();
        return ((IPEndPoint)listener.LocalEndpoint).Port;
    }

    private void DisposeEngine()
    {
        try
        {
            if (_process is { HasExited: false } && _rpc is not null)
                _rpc.CallAsync("aria2.shutdown").GetAwaiter().GetResult();
        }
        catch (Exception) { /* Fall back to terminating the child if the RPC endpoint is already gone. */ }
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
        DisposeEngine();
        GC.SuppressFinalize(this);
    }
}
