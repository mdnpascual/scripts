param([string]$Root, [string]$Mode)

$IsDebug = $Mode -like 'debug*'
$CopyInDebug = $Mode -eq 'debug-copy'
$action = if ($IsDebug) { 'Created' } else { 'Renamed' }

function Sanitize([string]$name) {
  if ([string]::IsNullOrWhiteSpace($name)) { return '' }
  $s = ($name -replace '[\x00-\x1F]', '') -replace '[/:*?""<>|]', ' '
  $invalid = [IO.Path]::GetInvalidFileNameChars()
  foreach ($c in $invalid) { $s = $s.Replace($c, ' ') }
  ($s.Trim() -replace '\s+', ' ')
}

function GetExtProp($item, [string]$prop) {
  try { $item.ExtendedProperty($prop) } catch { $null }
}

$Shell = New-Object -ComObject Shell.Application
$files = Get-ChildItem -LiteralPath $Root -Recurse -File 2>$null | Where-Object { $_.Extension -match '^\.(mp3|flac)$' }

$count = 0; $renamed = 0; $skipped = 0; $errors = 0

foreach ($f in $files) {
  $count++

  $folder = $Shell.Namespace($f.Directory.FullName)
  if (-not $folder) { $skipped++; continue }
  $item = $folder.ParseName($f.Name)
  if (-not $item) { $skipped++; continue }

  # Read tags
  $title = GetExtProp $item 'System.Title'
  if (-not $title) { $title = [IO.Path]::GetFileNameWithoutExtension($f.Name) }

  $artists = GetExtProp $item 'System.Music.Artist'
  if ($artists -is [array]) { $artist = ($artists -join ', ') } else { $artist = [string]$artists }
  if (-not $artist) {
    $albumArtist = GetExtProp $item 'System.Music.AlbumArtist'
    if ($albumArtist -is [array]) { $artist = ($albumArtist -join ', ') } else { $artist = [string]$albumArtist }
  }
  if (-not $artist) { $artist = 'Unknown Artist' }

  $track = GetExtProp $item 'System.Music.TrackNumber'
  $trackStr = '00'
  if ($track) {
    $t = [string]$track
    if ($t -match '^\s*(\d{1,3})') {
      $n = [int]$matches[1]
      if ($n -ge 0) { $trackStr = ('{0:D2}' -f $n) }
    }
  }

  # Sanitize for filesystem
  $safeArtist = Sanitize $artist
  $safeTitle  = Sanitize $title
  if (-not $safeArtist) { $safeArtist = 'Unknown Artist' }
  if (-not $safeTitle)  { $safeTitle  = 'Unknown Title' }

  $newBase = '{0}. {1} - {2}' -f $trackStr, $safeArtist, $safeTitle
  $newName = $newBase + $f.Extension

  if ($newName -eq $f.Name) { $skipped++; continue }

  # Avoid collisions
  $targetPath = Join-Path $f.Directory.FullName $newName
  $i = 1
  while (Test-Path -LiteralPath $targetPath) {
    $newName = '{0} ({1}){2}' -f $newBase, $i, $f.Extension
    $targetPath = Join-Path $f.Directory.FullName $newName
    $i++
    if ($i -gt 99) { break }
  }

  # {{ changed: debug behavior }}
  if ($IsDebug) {
    try {
      if ($CopyInDebug) {
        Copy-Item -LiteralPath $f.FullName -Destination $targetPath -ErrorAction Stop
        Write-Host "DEBUG:`t COPY  $($f.Name) -> $newName"
      } else {
        New-Item -ItemType File -Path $targetPath -ErrorAction Stop | Out-Null
        Write-Host "DEBUG:`t TOUCH $newName"
      }
      $renamed++
    } catch {
      $errors++
      Write-Warning ("FAILED (debug): {0} -> {1} : {2}" -f $f.FullName, $newName, $_.Exception.Message)
    }
    continue
  }

  try {
    Rename-Item -LiteralPath $f.FullName -NewName $newName -ErrorAction Stop
    $renamed++
    Write-Host "RENAMED:`t $($f.Name) -> $newName"
  } catch {
    $errors++
    Write-Warning ("FAILED: {0} -> {1} : {2}" -f $f.FullName, $newName, $_.Exception.Message)
  }
}

Write-Host ""
Write-Host ("Processed: {0}, {1}: {2}, Skipped: {3}, Errors: {4}" -f $count, $action, $renamed, $skipped, $errors)

if ($IsDebug) {
  Write-Host "Note: Debug mode keeps originals. Remove placeholders/copies before final run if desired."
}
