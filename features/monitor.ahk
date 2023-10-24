#SingleInstance Force
#NoEnv
SendMode Input
SetTitleMatchMode 2
global PRESETS := Array("Standard", "Multimedia", "Movie", "Game", "Text", "Warm", "Cool")
global presetIndex := 1
global INPUTS := Array("VGA", "DVI-D", "DisplayPort")
global inputIndex := 1
global brightnessLevel := 75
global contrastLevel := 75
global redLevel := 100
global greenLevel := 100
global blueLevel := 100

#F1::decBrightness()
#F2::incBrightness()
#F3::decContrast()
#F4::incContrast()
#F5::restoreDefaults()
#F6::restoreLevelDefaults()
#F7::restoreColorDefaults()
#F8::decRedLevel()
#F9::incRedLevel()
^#F8::decGreenLevel()
^#F9::incGreenLevel()
+#F8::decBlueLevel()
+#F9::incBlueLevel()
#F10::setNamedPreset()
#F11::setActiveInput()


;
; /SetControl 18 - green
; /SetControl 16 - red
; /SetControl 1A - blue
; ddm /SetControl 04 10 - looks like reset color settings
; ddm /SetControl 06 10 - does something

setNamedPreset() {
	global PRESETS, presetIndex
	currentPreset := PRESETS[presetIndex]
	execCommand("/SetNamedPreset " . currentPreset)
	showMonitorInfo("Preset:" . currentPreset)
	presetIndex := (presetIndex + 1)
	if (presetIndex > PRESETS.Length()) {
		presetIndex := 1
	}
}

; not working for some reason
setActiveInput() {
	global INPUTS, inputIndex
	currentInput := INPUTS[inputIndex]
	execCommand("/SetActiveInput " . currentInput)
	showMonitorInfo("Input:" . currentInput)
	inputIndex := (inputIndex + 1)
	if (inputIndex > INPUTS.Length()) {
		inputIndex := 1
	}
}

restoreColorDefaults() {
	execCommand(" /RestoreColorDefaults ")
	showMonitorInfo("Restore Color Defaults")
}

restoreLevelDefaults() {
	execCommand(" /RestoreLevelDefaults")
	showMonitorInfo("Restore Level Defaults")
}

restoreDefaults() {
	execCommand(" /RestoreFactoryDefaults ")
	showMonitorInfo("Restore Defaults")
}


decRedLevel() {
	global redLevel
	decValue(redLevel, "Control 16")
}

incRedLevel() {
	global redLevel
	incValue(redLevel, "Control 16")
}

decGreenLevel() {
	global greenLevel
	decValue(greenLevel, "Control 18")
}

incGreenLevel() {
	global greenLevel
	incValue(greenLevel, "Control 18")
}

decBlueLevel() {
	global blueLevel
	decValue(blueLevel, "Control 1A")
}

incBlueLevel() {
	global blueLevel
	incValue(blueLevel, "Control 1A")
}


incContrast() {
	global contrastLevel
	incValue(contrastLevel, "ContrastLevel")
}

decContrast() {
	global contrastLevel
	decValue(contrastLevel, "ContrastLevel")
}

incBrightness() {
	global brightnessLevel
	incValue(brightnessLevel, "BrightnessLevel")
}

decBrightness() {
	global brightnessLevel
	decValue(brightnessLevel, "BrightnessLevel")
}

incValue(ByRef optionValue, option) {
	if(optionValue < 100) {
		optionValue := optionValue + 5
	} else {
		showShowOptionValueInfo(optionValue, option)
		return
	}
	updateOptionValue(optionValue, option)
}

decValue(ByRef optionValue, option) {
	if (optionValue >= 5) {
		optionValue := optionValue - 5
	} else {
		showShowOptionValueInfo(optionValue, option)
		return
	}
	updateOptionValue(optionValue, option)
}

updateOptionValue(optionValue, option) {

	command := " /Set" . option . " " . optionValue
	execCommand(command)
	
	showShowOptionValueInfo(optionValue, option)
}

execCommand(command) {
; Start the process to set the brightness level
Run, "ddm.exe " .  %command%
}

showShowOptionValueInfo(optionValue, option) {
	showMonitorInfo( option . ":" . optionValue)
}


showMonitorInfo(textToShow) {
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

