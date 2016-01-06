%%%----------------------------------------------------------------------
%%% @Author: zhongbinbin
%%% @Create: 2015-5-20
%%% @desc   : global_data_disk 处理模块，数据自动定时保存到数据库
%%%----------------------------------------------------------------------

-module(global_data_disk).
-define(TABLE, global_data_disk).

-export([init/0,sync/0,stop/0]).
-export([list/0,get/1,get/2,set/2,del/1]).

-define(SYNC_INTERVAL, 5 * 60 * 1000).

-include("common.hrl").

init() ->
    ets:new(?TABLE,[{keypos,1},named_table,public,set,{read_concurrency,true}]),
    DbInfoList = db_util:get_all(global_data, [key, val], []),
    ?WARNING("global_data_disk init, DbInfoList:~w", [DbInfoList]),
    [?GLOBAL_DATA_DISK:set(util:string_to_term(util:to_list(Key)), util:string_to_term(util:to_list(Val))) || [Key, Val] <- DbInfoList],
	%% 后台连移到Global模块处理
	timer:apply_interval(?SYNC_INTERVAL, global_data_disk, sync, []),
	ok.

list() ->
	ets:tab2list(?TABLE).

get(K) ->
	get(K,undefined).

get(K,Def) ->
	case ets:lookup(?TABLE,K) of
		[{K,V}] ->
			V;
		[] ->
			Def
	end.

del(K) ->
    ets:delete(?TABLE, K),
    db_util:delete(global_data, [{key, util:to_binary(util:term_to_string(K))}]).

set(K,V) ->
	ets:insert(?TABLE,{K,V}).

%% 同步dets
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
    [db_util:replace(global_data, [{key, util:to_binary(util:term_to_string(Key))}, {val, util:to_binary(util:term_to_string(Val))}]) || {Key, Val} <- EtsInfoList],
    ok.
