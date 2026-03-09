local Players = game:GetService("Players")
local DataManager = require(script.Parent.DataManager)

local function onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local stayTime = Instance.new("IntValue")
    stayTime.Name = "Menit Galau" 
    stayTime.Parent = leaderstats

    -- Load the consolidated JSON table profile for this user
    local profileData = DataManager.LoadProfile(player)
    stayTime.Value = profileData.galau_time

    task.spawn(function()
        while player.Parent do
            task.wait(60)
            if player.Parent then
                stayTime.Value += 1
                
                -- Update the session table so it gets properly saved on disconnect
                local currentData = DataManager.GetProfile(player)
                if currentData then
                    currentData.galau_time = stayTime.Value
                end
            end
        end
    end)
end

local function onPlayerRemoving(player: Player)
    -- This handles the deep save of the new consolidated JSON table
    DataManager.ReleaseProfile(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerRemoving, player)
    end
    task.wait(2)
end)