local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataManager = require(script.Parent.DataManager)

local DonationConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DonationConfig"))
local PRODUCT_VALUES = DonationConfig.PRODUCT_VALUES

-- BindableEvent untuk komunikasi server-ke-server
-- Script lain bisa listen dengan: ServerScriptService.Server.donation:WaitForChild("DonateBindable").Event:Connect(...)
local DonateBindable = Instance.new("BindableEvent")
DonateBindable.Name = "DonateBindable"
DonateBindable.Parent = script

local DonationAnnouncement = Instance.new("RemoteEvent")
DonationAnnouncement.Name = "DonationAnnouncement"
DonationAnnouncement.Parent = ReplicatedStorage

local function broadcastDonation(playerName, amount)
    local msg = "🎉 " .. playerName .. " has just donated " .. tostring(amount) .. " Robux! Thank you for the support! 🎉"
    DonationAnnouncement:FireAllClients(playerName, amount)

    -- Legacy Chat Fallback
    task.spawn(function()
        pcall(function()
            local ServerScriptService = game:GetService("ServerScriptService")
            local runner = ServerScriptService:FindFirstChild("ChatServiceRunner")
            if runner then
                local chatModule = runner:FindFirstChild("ChatService")
                if chatModule then
                    local ChatService = require(chatModule)
                    local channel = ChatService:GetChannel("All")
                    if channel then
                        channel:SendSystemMessage(msg)
                    end
                end
            end
        end)
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

    local size = 10
    if amount >= 50 then
        size = 20
    elseif amount >= 25 then
        size = 15
    elseif amount >= 5 then
        size = 10
    end

    local FirefliesFolder = workspace:FindFirstChild("FirefliesCollection")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if FirefliesFolder and playerRoot then
        local allFireflies = {}
        
        for _, ffModel in pairs(FirefliesFolder:GetChildren()) do
            local primary = ffModel:IsA("Model") and (ffModel.PrimaryPart or ffModel:FindFirstChildWhichIsA("BasePart"))
            
            if primary then
                local dist = (primary.Position - playerRoot.Position).Magnitude
                table.insert(allFireflies, {model = ffModel, distance = dist})
            end
        end

        table.sort(allFireflies, function(a, b) return a.distance < b.distance end)

        for i = 1, size do
            if allFireflies[i] then
                local targetModel = allFireflies[i].model
                local tag = Instance.new("ObjectValue")
                tag.Name = "SelectedByDonator"
                tag.Value = player
                tag.Parent = targetModel
                game:GetService("Debris"):AddItem(tag, 15) -- Hapus otomatis
            end
        end
    else
        warn("!!! Folder FirefliesCollection tidak ditemukan atau Player Root hilang")
    end

    -- Beritahu server scripts lain (BindableEvent, server-to-server)
    DonateBindable:Fire(player)

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
