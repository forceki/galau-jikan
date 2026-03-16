local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.React)
local E = React.createElement

local DonationConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DonationConfig"))
local DONATION_VARIANTS = DonationConfig.VARIANTS

local function DonateUI()
    local isOpen, setIsOpen = React.useState(false)

    local function promptPurchase(productId)
        MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
    end

    local variantElements = {
        Layout = E("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }),
        Pad = E("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
        })
    }

    for i, variant in ipairs(DONATION_VARIANTS) do
        variantElements["Variant" .. i] = E("TextButton", {
            LayoutOrder = i,
            Text = "Donate " .. variant.amount .. " R$",
            Size = UDim2.new(1, -20, 0, 50),
            BackgroundColor3 = variant.color,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            [React.Event.Activated] = function()
                promptPurchase(variant.id)
            end,
        }, {
            Corner = E("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Stroke = E("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0),
                Transparency = 0.5,
                Thickness = 1,
            }),
            Shadow = E("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 4),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.7,
                ZIndex = -1,
            }, {
                Corner = E("UICorner", { CornerRadius = UDim.new(0, 8) })
            })
        })
    end

    return E("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    }, {
        DonateButtonContainer = E("Frame", {
            Size = UDim2.new(0, 120, 0, 40),
            Position = UDim2.new(0, 20, 0, 70),
            BackgroundTransparency = 1,
        }, {
            DonateButton = E("TextButton", {
                Text = "💎 Donate",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(230, 200, 80),
                TextColor3 = Color3.fromRGB(60, 40, 10),
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                [React.Event.Activated] = function()
                    setIsOpen(not isOpen)
                end,
            }, {
                Corner = E("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Stroke = E("UIStroke", {
                    Color = Color3.fromRGB(180, 140, 40),
                    Thickness = 2,
                }),
            }),
        }),

        DonateModal = isOpen and E("Frame", {
            Size = UDim2.new(0, 300, 0, 420),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BackgroundTransparency = 0.1,
            Active = true,
        }, {
            Corner = E("UICorner", { CornerRadius = UDim.new(0, 12) }),
            Stroke = E("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Thickness = 2 }),
            
            Header = E("TextLabel", {
                Text = "Support The Game!",
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBlack,
                TextSize = 22,
            }),

            CloseButton = E("TextButton", {
                Text = "✕",
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(1, -10, 0, 10),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 100, 100),
                Font = Enum.Font.GothamBold,
                TextSize = 20,
                [React.Event.Activated] = function()
                    setIsOpen(false)
                end,
            }),

            Divider = E("Frame", {
                Size = UDim2.new(1, -40, 0, 1),
                Position = UDim2.new(0, 20, 0, 60),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.8,
                BorderSizePixel = 0,
            }),

            List = E("ScrollingFrame", {
                Size = UDim2.new(1, -20, 1, -80),
                Position = UDim2.new(0, 10, 0, 70),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
            }, variantElements)
        })
    })
end

return DonateUI
