%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.06.15
%%% @desc   : 数据连接管理
%%%----------------------------------------------------------------------

-module(edb).

-include("common.hrl").
-include("../../deps/emysql/include/emysql.hrl").

-export([init/0
        ,init_databases/0
        ,stop/0
        ]).

-compile(export_all).


init() ->
    ok = init_mysql(),
    ok = init_mysql_pool(),                             %% 开启多个进程池
    ok = global_data_disk:init(),                       %% 数据库启动后开启
    ok = db_version:update_version(),                   %% 数据库版本更新
    ?INFO("mysql_service finish!~n"),
    ok.

init_mysql()->
    Host = ?CONFIG(db_host),
    User = ?CONFIG(db_user),
    Password = ?CONFIG(db_pwd),
    Encode = ?CONFIG(db_encode),
    DbName = undefined,   %% 连接默认数据库
    Port = ?CONFIG(db_port),
    ?INFO("Host:~w, User:~w, Password:~w, Encode:~w, DbName:~w, Port:~w",
        [Host, User, Password, Encode, DbName, Port]),
    emysql:add_pool(?BASE_MYSQL_POOL, 1, User, Password, Host, Port, DbName, Encode), %% 先开启一个基础数据库
    %% 检测数据库（创建、切换等操作）
    init_databases(),
    ok.

%% 根据需求，开启各个数据库链接池
init_mysql_pool()->
    Host = ?CONFIG(db_host),
    User = ?CONFIG(db_user),
    Password = ?CONFIG(db_pwd),
    Encode = ?CONFIG(db_encode),
    DbName = ?CONFIG(db_name),
    Port = ?CONFIG(db_port),
    emysql:add_pool(?MYSQL_POOL, 10, User, Password, Host, Port, DbName, Encode),   %% 默认数据库连接
    emysql:add_pool(?LOG_MYSQL_POOL, 10, User, Password, Host, Port, DbName, Encode), %% 日志数据库连接

    ok.

stop() ->
    %% 关掉进程池
    ok = lists:foreach(
        fun (Pool) -> emysql:remove_pool(Pool#pool.pool_id) end,
        emysql_conn_mgr:pools()),
    ok.

%% 检查是否需要新建数据库
init_databases() ->
    timer:sleep(1000),
    %% 获取该实例中的所有数据库
    DatabaseList = edb_util:execute(?BASE_MYSQL_POOL, "SHOW DATABASES"),
    DbName = ?CONFIG(db_name),
    Database = [util:to_binary(DbName)],
    case lists:member(Database, DatabaseList) of
        true -> %% 有数据库
            ?INFO("have database db_name:~p", [DbName]),
            skip;
        _ ->    %% 没有数据库，创建
            Res1 = edb_util:execute(?BASE_MYSQL_POOL,
                lists:concat(["CREATE DATABASE `", DbName, "` DEFAULT charset utf8"])),
            ?INFO("create database ~p res:~w",[DbName, Res1]),
            ok
    end,
    timer:sleep(1000),
    %% 切换数据库
    Res2 = edb_util:execute(?BASE_MYSQL_POOL, lists:concat(["USE `", DbName, "`"])),
    ?INFO("change database res:~w",[Res2]),
    %% TODO 数据库语句执行
    TableList = edb_util:execute(?BASE_MYSQL_POOL, "SHOW TABLES"),
    ?INFO("TableList:~p",[TableList]),
    case lists:member([util:to_binary(global_data)], TableList) of
        true -> %% 有global_data表
            skip;
        _ ->    %% 没有global_data表，创建
            %% global_data表建立
            db_version:version_sql()
    end,
    ok.

