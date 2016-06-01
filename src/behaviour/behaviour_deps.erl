%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   : behaviour后续需要根据不同模块处理的一些事件
%%%------------------------------------------------------------------------

-module(behaviour_deps).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([behaviour_gen_server_state/2]).
-export([]).
-export([]).
-export([]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
behaviour_gen_server_state(srv_user, User) ->
    {ok, User1} = srv_user:after_routine(User),
    {ok, User1};
behaviour_gen_server_state(_, State) ->
    {ok, State}.

%% ========================================================================
%% Local functions
%% ========================================================================

