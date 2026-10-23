using System.Collections.ObjectModel;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Media;
using Avalonia.Platform.Storage;
using Avalonia.Threading;
using DragonFruit.OnionFruit.Downloads;

namespace DragonFruit.OnionFruit.Views;

public partial class RayburstMainWindow : Window
{
    private readonly EngineHost _engine = new();
    private readonly DispatcherTimer _refreshTimer = new() { Interval = TimeSpan.FromSeconds(1.5) };
    private bool _refreshInProgress;
    private bool _engineReady;
    public ObservableCollection<DownloadItem> Items { get; } = [];

    public RayburstMainWindow()
    {
        InitializeComponent();
        DataContext = this;
        FolderBox.Text = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Downloads", "Rayburst");
        _refreshTimer.Tick += async (_, _) => await RefreshDownloadsAsync(true);
        Opened += async (_, _) => await StartEngineAsync();
        Closing += (_, _) => { _refreshTimer.Stop(); _engine.Dispose(); };
    }

    private async Task StartEngineAsync()
    {
        try
        {
            Directory.CreateDirectory(FolderBox.Text ?? string.Empty);
            SetStatus("Starting bundled Aria2 Next engine…");
            await _engine.StartAsync(FolderBox.Text ?? string.Empty);
            _engineReady = true;
            EngineBadge.Text = "ENGINE READY";
            EngineBadge.Foreground = Brush.Parse("#48D9D0");
            SetStatus("Engine connected. Add a link to begin.");
            _refreshTimer.Start();
            await RefreshDownloadsAsync(true);
        }
        catch (Exception ex)
        {
            EngineBadge.Text = "ENGINE OFFLINE";
            EngineBadge.Foreground = Brush.Parse("#FF8B8B");
            SetStatus(ex.Message);
        }
    }

    private async void Add_Click(object? sender, RoutedEventArgs e)
    {
        if (!EnsureEngineReady()) return;
        var raw = UrlBox.Text ?? string.Empty;
        var links = raw.Split(['\r', '\n', ';'], StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);
        if (links.Length == 0) { SetStatus("Paste at least one URL or magnet link."); return; }
        var folder = FolderBox.Text?.Trim();
        if (string.IsNullOrWhiteSpace(folder)) { SetStatus("Choose a download folder first."); return; }
        try
        {
            Directory.CreateDirectory(folder);
            var added = 0;
            foreach (var link in links)
            {
                if (!IsSupportedLink(link)) { SetStatus($"Unsupported link format: {link}"); continue; }
                await _engine.Rpc.AddUriAsync(link, Path.GetFullPath(folder));
                added++;
            }
            UrlBox.Text = string.Empty;
            SetStatus($"Added {added} download(s).");
            await RefreshDownloadsAsync(true);
        }
        catch (Exception ex) { SetStatus($"Could not add download: {ex.Message}"); }
    }

    private static bool IsSupportedLink(string value) =>
        value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) ||
        value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
        value.StartsWith("ftp://", StringComparison.OrdinalIgnoreCase) ||
        value.StartsWith("sftp://", StringComparison.OrdinalIgnoreCase) ||
        value.StartsWith("magnet:", StringComparison.OrdinalIgnoreCase) ||
        value.StartsWith("ed2k://", StringComparison.OrdinalIgnoreCase);

    private async void BrowseFolder_Click(object? sender, RoutedEventArgs e)
    {
        try
        {
            var selected = await StorageProvider.OpenFolderPickerAsync(new FolderPickerOpenOptions { Title = "Select download folder", AllowMultiple = false });
            if (selected.Count > 0) { FolderBox.Text = selected[0].Path.LocalPath; SetStatus("Download location updated for new tasks."); }
        }
        catch (Exception ex) { SetStatus($"Could not select folder: {ex.Message}"); }
    }

    private async void Pause_Click(object? sender, RoutedEventArgs e)
    {
        if (!EnsureEngineReady()) return;
        if (DownloadList.SelectedItem is not DownloadItem item) { SetStatus("Select a download first."); return; }
        try { await _engine.Rpc.PauseAsync(item.Gid); await RefreshDownloadsAsync(true); SetStatus("Pause requested."); }
        catch (Exception ex) { SetStatus($"Pause failed: {ex.Message}"); }
    }

    private async void Resume_Click(object? sender, RoutedEventArgs e)
    {
        if (!EnsureEngineReady()) return;
        if (DownloadList.SelectedItem is not DownloadItem item) { SetStatus("Select a download first."); return; }
        try { await _engine.Rpc.ResumeAsync(item.Gid); await RefreshDownloadsAsync(true); SetStatus("Resume requested."); }
        catch (Exception ex) { SetStatus($"Resume failed: {ex.Message}"); }
    }

    private async void Remove_Click(object? sender, RoutedEventArgs e)
    {
        if (!EnsureEngineReady()) return;
        if (DownloadList.SelectedItem is not DownloadItem item) { SetStatus("Select a download first."); return; }
        try
        {
            if (item.Status is "active" or "waiting" or "paused") await _engine.Rpc.RemoveAsync(item.Gid);
            else await _engine.Rpc.RemoveResultAsync(item.Gid);
            await RefreshDownloadsAsync(true);
            SetStatus("Removal requested.");
        }
        catch (Exception ex) { SetStatus($"Remove failed: {ex.Message}"); }
    }

    private async void Refresh_Click(object? sender, RoutedEventArgs e) => await RefreshDownloadsAsync(false);

    private async Task RefreshDownloadsAsync(bool silent)
    {
        if (!_engineReady || _refreshInProgress) return;
        _refreshInProgress = true;
        try
        {
            var snapshots = (await _engine.Rpc.GetDownloadsAsync()).Select(DownloadSnapshot.FromJson).Where(x => !string.IsNullOrWhiteSpace(x.Gid)).ToList();
            var visible = snapshots.Select(x => x.Gid).ToHashSet(StringComparer.Ordinal);
            var current = Items.ToDictionary(x => x.Gid, StringComparer.Ordinal);
            foreach (var snapshot in snapshots)
            {
                if (current.TryGetValue(snapshot.Gid, out var item)) item.Update(snapshot);
                else Items.Add(new DownloadItem(snapshot));
            }
            for (var i = Items.Count - 1; i >= 0; i--) if (!visible.Contains(Items[i].Gid)) Items.RemoveAt(i);
            if (!silent) SetStatus($"Refreshed {Items.Count} tasks.");
        }
        catch (Exception ex) { if (!silent) SetStatus($"Refresh failed: {ex.Message}"); }
        finally { _refreshInProgress = false; }
    }

    private bool EnsureEngineReady()
    {
        if (_engineReady) return true;
        SetStatus("Engine is offline. Ensure this install includes the matching aria2-next.exe binary.");
        return false;
    }

    private void SetStatus(string message) => StatusLabel.Text = message;
}