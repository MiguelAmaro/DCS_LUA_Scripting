--***************************
-- Variables
--***************************
-- Airwing
--local playerLandAirwing = AIRWING:New("Warehouse Batumi", "Player Land Fighter Wing")
--playerLandAirwing:Start()
--playerLandAirwing:NewPayload()


-- Player
local player = nil


-- Friends
local friendCarrierGroup = GROUP:FindByName("Friendly Boats")


-- Enemy
local firstEnemy = true
local enemyPlane = SPAWN:New( "Enemy BFM #001" )
                        --:InitLimit(1, 5)
                        --:InitRandomizePosition( true, 200, 50 )
                        --:SpawnScheduled( 5, .5 )
                        
enemyPlane:HandleEvent( EVENTS.Kill )
      
local enemyNum       = 1
local enemyTemplates = {"Enemy BFM #001"       ,
                        "Enemy BFM #002"       ,
                        "Enemy BFM #003 2_Ship",
                        "Enemy BFM #004"       ,
                        "Enemy BFM #005"       ,
                        "Enemy BFM #006"
                       }
 
 -- Database
 local databaseHandle = DATABASE:New()
 databaseHandle:HandleEvent(EVENTS.PlayerEnterUnit)
                       
-- Zone Section
local zones = {--zoneBFM = ZONE_RADIUS:New("zoneBFM")
              }
local currentZone = nil
local inTransit   = true

local zoneHomeAirBase        = ZONE      :New("zoneHomeAirBase"       )
local zoneAntiShip           = ZONE      :New("zoneAntiShip"          )
local zoneBFM                = ZONE      :New("zoneBFM"               )
local zoneBombing            = ZONE      :New("zoneBombing"           )
local zoneHomeCarrier        = ZONE_GROUP:New("zoneHomeCarrier", friendCarrierGroup, 18000)
local zoneDefensivePerimeter = ZONE      :New("zoneDefensivePerimeter")


-- Music Section
---- Zone Music
local Music_zoneAirBase            = USERSOUND:New("afdx_AirBase.wav"           )
local Music_zoneAntiShip           = USERSOUND:New("afdx_AntiShip.wav"          )
local Music_zoneBFM                = USERSOUND:New("afdx_BFM.wav"               )
local Music_zoneBombing            = USERSOUND:New("afdx_Bombing.wav"           )
local Music_zoneHomeCarrier        = USERSOUND:New("afdx_Carrier.wav"           )
local Music_zoneDefensivePerimeter = USERSOUND:New("afdx_DefensivePerimeter.wav")
---- Logic Music
local Music_MissionSuccess         = USERSOUND:New("afdx_MissionCompleted.wav"  )
local Music_playerDied             = USERSOUND:New("afdx_MissionFailed.wav"     )
local Music_inTransit              = USERSOUND:New("afdx_InTransit.wav"         )
                              
--***************************
-- Function Definitions
--***************************
function SpawnEnemyPlane( newEnemyPlane )
  if enemyNum < 5 then
    enemyPlane = SPAWN:New( enemyTemplates[enemyNum] )
    enemyNum   = enemyNum + 1
  else
    Music_MissionSuccess:ToAll();
    enemyNum   = 0
  end
  enemyPlane:Spawn()
end

function ScanZones()
  if player ~= nil then
    if     player:IsInZone(zoneHomeAirBase         ) then currentZone = zoneHomeAirBase
    elseif player:IsInZone(zoneAntiShip            ) then currentZone = zoneAntiShip
    elseif player:IsInZone(zoneBFM                 ) then currentZone = zoneBFM
    elseif player:IsInZone(zoneBombing             ) then currentZone = zoneBombing
    elseif player:IsInZone(zoneHomeCarrier         ) then currentZone = zoneHomeCarrier
    elseif player:IsInZone(zoneDefensivePerimeter  ) then currentZone = zoneDefensivePerimeter
    else   currentZone = nil 
    end
  
    ZoneEntryAndExitHandler(currentZone)
  else
    MESSAGE:New("Player Var is nil" , 1,   "Debubg"):ToAll()
  end
end

function ZoneEntryAndExitHandler(currentZone) 
  local zoneName = "Some Zone" --currentZone:GetName()
  
    -- Handles Transitions
  if currentZone == nil then
    if inTransit == true then
       player:MessageToAll("You have left " .. zoneName, 3, "Zones")
       
       Music_inTransit:ToAll()
       inTransit = false
    else
       player:MessageToAll("Currently intransit", 1, "Debug") 
     
      -- DO NOTHING
    end
  elseif currentZone ~= nil then
    if inTransit == false then
      player:MessageToAll("You have entered " .. zoneName, 3, "Zones")
      
       if     currentZone == zoneHomeAirBase        then 
       Music_zoneAirBase:ToAll()
        
       elseif currentZone == zoneAntiShip           then 
       Music_zoneAntiShip:ToAll()
       
       elseif currentZone == zoneBFM                then 
       Music_zoneBFM:ToAll()
       SpawnEnemyPlane()
        
       elseif currentZone == zoneBombing            then 
       Music_zoneBombing:ToAll()
        
       elseif currentZone == zoneHomeCarrier        then 
       Music_zoneHomeCarrier:ToAll()
       
       elseif currentZone == zoneDefensivePerimeter then 
       Music_zoneDefensivePerimeter:ToAll()
       --player = SPAWN:New("Player F-16 DefensivePerimeter")
      end
      
      inTransit = true
    else
     player:MessageToAll("No longer intransit", 1, "Debug")
      -- DO NOTHING
    end
  end
end

--**************************
-- Start of Script
--**************************

--ZONE GAMEPLAY MARKERS
zoneHomeAirBase        :SmokeZone( SMOKECOLOR.Orange , 90 )
zoneAntiShip           :SmokeZone( SMOKECOLOR.Blue   , 90 )
zoneBFM                :SmokeZone( SMOKECOLOR.Green  , 90 )
zoneBombing            :SmokeZone( SMOKECOLOR.Red    , 90 )
zoneHomeCarrier        :SmokeZone( SMOKECOLOR.White  , 90 )
zoneDefensivePerimeter :SmokeZone( SMOKECOLOR.Red    , 90 )


MESSAGE:New("Welcome to the Bubbles Mission", 10, "Start Message 1"):ToAll()

Music_inTransit:ToAll()

--*************************
-- Schedulers
--*************************
zoneScanScheduler = SCHEDULER:New(nil, ScanZones, {}, 0, 2)

--*************************
-- Event Handlers
--*************************
function enemyPlane:OnEventKill         ( EventData )
    MESSAGE:New("You killed that son of a bitch!", 10, "Success"):ToAll()
    MESSAGE:New(   "Fuck here comes another one!", 10,   "Brief"):ToAll()
    SpawnEnemyPlane()
end  

function playerCrashEventHandler     ( EventData )
  player:MessageToAll("You died!", 10, "Failed")
  Music_playerDied:ToAll();
end

function databaseHandle:OnEventPlayerEnterUnit ( EventData )
  player = EventData.IniUnit
  player:MessageToAll("Current Unit : "  .. EventData.IniUnitName, 15,   "Debug")
  player:HandleEvent (EVENTS.Crash, playerCrashEventHandler)
end
