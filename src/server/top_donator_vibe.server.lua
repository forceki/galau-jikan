-- top_donator_vibe.server.lua
-- Menjalankan pose duduk animasi untuk NPC Top Donator dan mengambil data dari schema
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
local DonationLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_Donations_v1")

local function playDonatorEmote(npcModel)
    if not npcModel then return end

    local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

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

local function applyPlayerToNPC(npc, userId, donationAmount, schemaData)
    -- Ambil display_name & username dari schema, atau fallback ke roblox API
    local displayName = "Unknown"
    local username = "Unknown"

    if schemaData and schemaData.player_info then
        displayName = schemaData.player_info.display_name or displayName
        username = schemaData.player_info.username or username
    else
        -- Fallback jika schema blm lengkap
        pcall(function()
            username = Players:GetNameFromUserIdAsync(userId)
            displayName = username -- Fallback simple
        end)
    end

    npc.Name = displayName .. " (" .. donationAmount .. " rbx)"
    -- npc.Name = displayName .. " — Relapsed into Silence"

    -- Terapkan avatar player ke NPC
    local success, description = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if success and description then
        local humanoid = npc:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ApplyDescription(description)
        end
    end

    -- Jalankan animasi emote
    playDonatorEmote(npc)
end

local function updateTopDonators()
    local success, pages = pcall(function()
        return DonationLeaderboard:GetSortedAsync(false, 3)
    end)

    if success and pages then
        local topDonators = pages:GetCurrentPage()
        
        -- Default nama NPC jika kosong
        local npcNames = {"NPC_Top1", "NPC_Top2", "NPC_Top3"}

        for rank, data in ipairs(topDonators) do
            if rank > 3 then break end
            
            local userId = tonumber(data.key)
            local donationAmount = data.value
            
            local npcModel = workspace:FindFirstChild(npcNames[rank])
            if npcModel and userId then
                -- Ambil data schema player
                local schemaSuccess, schemaData = pcall(function()
                    return PlayerDataStore:GetAsync("Player_" .. userId)
                end)
                
                applyPlayerToNPC(npcModel, userId, donationAmount, schemaData)
            end
        end
    else
        warn("[TopDonatorVibe] Gagal mengambil data leaderboard donasi.")
    end
end

-- Update setiap 60 detik
task.spawn(function()
    while true do
        updateTopDonators()
        task.wait(60)
    end
end)