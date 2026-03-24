local MarketplaceService = game:GetService("MarketplaceService")

local DataManager = require(script.Parent:WaitForChild("DataManager"))

MarketplaceService.PromptPurchaseFinished:Connect(function(player, assetId, isPurchased)
    if isPurchased then
        local playerData = DataManager.GetProfile(player)
        
        if playerData then
            local success, assetInfo = pcall(function()
                return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
            end)
            
            local price = (success and assetInfo.PriceInRobux) or 10
            playerData.galau_point = (playerData.galau_point or 0) + (price * 10)
            
            DataManager.SaveProfile(player)
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local gpStat = leaderstats:FindFirstChild("GalauPoints")
                if gpStat then
                    gpStat.Value = playerData.galau_point
                end
            end
            
            -- print("Data " .. player.Name .. " berhasil diupdate ke Schema melalui Catalog Avatar!")
        end
    end
end)
