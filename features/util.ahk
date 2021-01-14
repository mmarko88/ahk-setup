CCase() 
{
    If (A_ThisMenuItemPos = 1)
       StringUpper, TempText, TempText
    Else If (A_ThisMenuItemPos = 2)
       StringLower, TempText, TempText
    Else If (A_ThisMenuItemPos = 3)
       StringLower, TempText, TempText, T
    Else If (A_ThisMenuItemPos = 4)
    {
       StringLower, TempText, TempText
       TempText := RegExReplace(TempText, "((?:^|[.!?]\s+)[a-z])", "$u1")
    } ;Seperator, no 5
    Else If (A_ThisMenuItemPos = 6)
    {
       TempText := RegExReplace(TempText, "\R", "`r`n")
    }
    Else If (A_ThisMenuItemPos = 7)
    {
       Temp2 =
       StringReplace, TempText, TempText, `r`n, % Chr(29), All
       Loop Parse, TempText
          Temp2 := A_LoopField . Temp2
       StringReplace, TempText, Temp2, % Chr(29), `r`n, All
    }
    PutText(TempText)
    Return
}

; Pastes text from a variable while preserving the clipboard.
PutText(MyText)
{
   SavedClip := ClipboardAll 
   Clipboard =              ; For better compatability
   Sleep 20                 ; with Clipboard History
   Clipboard := MyText
   Send ^v
   Sleep 100
   Clipboard := SavedClip
   Return
}

; Makes window transparent
TransparentWindow() 
{
    static setTransparent := True
    If NOT IsWindow(WinExist("A"))
       Return
    If setTransparent
       Winset, Transparent, 100, A
    else
       Winset, Transparent, OFF, A
    setTransparent := !setTransparent
    Return
}

;This checks if a window is, in fact a window.
;As opposed to the desktop or a menu, etc.
IsWindow(hwnd) 
{
   WinGet, s, Style, ahk_id %hwnd% 
   return s & 0xC00000 ? (s & 0x80000000 ? 0 : 1) : 0
   ;WS_CAPTION AND !WS_POPUP(for tooltips etc) 
}

; close active IsWindow

CloseActiveWindow()
{
    MyWin := WinExist("A")
    WinGetTitle winTitle, ahk_id %MyWin%
    If NOT winTitle ;Prevents terminated the taskbar, or the like.
       Return
    WinGet MyPID, PID, ahk_id %MyWin%
    Process, Close, %MyPID%
    Return
}

AlwaysOnTop()
{
   static setAlwaysOnTop := True
    If NOT IsWindow(WinExist("A"))
        Return
    WinGetTitle, winTitle, A
    If NOT setAlwaysOnTop
    {
       WinSet AlwaysOnTop, Off, A
       If (SubStr(winTitle, 1, 2) = "† ")
          winTitle := SubStr(winTitle, 3)
    }
    else
    {
       WinSet AlwaysOnTop, On, A
       If (SubStr(winTitle, 1, 2) != "† ")
          winTitle := "† " . winTitle ;chr(134)
    }
    WinSetTitle, A, , %winTitle%
    setAlwaysOnTop := !setAlwaysOnTop
    Return

}

; work in progress
ToggleActiveWindow() {
;   static lastActiveWinId := "noID"
;   SetTitleMatchMode, 2
;   DetectHiddenWindows, Off
;   WinGet, curr_ActWinId, ID, A
;
;   if (lastActiveWinId == "NoId") {
;      lastActiveWinId = curr_ActWinId
;   }
;
;   If WinActive, %lastActiveWinId% {
;      WinMinimize, 
;   }
;   Else {
;      IfWinExist, {
;         DllCall("SwitchToThisWindow", "UInt", lastActiveWinId, "UInt", 1)
;      }
;   }
}

toggleTaskManager() {
	If WinExist("Task Manager") {
		WinKill
	}
	else {
		Run, taskmgr,,
	}
	;Else
	;	
}

startProgram(location) {
	Run, %location%
}

changeOpasity(value) {
	MouseGetPos,,, hwndUnderCursor
	WinGet, currOpacity, Transparent, ahk_id %hwndUnderCursor%
	If !(curropacity)
		currOpacity := 255
	currOpacity := currOpacity + value
	currOpacity := (currOpacity < 25) ? 25 : (currOpacity >= 255) ? 255 : currOpacity
	WinSet, Transparent, %currOpacity%, ahk_id %hwndUnderCursor%
}

; not used currently
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
 DllCall("LockWorkStation")
 Sleep, 200
 SendMessage,0x112,0xF170,2,,Program Manager
}
