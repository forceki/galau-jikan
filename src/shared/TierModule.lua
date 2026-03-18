local TierModule = {}

TierModule.Tiers = {
    {min = 50000, title = "Guardian of the Abyss", color = Color3.fromHex("#00FFFF")},
    {min = 25000, title = "Echo of the Night", color = Color3.fromHex("#4B0082")},
    {min = 10000, title = "The Relapsed", color = Color3.fromHex("#DC143C")},
    {min = 7500,  title = "Night Watcher", color = Color3.fromHex("#FF8C00")},
    {min = 5000,  title = "Eternal Wanderer", color = Color3.fromHex("#FFD700")},
    {min = 2500,  title = "Solitude Seeker", color = Color3.fromHex("#98FB98")},
    {min = 1000,  title = "The Melancholic", color = Color3.fromHex("#D8BFD8")},
    {min = 500,   title = "Midnight Thinker", color = Color3.fromHex("#ADD8E6")},
    {min = 100,   title = "Restless Soul", color = Color3.fromHex("#FFFFFF")},
    {min = 0,     title = "The Passerby", color = Color3.fromHex("#A9A9A9")},
}

function TierModule.getData(points)
    for _, tier in ipairs(TierModule.Tiers) do
        if points >= tier.min then
            return tier.title, tier.color
        end
    end
end

return TierModule