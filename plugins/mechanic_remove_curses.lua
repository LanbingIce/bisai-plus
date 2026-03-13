local function OnCurseEval(_, curses)
	-- 移除迷路诅咒和黑暗诅咒
	curses = curses & ~LevelCurse.CURSE_OF_DARKNESS
	curses = curses & ~LevelCurse.CURSE_OF_THE_LOST
	local level = Game():GetLevel()
	local stage = level:GetStage()
	-- 如果是第二章节及之后，移除XL诅咒
	if stage >= LevelStage.STAGE2_1 then
		curses = curses & ~LevelCurse.CURSE_OF_LABYRINTH
	end
	return curses
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, OnCurseEval)
