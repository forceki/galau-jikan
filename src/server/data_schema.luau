local DataSchema = {}

-- Default schema template
DataSchema.default = {
    player_id = "",
    player_info = {
        username = "",
        display_name = "",
    },
    donation = 0,
    galau_time = 0,
    last_login = 0,
    last_position = nil,
}

-- Init function: fills schema with real Player data
function DataSchema.init(player: Player)
    return {
        player_id = tostring(player.UserId),
        player_info = {
            username = player.Name,
            display_name = player.DisplayName,
        },
        donation = 0,
        galau_time = 0,
        last_login = os.time(),
        last_position = nil,
    }
end

return DataSchema
