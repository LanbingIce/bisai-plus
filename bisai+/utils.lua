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

return Utils