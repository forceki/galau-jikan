local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local App = require(script:WaitForChild("components"):WaitForChild("App"))

local root = ReactRoblox.createRoot(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
root:render(React.createElement(App))