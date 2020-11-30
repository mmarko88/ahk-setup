#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Google lookup
CapsLock & /::
OldClipboard:= Clipboard
Clipboard:= ""
Send, ^c ;copies selected text
ClipWait
Run http://www.google.com/search?q=%Clipboard%
Sleep 200
Clipboard:= OldClipboard
Return