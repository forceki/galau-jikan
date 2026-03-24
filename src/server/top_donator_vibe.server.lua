-- top_donator_vibe.server.lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
local DonationLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_Donations_v1")

-- Fungsi untuk membuat Tag Neon (BillboardGui)
local function createNeonTag(npcModel, displayName, rank, donationAmount)
    -- Hapus tag lama jika sudah ada (agar tidak double saat refresh)
    local existingTag = npcModel:FindFirstChild("DonatorTag")
    if existingTag then existingTag:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DonatorTag"
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 50 
    billboard.Size = UDim2.new(0, 150, 0, 80) 
    billboard.StudsOffset = Vector3.new(0, 3.5, 0) 
    billboard.Adornee = npcModel:FindFirstChild("Head")
    billboard.Parent = npcModel

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard

    local uiList = Instance.new("UIListLayout")
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    uiList.Padding = UDim.new(0, -2)
    uiList.Parent = container

    local rankLabel = Instance.new("TextLabel")
    rankLabel.Text = "Top " .. rank .. " Donator"
    rankLabel.Size = UDim2.new(1, 0, 0, 25)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.TextSize = 22
    rankLabel.Parent = container
    
    local rankColors = {
        [1] = Color3.fromRGB(0, 255, 255), -- Cyan (Top 1)
        [2] = Color3.fromRGB(255, 200, 0), -- Gold (Top 2)
        [3] = Color3.fromRGB(85, 255, 127), -- Green (Top 3)
    }
    rankLabel.TextColor3 = rankColors[rank] or Color3.new(1,1,1)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Parent = rankLabel

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = "@" .. displayName
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 16
    nameLabel.Parent = container

    -- 3. Label Nominal Donation (RBX)
    local amountLabel = Instance.new("TextLabel")
    amountLabel.Text = donationAmount .. " RBX"
    amountLabel.Size = UDim2.new(1, 0, 0, 18)
    amountLabel.BackgroundTransparency = 1
    amountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    amountLabel.Font = Enum.Font.GothamBold
    amountLabel.TextSize = 14
    amountLabel.Parent = container
end

local function playDonatorEmote(npcModel)
    if not npcModel then return end
    local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

    local animFolder = npcModel:FindFirstChild("Animations")
    local sittingAnim = animFolder and animFolder:FindFirstChild("SittingPose")

    if sittingAnim and sittingAnim.AnimationId ~= "" then
        local track = animator:LoadAnimation(sittingAnim)
        track.Looped = true
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
    end
end

local function applyPlayerToNPC(npc, userId, donationAmount, schemaData, rank)
    local displayName = "Unknown"
    
    if schemaData and schemaData.player_info then
        displayName = schemaData.player_info.display_name or schemaData.player_info.username or displayName
    else
        pcall(function()
            displayName = Players:GetNameFromUserIdAsync(userId)
        end)
    end

    createNeonTag(npc, displayName, rank, donationAmount)

    local success, description = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if success and description then
        local humanoid = npc:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ApplyDescription(description)
        end
    end

    task.delay(1.5, function()
        playDonatorEmote(npc)
    end)
end

local function updateTopDonators()
    local success, pages = pcall(function()
        return DonationLeaderboard:GetSortedAsync(false, 3)
    end)

    if success and pages then
        local topDonators = pages:GetCurrentPage()
        local npcNames = {"NPC_TOP1", "NPC_TOP2", "NPC_TOP3"}

        for rank, data in ipairs(topDonators) do
            if rank > 3 then break end
            
            local userId = tonumber(data.key)
            local donationAmount = data.value
            
            local leaderboardFolder = workspace:FindFirstChild("DonationLeaderboard")
            print(leaderboardFolder)
            local npcContainer = leaderboardFolder and leaderboardFolder:FindFirstChild(npcNames[rank])
            local npcModel = npcContainer and npcContainer:FindFirstChild("rig")
            print(npcModel)
            
            if npcModel and userId then
                local schemaSuccess, schemaData = pcall(function()
                    return PlayerDataStore:GetAsync("Player_" .. userId)
                end)
                
                -- Kirim parameter rank ke fungsi apply
                applyPlayerToNPC(npcModel, userId, donationAmount, schemaData, rank)
            end
        end
    else
        warn("[TopDonatorVibe] Gagal mengambil data leaderboard.")
    end
end

-- Main Loop
task.spawn(function()
    while true do
        updateTopDonators()
        task.wait(60)
    end
end)