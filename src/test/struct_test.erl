%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 七月 2016 17:12
%%%-------------------------------------------------------------------
-module(struct_test).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([test_in/1]).
-export([test_out/1]).
-export([test_store/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
%% 结果：N = 10000，  T1 = 16000， T2 = 0， T3 = 46000
%% 结果：N = 100000， T1 = 63000， T2 = 0， T3 = 577000
test_in(N) ->
    {T1, _} = timer:tc(fun() -> test_map_in(#{}, N) end),
    {T2, _} = timer:tc(fun() -> test_list_in([], N) end),
    {T3, _} = timer:tc(fun() -> test_dict_in(dict:new(), N) end),
    {T1, T2, T3}.

%% 结果：N = 10000，  T1 = 0，     T2 = 140000，   T3 = 0
%% 结果：N = 100000， T1 = 16000， T2 = 10936000， T3 = 31000
test_out(N) ->
    Map = test_map_in(#{}, N),
    {T1, _} = timer:tc(fun() -> test_map_out(Map, N) end),
    List = test_list_in([], N),
    {T2, _} = timer:tc(fun() -> test_list_out(List, N) end),
    Dict = test_dict_in(dict:new(), N),
    {T3, _} = timer:tc(fun() -> test_dict_out(Dict, N) end),
    {T1, T2, T3}.

%% 结果：N = 10000，  T1 = 15000， T2 = 1217000，   T3 = 0
%% 结果：N = 100000， T1 = 78000， T2 = 140011000， T3 = 765000
test_store(N) ->
    Map = test_map_in(#{}, N),
    {T1, _} = timer:tc(fun() -> test_map_store(Map, N) end),
    List = test_list_in([], N),
    {T2, _} = timer:tc(fun() -> test_list_store(List, N) end),
    Dict = test_dict_in(dict:new(), N),
    {T3, _} = timer:tc(fun() -> test_dict_store(Dict, N) end),
    {T1, T2, T3}.

%% ========================================================================
%% Local functions
%% ========================================================================
test_map_in(Map, N) when N > 0 ->
    test_map_in(maps:put(N, N, Map), N - 1);
test_map_in(Map, _) ->
    Map.

test_list_in(List, N) when N > 0 ->
    test_list_in([{N, N} | List], N - 1);
test_list_in(List, _) ->
    List.

test_dict_in(Dict, N) when N > 0 ->
    test_dict_in(dict:append(N, N, Dict), N - 1);
test_dict_in(Dict, _) ->
    Dict.

test_map_out(Map, M) when M > 0 ->
    maps:find(M, Map),
    test_map_out(Map, M - 1);
test_map_out(_, _) ->
    ok.

test_list_out(List, M) when M > 0 ->
    lists:keyfind(M, 1, List),
    test_list_out(List, M - 1);
test_list_out(_, _) ->
    ok.

test_dict_out(Dict, M) when M > 0 ->
    dict:find(M, Dict),
    test_dict_out(Dict, M - 1);
test_dict_out(_, _) ->
    ok.

test_map_store(Map, N) when N > 0 ->
    test_map_store(maps:put(N, N, Map), N - 1);
test_map_store(Map, _) ->
    Map.

test_list_store(List, N) when N > 0 ->
    test_list_store(lists:keystore(N, 1, List, {N, N}), N - 1);
test_list_store(List, _) ->
    List.

test_dict_store(Dict, N) when N > 0 ->
    test_dict_store(dict:store(N, N, Dict), N - 1);
test_dict_store(Dict, _) ->
    Dict.

test_map_fold(Map, M) when M > 0 ->
    maps:fold(fun(), Map),
    test_map_fold(Map, M - 1);
test_map_fold(_, _) ->
    ok.

test_list_out(List, M) when M > 0 ->
    lists:keyfind(M, 1, List),
    test_list_out(List, M - 1);
test_list_out(_, _) ->
    ok.

test_dict_out(Dict, M) when M > 0 ->
    dict:find(M, Dict),
    test_dict_out(Dict, M - 1);
test_dict_out(_, _) ->
    ok.