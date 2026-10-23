param([Parameter(Mandatory = $true)][string]$SourceRoot)
$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath $SourceRoot).Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$required = @(
    'DragonFruit.OnionFruit.Windows\DragonFruit.OnionFruit.Windows.csproj',
    'DragonFruit.OnionFruit\App.axaml.cs',
    'DragonFruit.OnionFruit\DragonFruit.OnionFruit.csproj'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $source $relative))) {
        throw "Not the expected OnionFruit source tree: missing $relative"
    }
}

$views = Join-Path $source 'DragonFruit.OnionFruit\Views'
$downloads = Join-Path $source 'DragonFruit.OnionFruit\Downloads'
New-Item -ItemType Directory -Force -Path $downloads | Out-Null
Copy-Item -LiteralPath (Join-Path $repoRoot 'port\DragonFruit.OnionFruit\Views\RayburstMainWindow.axaml') -Destination $views -Force
Copy-Item -LiteralPath (Join-Path $repoRoot 'port\DragonFruit.OnionFruit\Views\RayburstMainWindow.axaml.cs') -Destination $views -Force
Copy-Item -Path (Join-Path $repoRoot 'port\DragonFruit.OnionFruit\Downloads\*') -Destination $downloads -Force

# Replace the upstream Windows shell entry point with a minimal Avalonia host.
$program = @'
using Avalonia;
using Microsoft.Extensions.Hosting;
using ReactiveUI.Avalonia;

namespace DragonFruit.OnionFruit.Windows;

public static class Program
{
    private static IHost? _host;

    [STAThread]
    public static void Main(string[] args)
    {
        _host = Host.CreateDefaultBuilder().Build();
        try { BuildAvaloniaApp().StartWithClassicDesktopLifetime(args); }
        finally { _host.Dispose(); }
    }

    public static AppBuilder BuildAvaloniaApp() =>
        AppBuilder.Configure(() => new DragonFruit.OnionFruit.App(_host ?? Host.CreateDefaultBuilder().Build()))
            .UsePlatformDetect()
            .UseReactiveUI(_ => { });
}
'@
Set-Content -LiteralPath (Join-Path $source 'DragonFruit.OnionFruit.Windows\Program.cs') -Value $program -Encoding utf8

$appPath = Join-Path $source 'DragonFruit.OnionFruit\App.axaml.cs'
$appCode = Get-Content -LiteralPath $appPath -Raw
$appCode = $appCode.Replace('"DragonFruit Network", "OnionFruit"', '"PCUser2021", "Rayburst"')
$appCode = $appCode.Replace('Title = "OnionFruit™ Development Edition";', 'Title = "Rayburst Avalonia (Development)";')
$appCode = $appCode.Replace('Title = "OnionFruit™";', 'Title = "Rayburst Avalonia";')
$startMarker = '        private void StartAvaloniaApp()'
$endMarker = '        public async Task RequestAppShutdown()'
$start = $appCode.IndexOf($startMarker, [StringComparison]::Ordinal)
$end = if ($start -ge 0) { $appCode.IndexOf($endMarker, $start, [StringComparison]::Ordinal) } else { -1 }
if ($start -lt 0 -or $end -lt 0) { throw 'Unexpected upstream App.axaml.cs; no files were modified past this point.' }
$replacement = @'
        private void StartAvaloniaApp()
        {
            if (ApplicationLifetime is not IClassicDesktopStyleApplicationLifetime desktop)
                throw new InvalidOperationException("Rayburst requires the classic desktop lifetime.");

            // OnionFruit's Tor, proxy and DNS runtime must not start in the Rayburst port.
            desktop.ShutdownMode = ShutdownMode.OnMainWindowClose;
            desktop.MainWindow = new Views.RayburstMainWindow();
        }

'@
$appCode = $appCode.Substring(0, $start) + $replacement + $appCode.Substring($end)
Set-Content -LiteralPath $appPath -Value $appCode -Encoding utf8

$appXamlPath = Join-Path $source 'DragonFruit.OnionFruit\App.axaml'
$appXaml = Get-Content -LiteralPath $appXamlPath -Raw
$appXaml = $appXaml.Replace('CustomAccentColor="#c71585"', 'CustomAccentColor="#48D9D0"')
Set-Content -LiteralPath $appXamlPath -Value $appXaml -Encoding utf8

$icon = Join-Path $source 'DragonFruit.OnionFruit\Assets\icon.ico'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AnInsomniacy/rayburst/main/src-tauri/icons/icon.ico' -OutFile $icon
Write-Host 'Rayburst overlay applied. Run: dotnet run --project DragonFruit.OnionFruit.Windows'
