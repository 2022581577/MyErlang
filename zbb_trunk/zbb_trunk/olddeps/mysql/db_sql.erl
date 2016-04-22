%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.07.29.
%%% @desc   : 日志同步日志入库模块
%%%----------------------------------------------------------------------
-module(db_sql).

-include("common.hrl").

-export([version/0]).

version() ->
    SqlList = 
    ["CREATE TABLE IF NOT EXISTS `game_guild` (
      `pid` int(11) NOT NULL DEFAULT '0' COMMENT '帮派ID',
      `type` tinyint(2) DEFAULT '0' COMMENT '类型: 1-创建 2-删除 3-更新',
      `guild_name` varchar(255) NOT NULL COMMENT '帮派名',
      `leader_id` bigint(20) unsigned NOT NULL COMMENT '帮主ID',
      `leader_name` varchar(255) NOT NULL COMMENT '帮主名',
      `lv` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
      `create_time` int(11) unsigned NOT NULL COMMENT '创建时间',
      `cur_num` int(11) unsigned NOT NULL COMMENT '当前人数',
      `max_num` int(11) unsigned NOT NULL COMMENT '最大人数',
      `resources` bigint(20) NOT NULL COMMENT '帮派资源',
      `assistant_num` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '副帮主数量',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `player` (
      `pid` bigint(11) unsigned NOT NULL COMMENT '玩家id',
      `accname` varchar(255) NOT NULL COMMENT '账号',
      `name` varchar(255) NOT NULL COMMENT '名字',
      `lvl` smallint(4) unsigned NOT NULL COMMENT '等级',
      `career` tinyint(2) unsigned NOT NULL COMMENT '职业',
      `gender` tinyint(2) DEFAULT '0' COMMENT '性别',
      `user_type` tinyint(2) NOT NULL COMMENT '玩家类型',
      `vip_lv` tinyint(2) NOT NULL COMMENT 'vip等级',
      `yuanbao` int(11) NOT NULL COMMENT '元宝',
      `coin` int(11) NOT NULL COMMENT '铜钱',
      `map_id` int(11) NOT NULL COMMENT '所在地图',
      `x` int(11) NOT NULL COMMENT 'x坐标',
      `y` int(11) NOT NULL COMMENT 'y坐标',
      `reg_time` int(11) NOT NULL COMMENT '创建时间',
      `ip` varchar(126) NOT NULL COMMENT '创建ip',
      `guild_id` int(11) NOT NULL COMMENT '公会id',
      `guild_user_type` tinyint(4) NOT NULL COMMENT '公会职位',
      `on_line` tinyint(4) NOT NULL COMMENT '是否在线',
      `login_time` int(11) DEFAULT '0' COMMENT '上线时间',
      `logout_time` int(11) DEFAULT '0' COMMENT '下线时间',
      `login_ip` varchar(126) DEFAULT NULL COMMENT '登录ip',
      `option1` int(11) DEFAULT '0' COMMENT '扩展用',
      `option2` int(11) DEFAULT '0' COMMENT '扩展用',
      `option3` int(11) DEFAULT '0' COMMENT '扩展用',
      `option4` int(11) DEFAULT '0' COMMENT '扩展用',
      `option5` int(11) DEFAULT '0' COMMENT '扩展用',
      `option6` int(11) DEFAULT '0' COMMENT '扩展用',
      `option7` varchar(1024) DEFAULT NULL COMMENT '扩展用',
      `option8` varchar(1024) DEFAULT NULL COMMENT '扩展用',
      `option9` varchar(5120) DEFAULT NULL COMMENT '扩展用',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_achieve_score` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `achieve_id` int(11) NOT NULL DEFAULT '0' COMMENT '成就id',
      `score` int(11) NOT NULL DEFAULT '0' COMMENT '获得成就点',
      `op_time` int(11) DEFAULT '0',
      PRIMARY KEY (`id`,`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家成就点获取' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_achieve_state` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `achieve_id` int(11) NOT NULL DEFAULT '0' COMMENT '成就id',
      `state` int(11) NOT NULL DEFAULT '0' COMMENT '成就状态',
      `op_time` int(11) DEFAULT '0',
      PRIMARY KEY (`id`,`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家成就状态' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_activate_wujiang` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `wujiang_id` int(11) NOT NULL DEFAULT '0' COMMENT '武将类型id',
      `source` int(11) DEFAULT NULL COMMENT '来源',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='激活武将操作' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_arena` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `object_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '挑战对象玩家id',
      `result` tinyint(2) NOT NULL COMMENT '挑战结果',
      `mynewrank` int(11) NOT NULL COMMENT '我的新排名',
      `himnewrank` int(11) NOT NULL COMMENT '挑战对象的新排名',
      `op_time` int(11) DEFAULT '0',
      PRIMARY KEY (`id`,`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='竞技场' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_blockade_user` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `login_ip` varchar(126) DEFAULT NULL COMMENT '登录ip',
      `blockade_time` int(11) NOT NULL DEFAULT '0' COMMENT '封号限制时间',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='后台封号' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_bsxl` (
      `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `user_name` varchar(255) NOT NULL COMMENT '玩家名',
      `type` tinyint(2) DEFAULT '0' COMMENT '类型1-占领 2-挑战成功 3-挑战失败',
      `target_id` int(11) NOT NULL DEFAULT '0' COMMENT '被挑战者ID',
      `target_name` varchar(255) NOT NULL COMMENT '被挑战者名',
      `points` int(11) NOT NULL COMMENT '层数',
      `pos` tinyint(2) DEFAULT '0' COMMENT '位置',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_copy` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `copy_id` int(11) DEFAULT '0' COMMENT '副本ID',
      `copy_type` int(11) DEFAULT '0' COMMENT '副本类型(1-pve 2-pvp)',
      `enter_time` int(11) NOT NULL COMMENT '进入时间',
      `leave_time` int(11) NOT NULL COMMENT '离开时间',
      `quality` int(11) NOT NULL COMMENT '通关质量',
      `reward` varchar(1024) NOT NULL COMMENT '副本奖励',
      `last_num` int(11) NOT NULL COMMENT '剩余次数',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='副本出入日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_equip_jewel` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `eid` bigint(11) NOT NULL DEFAULT '0' COMMENT '装备唯一id',
      `equip_id` int(11) NOT NULL DEFAULT '0' COMMENT '装备id',
      `old_jewel_list` varchar(512) NOT NULL COMMENT '镶嵌前的宝石列表',
      `new_jewel_list` varchar(512) NOT NULL COMMENT '镶嵌后的宝石列表',
      `jewel_id` int(11) NOT NULL DEFAULT '0' COMMENT '镶嵌的宝石id',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='装备镶嵌宝石' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_equip_stren` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `eid` bigint(11) NOT NULL DEFAULT '0' COMMENT '装备唯一id',
      `equip_id` int(11) NOT NULL DEFAULT '0' COMMENT '装备id',
      `old_stren` tinyint(4) NOT NULL DEFAULT '0' COMMENT '旧的强化等级',
      `new_stren` tinyint(4) NOT NULL DEFAULT '0' COMMENT '新的强化等级',
      `old_proficiency` tinyint(4) NOT NULL DEFAULT '0' COMMENT '旧的强化熟练度',
      `new_proficiency` tinyint(4) NOT NULL DEFAULT '0' COMMENT '新的强化熟练度',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='装备强化' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_equip_up` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `eid` bigint(11) NOT NULL DEFAULT '0' COMMENT '装备唯一id',
      `old_equip_id` int(11) NOT NULL DEFAULT '0' COMMENT '旧的装备id',
      `new_equip_id` int(11) NOT NULL DEFAULT '0' COMMENT '新的装备id',
      `op_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '提升类型：1、打造升级, 2、精练提升品质',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='装备提升' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_err_item` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL COMMENT '玩家id',
      `item_only_id` bigint(11) NOT NULL COMMENT '物品唯一id',
      `item_id` int(11) NOT NULL COMMENT '物品id',
      `item` varchar(1024) NOT NULL COMMENT '物品结构',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家错误物品日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_guild` (
      `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `type` int(11) NOT NULL COMMENT '类型',
      `guild_id` int(11) NOT NULL DEFAULT '0' COMMENT '帮派ID',
      `guild_name` varchar(255) NOT NULL COMMENT '帮派名',
      `leader_id` bigint(20) unsigned NOT NULL COMMENT '帮主ID',
      `leader_name` varchar(255) NOT NULL COMMENT '帮主名',
      `lv` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
      `member_list` text NOT NULL COMMENT '成员列表',
      `create_time` int(11) unsigned NOT NULL COMMENT '创建时间',
      `cur_num` int(11) unsigned NOT NULL COMMENT '当前人数',
      `max_num` int(11) unsigned NOT NULL COMMENT '最大人数',
      `resources` bigint(20) NOT NULL COMMENT '帮派资源',
      `assistant_num` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '副帮主数量',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_guild_battle` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `round` int(11) NOT NULL DEFAULT '0' COMMENT '当前在第几轮',
      `total_round` int(11) NOT NULL DEFAULT '0' COMMENT '总共轮数',
      `guild_id_list` varchar(256) DEFAULT NULL COMMENT '参与的帮派ID列表',
      `guild_team` varchar(512) DEFAULT NULL COMMENT '分组情况',
      `round_list` varchar(512) DEFAULT NULL COMMENT '帮派战记',
      `map_id_list` varchar(256) DEFAULT NULL COMMENT '地图唯一ID列表',
      `state` int(11) NOT NULL DEFAULT '0' COMMENT '活动状态',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派争霸赛' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_guild_waged` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `act_id` int(11) NOT NULL DEFAULT '0' COMMENT '第几届活动',
      `state` int(11) NOT NULL DEFAULT '0' COMMENT '活动状态',
      `win` int(11) NOT NULL DEFAULT '0' COMMENT '哪方胜利',
      `defend_guild` int(11) NOT NULL DEFAULT '0' COMMENT '防守方帮派ID',
      `attack_guilds` varchar(256) DEFAULT NULL COMMENT '攻击方帮派ID列表',
      `defend_buff` int(11) NOT NULL DEFAULT '0' COMMENT '防守方buff',
      `attack_buff` int(11) NOT NULL DEFAULT '0' COMMENT '进攻方buff',
      `map_only_ids` varchar(256) DEFAULT NULL COMMENT '地图唯一ID列表',
      `kill_info` varchar(1024) DEFAULT NULL COMMENT '战况信息',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派硝烟四起' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_item` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL COMMENT '玩家id',
      `op_type` tinyint(2) NOT NULL COMMENT '操作类型（1、物品添加，2、物品更新，3、物品删除）',
      `source` int(11) NOT NULL COMMENT '来源',
      `item_only_id` bigint(11) NOT NULL COMMENT '物品唯一id',
      `item_id` int(11) NOT NULL COMMENT '物品id',
      `item` varchar(1024) NOT NULL COMMENT '物品结构',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家物品日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_item_stream` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `source` int(11) DEFAULT NULL COMMENT '来源',
      `op_type` tinyint(2) DEFAULT '0' COMMENT '1、获得，2、消耗',
      `item_id` int(11) DEFAULT '0' COMMENT '道具ID',
      `op_count` int(11) DEFAULT '0' COMMENT '操作数量',
      `currency` tinyint(2) DEFAULT '0' COMMENT '货币类型',
      `num` int(11) DEFAULT '0' COMMENT '货币数量',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='道具获得消耗流水日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_login_logout` (
      `id` int(11) NOT NULL,
      `pid` bigint(11) NOT NULL DEFAULT '0',
      `lv` int(11) NOT NULL COMMENT '玩家等级',
      `login_ip` varchar(126) DEFAULT NULL COMMENT '登录ip',
      `login_time` int(11) DEFAULT '0' COMMENT '登入的时间',
      `logout_time` int(11) DEFAULT '0' COMMENT '登出的时间',
      `online_time` int(11) DEFAULT '0' COMMENT '在线时间',
      `op_time` int(11) DEFAULT '0' COMMENT '插入时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家上下线日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_login_step` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `accname` varchar(255) NOT NULL COMMENT '账号',
      `step` int(11) DEFAULT NULL COMMENT '登录步骤',
      `op_time` int(11) DEFAULT NULL COMMENT '操作时间',
      PRIMARY KEY (`id`),
      KEY `op_time` (`op_time`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='登录步骤，用于统计流失率' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_logout_type` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `reason` int(11) DEFAULT NULL COMMENT '退出原因',
      `op_time` int(11) DEFAULT NULL COMMENT '操作时间',
      PRIMARY KEY (`id`,`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家下线类型日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_lvl` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `lvl` tinyint(3) DEFAULT NULL COMMENT '等级',
      `source` int(11) DEFAULT NULL COMMENT '来源',
      `op_time` int(11) DEFAULT NULL COMMENT '操作时间',
      PRIMARY KEY (`id`,`pid`),
      KEY `pid` (`pid`,`source`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家升级日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_money` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `lvl` int(11) DEFAULT '0' COMMENT '等级',
      `in_side` tinyint(2) NOT NULL COMMENT '是否内部玩家',
      `source` int(11) DEFAULT NULL COMMENT '来源',
      `money_type` int(2) NOT NULL DEFAULT '0' COMMENT '钱的类型：1、元宝 2、铜钱',
      `op_type` int(2) DEFAULT NULL COMMENT '操作类型：1、添加 2、减少',
      `op_count` int(11) DEFAULT NULL COMMENT '操作的数目',
      `curr_count` int(11) DEFAULT NULL COMMENT '当前数目',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`,`pid`,`money_type`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家金钱日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_online` (
      `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID标识',
      `op_count` int(5) DEFAULT '0' COMMENT '当前在线',
      `op_time` int(11) NOT NULL COMMENT '操作时间',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='在线人数日志' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_operate_mail` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `mail_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '邮件ID',
      `source` int(11) NOT NULL COMMENT '来源',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家邮件操作' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_party_player_in_out` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `party_id` int(11) DEFAULT '0' COMMENT '帮派ID',
      `is_join` int(11) DEFAULT '0' COMMENT '是否加入帮派',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派成员加入退出日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_rank` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `type` int(11) NOT NULL COMMENT '排行类型',
      `data` text NOT NULL COMMENT '数据',
      `op_time` int(11) DEFAULT '0',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='排行榜' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_recv_mail` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `mail_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '邮件ID',
      `type` tinyint(2) DEFAULT '0' COMMENT '邮件类型',
      `send_time` int(11) NOT NULL COMMENT '发送时间',
      `send_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '发送玩家id',
      `recv_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '接收玩家id',
      `title` char(255) NOT NULL COMMENT '标题',
      `content` varchar(1024) NOT NULL COMMENT '内容',
      `item` varchar(1024) NOT NULL COMMENT '道具附件',
      `yuanbao` int(11) DEFAULT NULL COMMENT '元宝',
      `coin` int(11) DEFAULT NULL COMMENT '金币',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家接收邮件' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_send_mail` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `mail_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '邮件ID',
      `type` tinyint(2) DEFAULT '0' COMMENT '邮件类型',
      `send_time` int(11) NOT NULL COMMENT '发送时间',
      `send_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '发送玩家id',
      `recv_id` bigint(11) NOT NULL DEFAULT '0' COMMENT '接收玩家id',
      `title` char(255) NOT NULL COMMENT '标题',
      `content` varchar(1024) NOT NULL COMMENT '内容',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家发送邮件' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_server_state` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `server_state` tinyint(2) NOT NULL DEFAULT '0' COMMENT '开服状态',
      `total_memory` int(11) DEFAULT NULL COMMENT '内存消耗（M）',
      `ets_num` int(11) DEFAULT NULL COMMENT 'ets数量',
      `process_num` int(11) DEFAULT NULL COMMENT '进程数量',
      `onlines` int(11) DEFAULT NULL COMMENT '在线人数',
      `log_server_conn` tinyint(2) DEFAULT NULL COMMENT '日志服务器连接状态',
      `db_conn` tinyint(2) DEFAULT NULL COMMENT 'mongodb链接状态',
      `logs_num` int(11) DEFAULT '0' COMMENT 'log_dets中日志的组数',
      `dets_mask_num` int(11) DEFAULT '0' COMMENT 'ets_db_mask的数量',
      `code_change_vsn` int(11) DEFAULT '0' COMMENT '热更版本号',
      `code_change_res` tinyint(2) DEFAULT '0' COMMENT '热更结果',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家金钱日志' PARTITION BY HASH (id) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_shenbing_lv_up` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `wujiang_id` int(11) NOT NULL DEFAULT '0' COMMENT '武将类型id',
      `old_wujiang_lv` tinyint(4) NOT NULL DEFAULT '0' COMMENT '旧的武将等级',
      `new_wujiang_lv` tinyint(4) NOT NULL DEFAULT '0' COMMENT '新的武将等级',
      `shenbing_id` int(11) NOT NULL DEFAULT '0' COMMENT '神兵类型id',
      `old_shenbing_lv` tinyint(4) NOT NULL DEFAULT '0' COMMENT '旧的神兵等级',
      `new_shenbing_lv` tinyint(4) NOT NULL DEFAULT '0' COMMENT '新的神兵等级',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神兵升级' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_soul` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `old_soul_id` int(11) NOT NULL DEFAULT '0' COMMENT '旧魂魄id',
      `new_soul_id` int(11) NOT NULL DEFAULT '0' COMMENT '新魂魄id',
      `blood_stone` int(11) NOT NULL DEFAULT '0' COMMENT '消耗血魂',
      `spirit_stone` int(11) NOT NULL DEFAULT '0' COMMENT '消耗精魂',
      `op_time` int(11) DEFAULT '0',
      PRIMARY KEY (`id`,`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家魂魄' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_stone` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `lvl` int(11) DEFAULT '0' COMMENT '等级',
      `source` int(11) DEFAULT NULL COMMENT '来源',
      `stone_type` int(2) NOT NULL DEFAULT '0' COMMENT '类型：1、血魂 2、精魄',
      `op_type` int(2) DEFAULT NULL COMMENT '操作类型：1、添加 2、减少',
      `op_count` int(11) DEFAULT NULL COMMENT '操作的数目',
      `curr_count` int(11) DEFAULT NULL COMMENT '当前数目',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`,`pid`,`stone_type`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家血魂精魄日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_task` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `task_id` int(11) DEFAULT NULL COMMENT '项目',
      `state` int(2) DEFAULT NULL COMMENT '操作类型：1、接受 2、未达成放弃 3、达成 4、达成放弃 5、完成、6付费达成',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`,`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_user_fashion` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `fashion_id` int(11) DEFAULT '0' COMMENT '时装id',
      `source` int(11) NOT NULL COMMENT '来源',
      `fashion` varchar(1024) NOT NULL COMMENT '时装结构',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家时装' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_user_lianling` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `ll_id` int(11) NOT NULL DEFAULT '0' COMMENT '灵兵唯一id',
      `lianling_id` int(11) NOT NULL DEFAULT '0' COMMENT '灵兵类型id',
      `lianling` varchar(1024) NOT NULL COMMENT '灵兵结构',
      `source` int(11) NOT NULL DEFAULT '0' COMMENT '来源',
      `op_type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '操作类型（1、添加，2、更新，3、删除）',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家炼灵日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_user_log` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `type` int(11) NOT NULL DEFAULT '0' COMMENT '系统类型',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家参与系统' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_user_power` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `old_power` int(11) DEFAULT '0' COMMENT '玩家旧的战力',
      `new_power` int(11) DEFAULT '0' COMMENT '玩家新的战力',
      `source` int(11) NOT NULL COMMENT '来源',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家战力变化' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_user_pvp_equip` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `pvp_equip_id` int(11) DEFAULT '0' COMMENT 'pvp装备id',
      `lv` tinyint(2) DEFAULT '0' COMMENT '等级',
      `source` int(11) NOT NULL COMMENT '来源',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家pvp装备' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_user_rune` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `rid` bigint(11) NOT NULL DEFAULT '0' COMMENT '符文唯一id',
      `rune_id` int(11) NOT NULL DEFAULT '0' COMMENT '符文id',
      `lv` tinyint(4) NOT NULL DEFAULT '0' COMMENT '符文等级',
      `exp` int(11) NOT NULL DEFAULT '0' COMMENT '符文当前经验值',
      `op_type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '操作类型（1、添加，2、更新，3、删除）',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='符文操作' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_user_skill` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `skill_h` int(11) NOT NULL DEFAULT '0' COMMENT 'H键',
      `skill_u` int(11) NOT NULL DEFAULT '0' COMMENT 'U键',
      `skill_i` int(11) NOT NULL DEFAULT '0' COMMENT 'I键',
      `skill_o` int(11) NOT NULL DEFAULT '0' COMMENT 'O键',
      `skill_l` int(11) NOT NULL DEFAULT '0' COMMENT 'L键',
      `skill_list` text NOT NULL COMMENT '技能列表',
      `type` tinyint(2) DEFAULT '0' COMMENT '类型',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家技能' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_vip` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `source` int(11) DEFAULT NULL COMMENT '来源',
      `add_exp` int(11) DEFAULT '0' COMMENT '增加的VIP经验',
      `old_vip` int(11) DEFAULT NULL COMMENT '旧VIP等级',
      `old_vip_exp` int(11) DEFAULT NULL COMMENT '旧VIP经验',
      `curr_vip` int(11) DEFAULT NULL COMMENT '当前VIP等级',
      `curr_vip_exp` int(11) DEFAULT NULL COMMENT '当前VIP经验',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`,`pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家VIP日志' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_world_chat` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `lvl` tinyint(3) DEFAULT NULL COMMENT '玩家等级',
      `content` varchar(1024) NOT NULL COMMENT '聊天内容',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='世界聊天' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_wujiang_juxing` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `wujiang_id` int(11) NOT NULL DEFAULT '0' COMMENT '武将类型id',
      `juxing_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '聚星类型',
      `event` tinyint(4) NOT NULL DEFAULT '0' COMMENT '事件类型',
      `event_finish` tinyint(4) NOT NULL DEFAULT '0' COMMENT '事件是否完成',
      `get_energy` tinyint(4) NOT NULL DEFAULT '0' COMMENT '获得灵能值',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='聚星操作' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_wuzhen_lv_up` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(11) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `wuzhen_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '武阵类型：1、天，2、地，3、人',
      `old_lv` tinyint(4) NOT NULL DEFAULT '0' COMMENT '旧的等级',
      `new_lv` tinyint(4) NOT NULL DEFAULT '0' COMMENT '新的等级',
      `old_yueli` int(11) NOT NULL DEFAULT '0' COMMENT '旧的阅历',
      `new_yueli` int(11) NOT NULL DEFAULT '0' COMMENT '新的阅历',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='武阵升级' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_xilian_stone` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家ID',
      `old_num` int(11) NOT NULL DEFAULT '0' COMMENT '旧的洗炼石数量',
      `new_num` int(11) NOT NULL DEFAULT '0' COMMENT '新的洗炼石数量',
      `source` int(11) NOT NULL DEFAULT '0' COMMENT '来源',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='洗炼石获得、消耗' PARTITION BY HASH (pid) PARTITIONS 10",
    "CREATE TABLE IF NOT EXISTS `rcd_yanwuchang` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `pid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
      `res` tinyint(2) DEFAULT '0' COMMENT '战斗结果：1、胜利，2、失败',
      `opp_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '对手id',
      `op_time` int(11) DEFAULT NULL COMMENT '时间',
      PRIMARY KEY (`id`, `pid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='演武场日志' PARTITION BY HASH (pid) PARTITIONS 10"],
    ?INFO("Len:~w", [length(SqlList)]),
    [db_version:execute(E) || E <- SqlList],
    ok.

