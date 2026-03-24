local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.React)
local E = React.createElement

local function GalauPointsUI()
    local points, setPoints = React.useState(0)
    local popupList, setPopupList = React.useState({})
    local popupIndex = React.useRef(0)

    React.useEffect(function()
        local isMounted = true
        local player = Players.LocalPlayer
        
        task.spawn(function()
            local leaderstats = player:WaitForChild("leaderstats", 10)
            if not leaderstats then return end
            
            local pointsVal = leaderstats:WaitForChild("GalauPoints", 10)
            if not pointsVal then return end

            if isMounted then
                setPoints(pointsVal.Value)
            end

            local connection = pointsVal.Changed:Connect(function(newVal)
                if not isMounted then return end
                
                setPoints(function(oldVal)
                    -- local diff = newVal - oldVal
                    -- if diff > 0 then
                    --     -- Buat Popup
                    --     popupIndex.current = popupIndex.current + 1
                    --     local newPopup = { id = popupIndex.current, amount = diff }
                        
                    --     setPopupList(function(oldList)
                    --         local newList = table.clone(oldList)
                    --         table.insert(newList, newPopup)
                    --         return newList
                    --     end)
                        
                    --     -- Hapus Popup setelah 3.5 detik
                    --     local currentId = popupIndex.current
                    --     task.delay(3.5, function()
                    --         if not isMounted then return end
                    --         setPopupList(function(oldList)
                    --             local newList = {}
                    --             for _, p in ipairs(oldList) do
                    --                 if p.id ~= currentId then
                    --                     table.insert(newList, p)
                    --                 end
                    --             end
                    --             return newList
                    --         end)
                    --     end)
                    -- end
                    
                    return newVal
                end)
            end)
            
            -- Cleanup
            _G.GalauPointsConnection = connection
        end)
        
        return function()
            isMounted = false
            if _G.GalauPointsConnection then
                _G.GalauPointsConnection:Disconnect()
                _G.GalauPointsConnection = nil
            end
        end
    end, {})

    -- Komponen Layout Popups
    local popupElements = {}
    popupElements.Layout = E("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 15),
    })

    for i, popup in ipairs(popupList) do
        popupElements["Popup_" .. popup.id] = E("Frame", {
            LayoutOrder = popup.id,
            Size = UDim2.new(0, 320, 0, 90),
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = 0.1,
        }, {
            Corner = E("UICorner", { CornerRadius = UDim.new(0, 12) }),
            Stroke = E("UIStroke", { Color = Color3.fromRGB(255, 215, 0), Thickness = 3 }),
            Title = E("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Text = "🎉 PURCHASE SUCCESSFUL! 🎉",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 18,
            }),
            Amount = E("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = "+" .. tostring(popup.amount) .. " Galau Points",
                TextColor3 = Color3.fromRGB(255, 215, 0),
                Font = Enum.Font.GothamBlack,
                TextSize = 24,
            })
        })
    end

    return E("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, {
        -- Tampilan UI Galau Points di Sudut Kanan Atas
        CornerDisplay = E("Frame", {
            Size = UDim2.new(0, 90, 0, 28),
            Position = UDim2.new(1, -20, 0, 60),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            BackgroundTransparency = 0.15,
        }, {
            Corner = E("UICorner", { CornerRadius = UDim.new(0, 6) }),
            Stroke = E("UIStroke", { Color = Color3.fromRGB(255, 215, 0), Thickness = 2 }),
            Label = E("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(points) .. " GP",
                TextColor3 = Color3.fromRGB(255, 215, 0),
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        }),

        -- Kontainer Modal Popups di Tengah Layar
        PopupContainer = (#popupList > 0) and E("Frame", {
            Size = UDim2.new(1, 0, 0, 500),
            Position = UDim2.new(0.5, 0, 0.4, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ZIndex = 100,
        }, popupElements)
    })
end

return GalauPointsUI
