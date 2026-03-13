local function OnUpdate()
	-- 此处故意不判断是否是祸兽终点，让其他终点进入祸兽房间时也能触发这个机制
	-- 判断是否是祸兽房间，优化性能，避免在其他房间无意义地遍历祸兽实体
	local isBeastBossRoom = BISAI_PLUS.Shared.GoalData[BISAI_PLUS.Shared.Goal.BEAST].IsStage()
		and BISAI_PLUS.Shared.GoalData[BISAI_PLUS.Shared.Goal.BEAST].IsRoom()

	if not isBeastBossRoom then
		return
	end
	local beasts = Isaac.FindByType(EntityType.ENTITY_BEAST, 0, -1, true, true)
	if #beasts == 0 then
		return
	end
	local beast = beasts[1]:ToNPC()
	if not beast then
		return
	end
	local sprite = beast:GetSprite()
	-- 在死亡动画的60帧直接移除大霍恩
	-- 因为超过65帧左右，屏幕变白就无法阻止了
	if sprite:IsPlaying("Death") and sprite:GetFrame() >= 60 then
		beast:Remove()
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
