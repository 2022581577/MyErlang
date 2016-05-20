%%%---------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2016.01.04.
%%% @desc   : 服务器开关是各种服务相关处理
%%%----------------------------------------------------------------------
-module(lib_server).
-include("common.hrl").

-export([start/1
        ,stop/0]).

-compile(export_all).

%% @doc 开启服务
start(Sup) ->
    game_config:init(),                                 %% 加载配置

    {ok, _} = server_sup:start_child(srv_timer),        %% 时间管理进程

    ok = lager_service(Sup),                            %% lager

    ok = error_logger_service(Sup),                     %% 错误日志相关
    ok = global_data_ram:init(),                        %% 需要在一开始init，game_node_interface中有用到

    game_node_interface:set_server_starting(),

    ok = netword_service(Sup),                          %% 网络相关服务
    %% ok = mysql_service(Sup),                            %% 数据库相关
    %% ok = global_data_disk:init(),                       %% 数据库启动后开启
    ok = game_ets_init:init(),                          %% 各种ets初始化
    %% ok = game_counter:init(),                           %% 自增id计数器模块

    {ok, _} = server_sup:start_child(srv_log),          %% 统计日志模块
    {ok, _} = server_sup:start_child(srv_map_manager),  %% 地图管理进程

    game_node_interface:set_server_running(),
    ok.

%% lager
lager_service(_Sup) ->
    application:start(syntax_tools),
    application:start(compiler),
    application:start(goldrush),
    application:start(lager),
    ok.

%% 开启错误日志
error_logger_service(_Sup) ->
    LogLevel = ?CONFIG(log_level),
    Return   = error_logger:add_report_handler(logger_h, logs),
    io:format("LogLevel:~w, Set logger return:~p~n",[LogLevel, Return]),
    loglevel:set(util:to_integer(LogLevel)),
    io:format("error_logger_service finish!~n"),
    ok.

%% 网络相关
netword_service(Sup) ->
    IP   = ?CONFIG(server_ip),
    Port = ?CONFIG(server_port),
    io:format("IP:~w, Port:~w~n", [IP, Port]),
    ok = tcp_listener_sup:start(Sup, IP, Port, ?TCP_OPT),        %% 端口监听
    io:format("tcp_listener_sup finish!~n"),
    ok = tcp_client_sup:start(Sup),          %% 连接进程
    io:format("tcp_client_sup finish!~n"),
    ok = inets:start(),                         %% httpc服务
    io:format("inets finish!~n"),
    io:format("netword_service finish!~n"),
    ok.
    
%% 数据库
mysql_service(Sup) ->
    edb:init(Sup),
    io:format("mysql_service finish!~n"),
    ok.

%% 关闭服务
stop() ->
    game_node_interface:set_server_stoping(),
    %% 踢掉玩家

    ?GLOBAL_DATA_DISK:stop(),

    %% 最后关闭
    ok.
