--***************************
-- Variables
--***************************
-- Player
local player = CLIENT:FindByName("Player #002")

player:HandleEvent( EVENTS.Crash )

-- Enemy
local firstEnemy = true
local enemyPlane = nil
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

local zoneBFM      = ZONE:New("zoneBFM"     )
local zoneAntiShip = ZONE:New("zoneAntiShip")
local zoneBombing  = ZONE:New("zoneBombing" )

-- Music Section
local Music_zoneBFM      = USERSOUND:New("afdx_z06.wav")
local Music_zoneBombing  = USERSOUND:New("afdx_m12.wav")
local Music_zoneAntiShip = USERSOUND:New("afdx_m16.wav")
local Music_playerDied   = USERSOUND:New("afdx_MissionFailed.wav")
local Music_inTransit    = USERSOUND:New("afdx_Select.wav")

-- Schedulers


                                 
--***************************
-- Function Definitions
--***************************
function SpawnEnemyPlane( newEnemyPlane )
  enemyPlane = SPAWN:New( enemyTemplates[enemyNum] )
  enemyPlane:Spawn()
  enemyPlane:HandleEvent( EVENTS.Crash )
  enemyNum = enemyNum + 1
end

local currentZone = nil
local inTransit   = true

function ScanZones()
  if     player:IsInZone(zoneBFM)      then currentZone = zoneBFM
  elseif player:IsInZone(zoneAntiShip) then currentZone = zoneAntiShip
  elseif player:IsInZone(zoneBombing)  then currentZone = zoneBombing  
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
      
      if currentZone == zoneBombing then 
        Music_zoneBombing:ToAll()
       
        
      elseif currentZone == zoneAntiShip then 
       Music_zoneAntiShip:ToAll()
        
      elseif currentZone == zoneBFM then 
       Music_zoneBFM:ToAll()
       SpawnEnemyPlane()
        
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
zoneBFM     :SmokeZone( SMOKECOLOR.Green, 90 )
zoneBombing :SmokeZone( SMOKECOLOR.Red  , 90 )
zoneAntiShip:SmokeZone( SMOKECOLOR.Blue , 90 )


MESSAGE:New("Welcome to the Bubbles Mission", 10, "Start Message 1"):ToAll()

zoneScanScheduler = SCHEDULER:New(nil, ScanZones, {}, 0, 2)

--*************************
-- Event Handlers
--*************************
function enemyPlane:OnEventCrash( EventData )
  if self == enemyPlane then
    --colectGarbage();
    MESSAGE:New("You killed that son of a bitch!", 10, "Success"):ToAll()
    SpawnEnemyPlane()
    MESSAGE:New(   "Fuck here comes another one!", 10,   "Brief"):ToAll()
 end
end  

function player:OnEventCrash( EventData )

  --Okay, the PlaneHuman has crashed, now smoke at the x, z position.ZZZ
  --self:E( "Smoking at the position" )
  --EventData.IniUnit:SmokeOrange()
  player:MessageToAll("You died!", 10, "Failed")
  Music_playerDied:ToAll();
 end
