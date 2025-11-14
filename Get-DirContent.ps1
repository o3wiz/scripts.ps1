param(
    [string] $Path = $PWD.Path,
    [string[]] $ExcludeDirs = @(),
    [string[]] $IncludeDirs = @(),
    [string[]] $ExcludeFileExtensions = @(),
    [string[]] $IncludeFileExtensions = @()
)

# ----------------------------
#      PARAMETER VALIDATION
# ----------------------------

# Validate mutually exclusive directory filters
if ($ExcludeDirs.Count -gt 0 -and $IncludeDirs.Count -gt 0) {
    throw "Invalid parameters: You cannot use both -ExcludeDirs and -IncludeDirs together."
}

# Validate mutually exclusive file extension filters
if ($ExcludeFileExtensions.Count -gt 0 -and $IncludeFileExtensions.Count -gt 0) {
    throw "Invalid parameters: You cannot use both -ExcludeFileExtensions and -IncludeFileExtensions together."
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

# ----------------------------
#       HELPER FUNCTIONS
# ----------------------------

function Process-Directory([string] $PPath) {
    $FullPath = (Resolve-Path $PPath).Path
    $DirName = Split-Path $FullPath -Leaf

    # Directory filtering
    if ($ExcludeDirs -contains $DirName) {
        return
    }
    if ($IncludeDirs.Count -gt 0 -and $IncludeDirs -notcontains $DirName) {
        return
    }

    $Items = Get-ChildItem -LiteralPath $FullPath -Force

    foreach ($item in $Items) {
        if ($item.PSIsContainer) {
            Process-Directory $item.FullName
        }
        else {
            $ext = $item.Extension.ToLower()

            # File extension filtering
            if ($ExcludeFileExtensions -contains $ext) { continue }
            if ($IncludeFileExtensions.Count -gt 0 -and $IncludeFileExtensions -notcontains $ext) { continue }

            Write-Output "FILE: $($item.FullName)"
            Write-Output (Get-Content -LiteralPath $item.FullName -Raw)
        }
    }
}

# ----------------------------
#         EXECUTION
# ----------------------------
Process-Directory $Path
