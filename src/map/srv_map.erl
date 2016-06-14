%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.02.16
%%% @desc   : 地图模块
%%%----------------------------------------------------------------------

-module(srv_map).
-behaviour(behaviour_gen_server).
-compile(inline).

-include("common.hrl").
-include("record.hrl").
-include("tpl_map.hrl").

-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).

-export([start/3, start_link/3]).

-export([cast_stop/1
        ,cast_stop/2
        ,cast_apply/2
        ,cast_apply/3
        ,cast_state_apply/2
        ,cast_state_apply/3
        ,cast/2
        ,cast/3]).

-export([call_stop/1
        ,call_stop/2
        ,call_apply/2
        ,call_apply/3
        ,call_state_apply/2
        ,call_state_apply/3
        ,call/2
        ,call/3
        ,i/1
        ,p/1]).


-define(MAP_LOOP_CHECK_SEND,((10 * 1000) div ?MAP_LOOP_TICK)).  %% 发送进程检查时间
-define(MAP_LOOP_CHECK,(1000 div ?MAP_LOOP_TICK)).              %% 发送进程检查时间
-define(MAP_LOOP_DAOFA,(400 div ?MAP_LOOP_TICK)).               %% 道法更新
-define(MAP_LOOP_CHECK_PVP,(200 div ?MAP_LOOP_TICK)).              %% 发送进程检查时间
-define(DUPLICATION_ADD_LIVE_TIME, 180).                        %% 额外给地图多180s的存活时间

%% @doc 开启地图API
start(MapID, MapIndexID, Args) ->
    ProcessName = map_api:get_map_process_name(MapID, MapIndexID),
    case erlang:whereis(ProcessName) of
        undefined ->
            server_sup:start_map([MapID, MapIndexID, Args]);
        Pid ->
            behaviour_gen_server:cast_apply(Pid, srv_map, set_last_active, []),   
            {ok,Pid}
    end.

start_link(MapID, MapIndexID, Args) ->
    ProcessName = map_api:get_map_process_name(MapID, MapIndexID),
    behaviour_gen_server:start_link({local,ProcessName}, ?MODULE, [MapID, MapIndexID, Args], []).

do_init([MapID, MapIndexID, Args]) ->
    ?INFO("Start Map, MapID:~w, MapIndexID:~w",[MapID, MapIndexID]),
    process_flag(trap_exit,true),
    erlang:send_after(?MAP_LOOP_TICK, self(), loop),
    {ok, Map} = map_base:init(MapID, MapIndexID, Args),
    {ok, Map}.

do_call(Info, _From, Map) -> 
    ?WARNING("Not done do_call:~w",[Info]),
    {reply, error, Map}.


do_cast(Info, Map) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
    {noreply, Map}.


do_info(loop, Map) ->
    erlang:send_after(?MAP_LOOP_TICK, self(), loop),
    {ok, NewMap} = map_base:loop(Map),
    {noreply, NewMap};

do_info(Info, Map) -> 
    ?WARNING("Not done do_info:~w",[Info]),
    {noreply, Map}.

do_terminate(Reason, #map{map_id = MapID, map_index_id = MapIndexID} = Map) ->
    ?INFO("~w stop,MapID:~w,MapIndexID:~w,Reason:~w...",
        [?MODULE, MapID, MapIndexID, Reason]),
    map_base:close(Map),
    ok.

%%% -------------------------------------------
%%%             -----API-----
%%% -------------------------------------------
%% @doc 停止进程 cast 方式
cast_stop(MapPid) ->
    cast(MapPid, stop).
cast_stop(MapID, MapIndexID) ->
    cast(MapID, MapIndexID, stop).
    
%% @doc 同步停止进程
call_stop(MapPid) ->
    call(MapPid, stop).
call_stop(MapID, MapIndexID) ->
    call(MapID, MapIndexID, stop).


%% @param Callback {M, F, A} | {F, A} | F
%% @return ok | false
%% 如果是MapID和MapIndexID，需要在地图进程所在节点调用；MapPid可在任意节点调用
cast_state_apply(MapID, MapIndexID, Callback) ->      
    case map_api:get_map_pid(MapID, MapIndexID) of
        false ->
            ?WARNING("cast state apply map false, MapID:~w, MapIndexID:~w, Callback:~w", [MapID, MapIndexID, Callback]),
            false;
        MapPid ->
            cast_state_apply(MapPid, Callback)
    end.
cast_state_apply(MapPid, Callback) ->
    {M, F, A} = util:transform_callback(Callback),
    behaviour_gen_server:cast_state_apply(MapPid, M, F, A).

cast_apply(MapID, MapIndexID, Callback) ->      
    case map_api:get_map_pid(MapID, MapIndexID) of
        false ->
            ?WARNING("cast apply map false, MapID:~w, MapIndexID:~w, Callback:~w", [MapID, MapIndexID, Callback]),
            false;
        MapPid ->
            cast_apply(MapPid, Callback)
    end.
cast_apply(MapPid, Callback) ->
    {M, F, A} = util:transform_callback(Callback),
    behaviour_gen_server:cast_apply(MapPid, M, F, A).

%% @param msg
%% @return ok | {false, Res}
%% 如果是MapID和MapIndexID，需要在地图进程所在节点调用；MapPid可在任意节点调用
cast(MapID, MapIndexID, Msg) ->
    case map_api:get_map_pid(MapID, MapIndexID) of
        false ->   
            ?WARNING("cast map false, MapID:~w, MapIndexID:~w, Msg:~w", [MapID, MapIndexID, Msg]);
        MapPid ->
            behaviour_gen_server:cast(MapPid, Msg)
    end.
cast(MapPid, Msg) ->
    behaviour_gen_server:cast(MapPid, Msg).


%% @param Callback {M, F, A} | {F, A} | F
%% @return ok | false
%% 如果是MapID和MapIndexID，需要在地图进程所在节点调用；MapPid可在任意节点调用
call_state_apply(MapID, MapIndexID, Callback) ->      
    case map_api:get_map_pid(MapID, MapIndexID) of
        false ->
            ?WARNING("call state apply map false, MapID:~w, MapIndexID:~w, Callback:~w", [MapID, MapIndexID, Callback]),
            false;
        MapPid ->
            call_state_apply(MapPid, Callback)
    end.
call_state_apply(MapPid, Callback) ->
    {M, F, A} = util:transform_callback(Callback),
    behaviour_gen_server:call_state_apply(MapPid, M, F, A).

call_apply(MapID, MapIndexID, Callback) ->      
    case map_api:get_map_pid(MapID, MapIndexID) of
        false ->
            ?WARNING("call apply map false, MapID:~w, MapIndexID:~w, Callback:~w", [MapID, MapIndexID, Callback]),
            false;
        MapPid ->
            call_apply(MapPid, Callback)
    end.
call_apply(MapPid, Callback) ->
    {M, F, A} = util:transform_callback(Callback),
    behaviour_gen_server:call_apply(MapPid, M, F, A).

%% @param msg
%% @return ok | {false, Res}
%% 如果是MapID和MapIndexID，需要在地图进程所在节点调用；MapPid可在任意节点调用
call(MapID, MapIndexID, Msg) ->
    case map_api:get_map_pid(MapID, MapIndexID) of
        false ->   
            ?WARNING("call map false, MapID:~w, MapIndexID:~w, Msg:~w", [MapID, MapIndexID, Msg]);
        MapPid ->
            behaviour_gen_server:call(MapPid, Msg)
    end.
call(MapPid, Msg) ->
    behaviour_gen_server:call(MapPid, Msg).


%% @doc 调试接口,获取状态
i(ID) ->
    call(ID, get_state).
p(ID) ->
    case i(ID) of
        #map{} = Map ->
            lib_record:print_record(Map);
        R ->
            R
    end.
