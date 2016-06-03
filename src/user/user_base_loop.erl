%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 五月 2016 15:18
%%%-------------------------------------------------------------------
-module(user_base_loop).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([loop/2]).
-export([is_loop_time/2]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
%% @doc 主要是#user{}中的各个字段的循环处理
%%      包括最后存储
loop(User, SumTime) ->
    case is_loop_time(SumTime, ?TIMER_FIVE_MIN_SEC) of
        ?TRUE ->    %% 5分钟的循环
            {ok, UserN} = user_action:save(User),
            {ok, UserN};
        _ ->
            {ok, User}
    end.

%% @doc 是否在循环时间点上
is_loop_time(SumTime, LoopTime) ->
    SumTime rem LoopTime =:= 0.

%% ========================================================================
%% Local functions
%% ========================================================================

