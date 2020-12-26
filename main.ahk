#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

#Include features/virtualDesktop.ahk
#Include features/favorites.ahk
#Include features/util.ahk
#Include features/stayAwake.ahk
#Include features/quicksearch.ahk
;#Include features/iswitchw.ahk
#Include features/winExplorer.ahk

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
#s::quickGoogleSearch()
CapsLock & s::quickGoogleSearch()

; enter as a hotkey
Enter::Send {Enter}
!Enter::Send !{Enter}
+Enter::Send +{Enter}
^Enter::Send ^{Enter}
^!Enter::Send ^!{Enter}
Enter & Esc::toggleTaskManager()
Enter & w::stayAwake()
Enter & t::TransparentWindow()

;LWin & o::ToggleWinMinimize()
#t::TransparentWindow()
#w::stayAwake()
#<:: moveWindowToPreviousMonitor()
#>:: moveWindowToNextMonitor()
#h:: selectPreviousWindow()
#l:: selectNextWindow()
#+Esc::lockWorkStationAndTurnOffScreen()  ;; Turn off monitor after locking system
#Space::ToggleTaskBarAndStart()
#WheelUp:: changeOpasity(10)
#WheelDown:: changeOpasity(-10)
#Esc::toggleTaskManager()
#m::restoreWindow()
#p::togglePinActiveWindow()
#Enter::startProgram("", "cmd.exe c:\")
CapsLock & Enter::startProgram("", "explorer.exe C:\")
#F1::startProgram("", "C:\Program Files\Google Chrome (Local)\chrome.exe --ssl-version-min=tls1 --ssl-version-fallback-min=tls1 --no-default-browser-check")
#F2::startProgram("Microsoft Teams", "C:\Program Files (x86)\Microsoft\Teams\current\Teams.exe")
PgDn::doNothing()
PgUp::doNothing()

restoreWindow() {
    WinGet, vMinMax, MinMax, A

    if (vMinMax == 1) { ; window is maximized -> action restore window
        Send, #{Down}
    } else if(vMinMax == -1) { ; window is minimized -> action maximize window
        Send, #{Up}
    } else { ; neider maximized nor minimized -> action maximize window
        Send, #{Up}
    }
}

doNothing() {
    
}


selectPreviousWindow() {
    Send !+{Tab}
}
selectNextWindow() {
    Send !{Tab}
}


;#;::showISwitchW() reserved in iswitchw.ahk

;CapsLock & t::TransparentWindow()
CapsLock & a::AlwaysOnTop()
;CapsLock & i::showInfo()

; TODO: window visible on all desktops

CapsLock & Esc::Suspend ; Suspend AutoHotKey



moveWindowToPreviousMonitor() {
    Send #+{Left}
}

moveWindowToNextMonitor() {
    Send #+{Right}
}


