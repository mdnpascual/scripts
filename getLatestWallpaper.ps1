function Get-ImageFormatFromSignature {
    param([Parameter(Mandatory)][string]$Path)

    $buffer = New-Object byte[] 8
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        $stream.Read($buffer, 0, $buffer.Length) | Out-Null
    }
    finally {
        $stream.Dispose()
    }

    $sig = [System.BitConverter]::ToString($buffer)

    switch -regex ($sig) {
        '^FF-D8-FF'            { return 'jpg' }
        '^89-50-4E-47-0D-0A-1A-0A' { return 'png' }
        '^42-4D'               { return 'bmp' }
        '^47-49-46-38'         { return 'gif' }
        default                { return $null }
    }
}

$desktopKey   = 'HKCU:\Control Panel\Desktop'
$ieDesktopKey = 'HKCU:\Software\Microsoft\Internet Explorer\Desktop\General'
$cacheDir     = Join-Path $env:APPDATA 'Microsoft\Windows\Themes\CachedFiles'

$result = [ordered]@{}

try {
    $originalSource = (Get-ItemProperty -Path $ieDesktopKey -Name WallpaperSource -ErrorAction Stop).WallpaperSource
    if ($originalSource -and (Test-Path $originalSource)) {
        $result.OriginalWallpaperSource = (Resolve-Path $originalSource).Path
    }
} catch {}

try {
    $activePath = (Get-ItemProperty -Path $desktopKey -Name WallPaper -ErrorAction Stop).WallPaper
    if ($activePath -and (Test-Path $activePath)) {
        $resolvedActive = (Resolve-Path $activePath).Path
        $format = Get-ImageFormatFromSignature -Path $resolvedActive
        $result.ActiveWallpaperCache = $resolvedActive
        if ($format) {
            $result.ActiveWallpaperFormat = ".$format"
            $tempCopy = Join-Path $env:TEMP ("CurrentWallpaper.$format")
            Copy-Item -Path $resolvedActive -Destination $tempCopy -Force
            $result.TempCopyWithExtension = $tempCopy
        }
    }
} catch {}

if (-not $result.ActiveWallpaperCache -and (Test-Path $cacheDir)) {
    $latestCached = Get-ChildItem -Path $cacheDir -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($latestCached) {
        $result.CachedSlideshowImage = $latestCached.FullName
    }
}

if ($result.Count -eq 0) {
    Write-Warning "Could not determine the current wallpaper."
} else {
    [PSCustomObject]$result
}
