%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.23
%%% @desc   : 打包并发送
%%%----------------------------------------------------------------------

-module(game_pack_send).

-include("common.hrl").
-include("record.hrl").
-include("tpl_map.hrl").

-export([
        send_to_one/2
        ,nodelay_send_to_one/1
        ,nodelay_send_to_one/2
        ,send_to_users/2
        ,nodelay_send_to_users/2

        ,send_to_all/1
        ,cross_send_to_all/1

        ,send_to_map_all/2
        ,map_send_to_all/2

        ,send_to_map_area/4
        ,map_send_to_area/4
    ]).

-export([pack/1]).

%% @doc 给某个玩家发送消息
%% 如果是当前节点，可以使用user_id，如果不确定节点，只能使用user_pid
send_to_one(UserX, Data) when is_tuple(Data) ->
    {ok, Bin} = pack(Data),
    send_to_one(UserX, Bin);
send_to_one(UserX, Bin) ->
    srv_user:cast_state_apply(UserX, {user_send, nodelay_send, [Bin]}).


%% @doc 给玩家直接发消息(地图等)
%% 如果是当前节点，可以使用user_id，如果不确定节点，只能使用user_pid
nodelay_send_to_one(UserX, Data) when is_tuple(Data) ->
    {ok, Bin} = pack(Data),
    nodelay_send_to_one(UserX, Bin);
nodelay_send_to_one(UserX, Bin) ->
    srv_user:cast_state_apply(UserX, {user_send, nodelay_send, [Bin]}).


%% @doc 发送给多个玩家
%% 如果是当前节点，可以使用user_id，如果不确定节点，只能使用user_pid
send_to_users(UserXList, Data) ->
    {ok, Bin} = pack(Data),
    [send_to_one(UserX, Bin) || UserX <- UserXList].

%% @doc 给多个玩家直接发消息，一般用于地图中
nodelay_send_to_users(UserXList, Data) ->
    {ok, Bin} = pack(Data),
    [nodelay_send_to_one(UserX, Bin) || UserX <- UserXList].


%% @doc 队伍广播
%% @doc 公会广播


%% @doc 当前节点给所有人发消息
send_to_all(DataList) when is_list(DataList) ->
    {ok, Bin} = pack(DataList),
    L = ets:tab2list(?ETS_USER_ONLINE),
    [send_to_one(Pid, Bin) || #user_online{pid = Pid} <- L];
send_to_all(Data) ->
    send_to_all([Data]).

%% @doc 在跨服节点给所有节点广播
cross_send_to_all(Data) ->
    %% TODO 获取所有连接节点
    NodeList = [],  
    [rpc:cast(Node, ?MODULE, send_to_all, [Data]) || Node <- NodeList].


%% @doc 非地图进程发消息给所有人
send_to_map_all(MapPid, DataList) when is_list(DataList) ->
    srv_map:cast_state_apply(MapPid, {?MODULE, map_send_to_all, [DataList]});
send_to_map_all(MapPid, Data) ->
    send_to_map_all(MapPid, [Data]).

%% @doc 在地图进程中发送消息给所有人
map_send_to_all(#map{map_id = MapID, user_dict = UserDict}, DataList) when is_list(DataList) ->
    {ok, Bin} = pack(DataList),
    case data_map:get(MapID) of
        #tpl_map{map_cross_type = 0} -> %% 非跨服地图
            [nodelay_send_to_one(E, Bin) || #map_user{user_pid = E} <- dict:to_list(UserDict)];
        _ ->        %% TODO 跨服地图，看是否需要把不同节点的玩家区分出来，先发送到对应节点在
            [nodelay_send_to_one(E, Bin) || #map_user{user_pid = E} <- dict:to_list(UserDict)]
    end;
map_send_to_all(Map, Data) ->
    map_send_to_all(Map, [Data]).


%% @doc 非地图进程发消息给某个区域内的人
send_to_map_area(MapPid, X, Y, DataList) when is_list(DataList) ->
    srv_map:cast_state_apply(MapPid, {?MODULE, map_send_to_area, [X, Y, DataList]});
send_to_map_area(MapPid, X, Y, Data) ->
    send_to_map_area(MapPid, X, Y, [Data]).

%% @doc 在地图进程中发送消息给某个区域的人
map_send_to_area(#map{map_id = MapID, aoi = Aoi}, X, Y, DataList) when is_list(DataList) ->
    %% 根据x,y获取区域内9宫格
    GridList = map_aoi:get_grids(X, Y),
    AoiObjList = map_aoi:get_grids_object(Aoi, GridList, ?AOI_OBJ_TYPE_USER),
    {ok, Bin} = pack(DataList),
    case data_map:get(MapID) of
        #tpl_map{map_cross_type = 0} -> %% 非跨服地图
            [nodelay_send_to_one(E, Bin) || #aoi_obj{pid = E} <- AoiObjList];
        _ ->        %% TODO 跨服地图，看是否需要把不同节点的玩家区分出来，先发送到对应节点在
            [nodelay_send_to_one(E, Bin) || #aoi_obj{pid = E} <- AoiObjList]
    end;
map_send_to_area(Map, X, Y, Data) ->
    map_send_to_area(Map, X, Y, [Data]).



%% @doc TODO 地图中阵营广播(涉及到地图的阵营)

%% @doc 打包
%% @return {ok, IoList}|any
%% TODO binary大于64字节时在进程之间共享内存，最好把iolist转成binary
pack(DataList) when is_list(DataList) ->
    IoList = [begin {ok, PackBin} = pack(Data), PackBin end || Data <- CmdDataList],
    case erlang:iolist_size(IoList) >= 64 of
        true ->
            {ok, erlang:iolist_to_binary(IoList)};
        _ ->
            {ok, IoList}
    end;
pack(Data) ->
    protobuf_encode:encode(Data).


