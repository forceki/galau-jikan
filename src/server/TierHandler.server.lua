local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TierModule = require(ReplicatedStorage.Shared.TierModule)

local function getGalauTime(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stayTime = leaderstats:FindFirstChild("Menit Galau")
        if stayTime then
            return stayTime.Value
        end
    end
    return 0
end

local function applyNametag(character, player)
    -- Tunggu hingga kepalanya dimuat
    local head = character:WaitForChild("Head", 10)
    if not head then return end
    
    local tierTitle, tierColor = TierModule.getData(getGalauTime(player))
    if not tierTitle then return end

    local existingTag = head:FindFirstChild("TierNametag")
    if existingTag then
        existingTag:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TierNametag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.Text = "[" .. tierTitle .. "]"
    textLabel.TextColor3 = tierColor
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboard

    billboard.Parent = head

    -- Update nametag periodically
    task.spawn(function()
        while character and character.Parent and billboard.Parent do
            task.wait(60) -- Cek setiap 1 menit (karena galau_time nambah per menit)
            local currentTitle, currentColor = TierModule.getData(getGalauTime(player))
            if currentTitle then
                textLabel.Text = "[" .. currentTitle .. "]"
                textLabel.TextColor3 = currentColor
            end
        end
    end)
end

local function setupPlayer(player)
    if player.Character then
        task.spawn(applyNametag, player.Character, player)
    end
    player.CharacterAdded:Connect(function(character)
        applyNametag(character, player)
    end)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end

-- --- SUPPORT UNTUK LEGACY CHAT SYSTEM ---
-- Jika game menggunakan Legacy Chat, script di bawah akan memasukkan Tags.
local function attachLegacyChatTags()
    local success, ChatService = pcall(function()
        return require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))
    end)
    if success and ChatService then
        ChatService.SpeakerAdded:Connect(function(speakerName)
            local speaker = ChatService:GetSpeaker(speakerName)
            if speaker then
                local player = speaker:GetPlayer()
                if player then
                    local tierTitle, tierColor = TierModule.getData(getGalauTime(player))
                    if tierTitle then
                        speaker:SetExtraData("Tags", {{
                            TagText = tierTitle,
                            TagColor = tierColor
                        }})
                    end
                end
            end
        end)
    end
end

-- Panggil untuk legacy system dengan pcall safe agar tidak error kalau TextChatService dipakai
task.spawn(function()
    pcall(attachLegacyChatTags)
end)
