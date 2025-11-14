param(
    [string] $Path = $PWD.Path,
    [string[]] $ExcludeDirs = @(),
    [string[]] $ExcludeFileExtensions = @(),
    [string[]] $IncludeFileExtensions = @()
)

# Input validation
if (!(Test-Path -Path $Path -PathType Container)) {
    throw "Path must be a directory"
}
if (($IncludeFileExtensions.Count -gt 0) -and ($ExcludeFileExtensions.Count -gt 0)) {
    throw "Cannot specify both IncludeFileExtensions and ExcludeFileExtensions."
}

# Normalize extensions (convert to lower-case and enforce dot prefix)
function Normalize-Extensions([string[]] $exts) {
    return $exts | ForEach-Object {
        $_ = $_.ToLower()
        if (-not $_.StartsWith(".")) { ".$_" } else { $_ }
    }
}
$ExcludeFileExtensions = Normalize-Extensions $ExcludeFileExtensions
$IncludeFileExtensions = Normalize-Extensions $IncludeFileExtensions

function Process-Directory([string] $PPath) {
    $FullPath = (Resolve-Path $PPath).Path
    $DirName = Split-Path $FullPath -Leaf

    # Directory filtering
    if ($ExcludeDirs -contains $DirName) {
        return
    }

    $folderItems = Get-ChildItem -LiteralPath $FullPath -Force

    foreach ($item in $folderItems) {
        if (Test-Path -Path $item -PathType Container) {
            Process-Directory $item.FullName
        }
        else {
            $fileExt = $item.Extension.ToLower()

            # File extension filtering
            if ($ExcludeFileExtensions -contains $fileExt) {
                continue
            }
            if ($IncludeFileExtensions.Count -gt 0 -and $IncludeFileExtensions -notcontains $fileExt) {
                continue
            }

            Write-Output "FILE: $($item.FullName)"
            Write-Output (Get-Content -LiteralPath $item.FullName -Raw)
        }
    }
}

Process-Directory $Path
