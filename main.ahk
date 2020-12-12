#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
#Include features/virtualDesktop.ahk
#Include features/favorites.ahk
#Include features/util.ahk
#Include features/stayAwake.ahk
#Include features/winExplorer.ahk
;#Include features/iswitchw.ahk

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
#+Q::CloseActiveWindow()
LWin & i::showInfo()
;LWin & o::ToggleWinMinimize()
LWin & t::TransparentWindow()
LWin & w::stayAwake()
LWin & <:: moveWindowToPreviousMonitor()
LWin & >:: moveWindowToNextMonitor()
LWin & h:: selectPreviousWindow()
LWin & l:: selectNextWindow()

selectPreviousWindow() {
    Send !+{Tab}
}
selectNextWindow() {
    Send !{Tab}
}



#L::lockWorkStationAndTurnOffScreen()  ;; Turn off monitor after locking system
#Space::ToggleTaskBarAndStart()
#WheelUp:: changeOpasity(10)
#WheelDown:: changeOpasity(-10)
;#;::showISwitchW() reserved in iswitchw.ahk

CapsLock & t::TransparentWindow()
CapsLock & x::CloseActiveWindow()
CapsLock & d::CloseActiveWindow()
CapsLock & a::AlwaysOnTop()
CapsLock & i::showInfo()

; TODO: window visible on all desktops

CapsLock & Esc::Suspend ; Suspend AutoHotKey
#Esc::toggleTaskManager()
#Enter::startProgram("", "cmd.exe c:\")
CapsLock & Enter::startProgram("", "explorer.exe C:\")
#F1::startProgram("", "C:\Program Files\Google Chrome (Local)\chrome.exe --ssl-version-min=tls1 --ssl-version-fallback-min=tls1 --no-default-browser-check")
#F2::startProgram("Microsoft Teams", "C:\Program Files (x86)\Microsoft\Teams\current\Teams.exe")


moveWindowToPreviousMonitor() {
    Send #+{Left}
}

moveWindowToNextMonitor() {
    Send #+{Right}
}