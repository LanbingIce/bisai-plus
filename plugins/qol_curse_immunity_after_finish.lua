local function OnUpdate()
	if BISAI_PLUS.Data.Save.State ~= BISAI_PLUS.Shared.State.FINISHED then
		return
	end

	-- 不加这个注解的话，会有警告
	---@diagnostic disable-next-line: param-type-mismatch
	Game():GetLevel():RemoveCurses(255) -- 移除所有诅咒
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
