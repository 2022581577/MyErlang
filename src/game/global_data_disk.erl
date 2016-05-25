%%%----------------------------------------------------------------------
%%% @Author: zhongbinbin
%%% @Create: 2015-5-20
%%% @desc   : global_data_disk 处理模块，数据自动定时保存到数据库
%%%----------------------------------------------------------------------

-module(global_data_disk).
-define(TABLE, global_data_disk).

-export([init/0,sync/0,stop/0]).
-export([list/0,get/1,get/2,set/2,del/1]).

-define(SYNC_INTERVAL, 15 * 60 * 1000).

-include("common.hrl").

-record(global_data, {key, value, is_dirty = 0}).

init() ->
    ets:new(?TABLE, [{keypos, #global_data.key}, named_table, public, set, {read_concurrency, true}]),
    SysGlobalList = get_all(),
    ets:insert(?TABLE, SysGlobalList),
	%% 后台连移到Global模块处理
	timer:apply_interval(?SYNC_INTERVAL, global_data_disk, sync, []),
	ok.

list() ->
	ets:tab2list(?TABLE).

get(K) ->
	get(K,undefined).

get(K,Def) ->
	case ets:lookup(?TABLE,K) of
        [#global_data{key = K, value = V}] ->
			V;
		[] ->
			Def
	end.

del(K) ->
    ets:delete(?TABLE, K),  %% 删除ets
    edb_util:delete(global_data, [{global_key, util:term_to_bitstring(K)}]). %% 删除数据库

set(K,V) ->
    ets:insert(?TABLE, #global_data{key = K, value = V}).

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
    [edb_util:replace(
        global_data,
        [{global_key, util:term_to_bitstring(K)}, {global_value, util:term_to_bitstring(V)}]
    ) || #global_data{key = K, value = V, is_dirty = 1} <- EtsInfoList],
    ok.

%%% ------------------------------
%%%     数据库操作
%%% ------------------------------
%% @doc 获取所有数据
get_all() ->
    DbList = edb_util:get_all(global_data, [global_key, global_value], []),
    [#global_data{key = util:bitstring_to_term(Key), value = util:bitstring_to_term(Value)}
        || [Key, Value] <- DbList].
