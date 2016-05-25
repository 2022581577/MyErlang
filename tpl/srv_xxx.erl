%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   : 
%%% @desc   : 
%%%------------------------------------------------------------------------

-module(srv_xxx).
-behaviour(behaviour_gen_server).
-compile(inline).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([do_init/1
        ,do_call/3
        ,do_cast/2
        ,do_info/2
        ,do_terminate/2]).

-export([start_link/1]).

%% record and define
-record(state, {id}).

start_link([]) ->
    behaviour_gen_server:start_link(?MODULE, [], []).


do_init([]) ->
    {ok, #state{}}.


do_cast(Info, State) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
	{noreply, State}.


do_call(Info, _From, State) -> 
    ?WARNING("Not done do_call:~w",[Info]),
	{reply, ok, State}.

	
do_info(Info, State) -> 
    ?WARNING("Not done do_info:~w",[Info]),
	{noreply, State}.

do_terminate(Reason, _State) ->   
    ?INFO("terminate Reason:~w",[Reason]),
    ok.

