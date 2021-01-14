/*
  bug.n -- tiling window management
  Copyright (c) 2010-2019 Joshua Fuhs, joten

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  @license GNU General Public License version 3
           ../LICENSE.md or <http://www.gnu.org/licenses/>

  @version 9.0.2
*/

ResourceMonitor_bytesToString(b) {
  If (b > 1047527424) {
    b /= 1024 * 1024 * 1024
    unit := "GB"
  } Else If (b > 1022976) {
    b /= 1024 * 1024
    unit := "MB"
  } Else If (b > 999) {
    b /= 1024
    unit := "kB"
  } Else {
    unit := " B"
  }
  b := Round(b, 1)
  If (b > 99.9 Or unit = " B")
    b := Round(b, 0)
  Return, SubStr("    " b, -3) . unit
}

ResourceMonitor_getBatteryStatus(ByRef batteryLifePercent, ByRef acLineStatus) {
  VarSetCapacity(powerStatus, (1 + 1 + 1 + 1 + 4 + 4))
  success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
  If (ErrorLevel != 0 Or success = 0) {
    MsgBox 16, Power Status, Can't get the power status...
    Return
  }
  acLineStatus       := NumGet(powerStatus, 0, "Char")
  batteryLifePercent := NumGet(powerStatus, 2, "Char")

  If acLineStatus = 0
    acLineStatus = off
  Else If acLineStatus = 1
    acLineStatus = on
  Else If acLineStatus = 255
    acLineStatus = ?

  If batteryLifePercent = 255
    batteryLifePercent = ???
}
;; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)

ResourceMonitor_getMemoryUsage() {
  VarSetCapacity(memoryStatus, 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4)
  DllCall("kernel32.dll\GlobalMemoryStatus", "UInt", &memoryStatus)
  Return, SubStr("  " Round(*(&memoryStatus + 4)), -2)    ;; LS byte is enough, 0..100
}
;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)

CPULoad() { ; By SKAN, CD:22-Apr-2014 / MD:05-May-2014. Thanks to ejor, Codeproject: http://goo.gl/epYnkO
Static PIT, PKT, PUT                           ; http://ahkscript.org/boards/viewtopic.php?p=17166#p17166
  IfEqual, PIT,, Return 0, DllCall( "GetSystemTimes", "Int64P",PIT, "Int64P",PKT, "Int64P",PUT )

  DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
, IdleTime := PIT - CIT,    KernelTime := PKT - CKT,    UserTime := PUT - CUT
, SystemTime := KernelTime + UserTime 

Return ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    PIT := CIT,    PKT := CKT,    PUT := CUT 
} 

ResourceMonitor_getText() {
  Global Config_readinCpu, Config_readinDiskLoad, Config_readinMemoryUsage, Config_readinNetworkLoad

  text := ""
  text .= " CPU: " CPULoad() "% "
  text .= "`n"
  text .= " RAM: " ResourceMonitor_getMemoryUsage() "% "
  text .= "`n"
  ResourceMonitor_getBatteryStatus(batteryPercentage, chargingStatus)
  text .= " Battery: " batteryPercentage "% | : Charging: " chargingStatus " "
  Return, text
}
