%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 各种服务的开启
%%-----------------------------------------------------

-module(server_app).

-include("common.hrl").

-export([start/2
        ,stop/1]).

-export([prep_stop/0]).

-compile(export_all).

start(normal, []) ->
    %% 开启主监控树
    {ok, Sup} = server_sup:start_link(),
    %% 加载配置
    game_config:init(),
    ok = start(Sup),
    {ok, Sup}.

stop(_) ->
    ok.

%% 关闭各种服务操作
prep_stop() ->
    ok.

%% -------------------------
%%      LOCAL Function
%% -------------------------
start(Sup) ->

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

