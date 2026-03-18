local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TierModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TierModule"))

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

-- Support untuk TextChatService (sistem modern Roblox)
TextChatService.OnIncomingMessage = function(message)
    local properties = Instance.new("TextChatMessageProperties")
    
    if message.TextSource then
        local player = Players:GetPlayerByUserId(message.TextSource.UserId)
        if player then
            local tierTitle, tierColor = TierModule.getData(getGalauTime(player))
            if tierTitle then
                local hexColor = string.format("#%02X%02X%02X", 
                    math.round(tierColor.R * 255), 
                    math.round(tierColor.G * 255), 
                    math.round(tierColor.B * 255))
                
                -- Tambahkan tier sebagai prefix warna di chat
                properties.PrefixText = "<font color='" .. hexColor .. "'>[" .. tierTitle .. "]</font> " .. message.PrefixText
            end
        end
    end
    
    return properties
end
