%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.20
%%% @desc   : 地图计数器模块,用于统计各地图开启数
%%%----------------------------------------------------------------------

-module(lib_map_counter).
-author('kongqingquan <kqqsysu@gmail.com>').
-export([
        get_map_only_id/1,
        get_map_id/1,
        save_map_state/1,
        get_map_state/1,
        remove_map_state/2,
        count/1,
        check_map_users/2,
        get_map_counter/0
    ]).

-include("common.hrl").
-include("record.hrl").

%% 地图最大自增ID
-define(MAX_MAP_COUNTER,100000).

%% @doc 根据地图唯一ID获取地图ID
get_map_id(MapOnlyID) ->
    case ets:lookup(?ETS_MAP_INFO,MapOnlyID) of
        [#map_state{map_id = MapID}] ->
            MapID;
        [] ->
            ?WARNING("Get MapID Fail,MapOnlyID:~w",[MapOnlyID]),
            0
    end.
save_map_state(#map_state{} = MapState) ->
    ets:insert(?ETS_MAP_INFO, MapState).
get_map_state(MapOnlyID) ->
    case ets:lookup(?ETS_MAP_INFO,MapOnlyID) of
        [#map_state{} = MapState] ->
            MapState;
        [] ->
            false
    end.
remove_map_state(MapOnlyID,MapID) ->
    ets:delete(?ETS_MAP_INFO,MapOnlyID),
    %% 删除ID映射
    case ets:lookup(?ETS_MAP_ID_LIST,MapID) of
        [{MapID,L}] when is_list(L) ->
            case lists:delete(MapOnlyID,L) of
                [] ->
                    ets:delete(?ETS_MAP_ID_LIST,MapID);
                NewList ->
                    ets:insert(?ETS_MAP_ID_LIST,{MapID,NewList})
            end;
        [] ->
            skip;
        Other  ->
            ?WARNING("Remove Map State fail,MapID:~w,MapOnlyID:~w,L:~w",[MapID,MapOnlyID,Other])
    end,
    ok.

%% @doc 创建地图唯一ID
get_map_only_id(MapID) ->
    case data_map:get(MapID) of
        #data_map{map_type = ?MAP_TYPE_NORMAL,fenxian = FenXian, max_user = MaxUser}->
            %% 普通地图
            get_map_counter(MapID,FenXian,MaxUser);
        #data_map{map_type = ?MAP_TYPE_DUPLICATION,max_user = MaxUser} ->
            %% 副本地图
            #data_duplication{type=DupType}=data_duplication:get(MapID),
            case DupType of
                ?DUPLICATION_FML -> %% 封魔录副本
                    get_map_counter(MapID,?MAP_FEN_XIAN, ?FML_MAX_USER);
                ?DUPLICATION_TEST_PVP ->   %% 测试pvp副本
                    get_map_counter(MapID,?MAP_FEN_XIAN, MaxUser);
                _ ->
                    OnlyID = get_map_counter(),
                    List = 
                    case ets:lookup(?ETS_MAP_ID_LIST,MapID) of
                        [{MapID,L}] when is_list(L) ->
                            L;
                        _ ->
                            []
                    end,
                    NewList = [OnlyID | List],
                    ets:insert(?ETS_MAP_ID_LIST,{MapID,NewList}),
                    OnlyID
            end;
        Other ->
            ?WARNING("Get data map fail,MapID:~w MapData:~w",[MapID,Other]),
            false
    end.

%% @doc 获取当前地图已开启数
get_map_counter() ->
    %% 限制地图ID次数
    do_get_map_counter(1000). 
do_get_map_counter(N) when N > 0 ->
    Counter = ets:update_counter(?ETS_MAP_COUNTER,?MAP_COUNTER,1),
    NewCounter =
    case Counter < (?MAX_MAP_COUNTER + ?INIT_MAP_ONLY_ID) of
        true ->
            Counter;
        false ->
            %% 重置自增ID
            ets:insert(?ETS_MAP_COUNTER,{?MAP_COUNTER,?INIT_MAP_ONLY_ID}),
            ?INIT_MAP_ONLY_ID
    end,
    case lib_map_api:get_pid(NewCounter) of
        undefined ->
            NewCounter;
        Pid ->
            %% 地图已经开启了
            ?WARNING("Map Has been Start,Pid:~w,Counter:~w",[Pid,NewCounter]),
            do_get_map_counter(N -1)
    end;
do_get_map_counter(_) ->
    ?WARNING("Get Map Counter Fail",[]),
    false.

%% @doc 不分线普通地图
get_map_counter(MapID,?MAP_NOT_FEN_XIAN,_MaxUser) ->
    case ets:lookup(?ETS_MAP_ID_LIST,MapID) of
        [{_,[ID |_]}] ->
            ID;
        [] ->
            OnlyID = get_map_counter(),
            ets:insert(?ETS_MAP_ID_LIST,{MapID,[OnlyID]}),
            OnlyID
    end;
get_map_counter(MapID,?MAP_FEN_XIAN,MaxUser) ->
    case ets:lookup(?ETS_MAP_ID_LIST,MapID) of
        [{_,L}] ->
            case check_map_users(L,MaxUser) of
                false ->
                    %% 所有分线已满人新开地图
                    ?WARNING("Open New FenXian,MapID:~w,MaxUser:~w",[MapID,MaxUser]),
                    Counter = get_map_counter(),
                    ets:insert(?ETS_MAP_ID_LIST,{MapID,L ++ [Counter]}),
                    Counter;
                OnlyID ->
                    OnlyID
            end;
        [] ->
            OnlyID = get_map_counter(),
            ets:insert(?ETS_MAP_ID_LIST,{MapID,[OnlyID]}),
            OnlyID
    end.


%% @doc 检查地图人数据上限
check_map_users([],_MaxUser) ->
    false;
check_map_users([H |T],MaxUser) ->
    case count(H) =< MaxUser of
        true ->
            H;
        false ->
            check_map_users(T,MaxUser)
    end.

%% @doc 地图人数
count(MapOnlyID) ->
    case get_map_state(MapOnlyID) of
        #map_state{count = Count} ->
            Count;
        _ ->
            0
    end.

