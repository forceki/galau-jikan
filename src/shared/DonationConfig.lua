local DonationConfig = {
    VARIANTS = {
        -- { amount = 1,   id = 3553078542, color = Color3.fromRGB(120, 200, 120) },
        { amount = 5,   id = 3553078604, color = Color3.fromRGB(100, 180, 220) },
        { amount = 10,  id = 3558590940, color = Color3.fromRGB(180, 120, 220) },
        { amount = 25,  id = 3558591155, color = Color3.fromRGB(180, 120, 220) },
        { amount = 50,  id = 3558591206, color = Color3.fromRGB(220, 180, 100) },
        -- { amount = 100, id = 1234571, color = Color3.fromRGB(220, 100, 100) },
    }
}

-- Create a lookup map for the server based on the variants
DonationConfig.PRODUCT_VALUES = {}
for _, variant in ipairs(DonationConfig.VARIANTS) do
    DonationConfig.PRODUCT_VALUES[variant.id] = variant.amount
end

return DonationConfig
