%%%---------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2016.01.04.
%%% @desc   : 节点信息接口
%%%----------------------------------------------------------------------
-module(node_interface).
-include("common.hrl").

-export([status/0
        ,set_status/1
        ,set_server_starting/0
        ,set_server_running/0
        ,set_server_stoping/0]).

status()->
    try
        ?GLOBAL_DATA_RAM:get(?GAME_STATUS)
    catch
        _:_ ->
            ?GAME_STATUS_ERROR
    end.

set_status(Status) ->
    ?GLOBAL_DATA_RAM:set(?GAME_STATUS,Status).

set_server_starting() ->
    set_status(?GAME_STATUS_STARTING).

set_server_running()->
    set_status(?GAME_STATUS_RUNNING).

set_server_stoping()->
    set_status(?GAME_STATUS_STOPING).
