# winRice

Meine Windows-Konfiguration (Tiling-WM, Hotkeys), um einen neuen Rechner schnell identisch einzurichten.

## Inhalt

- `GlazeWM/` – Config und Setup-Skripte für [GlazeWM](https://github.com/glzr-io/glazewm)
  - `setup.ps1` – installiert GlazeWM per winget und schreibt `config.yaml` nach `~/.glzr/glazewm/`
  - `config.yaml` – GlazeWM-Config (`__ZEN_PATH__` wird vom Setup durch den Zen-Browser-Pfad ersetzt)
  - `powermenu.ps1`, `add-power-menu.ps1` – Power-Menü
- `hotkeys/` – AutoHotkey-Shortcuts (`shortcuts.ahk`) und `VirtualDesktopAccessor.dll`

## Neuer Rechner

```powershell
git clone https://github.com/LennoWeber/winRice.git
cd winRice\GlazeWM
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Danach `hotkeys\shortcuts.ahk` mit AutoHotkey v2 starten (ggf. in den Autostart legen).
