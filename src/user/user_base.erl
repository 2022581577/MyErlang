%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 五月 2016 15:14
%%%-------------------------------------------------------------------
-module(user_base).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([init/1]).
-export([loop/2]).
-export([logout/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
%% @doc 初始化加载
init(UserID) ->
    case game_db:get_user(UserID) of
        #user{} = User ->
            {ok, UserN} = user_action:init(User),
            {ok, UserN};
        _ ->
            ?FALSE
    end.

%% @doc 循环
loop(User, SumTime) ->
    {ok, UserN} = user_action:loop(User, SumTime),
    {ok, UserN}.


%% @doc 下线保存
logout(User) ->
    {ok, UserN} = user_action:save(User),
    {ok, UserN}.

%% ========================================================================
%% Local functions
%% ========================================================================

