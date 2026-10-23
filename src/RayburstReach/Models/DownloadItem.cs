using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace RayburstReach.Models;

public sealed class DownloadItem : INotifyPropertyChanged
{
    private string _status = "waiting";
    private string _fileName = string.Empty;
    private string _filePath = string.Empty;
    private long _totalLength;
    private long _completedLength;
    private long _downloadSpeed;
    private long _uploadSpeed;
    private string _errorMessage = string.Empty;

    public string Gid { get; }
    public event PropertyChangedEventHandler? PropertyChanged;

    public string Status { get => _status; private set => SetField(ref _status, value); }
    public string FileName { get => _fileName; private set => SetField(ref _fileName, value); }
    public string FilePath { get => _filePath; private set => SetField(ref _filePath, value); }
    public long TotalLength { get => _totalLength; private set => SetField(ref _totalLength, value); }
    public long CompletedLength { get => _completedLength; private set => SetField(ref _completedLength, value); }
    public long DownloadSpeed { get => _downloadSpeed; private set { if (SetField(ref _downloadSpeed, value)) OnPropertyChanged(nameof(TransferRate)); } }
    public long UploadSpeed { get => _uploadSpeed; private set => SetField(ref _uploadSpeed, value); }
    public string ErrorMessage { get => _errorMessage; private set => SetField(ref _errorMessage, value); }

    public double ProgressPercent => TotalLength <= 0 ? 0 : Math.Clamp((double)CompletedLength * 100.0 / TotalLength, 0, 100);
    public string ProgressLabel => TotalLength > 0 ? $"{ProgressPercent:0.0}% · {FormatBytes(CompletedLength)} / {FormatBytes(TotalLength)}" : FormatBytes(CompletedLength);
    public string TransferRate => DownloadSpeed > 0 ? $"↓ {FormatBytes(DownloadSpeed)}/s" : Status == "complete" ? "Completed" : Status;

    public DownloadItem(DownloadSnapshot snapshot)
    {
        Gid = snapshot.Gid;
        Update(snapshot);
    }

    public void Update(DownloadSnapshot snapshot)
    {
        Status = snapshot.Status;
        FileName = snapshot.FileName;
        FilePath = snapshot.FilePath;
        TotalLength = snapshot.TotalLength;
        CompletedLength = snapshot.CompletedLength;
        DownloadSpeed = snapshot.DownloadSpeed;
        UploadSpeed = snapshot.UploadSpeed;
        ErrorMessage = snapshot.ErrorMessage;
        OnPropertyChanged(nameof(ProgressPercent));
        OnPropertyChanged(nameof(ProgressLabel));
        OnPropertyChanged(nameof(TransferRate));
    }

    private static string FormatBytes(long value)
    {
        if (value < 1024) return $"{value} B";
        string[] units = ["KB", "MB", "GB", "TB"];
        double size = value;
        var unit = -1;
        do { size /= 1024; unit++; } while (size >= 1024 && unit < units.Length - 1);
        return $"{size:0.##} {units[unit]}";
    }

    private bool SetField<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value)) return false;
        field = value;
        OnPropertyChanged(propertyName);
        return true;
    }

    private void OnPropertyChanged([CallerMemberName] string? propertyName = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
}
