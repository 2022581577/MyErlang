%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.02.16
%%% @desc   : 统一分配地图ID
%%%           跨服中，活动与对应活动地图需要在一致的跨服节点上
%%%----------------------------------------------------------------------

-module(srv_map_manager).
-behaviour(gen_server2).
-compile(inline).

-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).
-export([start_link/0]).
-export([apply/1,mfa_apply/3]).	                %% cast接口

-export([get_map_index_id/1, start_map/2]).

-include("common.hrl").
-include("record.hrl").
-include("tpl_map.hrl").

-record(state,{}).

get_map_index_id(MapID) ->
    gen_server:call(?MODULE, {get_map_index_id,MapID}).

%% TODO 后期需要添加跨服处理，到对应的跨服节点获取
%% 根据地图跨服类型活动对应的节点
start_map(MapID) ->
    gen_server:call(?MODULE, {start_map, MapID}).


start_link() ->
	gen_server2:start_link({local,?MODULE},?MODULE,[],[]).

do_init([]) ->
    process_flag(trap_exit,true),
    %% TODO 可考虑是否把一些基础地图开启
	{ok,#state{}}.

do_cast(Info, State) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
	{noreply, State}.

do_call({get_map_index_id, MapID},_From,State) ->
    MapOnlyID = lib_map_counter:get_map_index_id(MapID),
    {reply, {MapID, MapOnlyID}, State};

do_call({start_map, MapID},_From,State) ->
    Reply = do_start_map(MapID),
    {reply,Reply,State};

do_call(Info, _From, State) -> 
    ?WARNING("Not done do_call:~w",[Info]),
	{reply, ok, State}.

do_info(Info, State) -> 
    ?WARNING("Not done do_info:~w",[Info]),
	{noreply, State}.

do_terminate(_Reason, _State) ->
    ok.

	
%% @doc FUn函数调用
apply(Fun) ->
	gen_server:cast(?MODULE,{apply,Fun}).
%% @doc MFA函数调用
mfa_apply(Mod,Fun,Args) ->
	gen_server:cast(?MODULE,{mfa_apply,Mod,Fun,Args}).

do_start_map(MapID) ->
    MapOnlyID = get_map_index_id(MapID),
    ProcessName = map_api:get_map_process_name(MapID, MapIndexID),
    case erlang:whereis(ProcessName) of
        undefined ->
            ?D("============ MapID:~w,MapOnlyID:~w,IsPvp:~w ==========",[MapID,MapOnlyID,IsPvP]),
            {ok, MapPid} = srv_map:start(MapID, MapIndexID),
            {MapID, MapIndexID, MapPid};
        MapPid ->
            % mod_map:mfa_apply(Pid,mod_map,set_last_active,[]),    %% TODO 需重新激活地图
            {MapID, MapIndexID, MapPid}
    end.


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
                    IndexID = counter:get_map_index_id(MapID),
                    ets:insert(?ETS_MAP_ID_LIST, {MapID, L ++ [IndexID]}),
                    IndexID;
                [] ->   %% 没有对应地图
                    ?WARNING("Open First Index! MapID:~w, MaxUser:~w",[MapID, MaxUser]),
                    IndexID = counter:get_map_index_id(MapID),
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
        [{_,[ID |_]}] ->
            ID;
        [] ->
            IndexID = counter:get_map_index_id(MapID),
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
                    IndexID = counter:get_map_index_id(MapID),
                    ets:insert(?ETS_MAP_ID_LIST, {MapID, L ++ [IndexID]}),
                    IndexID;
                IndexID ->
                    IndexID
            end;
        [] ->   %% 没有对应地图
            ?WARNING("Open First Index! MapID:~w, MaxUser:~w",[MapID, MaxUser]),
            IndexID = counter:get_map_index_id(MapID),
            ets:insert(?ETS_MAP_ID_LIST, {MapID, [IndexID]}),
            IndexID;
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
