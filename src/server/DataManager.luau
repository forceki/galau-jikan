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
    
    local profileData = deepCopyTable(DataSchema)
    
    if success and data and type(data) == "table" then
        -- Add or overwrite the schema values with the saved values
        for k, v in pairs(data) do
            profileData[k] = v
        end
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
        DonationLeaderboard:SetAsync(tostring(player.UserId), data.donation or 0)
        GalauTimeLeaderboard:SetAsync(tostring(player.UserId), data.galau_time or 0)
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
            local newData = oldData or deepCopyTable(DataSchema)
            if type(newData) ~= "table" then
                newData = deepCopyTable(DataSchema)
            end
            newData.donation = (newData.donation or 0) + amount
            return newData
        end)
        
        if updatedData and updatedData.donation then
            DonationLeaderboard:SetAsync(tostring(userId), updatedData.donation)
        end
    end)
    
    if not success then
        warn("Failed to process donation for User " .. tostring(userId) .. ": " .. tostring(err))
    end
    
    return success
end

return DataManager
