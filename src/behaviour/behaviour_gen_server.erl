%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2013.06.15.
%%% @desc   : gen_server 自定义模板
%%%----------------------------------------------------------------------

-module(behaviour_gen_server).
-behaviour(gen_server).
-compile(inline).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([start/3,start/4,start_link/3,start_link/4]).

%% info接口
-export([info/2
        ,info/4
        ,state_info/4]).
%% cast接口
-export([cast_stop/1
        ,cast/2
        ,cast_apply/4
        ,cast_state_apply/4]).
%% call接口
-export([call_stop/1
        ,call/2
        ,call_apply/4
        ,call_state_apply/4
        ,i/1
        ,p/1]).

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
			?ERROR("start ~w fail,Reason:~w",[Mod,Reason]),
            util:sleep(1000),
            start_fail
    end.

handle_call(Info, From, State) ->
    try 
		do_call(Info, From, State) 
	catch
		_:Reason ->
            ?ERROR("~w error reason of do_call,Reason:~w,From:~w,Info:~w", [get_callback_mod(), Reason,From,Info]),
		    {reply, ok, State}
    end.

handle_cast(Info, State) ->
    try 
		do_cast(Info, State) 
	catch
		_:Reason ->
            ?ERROR("~w error reason of do_cast,Reason:~w,Info:~w", [get_callback_mod(), Reason,Info]),
			{noreply, State}
    end.

handle_info(Info, State) ->
    try 
		do_info(Info, State) 
	catch
		_:Reason ->
            ?ERROR("~w error reason of do_info,Reason:~w,Info:~w", [get_callback_mod(), Reason,Info]),
		 	{noreply, State}
    end.

terminate(Reason, State) ->
    Mod = get_callback_mod(),
	io:format("~w stop...",[Mod]),
    Mod:do_terminate(Reason,State).

code_change(_OldVsn, State, _Extra) -> 
	{ok, State}.
	

do_call({apply, M, F, A}, _From, State) when M =/= os ->
    case 
        case M of
            undefined ->
                erlang:apply(F, A);
            _ ->
                erlang:apply(M, F, A)
        end 
    of
        {ok, Reply} ->
            {reply, Reply, State};
        Reply ->     
            {reply, Reply, State}
    end;

do_call({state_apply, M, F, A}, _From, State) when M =/= os ->
    case 
        case M of
            undefined ->
                erlang:apply(F, [State | A]);
            _ ->
                erlang:apply(M, F, [State | A])
        end 
    of
        {ok, Reply, NewState} ->   
            Mod = get_callback_mod(),
            {ok, NewState1} = 
                behaviour_support:behaviour_gen_server_state(Mod, NewState),
            {reply, Reply, NewState1};
        {ok, Reply} ->              
            {reply, Reply, State};
        Reply ->
            {reply, Reply, State}
    end;

do_call(get_state,_From,State) ->
	{reply,State,State};
	
do_call(stop,_From,State) ->
	{stop,normal,ok,State};

do_call(Info, From, State) ->
    Mod = get_callback_mod(),
    Mod:do_call(Info,From,State).


do_cast({apply, M, F, A}, State) when M =/= os ->
    case M of
        undefined ->
            erlang:apply(F, A);
        _ ->
            erlang:apply(M, F, A)
    end,
    {noreply, State};

do_cast({state_apply, M, F, A}, State) when M =/= os ->
    case 
        case M of
            undefined ->
                erlang:apply(F, [State | A]);
            _ ->
                erlang:apply(M, F, [State | A])
        end 
    of
        {ok, NewState} ->
            Mod = get_callback_mod(),
            {ok, NewState1} = 
                behaviour_support:behaviour_gen_server_state(Mod, NewState),
            {noreply, NewState1};
        _ ->
            {noreply, State}
	end;	

do_cast(stop,State) ->
	{stop,normal,State};
	
do_cast(Info, State) ->
    Mod = get_callback_mod(),
    Mod:do_cast(Info,State).


do_info({apply, M, F, A}, State) when M =/= os ->
    case M of
        undefined ->
            erlang:apply(F, A);
        _ ->
            erlang:apply(M, F, A)
    end,
    {noreply, State};

do_info({state_apply, M, F, A}, State) when M =/= os ->
    case 
        case M of
            undefined ->
                erlang:apply(F, [State | A]);
            _ ->
                erlang:apply(M, F, [State | A])
        end 
    of
        {ok, NewState} ->
            Mod = get_callback_mod(),
            {ok, NewState1} = 
                behaviour_support:behaviour_gen_server_state(Mod, NewState),
            {noreply, NewState1};
        _ ->
            {noreply, State}
	end;	

do_info(stop,State) ->
	{stop,normal,State};

do_info(Info, State) -> 
    Mod = get_callback_mod(),
    Mod:do_info(Info,State).
	
get_callback_mod() ->
    get(?CALLBACK_MODULE).


%% @doc info接口调用
state_info(Pid, M, F, A) ->
    Pid ! {state_apply, M, F, A}.
info(Pid, M, F, A) ->
    Pid ! {apply, M, F, A}.
info(Pid, Msg) ->
	Pid ! Msg.

%% @doc cast 接口调用
cast_state_apply(Pid, M, F, A) ->
    cast(Pid,{state_apply, M, F, A}).
cast_apply(Pid, M, F, A) ->
    cast(Pid,{apply, M, F, A}).
cast(Pid,Msg) ->
	gen_server:cast(Pid,Msg).

%% @doc call 接口调用
call_state_apply(Pid, M, F, A) ->
    call(Pid, {state_apply, M, F, A}).
call_apply(Pid, M, F, A) ->
    call(Pid, {apply, M, F, A}).
call(Pid,Msg) ->
	gen_server:call(Pid,Msg).

%% @doc 停止进程 cast 方式
cast_stop(Pid) ->
	cast(Pid,stop).
	
%% @doc 同步停止进程
call_stop(Pid) ->
	call(Pid,stop).


%% @doc 调试接口,获取状态
i(Pid) ->
	call(Pid, get_state).
p(Pid) ->
	case i(Pid) of
		undefined ->
			undefined;
		State ->
			io:format("~p~n",[lib_record:fields_value(State)])
	end.
