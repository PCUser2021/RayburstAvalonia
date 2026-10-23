using System.Text.Json;

namespace RayburstReach.Models;

public sealed record DownloadSnapshot(
    string Gid,
    string Status,
    string FileName,
    string FilePath,
    long TotalLength,
    long CompletedLength,
    long DownloadSpeed,
    long UploadSpeed,
    string ErrorMessage)
{
    public static DownloadSnapshot FromJson(JsonElement item)
    {
        var gid = ReadString(item, "gid");
        var status = ReadString(item, "status");
        var total = ReadLong(item, "totalLength");
        var completed = ReadLong(item, "completedLength");
        var downloadSpeed = ReadLong(item, "downloadSpeed");
        var uploadSpeed = ReadLong(item, "uploadSpeed");
        var error = ReadString(item, "errorMessage");
        var path = string.Empty;

        if (item.TryGetProperty("files", out var files) && files.ValueKind == JsonValueKind.Array && files.GetArrayLength() > 0)
        {
            var file = files[0];
            if (file.TryGetProperty("path", out var pathElement) && pathElement.ValueKind == JsonValueKind.String)
                path = pathElement.GetString() ?? string.Empty;
        }

        var name = string.IsNullOrWhiteSpace(path) ? $"Task {gid}" : Path.GetFileName(path);
        if (string.IsNullOrWhiteSpace(name)) name = $"Task {gid}";
        return new DownloadSnapshot(gid, status, name, path, total, completed, downloadSpeed, uploadSpeed, error);
    }

    private static string ReadString(JsonElement item, string name)
    {
        if (!item.TryGetProperty(name, out var value) || value.ValueKind == JsonValueKind.Null) return string.Empty;
        return value.ValueKind == JsonValueKind.String ? value.GetString() ?? string.Empty : value.ToString();
    }

    private static long ReadLong(JsonElement item, string name)
    {
        if (!item.TryGetProperty(name, out var value)) return 0;
        if (value.ValueKind == JsonValueKind.Number && value.TryGetInt64(out var number)) return number;
        return long.TryParse(value.ToString(), out var parsed) ? parsed : 0;
    }
}
