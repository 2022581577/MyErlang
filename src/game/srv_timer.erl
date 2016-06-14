-module(srv_timer).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
            now/0,
            now_seconds/0,
            now_milseconds/0,
            cpu_time/0,
            start_link/0,
            info/0,
            change_timer/1,
            reset_timer/0
        ]).

-define(ETS_TIMER, ets_timer).
-define(TIMER, timer).
-define(CLOCK, 100).

-record(timer_state, {diff = 0}).

now() -> 
	[{?TIMER, {Now, _}}] = ets:lookup(?ETS_TIMER, ?TIMER),
	Now.

now_seconds()->
	[{?TIMER, {Now, _}}] = ets:lookup(?ETS_TIMER, ?TIMER),
	{MegaSecs, Secs, _MicroSecs} = Now,	
	MegaSecs * 1000000 + Secs.

%毫秒
now_milseconds() ->
    {M, S, Ms} = erlang:timestamp(),
    (M * 1000000000000 + S * 1000000 + Ms) div 1000.

cpu_time() -> 
	[{?TIMER, {_, Wallclock_Time_Since_Last_Call}}] = ets:lookup(?ETS_TIMER, ?TIMER),
	Wallclock_Time_Since_Last_Call.

info() ->
	[
            ets:info(?ETS_TIMER),
            ets:tab2list(?ETS_TIMER)
    ].

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

change_timer(UnixTime) ->
    gen_server:cast(?MODULE, {change_timer, UnixTime}).

reset_timer() ->
    gen_server:cast(?MODULE, reset_timer).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	ets:new(?ETS_TIMER, [set, protected, named_table]),
	ets:insert(?ETS_TIMER, {?TIMER, {erlang:timestamp(), 0}}),
	erlang:send_after(?CLOCK, self(), {event, clock}),
    {ok, #timer_state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    {reply, State, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({change_timer, UnixTime}, State) ->
    {M, S, _MS} = erlang:timestamp(),
    Diff = UnixTime - M * 1000000 - S,
    {noreply, State#timer_state{diff = Diff}};

handle_cast(reset_timer, State) ->
    {noreply, State#timer_state{diff = 0}};

handle_cast(_Msg, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({event, clock}, #timer_state{diff = Diff} = State) ->
 	{_Total_Run_Time, Time_Since_Last_Call} = statistics(runtime),
	ets:insert(?ETS_TIMER, {?TIMER, {get_now(Diff), Time_Since_Last_Call}}),
	erlang:send_after(?CLOCK, self(), {event, clock}),
	{noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

get_now(Diff) ->
    {M, S, MS} = erlang:timestamp(),
    NewM = M + Diff div 1000000,
    NewS = S + Diff rem 1000000,
    {NewM, NewS, MS}.
