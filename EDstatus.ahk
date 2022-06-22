
#Persistent

/* From Journal Docs v3.4.26 page 73f (http://hosting.zaonce.net/community/journal/v26/Journal-Manual-v26.pdf)

    Parameters:
        Flags: multiple flags encoded as bits in an integer (see below)
        Pips: an array of 3 integers representing energy distribution (in half-pips)
        Firegroup: the currently selected firegroup number
        GuiFocus: the selected GUI screen
        Fuel: { FuelMain, FuelReservoir} – both mass in tons
        Cargo: mass in tons
        LegalState
        Latitude (if on or near a planet)
        Altitude
        Longitude
        Heading
        BodyName
        PlanetRadius

    LegalState: one of:
        "Clean",
        "IllegalCargo",
        "Speeding",
        "Wanted",
        "Hostile",
        "PassengerWanted",
        "Warrant"

    GuiFocus values:
         0 NoFocus
         1 InternalPanel (right hand side)
         2 ExternalPanel (left hand side)
         3 CommsPanel (top)
         4 RolePanel (bottom)
         5 StationServices
         6 GalaxyMap
         7 SystemMap
         8 Orrery
         9 FSS mode
        10 SAA mode
        11 Codex 

    Flags:
         Bit      Value         Hex       Meaning
         0            1      0000 0001    Docked, (on a landing pad)
         1            2      0000 0002    Landed, (on planet surface)
         2            4      0000 0004    Landing Gear Down
         3            8      0000 0008    Shields Up
         4           16      0000 0010    Supercruise
         5           32      0000 0020    FlightAssist Off
         6           64      0000 0040    Hardpoints Deployed
         7          128      0000 0080    In Wing
         8          256      0000 0100    Lights On
         9          512      0000 0200    Cargo Scoop Deployed
        10         1024      0000 0400    Silent Running
        11         2048      0000 0800    Scooping Fuel
        12         4096      0000 1000    Srv Handbrake
        13         8192      0000 2000    Srv using Turret view
        14        16384      0000 4000    Srv Turret retracted (close to ship)
        15        32768      0000 8000    Srv DriveAssist
        16        65536      0001 0000    Fsd MassLocked
        17       131072      0002 0000    Fsd Charging 
        18       262144      0004 0000    Fsd Cooldown
        19       524288      0008 0000    Low Fuel ( < 25% )
        20      1048576      0010 0000    Over Heating ( > 100% )
        21      2097152      0020 0000    Has Lat Long
        22      4194304      0040 0000    Is In Danger
        23      8388608      0080 0000    Being Interdicted
        24     16777216      0100 0000    In MainShip
        25     33554432      0200 0000    In Fighter
        26     67108864      0400 0000    In SRV
        27    134217728      0800 0000    Hud in Analysis mode
        28    268435456      1000 0000    Night Vision
        29    536870912      2000 0000    Altitude from Average radius
        30   1073741824      4000 0000    fsdJump
        31   2147483648      8000 0000    srvHighBeam 

    { "timestamp":"2019-09-28T12:48:06Z", "event":"Status", "Flags":69730568, "Pips":[0,4,8], "FireGroup":0, "GuiFocus":0, "Fuel":{ "FuelMain":0.000000, "FuelReservoir":0.431156 }, "Cargo":1.000000, "LegalState":"Clean", "Latitude":-48.290974, "Longitude":-24.233133, "Heading":340, "Altitude":0, "BodyName":"Synuefe YG-J d10-90 6", "PlanetRadius":5109385.000000 }

    The latitude or longitude need to change by 0.02 degrees to trigger an update when flying, or by 0.0005 degrees when in the SRV
    If the bit29 is set, the altitude value is based on the planet’s average radius (used at higher altitudes)
    If the bit29 is not set, the Altitude value is based on a raycast to the actual surface below the ship/srv 
*/

parseStatusFile()
{
    ; ensure we update EDStatus uninterrupted
    Critical
    ; obtain static file handle so we don't have to reopen on every invocation
    static statusFile := FileOpen(getStatusFilePath(), "r")

    static needleFlags          := """Flags"":"         , needleFlagsLen            := StrLen(needleFlags)
    static needleFireGroup      := """FireGroup"":"     , needleFireGroupLen        := StrLen(needleFireGroup)
    static needleGuiFocus       := """GuiFocus"":"      , needleGuiFocusLen         := StrLen(needleGuiFocus)
    static needleFuelMain       := """FuelMain"":"      , needleFuelMainLen         := StrLen(needleFuelMain)
    static needleFuelReservoir  := """FuelReservoir"":" , needleFuelReservoirLen    := StrLen(needleFuelReservoir)
    static needleCargo          := """Cargo"":"         , needleCargoLen            := StrLen(needleCargo)
    static needleLatitude       := """Latitude"":"      , needleLatitudeLen         := StrLen(needleLatitude)
    static needleLongitude      := """Longitude"":"     , needleLongitudeLen        := StrLen(needleLongitude)
    static needleHeading        := """Heading"":"       , needleHeadingLen          := StrLen(needleHeading)
    static needleAltitude       := """Altitude"":"      , needleAltitudeLen         := StrLen(needleAltitude)
    static needlePlanetRadius   := """PlanetRadius"":"  , needlePlanetRadiusLen     := StrLen(needlePlanetRadius)
    ; the following have slightly different patterns to the above
    static needlePips           := """Pips"":["         , needlePipsLen             := StrLen(needlePips)
    static needleLegalState     := """LegalState"":"""  , needleLegalStateLen       := StrLen(needleLegalState)
    static needleBodyName       := """BodyName"":"""    , needleBodyNameLen         := StrLen(needleBodyName)

    statusFile.Seek(56, 0) ; set file pointer to skip timestamp and event entries at the beginning of line
    content := statusFile.ReadLine()
    ; example content taken from Journal Docs v3.4
    ; enable for testing
    ; content = { "timestamp":"2017-12-07T12:03:14Z", "event":"Status", "Flags":18874376, "Pips":[4,8,0], "FireGroup":0,"Fuel":{ "FuelMain":15.146626, "FuelReservoir":0.382796 }, "GuiFocus":0, "Latitude":-28.584963,"Longitude":6.826313, "Heading":109, "Altitude": 404 } 

    ; replace last 4 chars " }`r`n" in content with ","
    ; this simplifies the parser which now doesn't have to treat the last element any different
    content := SubStr(content, 1, -4) . ","

    ; TODO check timestamp and return if no change (status.json doesn't get written that often)
    ; TODO reset EDstatus entries that are invalid/absent (e.g. remove lat/lon/heading if EDstatus.HasLatLong is false)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; FORMAT: UInt of var length
    ; STRAT: read up to pos of next ','
    ; "Flags":69730568,
    pos := InStr(content, needleFlags)
    if (pos) {
          start := pos + needleFlagsLen
        , count := InStr(content, ",", false, start) - start
        , EDStatus.Flags.raw := SubStr(content, start, count)
    }
    ; "GuiFocus":0,
    pos := InStr(content, needleGuiFocus)
    if (pos) {
          start := pos + needleGuiFocusLen
        , count := InStr(content, ",", false, start) - start
        , EDStatus.GuiFocus := SubStr(content, start, count)
    }
    ; "Heading":340,
    pos := InStr(content, needleHeading)
    if (pos) {
          start := pos + needleHeadingLen
        , count := InStr(content, ",", false, start) - start
        , EDStatus.Heading := SubStr(content, start, count)
    }
    ; "Altitude":0,
    pos := InStr(content, needleAltitude)
    if (pos) {
          start := pos + needleAltitudeLen
        , count := InStr(content, ",", false, start) - start
        , EDStatus.Altitude := SubStr(content, start, count)
    }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; FORMAT: 3 single digits, separated by ','
    ; STRAT: read next 5 chars, copy chars 1, 3 and 5 to EDStatus.Pips.XXX
    ; "Pips":[0,4,8], 
    pos := InStr(content, needlePips)
    if (pos) {
          start := pos + needlePipsLen
        , EDStatus.Pips.SYS := SubStr(content, start, 1)
        , EDStatus.Pips.ENG := SubStr(content, start+2, 1)
        , EDStatus.Pips.WEP := SubStr(content, start+4, 1)
    }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; FORMAT: String ending on '"'
    ; ASSUMPTION: Strings from ED don't contain '"'
    ; STRAT: read up to pos of next '"'
    ; "LegalState":"Clean", 
    pos := InStr(content, needleLegalState)
    if (pos) {
          start := pos + needleLegalStateLen
        , count := InStr(content, """", false, start) - start
        , EDStatus.LegalState := SubStr(content, start, count)
    }
    ; "BodyName":"Synuefe YG-J d10-90 6", 
    pos := InStr(content, needleBodyName)
    if (pos) {
          start := pos + needleBodyNameLen
        , count := InStr(content, """", false, start) - start
        , EDStatus.BodyName := SubStr(content, start, count)
    }
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; FORMAT: single digit as ED has less than 10 FireGroups max
    ; STRAT: read next char
    ; "FireGroup":0, 
    pos := InStr(content, needleFireGroup)
    if (pos) {
        EDStatus.FireGroup := SubStr(content, pos + needleFireGroupLen, 1)
    }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; FORMAT: floating point value with fixed length
    ; STRAT: read up to pos of next "." +7 (6 digits plus the '.')
    ; "FuelMain":0.000000, 
    pos := InStr(content, needleFuelMain)
    if (pos) {
          start := pos + needleFuelMainLen
        , count := InStr(content, ".", false, start) - start
        , EDStatus.FuelMain := SubStr(content, start, count+7)
    }
    ; "Cargo":1.000000,  
    pos := InStr(content, needleCargo)
    if (pos) {
          start := pos + needleCargoLen
        , count := InStr(content, ".", false, start) - start
        , EDStatus.Cargo := SubStr(content, start, count+7)
    }
    ; "Latitude":-48.290974,   
    pos := InStr(content, needleLatitude)
    if (pos) {
          start := pos + needleLatitudeLen
        , count := InStr(content, ".", false, start) - start
        , EDStatus.Latitude := SubStr(content, start, count+7)
    }
    ; "Longitude":-24.233133,   
    pos := InStr(content, needleLongitude)
    if (pos) {
          start := pos + needleLongitudeLen
        , count := InStr(content, ".", false, start) - start
        , EDStatus.Longitude := SubStr(content, start, count+7)
    }
    ; "PlanetRadius":5109385.000000,   
    pos := InStr(content, needlePlanetRadius)
    if (pos) {
          start := pos + needlePlanetRadiusLen
        , count := InStr(content, ".", false, start) - start
        , EDStatus.PlanetRadius := SubStr(content, start, count+7)
    }
    ; "FuelReservoir":0.431156 },   
    pos := InStr(content, needleFuelReservoir)
    if (pos) {
          start := pos + needleFuelReservoirLen
        , count := InStr(content, ".", false, start) - start
        , EDStatus.FuelReservoir := SubStr(content, start, count+7)
    }
}

; normally this would go into the parseStatusFile body
; isolated here for slight improvement in execution speed
; KEEP THIS PHYSICALLY BELOW parseStatusFile() SO THE FILE HANDLE IS OBTAINED BEFORE THE BOOTSTRAPPER KICKS IN
bootstrap()
{
    ; assert version [v1.0.90+]: needed for bootstrapping to work
    static started := bootstrap()
    if (not started)
    {
        ; assert [v1.1.20+]: needed for SetTimer to accept function names - might work as a general canary for bootstrapping?
        SetTimer, parseStatusFile, 100
        return True
    }
}

getStatusFilePath()
{
    ; C:\Users\Maya\Saved Games\Frontier Developments\Elite Dangerous
    EnvGet, path, USERPROFILE
    return path . "\Saved Games\Frontier Developments\Elite Dangerous\Status.json"
}

; printHelp() {
;     static bar = printHelp()
;     MsgBox, % EDstatus.getAttributeList()
;     ExitApp
; }

; The return value of get or set becomes the result of the sub-expression which invoked the property. For example, val := obj.Property := 42 stores the return value of set in val.
; If set is not defined and is not handled by a meta-function or base class, assigning a value stores it in the object, effectively disabling the property.
; An alternate, single-line method to retrieve the script's PID is PID := DllCall("GetCurrentProcessId") - use with postMessage() and onMessage()
class EDStatus {

    getAttributeList() {
        
    static bar = this.getAttributeList()
        For key in this {
            foo .= key . "`n"
        }
    MsgBox, % EDstatus.getAttributeList()
        return foo
    }
    
    class Pips {
        static SYS := 0
        static ENG := 0
        static WEP := 0
    }

    static LegalState := ""
    static BodyName := ""

    static GuiFocus := 0
    static Heading := 0
    static Altitude := 0
    static FireGroup := 0
    
    static FuelMain := 0.0
    static Cargo := 0.0
    static Latitude := 0.0
    static Longitude := 0.0
    static PlanetRadius := 0.0
    static FuelReservoir := 0.0
    
    class Flags {
        
        static raw := 0

        Docked {
            get {
                return this.raw & 0x00000001 != 0
            }
            set {
                return 0
            }
        }
        Landed {
            get {
                return this.raw & 0x00000002 != 0
            }
            set {
                return 0
            }
        }
        LandingGearDown {
            get {
                return this.raw & 0x00000004 != 0
            }
            set {
                return 0
            }
        }
        ShieldsUp {
            get {
                return this.raw & 0x00000008 != 0
            }
            set {
                return 0
            }
        }
        Supercruise {
            get {
                return this.raw & 0x00000010 != 0
            }
            set {
                return 0
            }
        }
        FlightAssistOff {
            get {
                return this.raw & 0x00000020 != 0
            }
            set {
                return 0
            }
        }
        HardpointsDeployed {
            get {
                return this.raw & 0x00000040 != 0
            }
            set {
                return 0
            }
        }
        InWing {
            get {
                return this.raw & 0x00000080 != 0
            }
            set {
                return 0
            }
        }
        LightsOn {
            get {
                return this.raw & 0x00000100 != 0
            }
            set {
                return 0
            }
        }
        CargoScoopDeployed {
            get {
                return this.raw & 0x00000200 != 0
            }
            set {
                return 0
            }
        }
        SilentRunning {
            get {
                return this.raw & 0x00000400 != 0
            }
            set {
                return 0
            }
        }
        ScoopingFuel {
            get {
                return this.raw & 0x00000800 != 0
            }
            set {
                return 0
            }
        }
        SrvHandbrake {
            get {
                return this.raw & 0x00001000 != 0
            }
            set {
                return 0
            }
        }
        SrvUsingTurretView {
            get {
                return this.raw & 0x00002000 != 0
            }
            set {
                return 0
            }
        }
        SrvTurretRetracted {
            get {
                return this.raw & 0x00004000 != 0
            }
            set {
                return 0
            }
        }
        SrvDriveAssist {
            get {
                return this.raw & 0x00008000 != 0
            }
            set {
                return 0
            }
        }
        FsdMassLocked {
            get {
                return this.raw & 0x00010000 != 0
            }
            set {
                return 0
            }
        }
        FsdCharging {
            get {
                return this.raw & 0x00020000 != 0
            }
            set {
                return 0
            }
        }
        FsdCooldown {
            get {
                return this.raw & 0x00040000 != 0
            }
            set {
                return 0
            }
        }
        LowFuel {
            get {
                return this.raw & 0x00080000 != 0
            }
            set {
                return 0
            }
        }
        OverHeating {
            get {
                return this.raw & 0x00100000 != 0
            }
            set {
                return 0
            }
        }
        HasLatLong {
            get {
                return this.raw & 0x00200000 != 0
            }
            set {
                return 0
            }
        }
        IsInDanger {
            get {
                return this.raw & 0x00400000 != 0
            }
            set {
                return 0
            }
        }
        BeingInterdicted {
            get {
                return this.raw & 0x00800000 != 0
            }
            set {
                return 0
            }
        }
        InMainShip {
            get {
                return this.raw & 0x01000000 != 0
            }
            set {
                return 0
            }
        }
        InFighter {
            get {
                return this.raw & 0x02000000 != 0
            }
            set {
                return 0
            }
        }
        InSRV {
            get {
                return this.raw & 0x04000000 != 0
            }
            set {
                return 0
            }
        }
        HudInAnalysisMode {
            get {
                return this.raw & 0x08000000 != 0
            }
            set {
                return 0
            }
        }
        NightVision {
            get {
                return this.raw & 0x10000000 != 0
            }
            set {
                return 0
            }
        }
        AltitudeFromAverageRadius {
            get {
                return this.raw & 0x20000000 != 0
            }
            set {
                return 0
            }
        }
        FSDJump {
            get {
                return this.raw & 0x40000000 != 0
            }
            set {
                return 0
            }
        }
        SRVHighBeam {
            get {
                return this.raw & 0x80000000 != 0
            }
            set {
                return 0
            }
        }
    }
}
