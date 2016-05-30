%%%---------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2016.01.04.
%%% @desc   : 节点信息接口
%%%----------------------------------------------------------------------
-module(game_node_interface).
-include("common.hrl").

-export([status/0
        ,set_status/1
        ,set_server_starting/0
        ,set_server_running/0
        ,set_server_stopping/0]).

status()->
    try
        global_data_ram:get(?GAME_STATUS)
    catch
        _:_ ->
            ?GAME_STATUS_ERROR
    end.

set_status(Status) ->
    global_data_ram:set(?GAME_STATUS,Status).

set_server_starting() ->
    set_status(?GAME_STATUS_STARTING).

set_server_running()->
    set_status(?GAME_STATUS_RUNNING).

set_server_stopping()->
    set_status(?GAME_STATUS_STOPPING).
