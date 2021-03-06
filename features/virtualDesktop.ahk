﻿DetectHiddenWindows, On
hwnd:=WinExist("ahk_pid " . DllCall("GetCurrentProcessId","Uint"))
hwnd+=0x1000<<32

hVirtualDesktopAccessor := DllCall("LoadLibrary", Str, "VirtualDesktopAccessor.dll", "Ptr") 
GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnCurrentVirtualDesktop", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
RegisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnregisterPostMessageHook", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsPinnedWindow", "Ptr")
PinWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "PinWindow", "Ptr")
UnPinWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnPinWindow", "Ptr")
RestartVirtualDesktopAccessorProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RestartVirtualDesktopAccessor", "Ptr")
GetWindowDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetWindowDesktopNumber", "Ptr")
activeWindowByDesktop := {}

currentDesktop := DllCall(GetCurrentDesktopNumberProc, UInt)

; Restart the virtual desktop accessor when Explorer.exe crashes, or restarts (e.g. when coming from fullscreen game)
explorerRestartMsg := DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated")
OnMessage(explorerRestartMsg, "OnExplorerRestart")
OnExplorerRestart(wParam, lParam, msg, hwnd) {
    global RestartVirtualDesktopAccessorProc
    DllCall(RestartVirtualDesktopAccessorProc, UInt, result)
}

MoveCurrentWindowToDesktop(number) {
	global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc, activeWindowByDesktop
	WinGet, activeHwnd, ID, A
	activeWindowByDesktop[number] := 0 ; Do not activate
	DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, number)
}

isWindowPinned(windowId) {
	global IsPinnedWindowProc
	return DllCall(IsPinnedWindowProc, UInt, windowId, Int)
}

pinWindow(windowId) {
	global PinWindowProc
	DllCall(PinWindowProc, UInt, windowId)
}

unPinWindow(windowId) {
	global UnPinWindowProc
	DllCall(UnPinWindowProc, UInt, windowId)
}

togglePinActiveWindow() {
	global PinWindowProc, UnPinWindowProc
	WinGet, activeHwnd, ID, A
	isPinned := isWindowPinned(activeHwnd)
	if (isPinned) {
		unPinWindow(activeHwnd)
		showOsd("Window un-pinned")
	} else {
		pinWindow(activeHwnd)
		showOsd("Window pinned")
	}
}

GoToPrevDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, UInt)
	if (current = 0) {
		GoToDesktopNumber(9)
	} else {
		GoToDesktopNumber(current - 1)      
	}
	return
}

GoToNextDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, UInt)

	if (current = 9) {
		GoToDesktopNumber(0)
	} else {
		GoToDesktopNumber(current + 1)    
	}
	return
}

GoToDesktopNumber(num) {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc, IsPinnedWindowProc, activeWindowByDesktop, currentDesktop

	; Store the active window of old desktop, if it is not pinned
	WinGet, activeHwnd, ID, A
	current := DllCall(GetCurrentDesktopNumberProc, UInt)
	currentDesktop := current
	isPinned := DllCall(IsPinnedWindowProc, UInt, activeHwnd)
	if (isPinned == 0) {
		activeWindowByDesktop[current] := activeHwnd
	}

	; Try to avoid flashing task bar buttons, deactivate the current window if it is not pinned
	if (isPinned != 1) {
		WinActivate, ahk_class Shell_TrayWnd
	}

	; Change desktop
	DllCall(GoToDesktopNumberProc, Int, num)
	
	WinGet, active_id, ID, A
	WinActivate, ahk_id %active_id%
	return
}

; Windows 10 desktop changes listener
DllCall(RegisterPostMessageHookProc, Int, hwnd, Int, 0x1400 + 30)
OnMessage(0x1400 + 30, "VWMess")
VWMess(wParam, lParam, msg, hwnd) {
	global IsWindowOnCurrentVirtualDesktopProc, IsPinnedWindowProc, activeWindowByDesktop

	desktopNumber := lParam + 1
	
	; Try to restore active window from memory (if it's still on the desktop and is not pinned)
	WinGet, activeHwnd, ID, A 
	isPinned := DllCall(IsPinnedWindowProc, UInt, activeHwnd)
	oldHwnd := activeWindowByDesktop[lParam]
	isOnDesktop := DllCall(IsWindowOnCurrentVirtualDesktopProc, UInt, oldHwnd, Int)
	if (isOnDesktop == 1 && isPinned != 1) {
		WinActivate, ahk_id %oldHwnd%
	}

	; Menu, Tray, Icon, Icons/icon%desktopNumber%.ico
	
	; When switching to desktop 1, set background pluto.jpg
	; if (lParam == 0) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\saturn.jpg", UInt, 1)
	; When switching to desktop 2, set background DeskGmail.png
	; } else if (lParam == 1) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskGmail.png", UInt, 1)
	; When switching to desktop 7 or 8, set background DeskMisc.png
	; } else if (lParam == 2 || lParam == 3) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskMisc.png", UInt, 1)
	; Other desktops, set background to DeskWork.png
	; } else {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskWork.png", UInt, 1)
	; }
}

ChangeDesktop(num) {
	If GetKeyState("Shift", "P")
		MoveCurrentWindowToDesktop(num)
	Else
		GoToDesktopNumber(num)
	
	ToolTipText(num + 1)
}

ToolTipText(num)
{
	showOsd("Desktop: " . num)
}

getCurrDesktopNum(){
  global GetCurrentDesktopNumberProc
; RegRead, cur, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops, CurrentVirtualDesktop
; RegRead, all, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
; ix := floor(InStr(all,cur) / strlen(cur))
; return ix

 return DllCall(GetCurrentDesktopNumberProc, UInt)
}

; dateString should be in format dd/mm/yyyy
getDayOfWeek(dateString) {
;datestring = 1/1/2010 
SetFormat, float, 02.0
StringSplit, d, datestring, / 
FormatTime, day_of_Week, % d3 . d1+0. . d2+0., dddd 
return day_of_Week	
}
showInfo() {
	currDeskNum := getCurrDesktopNum()
	FormatTime, dateString, , 'dd/MMM/yyyy
	dayOfWeek := getDayOfWeek(dateString)
	FormatTime, currDateTimeStr,, hh:mm:ss' `n %dayOfWeek%, 'dd MMM yyyy
	text := "Desktop:" . (currDeskNum + 1) . "`n" . currDateTimeStr
	text := text . "`n" . ResourceMonitor_getText()
	showOsd(text)
}


showOsd(textToShow) {
	Gui, osdvd: Destroy
    CustomColor = 000000  ; Can be any RGB color (it will be made transparent below). 
	Gui, osdvd: +AlwaysOnTop +LastFound +Owner -Caption
	Gui, osdvd: Color, %CustomColor% 
	Gui, osdvd: Font, cFFFFFF S48, Verdana

    Gui, osdvd: add, Text, center center x2 y2 c000000 BackgroundTrans, %textToShow%
    Gui, osdvd: add, Text, center center x0 y0 cLime BackgroundTrans, %textToShow%

	WinSet, TransColor, %CustomColor%  250
	WinSet, ExStyle, +0x20, Output
	Gui, osdvd: Show, center center NoActivate , Output
 
	SetTimer, RemoveToolTip, 3000

	Return


RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	Gui, osdvd: Destroy
	return
	
}

