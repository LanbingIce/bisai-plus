-- 插件效果：在见证者路线的前两章节的支线层中，揭示白火房间、镜子房间、刀柄房间、矿车房间的位置。

-- 尝试揭示某个房间
local function TryRevealTargetRoom(roomDesc)
	-- 判空
	if not roomDesc then
		return
	end

	-- 获取房间数据
	local roomData = roomDesc.Data
	if not roomData then
		return
	end

	-- 获取房间名称
	local roomName = roomData.Name

	-- "Secret Entrance"：矿车房间
	-- "White Fire Room"：白火房间
	-- "Mirror Room"：镜子房间
	-- "Knife Piece Room"：刀柄房间
	local isTarget = roomName == "Secret Entrance"
		or roomName == "White Fire Room"
		or roomName == "Mirror Room"
		or roomName == "Knife Piece Room"

	-- 不是目标房间则不处理
	if not isTarget then
		return
	end

	-- 揭示房间：设置显示标志 101（1 << 0 表示点亮房间，1 << 2 表示显示图标）
	-- 镜子房和矿车房都需要进过一次之后才会显示图标，白火房没有图标
	-- 因此四个房间里只有刀柄房会成功显示图标
	roomDesc.DisplayFlags = roomDesc.DisplayFlags | 1 << 0 | 1 << 2
end

local function OnNewLevel()
	-- 确保是见证者路线
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.MOTHER then
		return
	end
	local level = Game():GetLevel()
	local stage = level:GetStage()

	-- 确保是在前两章节
	if stage > LevelStage.STAGE2_2 then
		return
	end

	local stageType = level:GetStageType()

	-- 确保是在支线层
	if stageType < StageType.STAGETYPE_REPENTANCE then
		return
	end

	-- 遍历房间索引，尝试揭示目标房间
	for i = 0, 168 do
		-- 维度0和1分别对应正常维度和镜子维度
		TryRevealTargetRoom(level:GetRoomByIdx(i, 0))
		TryRevealTargetRoom(level:GetRoomByIdx(i, 1))
	end

	-- 更新地图显示
	level:UpdateVisibility()
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OnNewLevel)
