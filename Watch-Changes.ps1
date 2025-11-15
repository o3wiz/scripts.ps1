param(
    [Parameter()]
    [System.IO.DirectoryInfo]
    [string]$Path,

    [string]$Filter = "*",

    [Parameter(Mandatory=$true)]
    [ScriptBlock]$Action
)

# Validate that Path exists and is a directory
if (-not $Path.Exists) {
    throw "Path '$($Path.FullName)' does not exist."
}
if (-not ($Path.Attributes -band [IO.FileAttributes]::Directory)) {
    throw "Path '$($Path.FullName)' is not a directory."
}

Write-Host "🔍 Watching '$Path' for changes in '$Filter'..."
$watcher = New-Object System.IO.FileSystemWatcher $Path, $Filter
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher Changed -Action {
    $time = (Get-Date).ToString("HH:mm:ss")
    Write-Host "`n[$time] Detected change at $($Event.SourceEventArgs.FullPath)"
    & $Action
} | Out-Null
