#IfWinActive, ahk_class CabinetWClass

CapsLock & BackSpace::backspaceToUp()
^b::openCmdInExplorerPath()
^e::showHideExtensionInExplorer()
^y::copyExplorerPathToClipboard()
^/:: Send ^e

#IfWinActive


backspaceToUp() {
    If (GetKeyState("Alt","P")) {
        Send return
    }
	Send !{Up}
}

getPathFromExplorer() {
	ClipSaved := ClipboardAll
	Send !d
	Sleep 100
	Send ^c
	Sleep, 200
	Send {Tab}
	Sleep, 200
	Send {Tab}
	ExplorerPath := Clipboard
	Clipboard := ClipSaved
	ClipSaved =
	return ExplorerPath
}

openCmdInExplorer(pathToOpen) {
	Run, cmd /K "cd `"%pathToOpen%`""
}

openCmdInExplorerPath() {
	ExplorerPath := getPathFromExplorer()
	openCmdInExplorer(ExplorerPath)
}

copyExplorerPathToClipboard() {
	Clipboard := getPathFromExplorer()
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
