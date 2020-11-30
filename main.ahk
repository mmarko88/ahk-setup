#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include features/virtualDesktop.ahk
#Include features/favorites.ahk
#Include features/util.ahk
#Include features/stayAwake.ahk
;#Include features/iswitchw.ahk

;TODOS:
; 1. Add run evaluated application (at least win explorer or free commander)



LWin & 1::ChangeDesktop(0)
LWin & 2::ChangeDesktop(1)
LWin & 3::ChangeDesktop(2)
LWin & 4::ChangeDesktop(3)
LWin & 5::ChangeDesktop(4)
LWin & 6::ChangeDesktop(5)
LWin & 7::ChangeDesktop(6)
LWin & 8::ChangeDesktop(7)
LWin & 9::ChangeDesktop(8)
LWin & 0::ChangeDesktop(9)
LWin & ,::GoToPrevDesktop()
LWin & .::GoToNextDesktop()
LWin & x::CloseActiveWindow()
; add shortcut to start task manager or bring it to front

#L::lockWorkStationAndTurnOffScreen()  ;; Turn off monitor after locking system
#Space::ToggleTaskBarAndStart()
#WheelUp:: changeOpasity(10)
#WheelDown:: changeOpasity(-10)
;#;::showISwitchW() reserved in iswitchw.ahk

CapsLock & Left::MouseMove, -1, 0, 0, R
CapsLock & Right::MouseMove, 1, 0, 0, R
CapsLock & Up::MouseMove, 0, -1, 0, R
CapsLock & Down::MouseMove, 0, 1, 0, R

CapsLock & t::TransparentWindow()
CapsLock & w::stayAwake()
CapsLock & x::CloseActiveWindow()
CapsLock & a::AlwaysOnTop()
CapsLock & i::showInfo()
CapsLock & b::removeTitleBar()
CapsLock & Esc::Suspend ; Suspend AutoHotKey


; Ctrl+Windows+Space - not working for some reason
; ^#Space::
; 	WinGet, ExStyle, ExStyle, A  ; "A" means the active window
; 	If  !(ExStyle & 0x00000080)  ; visible on all desktops.
; 		WinSet, ExStyle, 0x00000080, A
; 	else
; 		WinSet, ExStyle, -0x00000080, A 

; Always on Top
;^SPACE:: Winset, Alwaysontop, , A ; ctrl + space
;Return

; Press ~ to move up a folder in Explorer
#IfWinActive, ahk_class CabinetWClass

backspaceToUp() {
	Send !{Up}
}

openCmdInExplorer() {
	ClipSaved := ClipboardAll
	Send !d
	Sleep 10
	Send ^c
	Run, cmd /K "cd `"%clipboard%`""
	Clipboard := ClipSaved
	ClipSaved =
}

showHideExtensionInExplorer() {
	RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
	If HiddenFiles_Status = 1
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
	Else
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
	WinGetClass, eh_Class,A
	send, {F5}
}

BackSpace::backspaceToUp() 
^b::openCmdInExplorer()
^y::showHideExtensionInExplorer()

#IfWinActive


; F7 to launch or switch to Firefox
; #F7::
; IfWinExist Mozilla Firefox
; {
; WinActivateBottom, Mozilla Firefox
; }
; Else
; {
; Run “C:\Users\Public\Desktop\Mozilla Firefox.lnk”
; }
; Return



changeOpasity(value) {
	MouseGetPos,,, hwndUnderCursor
	WinGet, currOpacity, Transparent, ahk_id %hwndUnderCursor%
	If !(curropacity)
		currOpacity := 255
	currOpacity := currOpacity + value
	currOpacity := (currOpacity < 25) ? 25 : (currOpacity >= 255) ? 255 : currOpacity
	WinSet, Transparent, %currOpacity%, ahk_id %hwndUnderCursor%
}


removeTitleBar() {
	WinGet, actWinId, ID, A
	WinGet, Title, Style, ahk_id %actWinId%
	If (Title & 0xC00000)
		WinSet, Style, -0xC00000, ahk_id  %actWinId%
	Else
		WinSet, Style, +0xC00000, ahk_id  %actWinId%
	; Redraw the window
	WinGetPos,,,, Height, ahk_id  %actWinId%
	WinMove, ahk_id  %actWinId%,,,,, % Height - 1
	WinMove, ahk_id  %actWinId%,,,,, % Height
}


ToggleTaskBarAndStart()
{
   static action := True

   static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
   VarSetCapacity(APPBARDATA, size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
   NumPut(size, APPBARDATA) 
   NumPut(WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
   NumPut(action ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)


   DllCall("Shell32\SHAppBarMessage", UInt, ABM_SETSTATE, Ptr, &APPBARDATA)

   ;WinActivate, ahk_id %ActiveId%
   action := not action

}


lockWorkStationAndTurnOffScreen() {
 Sleep, 200
 DllCall("LockWorkStation")
 Sleep, 200
 SendMessage,0x112,0xF170,2,,Program Manager
}
