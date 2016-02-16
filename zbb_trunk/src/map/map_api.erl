%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.02.16
%%% @desc   : 地图接口
%%%----------------------------------------------------------------------

-module(map_api).

-include("common.hrl").
-include("record.hrl").

-export([get_map_process_name/2]).


%% @doc 获取地图进程名
get_map_process_name(MapID, MapIndexID) ->
    util:to_atom(lists:concat(["map_", MapID, "_", MapIndexID])).
