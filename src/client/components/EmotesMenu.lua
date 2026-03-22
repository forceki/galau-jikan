local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.React)
local E = React.createElement

local EmotesData = require(ReplicatedStorage.Shared.EmotesData)

local function playAnimation(id)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    -- Hentikan animasi yang sebelumnya jika ada
    if _G.CurrentAnimationTrack then
        _G.CurrentAnimationTrack:Stop()
    end
    
    local anim = Instance.new("Animation")
    anim.AnimationId = id
    
    local track = animator:LoadAnimation(anim)
    track:Play()
    _G.CurrentAnimationTrack = track
end

local function stopAnimation()
    if _G.CurrentAnimationTrack then
        _G.CurrentAnimationTrack:Stop()
        _G.CurrentAnimationTrack = nil
    end
end

local function EmotesMenu()
    local isPopoverVisible, setPopoverVisible = React.useState(false)
    local activeTab, setActiveTab = React.useState("emotes") -- Bisa "emotes" atau "dance"
    
    local items = activeTab == "emotes" and EmotesData.Emotes or EmotesData.Dances
    
    local containerItems = {}
    containerItems.UIListLayout = E("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    containerItems.StopButton = E("TextButton", {
        LayoutOrder = 0,
        Text = "Stop Animation",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        [React.Event.Activated] = stopAnimation,
    }, {
        Corner = E("UICorner", { CornerRadius = UDim.new(0, 6) })
    })

    for i, item in ipairs(items) do
        containerItems["Item_" .. i] = E("TextButton", {
            LayoutOrder = i,
            Text = item.name,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            [React.Event.Activated] = function()
                playAnimation(item.id)
            end,
        }, {
            Corner = E("UICorner", { CornerRadius = UDim.new(0, 6) })
        })
    end
    
    return E("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, {
        ToggleBtnContainer = E("Frame", {
            Size = UDim2.new(0, 120, 0, 30),
            Position = UDim2.new(0, 20, 0, 150), -- Posisi di bawah tombol Show Music (Y=115)
            AnchorPoint = Vector2.new(0, 0),
            BackgroundTransparency = 1,
        }, {
            ToggleBtn = E("TextButton", {
                Text = isPopoverVisible and "Hide Emotes" or "Show Emotes",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(60, 40, 200),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                [React.Event.Activated] = function()
                    setPopoverVisible(not isPopoverVisible)
                end,
            }, {
                Corner = E("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Stroke = E("UIStroke", {
                    Color = Color3.fromRGB(80, 80, 255),
                    Thickness = 2,
                }),
            }),
        }),

        Popover = isPopoverVisible and E("Frame", {
            Size = UDim2.new(0, 250, 0, 250),
            Position = UDim2.new(0, 150, 0, 150),
            AnchorPoint = Vector2.new(0, 0),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0.1,
        }, {
            Corner = E("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Stroke = E("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Thickness = 2 }),
            
            TabsFrame = E("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
            }, {
                Layout = E("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 0) }),
                EmotesTab = E("TextButton", {
                    Text = "Emotes",
                    Size = UDim2.new(0.5, 0, 1, 0),
                    BackgroundColor3 = activeTab == "emotes" and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(30, 30, 30),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    BorderSizePixel = 0,
                    [React.Event.Activated] = function() setActiveTab("emotes") end,
                }),
                DanceTab = E("TextButton", {
                    Text = "Dance",
                    Size = UDim2.new(0.5, 0, 1, 0),
                    BackgroundColor3 = activeTab == "dance" and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(30, 30, 30),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    BorderSizePixel = 0,
                    [React.Event.Activated] = function() setActiveTab("dance") end,
                })
            }),
            
            ScrollList = E("ScrollingFrame", {
                Size = UDim2.new(1, -20, 1, -40),
                Position = UDim2.new(0, 10, 0, 35),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            }, containerItems)
        })
    })
end

return EmotesMenu
