#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

; https://stackoverflow.com/questions/65961435/how-to-disable-the-71-keys-pressed-in-the-last-window - check for documentation
#MaxHotkeysPerInterval 1000
#HotkeyInterval 2000

#Include features/virtualDesktop.ahk
#Include features/favorites.ahk
#Include features/util.ahk
#Include features/winExplorer.ahk
#Include features/ResourceMonitor.ahk

; ! - Alt
; # - Win
; ^ - Ctrl
; + - Shift


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

#q::CloseActiveWindow()
#+Q::lockPC()  ;; Turn off monitor after locking system
#i::showInfo()
; enter as a hotkey Enter::Send {Enter} !Enter::Send !{Enter}
;Enter::Send {Enter}
;!Enter::Send !{Enter}
;+Enter::Send +{Enter}
;^Enter::Send ^{Enter}
;^!Enter::Send ^!{Enter}

;LWin & o::ToggleWinMinimize()
#w::stayAwake()l
#<:: moveWindowToPreviousMonitor()
#>:: moveWindowToNextMonitor()
#[:: moveWindowToPreviousMonitor()
#]:: moveWindowToNextMonitor()
^+#Space::ToggleTaskBarAndStart()
^#WheelUp:: changeOpasity(10)
^#WheelDown:: changeOpasity(-10)
#{:: changeOpasity(10)
#}:: changeOpasity(-10)
#Esc::toggleTaskManager()
#m::restoreWindow()
#p::togglePinActiveWindow()
#a::AlwaysOnTop()
#c::copyActiveWindowPathToClipboard()

#Enter::startProgram("cmd.exe c:\")
#+Enter::startProgram("explorer.exe C:\")
#+c::startProgram("C:\Program Files\Google Chrome (Local)\chrome.exe")
#+I::startProgram("C:\Program Files (x86)\JetBrains\IntelliJ IDEA 2021.3.1\bin\idea64.exe")


CapsLock & w::Send ^+{Right}

CapsLock & h::Send {Left}
CapsLock & j::Send {Down}
CapsLock & k::Send {Up}
CapsLock & l::Send {Right}
CapsLock & e::Send ^+{Right}
CapsLock & b::Send ^+{Left}
CapsLock & u::Send ^{z}
CapsLock & r::Send ^{y}

CapsLock & 4::Send +{End}
CapsLock & 0::Send +{Home}
CapsLock & x::Send {BackSpace}
CapsLock & Backspace::Send {Del}

CapsLock & F12::Suspend ; Suspend AutoHotKey
; this was setting for royal kludge tk61 keyboard
;Shift & Esc::Send {~}

CapsLock & m::SoundSet, +1,, Mute
CapsLock & Space::SoundSet, 1, Microphone, Mute


;CapsLock & h::Send #{Left}
;CapsLock & j::Send #{Down}
;CapsLock & k::Send #{Up}
;CapsLock & l::Send #{Right}

;Tab::Send {Tab}
;!Tab::Send !{Tab}
;#Tab::Send #{Tab}
;^Tab::Send ^{Tab}
;+Tab::Send +{Tab}
;
;Tab & h::Send {Left}
;Tab & j::Send {Down}
;Tab & k::Send {Up}
;Tab & l::Send {Right}
;Tab & e::Send ^{Right}
;Tab & b::Send ^{Left}



;CapsLock & 1::Send {F1}
;CapsLock & 2::Send {F2}
;CapsLock & 3::Send {F3}
;CapsLock & 4::Send {F4}
;CapsLock & 5::Send {F5}
;CapsLock & 6::Send {F6}
;CapsLock & 7::Send {F7}
;CapsLock & 8::Send {F8}
;CapsLock & 9::Send {F9}
;CapsLock & 0::Send {F10}
;CapsLock & -::Send {F11}
;CapsLock & =::Send {F12}

; Media keys
; ! - Alt
; # - Win
; ^ - Ctrl
; + - Shift
CapsLock & [::Send {Volume_Down}
CapsLock & ]::Send {Volume_Up}

^+WheelDown::Send {Right}
^+WheelUp::Send {Left}

!^+WheelDown::Send {Right}
!^+WheelUp::Send {Left}

+WheelDown::Send {Volume_Up}
+WheelUp::Send {Volume_Down}

!WheelDown::Send {WheelRight}
!WheelUp::Send {WheelLeft}

!^WheelDown::Send ^{Tab}
!^WheelUp::Send +^{Tab}

CapsLock::return

; This script will toggle your default Windows Audio Output device if you have 2 enabled audio devices.
; For more audio devices, contact me at https://davidvielmetter.com/contact/
; This script maps to Win+A hot key combo once activated!
#F13::
Run, mmsys.cpl
WinWait,Sound
ControlSend,SysListView321,{Up 2}
ControlGet, isEnabled, Enabled,,&Set Default
if(!isEnabled)
{
  ControlSend,SysListView321,{Down}
}
ControlClick,&Set Default
ControlClick,OK
return

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