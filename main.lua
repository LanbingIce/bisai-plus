BISAI_PLUS = RegisterMod("bisai+", 1)
BISAI_PLUS.Version = "1.5.1"
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
- 手柄操作：
    - 按下丢弃键+菜单键呼出控制面板
    - 键盘使用回车键的操作，手柄改为使用主动键
    - 其他操作与键盘相同，并且手柄模式也完全支持鼠标操作

道具生成改动：
- 降低了以下道具的生成权重
    - 我们需要深入挖掘：恶魔房道具池 1 → 0.25
    - 残损铁镐: 商店道具池 1 → 0.25
    - 水星: 星象房道具池 1 → 0.25
    - 地球: 星象房道具池 1 → 0.25
    - 牌意解读: 商店道具池 0.5 → 0.25
- 隐藏房的野生道具不会出现以下道具，重Roll或者其他途径生成的不受影响：
    - 我们需要深入挖掘！
    - 史诗胎儿博士
    - 烟火盛宴
    - 无限面骰
    - 谷底石
    - 超级蘑菇
    - 死亡证明
    - 大胃王
    - 错误王冠
    - 十字圣球
    - 生死逆转
    - 计数二十面骰

道具效果改动：
- 皇帝卡：效果改为由当前房间向BOSS方向前进4格，持有[塔罗牌桌布]时改为6格
- 四面骰：生效时，视为拥有[混沌]，持有[编号丢失]时不受影响，角色为堕化伊甸时不受影响
- 诅咒硬币：触发时掉落
- 损坏的遥控器：触发时掉落，金色版本/持有多个/持有[妈妈的盒子]时不受影响

修复游戏BUG：
- 修复了进房间立刻使用传送类主动，游戏会卡住的问题
- 堕化遗骸在跳下活板门时可以使用主动道具的问题

其他改动：
- 获得失忆症药丸时，会立即将其识别
- 黑暗诅咒和迷途诅咒不会自然生成，使用药丸获得的不受影响
- 对游戏中大量烦人的动画进行了加速处理

便利功能：
- 房间雷达功能，按住地图键时生效，在特定情况下会显示：
    - 房间大于1x1且有迷路诅咒时，显示当前房间门的布局
    - 房间大于1x1时，显示当前房间所有道具底座
    - 拥有[生死逆转]时，显示所有道具底座及其虚影道具
- 快速启用、禁用控制台功能：按下~键启用控制台，按下ctrl+~禁用控制台

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
v1.5.1：
修复：
- 使用Mod练习足够多的局数之后，开局出现严重卡顿的问题
----------------------------------------------------------------
v1.5.0：
修复：
- 当游戏窗口分辨率改变时，主窗口的位置没有自动改变的问题
- 准备状态下roll角色种子、长按R键等操作会导致选定的终点变回超级撒但的问题
- 手柄按下左十字键的右键会触发键盘回车键的问题
- 在有圣饼或者圣饼效果时，究极贪婪的大金币弹幕依旧造成整心伤害的问题
- 点击控制面板上的暂停按钮时，UI会报错的问题

新增：
- 超级种子功能：准备状态下在控制台中粘贴或者键入超级种子，会自动设置好角色，种子，终点
- 修复了游戏bug：堕化遗骸在跳下活板门时可以使用主动道具的问题
- 快速启用、禁用控制台：按下~键启用控制台，按下ctrl+~禁用控制台

其他：
- 控制面板里快速开关控制台的按钮改为快速开关滤镜
- 大幅调整了左下角信息面板的显示布局和逻辑
    - 把死亡数和目标放在一行，布局更紧凑
    - 标签始终显示为默认文字颜色，只有重要信息才会变色
    - 未选择新开局就重开游戏导致种子变化时，种子会显示为红字
    - 死亡次数大于等于3时，显示为红色
    - 增加了超级种子的显示
    - 准备状态下，纪录显示为无
----------------------------------------------------------------
v1.4.0：
修复：
- 呼出控制面板不暂停直接小退，继续游戏时控制面板不是暂停状态的问题
- 使用手柄时，选择终点会跳到上一个终点的问题
- 暂停状态下，可以丢弃卡牌饰品的问题
- 终点是超级撒但时，每次使用[小以扫]，都会增加一对钥匙碎片的问题
- 在举起奖杯时暂停计时器，会导致结算时间有误的问题

新增：
- 重做[四面骰]改动，废弃移除道具的改法，改为使用时视为拥有[混沌]，持有[编号丢失]时不受影响
- 【重要】不再删除隐藏房地形
- 【重要】隐藏房的野生道具不会出现以下道具，重Roll或者其他途径生成的不受影响：
    - 我们需要深入挖掘！
    - 史诗胎儿博士
    - 烟火盛宴
    - 无限面骰
    - 谷底石
    - 超级蘑菇
    - 死亡证明
    - 大胃王
    - 错误王冠
    - 十字圣球
    - 生死逆转
    - 计数二十面骰

其他：
- 修正UI中的错别字：“记录”->“纪录”
- 动画加速不再用删除动画帧的方式实现，而是改为固定4倍加速，并补充遗漏的巴比伦动画、睡觉动画等
- 允许手柄在打开游戏菜单时用控制面板进行继续游戏和新开局的操作（因为手柄的主动键不会影响游戏菜单）
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
		Seed = 0,
		PlayerType = PlayerType.PLAYER_POSSESSOR,
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

-- 插件列表（每一项为 { Name=string, Desc=string }）
BISAI_PLUS.Plugins = BISAI_PLUS.Plugins or {}

local Messages = require("bisai+.messages")
local MessageBus = require("bisai+.message_bus")
MessageBus:Clear()

function BISAI_PLUS.LoadPlugin(pluginName, pluginDesc)
	BISAI_PLUS.Plugins = BISAI_PLUS.Plugins or {}

	-- 创建插件记录并插入（先插入以便插件在 include 时可以修改描述）
	local pluginRecord = {
		Name = pluginName,
		Desc = pluginDesc or "",
	}
	table.insert(BISAI_PLUS.Plugins, pluginRecord)

	-- CurrentPluginAPI 暴露给插件使用，绑定 Description 字段到 pluginRecord.Desc
	local api = {
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
		-- 直接通过 `CurrentPluginAPI.Desc` 读写描述（由元表映射到 pluginRecord.Desc）
	}
	-- 通过元表，使得直接读写 api.Desc 会映射到 pluginRecord.Desc
	setmetatable(api, {
		__index = function(t, k)
			if k == "Desc" then
				return pluginRecord.Desc
			end
			return rawget(t, k)
		end,
		__newindex = function(t, k, v)
			if k == "Desc" then
				pluginRecord.Desc = tostring(v or "")
			else
				rawset(t, k, v)
			end
		end,
	})

	BISAI_PLUS.CurrentPluginAPI = api
	include("plugins." .. pluginName)
	BISAI_PLUS.CurrentPluginAPI = nil
end
-- 通过第二个参数在加载时传入插件简介，避免重复维护两处文本
BISAI_PLUS.LoadPlugin(
	"card_emperor",
	"修改皇帝卡：从当前房间按最短路径向BOSS房前进4格，持有[塔罗牌桌布]时改为6格"
)
BISAI_PLUS.LoadPlugin(
	"fix_t_forgotten_control_sync",
	"修复：堕化遗骸的灵魂的无法控制状态有时没有正确同步到本体的问题"
)
BISAI_PLUS.LoadPlugin("fix_teleport_softlock", "修复：进入房间的第一帧使用传送类主动导致的软锁")
BISAI_PLUS.LoadPlugin("goal_ultra_greed", "究极贪婪终点的实现")
BISAI_PLUS.LoadPlugin(
	"item_d4",
	"修改[四面骰]：生效时，视为拥有[混沌]，持有[编号丢失]时不受影响"
)
BISAI_PLUS.LoadPlugin("itempool_filter_natural", "在生成野生道具时，控制部分道具的权重")
BISAI_PLUS.LoadPlugin("mechanic_ban_input", "准备状态和暂停状态禁止角色操作")
BISAI_PLUS.LoadPlugin("mechanic_broken_heart_damage", "超时加碎心之后，根据碎心数量增加攻击倍率")
BISAI_PLUS.LoadPlugin("mechanic_chest_to_trophy", "将通关大宝箱替换为奖杯")
BISAI_PLUS.LoadPlugin(
	"mechanic_disable_lamb_collision",
	"掉落奖杯时，移除羔羊身体的碰撞箱并使其半透明，防止选手拿不到奖杯"
)
BISAI_PLUS.LoadPlugin("mechanic_identify_amnesia_pill", "获得失忆症药丸时，立刻将其识别")
BISAI_PLUS.LoadPlugin("mechanic_kill_lost", "如果游魂/堕化游魂碎心满了，切换房间时将其处死")
BISAI_PLUS.LoadPlugin(
	"mechanic_minecart_button",
	"在母亲路线里，矿层只需要踩一个按钮就可以进入逃亡区域"
)
BISAI_PLUS.LoadPlugin(
	"mechanic_polaroid_negative",
	"根据终点，自动把[全家福]修改为[底片]或者把[底片]修改[为全家福]"
)
BISAI_PLUS.LoadPlugin(
	"mechanic_remove_beast_cutscene",
	"祸兽播放死亡动画时直接将其移除，防止全屏变白"
)
BISAI_PLUS.LoadPlugin(
	"mechanic_remove_curses",
	"移除黑暗诅咒和迷路诅咒，第二章节及之后移除XL诅咒"
)
BISAI_PLUS.LoadPlugin(
	"mechanic_reveal_rooms",
	"在母亲路线的前两章节的支线层中，揭示白火房间、镜子房间、刀柄房间、矿车房间的位置。"
)
BISAI_PLUS.LoadPlugin("mechanic_revive", "结算之后，让角色免死")
BISAI_PLUS.LoadPlugin("mechanic_room_radar", "房间雷达功能")
BISAI_PLUS.LoadPlugin("mechanic_stop_game_time", "准备状态下，暂停游戏时间")
BISAI_PLUS.LoadPlugin("mechanic_time_limit", "时间限制，超过30分钟根据时间增加碎心")
BISAI_PLUS.LoadPlugin("mechanic_void_map", "精神错乱终点，进入虚空层时显示地图")
BISAI_PLUS.LoadPlugin(
	"mechanic_void_portal",
	"在教堂/阴间，如果没有正确的[全家福]/[底片]，宝箱被替换为虚空门"
)
BISAI_PLUS.LoadPlugin(
	"mechanic_wrong_goal_void_portal",
	"误入其他终点的最终房间之后，击杀最终BOSS生成虚空门"
)
BISAI_PLUS.LoadPlugin("route_beast_close_door", "祸兽路线，关闭错误的活板门，防止选手走错")
BISAI_PLUS.LoadPlugin("route_beast_mom_exit", "祸兽路线击杀妈腿之后，允许离开BOSS房")
BISAI_PLUS.LoadPlugin("route_delirium_trophy", "精神错乱房间始终生成奖杯")
BISAI_PLUS.LoadPlugin("route_mega_satan_key", "超级撒但终点始终给予钥匙碎片")
BISAI_PLUS.LoadPlugin("route_mother_close_door", "见证者路线，关闭错误的活板门，防止选手走错")
BISAI_PLUS.LoadPlugin("route_mother_open_door", "见证者路线自动无代价开启支线门")
BISAI_PLUS.LoadPlugin("route_path_restriction", "妈心和死寂层防止走到错误的教堂/阴间层")
BISAI_PLUS.LoadPlugin("trinket_broken_remote", "修改[损坏的遥控器]：触发时掉落在地上")
BISAI_PLUS.LoadPlugin("trinket_cursed_penny", "修改[诅咒硬币]：触发时掉落在地上")

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
			Seed = Data.Save.Seed,
			PlayerType = Data.Save.PlayerType,
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
	local runConfig = {
		Goal = Data.Save.Goal,
		PlayerType = Data.Save.PlayerType,
		Seed = Data.Save.Seed,
	}
	return {
		State = Data.Save.State,
		Goal = Data.Save.Goal,
		Timer = GetTimer(),
		Seed = Data.Save.Seed,
		SeedString = GameUtils.SeedToString(Data.Save.Seed),
		SuperSeed = Utils.GenerateModSeed(runConfig),
		PlayerType = Data.Save.PlayerType,
		PlayerName = Shared.PlayerNameMap[Data.Save.PlayerType] or "未知角色",
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
	Data.Save.Seed = payload.Seed
	Data.Save.PlayerType = payload.PlayerType
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

	Dispatcher:Run()
end

local function OnGameExit()
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
	OnGameStarted(nil, true)
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
