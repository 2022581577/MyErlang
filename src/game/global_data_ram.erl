%%%----------------------------------------------------------------------
%%% @Author: zhongbinbin
%%% @Create: 2015-5-20
%%% @desc   : Key Value 处理模块，数据只保存在内存中
%%%----------------------------------------------------------------------

-module(global_data_ram).

-include("common.hrl").

-export([init/0]).
-export([list/0,get/1,get/2,set/2,del/1]).

-define(TABLE, global_data_ram).

init() ->
	ets:new(?TABLE,[{keypos,1} | ?ETS_OPT]),
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
    ets:delete(?TABLE, K).

set(K,V) ->
	ets:insert(?TABLE,{K,V}).

