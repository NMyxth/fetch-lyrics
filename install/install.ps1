# fetch-lyrics installer for Windows (user scope, no admin needed).
# Downloads the latest release into %LOCALAPPDATA%\Programs\fetch-lyrics,
# adds that folder to your user PATH, and if Python 3.10+ is missing it
# unpacks a private copy so nothing else has to be installed.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo  = 'NMyxth/fetch-lyrics'
$dir   = Join-Path $env:LOCALAPPDATA 'Programs\fetch-lyrics'
$base  = "https://github.com/$repo/releases/latest/download"
$pyVer = '3.12.10'

New-Item -ItemType Directory -Force -Path $dir | Out-Null

Write-Host "Downloading fetch-lyrics to $dir ..."
Invoke-WebRequest -UseBasicParsing "$base/fetch-lyrics.py"  -OutFile (Join-Path $dir 'fetch-lyrics.py')
Invoke-WebRequest -UseBasicParsing "$base/fetch-lyrics.cmd" -OutFile (Join-Path $dir 'fetch-lyrics.cmd')

# --- Python 3.10+ -----------------------------------------------------------
$pyDir  = Join-Path $dir 'python'
$havePy = $false

foreach ($cand in @('py', 'python')) {
    if (Get-Command $cand -ErrorAction SilentlyContinue) {
        try {
            $v = & $cand -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
            if ($v -and [version]($v.Trim()) -ge [version]'3.10') { $havePy = $true; break }
        } catch { }
    }
}

if (-not $havePy) {
    if (Test-Path (Join-Path $pyDir 'python.exe')) {
        Write-Host "Using the Python already bundled in $pyDir"
    } else {
        Write-Host "Python 3.10+ not found. Downloading a private copy (no admin needed) ..."
        $zip = Join-Path $env:TEMP 'fetch-lyrics-python.zip'
        Invoke-WebRequest -UseBasicParsing "https://www.python.org/ftp/python/$pyVer/python-$pyVer-embed-amd64.zip" -OutFile $zip
        New-Item -ItemType Directory -Force -Path $pyDir | Out-Null
        Expand-Archive -Path $zip -DestinationPath $pyDir -Force
        Remove-Item $zip -Force
        Write-Host "Bundled Python $pyVer in $pyDir"
    }
}

# Add the folder to the *user* PATH if it is not already there.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($null -eq $userPath) { $userPath = '' }
$parts = @($userPath -split ';' | Where-Object { $_ -ne '' })
if ($parts -notcontains $dir) {
    $newPath = (@($parts) + $dir) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added $dir to your user PATH."
} else {
    Write-Host "$dir is already on your user PATH."
}

Write-Host ""
Write-Host "Done. Open a NEW terminal, then run:"
Write-Host "    fetch-lyrics"
Write-Host ""
Write-Host "Optional: for embedded lyrics tags you need the full Python + mutagen."
