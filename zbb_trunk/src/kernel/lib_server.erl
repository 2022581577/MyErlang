%%%---------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2016.01.04.
%%% @desc   : 服务器开关是各种服务相关处理
%%%----------------------------------------------------------------------
-module(lib_server).
-include("common.hrl").

-export([start/1
        ,stop/0]).

%% @doc 开启服务
start(Sup) ->
    %% 时间管理进程
    server_sup:start_child(srv_timer),
    %% 错误日志相关
    error_logger_service(Sup),
    io:format("error_logger_service finish!~n"),

    ?GLOBAL_DATA_RAM:init(),

    node_interface:set_server_starting(),

    %% 网络相关服务
    net_service(Sup),
    io:format("net_service finish!~n"),

    %% 数据库相关
    mysql_service(Sup),

    %% 数据库启动后开启GLOBAL_DATA_DISK
    ?GLOBAL_DATA_DISK:init(),

    %% 各种ets初始化
    ets_init:init(),

    %% 自增id计数器模块
    counter:init(), 
    %% 统计日志模块
    server_sup:start_child(srv_log),
    
    %% 地图管理进程
    server_sup:start_child(srv_map_manager),

    node_interface:set_server_running(),
    ok.

%% 开启错误日志
error_logger_service(_Sup) ->
    LogLevel = ?CONFIG(log_level),
    Return = error_logger:add_report_handler(logger_h, logs),
    io:format("LogLevel:~w, Set logger return:~p~n",[LogLevel, Return]),
    loglevel:set(util:to_integer(LogLevel)),
    ok.

%% 网络相关
net_service(Sup) ->
    IP = ?CONFIG(server_ip),
    Port = ?CONFIG(server_port),
    io:format("IP:~w, Port:~w~n", [IP, Port]),
    ok = tcp_listener_sup:start(Sup, IP, Port, ?TCP_OPT),        %% 端口监听
    io:format("tcp_listener_sup finish!~n"),
    ok = tcp_client_sup:start(Sup),          %% 连接进程
    io:format("tcp_client_sup finish!~n"),
    ok = inets:start(),                         %% httpc服务
    io:format("inets finish!~n"),
    ok.
    
%% 数据库
mysql_service(Sup) ->
    edb:init(Sup),
    ok.

%% 关闭服务
stop() ->
    node_interface:set_server_stoping(),
    %% 踢掉玩家

    ?GLOBAL_DATA_DISK:stop(),

    %% 最后关闭
    ok.
