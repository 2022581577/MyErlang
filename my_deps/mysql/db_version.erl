%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.07.29.
%%% @desc   : 日志同步日志入库模块
%%%----------------------------------------------------------------------
-module(db_version).

-include("common.hrl").
-export([check_version/0,
         execute/1]).

check_version() ->
    DbVersion = ?GLOBAL_DATA_DISK:get(log_version, 0),
    VersionList = case DbVersion >= ?SQL_VERSION of
                    true -> 
                        [];
                    _ -> 
                        lists:seq(DbVersion + 1, ?SQL_VERSION)
                  end,
    ?WARNING("check_version, VersionList:~w", [VersionList]),
    [version_sql(E) || E <- VersionList],
    case VersionList of
        [] ->
            skip;
        _ ->
            ?GLOBAL_DATA_DISK:set(log_version, ?SQL_VERSION),
            ?GLOBAL_DATA_DISK:sync()
    end,
    %% 删除一些超时的filename
    ok.

version_sql(1) ->
    db_sql:version(),
    ok;
%% 中间不需要执行其他一直到当前版本号
version_sql(43) ->
    ok;
%% 有新的语句修改直接用最新版本号

version_sql(44) ->
    Sql1 = "ALTER TABLE `rcd_equip_stren`
            ADD COLUMN `auto_buy` tinyint(2) NOT NULL DEFAULT '0' COMMENT '是否自动购买' AFTER `new_proficiency`,
            ADD COLUMN `cost_item_num` int(11) NOT NULL DEFAULT '0' COMMENT '消耗道具数量' AFTER `new_proficiency`,
            ADD COLUMN `cost_item_id` int(11) NOT NULL DEFAULT '0' COMMENT '消耗道具id' AFTER `new_proficiency`,
            ADD COLUMN `cost_coin` int(11) NOT NULL DEFAULT '0' COMMENT '消耗铜钱' AFTER `new_proficiency`,
            ADD COLUMN `cost_yuanbao` int(11) NOT NULL DEFAULT '0' COMMENT '消耗元宝' AFTER `new_proficiency`",
    execute(Sql1),

    Sql2 = "ALTER TABLE `rcd_equip_up`
            ADD COLUMN `cost_items` varchar(512) COMMENT '消耗道具' AFTER `op_type`,
            ADD COLUMN `cost_coin` int(11) NOT NULL DEFAULT '0' COMMENT '消耗铜钱' AFTER `op_type`",
    execute(Sql2),

    Sql3 = "ALTER TABLE `rcd_yanwuchang`
            ADD COLUMN `times` int(11) NOT NULL DEFAULT '0' COMMENT '剩余挑战次数' AFTER `opp_id`",
    execute(Sql3),

    Sql4 = "CREATE TABLE IF NOT EXISTS `rcd_rune_making` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '炼制类型：1、元宝炼制，2、铜钱炼制',
            `division_id` int(11) NOT NULL DEFAULT '0' COMMENT '炼制师id',
            `rune_id` int(11) NOT NULL DEFAULT '0' COMMENT '获得符文id',
            `cost_yuanbao` int(11) NOT NULL DEFAULT '0' COMMENT '消耗元宝',
            `cost_coin` int(11) NOT NULL DEFAULT '0' COMMENT '消耗铜钱',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='符文炼制日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql4),

    Sql5 = "ALTER TABLE `rcd_equip_jewel`
            ADD COLUMN `cost_coin` int(11) NOT NULL DEFAULT '0' COMMENT '消耗铜钱' AFTER `jewel_id`",
    execute(Sql5),
    ok;

version_sql(45) ->
    Sql1 = "ALTER TABLE `rcd_arena`
            ADD COLUMN `start_time` int(11) NOT NULL DEFAULT '0' COMMENT '挑战开始时间' AFTER `himnewrank`",
    execute(Sql1),

    Sql2 = "CREATE TABLE IF NOT EXISTS `rcd_daily_task` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '日常类型：1、通关主线副本，2、精英试炼，3、魔王试炼，4、聚宝兽，5、竞技场，6、魂魄，7、洗练，8、符文，9、聚星',
            `quality` tinyint(2) NOT NULL DEFAULT '0' COMMENT '品质：1绿2蓝3紫4橙',
            `state` tinyint(2) NOT NULL DEFAULT '0' COMMENT '任务状态：0接受1完成',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='日常任务日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql2),
    
    Sql3 = "CREATE TABLE IF NOT EXISTS `rcd_buy_coin` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `times` int(11) NOT NULL DEFAULT '0' COMMENT '招财次数',
            `cost_yuanbao` int(11) NOT NULL DEFAULT '0' COMMENT '消耗元宝',
            `gain_coin` int(11) NOT NULL DEFAULT '0' COMMENT '获得铜钱',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='招财天女日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql3),
    ok;

version_sql(46) ->
    Sql1 = "ALTER TABLE `player`
            ADD COLUMN `id` int(11) NOT NULL DEFAULT '0' COMMENT '自增id' AFTER `pid`",
    execute(Sql1),
    ok;

version_sql(47) ->
    Sql1 = "ALTER TABLE `rcd_arena`
            ADD COLUMN `rest_times` int(11) NOT NULL DEFAULT '0' COMMENT '剩余挑战次数' AFTER `start_time`",
    execute(Sql1),
    ok;

version_sql(48) ->
    Sql1 = "ALTER TABLE `rcd_user_pvp_equip`
            ADD COLUMN `pvp_equip` varchar(1024) NOT NULL COMMENT '杀器结构' AFTER `lv`",
    execute(Sql1),
    ok;

version_sql(49) ->
    Sql1 = "ALTER TABLE `rcd_login_step`
            ADD COLUMN `is_new` tinyint(2) NOT NULL DEFAULT '0' COMMENT '是否新号：0、非新号，1、新号' AFTER `step`",
    execute(Sql1),
    ok;

version_sql(50) ->
    Sql1 = "ALTER TABLE `rcd_copy`
            Add COLUMN `dup_type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '副本类型:1-普通副本 2-精英 3-魔王 4-搬山卸岭...' AFTER `copy_type`",
    execute(Sql1),

    Sql2 = "CREATE TABLE IF NOT EXISTS `rcd_world_boss` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `act_id` int(11) NOT NULL DEFAULT '0' COMMENT '活动ID',
            `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型 0-最后一击 1-排名奖',
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `rank` int(11) NOT NULL DEFAULT '0' COMMENT '排名',
            `hurt` float DEFAULT NULL COMMENT '伤害百分比',
            `reward` varchar(1024) NOT NULL COMMENT '奖励',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='世界boss活动日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql2),
    ok;

version_sql(51) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_user_property` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `pro_type` int(11) NOT NULL DEFAULT '0' COMMENT '类型 1阅历2声望3功勋4武魂',
            `old_value` int(11) NOT NULL DEFAULT '0' COMMENT '变更前值',
            `new_value` int(11) NOT NULL DEFAULT '0' COMMENT '变更后值',
            `source` int(11) DEFAULT NULL COMMENT '来源',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家属性变更日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    ok;

version_sql(52) ->
    Sql = "ALTER TABLE `rcd_user_property`
    Add COLUMN `add_value` int(11) NOT NULL DEFAULT '0' COMMENT '增加值' AFTER `new_value`",
    execute(Sql),
    ok;

version_sql(53) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_wujiang_combine` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `cost_items` varchar(1024) NOT NULL COMMENT '消耗的武将卡',
            `new_card` int(11) NOT NULL DEFAULT '0' COMMENT '获得的武将卡',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='武将卡合成日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    Sql2 = "CREATE TABLE IF NOT EXISTS `rcd_ride_pet` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `ride_pet_info` varchar(1024) NOT NULL COMMENT '骑宠信息',
            `source` int(11) DEFAULT NULL COMMENT '来源',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='骑宠日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql2),
    ok;

version_sql(54) ->
    Sql = "ALTER TABLE `rcd_online`
    Add COLUMN `ip_count` int(11) NOT NULL DEFAULT '0' COMMENT 'IP在线人数' AFTER `op_count`",
    execute(Sql),
    ok;

version_sql(55) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_dianjiang` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `cost_yuanbao` int(11) NOT NULL DEFAULT '0' COMMENT '消耗元宝',
            `cost_coin` int(11) NOT NULL DEFAULT '0' COMMENT '消耗铜钱',
            `wujiang_id` int(11) NOT NULL DEFAULT '0' COMMENT '武将id',
            `qual` int(2) NOT NULL DEFAULT '0' COMMENT '武将品质',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='点将台日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    ok;

version_sql(56) ->
    Sql = "CREATE TABLE IF NOT EXISTS `rcd_jhm_award` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `jhm_type` int(11) NOT NULL COMMENT '激活码类型',
            `account_name` varchar(1024) NOT NULL COMMENT '玩家账号',
            `plat` varchar(1024) NOT NULL COMMENT '平台',
            `server_id` varchar(1024) NOT NULL COMMENT '服务器id',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='激活码领取日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql),
    ok;
version_sql(57) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_pvp_activity` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `type` int(11) NOT NULL DEFAULT '0' COMMENT '活动类型 1-夺宝奇兵 2-封魔录',
            `num` int(11) DEFAULT NULL COMMENT '参加人数',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='pvp活动日志' PARTITION BY HASH (id) PARTITIONS 10",
    execute(Sql1),

    Sql2 = "CREATE TABLE IF NOT EXISTS `rcd_pve_error` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `dup_id` bigint(20) NOT NULL DEFAULT '0'  COMMENT '副本ID',
            `type` int(11) NOT NULL DEFAULT '0' COMMENT '异常类型',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='pve副本异常日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql2),
    ok;

version_sql(58) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_guild_task` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
            `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型',
            `quality` tinyint(2) NOT NULL DEFAULT '0' COMMENT '品质：1绿2蓝3紫4橙',
            `state` tinyint(2) DEFAULT NULL COMMENT '任务状态：0接受1完成',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派任务日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    ok;

version_sql(59) ->
    Sql = "ALTER TABLE `rcd_user_property`
        CHANGE `pro_type` `pro_type` int(11) NOT NULL DEFAULT '0' COMMENT '类型 1阅历2声望3功勋4武魂5体力6额外体力7特殊体力'",    
    db_util:execute(Sql),
    ok;

version_sql(60) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_admin` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `cmd` int NOT NULL DEFAULT '0' COMMENT '协议号',
            `ip` varchar(64) NOT NULL DEFAULT '' COMMENT 'IP地址',
            `type` varchar(64) NOT NULL DEFAULT '' COMMENT '错误类型',
            `content` text DEFAULT NULL COMMENT '消息内容',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='后台访问日志' PARTITION BY HASH (id) PARTITIONS 10",
    execute(Sql1),
    ok;

version_sql(61) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_change_map` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `old_map_id` int NOT NULL DEFAULT '0' COMMENT '原地图ID',
            `old_only_id` int NOT NULL DEFAULT '0' COMMENT '原地图唯一ID',
            `map_id` int NOT NULL DEFAULT '0' COMMENT '新地图ID',
            `only_id` int DEFAULT NULL COMMENT '新地图唯一ID',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='转场日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    ok;
version_sql(62) ->
    Sql = "ALTER TABLE `rcd_guild_battle`
        MODIFY `guild_team` text,
        MODIFY `round_list` text",
    execute(Sql),
    ok;

version_sql(63) ->
    Sql = "ALTER TABLE `rcd_change_map`
        CHANGE `pid` `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid'",    
    db_util:execute(Sql),
    ok;

version_sql(64) ->
    Sql = "CREATE TABLE IF NOT EXISTS `rcd_item_question` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `item_id` int(11) DEFAULT NULL COMMENT '礼包道具id',
            `question_id` int(11) DEFAULT NULL COMMENT '问题id',
            `answer_id` int(11) DEFAULT NULL COMMENT '答案id',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='礼包问卷日志' PARTITION BY HASH (pid) PARTITIONS 10",
    db_util:execute(Sql),
    ok;

version_sql(65) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_slow_heartbeat` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `is_pve` tinyint NOT NULL DEFAULT '0' COMMENT '是否PVE',
            `map_id` int NOT NULL DEFAULT '0' COMMENT '地图ID',
            `only_id` int DEFAULT NULL COMMENT '地图唯一ID',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='慢心跳状态被踢日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    ok;

version_sql(66) ->
    Sql = "ALTER TABLE `rcd_slow_heartbeat` Add COLUMN `map_type` int(11) NOT NULL DEFAULT '0' COMMENT '地图类型' after only_id",
    execute(Sql),
    Sql2 = "ALTER TABLE `rcd_slow_heartbeat` Add COLUMN `cmd` int(11) NOT NULL DEFAULT '0' COMMENT '最后接收协议' after map_type",
    execute(Sql2),
    ok;

version_sql(67) ->
    Sql = "ALTER TABLE `rcd_slow_heartbeat` Add COLUMN `cmd_list` varchar(64) NOT NULL DEFAULT '' COMMENT '地图类型' after `cmd`",
    execute(Sql),
    ok;

version_sql(68) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_user_dup_step` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `dup_id` int(11) NOT NULL DEFAULT '0' COMMENT '副本ID',
            `step` tinyint(2) NOT NULL DEFAULT '0' COMMENT '步骤',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家副本步骤流程统计' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    Sql2 = "CREATE TABLE IF NOT EXISTS `rcd_user_dup_juqing` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `dup_id` int(11) NOT NULL DEFAULT '0' COMMENT '副本ID',
            `step` tinyint(2) NOT NULL DEFAULT '0' COMMENT '步骤',
            `is_finish` tinyint(2) NOT NULL DEFAULT '0' COMMENT '是否完成',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家副本剧情统计' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql2),
    ok;

version_sql(69) ->
    Sql = "ALTER TABLE `rcd_slow_heartbeat` CHANGE `cmd_list` `cmd_list` text NOT NULL  COMMENT '协议列表'",
    execute(Sql),
    ok;

version_sql(70) ->
    Sql = "CREATE TABLE IF NOT EXISTS `rcd_dup_battle_count` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `pro` varchar(1024) NOT NULL COMMENT '玩家属性结构',
            `dup_type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '副本类型:1、pve，2、pvp',
            `dup_id` int(11) NOT NULL DEFAULT '0' COMMENT '副本ID',
            `battle_time` int(11) NOT NULL DEFAULT '0' COMMENT '战斗时间',
            `battle_res` tinyint(2) NOT NULL DEFAULT '0' COMMENT '战斗结果',
            `hp_percent` int(11) NOT NULL DEFAULT '0' COMMENT '剩余血量百分比',
            `att_num` int(11) NOT NULL DEFAULT '0' COMMENT '攻击次数',
            `blow_num` int(11) NOT NULL DEFAULT '0' COMMENT '受击次数',
            `act_type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '操作类型：1、自动，2、手动，3、混合',
            `call_num` int(11) NOT NULL DEFAULT '0' COMMENT '怪物召唤怪物次数',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家副本战斗统计' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql),
    ok;

version_sql(71) ->
    Sql = "ALTER TABLE `rcd_change_map` Add COLUMN `x` int(11) NOT NULL DEFAULT '0' COMMENT 'X坐标' after only_id",
    execute(Sql),
    Sql2 = "ALTER TABLE `rcd_change_map` Add COLUMN `y` int(11) NOT NULL DEFAULT '0' COMMENT 'Y会标' after x",
    execute(Sql2),
    ok;

version_sql(72) ->
    Sql = "CREATE TABLE IF NOT EXISTS `rcd_training_task` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `lv` int(11) NOT NULL DEFAULT '0' COMMENT '玩家等级',
            `type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '修行任务类型',
            `state` tinyint(2) NOT NULL DEFAULT '0' COMMENT '任务状态：0接受、1完成',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家修行任务统计' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql),
    ok;

version_sql(73) ->
    Sql = "CREATE TABLE IF NOT EXISTS `rcd_operate_depot` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(11) NOT NULL COMMENT '玩家id',
            `op_type` tinyint(2) NOT NULL COMMENT '操作类型（1、物品添加，2、物品更新，3、物品删除）',
            `source` int(11) NOT NULL COMMENT '来源',
            `cell` int(11) NOT NULL COMMENT '物品仓库位置',
            `item_id` int(11) NOT NULL COMMENT '物品id',
            `num` int(11) NOT NULL COMMENT '物品数量',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`, `pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家活动仓库日志' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql),
    ok;

version_sql(74) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_user_newhand_detail` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `task_id` int(11) NOT NULL DEFAULT '0' COMMENT '任务ID',
            `step` tinyint(2) NOT NULL DEFAULT '0' COMMENT '步骤',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家新手细节统计' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    ok;

version_sql(75) ->
    Sql = "ALTER TABLE `rcd_user_newhand_detail` CHANGE `step` `step` varchar(256) NOT NULL DEFAULT '' COMMENT '步骤详情'",
    execute(Sql),
    ok;

version_sql(76) ->
    Sql1 = "CREATE TABLE IF NOT EXISTS `rcd_user_fabao` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `fabao_id` int(11) NOT NULL DEFAULT '0' COMMENT '法宝ID',
            `qua` tinyint(2) NOT NULL DEFAULT '0' COMMENT '法宝品质',
            `lv` int(11) NOT NULL DEFAULT '0' COMMENT '强化等级',
            `slot` tinyint(2) NOT NULL DEFAULT '0' COMMENT '星级',
            `op` tinyint(2) NOT NULL DEFAULT '0' COMMENT '操作（1新增2装备3卸载4强化5分解6鉴定）',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家法宝统计' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql1),
    Sql2 = "CREATE TABLE IF NOT EXISTS `rcd_user_fabao_skill` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家pid',
            `fabao_skill_id` int(11) NOT NULL DEFAULT '0' COMMENT '法宝技能ID',
            `fabao_id` int(11) NOT NULL DEFAULT '0' COMMENT '法宝ID(0表示不装备在法宝上)',
            `lv` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
            `exp` int(11) NOT NULL DEFAULT '0' COMMENT '经验',
            `op` tinyint(2) NOT NULL DEFAULT '0' COMMENT '操作（1新增2装备3卸载4强化5消耗）',
            `op_time` int(11) DEFAULT NULL COMMENT '时间',
            PRIMARY KEY (`id`,`pid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家法宝技能统计' PARTITION BY HASH (pid) PARTITIONS 10",
    execute(Sql2),
    ok;

version_sql(77) ->
    Sql = "ALTER TABLE `rcd_recv_mail` ADD COLUMN `bond_yuanbao` int(11) NOT NULL DEFAULT '0' COMMENT '绑定元宝' AFTER `yuanbao`",
    execute(Sql),
    ok;

version_sql(N) ->
    ?WARNING("log_version sql has no log_version:~w", [N]),
    ok.

execute(Sql) ->
    db_util:execute(Sql, ?VERSION_SQL_TIMEOUT).
