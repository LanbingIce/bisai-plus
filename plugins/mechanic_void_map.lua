local function OnNewLevel()
	local level = Game():GetLevel()
	local levelStage = level:GetStage()
	-- 进入虚空时获得白地图和指南针效果
	-- 确保当前的终点是百变怪
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.DELIRIUM then
		return
	end

	-- 确保当前处于虚空层
	if levelStage ~= LevelStage.STAGE7 then
		return
	end

	level:ApplyMapEffect()
	level:ApplyCompassEffect()
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OnNewLevel)
