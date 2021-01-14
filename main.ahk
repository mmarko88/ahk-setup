#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

#Include features/virtualDesktop.ahk
#Include features/favorites.ahk
#Include features/util.ahk
#Include features/winExplorer.ahk
#Include features/ResourceMonitor.ahk


#1::ChangeDesktop(0)
#2::ChangeDesktop(1)
#3::ChangeDesktop(2)
#4::ChangeDesktop(3)
#5::ChangeDesktop(4)
#6::ChangeDesktop(5)
#7::ChangeDesktop(6)
#8::ChangeDesktop(7)
#9::ChangeDesktop(8)
#0::ChangeDesktop(9)
#,::GoToPrevDesktop()
#.::GoToNextDesktop()

+#1::ChangeDesktop(0)
+#2::ChangeDesktop(1)
+#3::ChangeDesktop(2)
+#4::ChangeDesktop(3)
+#5::ChangeDesktop(4)
+#6::ChangeDesktop(5)
+#7::ChangeDesktop(6)
+#8::ChangeDesktop(7)
+#9::ChangeDesktop(8)
+#0::ChangeDesktop(9)
+#,::GoToPrevDesktop()
+#.::GoToNextDesktop()

#+Q::CloseActiveWindow()
#i::showInfo()
; enter as a hotkey Enter::Send {Enter} !Enter::Send !{Enter}
Enter::Send {Enter}
+Enter::Send +{Enter}
^Enter::Send ^{Enter}
^!Enter::Send ^!{Enter}
Enter & w::stayAwake()

;LWin & o::ToggleWinMinimize()
#w::stayAwake()
#<:: moveWindowToPreviousMonitor()
#>:: moveWindowToNextMonitor()
#[:: moveWindowToPreviousMonitor()
#]:: moveWindowToNextMonitor()
#+Esc::lockPC()  ;; Turn off monitor after locking system
^+#Space::ToggleTaskBarAndStart()
#WheelUp:: changeOpasity(10)
#WheelDown:: changeOpasity(-10)
#{:: changeOpasity(10)
#}:: changeOpasity(-10)
#Esc::toggleTaskManager()
#m::restoreWindow()
#p::togglePinActiveWindow()
#a::AlwaysOnTop()
#c::copyActiveWindowPathToClipboard()
#Enter::startProgram("cmd.exe c:\")
#+Enter::startProgram("explorer.exe C:\")
#+c::startProgram("C:\Program Files\Google Chrome (Local)\chrome.exe --ssl-version-min=tls1 --ssl-version-fallback-min=tls1 --no-default-browser-check")
PgDn::Send {Down}
PgUp::Send {Up}

CapsLock & m::Send {End}
CapsLock & y::Send {PrintScreen}
CapsLock & u::Send {ScrollLock}
CapsLock & i::Send {Pause}
CapsLock & n::Send {Del}
CapsLock & ,::Send {PgDn}
CapsLock & Backspace::Send {Del}

CapsLock & F12::Suspend ; Suspend AutoHotKey
Enter & Esc::Send {~}

CapsLock & g::Send {Home}

CapsLock & h::Send #{Left}
CapsLock & j::Send #{Down}
CapsLock & k::Send #{Up}
CapsLock & l::Send #{Right}

CapsLock & 1::Send {F1}
CapsLock & 2::Send {F2}
CapsLock & 3::Send {F3}
CapsLock & 4::Send {F4}
CapsLock & 5::Send {F5}
CapsLock & 6::Send {F6}
CapsLock & 7::Send {F7}
CapsLock & 8::Send {F8}
CapsLock & 9::Send {F9}
CapsLock & 0::Send {F10}
CapsLock & -::Send {F11}
CapsLock & =::Send {F12}

; Media keys
CapsLock & [::Send {Volume_Down}
CapsLock & ]::Send {Volume_Up}

lockPC() {
    Run, regedit.exe /s "enableWinLock.reg"

    lockWorkStationAndTurnOffScreen()

    SetTimer, enableWindowsLock, -1000
    Return
    
    enableWindowsLock:
        Run, regedit.exe /s "disableWinLock.reg"
        Return
}

copyActiveWindowPathToClipboard() {
	WinGet, activePath, ProcessPath, % "ahk_id" winActive("A")	; activePath is the output variable and can be named anything you like, ProcessPath is a fixed parameter, specifying the action of the winget command.
	Clipboard := activePath 
}

restoreWindow() {
    WinGet, vMinMax, MinMax, A

    if (vMinMax == 1) { ; window is maximized -> action restore window
        WinRestore, A
    } else if(vMinMax == -1) { ; window is minimized -> action maximize window
        WinRestore, A
    } else { ; neider maximized nor minimized -> action maximize window
        WinMaximize, A
    }
}

doNothing() {
    
}


moveWindowToPreviousMonitor() {
    Send #+{Left}
}

moveWindowToNextMonitor() {
    Send #+{Right}
}


stayAwake() {
    static stayAwakeFlag := False
    CoordMode, Mouse, Screen
    
    stayAwakeFlag := !stayAwakeFlag

    if (stayAwakeFlag) {
        showOsd("Stay awake ON")
    } else {
        showOsd("Stay awake OFF")
    }
    Goto, moveMouse
    Return

    moveMouse:
        MouseGetPos, CurrentX, CurrentY
        MouseGetPos, CurrentX, CurrentY
        If (CurrentX = LastX and CurrentY = LastY) {
            MouseMove, 1, 1, , R
            Sleep, 100
            MouseMove, -1, -1, , R
        }
        LastX := CurrentX
        LastY := CurrentY
        if (stayAwakeFlag) {
            SetTimer, moveMouse, -60000
        }
        Return
}