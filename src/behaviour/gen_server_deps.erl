%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   : behaviour_gen_server后续需要根据不同模块处理的一些事件
%%%------------------------------------------------------------------------

-module(gen_server_deps).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([deps_action/2]).
-export([]).
-export([]).
-export([]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
deps_action(srv_user, User) ->
    {ok, User1} = srv_user:after_routine(User),
    {ok, User1};
deps_action(_, State) ->
    {ok, State}.

%% ========================================================================
%% Local functions
%% ========================================================================

