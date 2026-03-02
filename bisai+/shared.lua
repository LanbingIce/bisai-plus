local Dispatcher = require("bisai+.dispatcher")

---@class GoalConfig
---@field Name string
---@field Nickname string
---@field Desc string
---@field IsRoom fun(): boolean
---@field IsStage fun(): boolean
---@field OnSelect fun()

local Shared = {}

---@enum Goal
Shared.Goal = {
	MEGA_SATAN = 1,
	DELIRIUM = 2,
	MOTHER = 3,
	BEAST = 4,
	LAMB = 5,
	BLUE_BABY = 6,
	HUSH = 7,
	ULTRA_GREED = 8,
}

---@enum State
Shared.State = {
	READY = 1,
	RUNNING = 2,
	PAUSED = 3,
	FINISHED = 5,
}
---@type table<Goal, GoalConfig>
Shared.GoalData = {
	[Shared.Goal.MEGA_SATAN] = {
		Name = "超级撒但",
		Nickname = "大撒旦",
		Desc = [[- 永久获得[钥匙碎片1]和[钥匙碎片2]
		- 有[全家福]且没有[底片]时，封闭阴间入口
		- 有[底片]且没有[全家福]时，封闭教堂入口
		- 击败以撒后，若没有[全家福]，则将宝箱替换为虚空传送门
		- 击败撒但后，若没有[底片]，则将宝箱替换为虚空传送门]],
		IsStage = function()
			return Game():GetLevel():GetStage() == LevelStage.STAGE6
		end,
		IsRoom = function()
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "Mega Satan"
		end,
		OnSelect = function()
			SFXManager():Play(SoundEffect.SOUND_SATAN_GROW)
		end,
	},
	[Shared.Goal.DELIRIUM] = {
		Name = "精神错乱",
		Nickname = "百变怪",
		Desc = [[- 进入虚空时，获得[指南针]和[藏宝图]的效果
		]],
		IsRoom = function()
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "Delirium"
		end,
		IsStage = function()
			return Game():GetLevel():GetStage() == LevelStage.STAGE7
		end,
		OnSelect = function()
			Dispatcher:Dispatch(function()
				Game():ShowHallucination(30)
			end)
		end,
	},
	[Shared.Goal.MOTHER] = {
		Name = "母亲",
		Nickname = "见证者",
		Desc = [[- 封闭主线层的入口
		- 进入支线层的门无代价自动开启
		- 未获取[菜刀碎片1]和[菜刀碎片2]时，封闭支线层入口]],
		IsRoom = function()
			if Game():GetLevel():GetCurrentRoomIndex() ~= GridRooms.ROOM_SECRET_EXIT_IDX then
				return false
			end
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "Mother"
		end,
		IsStage = function()
			local level = Game():GetLevel()
			local stageType = level:GetStageType()
			if stageType ~= StageType.STAGETYPE_REPENTANCE then
				return false
			end
			local stage = level:GetStage()
			if stage == LevelStage.STAGE4_2 then
				return true
			end

			if stage ~= LevelStage.STAGE4_1 then
				return false
			end

			local hasXLCurse = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == LevelCurse.CURSE_OF_LABYRINTH

			if hasXLCurse then
				return true
			end
			return false
		end,
		OnSelect = function()
			SFXManager():Play(SoundEffect.SOUND_MOTHER_APPEAR1)
		end,
	},
	[Shared.Goal.BEAST] = {
		Name = "祸兽",
		Nickname = "三眼霍恩",
		Desc = [[- 击败妈妈后，允许离开房间
		- 封闭子宫层的入口
		- 封闭陵墓I的入口]],
		IsRoom = function()
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "Beast Room"
		end,
		IsStage = function()
			return Game():GetLevel():GetStage() == LevelStage.STAGE8
		end,
		OnSelect = function()
			SFXManager():Play(SoundEffect.SOUND_FLASHBACK)
		end,
	},
	[Shared.Goal.LAMB] = {
		Name = "羔羊",
		Nickname = "羊总",
		Desc = [[- [全家福]替换为[底片]
		- 封闭教堂入口
		- 击败撒但后，若没有[底片]，则将宝箱替换为虚空传送门]],
		IsRoom = function()
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "The Lamb"
		end,
		IsStage = function()
			local stageType = Game():GetLevel():GetStageType()
			if stageType ~= StageType.STAGETYPE_ORIGINAL then
				return false
			end
			return Game():GetLevel():GetStage() == LevelStage.STAGE6
		end,
		OnSelect = function()
			SFXManager():Play(SoundEffect.SOUND_MONSTER_YELL_B)
		end,
	},
	[Shared.Goal.BLUE_BABY] = {
		Name = "？？？",
		Nickname = "小蓝人",
		Desc = [[- [底片]替换为[全家福]
		- 封闭阴间入口
		- 击败以撒后，若没有[全家福]，则将宝箱替换为虚空传送门]],
		IsRoom = function()
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "???"
		end,
		IsStage = function()
			local stageType = Game():GetLevel():GetStageType()
			if stageType ~= StageType.STAGETYPE_WOTL then
				return false
			end
			return Game():GetLevel():GetStage() == LevelStage.STAGE6
		end,
		OnSelect = function()
			SFXManager():Play(SoundEffect.SOUND_SCARED_WHIMPER)
		end,
	},
	[Shared.Goal.HUSH] = {
		Name = "死寂",
		Nickname = "凹凸",
		Desc = [[- 封闭阴间入口
		- 封闭教堂入口]],
		IsRoom = function()
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "Boss Room"
		end,
		IsStage = function()
			return Game():GetLevel():GetStage() == LevelStage.STAGE4_3
		end,
		OnSelect = function()
			SFXManager():Play(SoundEffect.SOUND_HUSH_LOW_ROAR)
		end,
	},

	[Shared.Goal.ULTRA_GREED] = {
		Name = "究极贪婪",
		Nickname = "大贪婪",
		Desc = [[- 封闭阴间入口
		- 封闭教堂入口
		- 进入？？？层时，在初始房间生成按钮
		- 按下按钮后，召唤究极贪婪]],
		IsRoom = function()
			return Game():GetLevel():GetCurrentRoomDesc().Data.Name == "Starting Room"
		end,
		IsStage = function()
			return Game():GetLevel():GetStage() == LevelStage.STAGE4_3
		end,
		OnSelect = function()
			SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP, 1, 2, true)
			SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP, 1, 2, true)
			Dispatcher:Dispatch(function()
				SFXManager():Stop(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP)
				SFXManager():Stop(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP)

				SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_STOP)
				SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END)
			end, 30)
		end,
	},
}

-- 1. 定义角色 ID 到中文名的对照表
Shared.PlayerNameMap = {
	[PlayerType.PLAYER_ISAAC] = "以撒",
	[PlayerType.PLAYER_MAGDALENE] = "抹大拉",
	[PlayerType.PLAYER_CAIN] = "该隐",
	[PlayerType.PLAYER_JUDAS] = "犹大",
	[PlayerType.PLAYER_BLUEBABY] = "？？？",
	[PlayerType.PLAYER_EVE] = "夏娃",
	[PlayerType.PLAYER_SAMSON] = "参孙",
	[PlayerType.PLAYER_AZAZEL] = "阿撒泻勒",
	[PlayerType.PLAYER_LAZARUS] = "拉撒路",
	[PlayerType.PLAYER_EDEN] = "伊甸",
	[PlayerType.PLAYER_THELOST] = "游魂",
	[PlayerType.PLAYER_LAZARUS2] = "复活的拉撒路",
	[PlayerType.PLAYER_BLACKJUDAS] = "犹大之影",
	[PlayerType.PLAYER_LILITH] = "莉莉丝",
	[PlayerType.PLAYER_KEEPER] = "店主",
	[PlayerType.PLAYER_APOLLYON] = "亚玻伦",
	[PlayerType.PLAYER_THEFORGOTTEN] = "遗骸",
	[PlayerType.PLAYER_THESOUL] = "遗骸之魂",
	[PlayerType.PLAYER_BETHANY] = "伯大尼",
	[PlayerType.PLAYER_JACOB] = "雅各",
	[PlayerType.PLAYER_ESAU] = "以扫",

	[PlayerType.PLAYER_ISAAC_B] = "堕化以撒",
	[PlayerType.PLAYER_MAGDALENE_B] = "堕化抹大拉",
	[PlayerType.PLAYER_CAIN_B] = "堕化该隐",
	[PlayerType.PLAYER_JUDAS_B] = "堕化犹大",
	[PlayerType.PLAYER_BLUEBABY_B] = "堕化？？？",
	[PlayerType.PLAYER_EVE_B] = "堕化夏娃",
	[PlayerType.PLAYER_SAMSON_B] = "堕化参孙",
	[PlayerType.PLAYER_AZAZEL_B] = "堕化阿撒泻勒",
	[PlayerType.PLAYER_LAZARUS_B] = "堕化拉撒路",
	[PlayerType.PLAYER_EDEN_B] = "堕化伊甸",
	[PlayerType.PLAYER_THELOST_B] = "堕化游魂",
	[PlayerType.PLAYER_LILITH_B] = "堕化莉莉丝",
	[PlayerType.PLAYER_KEEPER_B] = "堕化店长",
	[PlayerType.PLAYER_APOLLYON_B] = "堕化亚玻伦",
	[PlayerType.PLAYER_THEFORGOTTEN_B] = "堕化遗骸",
	[PlayerType.PLAYER_BETHANY_B] = "堕化伯大尼",
	[PlayerType.PLAYER_JACOB_B] = "堕化雅各",
	[PlayerType.PLAYER_LAZARUS2_B] = "死亡的堕化拉撒路",
	[PlayerType.PLAYER_JACOB2_B] = "堕化雅各之魂",
	[PlayerType.PLAYER_THESOUL_B] = "堕化遗骸之魂",
}

-- 定义可以被随机R出来的角色集合
Shared.ValidPlayers = {
	PlayerType.PLAYER_ISAAC,
	PlayerType.PLAYER_MAGDALENE,
	PlayerType.PLAYER_CAIN,
	PlayerType.PLAYER_JUDAS,
	PlayerType.PLAYER_BLUEBABY,
	PlayerType.PLAYER_EVE,
	PlayerType.PLAYER_SAMSON,
	PlayerType.PLAYER_AZAZEL,
	PlayerType.PLAYER_LAZARUS,
	PlayerType.PLAYER_EDEN,
	PlayerType.PLAYER_THELOST,
	PlayerType.PLAYER_LILITH,
	PlayerType.PLAYER_KEEPER,
	PlayerType.PLAYER_APOLLYON,
	PlayerType.PLAYER_THEFORGOTTEN,
	PlayerType.PLAYER_BETHANY,
	PlayerType.PLAYER_JACOB,

	PlayerType.PLAYER_ISAAC_B,
	PlayerType.PLAYER_MAGDALENE_B,
	PlayerType.PLAYER_CAIN_B,
	PlayerType.PLAYER_JUDAS_B,
	PlayerType.PLAYER_BLUEBABY_B,
	PlayerType.PLAYER_EVE_B,
	PlayerType.PLAYER_SAMSON_B,
	PlayerType.PLAYER_AZAZEL_B,
	PlayerType.PLAYER_LAZARUS_B,
	PlayerType.PLAYER_EDEN_B,
	PlayerType.PLAYER_THELOST_B,
	PlayerType.PLAYER_LILITH_B,
	PlayerType.PLAYER_KEEPER_B,
	PlayerType.PLAYER_APOLLYON_B,
	PlayerType.PLAYER_THEFORGOTTEN_B,
	PlayerType.PLAYER_BETHANY_B,
	PlayerType.PLAYER_JACOB_B,
}
Shared.StageInfo = {
	[0] = { [0] = { weight = 0, name = "无" } },
	[LevelStage.STAGE1_1] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 1, name = "地下室 I" },
		[StageType.STAGETYPE_WOTL] = { weight = 1, name = "地窖 I" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 1, name = "燃烧地下室 I" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 2, name = "下水道 I" },
		[StageType.STAGETYPE_REPENTANCE_B] = { weight = 2, name = "污水井 I" },
	},
	[LevelStage.STAGE1_2] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 2, name = "地下室 II" },
		[StageType.STAGETYPE_WOTL] = { weight = 2, name = "地窖 II" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 2, name = "燃烧地下室 II" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 3, name = "下水道 II" },
		[StageType.STAGETYPE_REPENTANCE_B] = { weight = 3, name = "污水井 II" },
	},
	[LevelStage.STAGE2_1] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 3, name = "洞穴 I" },
		[StageType.STAGETYPE_WOTL] = { weight = 3, name = "墓穴 I" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 3, name = "淹水洞穴 I" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 4, name = "矿洞 I" },
		[StageType.STAGETYPE_REPENTANCE_B] = { weight = 4, name = "灰坑 I" },
	},
	[LevelStage.STAGE2_2] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 4, name = "洞穴 II" },
		[StageType.STAGETYPE_WOTL] = { weight = 4, name = "墓穴 II" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 4, name = "淹水洞穴 II" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 5, name = "矿洞 II" },
		[StageType.STAGETYPE_REPENTANCE_B] = { weight = 5, name = "灰坑 II" },
	},
	[LevelStage.STAGE3_1] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 5, name = "深牢 I" },
		[StageType.STAGETYPE_WOTL] = { weight = 5, name = "坟场 I" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 5, name = "阴湿深牢 I" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 6, name = "陵墓 I" },
		[StageType.STAGETYPE_REPENTANCE_B] = { weight = 6, name = "炼狱 I" },
	},
	[LevelStage.STAGE3_2] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 6, name = "深牢 II" },
		[StageType.STAGETYPE_WOTL] = { weight = 6, name = "坟场 II" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 6, name = "阴湿深牢 II" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 7, name = "陵墓 II" },
		[StageType.STAGETYPE_REPENTANCE_B] = { weight = 7, name = "炼狱 II" },
	},
	[LevelStage.STAGE4_1] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 7, name = "子宫 I" },
		[StageType.STAGETYPE_WOTL] = { weight = 7, name = "血宫 I" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 7, name = "结痂子宫 I" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 8, name = "尸宫 I" },
	},
	[LevelStage.STAGE4_2] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 8, name = "子宫 II" },
		[StageType.STAGETYPE_WOTL] = { weight = 8, name = "血宫 II" },
		[StageType.STAGETYPE_AFTERBIRTH] = { weight = 8, name = "结痂子宫 II" },
		[StageType.STAGETYPE_REPENTANCE] = { weight = 9, name = "尸宫 II" },
	},
	[LevelStage.STAGE4_3] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 9, name = "？？？" },
	},
	[LevelStage.STAGE5] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 10, name = "阴间" },
		[StageType.STAGETYPE_WOTL] = { weight = 10, name = "教堂" },
	},

	[LevelStage.STAGE6] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 11, name = "暗室" },
		[StageType.STAGETYPE_WOTL] = { weight = 11, name = "玩具箱" },
	},
	[LevelStage.STAGE7] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 12, name = "虚空" },
	},
	[LevelStage.STAGE8] = {
		[StageType.STAGETYPE_ORIGINAL] = { weight = 13, name = "家" },
		[StageType.STAGETYPE_WOTL] = { weight = 13, name = "家" },
	},
}
return Shared
