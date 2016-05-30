%%%----------------------------------------------------------------------
%%% @Author: zhongbinbin
%%% @Create: 2015-5-20
%%% @desc   : global_data_disk 处理模块，数据自动定时保存到数据库
%%%----------------------------------------------------------------------

-module(global_data_disk).

-include("common.hrl").
-include("record.hrl").

-export([init/0,sync/0,stop/0]).
-export([list/0,get/1,get/2,set/2,del/1]).

-define(SYNC_INTERVAL, 15 * 60 * 1000).


init() ->
    game_db:load_all_value(global_data),
    timer:apply_interval(?SYNC_INTERVAL, global_data_disk, sync, []),
    ok.

list() ->
    ets:tab2list(?ETS_GLOBAL_DATA).

get(K) ->
    get(K, undefined).

get(K, Def) ->
    case ets:lookup(?ETS_GLOBAL_DATA, K) of
        [#global_data{global_key = K, value = V}] ->
            V;
        [] ->
            Def
    end.

set(K, V) ->
    ets:insert(?ETS_GLOBAL_DATA, #global_data{global_key = K, value = V, is_dirty = 1}).

del(K) ->
    game_db:del_value(?ETS_GLOBAL_DATA, K, util:term_to_bitstring(K)).

%% 同步
sync() ->
    try
        do_sync()
    catch
        _:Reason ->
            ?WARNING2("global_data sync fail,Reason:~w",[Reason])
    end.

%% 关服同步数据库
stop() ->
    try
        do_sync()
    catch
        _:Reason ->
            ?WARNING2("global_data sync fail,Reason:~w",[Reason]),
            fail
    end.

do_sync() ->
    EtsInfoList = list(),
    game_db:save_value(?UNDEFINED, EtsInfoList),
    ok.
