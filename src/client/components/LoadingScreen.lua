local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local React = require(ReplicatedStorage.Packages.React)
local E = React.createElement

local function LoadingScreen(props)
    local progress, setProgress = React.useState(0)
    local isFading, setFading = React.useState(false)
    local fadeTransparency, setFadeTransparency = React.useState(0)
    local loadingText, setLoadingText = React.useState("LOADING ASSETS...")

    React.useEffect(function()
        local isMounted = true

        task.spawn(function()
            if not game:IsLoaded() then
                game.Loaded:Wait()
            end
            
            task.spawn(function()
                for i = 1, 85 do
                    if not isMounted or isFading then break end
                    setProgress(i / 100)
                    task.wait(0.01)
                end
            end)
            
            local toLoad = {workspace, game:GetService("Lighting"), game:GetService("ReplicatedStorage")}
            pcall(function()
                ContentProvider:PreloadAsync(toLoad)
            end)
            
            if not isMounted then return end
            
            setLoadingText("Loading...")
            setProgress(1)
            task.wait(1)
            
            setFading(true)
            local fadeSteps = 20
            for i = 1, fadeSteps do
                if not isMounted then return end
                setFadeTransparency(i / fadeSteps)
                task.wait(0.02)
            end
            
            if isMounted and props.onFinish then
                props.onFinish()
            end
        end)

        return function()
            isMounted = false
        end
    end, {props.onFinish})

    return E("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BackgroundTransparency = fadeTransparency,
        ZIndex = 1000,
        Active = true,
    }, {
        Center = E("Frame", {
            Size = UDim2.new(0, 300, 0, 100),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
        }, {
            UIListLayout = E("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 16)
            }),
            Title = E("TextLabel", {
                LayoutOrder = 1,
                Text = loadingText,
                TextColor3 = Color3.fromRGB(250, 250, 250),
                TextTransparency = fadeTransparency,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
            }),
            BarContainer = E("Frame", {
                LayoutOrder = 2,
                Size = UDim2.new(1, 0, 0, 6),
                BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                BackgroundTransparency = fadeTransparency,
            }, {
                UICorner = E("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Fill = E("Frame", {
                    Size = UDim2.new(progress, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(120, 200, 255),
                    BackgroundTransparency = fadeTransparency,
                    BorderSizePixel = 0,
                }, {
                    UICorner = E("UICorner", { CornerRadius = UDim.new(1, 0) })
                })
            })
        })
    })
end

return LoadingScreen
