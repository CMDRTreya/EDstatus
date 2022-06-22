#SingleInstance, Force
; #KeyHistory, 0
; SetBatchLines, -1
; ListLines, Off
SendMode Input ; Forces Send and SendRaw to use SendInput buffering for speed.
; SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
SetWorkingDir, %A_ScriptDir%
; SplitPath, A_ScriptName, , , , thisscriptname
; #MaxThreadsPerHotkey, 1 ; no re-entrant hotkey handling
; DetectHiddenWindows, On
; SetWinDelay, -1 ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
; SetKeyDelay, -1, -1 ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
; SetMouseDelay, -1 ; Remove short delay done automatically after Click and MouseMove/Click/Drag

#Include %A_ScriptDir%\EDstatus.ahk
#Include *i <autoReload>


CustomColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Color, %CustomColor%
Gui, Margin,, -5
Gui, Font, q5 s10, Segoe UI

; Gui, Font, s32  ; Set a large font size (32-point).
; Gui, Add, Text, vMyText cYellow

Gui, Add, Text, w200 vLegalState cYellow y10
Gui, Add, Text, w200 vGuiFocus cYellow
Gui, Add, Text, w200 vFireGroup cYellow
Gui, Add, Text, w200 vFuelMain cYellow
Gui, Add, Text, w200 vFuelReservoir cYellow
Gui, Add, Text, w200 vCargo cYellow
Gui, Add, Text, w200 vBodyName cYellow
Gui, Add, Text, w200 vHeading cYellow
Gui, Add, Text, w200 vAltitude cYellow
Gui, Add, Text, w200 vLatitude cYellow
Gui, Add, Text, w200 vLongitude cYellow
Gui, Add, Text, w200 vPlanetRadius cYellow
Gui, Add, Text, w200 vpipSYS cYellow
Gui, Add, Text, w200 vpipENG cYellow
Gui, Add, Text, w200 vpipWEP cYellow
Gui, Add, Text, w200 vFlags cYellow y10 R40


; Make all pixels of this color transparent and make the text itself translucent (150):
WinSet, TransColor, %CustomColor% 150


SetTimer, UpdateOSD, 100
Gosub, UpdateOSD  ; Make the first update immediate rather than waiting for the timer.

Gui, Show, xCenter y0 NoActivate  ; NoActivate avoids deactivating the currently active window.
; WinGetPos, , , Width
; xPos := (A_ScreenWidth - Width) / 2
; WinMove, , , %xPos%, -32
return

UpdateOSD:
foo := EDstatus.LegalState
GuiControl,, LegalState, LegalState: %foo%

foo := EDstatus.BodyName
GuiControl,, BodyName, BodyName: %foo%

foo := EDstatus.GuiFocus
GuiControl,, GuiFocus, GUIFocus: %foo%

foo := EDstatus.Heading
GuiControl,, Heading, Heading: %foo%

foo := EDstatus.Altitude
GuiControl,, Altitude, Altitude: %foo%

foo := EDstatus.FireGroup
GuiControl,, FireGroup, FireGroup: %foo%

foo := EDstatus.FuelMain
GuiControl,, FuelMain, FuelMain: %foo%

foo := EDstatus.Cargo
GuiControl,, Cargo, Cargo: %foo%

foo := EDstatus.Latitude
GuiControl,, Latitude, Latitude: %foo%

foo := EDstatus.Longitude
GuiControl,, Longitude, Longitude: %foo%

foo := EDstatus.PlanetRadius
GuiControl,, PlanetRadius, PlanetRadius: %foo%

foo := EDstatus.FuelReservoir
GuiControl,, FuelReservoir, FuelReservoir: %foo%

foo := EDstatus.pips.SYS
GuiControl,, pipSYS, SYS: %foo%

foo := EDstatus.pips.ENG
GuiControl,, pipENG, ENG: %foo%

foo := EDstatus.pips.WEP
GuiControl,, pipWEP, WEP: %foo%

bar := "Flags: " . EDstatus.Flags.raw . "`n"
if (EDstatus.Flags.Docked)
    bar .= "Docked" . "`n"
if (EDstatus.Flags.Landed)
    bar .= "Landed" . "`n"
if (EDstatus.Flags.LandingGearDown)
    bar .= "LandingGearDown" . "`n"
if (EDstatus.Flags.ShieldsUp)
    bar .= "ShieldsUp" . "`n"
if (EDstatus.Flags.Supercruise)
    bar .= "Supercruise" . "`n"
if (EDstatus.Flags.FlightAssistOff)
    bar .= "FlightAssistOff" . "`n"
if (EDstatus.Flags.HardpointsDeployed)
    bar .= "HardpointsDeployed" . "`n"
if (EDstatus.Flags.InWing)
    bar .= "InWing" . "`n"
if (EDstatus.Flags.LightsOn)
    bar .= "LightsOn" . "`n"
if (EDstatus.Flags.CargoScoopDeployed)
    bar .= "CargoScoopDeployed" . "`n"
if (EDstatus.Flags.SilentRunning)
    bar .= "SilentRunning" . "`n"
if (EDstatus.Flags.ScoopingFuel)
    bar .= "ScoopingFuel" . "`n"
if (EDstatus.Flags.SrvHandbrake)
    bar .= "SrvHandbrake" . "`n"
if (EDstatus.Flags.SrvUsingTurretView)
    bar .= "SrvUsingTurretView" . "`n"
if (EDstatus.Flags.SrvTurretRetracted)
    bar .= "SrvTurretRetracted" . "`n"
if (EDstatus.Flags.SrvDriveAssist)
    bar .= "SrvDriveAssist" . "`n"
if (EDstatus.Flags.FsdMassLocked)
    bar .= "FsdMassLocked" . "`n"
if (EDstatus.Flags.FsdCharging)
    bar .= "FsdCharging" . "`n"
if (EDstatus.Flags.FsdCooldown)
    bar .= "FsdCooldown" . "`n"
if (EDstatus.Flags.LowFuel)
    bar .= "LowFuel" . "`n"
if (EDstatus.Flags.OverHeating)
    bar .= "OverHeating" . "`n"
if (EDstatus.Flags.HasLatLong)
    bar .= "HasLatLong" . "`n"
if (EDstatus.Flags.IsInDanger)
    bar .= "IsInDanger" . "`n"
if (EDstatus.Flags.BeingInterdicted)
    bar .= "BeingInterdicted" . "`n"
if (EDstatus.Flags.InMainShip)
    bar .= "InMainShip" . "`n"
if (EDstatus.Flags.InFighter)
    bar .= "InFighter" . "`n"
if (EDstatus.Flags.InSRV)
    bar .= "InSRV" . "`n"
if (EDstatus.Flags.HudInAnalysisMode)
    bar .= "HudInAnalysisMode" . "`n"
if (EDstatus.Flags.NightVision)
    bar .= "NightVision" . "`n"
if (EDstatus.Flags.AltitudeFromAverageRadius)
    bar .= "AltitudeFromAverageRadius" . "`n"
if (EDstatus.Flags.FSDJump)
    bar .= "FSDJump" . "`n"
if (EDstatus.Flags.SRVHighBeam)
    bar .= "SRVHighBeam" . "`n"

GuiControl,, Flags, %bar%
return
