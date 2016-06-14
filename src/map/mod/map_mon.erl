%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 六月 2016 11:06
%%%-------------------------------------------------------------------
-module(map_mon).
-behaviour(behaviour_map).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([init/1]).
-export([loop/1]).
-export([enter/1]).
-export([leave/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
%% @doc 初始化加载
init(Map) ->
    {ok, Map}.

%% @doc 循环
loop(Map) ->
    {ok, Map}.

%% @doc 进入场景
enter(Map) ->
    {ok, Map}.

%% @doc 离开场景
leave(Map) ->
    {ok, Map}.

%% ========================================================================
%% Local functions
%% ========================================================================

