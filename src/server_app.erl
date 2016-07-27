%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 各种服务的开启
%%-----------------------------------------------------

-module(server_app).

-include("common.hrl").

-export([start/2
        ,prep_stop/1
        ,stop/1]).

start(_Type, _StartArgs) ->

    {ok, Sup} = start(),
    {ok, Sup}.

prep_stop(State) ->
    stop(),
    State.


stop(_State) ->
    ok.

%% -------------------------
%%      LOCAL Function
%% -------------------------
%% @doc 开启服务
start() ->
    game_node_interface:set_server_starting(),

    game_config:init(),                                 %% 加载配置
    {ok, Sup} = server_sup:start_link(),                %% 开启主监控树
    {ok, _} = server_sup:start_child(srv_timer),        %% 时间管理进程
    ok = service(error_logger, Sup),                    %% 错误日志相关
    ok = service(misc, Sup),                            %% 服务器各种初始化
    ok = service(process, Sup),                         %% 各种监控进程、工作进程相关
    ok = service(netword, Sup),                         %% 网络相关服务

    game_node_interface:set_server_running(),

    ?INFO("------ Server Start Finish ------"),
    {ok, Sup}.


%% 开启错误日志
service(error_logger, _Sup) ->
    LogLevel = ?CONFIG(log_level),
    Return   = error_logger:add_report_handler(logger_h, logs),
    io:format("LogLevel:~w, Set logger return:~p~n",[LogLevel, Return]),
    loglevel:set(util:to_integer(LogLevel)),
    io:format("error_logger_service finish!~n"),
%%    ok = log_lager:init(),                              %% lager
    ok;

%% 服务器各种初始化，需要保证顺序
service(misc, _Sup) ->
    ok = global_data_ram:init(),                        %% 全局临时变量
    ok = game_ets:init(),                               %% 各种ets初始化(数据库初始化前执行，有用到?ETS_GLOBAL_DATA)
    ok = edb:init(),                                    %% 数据库相关
    ok = game_ets:load(),                               %% 一些ets的加载(数据库初始化后执行)
    ok = game_counter:init(),                           %% 自增id计数器模块
    ok;

%% 一些监控进程和工作进程，注意有些进程需要保证顺序
service(process, _Sup) ->
    %% 开启一些进程的监控树
    {ok, _} = server_sup:start_sup_child(srv_map),
    {ok, _} = server_sup:start_sup_child(srv_user),
    {ok, _} = server_sup:start_sup_child(srv_send),

    %% 工作进程
    {ok, _} = server_sup:start_child(srv_node),         %% 节点管理进程
    {ok, _} = server_sup:start_child(srv_log),          %% 统计日志模块
    {ok, _} = server_sup:start_child(srv_map_manager),  %% 地图管理进程
    ok;

%% 网络相关
service(netword, Sup) ->
    IP      = ?CONFIG(server_ip),
    Port    = ?CONFIG(server_port),
    MapPort = ?CONFIG(map_port),
    ?INFO("IP:~w, Port:~w", [IP, Port]),
    NetAddressL = [{game, IP, Port, ?TCP_OPT}, {map, IP, MapPort, ?TCP_OPT}],
    ok = tcp_listener_sup:start(Sup, NetAddressL),        %% 端口监听
    ok = tcp_client_sup:start(Sup, srv_reader),          %% 连接进程
    ok = inets:start(),                         %% httpc服务
    ?INFO("netword_service finish!"),
    ok;

service(_, _Sup) ->
    ok.

%% 关闭服务
stop() ->
    game_node_interface:set_server_stopping(),
    %% 踢掉玩家

    %% 关闭各个系统
    global_data_disk:stop(),

    %% 最后关闭
    ok.

