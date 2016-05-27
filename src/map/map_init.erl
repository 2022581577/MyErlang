%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   :
%%%------------------------------------------------------------------------

-module(map_init).

%% include
-include("common.hrl").
-include("record.hrl").
-include("tpl_map.hrl").

%% export
-export([init/3]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
init(MapID, MapIndexID, _Args) ->
    lib_trap_block:set_block_trap_list([]),
    lib_map_point:init(MapID),
    _TimeStamp = util:timestamp(),
    MapInfo = #map_info{map_inst_id = {MapID, MapIndexID}
        ,map_id = MapID
        ,map_index_id = MapIndexID
        ,map_pid = self()},
    ets:insert(?ETS_MAP_INFO, MapInfo),
    MapTpl = data_map:get(MapID),
    Map = #map{
        map_id = MapID
        ,map_index_id = MapIndexID
        ,map_type = MapTpl#tpl_map.map_type
        ,map_sub_type = MapTpl#tpl_map.map_sub_type
        %,aoi_map = aoi:create_map({0, 0}, {MapConfigTpl#tpl_map_config.width, MapConfigTpl#tpl_map_config.height})
        ,create_time = util:longunixtime()
    },
    %% TODO 地图掩码、九宫格、NPC、怪物等处理
    %% {true, NewMap} = map:create_mon([Map, NewMonList]),
    srv_map:set_last_active(),
    {ok, Map}.

%% ========================================================================
%% Local functions
%% ========================================================================

