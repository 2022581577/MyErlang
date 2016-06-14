%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 五月 2016 15:14
%%%-------------------------------------------------------------------
-module(map_base).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").
-include("tpl_map.hrl").

%% export
-export([init/3]).
-export([loop/1]).
-export([enter/1]).
-export([leave/1]).
-export([close/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
%% @doc 初始化加载
init(MapID, MapIndexID, Args) ->
    {ok, #map{module = Module} = Map1} = base_init(MapID, MapIndexID, Args),
    case Module of
        ?UNDEFINED ->
            {ok, Map1};
        _ ->
            Module:init(Map1)
    end.

%% @doc 循环
loop(Map) ->
    {ok, #map{module = Module} = Map1} = base_loop(Map),
    case Module of
        ?UNDEFINED ->
            {ok, Map1};
        _ ->
            Module:init(Map1)
    end.

%% @doc 进入场景
enter(Map) ->
    {ok, #map{module = Module} = Map1} = base_enter(Map),
    case Module of
        ?UNDEFINED ->
            {ok, Map1};
        _ ->
            Module:enter(Map1)
    end.

%% @doc 离开场景
leave(Map) ->
    {ok, #map{module = Module} = Map1} = base_leave(Map),
    case Module of
        ?UNDEFINED ->
            {ok, Map1};
        _ ->
            Module:leave(Map1)
    end.

%% @doc 场景关闭
close(Map) ->
    {ok, #map{module = Module} = Map1} = base_close(Map),
    case Module of
        ?UNDEFINED ->
            {ok, Map1};
        _ ->
            Module:close(Map1)
    end.

%% ========================================================================
%% Local functions
%% ========================================================================
base_init(MapID, MapIndexID, Args) ->
    LongNow = util:longunixtime(),
    Now     = util:unixtime(),
    MapInfo = #map_info{map_inst_id = {MapID, MapIndexID}
                        ,map_id     = MapID
                        ,map_index_id = MapIndexID
                        ,map_pid    = self()
    },
    ets:insert(?ETS_MAP_INFO, MapInfo),
    MapTpl = data_map:get(MapID),
    Map = #map{map_id       = MapID
            ,map_index_id   = MapIndexID
            ,map_type       = MapTpl#tpl_map.map_type
            ,map_sub_type   = MapTpl#tpl_map.map_sub_type
            ,module         = proplists:get_value(module, Args, ?UNDEFINED)
            ,create_time    = LongNow
            ,longunixtime   = LongNow
            ,unixtime       = Now
            ,last_active    = LongNow   %% TODO 是否需要改成相对时间或者系统时间
    },
    %% TODO 地图掩码、九宫格处理

    %% 怪物、npc、玩家
    {ok, Map1} = map_mon:init(Map),
    {ok, Map2} = map_npc:init(Map1),
    {ok, MapN} = map_user:init(Map2),
    {ok, MapN}.

base_loop(Map) ->
    #map{loop_count = LoopCount} = Map,
    LongNow = util:longunixtime(),
    Now     = util:unixtime(),
    Map1 = Map#map{longunixtime = LongNow
                ,unixtime       = Now
                ,loop_count     = LoopCount + 1
    },
    {ok, Map1}.

base_enter(Map) ->
    {ok, Map}.

base_leave(Map) ->
    {ok, Map}.

base_close(#map{map_id = MapID, map_index_id = MapIndexID} = Map) ->
    ets:delete(?ETS_MAP_INFO, {MapID, MapIndexID}),
    %% 在srv_map_manager中删除各种映射关系
    srv_map_manager:del_map(MapID, MapIndexID),
    {ok, Map}.