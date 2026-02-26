---@class ConfigManager
---@field SetConfig fun(self: ConfigManager, config?: Config)
---@field GetConfig fun(self: ConfigManager): Config

---@class Config
---@field Theme string
---@field CustomTheme table

local ConfigManager = {}
local Utils = require("bisai+.utils")

---@type Config
local DefaultConfig = {
	Theme = "Soul",
	CustomTheme = {
		Window = {R=0.1, G=0.1, B=0.1, A=0.9},
		WindowUnfocused = {R=0.08, G=0.08, B=0.09, A=0.72},
		Button = {R=0.2, G=0.2, B=0.21, A=1.0},
		ButtonHighlight = {R=0.31, G=0.76, B=0.97, A=1.0},
		Text = {R=1.0, G=1.0, B=1.0, A=1.0},
		ButtonText = {R=1.0, G=1.0, B=1.0, A=1.0},
		LabelText = {R=1.0, G=1.0, B=1.0, A=1.0},
	}
}

---@type Config
local Config = setmetatable({}, { __index = DefaultConfig })

---@param config? Config
function ConfigManager:SetConfig(config)
	local newConfig = {}
	if type(config) == "table" then
		newConfig = Utils.CloneTable(config)
	end
	setmetatable(newConfig, { __index = DefaultConfig })
	Config = newConfig
end

---@return Config
---@nodiscard
function ConfigManager:GetConfig()
	return Utils.CloneTable(Config)
end

return ConfigManager
