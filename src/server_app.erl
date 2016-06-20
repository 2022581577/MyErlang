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

start(_Type, _StartArgs) ->

    {ok, Sup} = start(),
    {ok, Sup}.

stop(_State) ->
    stop(),
    ok.

%% -------------------------
%%      LOCAL Function
%% -------------------------
%% @doc 开启服务
start() ->
    %% 开启主监控树
    {ok, Sup} = server_sup:start_link(),
    %% 开启一些进程的监控树
    {ok, _} = server_sup:start_sup_child(srv_map),
    {ok, _} = server_sup:start_sup_child(srv_user),
    {ok, _} = server_sup:start_sup_child(srv_send),

    game_config:init(),                                 %% 加载配置

    {ok, _} = server_sup:start_child(srv_timer),        %% 时间管理进程

%    ok = log_lager:init(),                              %% lager

    ok = error_logger_service(Sup),                     %% 错误日志相关
    ok = global_data_ram:init(),                        %% 需要在一开始init，game_node_interface中有用到

    game_node_interface:set_server_starting(),

    ok = netword_service(Sup),                          %% 网络相关服务
    ok = game_ets:init(),                               %% 各种ets初始化(数据库初始化前执行，有用到?ETS_GLOBAL_DATA)
    ok = edb:init(),                                    %% 数据库相关
    ok = game_ets:load(),                               %% 一些ets的加载(数据库初始化后执行)
    ok = game_counter:init(),                           %% 自增id计数器模块

    {ok, _} = server_sup:start_child(srv_node),         %% 节点管理进程
    {ok, _} = server_sup:start_child(srv_log),          %% 统计日志模块
    {ok, _} = server_sup:start_child(srv_map_manager),  %% 地图管理进程

    game_node_interface:set_server_running(),

    ?INFO("------Server Start Finish------"),
    {ok, Sup}.


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
    IP      = ?CONFIG(server_ip),
    Port    = ?CONFIG(server_port),
    MapPort = ?CONFIG(map_port),
    ?INFO("IP:~w, Port:~w~n", [IP, Port]),
    NetAddressL = [{game, IP, Port, ?TCP_OPT}, {map, IP, MapPort, ?TCP_OPT}],
    ok = tcp_listener_sup:start(Sup, NetAddressL),        %% 端口监听
    ?INFO("tcp_listener_sup finish!~n"),
    ok = tcp_client_sup:start(Sup, srv_reader),          %% 连接进程
    ?INFO("tcp_client_sup finish!~n"),
    ok = inets:start(),                         %% httpc服务
    ?INFO("inets finish!~n"),
    ?INFO("netword_service finish!~n"),
    ok.


%% 关闭服务
stop() ->
    game_node_interface:set_server_stopping(),
    %% 踢掉玩家

    %% 关闭各个系统
    global_data_disk:stop(),

    %% 最后关闭
    ok.

