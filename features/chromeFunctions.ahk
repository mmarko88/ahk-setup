;==================================================

;Chrome functions suite (tested on Chrome v77):

;requires Acc.ahk:
;Acc library (MSAA) and AccViewer download links - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=6&t=26201

;JEE_ChromeAccInit(vValue)
;JEE_ChromeGetUrl(hWnd:="", vOpt:="")
;JEE_ChromeGetTabCount(hWnd:="")
;JEE_ChromeGetTabNames(hWnd:="", vSep:="`n")
;JEE_ChromeFocusTabByNum(hWnd:="", vNum:="")
;JEE_ChromeFocusTabByName(hWnd:="", vTitle:="", vNum:="")
;JEE_ChromeGetFocusedTabNum(hWnd:="")
;JEE_ChromeAddressBarIsFoc(hWnd:="")
;JEE_ChromeCloseOtherTabs(hWnd:="", vOpt:="", vNum:="")

;note: you can only get the url for the *active* tab via Acc,
;to get the urls for other tabs, you could use a browser extension, see:
;Firefox/Chrome: copy titles/urls to the clipboard - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=22&t=66246

;==================================================

;note: these Acc paths often change:
;Acc paths determined via:
;[JEE_AccGetTextAll function]
;Acc: get text from all window/control elements - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=6&t=40615

#Include acc.ahk

JEE_ChromeAccInit(vValue)
{
	if (vValue = "U1")
		return "4.1.2.1.2.5.2" ;address bar
	if (vValue = "U2")
		return "4.1.2.2.2.5.2" ;address bar
	if (vValue = "T")
		return "4.1.2.1.1.1" ;tabs (append '.1' to get the first tab)
}

;==================================================

JEE_ChromeGetUrl(hWnd:="", vOpt:="")
{
	local
	static vAccPath1 := JEE_ChromeAccInit("U1")
	static vAccPath2 := JEE_ChromeAccInit("U2")
	if (hWnd = "")
		hWnd := WinExist("A")
	oAcc := Acc_Get("Object", vAccPath1, 0, "ahk_id " hWnd)
	if !IsObject(oAcc)
	|| !(oAcc.accName(0) = "Address and search bar")
		oAcc := Acc_Get("Object", vAccPath2, 0, "ahk_id " hWnd)
	vUrl := oAcc.accValue(0)
	oAcc := ""

	if InStr(vOpt, "x")
	{
		if !(vUrl = "") && !InStr(vUrl, "://")
			vUrl := "http://" vUrl
	}
	return vUrl
}

;==================================================

JEE_ChromeGetTabCount(hWnd:="")
{
	local
	static vAccPath := JEE_ChromeAccInit("T")
	if (hWnd = "")
		hWnd := WinExist("A")
	oAcc := Acc_Get("Object", vAccPath, 0, "ahk_id " hWnd)
	vCount := 0
	for _, oChild in Acc_Children(oAcc)
	{
		;ROLE_SYSTEM_PUSHBUTTON := 0x2B
		if (oChild.accRole(0) = 0x2B)
			continue
		vCount++
	}
	oAcc := oChild := ""
	return vCount
}

;==================================================

JEE_ChromeGetTabNames(hWnd:="", vSep:="`n")
{
	local
	static vAccPath := JEE_ChromeAccInit("T")
	if (hWnd = "")
		hWnd := WinExist("A")
	oAcc := Acc_Get("Object", vAccPath, 0, "ahk_id " hWnd)

	vHasSep := !(vSep = "")
	if vHasSep
		vOutput := ""
	else
		oOutput := []
	for _, oChild in Acc_Children(oAcc)
	{
		;ROLE_SYSTEM_PUSHBUTTON := 0x2B
		if (oChild.accRole(0) = 0x2B)
			continue
		try vTabText := oChild.accName(0)
		catch
			vTabText := ""
		if vHasSep
			vOutput .= vTabText vSep
		else
			oOutput.Push(vTabText)
	}
	oAcc := oChild := ""
	return vHasSep ? SubStr(vOutput, 1, -StrLen(vSep)) : oOutput
}

;==================================================

JEE_ChromeFocusTabByNum(hWnd:="", vNum:="")
{
	local
	static vAccPath := JEE_ChromeAccInit("T")
	if (hWnd = "")
		hWnd := WinExist("A")
	if !vNum
		return
	oAcc := Acc_Get("Object", vAccPath, 0, "ahk_id " hWnd)
	if !Acc_Children(oAcc)[vNum]
		vNum := ""
	else
		Acc_Children(oAcc)[vNum].accDoDefaultAction(0)
	oAcc := ""
	return vNum
}

;==================================================

JEE_ChromeFocusTabByName(hWnd:="", vTitle:="", vNum:="")
{
	local
	static vAccPath := JEE_ChromeAccInit("T")
	if (hWnd = "")
		hWnd := WinExist("A")
	if (vNum = "")
		vNum := 1
	oAcc := Acc_Get("Object", vAccPath, 0, "ahk_id " hWnd)
	vCount := 0, vRet := 0
	for _, oChild in Acc_Children(oAcc)
	{
		vTabText := oChild.accName(0)
		if (vTabText = vTitle)
			vCount++
		if (vCount = vNum)
		{
			oChild.accDoDefaultAction(0), vRet := A_Index
			break
		}
	}
	oAcc := oChild := ""
	return vRet
}

;==================================================

JEE_ChromeGetFocusedTabNum(hWnd:="")
{
	local
	static vAccPath := JEE_ChromeAccInit("T")
	if (hWnd = "")
		hWnd := WinExist("A")
	oAcc := Acc_Get("Object", vAccPath, 0, "ahk_id " hWnd)
	vRet := 0
	for _, oChild in Acc_Children(oAcc)
	{
		;STATE_SYSTEM_SELECTED := 0x2
		if (oChild.accState(0) & 0x2)
		{
			vRet := A_Index
			break
		}
	}
	oAcc := oChild := ""
	return vRet
}

;==================================================

JEE_ChromeAddressBarIsFoc(hWnd:="")
{
	local
	static vAccPath1 := JEE_ChromeAccInit("U1")
	static vAccPath2 := JEE_ChromeAccInit("U2")
	if (hWnd = "")
		hWnd := WinExist("A")
	oAcc := Acc_Get("Object", vAccPath1, 0, "ahk_id " hWnd)
	if !IsObject(oAcc)
	|| !(oAcc.accName(0) = "Address and search bar")
		oAcc := Acc_Get("Object", vAccPath2, 0, "ahk_id " hWnd)
	;STATE_SYSTEM_FOCUSED := 0x4
	vIsFoc := !!(oAcc.accState(0) & 0x4)
	oAcc := ""
	return vIsFoc
}

;==================================================

;vOpt: L (close tabs to the left)
;vOpt: R (close tabs to the right)
;vOpt: LR (close other tabs)
;vOpt: (blank) (close other tabs)
;vNum: specify a tab other than the focused tab
JEE_ChromeCloseOtherTabs(hWnd:="", vOpt:="", vNum:="")
{
	local
	static vAccPath := JEE_ChromeAccInit("T")
	if (hWnd = "")
		hWnd := WinExist("A")
	if (vNum = "")
		vNum := JEE_ChromeGetFocusedTabNum(hWnd)
	if (vOpt = "")
		vOpt := "LR"
	vDoCloseLeft := !!InStr(vOpt, "L")
	vDoCloseRight := !!InStr(vOpt, "R")

	oAcc := Acc_Get("Object", vAccPath, 0, "ahk_id " hWnd)
	vRet := 0
	oChildren := Acc_Children(oAcc)
	vIndex := oChildren.Length() + 1
	Loop % vIndex - 1
	{
		vIndex--
		oChild := oChildren[vIndex]
		;ROLE_SYSTEM_PUSHBUTTON := 0x2B
		if (oChild.accRole(0) = 0x2B)
			continue
		if (vIndex = vNum)
			continue
		if (vIndex > vNum) && !vDoCloseRight
			continue
		if (vIndex < vNum) && !vDoCloseLeft
			continue
		oChild2 := Acc_Children(oChild).4
		if (oChild2.accName(0) = "Close")
			oChild2.accDoDefaultAction(0)
		oChild2 := ""
	}
	oAcc := oChild := ""
	return vRet
}

;==================================================