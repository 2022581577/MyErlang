%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : gen_server 自定义模板
%%%----------------------------------------------------------------------

-module(gen_server2).
-author('kongqingquan <kqqsysu@gmail.com>').
-behaviour(gen_server).
-compile(inline).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([start/3,start/4,start_link/3,start_link/4]).
-export([stop/1,sync_stop/1,cast/2,call/2,sync_apply/2,i/1,p/1,sync_mfa/4,sync_status/4]).		                    %% call 接口
-export([apply/2,status_apply/2,mfa_apply/4,mfa_status/4]).	%% cast接口

-include("common.hrl").

-define(CALLBACK_MODULE,callback_module).

%%%=========================================================================
%%%  API
%%%=========================================================================

-callback do_init(Args :: term()) ->
    {ok, State :: term()} | {ok, State :: term(), timeout() | hibernate} |
    {stop, Reason :: term()} | ignore.
-callback do_call(Request :: term(), From :: {pid(), Tag :: term()},
                      State :: term()) ->
    {reply, Reply :: term(), NewState :: term()} |
    {reply, Reply :: term(), NewState :: term(), timeout() | hibernate} |
    {noreply, NewState :: term()} |
    {noreply, NewState :: term(), timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: term()} |
    {stop, Reason :: term(), NewState :: term()}.
-callback do_cast(Request :: term(), State :: term()) ->
    {noreply, NewState :: term()} |
    {noreply, NewState :: term(), timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: term()}.
-callback do_info(Info :: timeout() | term(), State :: term()) ->
    {noreply, NewState :: term()} |
    {noreply, NewState :: term(), timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: term()}.
-callback do_terminate(Reason :: (normal | shutdown | {shutdown, term()} |
                               term()),
                    State :: term()) ->
    term().


start(Mod,Args,Otps) ->
    gen_server:start(?MODULE, [Mod,Args], Otps).
start(Name,Mod,Args,Otps) ->
    gen_server:start(Name,?MODULE, [Mod,Args], Otps).

start_link(Mod,Args,Otps) ->
    gen_server:start_link(?MODULE, [Mod,Args], Otps).
start_link(Name,Mod,Args,Otps) ->
    gen_server:start_link(Name,?MODULE, [Mod,Args], Otps).

init([Mod,Args]) ->
    try
        put(?CALLBACK_MODULE,Mod),
		Mod:do_init(Args)
	catch 
		_:Reason ->
			?WARNING2("start ~w fail,Reason:~w",[Mod,Reason]),
            util:sleep(1000),
            start_fail
    end.

handle_call(Info, From, State) ->
    try 
		do_call(Info, From, State) 
	catch
		_:Reason ->
            ?WARNING2("~w error reason of do_call,Reason:~w,From:~w,Info:~w", [get_callback_mod(), Reason,From,Info]),
		    {reply, ok, State}
    end.

handle_cast(Info, State) ->
    try 
		do_cast(Info, State) 
	catch
		_:Reason ->
            ?WARNING2("~w error reason of do_cast,Reason:~w,Info:~w", [get_callback_mod(), Reason,Info]),
			{noreply, State}
    end.

handle_info(Info, State) ->
    try 
		do_info(Info, State) 
	catch
		_:Reason ->
            ?WARNING2("~w error reason of do_info,Reason:~w,Info:~w", [get_callback_mod(), Reason,Info]),
		 	{noreply, State}
    end.

terminate(Reason, State) ->
    Mod = get_callback_mod(),
	io:format("~w stop...",[Mod]),
    Mod:do_terminate(Reason,State).

code_change(_OldVsn, State, _Extra) -> 
	{ok, State}.
	
do_call({apply,Fun},_From,State) ->
	Reply = Fun(),
	{reply,Reply,State};

do_call({mfa_apply,Mod,Fun,Args},_From,State) when Mod =/= os ->
	Reply = erlang:apply(Mod,Fun,Args),
	{reply,Reply,State};	

do_call({mfa_status,Mod,Fun,Args},_From,State) when Mod =/= os ->
	case erlang:apply(Mod,Fun,[State | Args]) of
        {ok, Reply, NewState} ->
            {reply,Reply,NewState};
        Reply ->
        	{reply,Reply,State}
    end;

do_call(get_status,_From,State) ->
	{reply,State,State};
	
do_call(stop,_From,State) ->
	io:format("SYNC STOP"),
	{stop,normal,ok,State};

do_call(Info, From, State) ->
    Mod = get_callback_mod(),
    Mod:do_call(Info,From,State).

do_cast({mfa_apply,Mod,Fun,Args},State) when Mod =/= os ->
	erlang:apply(Mod,Fun,Args),
	{noreply,State};	

do_cast({mfa_status,Mod,Fun,Args},State) when Mod =/= os ->
	case erlang:apply(Mod,Fun,[State | Args]) of
		{ok,NewState} ->
			{noreply,NewState};
		_ ->
			{noreply,State}
	end;	

do_cast({apply,Fun},State) ->
	Fun(),
	{noreply,State};

do_cast({status_apply,Fun},State) ->
	case Fun(State) of
		{ok,NewState} ->
			{noreply,NewState};
		_ ->
			{noreply,State}
	end;	

do_cast(stop,State) ->
	{stop,normal,State};
	
do_cast(Info, State) ->
    Mod = get_callback_mod(),
    Mod:do_cast(Info,State).

do_info({mfa_apply,Mod,Fun,Args},State) when Mod =/= os ->
	erlang:apply(Mod,Fun,Args),
	{noreply,State};	

do_info(stop,State) ->
	{stop,normal,State};

do_info(Info, State) -> 
    Mod = get_callback_mod(),
    Mod:do_info(Info,State).
	
get_callback_mod() ->
    get(?CALLBACK_MODULE).


%% @doc cast 接口调用
cast(Pid,Msg) ->
	gen_server:cast(Pid,Msg).
call(Pid,Msg) ->
	gen_server:call(Pid,Msg).

%% @doc 停止进程 cast 方式
stop(Pid) ->
	cast(Pid,stop).
	
%% @doc 同步停止进程
sync_stop(Pid) ->
	call(Pid,stop).

%% @doc 函数调用
sync_apply(Pid,Fun) ->
	call(Pid,{apply,Fun}).

%% @doc MFA函数调用
sync_mfa(Pid,Mod,Fun,Args) ->
	call(Pid,{mfa_apply,Mod,Fun,Args}).
sync_status(Pid,Mod,Fun,Args) ->
    call(Pid,{mfa_status,Mod,Fun,Args}).

%% @doc fun 调用
apply(Pid,Fun) ->
	cast(Pid,{apply,Fun}).
%% @doc Fun(State)函数调用 State,更新函数修改后的Status
status_apply(Pid,Fun) ->
	cast(Pid,{status_apply,Fun}).
%% @doc MFA函数调用
mfa_apply(Pid,Mod,Fun,Args) ->
	cast(Pid,{mfa_apply,Mod,Fun,Args}).
%% @doc MFA + State 函数调用 State 将加在 Args前面调用,更新函数修改后的Status
mfa_status(Pid,Mod,Fun,Args) ->
	cast(Pid,{mfa_status,Mod,Fun,Args}).

%% @doc 调试接口,获取状态
i(Pid) ->
	call(Pid,get_status).
p(Pid) ->
	case i(Pid) of
		undefined ->
			undefined;
		State ->
			io:format("~p~n",[lib_record:fields_value(State)])
	end.
