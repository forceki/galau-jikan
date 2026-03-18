local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

-- Tunggu sampai server membuat event-nya
local DonationAnnouncement = ReplicatedStorage:WaitForChild("DonationAnnouncement")

DonationAnnouncement.OnClientEvent:Connect(function(playerName, amount)
    local msgText = "🎉 " .. playerName .. " has just donated " .. tostring(amount) .. " Robux! Thank you! 🎉"
    
    -- Memeriksa apakah game menggunakan sistem TextChatService yang baru
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannels = TextChatService:FindFirstChild("TextChannels")
        if textChannels then
            local rbxGeneral = textChannels:FindFirstChild("RBXGeneral")
            if rbxGeneral then
                -- Menggunakan styling HTML warna gold
                local formattedMsg = "<font color='#FFD700'><b>" .. msgText .. "</b></font>"
                rbxGeneral:DisplaySystemMessage(formattedMsg)
                return
            end
        end
    end
    
    -- Apabila sistem legacy chat atau display message gagal, gunakan StarterGui SetCore sebagai fallback aman
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = msgText,
            Color = Color3.fromHex("#FFD700"),
            Font = Enum.Font.SourceSansBold,
            TextSize = 18
        })
    end)
end)
