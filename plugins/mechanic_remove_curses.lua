local function OnCurseEval(_, curses)
	-- 移除迷路诅咒
	curses = curses & ~LevelCurse.CURSE_OF_DARKNESS
	curses = curses & ~LevelCurse.CURSE_OF_THE_LOST
	return curses
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, OnCurseEval)
