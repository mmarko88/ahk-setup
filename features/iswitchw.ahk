#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

#Include chromeFunctions.ahk
#Include virtualDesktop.ahk


; Window titles containing any of the listed substrings are filtered out from
; the initial list of windows presented when iswitchw is activated. Can be
; useful for things like  hiding improperly configured tool windows or screen
; capture software during demos.
filters := ["Window Switcher", "AutoHotkey"]

; Set this to true to update the list of windows every time the search is
; updated. This is usually not necessary and creates additional overhead, so
; it is disabled by default.
refreshEveryKeystroke := false

; Only re-filter the possible window matches this often (in ms) at maximum.
; When typing is rapid, no sense in running the search on every keypress.
debounceDuration = 250

; When true, filtered matches are scored and the best matches are presented
; first. This helps account for simple spelling mistakes such as transposed
; letters e.g. googel, vritualbox. When false, title matches are filtered and
; presented in the order given by Windows.
scoreMatches := true

; Split search string on spaces and use each term as an additional
; filter expression.
;
; For example, you are working on an AHK script:
;  - There are two Explorer windows open to ~/scripts and ~/scripts-old.
;  - Two Vim instances editing scripts in each one of those folders.
;  - A browser window open that mentions scripts in the title
;
; This is amongst all the other stuff going on. You bring up iswitchw and
; begin typing 'scrip'. Now, we have several best matches filtered.  But I
; want the Vim windows only. Now I might be able to make a more unique match by
; adding the extension of the file open in Vim: 'scripahk'. Pretty good, but
; really the first thought was process name -- Vim. By breaking on space, we
; can first filter the list for matches on 'scrip' for 'script' and then,
; 'vim' in order to match by Vim amongst the remaining windows.
useMultipleTerms := true

;----------------------------------------------------------------------
;
; Global variables
;
;     allwindows  - windows on desktop
;     windows     - windows in listbox
;     search      - the current search string
;     lastSearch  - previous search string
;     switcher_id - the window ID of the switcher window
;     debounced   - true when its ok to re-filter
;
;----------------------------------------------------------------------

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Global tClass:="SysShadow,Alternate Owner,tooltips_class32,DummyDWMListenerWindow,EdgeUiInputTopWndClass,ApplicationFrameWindow,TaskManagerWindow,Qt5QWindowIcon,Windows.UI.Core.CoreWindow,WorkerW,Progman,Internet Explorer_Hidden,Shell_TrayWnd" ; HH Parent

hVirtualDesktopAccessor := DllCall("LoadLibrary", Str, "VirtualDesktopAccessor.dll", "Ptr") 
ViewSwitchTo := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "ViewSwitchTo", "Ptr")
GetWindowDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetWindowDesktopNumber", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")

global search =
global lastSearch =
global allwindows := Object()
global hiddenWindows := Object()
global filteredWindows := Object()
global debounced := true
global activeWindowId =


global windowsOnDesktop := Object()
global selectedWindowIndex := 1

#j::changeActiveWindow(1)
#k::changeActiveWindow(-1)

changeActiveWindow(offset) {
  syncWindowList()
;  wid := windowsOnDesktop[selectedWindowIndex].id
;  title := windowsOnDesktop[selectedWindowIndex].title
;  MsgBox, selectedWindowIndex %selectedWindowIndex% wid %wid% title %title%
  selectedWindowIndex := incDecByOffset(selectedWindowIndex, windowsOnDesktop.MaxIndex(), offset)

  wid := windowsOnDesktop[selectedWindowIndex].id
  ;  title := windowsOnDesktop[selectedWindowIndex].title
  ;  MsgBox, selectedWindowIndex %selectedWindowIndex% wid %wid% title %title%
  activateWindow(wid)
}

incDecByOffset(currVal, maxVal, offset) {
  returnVal := currVal + offset
  if (returnVal <= 0) {
    returnVal := maxVal
  }
  if (returnVal > maxVal) {
    returnVal := 1
  }
  return returnVal
}

syncWindowList() {
  global windowsOnDesktop
  static checkForWindowChanges := True
  if (!checkForWindowChanges) {
    Return
  }
  DetectHiddenWindows, Off
  currDesktopNum := getCurrDesktopNum() ; filter only those on the same desktop
  currentWindowList := GetAllWindows(-1, false, false, false, currDesktopNum)

  if (windowsOnDesktop.MinIndex() == "" || windowsOnDesktop.MaxIndex() != currentWindowList.MaxIndex()) {
    windowsOnDesktop := currentWindowList
    selectedWindowIndex := 1
  }
  checkForWindowChanges := False

  refreshTime := 2000
  SetTimer, turnOnCheckForWindowChanges, -%refreshTime%
  return

  turnOnCheckForWindowChanges:
    checkForWindowChanges := true
    return
}


;----------------------------------------------------------------------
;
; Alt tab to activate.
;
#'::showSearchList(false, false)
#+'::showSearchList(false, true)
#^'::showSearchList(true, false)

getCurrentDesktopNum(){
  global GetCurrentDesktopNumberProc
;  RegRead, cur, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops, CurrentVirtualDesktop
;  RegRead, all, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
;  ix := floor(InStr(all,cur) / strlen(cur))
;  return ix

 return DllCall(GetCurrentDesktopNumberProc, UInt)

}

drawSwitcherWindow() {
  global search

  Gui,   +LastFound +AlwaysOnTop -Caption +ToolWindow
  Gui,   Color, black,black
  WinSet, Transparent, 225
  Gui,   Font, s16 cEEE8D5 bold, Consolas
  Gui,   Margin, 4, 4
  Gui,   Add, Text,     w100 h30 x6 y8, Search`:
  Gui,   Add, Edit,     w500 h30 x110 y4 gSearchChange vsearch,
  Gui,   Add, ListView, w1200 h510 x4 y40 -VScroll -HScroll -Hdr -Multi Count10 AltSubmit gListViewClick, index|listId|deskNo|title|proc

  GuiControl,   , Edit1
  Gui,   Show, Center, Window Switcher
  WinGet, switcherId, ID, A
  WinSet, AlwaysOnTop, On, ahk_id %switcherId%
  ControlFocus, ahk_id %switcherId%
  return switcherId
}

processUserInput(switcherId) {
  Loop
  {
    Input, input, L1, {enter}{esc}{tab}{backspace}{delete}{up}{down}{left}{right}{home}{end}{F4}{Ctrl}

    if ErrorLevel = EndKey:enter
    {
      activateWindowFromGui()
      break
    }
    else if ErrorLevel = EndKey:escape
    {
      Gui,   Destroy
      break
    }
    else if ErrorLevel = EndKey:tab
    {
      ControlFocus, SysListView321, ahk_id %switcherId%

      ; When on last row, wrap tab next to top of list.
      if LV_GetNext(0) = LV_GetCount()
      {
        LV_Modify(1, "Select")
        LV_Modify(1, "Focus")
      } else {
        ControlSend, SysListView321, {down}, ahk_id %switcherId%
      }

      continue
    }
    else if ErrorLevel = EndKey:backspace
    {
      ControlFocus, Edit1, ahk_id %switcherId%

      if GetKeyState("Ctrl","P")
        chars = {blind}^{Left}{Del} ; courtesy of VxE: http://www.autohotkey.com/board/topic/35458-backward-search-delete-a-word-to-the-left/#entry223378
      else
        chars = {backspace}

      ControlSend, Edit1, %chars%, ahk_id %switcherId%

      continue
    }
    else if ErrorLevel = EndKey:delete
    {
      ControlFocus,  Edit1, ahk_id %switcherId%
      keys := AddModifierKeys("{del}")
      ControlSend, Edit1, %keys%, ahk_id %switcherId%
      continue
    }
    else if ErrorLevel = EndKey:up
    {
      ControlFocus, SysListView321, ahk_id %switcherId%
      ControlSend, SysListView321, {up}, ahk_id %switcherId%
      continue
    }
    else if ErrorLevel = EndKey:down
    {
      ControlFocus, SysListView321, ahk_id %switcherId%
      ControlSend, SysListView321, {down}, ahk_id %switcherId%
      continue
    }
    else if ErrorLevel = EndKey:left
    {
      ControlFocus, Edit1, ahk_id %switcherId%
      keys := AddModifierKeys("{left}")
      ControlSend, Edit1, %keys%, ahk_id %switcherId%
      continue
    }
    else if ErrorLevel = EndKey:right
    {
      ControlFocus, Edit1, ahk_id %switcherId%
      keys := AddModifierKeys("{right}")
      ControlSend, Edit1, %keys%, ahk_id %switcherId%
      continue
    }
    else if ErrorLevel = EndKey:home
    {
      send % AddModifierKeys("{home}")
      continue
    }
    else if ErrorLevel = EndKey:end
    {
      send % AddModifierKeys("{end}")
      continue
    }
    else if ErrorLevel = EndKey:F4
    {
      if GetKeyState("Alt","P")
        ExitApp
    }

    ControlFocus, Edit1, ahk_id %switcherId%
    Control, EditPaste, %input%, Edit1, ahk_id %switcherId%
  }
}


showSearchList(searchChromeTabs := false, searchActiveWindowSiblings := false) {
  global debounced, debounceDuration, activeWindowId
  AutoTrim, off

  global search =
  global lastSearch =
  global allwindows := Object()
  global hiddenWindows := Object()
  global filteredWindows := Object()
  global debounced := true
  global activeWindowId =

  Gui, osd: Destroy ; remove any other active window

  WinGet, activeWindowId, ID, A

  switcherId := drawSwitcherWindow()
  processUserInput(switcherId)

  return
  ;
  ; Runs whenever Edit control is updated
  SearchChange:
    onSearchChange(switcherId, searchChromeTabs, searchActiveWindowSiblings)
    return
  ;----------------------------------------------------------------------
  ;
  ; Handle mouse click events on the listview
  ;
  ListViewClick:
    if (A_GuiControlEvent = "Normal") {
      SendEvent {enter}
    }
    return
}

isVarInitialized(var) {
  if var =
    return False
  else
    return True
}

onSearchChange(switcherId, searchChromeTabs := false, searchActiveWindowSiblings := false) {
  global debounced, debounceDuration
  
  if(!isVarInitialized(switcherId)) Return

  if (!debounced) {
    return
  }
  debounced := false
  SetTimer, Debounce, -%debounceDuration%
  Gui, Submit, NoHide
  refreshWindowList(switcherId, searchChromeTabs, searchActiveWindowSiblings)
  return
  ;----------------------------------------------------------------------
  ; Clear debounce check
  Debounce:
    debounced := true
    Gui, Submit, NoHide
    refreshWindowList(switcherId, searchChromeTabs, searchActiveWindowSiblings)
    return
}

;----------------------------------------------------------------------
;
; Refresh the list of windows according to the search criteria
;
refreshWindowList(switcherId, searchChromeTabs := false, searchActiveWindowSiblings := false)
{
  DetectHiddenWindows, On

  global allwindows, filteredWindows
  global search, lastSearch, refreshEveryKeystroke

  uninitialized := (allwindows.MinIndex() = "")

  allwindows := GetAllWindows(switcherId, searchActiveWindowSiblings, searchChromeTabs)

  currentSearch := Trim(search)
  if ((currentSearch == lastSearch) && !uninitialized) {
    return
  }

  ; When adding to criteria (ie typing, not erasing), refilter
  ; the existing filtered list. This should be sane since the even if we enter
  ; a new letter at the beginning of the search term, all shown matches should
  ; still contain the previous search term as a 'substring'.
  useExisting := (StrLen(currentSearch) > StrLen(lastSearch))
  lastSearch := currentSearch

  filteredWindows := FilterWindowList(useExisting ? filteredWindows : allwindows, currentSearch)

  DrawListView(filteredWindows)
  DetectHiddenWindows, Off
}


;----------------------------------------------------------------------
;
; Checks if user is holding Ctrl and/or Shift, then adds the
; appropriate modifiers to the key parameter before returning the
; result.
;
AddModifierKeys(key)
{
  if GetKeyState("Ctrl","P")
    key := "^" . key

  if GetKeyState("Shift","P")
    key := "+" . key

  return key
}

;----------------------------------------------------------------------
;
; Unoptimized array search, returns index of first occurrence or -1
;
IncludedIn(haystack,needle)
{
  Loop % haystack.MaxIndex()
  {
    item := haystack[a_index]
    item := Trim(item)

    if item =
      continue

    IfInString, needle, %item%
      return %a_index%
  }

  return -1
}

;----------------------------------------------------------------------
;
; Fetch info on all active windows
;
GetAllWindows(switcherId, searchActiveWindowSiblings := False, searchBrowserTabs := false, switchFirstAndSecond := true, deskNum := -1) {
  global filters
  global currWinSize
  global cycleCurrentIdx
  global GetWindowDesktopNumberProc

  newWindows := Object()

  activeWindowProcessName =
  
  if searchActiveWindowSiblings {
    activeWindowProcessName := GetProcessName(activeWindowId)
  }


  cnt := 0
  WinGet, id, list, , , Program Manager
  Loop, %id%
  {
    wid := Trim(id%a_index%)

    ; don't add the switcher window
    if switcherId = %wid%
      continue


    if !IsWindowVisibleMemo(wid) || !IsValidExStyle(wid)
      Continue

    if IsInTClass(wid)
      Continue

    WinGetTitle, title, ahk_id %wid%
    title := Trim(title)

    if title = 
      continue    

    ; don't add titles which match any of the filters
    if IncludedIn(filters, title) > -1
      continue

    ; replace pipe (|) characters in the window title,
    ; because Gui Add uses it for separating listbox items
    title := StrReplace(title, "|", "-", 0, -1)
    ;OutputVarCount 0 if none
    ;Limit it defaults to -1

    procName := GetProcessName(wid)

    if procName = AutoHotkey
      Continue


    if searchActiveWindowSiblings && activeWindowProcessName != procName {
      Continue
    }

    windowDeskNum := DllCall(GetWindowDesktopNumberProc, UInt, wid, UInt)

    if (deskNum >= 0 && windowDeskNum != deskNum) {
      Continue
    }

    if (procName = "chrome" && searchBrowserTabs) {
      chromeTabNames := JEE_ChromeGetTabNames(wid, "|")
      chromeTabArray := StrSplit(chromeTabNames, "|")
      Loop % chromeTabArray.MaxIndex()
      {
        tabTitle := Trim(chromeTabArray[A_Index])
        if tabTitle = 
          Continue
        cnt := cnt + 1
        printCnt := getPrintCnt(cnt)

        newWindows.Insert({ "id": wid, "title": tabTitle, "procName": procName, "listid" : printCnt, "deskNum" : windowDeskNum })
        
      }
      Continue
    }

    if (searchBrowserTabs) {
      Continue
    }


    cnt := cnt + 1
    printCnt := getPrintCnt(cnt)  
    newWindows.Insert({ "id": wid, "title": title, "procName": procName, "listid" : printCnt, "deskNum" :windowDeskNum })
  }

  currWinSize := cnt - 1
  cycleCurrentIdx := 1

  ; first window is active window, user usually wants to switch to other window
  ; because of that, switch first and second place in the array

  if (switchFirstAndSecond && newWindows.MaxIndex() > 2) {
    swapListElements(newWindows, newWindows.MinIndex(), newWindows.MinIndex() + 1)
  }

  return newWindows
}

swapListElements(ByRef list,t,u) {
  tmp := list[t]
  tmpPrintCnt := list[t].listid

  list[t].listid := list[u].listid
  list[t] := list[u]

  list[u].listid := tmpPrintCnt
  list[u] := tmp

return list
}


getPrintCnt(cnt) {
  printCnt := cnt

    if (printCnt < 10)
      printCnt := "0" + cnt

  return printCnt
}
IsWindowCloaked(hwnd) {
  return DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "int", 14, "int*", cloaked, "int", 4) >= 0
      && cloaked
}

IsWindowVisibleMemo(hwnd) {
  global hiddenWindows
  if (hiddenWindows.HasKey(hwnd)) {
    return False
  } else {
    isVisible := IsWindowVisible(hwnd)
    if (!isVisible) {
      hiddenWindows[hwnd] := True
    }
    Return isVisible
  }
}

IsWindowVisible(hwnd) {
    if DllCall("IsWindowVisible", UPtr,hwnd) 
      return True
    else
      return False
}

IsInTClass(hwnd) {
  WinGetClass, cClass, ahk_id %hwnd%
  if InStr(tClass, cClass, 1) ; if cClass in %tClass%
    return True
  else
    return False
}

IsValidExStyle(hwnd) {
  WinGet, vExStyle, ExStyle, ahk_id %hwnd%
  return !((vExStyle & WS_EX_TOOLWINDOW) && !(vExStyle & WS_EX_APPWINDOW))
}

;----------------------------------------------------------------------
;
; Filter window list with given search criteria
;
FilterWindowList(list, criteria)
{
  global scoreMatches, useMultipleTerms
  filteredList := Object(), expressions := Object()
  lastTermInSearch := criteria, doScore := scoreMatches

  ; If useMultipleTerms, do multiple passes with filter expressions
  if (useMultipleTerms) {
    StringSplit, searchTerms, criteria, %A_space%

    Loop, %searchTerms0%
    {
      term := searchTerms%A_index%
      lastTermInSearch := term

      expr := BuildFilterExpression(term)
      expressions.Insert(expr)
    }
  } else if (criteria <> "") {
    expr := BuildFilterExpression(criteria)
    expressions[0] := expr
  }

  atNextWindow:
  For idx, window in list
  {
    ; if there is a search string
    if criteria <>
    {
      title := window.title
      procName := window.procName
      listid := window.listid
    
       ; don't add the windows not matching the search string
       titleAndProcName = %listid% %procName% %title%
       For idx, expr in expressions
       {
         if RegExMatch(titleAndProcName, expr) = 0
           continue atNextWindow
       }
    }

    doScore := scoreMatches && (criteria <> "") && (lastTermInSearch <> "")
    window["score"] := doScore ? StrDiff(lastTermInSearch, titleAndProcName) : 0

    filteredList.Insert(window)
  }

  return (doScore ? SortByScore(filteredList) : filteredList)
}

IsNum(x) {
   If x is Number
      Return 1
   Return 0
}


;----------------------------------------------------------------------
;
; http://stackoverflow.com/questions/2891514/algorithms-for-fuzzy-matching-strings
;
; Matching in the style of Ido/CtrlP
;
; Returns:
;   Regex for provided search term 
;
; Example:
;   explr builds the regex /[^e]*e[^x]*x[^p]*p[^l]*l[^r]*r/i
;   which would match explorer
;   or likewise
;   explr ahk
;   which would match Explorer - ~/autohotkey, but not Explorer - Documents
;
; Rules:
;  It is expected that all the letters of the input be in the keyword
;  It is expected that the letters in the input be in the same order in the keyword
;  The list of keywords returned should be presented in a consistent (reproductible) order
;  The algorithm should be case insensitive
;
BuildFilterExpression(term)
{
  expr := "i)" . term
;  Loop, parse, term
;  {
;    expr .= "[^" . A_LoopField . "]*" . A_LoopField
;  }

  return expr
}



;------------------------------------------------------------------------
;
; Perform insertion sort on list, comparing on each item's score property 
;
SortByScore(list)
{
  Loop % list.MaxIndex() - 1
  {
    i := A_Index+1
    window := list[i]
    j := i-1

    While j >= 0 and list[j].score > window.score
    {
      list[j+1] := list[j]
      j--
    }

    list[j+1] := window
  }

  return list
}

activateWindowFromGui() {
  global search
  Gui, Submit
  rowNum := LV_GetNext(0)
  if (rowNum > 0) {
    activateWindowFromList(rowNum)
  } else {
    windowsSearchProgram(search)
  }
  LV_Delete()
  Gui, Destroy
}

windowsSearchProgram(searchText) {
    Send {LWin}
    Sleep, 100
    Clipboard := searchText
    Send, ^{v}
}

;----------------------------------------------------------------------
;
; Activate selected window
;
activateWindowFromList(rowNum)
{
  global filteredWindows

  wid := filteredWindows[rowNum].id
  title := filteredWindows[rowNum].title
  procName := filteredWindows[rowNum].procName

  activateWindow(wid)

  if (procName = "chrome") {
    Sleep, 100 ; just in case
    JEE_ChromeFocusTabByName(wid, title)
  }

	SetTimer, osdCurrentDesktop, 200
	Return

osdCurrentDesktop:
	SetTimer, osdCurrentDesktop, Off
  currDesk := getCurrentDesktopNum() + 1
  showOsd("Desktop: " . currDesk)
	return
}

activateWindow(wid) {
  global GetWindowDesktopNumberProc
  windowDeskNum := DllCall(GetWindowDesktopNumberProc, UInt, wid, UInt)
  currentDeskNum := getCurrentDesktopNum()

  if (windowDeskNum  < 1000 and windowDeskNum != currentDeskNum) {
    ChangeDesktop(windowDeskNum)
  }
  
  WinShow, ahk_id %wid%
  WinActivate, ahk_id %wid%
}

;----------------------------------------------------------------------
;
; Add window list to listview
;
DrawListView(windowList)
{
  windowCount := windowList.MaxIndex()
  imageListID := IL_Create(windowCount, 1, 1)

  ; Attach the ImageLists to the ListView so that it can later display the icons:
  LV_SetImageList(imageListID, 1)
  LV_Delete()

  iconCount = 0
  removedRows := Array()

  For idx, window in windowList
  {
    wid := window.id
    title := window.title
    listid := window.listid
    deskNum := window.deskNum

    iconNumber := getIconNumber(imageListID, wid)

    if iconNumber > 0
    {
      iconCount+=1
      LV_Add("Icon" . iconNumber, listid, deskNum + 1, window.procName, title)
    } else {
      removedRows.Insert(idx)
    }
  }

  ; Don't draw rows without icons.
  windowCount-=removedRows.MaxIndex()
  For key,rowNum in removedRows
  {
    windowList.Remove(rowNum)
  }

  LV_Modify(1, "Select")
  LV_Modify(1, "Focus")
;  LV_ModifyCol(2, "Integer")  ; For sorting purposes, indicate that column 2 is an integer.
  LV_ModifyCol(1,70)
  LV_ModifyCol(2, 50)
  LV_ModifyCol(3, 200)
  LV_ModifyCol(4)
}

getIconNumber(imageListID, wid) {
    ; http://msdn.microsoft.com/en-us/library/windows/desktop/ff700543(v=vs.85).aspx
    ; Forces a top-level window onto the taskbar when the window is visible.
    WS_EX_APPWINDOW = 0x40000
    ; A tool window does not appear in the taskbar or in the dialog that appears when the user presses ALT+TAB.
    WS_EX_TOOLWINDOW = 0x80

    ; Retrieves an 8-digit hexadecimal number representing extended style of a window.
    WinGet, style, ExStyle, ahk_id %wid%

    isAppWindow := (style & WS_EX_APPWINDOW)
    isToolWindow := (style & WS_EX_TOOLWINDOW)

    ; http://msdn.microsoft.com/en-us/library/windows/desktop/ms632599(v=vs.85).aspx#owned_windows
    ; An application can use the GetWindow function with the GW_OWNER flag to retrieve a handle to a window's owner.
    GW_OWNER = 4
    ownerHwnd := DllCall("GetWindow", "uint", wid, "uint", GW_OWNER)

  if (isAppWindow or ( !ownerHwnd and !isToolWindow ))
    {
      ; http://www.autohotkey.com/docs/misc/SendMessageList.htm
      WM_GETICON := 0x7F

      ; http://msdn.microsoft.com/en-us/library/windows/desktop/ms632625(v=vs.85).aspx
      ICON_BIG := 1
      ICON_SMALL2 := 2
      ICON_SMALL := 0

      SendMessage, WM_GETICON, ICON_BIG, 0, , ahk_id %wid%
      iconHandle := ErrorLevel

      if (iconHandle = 0)
      {
        SendMessage, WM_GETICON, ICON_SMALL2, 0, , ahk_id %wid%
        iconHandle := ErrorLevel

        if (iconHandle = 0)
        {
          SendMessage, WM_GETICON, ICON_SMALL, 0, , ahk_id %wid%
          iconHandle := ErrorLevel

          if (iconHandle = 0)
          {
            ; http://msdn.microsoft.com/en-us/library/windows/desktop/ms633581(v=vs.85).aspx
            ; To write code that is compatible with both 32-bit and 64-bit
            ; versions of Windows, use GetClassLongPtr. When compiling for 32-bit
            ; Windows, GetClassLongPtr is defined as a call to the GetClassLong
            ; function.
            iconHandle := DllCall("GetClassLongPtr", "uint", wid, "int", -14) ; GCL_HICON is -14

            if (iconHandle = 0)
            {
              iconHandle := DllCall("GetClassLongPtr", "uint", wid, "int", -34) ; GCL_HICONSM is -34

              if (iconHandle = 0) {
                iconHandle := DllCall("LoadIcon", "uint", 0, "uint", 32512) ; IDI_APPLICATION is 32512
              }
            }
          }
        }
      }

      if (iconHandle <> 0)
        iconNumber := DllCall("ImageList_ReplaceIcon", UInt, imageListID, Int, -1, UInt, iconHandle) + 1

    } else {
      WinGetClass, Win_Class, ahk_id %wid%
      if Win_Class = #32770 ; fix for displaying control panel related windows (dialog class) that aren't on taskbar
        iconNumber := IL_Add(imageListID, "C:\WINDOWS\system32\shell32.dll", 217) ; generic control panel icon
    }
    return iconNumber
}

;----------------------------------------------------------------------
;
; Get process name for given window id
;
GetProcessName(wid)
{
  WinGet, name, ProcessName, ahk_id %wid%
  pos := InStr(name, ".") -1
  if ErrorLevel <> 1
  {
    name := SubStr(name, 1, pos)
  }

  return name
}

/*
https://gist.github.com/grey-code/5286786

By Toralf:
Forum thread: http://www.autohotkey.com/board/topic/54987-sift3-super-fast-and-accurate-string-distance-algorithm/#entry345400

Basic idea for SIFT3 code by Siderite Zackwehdex
http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html

Took idea to normalize it to longest string from Brad Wood
http://www.bradwood.com/string_compare/

Own work:
- when character only differ in case, LSC is a 0.8 match for this character
- modified code for speed, might lead to different results compared to original code
- optimized for speed (30% faster then original SIFT3 and 13.3 times faster than basic Levenshtein distance)
*/

;----------------------------------------------------------------------
;
; returns a float: between "0.0 = identical" and "1.0 = nothing in common"
;
StrDiff(str1, str2, maxOffset:=5) {
  if (str1 = str2)
    return (str1 == str2 ? 0/1 : 0.2/StrLen(str1))

  if (str1 = "" || str2 = "")
    return (str1 = str2 ? 0/1 : 1/1)

  StringSplit, n, str1
  StringSplit, m, str2

  ni := 1, mi := 1, lcs := 0
  while ((ni <= n0) && (mi <= m0)) {
    if (n%ni% == m%mi%)
      lcs++
    else if (n%ni% = m%mi%)
      lcs += 0.8
    else {
      Loop, % maxOffset {
        oi := ni + A_Index, pi := mi + A_Index
        if ((n%oi% = m%mi%) && (oi <= n0)) {
          ni := oi, lcs += (n%oi% == m%mi% ? 1 : 0.8)
          break
        }
        if ((n%ni% = m%pi%) && (pi <= m0)) {
          mi := pi, lcs += (n%ni% == m%pi% ? 1 : 0.8)
          break
        }
      }
    }

    ni++, mi++
  }

  return ((n0 + m0)/2 - lcs) / (n0 > m0 ? n0 : m0)
}

showOsd1(textToShow) {
	Gui, osd: Destroy
  CustomColor = 000000  ; Can be any RGB color (it will be made transparent below). 
	Gui, osd: +AlwaysOnTop +LastFound +Owner -Caption
	Gui, osd: Color, %CustomColor% 
	Gui, osd: Font, cFFFFFF S48, Verdana

  Gui, osd: add, Text, center center x2 y2 c000000 BackgroundTrans, %textToShow%
  Gui, osd: add, Text, center center x0 y0 cLime BackgroundTrans, %textToShow%

	WinSet, TransColor, %CustomColor%  250
	WinSet, ExStyle, +0x20, Output
	Gui, osd: Show, center center NoActivate, Output
 
	SetTimer, RemoveToolTip1, 3000

	Return


RemoveToolTip1:
	SetTimer, RemoveToolTip1, Off
	Gui, osd: Destroy
	return
	
}