local MessageBus = require("bisai+.message_bus")
local ConfigManager = require("bisai+.config_manager")
local Shared = require("bisai+.shared")
local Messages = require("bisai+.messages")
local ThemeManager = require("bisai+.theme_manager")
local Utils = require("bisai+.utils")

---@type wga_menu
local WGA = include("worst gui api")

local NIL_SPRITE = Sprite()
local NIL_FUNCTION = function() end

local FontPlain = Font()
local FontOutline = Font()
local FontMono = Font()

do
	local modPath
	local _, err = pcall(require, "")
	local path = err and err:gsub("\\", "/"):match(".*no file '(.*/).lua'")
	modPath = path
	FontPlain:Load(modPath .. "resources/font/fusion_pixel_font_12px_plain/fusion_pixel_font_12px_plain.fnt")
	FontOutline:Load(modPath .. "resources/font/fusion_pixel_font_12px_outline/fusion_pixel_font_12px_outline.fnt")
	FontMono:Load("font/terminus.fnt")
end

local TextBoxSprite = Sprite()
local StageIconSprite = Sprite()

do
	TextBoxSprite:Load("gfx/wdm_editor/ui copy.anm2", true)
	TextBoxSprite:Play("custom textbox_bg")
	StageIconSprite:Load("gfx/ui/stage/progress.anm2", true)
end

local WindowName = {
	MAIN = "bisai+_main_win",
	THEME = "bisai+_theme_win",
	CUSTOM_THEME = "bisai+_custom_theme_win",
	CONTROL = "bisai+_controls_win",
	HELP = "bisai+_help_win",
}

local Data = {
	Runtime = {
		PlayerName = "未知角色",
		DeathCount = 0,
		ControllerIndex = 0,
		MouseMoved = false,
		LastMovedTime = 0,
		Goal = Shared.Goal.MEGA_SATAN,
		State = Shared.State.READY,
		Timer = {
			StoredTime = 0,
			StartTime = 0,
		},
		Record = {
			Time = 0,
			LevelStage = 0,
			StageType = 0,
			IsAscent = false,
			IsXL = false,
			LevelName = "无",
			LevelWeight = 0,
		},
		IsRollingGoal = false,
		GoalRollSequence = {},
		GoalRollIndex = 1,
		GoalRollTimer = 0,
		TargetGoal = 1,
	},
}

local function IsCombinationBanned(playerType, goal, rollingType)
	if not BISAI_PLUS.BannedCombinations then
		return false
	end

	for _, ban in ipairs(BISAI_PLUS.BannedCombinations) do
		local matchPlayer = (ban.PlayerType == nil) or (ban.PlayerType == playerType)
		local matchGoal = (ban.Goal == nil) or (ban.Goal == goal)
		if matchPlayer and matchGoal then
			if rollingType == "goal" and ban.Goal == nil then
				-- 仅仅ban了角色，不影响roll终点
			elseif rollingType == "playertype" and ban.PlayerType == nil then
				-- 仅仅ban了终点，不影响roll角色
			else
				return true
			end
		end
	end
	return false
end

local function RollGoal()
	if Data.Runtime.IsRollingGoal then
		return
	end

	local goal = -1
	local playerType = Game():GetPlayer(0):GetPlayerType()

	while goal == -1 or IsCombinationBanned(playerType, goal, "goal") do
		goal = Random() % #Shared.GoalData + 1
	end

	-- 开始滚动动画
	Data.Runtime.IsRollingGoal = true
	Data.Runtime.TargetGoal = goal
	Data.Runtime.GoalRollSequence = {}

	local currentGoal = Data.Runtime.Goal

	-- 预先计算出从当前位置到目标位置，需要走多少步
	local stepsToTarget = 0
	local tempGoal = currentGoal
	while tempGoal ~= goal do
		repeat
			tempGoal = (tempGoal % #Shared.GoalData) + 1
		until not IsCombinationBanned(playerType, tempGoal, "goal")
		stepsToTarget = stepsToTarget + 1
	end

	-- 计算出合法的终点总数
	local validGoalCount = 0
	for i = 1, #Shared.GoalData do
		if not IsCombinationBanned(playerType, i, "goal") then
			validGoalCount = validGoalCount + 1
		end
	end

	if validGoalCount > 1 then
		-- 固定的减速延迟序列（最后24步，约1.8秒）
		-- 保证每次滚动的“刹车手感”完全一模一样
		local fixedDelays = {
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			2,
			2,
			2,
			3,
			3,
			4,
			4,
			5,
			6,
			7,
			9,
			11,
			14,
			18,
		}
		local minRolls = #fixedDelays

		-- 计算总步数：必须是 stepsToTarget + N * validGoalCount，且至少为 minRolls
		local n = math.ceil((minRolls - stepsToTarget) / validGoalCount)
		if n < 0 then
			n = 0
		end
		local totalRolls = stepsToTarget + n * validGoalCount

		local fastSteps = totalRolls - minRolls

		tempGoal = currentGoal
		for i = 1, totalRolls do
			repeat
				tempGoal = (tempGoal % #Shared.GoalData) + 1
			until not IsCombinationBanned(playerType, tempGoal, "goal")

			local delay = 1
			if i > fastSteps then
				delay = fixedDelays[i - fastSteps]
			end

			table.insert(Data.Runtime.GoalRollSequence, { goal = tempGoal, delay = delay })
		end
	else
		-- 如果只有一个合法终点，直接结束
		table.insert(Data.Runtime.GoalRollSequence, { goal = goal, delay = 1 })
	end

	Data.Runtime.GoalRollIndex = 1
	Data.Runtime.GoalRollTimer = Data.Runtime.GoalRollSequence[1].delay
end

local function RollPlayerType()
	SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
	local playerType = PlayerType.PLAYER_POSSESSOR
	local currentGoal = Data.Runtime.Goal

	while playerType == PlayerType.PLAYER_POSSESSOR or IsCombinationBanned(playerType, currentGoal, "playertype") do
		playerType = Shared.ValidPlayers[Random() % #Shared.ValidPlayers + 1]
	end
	local seed = 0
	while seed == 0 do
		seed = Random()
	end
	MessageBus:Send(Messages.Command.SET_PLAYER_TYPE, { PlayerType = playerType })
	MessageBus:Send(Messages.Command.SET_SEED, { Seed = seed })
end

---@return string
local function GetCurrentPlayerName()
	local player = Game():GetPlayer(0)
	local name = Shared.PlayerNameMap[player:GetPlayerType()] or player:GetName() or "未知角色"
	return name
end

local function UpdateRuntimeData(payload)
	Utils.DeepAssignExisting(Data.Runtime, payload)
end

local function UpdateWindowBackColors()
	for name, win in pairs(WGA.Windows.menus) do
		if name == WindowName.MAIN and ThemeManager:IsUsingBackgroundImage() then
			win.backcolor = Color(0, 0, 0, 0)
			win.backcolornfocus = Color(0, 0, 0, 0)
			win.RenderCustomMenuBack = function() end -- 完全禁用默认背景渲染
		else
			win.backcolor = ThemeManager:GetWindowColor()
			win.backcolornfocus = ThemeManager:GetWindowUnfocusedColor()
			win.RenderCustomMenuBack = nil -- 恢复默认背景渲染
		end
	end
end

local function AddStyledButton(windowName, pos, size, text, onClick, highlightCheck, onHover)
	local buttonName = windowName
		.. tostring(pos)
		.. tostring(size)
		.. text
		.. tostring(onClick)
		.. tostring(highlightCheck)
		.. tostring(onHover)
	local btn

	local function OnRender(renderPos)
		local isHovered = btn and btn.IsSelected and btn.IsSelected > 0

		if isHovered and onHover then
			onHover()
		end

		local showSelected = isHovered
		if highlightCheck then
			showSelected = highlightCheck(isHovered)
		end

		do
			if showSelected then
				TextBoxSprite:SetFrame(1)
				TextBoxSprite.Color = ThemeManager:GetButtonHighlightColor()
			else
				TextBoxSprite:SetFrame(0)
				TextBoxSprite.Color = ThemeManager:GetButtonColor()
			end

			TextBoxSprite.Scale = Vector(size.X / 2, size.Y / 2)
			TextBoxSprite:RenderLayer(0, renderPos)
			TextBoxSprite.Scale = Vector(size.X / 2 - 1, size.Y / 2 - 1)
			TextBoxSprite:RenderLayer(1, renderPos + Vector(1, 1))
		end
		local textColor = ThemeManager:GetButtonTextColor()
		FontPlain:DrawStringScaledUTF8(text, renderPos.X + 4, renderPos.Y + 3, 0.5, 0.5, textColor, 0, false)
	end

	btn = WGA.AddButton(windowName, buttonName, pos, size.X, size.Y, NIL_SPRITE, onClick, OnRender)
	return btn
end

local function AddLabel(windowName, pos, renderFunc, priority)
	local btnName = windowName .. tostring(pos) .. tostring(renderFunc)
	WGA.AddButton(windowName, btnName, pos, 0, 0, NIL_SPRITE, NIL_FUNCTION, renderFunc, true, priority)
end

local EnsureMainWindow -- 提前声明，供 EnsureCustomThemeWindow 使用

local function EnsureCustomThemeWindow()
	local winName = WindowName.CUSTOM_THEME
	if WGA.Windows.menus[winName] then
		return
	end

	if WGA.MenuData[winName] then
		WGA.MenuData[winName].sortList = {}
		WGA.MenuData[winName].Buttons = {}
	end

	local config = ConfigManager:GetConfig()
	local customTheme = config.CustomTheme or {}
	local currentY = 20
	local paddingX = 8
	local gapY = 20
	local winW = 220
	local winH = 250

	local sWidth = Isaac.GetScreenWidth()
	local sHeight = Isaac.GetScreenHeight()
	local winPos = Vector((sWidth - winW) / 2, (sHeight - winH) / 2)

	local window = WGA.ShowWindow(winName, winPos, Vector(winW, winH))
	window.backcolor = ThemeManager:GetWindowColor()
	window.backcolornfocus = ThemeManager:GetWindowUnfocusedColor()

	local function AddColorEditor(label, key, isKColor)
		AddLabel(winName, Vector(paddingX, currentY), function(pos, visible)
			if not visible then
				return
			end
			local color = ThemeManager:GetLabelTextColor()
			FontPlain:DrawStringScaledUTF8(label, pos.X, pos.Y, 0.5, 0.5, color, 0, false)
		end)

		local c = customTheme[key]
		if not c then
			if key == "ButtonText" or key == "LabelText" then
				c = customTheme["Text"] or { R = 1, G = 1, B = 1, A = 1 }
			else
				c = { R = 1, G = 1, B = 1, A = 1 }
			end
		end
		local components = { "R", "G", "B", "A" }
		local sliderW = 35
		local sliderGap = 8

		for i, comp in ipairs(components) do
			local startVal = c[comp]
			if (key == "ButtonText" or key == "LabelText") and not customTheme[key] then
				local textC = customTheme["Text"] or { R = 1, G = 1, B = 1, A = 1 }
				startVal = textC[comp]
			end
			startVal = startVal or 1 -- 防止 startVal 为 nil
			local sliderX = paddingX + 40 + (i - 1) * (sliderW + sliderGap)

			WGA.AddGragFloat(
				winName,
				key .. "_" .. comp,
				Vector(sliderX, currentY + 4),
				Vector(sliderW, 8),
				NIL_SPRITE,
				nil,
				function(button, value, oldvalue)
					if button ~= 0 then
						return
					end

					-- 如果是第一次修改 ButtonText 或 LabelText，需要从 Text 复制一份独立的数据
					if (key == "ButtonText" or key == "LabelText") and not customTheme[key] then
						local textC = customTheme["Text"] or { R = 1, G = 1, B = 1, A = 1 }
						customTheme[key] = { R = textC.R, G = textC.G, B = textC.B, A = textC.A }
						c = customTheme[key]
					end

					c[comp] = value
					customTheme[key] = c

					if key == "Text" then
						if not config.CustomTheme.ButtonText then
							ThemeManager:UpdateCustomThemeColor("ButtonText", c.R, c.G, c.B, c.A)
						end
						if not config.CustomTheme.LabelText then
							ThemeManager:UpdateCustomThemeColor("LabelText", c.R, c.G, c.B, c.A)
						end
					end

					config.CustomTheme = customTheme
					ThemeManager:UpdateCustomThemeColor(key, c.R, c.G, c.B, c.A)
					UpdateWindowBackColors()
					MessageBus:Send(Messages.Command.UPDATE_CONFIG, { Config = config })
				end,
				function(pos, visible)
					if not visible then
						return
					end
					local color = ThemeManager:GetLabelTextColor()
					local displayVal = c[comp]
					if (key == "ButtonText" or key == "LabelText") and not customTheme[key] then
						local textC = customTheme["Text"] or { R = 1, G = 1, B = 1, A = 1 }
						displayVal = textC[comp]
					end
					displayVal = displayVal or 1 -- 防止 displayVal 为 nil
					FontPlain:DrawStringScaledUTF8(
						comp .. ": " .. string.format("%.2f", displayVal),
						pos.X,
						pos.Y - 8,
						0.5,
						0.5,
						color,
						0,
						false
					)

					-- Draw slider background
					TextBoxSprite:SetFrame(0)
					TextBoxSprite.Color = ThemeManager:GetWindowUnfocusedColor()
					TextBoxSprite.Scale = Vector(sliderW / 2, 4)
					TextBoxSprite:RenderLayer(0, pos)
				end,
				startVal
			)
		end
		currentY = currentY + gapY
	end

	AddColorEditor("窗口背景", "Window", false)
	AddColorEditor("失焦背景", "WindowUnfocused", false)
	AddColorEditor("按钮背景", "Button", false)
	AddColorEditor("按钮高亮", "ButtonHighlight", false)
	AddColorEditor("HUD文本", "Text", true)
	AddColorEditor("按钮文本", "ButtonText", true)
	AddColorEditor("标签文本", "LabelText", true)

	-- 添加使用背景图片的开关
	local useBg = customTheme.UseBackgroundImage or false
	AddStyledButton(
		winName,
		Vector(paddingX, currentY),
		Vector(100, 12),
		"使用背景图片: " .. (useBg and "开" or "关"),
		function(btn)
			if btn == 0 then
				customTheme.UseBackgroundImage = not customTheme.UseBackgroundImage
				config.CustomTheme = customTheme
				ThemeManager:LoadCustomTheme(customTheme)
				MessageBus:Send(Messages.Command.UPDATE_CONFIG, { Config = config })

				-- 刷新窗口
				WGA.CloseWindow(winName)
				EnsureCustomThemeWindow()

				-- 如果主窗口开着，也刷新一下
				if WGA.Windows.menus[WindowName.MAIN] then
					WGA.CloseWindow(WindowName.MAIN)
					EnsureMainWindow()
				end
			end
		end
	)
	currentY = currentY + gapY

	-- 添加背景透明度滑块
	local bgAlpha = customTheme.BackgroundImageAlpha or 1.0
	AddLabel(winName, Vector(paddingX, currentY), function(pos, visible)
		if not visible then
			return
		end
		local color = ThemeManager:GetLabelTextColor()
		FontPlain:DrawStringScaledUTF8(
			"背景图透明度: " .. string.format("%.2f", bgAlpha),
			pos.X,
			pos.Y,
			0.5,
			0.5,
			color,
			0,
			false
		)
	end)

	WGA.AddGragFloat(
		winName,
		"BgAlphaSlider",
		Vector(paddingX + 80, currentY + 4),
		Vector(80, 8),
		NIL_SPRITE,
		nil,
		function(button, value, oldvalue)
			if button ~= 0 then
				return
			end
			bgAlpha = math.max(0, math.min(1, value)) -- 限制在 0-1 之间
			customTheme.BackgroundImageAlpha = bgAlpha
			config.CustomTheme = customTheme
			ThemeManager:LoadCustomTheme(customTheme)
			MessageBus:Send(Messages.Command.UPDATE_CONFIG, { Config = config })
		end,
		function(pos, visible)
			if not visible then
				return
			end
			TextBoxSprite:SetFrame(0)
			TextBoxSprite.Color = ThemeManager:GetWindowUnfocusedColor()
			TextBoxSprite.Scale = Vector(80 / 2, 4)
			TextBoxSprite:RenderLayer(0, pos)
		end,
		bgAlpha
	)
	currentY = currentY + gapY

	-- 添加替换背景图片的提示信息
	AddLabel(winName, Vector(paddingX, currentY), function(pos, visible)
		if not visible then
			return
		end
		local color = ThemeManager:GetLabelTextColor()
		FontPlain:DrawStringScaledUTF8(
			"设置背景图片: 把要修改的图片放到",
			pos.X,
			pos.Y,
			0.5,
			0.5,
			color,
			0,
			false
		)
		FontPlain:DrawStringScaledUTF8(
			"mods/bisai+/resources/gfx/main_bg.png 覆盖原文件",
			pos.X,
			pos.Y + 10,
			0.5,
			0.5,
			color,
			0,
			false
		)
		FontPlain:DrawStringScaledUTF8(
			"格式: png动画文件 (图片分辨率: 480x320)",
			pos.X,
			pos.Y + 20,
			0.5,
			0.5,
			color,
			0,
			false
		)
	end)
end

local function EnsureThemeWindow()
	local winName = WindowName.THEME
	if WGA.Windows.menus[winName] then
		return
	end

	if WGA.MenuData[winName] then
		WGA.MenuData[winName].sortList = {}
		WGA.MenuData[winName].Buttons = {}
	end

	local themes = ThemeManager:GetThemeNames()
	local itemSize = Vector(80, 12)
	local gapY = 1

	local config = ConfigManager:GetConfig()
	local isCustom = config.Theme == "自定义"

	local winW = 96
	local winH = math.max(40, 16 + #themes * (itemSize.Y + gapY) + 8)

	local sWidth = Isaac.GetScreenWidth()
	local sHeight = Isaac.GetScreenHeight()
	local mainWinSize = Vector(240, 160)
	local mainWinPos = Vector((sWidth - mainWinSize.X) / 2, (sHeight - mainWinSize.Y) / 2)

	-- 将主题窗口放在主窗口的右侧，并留出一点间距，顶部位置保持原来的 8
	local winPos = Vector(mainWinPos.X + mainWinSize.X + 10, 8)

	local window = WGA.ShowWindow(winName, winPos, Vector(winW, winH))
	window.backcolor = ThemeManager:GetWindowColor()
	window.backcolornfocus = ThemeManager:GetWindowUnfocusedColor()

	for i, themeName in ipairs(themes) do
		AddStyledButton(
			WindowName.THEME,
			Vector(8, 20) + Vector(0, (i - 1) * (itemSize.Y + gapY)),
			itemSize,
			themeName,
			function(button)
				if button == 0 then
					local config = ConfigManager:GetConfig()

					if WGA.Windows.menus[WindowName.CUSTOM_THEME] then
						-- 如果自定义主题窗口存在，则将选中的主题颜色复制给自定义主题
						local sourceTheme = nil
						for _, t in ipairs(ThemeManager:GetThemeNames()) do
							if t == themeName then
								-- 找到对应的主题数据
								-- 这里需要从 ThemeManager 获取具体颜色
								ThemeManager:SetTheme(themeName) -- 临时切换以获取颜色
								local newCustom = {
									Window = {
										R = ThemeManager:GetWindowColor().R,
										G = ThemeManager:GetWindowColor().G,
										B = ThemeManager:GetWindowColor().B,
										A = ThemeManager:GetWindowColor().A,
									},
									WindowUnfocused = {
										R = ThemeManager:GetWindowUnfocusedColor().R,
										G = ThemeManager:GetWindowUnfocusedColor().G,
										B = ThemeManager:GetWindowUnfocusedColor().B,
										A = ThemeManager:GetWindowUnfocusedColor().A,
									},
									Button = {
										R = ThemeManager:GetButtonColor().R,
										G = ThemeManager:GetButtonColor().G,
										B = ThemeManager:GetButtonColor().B,
										A = ThemeManager:GetButtonColor().A,
									},
									ButtonHighlight = {
										R = ThemeManager:GetButtonHighlightColor().R,
										G = ThemeManager:GetButtonHighlightColor().G,
										B = ThemeManager:GetButtonHighlightColor().B,
										A = 1,
									}, -- 忽略呼吸动画的A
									Text = {
										R = ThemeManager:GetTextColor().Red,
										G = ThemeManager:GetTextColor().Green,
										B = ThemeManager:GetTextColor().Blue,
										A = ThemeManager:GetTextColor().Alpha,
									},
									ButtonText = {
										R = ThemeManager:GetButtonTextColor().Red,
										G = ThemeManager:GetButtonTextColor().Green,
										B = ThemeManager:GetButtonTextColor().Blue,
										A = ThemeManager:GetButtonTextColor().Alpha,
									},
									LabelText = {
										R = ThemeManager:GetLabelTextColor().Red,
										G = ThemeManager:GetLabelTextColor().Green,
										B = ThemeManager:GetLabelTextColor().Blue,
										A = ThemeManager:GetLabelTextColor().Alpha,
									},
								}
								config.CustomTheme = newCustom
								ThemeManager:LoadCustomTheme(newCustom)
								ThemeManager:SetTheme("自定义") -- 切回自定义主题
								config.Theme = "自定义"
								MessageBus:Send(Messages.Command.UPDATE_CONFIG, { Config = config })

								-- 刷新自定义主题窗口
								WGA.CloseWindow(WindowName.CUSTOM_THEME)
								EnsureCustomThemeWindow()

								WGA.SelectedMenu = WindowName.CUSTOM_THEME
								local wind = WGA.Windows
								if wind and wind.order then
									for j, name in ipairs(wind.order) do
										if name == WindowName.CUSTOM_THEME then
											table.remove(wind.order, j)
											table.insert(wind.order, 1, WindowName.CUSTOM_THEME)
											break
										end
									end
								end
								break
							end
						end
					else
						-- 正常切换主题
						ThemeManager:SetTheme(themeName)
						UpdateWindowBackColors()
						config.Theme = themeName
						MessageBus:Send(Messages.Command.UPDATE_CONFIG, { Config = config })

						if themeName == "自定义" then
							EnsureCustomThemeWindow()
							WGA.SelectedMenu = WindowName.CUSTOM_THEME
							local wind = WGA.Windows
							if wind and wind.order then
								for j, name in ipairs(wind.order) do
									if name == WindowName.CUSTOM_THEME then
										table.remove(wind.order, j)
										table.insert(wind.order, 1, WindowName.CUSTOM_THEME)
										break
									end
								end
							end
						end
					end

					-- 重新打开窗口以刷新大小和内容
					WGA.CloseWindow(winName)
					EnsureThemeWindow()
				end
			end,
			function(isHovered)
				return isHovered or config.Theme == themeName
			end
		)
	end
end

local function EnsureHelpWindow()
	local winName = WindowName.HELP
	if WGA.Windows.menus[winName] then
		return
	end

	if WGA.MenuData[winName] then
		WGA.MenuData[winName].sortList = {}
		WGA.MenuData[winName].Buttons = {}
	end

	local winW, winH = 400, 220
	local paddingX, paddingY = 8, 8
	local lineHeight = 12
	local visibleHeight = winH - paddingY * 2
	local visibleLines = math.floor(visibleHeight / lineHeight)

	local lines = Utils.SplitLines(BISAI_PLUS.Description)
	local totalLines = #lines
	local maxScroll = math.max(1, totalLines - visibleLines + 1)

	-- 使用闭包外部变量或者 Data.Runtime 来存储滚动状态，防止重置
	-- 但由于窗口关闭即销毁（WGA机制不明，暂时假设），这里简单处理
	local currentScrollLine = 1

	local sWidth = Isaac.GetScreenWidth()
	local sHeight = Isaac.GetScreenHeight()
	local winPos = Vector((sWidth - winW) / 2, (sHeight - winH) / 2)

	local window = WGA.ShowWindow(winName, winPos, Vector(winW, winH))
	window.backcolor = ThemeManager:GetWindowColor()
	window.backcolornfocus = ThemeManager:GetWindowUnfocusedColor()

	if totalLines > visibleLines then
		-- Add ScrollBar
		local barSize = Vector(8, visibleHeight)
		local scrollBar = WGA.AddScrollBar(
			winName,
			"HelpScroll",
			Vector(winW - 14, paddingY), -- pos relative to window
			barSize, -- size
			nil, -- sprite
			nil, -- dragSpr (will use default if nil, potentially broken if animation missing)
			function(btn, val)
				currentScrollLine = 1 + math.floor(val / lineHeight)
			end,
			function(pos, visible)
				-- 绘制滚动条背景槽
				if not visible then
					return
				end
				local size = barSize
				TextBoxSprite.Color = ThemeManager:GetWindowUnfocusedColor()
				-- 稍微调暗一点作为背景
				TextBoxSprite.Color = Color.Lerp(TextBoxSprite.Color, Color(0, 0, 0, 1), 0.3)

				TextBoxSprite.Scale = Vector(size.X / 2, size.Y / 2)
				TextBoxSprite:SetFrame(0)
				TextBoxSprite:RenderLayer(0, pos)
			end,
			0, -- start percent
			0, -- start value
			(totalLines - visibleLines) * lineHeight + visibleHeight, -- end value
			0
		)

		if scrollBar then
			-- Custom Render Function
			-- We override the rendering to draw the handle at the correct position and size
			scrollBar.dragsprRenderFunc = function(self, pos, dragVal, barHalfSize)
				local drawSize = Vector(self.x, barHalfSize * 2)

				-- Render Logic
				local isDragging = (
					self.isDrager
					and self.IsSelected
					and self.IsSelected > 0
					and Input.IsMouseBtnPressed(0)
				)
				local isHovered = (self.IsSelected and self.IsSelected > 0)

				if isDragging or isHovered then
					TextBoxSprite:SetFrame(1)
					TextBoxSprite.Color = ThemeManager:GetButtonHighlightColor()
				else
					TextBoxSprite:SetFrame(0)
					TextBoxSprite.Color = ThemeManager:GetButtonColor()
				end

				-- Draw background/shadow
				TextBoxSprite.Scale = Vector(drawSize.X / 2, drawSize.Y / 2)
				TextBoxSprite:RenderLayer(0, pos)
				-- Draw foreground
				TextBoxSprite.Scale = Vector(drawSize.X / 2 - 1, drawSize.Y / 2 - 1)
				TextBoxSprite:RenderLayer(1, pos + Vector(1, 1))
			end
		end
	end

	AddLabel(winName, Vector(paddingX, paddingY), function(pos)
		local color = ThemeManager:GetLabelTextColor()
		local startLine = Utils.Clamp(currentScrollLine, 1, math.max(1, totalLines))
		local endLine = math.min(totalLines, startLine + visibleLines - 1)

		local y = pos.Y
		for i = startLine, endLine do
			local line = lines[i]
			if line then
				FontPlain:DrawStringScaledUTF8(line, pos.X, y, 0.5, 0.5, color, 0, false)
				y = y + lineHeight
			end
		end
	end)
end

local function EnsureControlsWindow()
	if WGA.Windows.menus[WindowName.CONTROL] then
		return
	end
	if WGA.MenuData[WindowName.CONTROL] then
		WGA.MenuData[WindowName.CONTROL].sortList = {}
		WGA.MenuData[WindowName.CONTROL].Buttons = {}
	end

	local state = Data.Runtime.State
	local showPause = (state == Shared.State.RUNNING)
	local showResume = (state == Shared.State.PAUSED)
	local hasControlBtn = showPause or showResume

	local winW = 160
	local winH = 110
	if not hasControlBtn then
		winH = winH - 18
	end

	local win = WGA.ShowWindow(WindowName.CONTROL, Vector(60, 40), Vector(winW, winH))
	if win and Data.Runtime.State ~= Shared.State.RUNNING then
		win.close.visible = false
		win.close.canPressed = false
	end

	UpdateWindowBackColors()

	AddLabel(WindowName.CONTROL, Vector(winW / 2 - 30, 4), function(b)
		local pos = b
		local color = ThemeManager:GetLabelTextColor()
		FontPlain:DrawStringScaledUTF8("控制面板 (F4)", pos.X, pos.Y, 0.5, 0.5, color, 0, false)
	end)

	local currentY = 20
	local paddingLeft = 8
	local btnW = 144
	local halfBtnW = 70
	local btnH = 14
	local gapY = 4
	local gapX = 4

	if showPause then
		AddStyledButton(WindowName.CONTROL, Vector(paddingLeft, currentY), Vector(btnW, btnH), "暂停", function(btn)
			if btn == 0 then
				MessageBus:Send(Messages.Command.PAUSE_RUN)
				WGA.CloseWindow(WindowName.CONTROL)
			end
		end)
		currentY = currentY + btnH + gapY
	elseif showResume then
		AddStyledButton(
			WindowName.CONTROL,
			Vector(paddingLeft, currentY),
			Vector(btnW, btnH),
			"继续 (Enter)",
			function(btn)
				if btn == 0 then
					MessageBus:Send(Messages.Command.RESUME_RUN)
					WGA.CloseWindow(WindowName.CONTROL)
				end
			end
		)
		currentY = currentY + btnH + gapY
	end

	AddStyledButton(
		WindowName.CONTROL,
		Vector(paddingLeft, currentY),
		Vector(btnW, btnH),
		"新开局 (Ctrl+Enter)",
		function(b)
			if b == 0 and Input.IsActionPressed(ButtonAction.ACTION_DROP, Data.Runtime.ControllerIndex) then
				MessageBus:Send(Messages.Command.CREATE_RUN)
				WGA.CloseWindow(WindowName.CONTROL)
			end
		end,
		function(isHovered)
			return Input.IsActionPressed(ButtonAction.ACTION_DROP, Data.Runtime.ControllerIndex)
		end
	)
	currentY = currentY + btnH + gapY

	AddStyledButton(WindowName.CONTROL, Vector(paddingLeft, currentY), Vector(halfBtnW, btnH), "主题", function(btn)
		if btn == 0 then
			EnsureThemeWindow()
			WGA.SelectedMenu = WindowName.THEME
			local wind = WGA.Windows
			if wind and wind.order then
				for i, name in ipairs(wind.order) do
					if name == WindowName.THEME then
						table.remove(wind.order, i)
						table.insert(wind.order, 1, WindowName.THEME)
						break
					end
				end
			end
		end
	end)

	AddStyledButton(
		WindowName.CONTROL,
		Vector(paddingLeft + halfBtnW + gapX, currentY),
		Vector(halfBtnW, btnH),
		"说明",
		function(btn)
			if btn == 0 then
				EnsureHelpWindow()
				WGA.SelectedMenu = WindowName.HELP
				local wind = WGA.Windows
				if wind and wind.order then
					for i, name in ipairs(wind.order) do
						if name == WindowName.HELP then
							table.remove(wind.order, i)
							table.insert(wind.order, 1, WindowName.HELP)
							break
						end
					end
				end
			end
		end
	)
	currentY = currentY + btnH + gapY

	local Text = [[
手柄操作：
Enter->主动键
Ctrl->丢弃键]]
	AddLabel(WindowName.CONTROL, Vector(paddingLeft, currentY + 2), function(b)
		local pos = b
		local color = ThemeManager:GetLabelTextColor()
		Utils.DrawMultiLineText(FontPlain, Text, pos.X, pos.Y, 0.5, color)
	end)
end

function EnsureMainWindow()
	local winName = WindowName.MAIN
	if WGA.Windows.menus[winName] then
		return
	end

	if WGA.MenuData[winName] then
		WGA.MenuData[winName].sortList = {}
		WGA.MenuData[winName].Buttons = {}
	end

	-- 1. 定义窗口尺寸
	local winSize = Vector(240, 160)

	-------------------------------------------------------
	-- 2. 使用正确的 API 获取宽度和高度
	local sWidth = Isaac.GetScreenWidth()
	local sHeight = Isaac.GetScreenHeight()

	-- 3. 计算居中位置
	local winPos = Vector((sWidth - winSize.X) / 2, (sHeight - winSize.Y) / 2)
	-------------------------------------------------------

	local window = WGA.ShowWindow(winName, winPos, winSize)

	if window then
		-- 禁止主窗口通过鼠标移动（WGA 使用 window.unuser 来跳过移动逻辑）
		window.unuser = true
		window.close.visible = false
		window.close.canPressed = false
		window.hide.visible = false
		window.hide.canPressed = false

		-- 这里的颜色会自动应用你之前写的元表逻辑
		window.backcolor = ThemeManager:GetWindowColor()
		window.backcolornfocus = ThemeManager:GetWindowUnfocusedColor()
		---@cast window +{RenderCustomMenuBack: function|nil} 解决一个警告
		window.RenderCustomMenuBack = nil

		if ThemeManager:IsUsingBackgroundImage() then
			window.backcolor = Color(0, 0, 0, 0)
			window.backcolornfocus = Color(0, 0, 0, 0)
			window.RenderCustomMenuBack = function() end -- 完全禁用默认背景渲染
		end

		local bgSprite = Sprite()
		bgSprite:Load("gfx/main_bg.anm2", true)
		bgSprite.Scale = Vector(0.5, 0.5)
		bgSprite:Play("Idle")
		bgSprite:Update() -- 强制更新一次状态，防止第一帧不显示

		AddLabel(WindowName.MAIN, Vector(0, 0), function(pos, visible)
			if not visible or not ThemeManager:IsUsingBackgroundImage() then
				return
			end
			bgSprite:Update() -- 保持动画更新（如果是动态图的话）
			bgSprite.Color = Color(1, 1, 1, ThemeManager:GetBackgroundImageAlpha())
			bgSprite:Render(pos, Vector.Zero, Vector.Zero)
		end, 100) -- 使用正数高优先级，确保它在最底层渲染

		local itemSize = Vector(40, 12)
		local gapY = 1

		for i, item in ipairs(Shared.GoalData) do
			local name = item.Name

			AddStyledButton(
				WindowName.MAIN,
				Vector(8, 12) + Vector(0, (i - 1) * (itemSize.Y + gapY)),
				itemSize,
				name,
				function(button)
					if button == 0 then
						MessageBus:Send(Messages.Command.START_RUN, { Goal = i, PlayerName = GetCurrentPlayerName() })
						MessageBus:Send(Messages.Command.PAUSE_RUN) -- 开始游戏时先进入暂停状态，防止玩家不小心选错终点
					end
				end,
				function()
					return i == Data.Runtime.Goal
				end,
				function()
					if Data.Runtime.MouseMoved then
						Data.Runtime.Goal = i
					end
				end
			)
		end

		AddStyledButton(
			WindowName.MAIN,
			Vector(8, 12) + Vector(0, 9 * (itemSize.Y + gapY)),
			Vector(40, 12),
			"主题",
			function(button)
				if button == 0 then
					EnsureThemeWindow()
					WGA.SelectedMenu = WindowName.THEME
					local wind = WGA.Windows
					if wind and wind.order then
						for i, name in ipairs(wind.order) do
							if name == WindowName.THEME then
								table.remove(wind.order, i)
								table.insert(wind.order, 1, WindowName.THEME)
								break
							end
						end
					end
				end
			end
		)

		AddStyledButton(
			WindowName.MAIN,
			Vector(8, 12) + Vector(0, 10 * (itemSize.Y + gapY)),
			Vector(40, 12),
			"说明",
			function(button)
				if button == 0 then
					EnsureHelpWindow()
					WGA.SelectedMenu = WindowName.HELP
					local wind = WGA.Windows
					if wind and wind.order then
						for i, name in ipairs(wind.order) do
							if name == WindowName.HELP then
								table.remove(wind.order, i)
								table.insert(wind.order, 1, WindowName.HELP)
								break
							end
						end
					end
				end
			end
		)

		AddLabel(WindowName.MAIN, Vector(180, 4), function(pos)
			local color = ThemeManager:GetLabelTextColor()
			FontPlain:DrawStringScaledUTF8(
				"比赛+ 版本：v" .. BISAI_PLUS.Version,
				pos.X,
				pos.Y,
				0.5,
				0.5,
				color,
				0,
				false
			)
		end)

		AddStyledButton(WindowName.MAIN, Vector(104, 12), Vector(60, 12), "随机角色种子(Q)", function(button)
			if button == 0 then
				RollPlayerType()
			end
		end)

		AddStyledButton(WindowName.MAIN, Vector(172, 12), Vector(60, 12), "随机终点(E)", function(button)
			if button == 0 then
				RollGoal()
			end
		end)

		AddLabel(WindowName.MAIN, Vector(60, 32), function(pos, visible)
			if not visible then
				return
			end
			local item = Shared.GoalData[Data.Runtime.Goal]
			if not item then
				return
			end

			local color = ThemeManager:GetLabelTextColor()
			local currentY = pos.Y

			if item.Name then
				FontPlain:DrawStringScaledUTF8(item.Name, pos.X, currentY, 0.5, 0.5, color, 0, false)
			end

			currentY = currentY + 16

			Utils.DrawMultiLineText(FontPlain, item.Desc, pos.X, currentY, 0.5, color)
		end)
	end
end

local function SetMainWindowExits(exits)
	if exits then
		EnsureMainWindow()
	elseif WGA.Windows.menus[WindowName.MAIN] then
		WGA.CloseWindow(WindowName.MAIN)
	end
end

-- TODO: 抽取一下公共逻辑
-- TODO: 处理手柄和键盘键位冲突
local function HandleGlobalKeyInput()
	if
		Data.Runtime.State ~= Shared.State.READY
		and (
			(
				Input.IsButtonTriggered(Keyboard.KEY_F4, Data.Runtime.ControllerIndex)
				and not Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, Data.Runtime.ControllerIndex)
			)
			or (
				Input.IsActionPressed(ButtonAction.ACTION_DROP, Data.Runtime.ControllerIndex)
				and Input.IsActionTriggered(ButtonAction.ACTION_PAUSE, Data.Runtime.ControllerIndex)
			)
		)
	then
		if WGA.Windows.menus[WindowName.CONTROL] then
			WGA.CloseWindow(WindowName.CONTROL)
		else
			EnsureControlsWindow()
		end
	end
end

local function HandleControlsWindowKeyInput()
	if not WGA.Windows.menus[WindowName.CONTROL] then
		return
	end

	local isConfirmTriggered = Input.IsButtonTriggered(Keyboard.KEY_ENTER, Data.Runtime.ControllerIndex)
		or Input.IsActionTriggered(ButtonAction.ACTION_ITEM, Data.Runtime.ControllerIndex)

	if isConfirmTriggered then
		if Input.IsActionPressed(ButtonAction.ACTION_DROP, Data.Runtime.ControllerIndex) then
			if WGA.Windows.menus[WindowName.CONTROL] then
				WGA.CloseWindow(WindowName.CONTROL)
			end
			MessageBus:Send(Messages.Command.CREATE_RUN)
		else
			if WGA.Windows.menus[WindowName.CONTROL] then
				WGA.CloseWindow(WindowName.CONTROL)
			end
			if Data.Runtime.State == Shared.State.PAUSED then
				MessageBus:Send(Messages.Command.RESUME_RUN)
			end
		end
	end
end

local function HandleMenuKeyInput()
	if not WGA.Windows.menus[WindowName.MAIN] then
		return
	end

	if Data.Runtime.IsRollingGoal then
		return
	end

	local numItems = #Shared.GoalData
	if numItems <= 0 then
		return
	end

	if Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, Data.Runtime.ControllerIndex) then
		RollPlayerType()
	end

	if Input.IsActionTriggered(ButtonAction.ACTION_BOMB, Data.Runtime.ControllerIndex) then
		RollGoal()
	end

	-- 上下选择
	local delta = 0
	if
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, Data.Runtime.ControllerIndex)
		or Input.IsActionTriggered(ButtonAction.ACTION_UP, Data.Runtime.ControllerIndex)
		or Input.IsButtonTriggered(Keyboard.KEY_UP, Data.Runtime.ControllerIndex)
	then
		delta = -1
	elseif
		Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, Data.Runtime.ControllerIndex)
		or Input.IsActionTriggered(ButtonAction.ACTION_DOWN, Data.Runtime.ControllerIndex)
		or Input.IsButtonTriggered(Keyboard.KEY_DOWN, Data.Runtime.ControllerIndex)
	then
		delta = 1
	end

	if delta ~= 0 then
		Data.Runtime.Goal = ((Data.Runtime.Goal - 1 + delta) % numItems) + 1
		Data.Runtime.MouseMoved = false -- 键盘操作时禁用鼠标自动选择
		if delta < 0 then
			SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
		else
			SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)
		end
	end

	-- 确认选择
	if
		Input.IsActionTriggered(ButtonAction.ACTION_ITEM, Data.Runtime.ControllerIndex)
		or Input.IsButtonTriggered(Keyboard.KEY_ENTER, Data.Runtime.ControllerIndex)
	then
		MessageBus:Send(Messages.Command.START_RUN, { Goal = Data.Runtime.Goal, PlayerName = GetCurrentPlayerName() })
		MessageBus:Send(Messages.Command.PAUSE_RUN) -- 开始游戏时先进入暂停状态，防止玩家不小心选错终点
	end
end

--- 将毫秒转换为 {min, sec, ms} 的表
---@param totalMs integer
---@return table
local function ConvertMilliseconds(totalMs)
	local minutes = totalMs // 60000
	local remaining = totalMs % 60000
	local seconds = remaining // 1000
	local ms = remaining % 1000
	return {
		Minutes = minutes,
		Seconds = seconds,
		Milliseconds = ms,
	}
end

local function GetTimerComponents()
	local totalMilliseconds

	if Data.Runtime.State == Shared.State.RUNNING then
		local currentTime = Isaac.GetTime()
		local elapsed = currentTime - Data.Runtime.Timer.StartTime
		totalMilliseconds = Data.Runtime.Timer.StoredTime + elapsed
	else
		totalMilliseconds = Data.Runtime.Timer.StoredTime
	end

	return ConvertMilliseconds(totalMilliseconds)
end
local function RenderTimeStatistics()
	local sWidth = Isaac.GetScreenWidth()
	local sHeight = Isaac.GetScreenHeight()
	local centerX = sWidth / 2
	local centerY = sHeight / 2

	-- 整体向右下偏移，填补留白
	local offsetX = 80
	local offsetY = 40 -- 稍微往上移一点，避免底部文字被遮挡

	-- 绘制统计图表
	local records = BISAI_PLUS.Data.Save.Records

	if records and #records > 1 then -- 需要至少两条记录（起点和终点）才能计算时间差
		local numBars = #records - 1 -- 柱子的数量 = 记录数 - 1
		local max = numBars
		local dx = 40 - max * 1.5
		local px = centerX + (max * dx) / 2 + offsetX
		local py = centerY + 60 + offsetY
		local l = 1 / 60000 -- 毫秒转分钟的比例，用于计算高度

		-- 绘制背景底板
		local bgScaleX = (max - 1) * dx / 10
		local bgScaleY = 0.5
		TextBoxSprite.Color = Color(0, 0, 0, 0.7)
		TextBoxSprite.Scale = Vector(bgScaleX, bgScaleY)
		TextBoxSprite:SetFrame(0)
		-- 原版是底部中心对齐，现在是左上角对齐
		-- 中心 X = px - (max + 1) * dx / 2
		-- 底部 Y = py + 11
		-- 左上角 X = 中心 X - bgScaleX
		-- 左上角 Y = 底部 Y - bgScaleY * 2
		TextBoxSprite:Render(Vector(px - (max + 1) * dx / 2 - bgScaleX, py + 11 - bgScaleY * 2))

		for i = max, 1, -1 do
			local ft = records[i]
			local nextFt = records[i + 1]
			local t = nextFt.Time - ft.Time -- 当前层花费的时间 = 到达下一层的时间 - 到达本层的时间

			-- 统一使用主题普通按钮颜色
			local R = ThemeManager:GetButtonColor().R
			local G = ThemeManager:GetButtonColor().G
			local B = ThemeManager:GetButtonColor().B
			local A = 0.8
			local barColor = Color(R, G, B, A)

			-- 四舍五入
			local roundedMs = t + 500
			local tComp = ConvertMilliseconds(roundedMs)
			local txt = string.format("%ds", tComp.Seconds)
			if tComp.Minutes > 0 then
				txt = string.format("%dm%ds", tComp.Minutes, tComp.Seconds)
			end

			local hScale = 0.6 -- 降低柱子高度放大倍数，让柱子变矮
			local barHeight = t * l * 10 * hScale -- 柱子的实际像素高度
			local scaleY = barHeight / 2 -- TextBoxSprite 是 2x2 的，所以 scaleY 是高度的一半

			local wScale = 4.0 -- 柱子宽度放大倍数 (让柱子变粗)
			local baseW = 2 - max / 20
			local scaleX = baseW * wScale

			-- 绘制柱子主体 (使用类似按钮的 Layer 渲染方式实现描边)
			TextBoxSprite.Color = barColor
			TextBoxSprite:SetFrame(1)

			-- 左上角坐标
			local renderPos = Vector(px - i * dx - scaleX, py - barHeight)

			-- 渲染 Layer 0 (带描边的底图)
			TextBoxSprite.Scale = Vector(scaleX, scaleY)
			TextBoxSprite:RenderLayer(0, renderPos)

			-- 渲染 Layer 1 (内部纯色填充，稍微缩小并偏移)
			-- 确保高度足够时才缩小，避免极短的柱子渲染异常
			local innerScaleY = math.max(0, scaleY - 1)
			local innerScaleX = math.max(0, scaleX - 1)
			if innerScaleY > 0 and innerScaleX > 0 then
				TextBoxSprite.Scale = Vector(innerScaleX, innerScaleY)
				TextBoxSprite:RenderLayer(1, renderPos + Vector(1, 1))
			end

			-- 绘制层数图标
			local stageIconFrames = {
				[1] = { [0] = 0, [1] = 1, [2] = 2, [4] = 19, [5] = 20 },
				[2] = { [0] = 0, [1] = 1, [2] = 2, [4] = 19, [5] = 20 },
				[3] = { [0] = 3, [1] = 4, [2] = 5, [4] = 21, [5] = 22 },
				[4] = { [0] = 3, [1] = 4, [2] = 5, [4] = 21, [5] = 22 },
				[5] = { [0] = 6, [1] = 7, [2] = 8, [4] = 23, [5] = 24 },
				[6] = { [0] = 6, [1] = 7, [2] = 8, [4] = 23, [5] = 24 },
				[7] = { [0] = 9, [1] = 10, [2] = 11, [4] = 25, [5] = 26 },
				[8] = { [0] = 9, [1] = 10, [2] = 11, [4] = 25, [5] = 26 },
				[9] = { [0] = 12 },
				[10] = { [0] = 13, [1] = 14 },
				[11] = { [0] = 15, [1] = 16 },
				[12] = { [0] = 18 },
				[13] = { [0] = 27 },
			}

			local iconFrame = 17 -- 默认图标
			if ft.IsAscent then
				iconFrame = 17 -- 回溯统一使用默认图标
			elseif stageIconFrames[ft.LevelStage] and stageIconFrames[ft.LevelStage][ft.StageType] then
				iconFrame = stageIconFrames[ft.LevelStage][ft.StageType]
			end

			StageIconSprite:SetFrame("Levels", iconFrame)
			StageIconSprite.Color = Color(1, 1, 1, A)
			StageIconSprite:Render(Vector(px - i * dx, py + 3.5))

			-- 绘制层数文本 (智能折行)
			local stageNameInfo = BISAI_PLUS.GameUtils.GetStageInfo(ft)
			local stageName = stageNameInfo.Name
			local textColor = ThemeManager:GetTextColor()

			-- 一个中文字符的宽度大概是字体原本宽度的对应缩放
			-- 如果字符串长度超过某个阈值 (例如包含 "地下室" 这类或者长度较长)，尝试按空格或者居中附近拆分成两行
			local line1 = stageName
			local line2 = ""

			-- 简单的硬编码长度/关键字截断
			local len = utf8.len(stageName)
			if len and len > 3 then
				-- 寻找 I 或 II 这样带罗马数字或空格的部分，从这里裁断最为自然
				local spaceIndex = string.find(stageName, " ")
				if spaceIndex then
					line1 = string.sub(stageName, 1, spaceIndex - 1)
					line2 = string.sub(stageName, spaceIndex + 1)
				elseif string.find(stageName, "地下室") and len > 4 then
					-- 处理燃烧地下室这种
					line1 = string.match(stageName, "(.*地下室)")
					line2 = string.match(stageName, "地下室(.*)")
					if not line1 or not line2 or line2 == "" then
						line1 = string.sub(stageName, 1, 6)
						line2 = string.sub(stageName, 7)
					end
				else
					-- 兜底逻辑：简单的对半切
					local half = math.ceil(len / 2)
					line1 = string.sub(stageName, 1, half * 3) -- UTF8汉字通常占3字节
					line2 = string.sub(stageName, half * 3 + 1)
				end
			end

			-- 处理部分包含罗马数字后缀产生的多余空格前缀
			line2 = string.gsub(line2, "^%s+", "")

			-- 统一第一行的高度为 py + 18
			local yOffset = py + 18

			local line1W = FontOutline:GetStringWidthUTF8(line1) * 0.5
			FontOutline:DrawStringScaledUTF8(
				line1,
				px - i * dx - line1W / 2,
				yOffset,
				0.5,
				0.5,
				KColor(textColor.Red, textColor.Green, textColor.Blue, 1),
				0,
				false
			)

			-- 如果有第二行，画在下面
			if line2 ~= "" then
				local line2W = FontOutline:GetStringWidthUTF8(line2) * 0.5
				FontOutline:DrawStringScaledUTF8(
					line2,
					px - i * dx - line2W / 2,
					yOffset + 9, -- 下移 9 像素
					0.5,
					0.5,
					KColor(textColor.Red, textColor.Green, textColor.Blue, 1),
					0,
					false
				)
			end

			-- 绘制时间文本 (缩小字体并手动居中，贴近柱状图顶部)
			local txtW = FontOutline:GetStringWidthUTF8(txt) * 0.5
			FontOutline:DrawStringScaledUTF8(
				txt,
				px - i * dx - txtW / 2,
				py - 8 - barHeight,
				0.5,
				0.5,
				KColor(textColor.Red, textColor.Green, textColor.Blue, 1),
				0,
				false
			)
		end
	end
end

local function RenderHud()
	-- ===========================
	-- 配置与状态获取
	-- ===========================
	local hudOffset = Options.HUDOffset
	local scale = 0.5
	local startPos = Vector(4 + hudOffset * 20, 195 + hudOffset * 10)

	local cWhite = ThemeManager:GetTextColor()
	local cRed = KColor(1, 0, 0, 1)

	local timerComp = GetTimerComponents()
	local min, sec, ms = timerComp.Minutes, timerComp.Seconds, timerComp.Milliseconds

	-- 时间格式化：运行中显示一位毫秒(.5)，静止显示三位(.500)
	local msStr
	if Data.Runtime.State == Shared.State.RUNNING then
		msStr = string.format(".%d", math.floor(ms / 100))
	else
		msStr = string.format(".%03d", ms)
	end
	local timeStr = string.format("%02d:%02d%s", min, sec, msStr)

	-- ===========================
	-- 内部辅助绘图函数
	-- ===========================
	local function DrawText(font, text, x, y, color)
		font:DrawStringScaledUTF8(text, x, y, scale, scale, color, 0, false)
		return font:GetStringWidthUTF8(text) * scale
	end

	-- ===========================
	-- 1. 通关结算显示 (独立层)
	-- ===========================
	if Data.Runtime.State == Shared.State.FINISHED then
		local goalInfo = Shared.GoalData[Data.Runtime.Goal]
		local goalName = goalInfo and goalInfo.Name or "未知目标"
		local finishMsg = string.format("你击败了%s!\n用时：%s", goalName, timeStr)

		RenderTimeStatistics()
		Utils.DrawMultiLineText(FontOutline, finishMsg, 140, 135, 2, cWhite)
	elseif Data.Runtime.State == Shared.State.PAUSED then
		-- 暂停状态下，也显示时间统计
		RenderTimeStatistics()
	end

	-- ===========================
	-- 2. HUD 面板渲染 (光标流布局)
	-- ===========================
	local cursorX = startPos.X
	local cursorY = startPos.Y
	local lineHeight = (FontOutline:GetLineHeight() / 2) + 4

	-- [第一行] 当前用时
	local limitMin = 30
	local timeColor = (min >= limitMin) and cRed or cWhite

	local labelW = DrawText(FontOutline, "用时：", cursorX, cursorY, cWhite)
	local timeW = DrawText(FontMono, timeStr, cursorX + labelW, cursorY, timeColor)

	if Data.Runtime.State == Shared.State.PAUSED then
		local gap = 6
		DrawText(FontOutline, "（已暂停）", cursorX + labelW + timeW + gap, cursorY, cRed)
	end

	cursorY = cursorY + lineHeight

	-- [第二行] 目标名称
	local currentGoal = Shared.GoalData[Data.Runtime.Goal]
	local goalNameStr = currentGoal and currentGoal.Name or "-"
	
	local goalColor = cWhite
	if Data.Runtime.State ~= Shared.State.RUNNING then
		goalColor = KColor(0, 1, 0, 1)
	end

	DrawText(FontOutline, "目标：" .. goalNameStr, cursorX, cursorY, goalColor)

	cursorY = cursorY + lineHeight

	-- [第三行] 死亡次数 (原第四行)
	local deathW = DrawText(FontOutline, "死亡：", cursorX, cursorY, cWhite)
	DrawText(FontMono, tostring(Data.Runtime.DeathCount), cursorX + deathW, cursorY, cWhite)

	cursorY = cursorY + lineHeight

	-- [第四行] 玩家与种子 (原第五行)

	local pName = Data.Runtime.PlayerName
	if Data.Runtime.State == Shared.State.READY then
		pName = GetCurrentPlayerName()
	end

	local seedStr = Game():GetSeeds():GetStartSeedString()
	
	local playerSeedColor = cWhite
	if Data.Runtime.State ~= Shared.State.RUNNING then
		playerSeedColor = KColor(0, 1, 0, 1)
	end

	local seedLabelW = DrawText(FontOutline, pName .. " - ", cursorX, cursorY, playerSeedColor)
	DrawText(FontMono, seedStr, cursorX + seedLabelW, cursorY, playerSeedColor)

	cursorY = cursorY + lineHeight

	-- [第五行] 最佳记录 (原第三行，下移至此)
	local dynamicX = cursorX

	-- 5.1 画标签
	dynamicX = dynamicX + DrawText(FontOutline, "记录：", dynamicX, cursorY, cWhite)

	-- 5.2 获取数据
	local weight = Data.Runtime.Record.LevelWeight
	local name = Data.Runtime.Record.LevelName

	-- 5.3 画权重 (Mono字体)
	local weightStr = string.format("[%s]", weight)
	dynamicX = dynamicX + DrawText(FontMono, weightStr, dynamicX, cursorY, cWhite)

	-- 5.4 画关卡名称 (Outline字体)
	dynamicX = dynamicX + DrawText(FontOutline, " " .. name, dynamicX, cursorY, cWhite)

	-- 5.5 画时间 (Mono字体)
	if Data.Runtime.State ~= Shared.State.READY then
		dynamicX = dynamicX + DrawText(FontOutline, " - ", dynamicX, cursorY, cWhite)
		local recordStr = "00:00"
		if Data.Runtime.Record.Time > 0 then
			local rTime = ConvertMilliseconds(Data.Runtime.Record.Time)
			recordStr = string.format("%02d:%02d.%03d", rTime.Minutes, rTime.Seconds, rTime.Milliseconds)
		end
		DrawText(FontMono, recordStr, dynamicX, cursorY, cWhite)
	end

	cursorY = cursorY + lineHeight
end

MessageBus:On(Messages.Event.RUN_PAUSED, function(payload)
	UpdateRuntimeData(payload)
	SetMainWindowExits(payload.State == Shared.State.READY)
end)

MessageBus:On(Messages.Event.RUN_RESUMED, function(payload)
	UpdateRuntimeData(payload)
	SetMainWindowExits(payload.State == Shared.State.READY)
end)

MessageBus:On(Messages.Event.RUN_CREATED, function(payload)
	UpdateRuntimeData(payload)
	SetMainWindowExits(payload.State == Shared.State.READY)
end)

MessageBus:On(Messages.Event.RUN_STARTED, function(payload)
	UpdateRuntimeData(payload)
	SetMainWindowExits(payload.State == Shared.State.READY)
end)

MessageBus:On(Messages.Event.RUN_RESTORED, function(payload)
	UpdateRuntimeData(payload)
	SetMainWindowExits(false)
	SetMainWindowExits(payload.State == Shared.State.READY)
end)

MessageBus:On(Messages.Event.RUN_FINISHED, function(payload)
	UpdateRuntimeData(payload)
	SetMainWindowExits(payload.State == Shared.State.READY)
end)

MessageBus:On(Messages.Event.CONFIG_UPDATED, function(payload)
	ThemeManager:LoadCustomTheme(payload.Config.CustomTheme)
	ThemeManager:SetTheme(payload.Config.Theme)
end)

MessageBus:On(Messages.Event.RECORD_UPDATED, function(payload)
	UpdateRuntimeData(payload)
	SetMainWindowExits(payload.State == Shared.State.READY)
end)

local function UpdateMousePos()
	local current = Isaac.WorldToScreen(Input.GetMousePosition(true)) - Game().ScreenShakeOffset
	Data.Runtime.MouseMoved = (current - WGA.MousePos):LengthSquared() > 0
	if Data.Runtime.MouseMoved then
		Data.Runtime.LastMovedTime = Isaac.GetTime()
	end
	WGA.MousePos = current
end

local function HandleGoalRolling()
	if not Data.Runtime.IsRollingGoal then
		return
	end

	Data.Runtime.GoalRollTimer = Data.Runtime.GoalRollTimer - 1
	if Data.Runtime.GoalRollTimer <= 0 then
		local currentStep = Data.Runtime.GoalRollSequence[Data.Runtime.GoalRollIndex]
		Data.Runtime.Goal = currentStep.goal
		SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)

		Data.Runtime.GoalRollIndex = Data.Runtime.GoalRollIndex + 1
		if Data.Runtime.GoalRollIndex > #Data.Runtime.GoalRollSequence then
			-- 滚动结束
			Data.Runtime.IsRollingGoal = false
			MessageBus:Send(Messages.Command.SET_GOAL, { Goal = Data.Runtime.TargetGoal })
		else
			-- 继续下一步
			Data.Runtime.GoalRollTimer = Data.Runtime.GoalRollSequence[Data.Runtime.GoalRollIndex].delay
		end
	end
end

-- 着色器回调，所有UI都在这里渲染
local function OnGetShaderParams(_, name)
	if name ~= "Bisai-RenderAboveHUD" then
		return
	end
	RenderHud()
	Data.Runtime.ControllerIndex = Game():GetPlayer(0).ControllerIndex
	-- 更新输入
	UpdateMousePos()

	-- 即使游戏暂停，也继续处理滚动动画
	HandleGoalRolling()

	if not Game():IsPaused() then
		HandleMenuKeyInput()
		HandleControlsWindowKeyInput()
	end

	HandleGlobalKeyInput()

	-- GUI 库处理
	if not Data.Runtime.IsRollingGoal then
		WGA.HandleWindowControl()
		WGA.DetectSelectedButtonActuale()
	end
	WGA.RenderWindows()

	if Data.Runtime.State == Shared.State.PAUSED or Data.Runtime.State == Shared.State.FINISHED then
		EnsureControlsWindow()
	end
end

local function OnPlayerInit()
	-- 不加这个就会崩溃
	if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
		Isaac.ExecuteCommand("reloadshaders")
	end
end

do
	EnsureMainWindow()
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, OnGetShaderParams)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, OnPlayerInit)
