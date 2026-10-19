# fetch-lyrics installer for Windows (user scope, no admin needed).
# Downloads the latest release into %LOCALAPPDATA%\Programs\fetch-lyrics
# and adds that folder to your user PATH.
$ErrorActionPreference = 'Stop'

$repo = 'NMyxth/fetch-lyrics'
$dir  = Join-Path $env:LOCALAPPDATA 'Programs\fetch-lyrics'
$base = "https://github.com/$repo/releases/latest/download"

New-Item -ItemType Directory -Force -Path $dir | Out-Null

Write-Host "Downloading to $dir ..."
Invoke-WebRequest -UseBasicParsing "$base/fetch-lyrics.py"  -OutFile (Join-Path $dir 'fetch-lyrics.py')
Invoke-WebRequest -UseBasicParsing "$base/fetch-lyrics.cmd" -OutFile (Join-Path $dir 'fetch-lyrics.cmd')

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
Write-Host '    fetch-lyrics "$env:USERPROFILE\Music"'
Write-Host ""
Write-Host "Optional: for embedded lyrics tags, run:  py -m pip install mutagen"
