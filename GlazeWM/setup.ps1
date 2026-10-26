# setup.ps1 - installiert GlazeWM und richtet die Config ein.
# config.yaml muss im selben Ordner liegen wie dieses Skript.
# Aufruf: powershell -ExecutionPolicy Bypass -File .\setup.ps1

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = Join-Path $here 'config.yaml'

if (-not (Test-Path $template)) {
    throw "config.yaml wurde nicht gefunden. Lege sie in denselben Ordner wie setup.ps1."
}

# 1. GlazeWM installieren
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget nicht gefunden. Installiere den 'App-Installer' aus dem Microsoft Store und starte das Skript erneut."
}
Write-Host "Installiere GlazeWM ..."
winget install --id glzr-io.glazewm --exact --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) {
    Write-Warning "winget meldete Code $LASTEXITCODE (bei 'bereits installiert' ist das normal). Mache weiter."
}

# 2. Zen Browser suchen
$candidates = @(
    "$env:LOCALAPPDATA\Zen Browser\zen.exe",
    "$env:ProgramFiles\Zen Browser\zen.exe",
    "${env:ProgramFiles(x86)}\Zen Browser\zen.exe"
)
$zen = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $zen) {
    $cmd = Get-Command zen.exe -ErrorAction SilentlyContinue
    if ($cmd) { $zen = $cmd.Source }
}
if (-not $zen) {
    Write-Warning "Zen Browser wurde nicht gefunden. mod+B wird auf 'zen' gesetzt. Passe den Pfad ggf. in config.yaml an."
    $zen = 'zen'
}
else {
    Write-Host "Zen Browser gefunden: $zen"
}
$zenForConfig = $zen -replace '\\', '/'

# 3. Config schreiben (vorhandene wird gesichert)
$dir = Join-Path $HOME '.glzr\glazewm'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$target = Join-Path $dir 'config.yaml'
if (Test-Path $target) {
    $backup = "$target.bak-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
    Copy-Item $target $backup -Force
    Write-Host "Alte Config gesichert: $backup"
}
$content = [System.IO.File]::ReadAllText($template)
$content = $content.Replace('__ZEN_PATH__', $zenForConfig)
[System.IO.File]::WriteAllText($target, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Config geschrieben: $target"

Write-Host ""
Write-Host "Fertig. Starte jetzt GlazeWM ueber das Startmenue."
Write-Host "Autostart: Rechtsklick auf das GlazeWM-Symbol im Infobereich -> 'Run on system startup'."
