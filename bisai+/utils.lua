local Utils = {}

---@param s string
---@return string[]
function Utils.SplitLines(s)
	s = tostring(s or "")
	-- 1. 统一换行符：将 \r\n 或 \r 都变成 \n
	s = s:gsub("\r\n", "\n"):gsub("\r", "\n")

	local lines = {}
	-- 2. 使用 (.-)\n 模式匹配，手动补一个 \n 在末尾以捕获最后一行
	for line in (s .. "\n"):gmatch("(.-)\n") do
		table.insert(lines, line)
	end

	-- 3. 保底返回
	if #lines == 0 then
		lines[1] = ""
	end

	return lines
end

--- 渲染多行文本 (自动计算行高)
--- @param font table 字体对象 (例如 FontPlain)
--- @param text string 要渲染的完整字符串
--- @param x number 起始 X 坐标
--- @param y number 起始 Y 坐标
--- @param scale number 缩放比例 (例如 0.5)
--- @param color any 颜色对象
--- @return number 绘制结束后的 Y 坐标
function Utils.DrawMultiLineText(font, text, x, y, scale, color)
	if not text or text == "" then
		return y
	end

	local lines = Utils.SplitLines(text)

	-- 1. 获取字体基准高度
	local baseHeight = font:GetLineHeight()
	-- 2. 计算实际行高 (基准高度 * 缩放)
	local lineHeight = baseHeight * scale + 2

	for _, line in ipairs(lines) do
		font:DrawStringScaledUTF8(line, x, y, scale, scale, color, 0, false)
		-- 3. 累加 Y 坐标
		y = y + lineHeight
	end

	return y
end

---限制数值范围 (Clamp)
---@param val number 当前值
---@param min number 最小值
---@param max number 最大值
---@return number
function Utils.Clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

---线性插值 (Lerp)
---用于 UI 动画平滑过渡
---@param a number 起始值
---@param b number 结束值
---@param t number 进度 (0~1)
---@return number
function Utils.Lerp(a, b, t)
	return a + (b - a) * Utils.Clamp(t, 0, 1)
end

---检查数值是否近似相等 (用于浮点数比较)
---@param a number
---@param b number
---@return boolean
function Utils.Aprox(a, b)
	return math.abs(a - b) < 0.0001
end

--- 辅助函数：标准的深度拷贝
function Utils.DeepCopy(obj)
	if type(obj) ~= "table" then
		return obj
	end
	local res = {}
	for k, v in pairs(obj) do
		res[Utils.DeepCopy(k)] = Utils.DeepCopy(v)
	end
	return res
end

--- 核心函数：将 B 的成员深度赋值给 A，但只处理 A 中已有的成员
--- @param target table @表 A
--- @param source table @表 B
function Utils.DeepAssignExisting(target, source)
	-- 1. 遍历 A (target)，这样 B 中多出来的成员会被自然忽略
	for k, v in pairs(target) do
		local newValue = source[k]

		-- 2. 只有当 B 中也存在这个成员时才处理
		if newValue ~= nil then
			if type(v) == "table" and type(newValue) == "table" then
				-- 如果 A 和 B 对应位置都是表，则递归向下对比
				Utils.DeepAssignExisting(v, newValue)
			else
				-- 如果 A 中是基本类型，或者 B 对应的位置变成了基本类型
				-- 则直接从 B 深度拷贝一份值覆盖 A
				target[k] = Utils.DeepCopy(newValue)
			end
		end
	end
end

---克隆表（深拷贝），支持循环引用并复制元表
---@param tbl table
---@return table
function Utils.CloneTable(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end
	local lookup = {}
	local function copy(t)
		if type(t) ~= "table" then
			return t
		end
		if lookup[t] then
			return lookup[t]
		end
		local new = {}
		lookup[t] = new
		for k, v in pairs(t) do
			new[copy(k)] = copy(v)
		end
		local mt = getmetatable(t)
		if mt then
			setmetatable(new, copy(mt))
		end
		return new
	end
	return copy(tbl)
end

-- 字典去除了 B, I, O, S 防止和数字混淆
local TABLE_STR = "ACDEFGHJKLMNPQRTUVWXYZ0123456789"

function Utils.HashRnd(val)
	-- 异或魔数，避免输入 0 时无法产生雪崩
	local mixed_val = val ~ 0x9E3779B9
	-- 乘法散列并强制截断在 32 位内
	local h = (mixed_val * 2654435761) & 0xFFFFFFFF
	-- 再次移位混淆
	return (h ~ (h >> 15))
end

function Utils.GenerateModSeed(runConfig)
	local goal = runConfig.Goal
	local playerType = runConfig.PlayerType
	local seed = runConfig.Seed

	-- 数据打包 (最大容纳: 终点3位, 角色6位, 种子32位 = 41位)
	local eBits = (goal - 1) & 0x7
	local cBits = playerType & 0x3F
	local sBits = seed & 0xFFFFFFFF
	local data41 = (eBits << 38) | (cBits << 32) | sBits

	-- 核心加密：3 轮 Feistel 网络打乱 (完美雪崩效应)
	local L = data41 & 0xFFFFF -- 拿低 20 位
	local R = (data41 >> 20) & 0x1FFFFF -- 拿高 21 位

	L = L ~ (Utils.HashRnd(R) & 0xFFFFF)
	R = R ~ (Utils.HashRnd(L) & 0x1FFFFF)
	L = L ~ (Utils.HashRnd(R) & 0xFFFFF)

	-- 合并打乱后的高低位
	local mixed_data = (R << 20) | L

	-- 以撒原版雪崩校验和
	local cksum = 0
	local k = mixed_data
	repeat
		cksum = (cksum + (k & 0xFF)) & 0xFF
		cksum = ((cksum << 1) + (cksum >> 7)) & 0xFF
		k = k >> 5
	until k == 0

	-- 终极组装 (49位 = 41位密文 + 8位校验和)
	local finalInt = (mixed_data << 8) | cksum

	-- 切割字符串并格式化
	local str = ""
	for i = 9, 0, -1 do
		local shift = 5 * i
		local index = (finalInt >> shift) & 31
		-- 从字典映射出对应的字符
		local char = string.sub(TABLE_STR, index + 1, index + 1)
		str = str .. char

		-- 中间插个连字符，变成 XXXXX-XXXXX 格式
		if i == 5 then
			str = str .. "-"
		end
	end

	return str
end

local function IsValidPlayer(playerId)
	local Shared = require("bisai+.shared")
	for _, validId in ipairs(Shared.ValidPlayers) do
		if validId == playerId then
			return true
		end
	end
	return false
end

function Utils.DecodeModSeed(seedStr)
	-- 转为大写
	seedStr = string.upper(seedStr)
	-- 过滤掉连字符、空格等非字母数字字符
	seedStr = string.gsub(seedStr, "[^A-Z0-9]", "")

	-- 种子长度必须为10
	if #seedStr ~= 10 then
		return false, "错误：种子长度不正确"
	end

	-- 替换常见的易混淆字符（静默纠错）
	local charMap = {
		I = "1",
		O = "0",
		S = "5",
		B = "8",
	}
	seedStr = string.gsub(seedStr, "[IOSB]", charMap)

	-- 还原 49 位超大整数
	local finalInt = 0
	for i = 1, 10 do
		local char = string.sub(seedStr, i, i)
		local index = string.find(TABLE_STR, char, 1, true)

		-- 理论上经过上面的过滤和映射，不会走到这里，留作安全兜底
		if not index then
			return false, "错误：包含无法识别的字符"
		end

		finalInt = (finalInt << 5) | (index - 1)
	end

	-- 拆解与校验 (低8位是校验和，剩下的是密文数据)
	local provided_cksum = finalInt & 0xFF
	local mixed_data = finalInt >> 8

	-- 重新计算一遍校验和用来对比
	local cksum = 0
	local k = mixed_data
	repeat
		cksum = (cksum + (k & 0xFF)) & 0xFF
		cksum = ((cksum << 1) + (cksum >> 7)) & 0xFF
		k = k >> 5
	until k == 0

	if cksum ~= provided_cksum then
		return false, "校验失败：代码输入有误"
	end

	-- 反向运行 Feistel 网络，完美还原出原始的 41 位数据
	local L = mixed_data & 0xFFFFF
	local R = (mixed_data >> 20) & 0x1FFFFF

	L = L ~ (Utils.HashRnd(R) & 0xFFFFF)
	R = R ~ (Utils.HashRnd(L) & 0x1FFFFF)
	L = L ~ (Utils.HashRnd(R) & 0xFFFFF)

	local data41 = (R << 20) | L

	-- 按位拆包，恢复真实业务数据
	local gameSeed = data41 & 0xFFFFFFFF
	local character = (data41 >> 32) & 0x3F

	-- 【修改】：解包出 0~7 的数据后，加 1 还原回 1~8 的真实目标
	local goal = ((data41 >> 38) & 0x7) + 1

	-- 【校验逻辑】这里直接检查是否在 1~8 之间即可
	if goal < 1 or goal > 8 or not IsValidPlayer(character) then
		return false, "数据损坏或包含非法的角色/终点ID"
	end

	return true, {
		Goal = goal,
		PlayerType = character,
		Seed = gameSeed,
	}
end

return Utils
