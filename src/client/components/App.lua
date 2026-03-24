local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local E = React.createElement

local LoadingScreen = require(script.Parent.LoadingScreen)
local MusicPlayer = require(script.Parent.MusicPlayer)
local DonateUI = require(script.Parent.DonateUI)
local EmotesMenu = require(script.Parent.EmotesMenu)
local GalauPointsUI = require(script.Parent.GalauPointsUI)

local function App()
    local isLoaded, setLoaded = React.useState(false)

    return E("ScreenGui", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true, -- Fitur ini membuat layarnya menutupi notch top-bar roblox di layar HP sepenuhnya.
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, {
        -- UI Musik dan Donate hanya akan dimunculkan SETELAH loading screen selesai sepenuhnya.
        MusicApp = isLoaded and E(MusicPlayer),
        DonateApp = isLoaded and E(DonateUI),
        EmotesApp = isLoaded and E(EmotesMenu),
        GalauPointsApp = isLoaded and E(GalauPointsUI),
        
        -- Mula-mula ini akan memunculkan loading screen
        Loading = not isLoaded and E(LoadingScreen, {
            onFinish = function()
                setLoaded(true)
            end,
        })
    })
end

return App
