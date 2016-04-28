%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.06.15
%%% @desc   : 数据连接管理
%%%----------------------------------------------------------------------

-module(db).

-include("common.hrl").

-export([init/1
        ,test/0
        ,check_log_db/0
        ,stop/0
        ,reconnect/0
        ,switch_db/0]).

-define(MYSQL_CONNECT_COUNT,4).

init(SupPid) ->
	start_mysql(SupPid),
    %% 检测数据库（创建、切换等操作）
    check_log_db(),
    %% 开启多个进程池
    start_mysql_pool(SupPid, ?MYSQL_CONNECT_COUNT),
	ok.

reconnect() ->
    SupPid = server_sup,
    start_mysql(SupPid),
    DbName = get_db_name(),   %% 连接正确的数据库
    db_util:execute(lists:concat(["USE `", DbName, "`"])),
    start_mysql_pool(SupPid, ?MYSQL_CONNECT_COUNT),
    ok.

switch_db() ->
    stop(),
    reconnect(),
    case db_util:check_db_state() of
        false ->
            false;
        _ ->
            true
    end.

start_mysql(SupPid)->
	Host = ?CONFIG(db_host),
	User = ?CONFIG(db_user),
	Password = ?CONFIG(db_password),
	Encode = ?CONFIG(db_encode),
	DbName = "test",   %% 连接默认数据库
	Port = ?CONFIG(db_port),
	Child = {mysql
             ,{mysql, start_link, [?MYSQL_POOL,Host,Port,User,Password,DbName,fun(_,_,_,_)-> ok end,Encode]}
             ,transient
             ,100
             ,worker
             ,[mysql]},
    case supervisor:start_child(SupPid,Child) of
    	{ok, MysqlPid} ->
            ?GLOBAL_DATA_RAM:set(db_config,{?CONFIG(db_host),?CONFIG(db_port)}),
            ?GLOBAL_DATA_RAM:set(db_name,?CONFIG(db_name)),
        	MysqlPid;
    	Other ->
    		?WARNING2("Start Mysql Fail:~w",[Other]),
            false
    end.

start_mysql_pool(SupPid,ConnectCount)->
	Host = ?CONFIG(db_host),
	User = ?CONFIG(db_user),
	Password = ?CONFIG(db_password),
	Encode = ?CONFIG(db_encode),
    DbName = get_db_name(),   %% 连接正确的数据库
	Port = ?CONFIG(db_port),
	
	%% mysql:connect(PoolId, Host, Port, User, Password, Database, Encoding, Reconnect) ->
	ConnPidList = [begin
                    ConnectChild = {util:to_atom("mysql_" ++ util:to_list(N)), {mysql, connect,
							[?MYSQL_POOL,Host,Port,User,Password,DbName,Encode,true]},
							transient, 100, worker, [mysql]},
					case supervisor:start_child(SupPid,ConnectChild) of
					{ok,ConnectPid} ->
						ConnectPid;
					Other2 ->
						?WARNING2("Connect Mysql Fail:~w",[Other2])
					end
                  end || N <- lists:seq(1,ConnectCount)],
    ?WARNING("ConnPidL:~w", [ConnPidList]),
    ok.

stop() ->
    catch mysql:stop(),
    supervisor:terminate_child(server_sup,mysql),
    supervisor:delete_child(server_sup,mysql),
    lists:foreach(fun(N) ->
                    ConnectChild = util:to_atom("mysql_" ++ util:to_list(N)),
                    supervisor:terminate_child(server_sup,ConnectChild),
                    supervisor:delete_child(server_sup,ConnectChild)
            end,lists:seq(1,?MYSQL_CONNECT_COUNT)),
    ok.

%% 检查数据库
check_log_db() ->
    timer:sleep(1000),
    %% 获取该实例中的所有数据库
    DatabaseList = db_util:execute("SHOW DATABASES"),
    DbName = get_db_name(),
    Database = [util:to_binary(DbName)],
    case lists:member(Database, DatabaseList) of
        true -> %% 有数据库
			?WARNING("have database db_name:~p", [DbName]),
            skip;
        _ ->    %% 没有数据库，创建
            Res1 = db_util:execute(lists:concat(["CREATE DATABASE `", DbName, "` DEFAULT charset utf8"])),
			?WARNING("create database ~p res:~w",[DbName, Res1]),
            ok
    end,
    timer:sleep(1000),
    %% 切换数据库
    Res2 = db_util:execute(lists:concat(["USE `", DbName, "`"])),
    ?WARNING("change database res:~w",[Res2]),
    %% 修改connpid的database
    timer:sleep(1000),
    %% 检测是否有global_data表
    TableList = db_util:execute("SHOW TABLES"),
    ?WARNING("TableList:~p",[TableList]),
    GlobalData = "global_data",
    GlobalDataTable = [util:to_binary(GlobalData)],
    case lists:member(GlobalDataTable, TableList) of
        true -> %% 有global_data表
            skip;
        _ ->    %% 没有global_data表，创建
            GDTSql = lists:concat(["CREATE TABLE `", GlobalData, "` (`key` varchar(255) NOT NULL,`val` text NOT NULL,PRIMARY KEY (`key`)) ENGINE=InnoDB DEFAULT CHARSET=utf8"]),
            Res3 = db_util:execute(GDTSql),
            ?WARNING("create table globaldata res:~w",[Res3]),
            ok
    end,
    %% 初始化golbal_data_disk
    ?GLOBAL_DATA_DISK:init(),
    db_version:check_version(),

    %% 重置player表
    Sql = lists:concat(["update player set on_line = 0,logout_time = if(logout_time = 0,",mod_timer:unixtime(),",logout_time) where on_line = 1"]),
    db_util:execute(Sql, ?VERSION_SQL_TIMEOUT),

    ok.

test() ->
    User = "root",
	Password = "123456",
    %% Start the MySQL dispatcher and create the first connection
    %% to the database. 'p1' is the connection pool identifier.
    mysql:start_link(p1, "localhost", User, Password, "test"),

    %% Add 2 more connections to the connection pool
    mysql:connect(p1, "localhost", undefined, User, Password, "test",
		  true),
    mysql:connect(p1, "localhost", undefined, User, Password, "test",
		  true),
    
    mysql:fetch(p1, <<"DELETE FROM developer">>),

    mysql:fetch(p1, <<"INSERT INTO developer(name, country) VALUES "
		     "('Claes (Klacke) Wikstrom', 'Sweden'),"
		     "('Ulf Wiger', 'USA')">>),

    %% Execute a query (using a binary)
    Result1 = mysql:fetch(p1, <<"SELECT * FROM developer">>),
    io:format("Result1: ~p~n", [Result1]),
    
    %% Register a prepared statement
    mysql:prepare(update_developer_country,
		  <<"UPDATE developer SET country=? where name like ?">>),
    
    %% Execute the prepared statement
    mysql:execute(p1, update_developer_country, [<<"Sweden">>, <<"%Wiger">>]),
    
    Result2 = mysql:fetch(p1, <<"SELECT * FROM developer">>),
    io:format("Result2: ~p~n", [Result2]),
    
    mysql:transaction(
      p1,
      fun() -> mysql:fetch(<<"INSERT INTO developer(name, country) VALUES "
			    "('Joe Armstrong', 'USA')">>),
	       mysql:fetch(<<"DELETE FROM developer WHERE name like "
			    "'Claes%'">>)
      end),

    Result3 = mysql:fetch(p1, <<"SELECT * FROM developer">>),
    io:format("Result3: ~p~n", [Result3]),
    
    ok.
    

get_db_name() ->
    util:to_list(?CONFIG(db_name)).

