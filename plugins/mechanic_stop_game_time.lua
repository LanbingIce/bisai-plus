local function OnUpdate()
	-- 准备时禁止游戏时间流逝
	if BISAI_PLUS.Data.Save.State == BISAI_PLUS.Shared.State.READY then
		Game().TimeCounter = 1
	end
end
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
