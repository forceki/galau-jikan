local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local MusicPlayer = require(script:WaitForChild("components"):WaitForChild("MusicPlayer"))

local root = ReactRoblox.createRoot(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
root:render(React.createElement("ScreenGui", {
    ResetOnSpawn = false,
}, {
    App = React.createElement(MusicPlayer)
}))