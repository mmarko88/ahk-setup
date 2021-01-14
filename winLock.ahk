#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

fileName := "disableWinLock.reg"
Run, regedit.exe /s %fileName%

;    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 0
    Msgbox Writing to registry now %fileName%

; RunAsAdmin2:
; full_command_line := DllCall("GetCommandLine", "str")
; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
; {
;   try
;   {
;   if A_IsCompiled
;     Run *RunAs "%A_ScriptFullPath%" /restart
;       else
;     Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
;   }
; ExitApp
; }
; return