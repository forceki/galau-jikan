local Players = game:GetService("Players")
local DataManager = require(script.Parent.DataManager)

local function onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local stayTime = Instance.new("IntValue")
    stayTime.Name = "Menit Galau" 
    stayTime.Parent = leaderstats

    local galauPointsStats = Instance.new("IntValue")
    galauPointsStats.Name = "GalauPoints"
    galauPointsStats.Parent = leaderstats

    -- Load the consolidated JSON table profile for this user
    local profileData = DataManager.LoadProfile(player)
    stayTime.Value = profileData.galau_time or 0
    galauPointsStats.Value = profileData.galau_point or 0

    -- Teleport pemain ke posisi terakhir saat karakter mereka spawn
    player.CharacterAdded:Connect(function(character)
        if profileData.last_position and type(profileData.last_position) == "table" then
            local pos = profileData.last_position
            if pos.x and pos.y and pos.z then
                -- Tunggu sebentar sampai game memuat Physics karakter
                task.wait(0.2)
                character:PivotTo(CFrame.new(pos.x, pos.y, pos.z))
            end
        end
    end)

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

    -- Tracker posisi yang lebih sering agar akurat saat pemain keluar
    task.spawn(function()
        while player.Parent do
            task.wait(2)
            if player.Parent then
                local currentData = DataManager.GetProfile(player)
                local char = player.Character
                if currentData and char and char:FindFirstChild("HumanoidRootPart") then
                    local pos = char.HumanoidRootPart.Position
                    currentData.last_position = {x = pos.X, y = pos.Y, z = pos.Z}
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
