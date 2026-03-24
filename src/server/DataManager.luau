local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
local DonationLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_Donations_v1")
local GalauTimeLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_StayTime_v1")

local DataSchema = require(script.Parent.data_schema)

local DataManager = {}
local sessionData = {}

local function deepCopyTable(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = deepCopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function DataManager.LoadProfile(player)
    local userId = "Player_" .. player.UserId
    
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(userId)
    end)
    
    -- Use DataSchema.init to fill player_id and player_info from the real Player object
    local profileData = DataSchema.init(player)
    
    if success and data and type(data) == "table" then
        -- Overwrite defaults with saved values, but always keep fresh player_info
        for k, v in pairs(data) do
            profileData[k] = v
        end
        -- Always sync latest username & display name (they can change on Roblox)
        profileData.player_id = tostring(player.UserId)
        profileData.player_info = {
            username = player.Name,
            display_name = player.DisplayName,
        }
    end
    
    profileData.last_login = os.time()
    sessionData[player] = profileData
    return profileData
end

function DataManager.GetProfile(player)
    return sessionData[player]
end

function DataManager.SaveProfile(player)
    local data = sessionData[player]
    if not data then return end
    
    local userId = "Player_" .. player.UserId
    
    local success, err = pcall(function()
        PlayerDataStore:SetAsync(userId, data)
        DonationLeaderboard:SetAsync(tostring(player.UserId), math.floor(data.donation or 0))
        GalauTimeLeaderboard:SetAsync(tostring(player.UserId), math.floor(data.galau_time or 0))
    end)
    
    if not success then
        warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
    end
end

function DataManager.ReleaseProfile(player)
    DataManager.SaveProfile(player)
    sessionData[player] = nil
end

function DataManager.ProcessDonation(userId, amount)
    local playerKey = "Player_" .. tostring(userId)
    
    local success, err = pcall(function()
        local updatedData = PlayerDataStore:UpdateAsync(playerKey, function(oldData)
            local newData = oldData or deepCopyTable(DataSchema.default)
            if type(newData) ~= "table" then
                newData = deepCopyTable(DataSchema.default)
            end
            newData.donation = (newData.donation or 0) + amount
            return newData
        end)
        
        if updatedData and updatedData.donation then
            -- OrderedDataStore WAJIB menerima nilai Integer, gunakan math.floor
            local exactDonationNum = math.floor(updatedData.donation)
            DonationLeaderboard:SetAsync(tostring(userId), exactDonationNum)
            print("[DataManager] Successfully pushed " .. tostring(exactDonationNum) .. " to GlobalLeaderboard_Donations_v1 !")
        end
    end)
    
    if not success then
        warn("Failed to process donation for User " .. tostring(userId) .. " | Error: " .. tostring(err))
    end
    
    return success
end

function DataManager.finalSave(player, schema)
    local key = "Player_" .. player.UserId
    
    -- 1. Simpan Full JSON (Untuk Info NPC & Load Player)
    pcall(function()
        PlayerDataStore:SetAsync(key, schema)
    end)
    
    -- 2. Simpan Angka Saja (Untuk Ranking NPC & Board)
    pcall(function()
        DonationLeaderboard:SetAsync(tostring(player.UserId), math.floor(schema.donation or 0))
    end)
    
    -- 3. Simpan Stay Time / Galau Time
    pcall(function()
        GalauTimeLeaderboard:SetAsync(tostring(player.UserId), math.floor(schema.galau_time or 0))
    end)
end

return DataManager
