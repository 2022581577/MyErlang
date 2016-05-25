%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.02.16
%%% @desc   : 统一分配地图ID(只是保证在单一进程执行，数据存在ets中，进程重启不影响数据)
%%%           跨服中，活动与对应活动地图需要在一致的跨服节点上
%%%----------------------------------------------------------------------

-module(srv_map_manager).
-behaviour(behaviour_gen_server).
-compile(inline).

-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).
-export([start_link/0]).

-export([start_map/1, del_map/2]).

%% 进程内接口
-export([do_start_map/1
        ,do_del_map/2]).

-include("common.hrl").
-include("record.hrl").
-include("tpl_map.hrl").

-record(state,{}).

%% TODO 后期需要添加跨服处理，到对应的跨服节点获取
%% 根据地图跨服类型活动对应的节点
start_map(MapID) ->
    behaviour_gen_server:call_apply(?MODULE, ?MODULE, do_start_map, [MapID]).

%% 删除映射关系
del_map(MapID, MapIndexID) ->
    behaviour_gen_server:cast_apply(?MODULE, ?MODULE, do_del_map, [MapID, MapIndexID]).

start_link() ->
	behaviour_gen_server:start_link({local,?MODULE},?MODULE,[],[]).

do_init([]) ->
    process_flag(trap_exit,true),
    %% TODO 可考虑是否把一些基础地图开启
	{ok,#state{}}.

do_cast(Info, State) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
	{noreply, State}.

do_call(Info, _From, State) -> 
    ?WARNING("Not done do_call:~w",[Info]),
	{reply, ok, State}.

do_info(Info, State) -> 
    ?WARNING("Not done do_info:~w",[Info]),
	{noreply, State}.

do_terminate(_Reason, _State) ->
    ok.


%% @doc 开启地图
do_start_map(MapID) ->
    MapIndexID = get_map_index_id(MapID),
    {ok, MapPid} = srv_map:start(MapID, MapIndexID),
    {MapID, MapIndexID, MapPid}.


%% @doc 创建地图index_id
get_map_index_id(MapID) ->
    case data_map:get(MapID) of
        #tpl_map{map_type = ?MAP_TYPE_NORMAL, max_user = MaxUser}->     %% 普通地图
            get_map_counter(MapID, MaxUser);
        #tpl_map{map_type = ?MAP_TYPE_ACTIVITY, max_user = MaxUser}->   %% 和普通地图类似
            get_map_counter(MapID, MaxUser);
        #tpl_map{map_type = ?MAP_TYPE_DUP, max_user = MaxUser} ->       %% 副本，开启一个算一个
            case ets:lookup(?ETS_MAP_ID_LIST, MapID) of
                [{_,L}] ->
                    IndexID = game_counter:get_map_index_id(MapID),
                    ets:insert(?ETS_MAP_ID_LIST, {MapID, L ++ [IndexID]}),
                    IndexID;
                [] ->   %% 没有对应地图
                    ?WARNING("Open First Index! MapID:~w, MaxUser:~w",[MapID, MaxUser]),
                    IndexID = game_counter:get_map_index_id(MapID),
                    ets:insert(?ETS_MAP_ID_LIST, {MapID, [IndexID]}),
                    IndexID
            end;
        Other ->
            ?WARNING("Get data map fail,MapID:~w MapData:~w",[MapID,Other]),
            false
    end.


%% 不限制人数上限的地图
get_map_counter(MapID, 0) ->
    case ets:lookup(?ETS_MAP_ID_LIST, MapID) of
        [{_,[IndexID |_]}] ->
            IndexID;
        [] ->
            IndexID = game_counter:get_map_index_id(MapID),
            ets:insert(?ETS_MAP_ID_LIST, {MapID, [IndexID]}),
            IndexID
    end;
%% 有人数上限限制
get_map_counter(MapID, MaxUser) ->
    case ets:lookup(?ETS_MAP_ID_LIST, MapID) of
        [{_,L}] ->
            case check_map_max_user(MapID, L,MaxUser) of
                false ->    %% 现有地图人数都满了
                    ?WARNING("Open New Index! MapID:~w, MaxUser:~w",[MapID, MaxUser]),
                    IndexID = game_counter:get_map_index_id(MapID),
                    ets:insert(?ETS_MAP_ID_LIST, {MapID, L ++ [IndexID]}),
                    IndexID;
                IndexID ->
                    IndexID
            end;
        [] ->   %% 没有对应地图
            ?WARNING("Open First Index! MapID:~w, MaxUser:~w",[MapID, MaxUser]),
            IndexID = game_counter:get_map_index_id(MapID),
            ets:insert(?ETS_MAP_ID_LIST, {MapID, [IndexID]}),
            IndexID
    end.


%% @doc 检查地图人数据上限
check_map_max_user(_MapID, [], _MaxUser) ->
    false;
check_map_max_user(MapID, [H |T], MaxUser) ->
    case ets:lookup(?ETS_MAP_INFO, {MapID, H}) of
        [#map_info{count = Count}] when Count < MaxUser ->
            H;
        _ ->
            check_map_max_user(MapID, T, MaxUser)
    end.

%% @doc 删除地图
do_del_map(MapID, MapIndexID) ->
    case ets:lookup(?ETS_MAP_ID_LIST, MapID) of
        [{MapID, L}] when is_list(L) ->
            case lists:delete(MapIndexID, L) of
                [] ->
                    ets:delete(?ETS_MAP_ID_LIST, MapID);
                L1 ->
                    ets:insert(?ETS_MAP_ID_LIST, {MapID, L1})
            end;
        _ ->
            skip
    end.
