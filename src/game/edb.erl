%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.06.15
%%% @desc   : 数据连接管理
%%%----------------------------------------------------------------------

-module(edb).

-include("common.hrl").
-include("../../deps/emysql/include/emysql.hrl").

-export([init/1
        ,check_db/0
        ,stop/0
        ]).

-compile(export_all).

-define(MYSQL_CONNECT_COUNT,4).
-define(BASE_MYSQL_POOL, base_mysql_pool).

init(SupPid) ->
    crypto:start(), %% 开启crypto模块
    emysql_sup:start(SupPid),   %% 开启emysql主监控进程
	start_mysql(),
    %% 开启多个进程池
    start_mysql_pool(),
	ok.

start_mysql()->
	Host = ?CONFIG(db_host),
	User = ?CONFIG(db_user),
	Password = ?CONFIG(db_pwd),
	Encode = ?CONFIG(db_encode),
	DbName = undefined,   %% 连接默认数据库
	Port = ?CONFIG(db_port),
    ?WARNING("Host:~w, User:~w, Password:~w, Encode:~w, DbName:~w, Port:~w", [Host, User, Password, Encode, DbName, Port]),
    emysql:add_pool(?BASE_MYSQL_POOL, 1, User, Password, Host, Port, DbName, Encode), %% 先开启一个基础数据库
    %% 检测数据库（创建、切换等操作）
    check_db(),
    ok.

%% 根据需求，开启各个数据库链接池
start_mysql_pool()->
	Host = ?CONFIG(db_host),
	User = ?CONFIG(db_user),
	Password = ?CONFIG(db_pwd),
	Encode = ?CONFIG(db_encode),
    DbName = ?CONFIG(db_name),
	Port = ?CONFIG(db_port),
    emysql:add_pool(?MYSQL_POOL, 1, User, Password, Host, Port, DbName, Encode), %% 主数据库
    %emysql:add_pool(pool2, 1, User, Password, Host, Port, DbName, Encode), %% 
    %emysql:add_pool(pool3, 1, User, Password, Host, Port, DbName, Encode), %% 
	
    ok.

stop() ->
    %% 关掉进程池
	ok = lists:foreach(
		fun (Pool) -> emysql:remove_pool(Pool#pool.pool_id) end,
		emysql_conn_mgr:pools()),
    supervisor:terminate_child(server_sup, emysql_sup),
    supervisor:delete_child(server_sup, emysql_sup),
    ok.

%% 检查数据库
check_db() ->
    timer:sleep(1000),
    %% 获取该实例中的所有数据库
    DatabaseList = edb_util:execute(?BASE_MYSQL_POOL, "SHOW DATABASES"),
    DbName = ?CONFIG(db_name),
    Database = [util:to_binary(DbName)],
    case lists:member(Database, DatabaseList) of
        true -> %% 有数据库
			?WARNING("have database db_name:~p", [DbName]),
            skip;
        _ ->    %% 没有数据库，创建
            Res1 = edb_util:execute(?BASE_MYSQL_POOL, lists:concat(["CREATE DATABASE `", DbName, "` DEFAULT charset utf8"])),
			?WARNING("create database ~p res:~w",[DbName, Res1]),
            ok
    end,
    timer:sleep(1000),
    %% 切换数据库
    Res2 = edb_util:execute(?BASE_MYSQL_POOL, lists:concat(["USE `", DbName, "`"])),
    ?WARNING("change database res:~w",[Res2]),
    %% TODO 数据库语句执行
    %% global_data表建立
    %Res3 = edb_util:execute(?BASE_MYSQL_POOL, <<"CREATE TABLE `global_data` (
    %                                            `global_key` varchar(50) NOT NULL,
    %                                            `global_value` text NOT NULL,
    %                                            PRIMARY KEY (`global_key`)
    %                                            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='全局信息';">>),
    %?WARNING("create global data res:~w",[Res3]),
    %db_version:check_version(),

    ok.

