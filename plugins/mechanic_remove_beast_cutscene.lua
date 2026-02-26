local function OnUpdate()
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.BEAST then
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
