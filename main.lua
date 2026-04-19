-- TODO 超级种子功能

BISAI_PLUS = RegisterMod("bisai+", 1)
BISAI_PLUS.Version = "1.3.0"
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
- 任何方式获得的碎心，都会在超时之后为角色增加伤害倍率，每一个碎心提供0.1倍加成
- 游魂、堕化游魂在碎心满了之后和其他角色一样会在切换房间之后立即死亡，但不会因为使用卡牌和拾取道具等动作死亡

mod内置随机功能，不会随机到以下情况，手动选择不受影响：
- 堕化拉撒路 : 全部终点
- 堕化伊甸 : 全部终点
- 堕化该隐 : 全部终点
- 堕化店主 : 死寂
- 游魂 : 死寂|究极贪婪
- 堕化游魂 : 死寂|究极贪婪
- 全部角色 : 精神错乱
----------------------------------------------------------------
【更新日志】
----------------------------------------------------------------
v1.3.0：
修复：
- 小退后不选择继续游戏而是选择新游戏，死亡次数没有增加的问题
- 在举起奖杯时暂停计时器，结算后可以取消结算状态的问题

新增：
- 在暂停状态下，修改目标终点的功能
- 在暂停状态下，启用、禁用控制台的功能

其他：
- 选定终点并开始比赛后，会先进入暂停状态，方便选手二次确认
- 准备状态、暂停状态、结算状态下，左下角会显示版本号
----------------------------------------------------------------
v1.2.0：
修复：
- 极少数情况下，母亲路线的矿车房间踩按钮没有自动铺路的问题

新增：
- 房间雷达功能，按住地图键时生效，在特定情况下会显示：
    - 房间大于1x1且有迷路诅咒时，显示当前房间门的布局
    - 房间大于1x1时，显示当前房间所有道具底座
    - 拥有[生死逆转]时，显示所有道具底座及其虚影道具

其他：
- 暂停时，也显示时间统计柱状图
----------------------------------------------------------------
v1.1.0：
修复：
- 有时开局会自动扔卡牌饰品的问题
- 遗骸能在准备状态下切换灵魂的问题
- 堕化遗骸使用[诅咒硬币]时不会掉落的问题
- 究极贪婪的二阶段血量异常多出15%的问题
- 局内更换角色，导致左下角角色显示变化的问题
- 房间内有多个奖杯时，只有第一个奖杯能正常结算的问题

优化：
- 究极贪婪终点，踩下按钮时会清理地面上的空底座和空箱子
- 掉落奖杯时，移除羔羊身体的碰撞箱，防止拿不到奖杯

新增：
- 结算时，显示每层耗时柱状图

调整：
- 在教堂/阴间，若没有持有正确的[全家福]/[底片]，大宝箱会被替换为虚空门
- 将究极贪婪对玩家造成的伤害，同步到困难贪婪模式的水平（无视子宫层伤害修正）
- 第二章节及之后，不会再生成XL诅咒
- 获得失忆症药丸时，会立即将其识别
- 走错路线并击杀其他终点的最终BOSS，会生成一个虚空门而不是大宝箱
- 见证者路线下，矿层只需要踩下一个按钮即可进入逃亡区域
- 见证者路线下，白火、镜子、刀柄、矿车房间的位置会在地图上点亮

其他：
- 更换了祸兽终点的选择音效，旧的音效太吵了
- 移除了强行关闭滤镜设置的机制
- 纪录功能现在支持XL诅咒以及回溯路线
- 比赛开始时，左下角的层数纪录不再是“无”，而是当前所在的层数
- 准备状态、暂停状态、结算状态下，左下角的角色、种子、目标显示为绿色
- 结算时，左下角层数会显示为99层，层名称为完成
- 移除了背景图片的占位文件，因为占位文件会导致每次更新都需要重新覆盖
----------------------------------------------------------------
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
Dispatcher:Clear()
BISAI_PLUS.Dispatcher = Dispatcher

local DEFAULT_RECORD = {
	Time = 0,
	LevelStage = 0,
	StageType = 0,
	IsAscent = false,
	IsXL = false,
	LevelWeight = 0,
	LevelName = "未知",
}

local DEFAULT_DATA = {
	Save = {
		PlayerName = "未知角色",
		DeathCount = 0,
		State = Shared.State.READY,
		Goal = Shared.Goal.MEGA_SATAN,
		Timer = {
			StoredTime = 0,
		},
		Record = Utils.DeepCopy(DEFAULT_RECORD),
		Records = {},
	},
	Runtime = {
		InGame = false,
		Timer = {
			StartTime = 0,
		},
	},
	PluginSave = {},
}

local Data = Utils.DeepCopy(DEFAULT_DATA)

BISAI_PLUS.Data = Data

local Messages = require("bisai+.messages")
local MessageBus = require("bisai+.message_bus")
MessageBus:Clear()

function BISAI_PLUS.LoadPlugin(pluginName)
	BISAI_PLUS.CurrentPluginAPI = {
		Name = pluginName,
		GetSaveData = function()
			return BISAI_PLUS.Data.PluginSave[pluginName]
		end,
		SetSaveData = function(data)
			BISAI_PLUS.Data.PluginSave[pluginName] = data
		end,
		ClearSaveData = function()
			BISAI_PLUS.Data.PluginSave[pluginName] = nil
		end,
	}
	include("plugins." .. pluginName)
	BISAI_PLUS.CurrentPluginAPI = nil
end

BISAI_PLUS.LoadPlugin("card_emperor") -- 修改皇帝卡效果，向着BOSS房方向前进4格，如果有塔罗牌桌布，改为6格
BISAI_PLUS.LoadPlugin("fix_teleport_softlock") -- 修复进房间立刻使用传送主动会卡住的问题
BISAI_PLUS.LoadPlugin("goal_ultra_greed") -- 大贪婪终点的BOSS实现
BISAI_PLUS.LoadPlugin("item_d4") -- 修改D4效果，使用时，视为拥有混沌，持有编号丢失时不受影响
BISAI_PLUS.LoadPlugin("mechanic_ban_input") -- 准备阶段和暂停状态禁止任何角色操作
BISAI_PLUS.LoadPlugin("itempool_filter_natural") -- 控制部分道具在野生生成时的权重
BISAI_PLUS.LoadPlugin("mechanic_room_radar") -- 房间雷达功能
BISAI_PLUS.LoadPlugin("mechanic_broken_heart_damage") -- 超时加碎心之后，根据碎心数量增加攻击力
BISAI_PLUS.LoadPlugin("mechanic_chest_to_trophy") -- 将通关大宝箱替换为奖杯
BISAI_PLUS.LoadPlugin("mechanic_disable_lamb_collision") -- 掉落奖杯时，移除羔羊身体的碰撞箱并使其半透明，防止选手拿不到奖杯
BISAI_PLUS.LoadPlugin("mechanic_identify_amnesia_pill") -- 获得失忆症药丸时，立刻将其识别
BISAI_PLUS.LoadPlugin("mechanic_kill_lost") -- 如果lost碎心满了，切换房间时处死lost，解决lost在碎心满了之后还能继续比赛的问题
BISAI_PLUS.LoadPlugin("mechanic_minecart_button") -- 在见证者路线里，矿层只需要踩一个按钮就可以进入逃亡区域
BISAI_PLUS.LoadPlugin("mechanic_polaroid_negative") -- 根据终点，自动把全家福修改为底片或者把底片修改为全家福
BISAI_PLUS.LoadPlugin("mechanic_remove_beast_cutscene") -- 祸兽播放死亡动画时直接移除，防止全屏变白
BISAI_PLUS.LoadPlugin("mechanic_remove_curses") -- 移除黑暗诅咒和迷路诅咒，第二章节及之后移除XL诅咒
BISAI_PLUS.LoadPlugin("mechanic_reveal_rooms") -- 在见证者路线的前两章节的支线层中，揭示白火房间、镜子房间、刀柄房间、矿车房间的位置。
BISAI_PLUS.LoadPlugin("mechanic_revive") -- 结算之后，让玩家免死
BISAI_PLUS.LoadPlugin("mechanic_stop_game_time") -- 准备时，暂停游戏时间
BISAI_PLUS.LoadPlugin("mechanic_time_limit") -- 时间限制，超过30分钟根据时间增加碎心
BISAI_PLUS.LoadPlugin("mechanic_void_map") -- 百变怪终点，进入虚空时显示地图
BISAI_PLUS.LoadPlugin("mechanic_void_portal") -- 教堂/阴间如果没有对应的全家福/底片，宝箱被替换为虚空门
BISAI_PLUS.LoadPlugin("mechanic_wrong_goal_void_portal") -- 误入其他终点的最终房间之后，击杀最终BOSS生成虚空门
BISAI_PLUS.LoadPlugin("route_beast_close_door") -- 祸兽路线，关闭错误的门，防止选手走错
BISAI_PLUS.LoadPlugin("route_beast_mom_exit") -- 祸兽路线击杀妈腿之后，允许离开BOSS房
BISAI_PLUS.LoadPlugin("route_delirium_trophy") -- 百变怪房间始终生成奖杯
BISAI_PLUS.LoadPlugin("route_mega_satan_key") -- 大撒旦终点给钥匙碎片
BISAI_PLUS.LoadPlugin("route_mother_close_door") -- 见证者路线，关闭错误的门，防止选手走错
BISAI_PLUS.LoadPlugin("route_mother_knife_check") -- 见证者路线如果不拿剧情刀碎片，就禁止下层
BISAI_PLUS.LoadPlugin("route_mother_open_door") -- 见证者路线自动无代价开启支线门
BISAI_PLUS.LoadPlugin("route_path_restriction") -- 妈心和凹凸层防止防止走到错误的天堂/地狱层
BISAI_PLUS.LoadPlugin("trinket_broken_remote") -- 修改破传效果，触发时掉落在地上
BISAI_PLUS.LoadPlugin("trinket_cursed_penny") -- 咒币效果修改，触发时掉落在地上


local Json = require("json")

local ConfigManager = require("bisai+.config_manager")

include("effect_manager")

include("ui") -- UI相关
local debugger = include("debugger")
if debugger.Init then
	debugger:Init(Data)
end

local function GetRecord()
	return Utils.DeepCopy(Data.Save.Record or DEFAULT_RECORD)
end

local function GetCandidateRecord()
	local level = Game():GetLevel()
	local levelStage = level:GetStage()
	local stageType = level:GetStageType()

	-- 仅在处于 RUNNING 状态下才累加时间并设置 StartTime
	-- 这样如果在 PAUSED 或 FINISHED 状态下调用此函数构造 Record，时间就不会错误地产生偏移或重复计算
	if Data.Save.State == Shared.State.RUNNING then
		local current_time = Isaac.GetTime()
		local elapsed = current_time - Data.Runtime.Timer.StartTime
		Data.Save.Timer.StoredTime = Data.Save.Timer.StoredTime + elapsed
		Data.Runtime.Timer.StartTime = current_time
	end

	local candidateRecord = {
		Time = Data.Save.Timer.StoredTime,
		LevelStage = levelStage,
		StageType = stageType,
		IsAscent = level:IsAscent(),
		IsXL = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == LevelCurse.CURSE_OF_LABYRINTH,
	}

	if Data.Save.State == Shared.State.FINISHED then
		candidateRecord.LevelWeight = 99
		candidateRecord.LevelName = "完成"
	else
		local recordStageInfo = GameUtils.GetStageInfo(candidateRecord)
		candidateRecord.LevelWeight = recordStageInfo.Weight
		candidateRecord.LevelName = recordStageInfo.Name
	end
	return candidateRecord
end

local function LoadModData()
	local config = {}
	if BISAI_PLUS:HasData() then
		local success, data = pcall(Json.decode, BISAI_PLUS:LoadData())
		if success and data then
			Utils.DeepAssignExisting(Data.Save, data.Save or {})

			if data.Save and data.Save.Records then
				Data.Save.Records = Utils.DeepCopy(data.Save.Records)
			end
			if data.PluginSave then
				Data.PluginSave = Utils.DeepCopy(data.PluginSave)
			end

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
			PlayerName = Data.Save.PlayerName,
			DeathCount = Data.Save.DeathCount,
			State = state,
			Goal = Data.Save.Goal,
			Timer = {
				StoredTime = Data.Save.Timer.StoredTime,
			},
			Record = GetRecord(),
			Records = Data.Save.Records,
		},
		PluginSave = Data.PluginSave,
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
		PlayerName = Data.Save.PlayerName,
		DeathCount = Data.Save.DeathCount,
		Record = GetRecord(),
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
	if Data.Save.State ~= Shared.State.PAUSED then
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
	Data.Save.Record = Utils.DeepCopy(DEFAULT_RECORD)
	Data.Save.Records = {}

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
	Data.Save.PlayerName = payload.PlayerName
	Data.Save.DeathCount = 0
	Data.Save.Record = GetCandidateRecord()
	Data.Save.Records = {}
	table.insert(Data.Save.Records, Data.Save.Record)
	SaveModData()
	MessageBus:Emit(Messages.Event.RUN_STARTED, GetPayload())
end

local function HandleSetPlayerType(payload)
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
	if Data.Save.State ~= Shared.State.PAUSED then
		return
	end

	if Data.Save.Goal == Shared.Goal.MEGA_SATAN then
		for i = 0, Game():GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1)
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)
		end
	end

	Data.Save.Goal = payload.Goal
	MessageBus:Emit(Messages.Event.GOAL_SET, GetPayload())
end

local function OnUpdate()
	Dispatcher:Run()
end

local function CheckTrophyAnimationFinished(player)
	local data = player:GetData()
	local state = Data.Save.State

	-- 是否在举起奖杯动画中
	if not data.BisaiPlus_TrophyPickupFrame then
		return
	end

	-- 举起奖杯的过程中死了不结算（例如C计划、狂暴头时间结束）
	if player:IsDead() then
		return
	end

	-- 计算举起奖杯已经过的帧数
	local framesSinceTrophyPickup = Game():GetFrameCount() - data.BisaiPlus_TrophyPickupFrame
	-- 结算情况1：动画结束
	-- 结算情况2：举起奖杯超过35帧（满碎心情况下举奖杯动画结束之后会死亡，因此在死亡的前1帧结算）
	local isTrophySecured = player:IsExtraAnimationFinished() or framesSinceTrophyPickup >= 35

	if isTrophySecured then
		data.BisaiPlus_TrophyPickupFrame = nil
		player.ControlsEnabled = true
		player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

		-- 防止重复结算
		if state == Shared.State.FINISHED then
			return
		end

		-- 如果是暂停状态，先解除暂停状态
		if state == Shared.State.PAUSED then
			MessageBus:Send(Messages.Command.RESUME_RUN)
		end

		Data.Save.State = Shared.State.FINISHED
		PauseTimer()

		local candidateRecord = GetCandidateRecord()

		Data.Save.Record = candidateRecord
		table.insert(Data.Save.Records, candidateRecord)
		MessageBus:Emit(Messages.Event.RECORD_UPDATED, GetPayload())

		MessageBus:Emit(Messages.Event.RUN_FINISHED, GetPayload())
	end
end

local function HandleTrophyPickup(player)
	local data = player:GetData()
	-- 如果刚刚举起奖杯，则删除奖杯
	if player.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
		local trophies = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY, -1, true, true)
		-- 角色碰到奖杯的时候，角色会播放举起奖杯的动画，奖杯会被置为不可见并且碰撞体积被关闭，实际上奖杯还在原地，手上的只是一个贴图
		for _, trophy in ipairs(trophies) do
			if not trophy.Visible then
				-- 动画结束之后，地上的不可见的奖杯会使得游戏通关，因此需要先把它移除掉
				trophy:Remove()
				-- 为了让选手在满碎心状态下能举起奖杯，记录一下当前帧数，这样可以在死前一帧结算奖杯
				data.BisaiPlus_TrophyPickupFrame = Game():GetFrameCount()
			end
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
	LoadModData()

	repeat
		if isContinued then
			break
		end

		local seeds = Game():GetSeeds()
		if not seeds:IsCustomRun() then
			local seedStr = seeds:GetStartSeedString()
			Isaac.ExecuteCommand("seed " .. seedStr)
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
	-- 层数纪录
	local candidateRecord = GetCandidateRecord()

	if candidateRecord.LevelWeight > Data.Save.Record.LevelWeight then
		Data.Save.Record = candidateRecord
		table.insert(Data.Save.Records, candidateRecord)
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
MessageBus:Handle(Messages.Command.SET_PLAYER_TYPE, HandleSetPlayerType)
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
