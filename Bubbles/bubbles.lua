--***************************
-- Variables
--***************************
-- Player
local player = CLIENT:FindByName("Player #002")
player:HandleEvent( EVENTS.Crash )

-- Enemy
local firstEnemy = true
local enemyPlane = SPAWN:New( "enemy Template #001" )
                        :InitLimit(1, 5)
                        :InitRandomizePosition( true, 200, 50 )
                        :SpawnScheduled( 5, .5 )
                        
enemyPlane:HandleEvent( EVENTS.Crash )
      
local enemyNum   = 1
local enemyTemplates = {"enemy Template #001",
                        "enemy Template #002",
                        "enemy Template #003",
                        "enemy Template #004",
                        "enemy Template #005",
                        "enemy Template #006"
                       }
                       
-- Zone Section
local zones = {--zoneBFM = ZONE_RADIUS:New("zoneBFM")
              }

local zoneHomeAirBase        = ZONE:New("zoneHomeBase"          )
local zoneAntiShip           = ZONE:New("zoneAntiShip"          )
local zoneBFM                = ZONE:New("zoneBFM"               )
local zoneBombing            = ZONE:New("zoneBombing"           )
--local zoneHomeCarrier            = ZONE:New("zoneCarrier"           )
local zoneDefensivePerimeter = ZONE:New("zoneDefensivePerimeter")


-- Music Section
---- Zone Music
local Music_zoneAirBase            = USERSOUND:New("afdx_AirBase.wav"           )
local Music_zoneAntiShip           = USERSOUND:New("afdx_AntiShip.wav"          )
local Music_zoneBFM                = USERSOUND:New("afdx_BFM.wav"               )
local Music_zoneBombing            = USERSOUND:New("afdx_Bombing.wav"           )
local Music_zoneCarrier            = USERSOUND:New("afdx_Carrier.wav"           )
local Music_zoneDefensivePerimeter = USERSOUND:New("afdx_DefensivePerimeter.wav")
---- Logic Music
--local Music_MissionSuccess         = USERSOUND:New("afdx_MissionCompleted.wav"  )
local Music_playerDied             = USERSOUND:New("afdx_MissionFailed.wav"     )
local Music_inTransit              = USERSOUND:New("afdx_Select.wav"            )

-- Schedulers


                                 
--***************************
-- Function Definitions
--***************************
function SpawnEnemyPlane( newEnemyPlane )
  enemyPlane:Spawn()
  enemyNum = enemyNum + 1
end

local currentZone = nil
local inTransit   = true

function ScanZones()
  if     player:IsInZone(zoneHomeAirBase         ) then currentZone = zoneHomeAirBase
 elseif player:IsInZone(zoneAntiShip             ) then currentZone = zoneAntiShip
  elseif player:IsInZone(zoneBFM                 ) then currentZone = zoneBFM
  elseif player:IsInZone(zoneBombing             ) then currentZone = zoneBombing
--  elseif player:IsInZone(zoneHomeCarrier             ) then currentZone = zoneHomeCarrier
  elseif player:IsInZone(zoneDefensivePerimeter  ) then currentZone = zoneDefensivePerimeter
  else   currentZone = nil 
  end
  
  ZoneEntryAndExitHandler(currentZone)
  
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
      
      if     currentZone == zoneHomeAirBase         then 
       Music_zoneAirBase:ToAll()
        
       elseif currentZone == zoneAntiShip           then 
       Music_zoneAntiShip:ToAll()
       
       elseif currentZone == zoneBFM                then 
       Music_zoneBFM:ToAll()
       SpawnEnemyPlane()
        
       elseif currentZone == zoneBombing            then 
       Music_zoneBombing:ToAll()
       --local payload = player:GetTemplatePayload()
        
--      elseif currentZone == zoneHomeCarrier            then 
--       Music_zoneCarrier:ToAll()
       
      elseif currentZone == zoneDefensivePerimeter then 
       Music_zoneDefensivePerimeter:ToAll()
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
--zoneCarrier            :SmokeZone( SMOKECOLOR.White  , 90 )
zoneDefensivePerimeter :SmokeZone( SMOKECOLOR.Red    , 90 )


MESSAGE:New("Welcome to the Bubbles Mission", 10, "Start Message 1"):ToAll()

zoneScanScheduler = SCHEDULER:New(nil, ScanZones, {}, 0, 2)

--*************************
-- Event Handlers
--*************************
function enemyPlane:OnEventCrash( EventData )
  --if self == enemyPlane then
    --colectGarbage();
    MESSAGE:New("You killed that son of a bitch!", 10, "Success"):ToAll()
    --SpawnEnemyPlane()
    MESSAGE:New(   "Fuck here comes another one!", 10,   "Brief"):ToAll()
    Music_playerDied:ToAll();
 --end
end  

function player:OnEventCrash( EventData )

  --Okay, the PlaneHuman has crashed, now smoke at the x, z position.ZZZ
  --self:E( "Smoking at the position" )
  --EventData.IniUnit:SmokeOrange()
  player:MessageToAll("You died!", 10, "Failed")
  Music_playerDied:ToAll();
 end
