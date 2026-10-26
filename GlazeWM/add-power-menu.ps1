# add-power-menu.ps1
# - kopiert powermenu.ps1 in den GlazeWM-Ordner
# - ergaenzt in deiner bestehenden config.yaml:
#     mod + X            -> Power-Menue
#     Power-Menue-Fenster -> immer floating
#     Zen Browser         -> oeffnet auf Workspace 2 (und wechselt dorthin)
# Deine anderen Einstellungen bleiben erhalten, die alte Config wird gesichert.
# Aufruf: powershell -ExecutionPolicy Bypass -File .\add-power-menu.ps1

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $here 'powermenu.ps1'
$dir = Join-Path $HOME '.glzr\glazewm'
$cfgPath = Join-Path $dir 'config.yaml'

if (-not (Test-Path $src)) { throw "powermenu.ps1 muss im selben Ordner wie dieses Skript liegen." }
if (-not (Test-Path $cfgPath)) { throw "Keine Config gefunden: $cfgPath. Fuehre zuerst setup.ps1 aus." }

# 1. Menue-Skript kopieren
$menuTarget = Join-Path $dir 'powermenu.ps1'
Copy-Item $src $menuTarget -Force
$menuPath = $menuTarget -replace '\\', '/'

# 2. Config sichern
$backup = "$cfgPath.bak-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
Copy-Item $cfgPath $backup -Force
Write-Host "Config gesichert: $backup"

$cfg = [System.IO.File]::ReadAllText($cfgPath)
$changed = $false

# 3. Keybinding mod + X
if ($cfg -notmatch 'lwin\+x') {
    $entry = "  - commands: ['shell-exec powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $menuPath']`n    bindings: ['lwin+x']`n"
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $m.Value + $entry }
    $cfg = [regex]::Replace($cfg, '(?m)^keybindings:[ \t]*\r?\n', $evaluator, 1)
    $changed = $true
    Write-Host "Keybinding mod + X ergaenzt."
}
else { Write-Host "mod + X ist schon in der Config - uebersprungen." }

# 4. Window-Regeln
$newRules = ''
if ($cfg -notmatch "equals: 'Power Menu'") {
    $newRules += "  - commands: ['set-floating']`n    match:`n      - window_title: { equals: 'Power Menu' }`n"
}
if ($cfg -notmatch "equals: 'zen'") {
    $newRules += "  - commands: ['move --workspace 2', 'focus --workspace 2']`n    match:`n      - window_process: { equals: 'zen' }`n"
}
if ($newRules -ne '') {
    $evaluator2 = [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $m.Value + $newRules }
    $cfg = [regex]::Replace($cfg, '(?m)^window_rules:[ \t]*\r?\n', $evaluator2, 1)
    $changed = $true
    Write-Host "Window-Regeln ergaenzt."
}
else { Write-Host "Window-Regeln sind schon vorhanden - uebersprungen." }

if ($changed) {
    [System.IO.File]::WriteAllText($cfgPath, $cfg, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ""
Write-Host "Fertig. Druecke jetzt Win + Shift + R, um die Config neu zu laden."
