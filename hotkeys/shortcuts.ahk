#Requires AutoHotkey v2.0
#SingleInstance Force

; ---------------------------------------------------------------
; mod = Windows-Taste
;   mod + Enter          Terminal (Windows Terminal)
;   mod + B              Zen Browser
;   mod + 1..5           zu Desktop 1..5 wechseln
;   mod + Shift + 1..5   fokussiertes Fenster auf Desktop 1..5 schieben
;
; Benoetigt VirtualDesktopAccessor.dll im selben Ordner wie dieses Skript.
; ---------------------------------------------------------------

; --- VirtualDesktopAccessor laden -------------------------------
dllPath := A_ScriptDir "\VirtualDesktopAccessor.dll"
hVDA := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
if !hVDA {
    MsgBox "VirtualDesktopAccessor.dll wurde nicht gefunden in:`n" A_ScriptDir "`n`nDesktop-Shortcuts sind deaktiviert."
}

procGoTo  := hVDA ? DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GoToDesktopNumber", "Ptr") : 0
procMove  := hVDA ? DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "MoveWindowToDesktopNumber", "Ptr") : 0
procCount := hVDA ? DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GetDesktopCount", "Ptr") : 0

; Stellt sicher, dass mindestens n Desktops existieren
EnsureDesktops(n) {
    global procCount
    tries := 0
    while DllCall(procCount, "Int") < n && tries < 10 {
        Send "^#d"          ; neuen Desktop anlegen
        Sleep 300
        tries++
    }
}

GoToDesktop(n, *) {
    global procGoTo
    if !procGoTo
        return
    EnsureDesktops(n)
    DllCall(procGoTo, "Int", n - 1, "Int")
}

MoveWindowToDesktop(n, *) {
    global procMove
    if !procMove
        return
    hwnd := WinExist("A")
    if !hwnd
        return
    EnsureDesktops(n)
    DllCall(procMove, "Ptr", hwnd, "Int", n - 1, "Int")
}

; Fenster verschieben und mitgehen (Fokus folgt dem Fenster)
MoveWindowAndFollow(n, *) {
    global procMove
    if !procMove
        return
    hwnd := WinExist("A")
    if !hwnd
        return
    EnsureDesktops(n)
    DllCall(procMove, "Ptr", hwnd, "Int", n - 1, "Int")
    GoToDesktop(n)
    Sleep 100
    try WinActivate hwnd
}

; --- Hotkeys fuer Desktops 1-5 ----------------------------------
;   Win + N          Desktop wechseln
;   Win + Shift + N  Fenster verschieben und mitgehen
;   Win + Alt + N    Fenster verschieben, aber auf dem aktuellen Desktop bleiben
for i in [1, 2, 3, 4, 5] {
    Hotkey "#" i, GoToDesktop.Bind(i)
    Hotkey "#+" i, MoveWindowAndFollow.Bind(i)
    Hotkey "#!" i, MoveWindowToDesktop.Bind(i)
}

; --- Programme starten ------------------------------------------
#Enter:: Run "wt.exe"

; --- Fenster maximieren / zurueck (Vollbild-Toggle) -------------
#f:: {
    hwnd := WinExist("A")
    if !hwnd || (WinGetClass(hwnd) ~= "^(Progman|WorkerW|Shell_TrayWnd)$")
        return
    if WinGetMinMax(hwnd) = 1
        WinRestore hwnd
    else
        WinMaximize hwnd
}

; --- Fenster schliessen -----------------------------------------
#q:: {
    hwnd := WinExist("A")
    ; Desktop und Taskleiste nicht schliessen
    if hwnd && !(WinGetClass(hwnd) ~= "^(Progman|WorkerW|Shell_TrayWnd)$")
        WinClose hwnd
}

#b:: {
    local appData := EnvGet("LOCALAPPDATA")
    for path in [appData "\Zen Browser\zen.exe", A_ProgramFiles "\Zen Browser\zen.exe"] {
        if FileExist(path) {
            Run path
            return
        }
    }
    try Run "zen.exe"
    catch
        MsgBox "Zen Browser wurde nicht gefunden. Passe den Pfad in shortcuts.ahk an."
}
