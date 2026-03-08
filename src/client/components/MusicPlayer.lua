local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
local E = React.createElement

local PLAYLIST = {
    {id = "rbxassetid://81549849467553", title = "あなたのことか好きたなんて言えないんてすfeat 杏沙子コバソロ"},
    {id = "rbxassetid://128560685759007", title = "ヨルシカ - ただ君に晴れ"},
    {id = "rbxassetid://134417754010566", title = "りりあriria. 最後のバイバイsaigo no bye bye"},
}

local function MusicPlayer()
    local trackIndex, setTrackIndex = React.useState(1)
    local isPlaying, setPlaying = React.useState(false)
    local barHeights, setBarHeights = React.useBinding({3, 3, 3, 3, 3})
    local progress, setProgress = React.useBinding(0)
    local sound = game.SoundService:WaitForChild("Musics")

    -- Fungsi untuk pindah lagu (dibuat agar bisa dipanggil berulang)
    local function playTrack(index)
        sound:Stop()
        sound.SoundId = PLAYLIST[index].id
        sound.TimePosition = 0
        if isPlaying then 
            sound:Play() 
        end
    end

    local function nextTrack()
        local newIndex = trackIndex + 1
        if newIndex > #PLAYLIST then newIndex = 1 end
        setTrackIndex(newIndex)
        -- Kita paksa isPlaying jadi true karena user biasanya ingin lagu lanjut terus
        setPlaying(true)
        
        -- Logic play lagu baru
        sound:Stop()
        sound.SoundId = PLAYLIST[newIndex].id
        sound:Play()
    end

    -- Effect untuk Visualizer & Progress Bar
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

    -- NEW: Effect untuk Auto-Next saat lagu selesai
    React.useEffect(function()
        local endedConnection = sound.Ended:Connect(function()
            nextTrack()
        end)
        
        return function()
            endedConnection:Disconnect()
        end
    end, {trackIndex, isPlaying}) -- Re-bind saat index berubah

    return E("Frame", {
        Size = UDim2.new(0, 250, 0, 140),
        Position = UDim2.new(0.5, 0, 0.75, 0), 
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
    }, {
        Layout = E("UIListLayout", { 
            HorizontalAlignment = Enum.HorizontalAlignment.Center, 
            VerticalAlignment = Enum.VerticalAlignment.Center, 
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder 
        }),

        Visualizer = E("Frame", { LayoutOrder = 1, Size = UDim2.new(0, 80, 0, 25), BackgroundTransparency = 1 }, {
            Layout = E("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 3) }),
            B1 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[1]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
            B2 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[2]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
            B3 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[3]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
            B4 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[4]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
            B5 = E("Frame", { Size = barHeights:map(function(v) return UDim2.new(0, 3, 0, v[5]) end), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }),
        }),
    
        Title = E("TextLabel", { 
            LayoutOrder = 2, 
            Text = PLAYLIST[trackIndex].title, 
            Font = Enum.Font.GothamBold, 
            TextSize = 14, 
            TextColor3 = Color3.new(1, 1, 1), 
            Size = UDim2.new(1, 0, 0, 20), 
            BackgroundTransparency = 1, 
            TextStrokeTransparency = 0.5 
        }),

        PB = E("Frame", { 
            LayoutOrder = 3, 
            Size = UDim2.new(0, 180, 0, 3), 
            BackgroundColor3 = Color3.new(1, 1, 1), 
            BackgroundTransparency = 0.7, 
            BorderSizePixel = 0 
        }, {
            Fill = E("Frame", { Size = progress:map(function(p) return UDim2.new(p, 0, 1, 0) end), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }),
        }),

        Controls = E("Frame", { 
            LayoutOrder = 4, 
            Size = UDim2.new(1, 0, 0, 35), 
            BackgroundTransparency = 1 
        }, {
            UIList = E("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 15) }),
            Prev = E("ImageButton", { Image = "rbxassetid://130750647080057", Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, [React.Event.Activated] = function() local n = trackIndex - 1 if n < 1 then n = #PLAYLIST end setTrackIndex(n) playTrack(n) end }),
            Play = E("ImageButton", { Image = isPlaying and "rbxassetid://99570475438430" or "rbxassetid://126058622133572", Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, [React.Event.Activated] = function() if isPlaying then sound:Pause() else sound:Play() end setPlaying(not isPlaying) end }),
            Next = E("ImageButton", { Image = "rbxassetid://138802853324251", Size = UDim2.new(0, 18, 0, 18), Rotation = 180, BackgroundTransparency = 1, [React.Event.Activated] = nextTrack }),
        })
    })
end

return MusicPlayer