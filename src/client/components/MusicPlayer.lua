local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
local E = React.createElement

local PLAYLIST = {
    {id = "rbxassetid://81549849467553", title = "あなたのことが好き"},
    {id = "rbxassetid://128560685759007", title = "ヨルシカ - ただ君に晴れ"},
    {id = "rbxassetid://134417754010566", title = "りりあriria. 最後のバイバイ"},
}

local function MusicPlayer()
    local trackIndex, setTrackIndex = React.useState(1)
    local isPlaying, setPlaying = React.useState(false)
    local isExpanded, setExpanded = React.useState(false) 
    local isPlayerVisible, setPlayerVisible = React.useState(true)
    
    local barHeights, setBarHeights = React.useBinding({3, 3, 3, 3, 3})
    local progress, setProgress = React.useBinding(0)
    local sound = game.SoundService:WaitForChild("Musics")

    React.useEffect(function()
        local connection = RunService.RenderStepped:Connect(function()
            if isPlaying and sound.IsPlaying then
                local loudness = math.clamp(sound.PlaybackLoudness / 20, 3, 25)
                setBarHeights({math.random(loudness*0.5, loudness), math.random(loudness*0.8, loudness), math.random(loudness*0.4, loudness), math.random(loudness*0.9, loudness), math.random(loudness*0.6, loudness)})
                if sound.TimeLength > 0 then setProgress(sound.TimePosition / sound.TimeLength) end
            else
                setBarHeights({3, 3, 3, 3, 3})
            end
        end)
        return function() connection:Disconnect() end
    end, {isPlaying})

    local function playTrack(index)
        setTrackIndex(index)
        sound:Stop()
        sound.SoundId = PLAYLIST[index].id
        sound.TimePosition = 0
        if isPlaying then sound:Play() end
    end

    React.useEffect(function()
        local connection = sound.Ended:Connect(function()
            if isPlaying then
                local n = trackIndex + 1
                if n > #PLAYLIST then n = 1 end
                playTrack(n)
            end
        end)
        return function() connection:Disconnect() end
    end, {trackIndex, isPlaying})

    local songElements = {
        UIList = E("UIListLayout", { 
            FillDirection = Enum.FillDirection.Vertical, 
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        UIPadding = E("UIPadding", { 
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 4)
        })
    }
    
    for i, track in ipairs(PLAYLIST) do
        local isSelected = (i == trackIndex)
        songElements["Song" .. i] = E("TextButton", {
            LayoutOrder = i,
            Text = track.title,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 12,
            BackgroundTransparency = isSelected and 0.85 or 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = isSelected and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextSize = 13,
            AutoButtonColor = true,
            [React.Event.Activated] = function() playTrack(i) end,
        }, {
            Corner = E("UICorner", { CornerRadius = UDim.new(0, 6) }),
            Padding = E("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 30) }),
            Stroke = E("UIStroke", {
                Color = Color3.new(0, 0, 0),
                Transparency = 0.5,
                Thickness = 1,
            }),
            Icon = isSelected and E("TextLabel", {
                Text = "♫",
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, 20, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                ZIndex = 13,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
            })
        })
    end

    return E("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, {
        ToggleBtnContainer = E("Frame", {
            Size = UDim2.new(0, 120, 0, 30),
            Position = UDim2.new(0, 20, 0, 65), -- Placed right underneath the Donate UI (pos 20, 20 + size 40)
            AnchorPoint = Vector2.new(0, 0),
            BackgroundTransparency = 1,
        }, {
            ToggleBtn = E("TextButton", {
                Text = isPlayerVisible and "Hide Music" or "Show Music",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                [React.Event.Activated] = function()
                    setPlayerVisible(not isPlayerVisible)
                end,
            }, {
                Corner = E("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Stroke = E("UIStroke", {
                    Color = Color3.fromRGB(80, 80, 80),
                    Thickness = 2,
                }),
            }),
        }),

        PlayerContainer = isPlayerVisible and E("Frame", {
            Size = UDim2.new(0, 250, 0, 140),
            Position = UDim2.new(0.5, 0, 0.75, 0), -- Put back to bottom-center
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundTransparency = 1,
        }, {
            MainLayout = E("UIListLayout", { 
                HorizontalAlignment = Enum.HorizontalAlignment.Center, 
                VerticalAlignment = Enum.VerticalAlignment.Center, 
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder 
            }),

        Visualizer = E("Frame", { LayoutOrder = 1, Size = UDim2.new(0, 80, 0, 20), BackgroundTransparency = 1 }, {
            E("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 3) }),
            B1 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[1]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
            B2 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[2]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
            B3 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[3]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
        }),

        Title = E("TextLabel", { LayoutOrder = 2, Text = PLAYLIST[trackIndex].title, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextStrokeTransparency = 0.5 }),

        ProgressBar = E("Frame", { LayoutOrder = 3, Size = UDim2.new(0, 180, 0, 3), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.7, BorderSizePixel = 0 }, {
            Fill = E("Frame", { Size = progress:map(function(p) return UDim2.new(p, 0, 1, 0) end), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }),
        }),

        Controls = E("Frame", { LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, ClipsDescendants = false }, {
            E("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 15) }),

            MenuContainer = E("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                BackgroundTransparency = 1,
                ClipsDescendants = false,
            }, {
                Menu = E("ImageButton", {
                    Image = "rbxassetid://79284721074974", 
                    Size = UDim2.new(1, 1, 1, 1),
                    BackgroundTransparency = 1,
                    [React.Event.Activated] = function() setExpanded(not isExpanded) end,
                }),

                PlaylistMenu = isExpanded and E("Frame", {
                    Size = UDim2.new(0, 240, 0, math.min(#PLAYLIST * 34 + 60, 200)),
                    Position = UDim2.new(1, 10, 0, -15),
                    AnchorPoint = Vector2.new(1, 1),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                    BackgroundTransparency = 0.1,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, {
                    Corner = E("UICorner", { CornerRadius = UDim.new(0, 8) }),
                    Stroke = E("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1 }),
                    UIPadding = E("UIPadding", { 
                        PaddingLeft = UDim.new(0, 10), 
                        PaddingRight = UDim.new(0, 10), 
                        PaddingTop = UDim.new(0, 10), 
                        PaddingBottom = UDim.new(0, 10) 
                    }),
                    
                    Header = E("Frame", {
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundTransparency = 1,
                        ZIndex = 11,
                    }, {
                        Title = E("TextLabel", {
                            Text = "Playlist",
                            TextColor3 = Color3.fromRGB(220, 220, 220),
                            Font = Enum.Font.GothamBold,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Size = UDim2.new(1, -30, 1, 0),
                            BackgroundTransparency = 1,
                            ZIndex = 12,
                        }),
                        CloseBtn = E("TextButton", {
                            Text = "✕",
                            TextColor3 = Color3.fromRGB(255, 80, 80),
                            Font = Enum.Font.GothamBold,
                            TextSize = 16,
                            Size = UDim2.new(0, 24, 0, 24),
                            Position = UDim2.new(1, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(1, 0.5),
                            BackgroundTransparency = 1,
                            ZIndex = 12,
                            [React.Event.Activated] = function() setExpanded(false) end,
                        })
                    }),
                    
                    Divider = E("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0, 32),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.8,
                        BorderSizePixel = 0,
                        ZIndex = 11,
                    }),

                    Scroll = E("ScrollingFrame", {
                        Size = UDim2.new(1, 0, 1, -42),
                        Position = UDim2.new(0, 0, 0, 42),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 11,
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                    }, songElements)
                }),
            }),

            Prev = E("ImageButton", { Image = "rbxassetid://130750647080057", Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, [React.Event.Activated] = function() local n = trackIndex - 1; if n < 1 then n = #PLAYLIST end; playTrack(n) end }),
            Play = E("ImageButton", { Image = isPlaying and "rbxassetid://99570475438430" or "rbxassetid://126058622133572", Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, [React.Event.Activated] = function() if isPlaying then sound:Pause() else sound:Play() end; setPlaying(not isPlaying) end }),
            Next = E("ImageButton", { Image = "rbxassetid://138802853324251", Size = UDim2.new(0, 18, 0, 18), Rotation = 180, BackgroundTransparency = 1, [React.Event.Activated] = function() local n = trackIndex + 1; if n > #PLAYLIST then n = 1 end; playTrack(n) end }),
        }),
        })
    })
end

return MusicPlayer