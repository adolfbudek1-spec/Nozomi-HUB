--[[============== CONFIG ==============]]
local Config = {
	-- ESP
	ESP_ZOMBIE                  = false,
	ESP_PLAYER                  = false,
	ESP_PLAYER_LABEL            = false,
	ESP_PLAYER_LABEL_DISTANCE   = 1000,
	ESP_NPC                     = false,

	-- ESP Player visual
	ESP_PLAYER_FILL_COLOR       = Color3.fromRGB(255, 255, 255),
	ESP_PLAYER_OUTLINE_COLOR    = Color3.fromRGB(255, 0, 0),
	ESP_PLAYER_FILL_TRANS       = 0.5,
	ESP_PLAYER_OUTLINE_TRANS    = 0,
	ESP_PLAYER_LABEL_COLOR      = Color3.fromRGB(255, 255, 255),
	ESP_PLAYER_LABEL_TRANS      = 0,

	-- Platform
	PLATFORM_SHOW               = false,
	PLATFORM_SPEED              = 0.4,
	PLATFORM_TRANSPARENCY       = 0.4,
	PLATFORM_MATERIAL           = Enum.Material.Asphalt,

	-- Remove Object
	REMOVE_OBJECT               = false,
}

return Config
