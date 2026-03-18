local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataManager = require(script.Parent.DataManager)

local DonationConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DonationConfig"))
local PRODUCT_VALUES = DonationConfig.PRODUCT_VALUES

local DonationAnnouncement = Instance.new("RemoteEvent")
DonationAnnouncement.Name = "DonationAnnouncement"
DonationAnnouncement.Parent = ReplicatedStorage

local function broadcastDonation(playerName, amount)
    local msg = "🎉 " .. playerName .. " has just donated " .. tostring(amount) .. " Robux! Thank you for the support! 🎉"
    DonationAnnouncement:FireAllClients(playerName, amount)

    -- Legacy Chat Fallback
    pcall(function()
        local ServerScriptService = game:GetService("ServerScriptService")
        local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))
        if ChatService then
            local channel = ChatService:GetChannel("All")
            if channel then
                channel:SendSystemMessage(msg)
            end
        end
    end)
end

local function processReceipt(receiptInfo)
    local playerId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId
    local amountSpent = receiptInfo.CurrencySpent
    local amount = PRODUCT_VALUES[productId] or amountSpent

    local player = Players:GetPlayerByUserId(playerId)
    if player then
        -- Update their live session data right away if they are in game
        local profile = DataManager.GetProfile(player)
        if profile then
            profile.donation = (profile.donation or 0) + amount
        end
    end

    -- Save the data properly via our central DataManager structure
    local success = DataManager.ProcessDonation(playerId, amount)

    if not success then
        warn("Failed to save donation data for player " .. tostring(playerId))
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Siarkan ke semua orang di server
    local pName = player and player.Name or "Offline Player"
    broadcastDonation(pName, amount)

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
