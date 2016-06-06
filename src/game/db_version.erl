%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   :
%%%------------------------------------------------------------------------

-module(db_version).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([update_version/0]).
-export([execute/1]).
-export([version_sql/0]).
-export([version_sql/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
update_version() ->
    DbVersion = global_data_disk:get(sql_version, 0),
    case DbVersion >= ?SQL_VERSION of
        ?TRUE ->
            ?INFO("check_version, same version!");
        _ ->
            VersionList = lists:seq(DbVersion + 1, ?SQL_VERSION),
            ?INFO("check_version, VersionList:~w", [VersionList]),
            [version_sql(E) || E <- VersionList],
            global_data_disk:set(sql_version, ?SQL_VERSION),
            global_data_disk:sync()
    end,
    ok.

version_sql() ->
    Sql = "CREATE TABLE `global_data` (
            `global_key` varchar(50) NOT NULL,
            `global_value` text NOT NULL,
            `is_dirty` tinyint(1) unsigned zerofill NOT NULL,
            PRIMARY KEY (`global_key`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='全局信息';",
    Res = execute(Sql),
    ?INFO("create global data res:~w",[Res]),
    ok.

version_sql(1) ->
    Sql1 =
        "CREATE TABLE `user` (
                      `user_id` bigint(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '玩家ID',
                      `acc_name` varchar(50) DEFAULT '' COMMENT '玩家账号',
                      `name` varchar(25) NOT NULL DEFAULT '' COMMENT '玩家名',
                      `server_id` int(11) NOT NULL DEFAULT '0' COMMENT '服务器编号',
                      `reg_server_id` int(11) NOT NULL DEFAULT '0' COMMENT '注册服务器编号',
                      `user_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '玩家类型',
                      `ip` varchar(20) DEFAULT '' COMMENT '玩家ip',
                      `reg_time` int(11) NOT NULL DEFAULT '0' COMMENT '注册时间',
                      `online_time` int(11) NOT NULL DEFAULT '0' COMMENT '当次登陆在线时间',
                      `total_online_time` int(11) DEFAULT '0' COMMENT '累计在线时间',
                      `login_time` int(11) NOT NULL DEFAULT '0' COMMENT '登陆时间',
                      `last_online_time` int(11) NOT NULL DEFAULT '0' COMMENT '最后在线时间',
                      `last_update_time` int(11) NOT NULL DEFAULT '0' COMMENT '上次存库的时间',
                      `logout_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '下线类型',
                      `coin` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '金币',
                      `map_id` int(11) NOT NULL DEFAULT '0' COMMENT '地图ID',
                      `pos_x` int(11) NOT NULL DEFAULT '0' COMMENT '坐标X',
                      `pos_y` int(11) NOT NULL DEFAULT '0' COMMENT '坐标Y',
                      `gender` tinyint(1) NOT NULL DEFAULT '0' COMMENT '性别 1-男 2-女 ',
                      `career` tinyint(1) NOT NULL DEFAULT '0' COMMENT '职业',
                      `lv` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
                      `exp` int(11) NOT NULL DEFAULT '0' COMMENT '经验',
                      `hp` int(11) DEFAULT '0' COMMENT '血量',
                      `mp` int(11) DEFAULT '0' COMMENT '蓝量',
                      `guild_id` int(11) NOT NULL DEFAULT '0' COMMENT '帮派ID',
                      `other_data` varchar(50) DEFAULT NULL,
                      PRIMARY KEY (`user_id`)
                    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;",
    execute(Sql1),
    Sql2 =
        "CREATE TABLE `user_item` (
                      `item_id` bigint(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '道具id',
                      `tpl_id` int(11) unsigned NOT NULL COMMENT '道具模板id',
                      `user_id` bigint(11) unsigned NOT NULL COMMENT '玩家ID',
                      `location` tinyint(2) NOT NULL DEFAULT '0' COMMENT '位置',
                      `is_dirty` tinyint(1) NOT NULL DEFAULT '0',
                      PRIMARY KEY (`item_id`),
                      KEY `ix_user_id` (`user_id`)
                    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;",
    execute(Sql2),
    ok;

version_sql(N) ->
    ?INFO("log_version sql has no log_version:~w", [N]),
    ok.

%% 确保顺序执行，用?BASE_MYSQL_POOL
execute(Sql) ->
    Sql1 = unicode:characters_to_binary(Sql),   %% 中文编码转换
    edb_util:execute(?BASE_MYSQL_POOL, Sql1).

%% ========================================================================
%% Local functions
%% ========================================================================

