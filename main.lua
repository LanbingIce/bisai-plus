-- TODO 超级种子功能
-- TODO 时间统计功能
-- TODO 去动画

BISAI_PLUS = RegisterMod("bisai+", 1)
BISAI_PLUS.Version = "1.0.0"
BISAI_PLUS.Description = [[
【比赛+】

说明：
- 这是以撒竞速比赛的专用mod，具体比赛规则请查看主办方相关消息。
- 单人开发，能力有限，难免有问题，有任何问题或建议请反馈给我，B站@一块蓝冰
- UI部分，使用了国外大佬@Goganidze 的UI库【worst gui api】并魔改而实现，非常感谢他的无私分享。

与以前使用的比赛Mod【bisai】的关系：
- 本mod并非基于【bisai】开发，而是从零编写的全新Mod，因此不包含【bisai】的特性或者bug。

提示：
- 需要重开时，不需要自杀，只需要长按R键，Mod会自动记录一次死亡
- 以任何方式进入虚空层，都可以通过击杀精神错乱来完成比赛，成绩正常结算
- 以任何方式得到奖杯，都可以完成比赛，成绩正常结算，例如：通过[错误技]生成奖杯

操作说明：
- 全面支持鼠标操作
- 比赛过程中，按下F4可以呼出控制面板，可以进行暂停、新开局等操作
- 为避免恶意暂停，暂停按钮必须使用鼠标操作
- 为避免误触，新开局按钮必须按住ctrl键才会生效

道具权重改动：
- 我们需要深入挖掘：恶魔房道具池 1 → 0.25
- 残损铁镐: 商店道具池 1 → 0.25
- 水星: 星象房道具池 1 → 0.25
- 地球: 星象房道具池 1 → 0.25
- 牌意解读: 商店道具池 0.5 → 0.25

道具效果改动：
- 皇帝卡：效果改为由当前房间向BOSS方向前进4格，持有[塔罗牌桌布]时改为6格
- 四面骰：生效时，持有的最后n个道具会被roll没，n为持有道具总数的1/8，向上取整，持有[编号丢失]时不受影响
- 诅咒硬币：触发时掉落
- 损坏的遥控器：触发时掉落，金色版本/持有多个/持有[妈妈的盒子]时不受影响

修复游戏BUG：
- 修复了进房间立刻使用传送类主动，游戏会卡住的问题

其他改动：
- 删除了隐藏房中直接生成道具的地形。
- 黑暗诅咒和迷途诅咒不会自然生成，使用药丸获得的不受影响
- 对大部分主动道具和卡牌的动画进行加速处理

时间限制：
- 每场比赛限制30分钟，超过时间后，若角色碎心数量小于n，则置为n，n=(当前时间-30分钟)/30秒，向上取整
- 超过30分钟之后，每拥有一个碎心，会获得0.1倍伤害加成，即使不是因为时间限制而获得的碎心，也会获得这个加成
- 游魂、堕化游魂在碎心满了之后和其他角色一样会在切换房间之后立即死亡，但不会因为使用卡牌和拾取道具等动作死亡

mod内置随机功能，不会随机到以下情况，手动选择不受影响：
- 堕化拉撒路 : 全部终点
- 堕化伊甸 : 全部终点
- 堕化该隐 : 全部终点
- 堕化店主 : 死寂
- 游魂 : 死寂
- 堕化游魂 : 死寂
- 游魂 : 究极贪婪
- 堕化游魂 : 究极贪婪
- 全部角色 : 精神错乱
--------------------------------
【更新日志】
--------------------------------
v1.0.0： 
正式发布
]]

local Shared = require("bisai+.shared")
BISAI_PLUS.Shared = Shared

BISAI_PLUS.BannedCombinations = {
	{ PlayerType = PlayerType.PLAYER_LAZARUS_B, Goal = nil }, -- 堕化拉撒路 : 全部终点
	{ PlayerType = PlayerType.PLAYER_EDEN_B, Goal = nil }, -- 堕化伊甸 : 全部终点
	{ PlayerType = PlayerType.PLAYER_CAIN_B, Goal = nil }, -- 堕化该隐 : 全部终点
	{ PlayerType = PlayerType.PLAYER_KEEPER_B, Goal = Shared.Goal.HUSH }, -- 堕化店主 : 死寂
	{ PlayerType = PlayerType.PLAYER_THELOST, Goal = Shared.Goal.HUSH }, --游魂 : 死寂
	{ PlayerType = PlayerType.PLAYER_THELOST_B, Goal = Shared.Goal.HUSH }, -- 堕化游魂 : 死寂
	{ PlayerType = PlayerType.PLAYER_THELOST, Goal = Shared.Goal.ULTRA_GREED }, -- 游魂 : 究极贪婪
	{ PlayerType = PlayerType.PLAYER_THELOST_B, Goal = Shared.Goal.ULTRA_GREED }, -- 堕化游魂 : 究极贪婪
	{ PlayerType = nil, Goal = Shared.Goal.DELIRIUM }, -- 全部角色 : 精神错乱
}

local Utils = require("bisai+.utils")

---@type GameUtils
local GameUtils = include("game_utils")
BISAI_PLUS.GameUtils = GameUtils

local Dispatcher = require("bisai+.dispatcher")
BISAI_PLUS.Dispatcher = Dispatcher

local Data = {
	Save = {
		DeathCount = 0,
		State = Shared.State.READY,
		Goal = Shared.Goal.MEGA_SATAN,
		Timer = {
			StoredTime = 0,
		},
		Record = {
			Time = 0,
			LevelStage = 0,
			StageType = 0,
		},
	},
	Runtime = {
		InGame = false,
		Timer = {
			StartTime = 0,
		},
	},
}

BISAI_PLUS.Data = Data

include("plugins.card_emperor") -- 修改皇帝卡效果，向着BOSS房方向前进4格，如果有塔罗牌桌布，改为6格
include("plugins.fix_teleport_softlock") -- 修复进房间立刻使用传送主动会卡住的问题
include("plugins.goal_ultra_greed") -- 大贪婪终点的BOSS实现
include("plugins.item_d4") -- 修改D4效果，使用后，移除最后八分之一数量的道具，向上取整
include("plugins.mechanic_ban_input") -- 准备阶段和暂停状态禁止任何角色操作
include("plugins.mechanic_broken_heart_damage") -- 超时加碎心之后，根据碎心数量增加攻击力
include("plugins.mechanic_chest_to_trophy") -- 将通关大宝箱替换为奖杯
include("plugins.mechanic_kill_lost") -- 如果lost碎心满了，切换房间时处死lost，解决lost在碎心满了之后还能继续比赛的问题
include("plugins.mechanic_polaroid_negative") -- 根据终点，自动把全家福修改为底片或者把底片修改为全家福
include("plugins.mechanic_remove_beast_cutscene") -- 祸兽播放死亡动画时直接移除，防止全屏变白
include("plugins.mechanic_remove_curses") -- 移除黑暗诅咒和迷路诅咒
include("plugins.mechanic_revive") -- 结算之后，让玩家免死
include("plugins.mechanic_stop_game_time") -- 准备时，暂停游戏时间
include("plugins.mechanic_time_limit") -- 时间限制，超过30分钟根据时间增加碎心
include("plugins.mechanic_void_map") -- 百变怪终点，进入虚空时显示地图
include("plugins.route_beast_close_door") -- 祸兽路线，关闭错误的门，防止选手走错
include("plugins.route_beast_mom_exit") -- 祸兽路线击杀妈腿之后，允许离开BOSS房
include("plugins.route_delirium_trophy") -- 百变怪房间始终生成奖杯
include("plugins.route_mega_satan_key") -- 大撒旦终点给钥匙碎片
include("plugins.route_mother_close_door") -- 见证者路线，关闭错误的门，防止选手走错
include("plugins.route_mother_knife_check") -- 见证者路线如果不拿剧情刀碎片，就禁止下层
include("plugins.route_mother_open_door") -- 见证者路线自动无代价开启支线门
include("plugins.route_path_restriction") -- 妈心和凹凸层防止防止走到错误的天堂/地狱层
include("plugins.trinket_broken_remote") -- 修改破传效果，触发时掉落在地上
include("plugins.trinket_cursed_penny") -- 咒币效果修改，触发时掉落在地上

local Json = require("json")

local Messages = require("bisai+.messages")
local MessageBus = require("bisai+.message_bus")
local ConfigManager = require("bisai+.config_manager")

MessageBus:Clear()
Dispatcher:Clear()

include("effect_manager")

include("ui") -- UI相关
local debugger = include("debugger")
if debugger.Init then
	debugger:Init(Data)
end

local function LoadModData()
	local config = {}
	if BISAI_PLUS:HasData() then
		local success, data = pcall(Json.decode, BISAI_PLUS:LoadData())
		if success and data then
			Utils.DeepAssignExisting(Data.Save, data.Save or {})
			config = data.Config or config
		end
	end
	-- todo config也支持一下深度合并
	ConfigManager:SetConfig(config)
	MessageBus:Emit(Messages.Event.CONFIG_UPDATED, { Config = ConfigManager:GetConfig() })
end

local function SaveModData()
	local current = Isaac.GetTime()
	local state = Data.Save.State

	if Data.Save.State == Shared.State.RUNNING then
		local elapsed = current - Data.Runtime.Timer.StartTime
		Data.Save.Timer.StoredTime = Data.Save.Timer.StoredTime + elapsed
		Data.Runtime.Timer.StartTime = current
		state = Shared.State.PAUSED
	end

	local payload = {
		Save = {
			DeathCount = Data.Save.DeathCount,
			State = state,
			Goal = Data.Save.Goal,
			Timer = {
				StoredTime = Data.Save.Timer.StoredTime,
			},
			Record = {
				Time = Data.Save.Record.Time,
				LevelStage = Data.Save.Record.LevelStage,
				StageType = Data.Save.Record.StageType,
			},
		},
		Config = ConfigManager:GetConfig(),
	}

	BISAI_PLUS:SaveData(Json.encode(payload))
end

local function GetTimer()
	local timer = {
		StoredTime = Data.Save.Timer.StoredTime,
		StartTime = Data.Runtime.Timer.StartTime,
	}
	return timer
end

local function GetPayload()
	return {
		State = Data.Save.State,
		Goal = Data.Save.Goal,
		Timer = GetTimer(),
		DeathCount = Data.Save.DeathCount,
		Record = {
			Time = Data.Save.Record.Time,
			LevelStage = Data.Save.Record.LevelStage,
			StageType = Data.Save.Record.StageType,
		},
	}
end

local function PauseTimer()
	local current_time = Isaac.GetTime()
	local elapsed = current_time - Data.Runtime.Timer.StartTime
	Data.Save.Timer.StoredTime = Data.Save.Timer.StoredTime + elapsed
end

local function ResumeTimer()
	Data.Runtime.Timer.StartTime = Isaac.GetTime()
end

local function ResetTimer()
	Data.Save.Timer.StoredTime = 0
end

local function HandleUpdateConfig(payload)
	ConfigManager:SetConfig(payload.Config)
	MessageBus:Emit(Messages.Event.CONFIG_UPDATED, { Config = ConfigManager:GetConfig() })
end

local function HandleResumeRun()
	if Data.Save.State == Shared.State.RUNNING then
		return
	end
	Data.Save.State = Shared.State.RUNNING
	ResumeTimer()
	SaveModData()
	MessageBus:Emit(Messages.Event.RUN_RESUMED, GetPayload())
end

local function HandlePauseRun()
	if Data.Save.State ~= Shared.State.RUNNING then
		return
	end
	Data.Save.State = Shared.State.PAUSED
	PauseTimer()
	SaveModData()
	MessageBus:Emit(Messages.Event.RUN_PAUSED, GetPayload())
end

local function HandleCreateRun()
	Data.Save.State = Shared.State.READY
	Data.Save.Goal = Shared.Goal.MEGA_SATAN
	ResetTimer()
	Data.Save.DeathCount = 0
	Data.Save.Record = {
		Time = 0,
		LevelStage = 0,
		StageType = 0,
	}
	SaveModData()
	local seedStr = tostring(Game():GetSeeds():GetStartSeedString())
	Isaac.ExecuteCommand("seed " .. seedStr)

	MessageBus:Emit(Messages.Event.RUN_CREATED, GetPayload())
end

local function HandleStartRun(payload)
	Data.Save.State = Shared.State.RUNNING
	Data.Save.Goal = payload.Goal
	ResetTimer()
	ResumeTimer()
	Data.Save.DeathCount = 0
	Data.Save.Record = {
		Time = 0,
		LevelStage = 0,
		StageType = 0,
	}
	SaveModData()
	MessageBus:Emit(Messages.Event.RUN_STARTED, GetPayload())
end

local function HandleSelectCharacter(payload)
	if Data.Save.State ~= Shared.State.READY then
		return
	end
	Isaac.ExecuteCommand("restart " .. payload.PlayerType)
end

local function HandleSetSeed(payload)
	if Data.Save.State ~= Shared.State.READY then
		return
	end
	local seedStr = GameUtils.SeedToString(payload.Seed)
	Isaac.ExecuteCommand("seed " .. seedStr)
end
local function HandleSetGoal(payload)
	if Data.Save.State ~= Shared.State.READY then
		return
	end
	Data.Save.Goal = payload.Goal
end

local function OnUpdate()
	Dispatcher:Run()
end

local function CheckTrophyAnimationFinished(player)
	local data = player:GetData()
	local state = Data.Save.State

	-- 是否在举起奖杯动画中
	if not data.TrophyPickupFrame then
		return
	end

	-- 举起奖杯的过程中死了不结算（例如C计划、狂暴头时间结束）
	if player:IsDead() then
		return
	end

	-- 计算举起奖杯已经过的帧数
	local framesSinceTrophyPickup = Game():GetFrameCount() - data.TrophyPickupFrame
	-- 结算情况1：动画结束
	-- 结算情况2：举起奖杯超过35帧（满碎心情况下举奖杯动画结束之后会死亡，因此在死亡的前1帧结算）
	local isTrophySecured = player:IsExtraAnimationFinished() or framesSinceTrophyPickup >= 35

	if isTrophySecured then
		data.TrophyPickupFrame = nil
		player.ControlsEnabled = true
		player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

		-- 防止重复结算
		if state == Shared.State.FINISHED then
			return
		end

		Data.Save.State = Shared.State.FINISHED
		PauseTimer()
		MessageBus:Emit(Messages.Event.RUN_FINISHED, GetPayload())
	end
end

local function HandleTrophyPickup(player)
	local data = player:GetData()
	-- 如果刚刚举起奖杯，则删除奖杯
	if player.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
		local trophies = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY, -1, true, true)
		local trophy = trophies[1]
		-- 角色碰到奖杯的时候，角色会播放举起奖杯的动画，奖杯会被置为不可见并且碰撞体积被关闭，实际上奖杯还在原地，手上的只是一个贴图
		if trophy and not trophy.Visible then
			-- 动画结束之后，地上的奖杯会使得游戏通关，因此需要先把它移除掉
			trophy:Remove()
			data.TrophyPickupFrame = Game():GetFrameCount()
		end
	end
end

local function OnPlayerUpdate(_, player)
	if not GameUtils.IsRealPlayer(player) then
		return
	end

	CheckTrophyAnimationFinished(player)
	HandleTrophyPickup(player)
end

local function OnNewRoom()
	if Data.Runtime.InGame then
		SaveModData()
	end
end

local function OnGameStarted(_, isContinued)
	Options.Filter = false
	LoadModData()

	repeat
		if isContinued then
			break
		end

		local seeds = Game():GetSeeds()
		if not seeds:IsCustomRun() then
			local seedStr = seeds:GetStartSeedString()
			Isaac.ExecuteCommand("seed " .. seedStr)
			break
		end

		Data.Save.DeathCount = Data.Save.DeathCount + 1
		if Data.Save.State == Shared.State.READY or Data.Save.State == Shared.State.FINISHED then
			Data.Save.DeathCount = 0
			break
		end
	until true

	MessageBus:Emit(Messages.Event.RUN_RESTORED, GetPayload())
	Data.Runtime.InGame = true
	OnNewRoom()
end

local function OnGameExit()
	Dispatcher:Clear()
	Data.Runtime.InGame = false
	MessageBus:Send(Messages.Command.PAUSE_RUN)
	SaveModData()
end

local function OnNewLevel()
	local level = Game():GetLevel()
	local levelStage = level:GetStage()

	-- TODO 重构
	-- TODO 支持一下合并层

	-- 层数记录
	local stageType = level:GetStageType()
	local current_time = Isaac.GetTime()
	local elapsed = current_time - Data.Runtime.Timer.StartTime
	Data.Save.Timer.StoredTime = Data.Save.Timer.StoredTime + elapsed
	Data.Runtime.Timer.StartTime = current_time
	local time = Data.Save.Timer.StoredTime
	local currentWeight = Shared.StageInfo[levelStage][stageType].weight
	local recordWeight = Shared.StageInfo[Data.Save.Record.LevelStage][Data.Save.Record.StageType].weight
	if currentWeight > recordWeight then
		Data.Save.Record.Time = time
		Data.Save.Record.LevelStage = levelStage
		Data.Save.Record.StageType = stageType
		MessageBus:Emit(Messages.Event.RECORD_UPDATED, GetPayload())
	end
end

local function OnClearAward(_, _, spawnPosition)
	local inFinalBossRoom = Shared.GoalData[Data.Save.Goal].IsStage() and Shared.GoalData[Data.Save.Goal].IsRoom()
	if not inFinalBossRoom then
		return
	end
	-- 禁用通关剧情和宝箱并生成一个奖杯
	Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY, spawnPosition, Vector.Zero, nil, 0, 1)
	return true
end

-- luamod 卸载mod时保存配置
local function OnModUnload(_, mod)
	-- 确定是卸载的这个mod，而不是其他mod，防止其他mod卸载时误触发保存配置
	if mod ~= BISAI_PLUS then
		return
	end

	-- 这里不可以使用Game():GetNumPlayers() > 0来判断是否在游戏中
	-- 因为正常退出游戏时也会触发这个回调，而Game()对象在这个时候很可能已经被销毁了，会导致退出游戏的时候弹窗报错
	if not Data.Runtime.InGame then
		return
	end

	SaveModData()
end

-- luamod 加载mod时读取配置
local function OnModload()
	-- luamod 加载mod时，Data.Runtime.InGame是false，但是实际上是在游戏里没错
	-- 因此需要手动执行一下OnGameStarted()来加载配置
	-- 如果是正常开关游戏或者开关mod，角色数一定是0，如果是luamod，角色数一定不是0
	local inGame = Game():GetNumPlayers() > 0
	if not inGame then
		return
	end
	OnGameStarted()
end

pcall(OnModload)

-- Mod消息总线注册
MessageBus:Handle(Messages.Command.UPDATE_CONFIG, HandleUpdateConfig)
MessageBus:Handle(Messages.Command.RESUME_RUN, HandleResumeRun)
MessageBus:Handle(Messages.Command.PAUSE_RUN, HandlePauseRun)
MessageBus:Handle(Messages.Command.CREATE_RUN, HandleCreateRun)
MessageBus:Handle(Messages.Command.START_RUN, HandleStartRun)
MessageBus:Handle(Messages.Command.SELECT_CHARACTER, HandleSelectCharacter)
MessageBus:Handle(Messages.Command.SET_SEED, HandleSetSeed)
MessageBus:Handle(Messages.Command.SET_GOAL, HandleSetGoal)

-- 游戏回调注册
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, OnGameStarted)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, OnGameExit)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OnNewLevel)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClearAward)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, OnModUnload)
