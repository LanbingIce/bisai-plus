---@class ThemeManager
---@field SetTheme fun(self, name: string)
---@field GetActiveThemeIndex fun(self): integer
---@field GetWindowColor fun(self): Color
---@field GetWindowUnfocusedColor fun(self): Color
---@field GetTextColor fun(self): KColor
---@field GetButtonTextColor fun(self): KColor
---@field GetLabelTextColor fun(self): KColor
---@field GetButtonColor fun(self): Color
---@field GetButtonHighlightColor fun(self): Color
---@field GetThemeNames fun(self): string[]

---@class Theme
---@field Name string
---@field Window Color
---@field WindowUnfocused Color
---@field Button Color
---@field ButtonHighlight Color
---@field Text KColor
---@field ButtonText KColor
---@field LabelText KColor
---@field UseBackgroundImage boolean|nil
---@field BackgroundImageAlpha number|nil

---@type Theme[]
local Themes = {
	{
		Name = "Soul",
		Window = Color(0.10, 0.10, 0.11, 0.90),
		WindowUnfocused = Color(0.08, 0.08, 0.09, 0.72),
		Button = Color(0.20, 0.20, 0.21, 1.00),
		ButtonHighlight = Color(0.31, 0.76, 0.97, 1.00),
		Text = KColor(1.00, 1.00, 1.00, 1.00),
		ButtonText = KColor(1.00, 1.00, 1.00, 1.00),
		LabelText = KColor(1.00, 1.00, 1.00, 1.00),
	},

	{
		Name = "蓝冰",
		Window = Color(0.85, 0.90, 0.95, 0.95),
		WindowUnfocused = Color(0.70, 0.75, 0.80, 0.80),
		Button = Color(0.60, 0.75, 0.85, 1.00),
		ButtonHighlight = Color(0.20, 0.60, 0.80, 1.00),
		Text = KColor(1.00, 1.00, 1.00, 1.00),
		ButtonText = KColor(0.10, 0.20, 0.35, 1.00),
		LabelText = KColor(0.10, 0.20, 0.35, 1.00),
	},

	{
		Name = "Isaac Paper",
		Window = Color(0.84, 0.76, 0.69, 1.00),
		WindowUnfocused = Color(0.67, 0.61, 0.55, 0.80),
		Button = Color(0.75, 0.65, 0.58, 1.00),
		ButtonHighlight = Color(0.60, 0.20, 0.20, 1.00),
		Text = KColor(1.00, 1.00, 1.00, 1.00),
		ButtonText = KColor(0.20, 0.15, 0.15, 1.00),
		LabelText = KColor(0.20, 0.15, 0.15, 1.00),
	},

	{
		Name = "Matcha",
		Window = Color(0.15, 0.18, 0.16, 0.96),
		WindowUnfocused = Color(0.12, 0.14, 0.13, 0.77),
		Button = Color(0.22, 0.26, 0.23, 1.00),
		ButtonHighlight = Color(0.45, 0.60, 0.50, 1.00),
		Text = KColor(0.85, 0.90, 0.85, 1.00),
		ButtonText = KColor(0.85, 0.90, 0.85, 1.00),
		LabelText = KColor(0.85, 0.90, 0.85, 1.00),
	},

	{
		Name = "Mocha",
		Window = Color(0.12, 0.12, 0.18, 0.95),
		WindowUnfocused = Color(0.10, 0.10, 0.14, 0.76),
		Button = Color(0.19, 0.19, 0.27, 1.00),
		ButtonHighlight = Color(0.53, 0.47, 0.65, 1.00),
		Text = KColor(0.80, 0.82, 0.89, 1.00),
		ButtonText = KColor(0.80, 0.82, 0.89, 1.00),
		LabelText = KColor(0.80, 0.82, 0.89, 1.00),
	},



	{
		Name = "Nord",
		Window = Color(0.18, 0.20, 0.25, 0.96),
		WindowUnfocused = Color(0.14, 0.16, 0.20, 0.77),
		Button = Color(0.26, 0.30, 0.37, 1.00),
		ButtonHighlight = Color(0.53, 0.75, 0.82, 1.00),
		Text = KColor(0.93, 0.94, 0.96, 1.00),
		ButtonText = KColor(0.93, 0.94, 0.96, 1.00),
		LabelText = KColor(0.93, 0.94, 0.96, 1.00),
	},

	{
		Name = "Abyss",
		Window = Color(0.05, 0.10, 0.14, 0.95),
		WindowUnfocused = Color(0.04, 0.08, 0.11, 0.76),
		Button = Color(0.10, 0.25, 0.30, 1.00),
		ButtonHighlight = Color(0.00, 0.80, 0.80, 1.00),
		Text = KColor(0.90, 0.95, 0.95, 1.00),
		ButtonText = KColor(0.90, 0.95, 0.95, 1.00),
		LabelText = KColor(0.90, 0.95, 0.95, 1.00),
	},


	{
		Name = "Dracula",
		Window = Color(0.16, 0.17, 0.21, 0.95),
		WindowUnfocused = Color(0.13, 0.14, 0.17, 0.76),
		Button = Color(0.27, 0.29, 0.36, 1.00),
		ButtonHighlight = Color(1.00, 0.47, 0.77, 1.00),
		Text = KColor(0.97, 0.97, 0.99, 1.00),
		ButtonText = KColor(0.97, 0.97, 0.99, 1.00),
		LabelText = KColor(0.97, 0.97, 0.99, 1.00),
	},

	{
		Name = "Cyberpunk",
		Window = Color(0.02, 0.01, 0.05, 0.95),
		WindowUnfocused = Color(0.02, 0.01, 0.04, 0.76),
		Button = Color(0.08, 0.04, 0.15, 1.00),
		ButtonHighlight = Color(0.00, 1.00, 0.81, 1.00),
		Text = KColor(1.00, 1.00, 1.00, 1.00),
		ButtonText = KColor(1.00, 1.00, 1.00, 1.00),
		LabelText = KColor(1.00, 1.00, 1.00, 1.00),
	},

	{
		Name = "Hellfire",
		Window = Color(0.10, 0.02, 0.02, 0.95),
		WindowUnfocused = Color(0.08, 0.02, 0.02, 0.76),
		Button = Color(0.30, 0.05, 0.05, 1.00),
		ButtonHighlight = Color(1.00, 0.20, 0.00, 1.00),
		Text = KColor(1.00, 0.90, 0.80, 1.00),
		ButtonText = KColor(1.00, 0.90, 0.80, 1.00),
		LabelText = KColor(1.00, 0.90, 0.80, 1.00),
	},

	{
		Name = "Devil",
		Window = Color(0.17, 0.11, 0.11, 1.00),
		WindowUnfocused = Color(0.14, 0.09, 0.09, 0.80),
		Button = Color(0.25, 0.16, 0.16, 1.00),
		ButtonHighlight = Color(1.00, 0.27, 0.27, 1.00),
		Text = KColor(0.88, 0.88, 0.88, 1.00),
		ButtonText = KColor(0.88, 0.88, 0.88, 1.00),
		LabelText = KColor(0.88, 0.88, 0.88, 1.00),
	},

	{
		Name = "Midnight",
		Window = Color(0.07, 0.07, 0.12, 0.95),
		WindowUnfocused = Color(0.06, 0.06, 0.10, 0.76),
		Button = Color(0.12, 0.12, 0.20, 1.00),
		ButtonHighlight = Color(0.85, 0.65, 0.13, 1.00),
		Text = KColor(0.95, 0.95, 1.00, 1.00),
		ButtonText = KColor(0.95, 0.95, 1.00, 1.00),
		LabelText = KColor(0.95, 0.95, 1.00, 1.00),
	},

	{
		Name = "Forest",
		Window = Color(0.10, 0.15, 0.12, 0.95),
		WindowUnfocused = Color(0.08, 0.12, 0.10, 0.76),
		Button = Color(0.18, 0.25, 0.20, 1.00),
		ButtonHighlight = Color(0.48, 0.75, 0.35, 1.00),
		Text = KColor(0.90, 1.00, 0.90, 1.00),
		ButtonText = KColor(0.90, 1.00, 0.90, 1.00),
		LabelText = KColor(0.90, 1.00, 0.90, 1.00),
	},

	{
		Name = "Retro80s",
		Window = Color(0.12, 0.05, 0.15, 0.95),
		WindowUnfocused = Color(0.10, 0.04, 0.12, 0.76),
		Button = Color(0.25, 0.10, 0.30, 1.00),
		ButtonHighlight = Color(1.00, 0.00, 0.70, 1.00),
		Text = KColor(0.00, 1.00, 1.00, 1.00),
		ButtonText = KColor(0.00, 1.00, 1.00, 1.00),
		LabelText = KColor(0.00, 1.00, 1.00, 1.00),
	},

	{
		Name = "Minimalist",
		Window = Color(0.92, 0.92, 0.94, 0.95),
		WindowUnfocused = Color(0.74, 0.74, 0.75, 0.76),
		Button = Color(0.85, 0.85, 0.88, 1.00),
		ButtonHighlight = Color(0.20, 0.20, 0.25, 1.00),
		Text = KColor(1.00, 1.00, 1.00, 1.00),
		ButtonText = KColor(0.10, 0.10, 0.15, 1.00),
		LabelText = KColor(0.10, 0.10, 0.15, 1.00),
	},

	{
		Name = "Volcano",
		Window = Color(0.05, 0.05, 0.05, 0.98),
		WindowUnfocused = Color(0.04, 0.04, 0.04, 0.78),
		Button = Color(0.15, 0.10, 0.10, 1.00),
		ButtonHighlight = Color(1.00, 0.40, 0.00, 1.00),
		Text = KColor(1.00, 0.90, 0.80, 1.00),
		ButtonText = KColor(1.00, 0.90, 0.80, 1.00),
		LabelText = KColor(1.00, 0.90, 0.80, 1.00),
	},

	{
		Name = "三只熊",
		Window = Color(0.14, 0.12, 0.10, 0.96),
		WindowUnfocused = Color(0.11, 0.10, 0.08, 0.77),
		Button = Color(0.36, 0.28, 0.20, 1.00),
		ButtonHighlight = Color(0.95, 0.95, 0.95, 1.00),
		Text = KColor(0.98, 0.98, 0.98, 1.00),
		ButtonText = KColor(0.98, 0.98, 0.98, 1.00),
		LabelText = KColor(0.98, 0.98, 0.98, 1.00),
	},

	{
		Name = "自定义",
		Window = Color(0.10, 0.10, 0.11, 0.90),
		WindowUnfocused = Color(0.08, 0.08, 0.09, 0.72),
		Button = Color(0.20, 0.20, 0.21, 1.00),
		ButtonHighlight = Color(0.31, 0.76, 0.97, 1.00),
		Text = KColor(1.00, 1.00, 1.00, 1.00),
		ButtonText = KColor(1.00, 1.00, 1.00, 1.00),
		LabelText = KColor(1.00, 1.00, 1.00, 1.00),
		UseBackgroundImage = false,
		BackgroundImageAlpha = 1.0,
	},
}
local ActiveThemeIndex = 1
local BreathingSpeed = 0.1
local ThemeManager = {}

function ThemeManager:LoadCustomTheme(customThemeConfig)
	local customTheme = Themes[#Themes]
	if customTheme.Name ~= "自定义" then return end

	if not customThemeConfig then
		-- 重置为默认值
		local defaultTheme = Themes[1] -- 假设第一个是默认主题
		customTheme.Window = defaultTheme.Window
		customTheme.WindowUnfocused = defaultTheme.WindowUnfocused
		customTheme.Button = defaultTheme.Button
		customTheme.ButtonHighlight = defaultTheme.ButtonHighlight
		customTheme.Text = defaultTheme.Text
		customTheme.ButtonText = defaultTheme.ButtonText
		customTheme.LabelText = defaultTheme.LabelText
		return
	end

	local function applyColor(key, isKColor)
		local c = customThemeConfig[key]
		if c then
			if isKColor then
				customTheme[key] = KColor(c.R or 1, c.G or 1, c.B or 1, c.A or 1)
			else
				customTheme[key] = Color(c.R or 1, c.G or 1, c.B or 1, c.A or 1)
			end
		else
			-- 如果没有单独设置，则回退到普通文本颜色
			if key == "ButtonText" or key == "LabelText" then
				local textC = customThemeConfig["Text"]
				if textC then
					customTheme[key] = KColor(textC.R or 1, textC.G or 1, textC.B or 1, textC.A or 1)
				else
					customTheme[key] = KColor(1, 1, 1, 1)
				end
			elseif isKColor then
				customTheme[key] = KColor(1, 1, 1, 1)
			else
				customTheme[key] = Color(1, 1, 1, 1)
			end
		end
	end

	applyColor("Window", false)
	applyColor("WindowUnfocused", false)
	applyColor("Button", false)
	applyColor("ButtonHighlight", false)
	applyColor("Text", true)
	applyColor("ButtonText", true)
	applyColor("LabelText", true)
	
	customTheme.UseBackgroundImage = customThemeConfig.UseBackgroundImage or false
	customTheme.BackgroundImageAlpha = customThemeConfig.BackgroundImageAlpha or 1.0
end

---@param name string
function ThemeManager:SetTheme(name)
	if type(name) == "string" then
		for i = 1, #Themes do
			if Themes[i].Name == name then
				ActiveThemeIndex = i
				return
			end
		end
	end
end

---@nodiscard
---@return integer
function ThemeManager:GetActiveThemeIndex()
	return ActiveThemeIndex
end

---@nodiscard
---@return Color
function ThemeManager:GetWindowColor()
	return Themes[ActiveThemeIndex].Window
end

---@nodiscard
---@return Color
function ThemeManager:GetWindowUnfocusedColor()
	return Themes[ActiveThemeIndex].WindowUnfocused
end

---@nodiscard
---@return KColor
function ThemeManager:GetTextColor()
	return Themes[ActiveThemeIndex].Text
end

---@nodiscard
---@return KColor
function ThemeManager:GetButtonTextColor()
	local theme = Themes[ActiveThemeIndex]
	return theme.ButtonText or theme.Text
end

---@nodiscard
---@return KColor
function ThemeManager:GetLabelTextColor()
	local theme = Themes[ActiveThemeIndex]
	return theme.LabelText or theme.Text
end

---@nodiscard
---@return Color
function ThemeManager:GetButtonColor()
	return Themes[ActiveThemeIndex].Button
end

---@nodiscard
---@return Color
function ThemeManager:GetButtonHighlightColor()
	local baseColor = Themes[ActiveThemeIndex].ButtonHighlight
	local alpha = baseColor.A
	local time = Isaac.GetFrameCount()
	local speed = BreathingSpeed
	local pulse = (math.sin(time * speed) + 1) / 4 + 0.5
	alpha = alpha * pulse
	return Color(baseColor.R, baseColor.G, baseColor.B, alpha)
end

---@nodiscard
---@return string[]
function ThemeManager:GetThemeNames()
	local names = {}
	for i = 1, #Themes do
		names[i] = Themes[i].Name
	end
	return names
end

function ThemeManager:UpdateCustomThemeColor(key, r, g, b, a)
	local customTheme = Themes[#Themes]
	if customTheme.Name ~= "自定义" then return end

	r = r or 1
	g = g or 1
	b = b or 1
	a = a or 1

	if key == "Window" or key == "WindowUnfocused" or key == "Button" or key == "ButtonHighlight" then
		customTheme[key] = Color(r, g, b, a)
	elseif key == "Text" or key == "ButtonText" or key == "LabelText" then
		customTheme[key] = KColor(r, g, b, a)
		if key == "Text" then
			-- 如果修改了普通文本，且没有单独设置按钮文本或标签文本，则同步更新
			local config = require("bisai+.config_manager"):GetConfig()
			if config and config.CustomTheme then
				if not config.CustomTheme.ButtonText then
					customTheme.ButtonText = KColor(r, g, b, a)
				end
				if not config.CustomTheme.LabelText then
					customTheme.LabelText = KColor(r, g, b, a)
				end
			end
		end
	end
end

function ThemeManager:GetCustomThemeColor(key)
	local customTheme = Themes[#Themes]
	if customTheme.Name ~= "自定义" then return end
	return customTheme[key]
end

function ThemeManager:IsUsingBackgroundImage()
	local theme = Themes[ActiveThemeIndex]
	return theme.UseBackgroundImage == true
end

function ThemeManager:GetBackgroundImageAlpha()
	local theme = Themes[ActiveThemeIndex]
	return theme.BackgroundImageAlpha or 1.0
end

return ThemeManager
