
CapsLock & i::showTextInBox("Hello OSD")
CapsLock & o::showOsd("Hello OSD")

showOsd(textToShow) {
    ;Gui,  destroy
    CustomColor = 000000  ; Can be any RGB color (it will be made transparent below). 
    Gui, +AlwaysOnTop +LastFound +Owner -Caption
    Gui, Color, %CustomColor% 
    Gui, Font, cFFFFFF S42, Verdana


    ;Gui, Add, Text, x2 y2 c000000 BackgroundTrans, %textToShow%
    Gui, Add, Text, x0 y0 cLime BackgroundTrans, %textToShow% 
    
    ; Make all pixels of this color transparent and make the text itself translucent (150): 
    WinSet, TransColor, %CustomColor% 150 
    WinSet, ExStyle, +0x20, Output
    Gui,  Show, center center NoActivate, output
    Sleep, 2000
    Gui,  destroy   ; closes the 1st Gui window

}

; OSD(text)
; {
; 	#Persistent
; 	; borderless, no progressbar, font size 25, color text 009900
; 	Progress, hide Y600 W1000 b zh0 cwFFFFFF FM50 CT00BB00,, %text%, AutoHotKeyProgressBar, Backlash BRK
; 	WinSet, TransColor, FFFFFF 255, AutoHotKeyProgressBar
; 	Progress, show, center center
; 	SetTimer, RemoveToolTip, 3000

; 	Return


; RemoveToolTip:
; 	SetTimer, RemoveToolTip, Off
; 	Progress, Off
; 	return
; }

showTextInBox(textToShow) {
;Gui, +ToolWindow -Caption +AlwaysOnTop +Disabled
    CustomColor = 000000  ; Can be any RGB color (it will be made transparent below). 
Gui, +AlwaysOnTop +LastFound +Owner -Caption
Gui, Color, %CustomColor% 
Gui, Font, cFFFFFF S42, Verdana

    Gui, add, Text, center center x2 y2 c000000 BackgroundTrans, %textToShow%
    Gui, add, Text, center center x0 y0 cLime BackgroundTrans, %textToShow%
 
;Gui, Show, center center NoActivate, Output
;WinSet, Region, 0-0 H111 W600 R30-30, Output
;WinSet, ExStyle, +0x20, Output

WinSet, TransColor, %CustomColor%  250
WinSet, ExStyle, +0x20, Output
Gui, Show, center center NoActivate , Output
;WinSet, Region, 0-0 H211 W800 R30-30, Output
;WinSet, ExStyle, +0x20, Output

Loop,60
 {
 If A_Index = 1
  {
  WinSet, Transparent, 180, Output
  Sleep 600
  }
 Else If A_Index = 60
  {
  Gui, Destroy
  Break
  }
 Else
  {
  TransFade := 180 - A_Index*2
  WinSet, Transparent, %TransFade%, Output
  Sleep 1
  }
 }
Return
}