-module(fsm_lock).

-behaviour(gen_fsm).

-export([start_link/1
        ,init/1
        ,handle_event/3
        ,handle_sync_event/4
        ,handle_info/3
        ,terminate/3
        ,code_change/4
        ,locked/2
        ,open/2
    ]).

-export([button/1]).

button(Digit) ->
    gen_fsm:send_event(?MODULE, {button, Digit}).

start_link(Code) ->
    gen_fsm:start_link({local, ?MODULE}, ?MODULE, Code, []).

init(Code) ->
    {ok, locked, {[], Code}}.

handle_event(_Event, StateName, StateData) ->
    {next_state, StateName, StateData}.

handle_sync_event(_Event, _From, StateName, StateData) ->
    Reply = ok,
    {reply,Reply,StateName,StateData}.

handle_info(_Info, StateName, StateData) ->
    {next_state, StateName, StateData}.

terminate(_Reason, _StateName, _StateData) ->
    ok.

code_change(_OldVsn, StateName, StateData, _Extra) -> 
    {ok, StateName, StateData}.

locked({button, Digit}, {Sofar, Code}) ->
    io:format("Digit:~w, Sofar:~w, Code:~w~n", [Digit, Sofar, Code]),
    case [Digit | Sofar] of
        Code ->
            io:format("do unlock!~n"),
            {next_state, open, {[], Code}, 3000};
        InComplete when length(InComplete) < length(Code) ->
            io:format("InComplete:~w, Code:~w~n", [InComplete, Code]),
            {next_state, locked, {InComplete, Code}};
        _ ->
            {next_state, locked, {[], Code}}
    end.

open(timeout, State) ->
    io:format("do lock!~n"),
    {next_state, locked, State}.

