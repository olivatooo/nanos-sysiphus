-- local my_interval = Timer.SetInterval(function()
--   local player = Client.GetLocalPlayer()
--   if (not player) then return end
--   local character = player:GetControlledCharacter()
--   if (not character) then return end
--   Console.Log(character:GetLocation())
-- end, 2000)

local my_ui = WebUI(
  "Awesome UI",       -- Name
  "file://index.html" -- Path relative to this package (Client/)
)

Events.SubscribeRemote("SetMaxScore", function(my_text)
  my_ui:CallEvent("SetMaxScore", my_text)
end)

Events.SubscribeRemote("SetScore", function(my_text)
  my_ui:CallEvent("SetScore", my_text)
end)

Events.SubscribeRemote("UpdatePlayer", function(my_text)
  my_ui:CallEvent("UpdatePlayer", my_text)
end)

Events.SubscribeRemote("UpdateMaxPlayer", function(my_text)
  my_ui:CallEvent("UpdateMaxPlayer", my_text)
end)


Events.SubscribeRemote("Sisyphus", function()
  Sound(Vector(), "package://sisyphus/Client/duster.ogg", true, true, SoundType.Music)
  my_ui:CallEvent("Sisyphus")
end)


Timer.SetInterval(function()
  local player = Client.GetLocalPlayer()
  if (not player) then return end
  local character = player:GetControlledCharacter()
  if (not character) then return end
  if character:GetLocation().Z < 50000 then
    Events.CallRemote("Death", character)
  end
end, 1000)
