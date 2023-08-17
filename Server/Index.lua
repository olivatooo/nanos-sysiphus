function SpawnCharacterRandomized(location, rotation, asset)
  local selected_mesh = asset or "nanos-world::SK_Male"
  local spawn_point = GetRandomSpawnPoint()
  local new_char = Character(location or spawn_point.location, rotation or spawn_point.rotation, "nanos-world::SK_Male")

  CustomizeCharacter(new_char, selected_mesh)
  return new_char
end

function OnPlayerCharacterDeath(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
  local controller = chara:GetPlayer()
  if (not controller) then return end
  if (instigator) then
    if (instigator == controller) then
      Chat.BroadcastMessage("<cyan>" .. instigator:GetName() .. "</> couldn't handle the experience")
    else
      Chat.BroadcastMessage("<cyan>" ..
        instigator:GetName() .. "</> killed <cyan> which is fine" .. controller:GetName() .. "</>")
    end
  else
    Chat.BroadcastMessage("<cyan>" .. controller:GetName() .. "</> died")
  end
  Timer.Bind(
    Timer.SetTimeout(function(character)
      if (character:GetHealth() ~= 0) then return end
      local spawn_point = GetRandomSpawnPoint()
      character:Respawn(spawn_point.location, spawn_point.rotation)
    end, 5000, chara),
    chara
  )
end

function GetRandomSpawnPoint()
  return #SPAWN_POINTS > 0 and SPAWN_POINTS[math.random(#SPAWN_POINTS)] or { location = Vector(), rotation = Rotator() }
end

function SpawnPlayer(player, location, rotation)
  local new_char = Character(GetRandomSpawnPoint(), Rotator(0, 0, 0), "nanos-world::SK_Male")
  player:Possess(new_char)
  new_char:Subscribe("Death", OnPlayerCharacterDeath)
  new_char:Subscribe("UnPossess", function(self)
    self:Unsubscribe("Death", OnPlayerCharacterDeath)
  end)
  local plane = StaticMesh(Vector(), Rotator(0, 0, 90), "nanos-world::SM_Plane")
  plane:AttachTo(new_char)
  plane:SetRelativeLocation(Vector(75, 0, 0))
  plane:SetRotation(Rotator(0, 90, 90))
  plane:SetVisibility(false)
end

Player.Subscribe("Spawn", function(player)
  Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has joined the server")
  SpawnPlayer(player)
  SpawnBoulder(player)
end)


Package.Subscribe("Load", function()
  local character_locations = Server.GetValue("character_locations") or {}
  if (#character_locations == 0) then
    for k, player in pairs(Player.GetAll()) do
      SpawnPlayer(player)
    end
  else
    for k, p in pairs(character_locations) do
      if (p.player and p.player:IsValid()) then
        SpawnPlayer(p.player, p.location, p.rotation)
      end
    end
  end
  Chat.BroadcastMessage("The package <cyan>Sandbox</> has been reloaded!")
end)




SPAWN_POINTS = { Vector(500000, 433826, 50614), Vector(500100, 433826, 50614), Vector(500200, 433826, 50614) }
local my_staticmesh = StaticMesh(Vector(500000, 0, 300000), Rotator(0, 0, 30), "nanos-world::SM_Plane")
my_staticmesh:SetScale(Vector(100, 10000, 1))
my_staticmesh:SetMaterial("nanos-world::M_Default_Masked_Lit")
my_staticmesh:SetPhysicalMaterial("nanos-world::PM_Gravel")
my_staticmesh:SetMaterialTextureParameter("Texture", "package://sisyphus/Client/mountain.jpg")
my_staticmesh:SetMaterialScalarParameter("Metallic", 0)
my_staticmesh:SetMaterialScalarParameter("Specular ", 0)


local platform = StaticMesh(Vector(500000, 432826, 50214), Rotator(0, 0, 0),
  "nanos-world::SM_Plane")
platform:SetScale(Vector(100, 100, 1))
platform:SetMaterial("nanos-world::M_Default_Masked_Lit")
platform:SetPhysicalMaterial("nanos-world::PM_Gravel")
platform:SetMaterialTextureParameter("Texture", "package://sisyphus/Client/mountain.jpg")
platform:SetMaterialScalarParameter("Metallic", 0)
platform:SetMaterialScalarParameter("Specular ", 0)


LastToTouch = "Sisyphus"
MaxToTouch = "Sisyphus"
MaxGlobalScore = 0

Score = 0
MyMaxScore = 0
Sisyphus = false

function SpawnBoulder(player)
  local boulder = Prop(Vector(500000, 432826, 50314), Rotator(), "nanos-world::SM_Sphere")
  boulder:SetScale(Vector(3, 3, 3))
  boulder:SetMaterial("nanos-world::M_Default_Masked_Lit")
  boulder:SetPhysicalMaterial("nanos-world::PM_Rock")
  boulder:SetMaterialTextureParameter("Texture", "package://sisyphus/Client/rock.jpg")
  boulder:SetMaterialScalarParameter("Metallic", 0)
  boulder:SetMaterialScalarParameter("Specular ", 0)
  boulder:SetGrabMode(GrabMode.Disabled)

  local sphere_trigger = Trigger(Vector(500000, 432826, 50314), Rotator(), Vector(100), TriggerType.Sphere, false,
    Color(1, 0, 0))
  sphere_trigger:SetScale(Vector(3, 3, 3))
  sphere_trigger:AttachTo(boulder)
  sphere_trigger:Subscribe("BeginOverlap", function(trigger, actor_triggering)
    if actor_triggering:IsA(Character) then
      LastToTouch = actor_triggering:GetPlayer():GetName()
    end
  end)


  local my_timer = Timer.SetInterval(function(_boulder)
    Score = _boulder:GetLocation().Z - 50365
    if Score > MaxGlobalScore then
      MaxGlobalScore = Score
      MaxToTouch = LastToTouch
      Sisyphus = true
    end
    if Sisyphus and Score < (MyMaxScore - 1000) and MyMaxScore > 1000 then
      Sisyphus = false
      local p = boulder:GetValue("LastToTouch")
      if p then
        Events.CallRemote("Sisyphus", p)
      end
    end

    Events.BroadcastRemote("SetScore", Score)
    Events.BroadcastRemote("UpdatePlayer", LastToTouch)

    Events.BroadcastRemote("SetMaxScore", MaxGlobalScore)
    Events.BroadcastRemote("UpdateMaxPlayer", MaxToTouch)
    if _boulder:GetLocation().Z < 50000 then
      _boulder:SetLocation(Vector(500000, 432826, 50314))
    end
  end, 500, boulder)

  Timer.Bind(my_timer, boulder)
  player:SetValue("boulder", boulder)
end

Events.SubscribeRemote("Death", function(player, my_text)
  my_text:SetHealth(0)
end)


Player.Subscribe("Destroy", function(player)
  -- Destroy it's Character
  local character = player:GetControlledCharacter()
  if (character) then
    character:Destroy()
  end
  Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has left the experience")
  local boulder = player:GetValue("boulder")
  if (boulder) then
    boulder:Destroy()
  end
end)
