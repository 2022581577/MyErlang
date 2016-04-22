%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.15.
%%% @desc   : listner 
%%%----------------------------------------------------------------------

-module(tcp_listener).
-author('zhongbinbin <binbinjnu@163.com>').
-behaviour(gen_server).

-include("common.hrl").

-export([start_link/3]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {sock}).


start_link(IPAddress, Port, SocketOpts) ->
    gen_server:start_link(?MODULE, {IPAddress, Port, SocketOpts}, []).

%%--------------------------------------------------------------------

init({IPAddress, Port, SocketOpts}) ->
    process_flag(trap_exit, true),  %% 需要在进程关闭时调用terminate来关闭LSock
    case gen_tcp:listen(Port, SocketOpts) of
        {ok, LSock} ->
            lists:foreach(fun (_) ->
                                 {ok, _APid} = supervisor:start_child(tcp_acceptor_sup, [LSock])
                          end,
                          lists:duplicate(10, dummy)),
            {ok, #state{sock = LSock}};
        {error, Reason} ->
            ?WARNING2("Star Listen Fail,Reason:~w",[Reason]),
            {stop, {cannot_listen, IPAddress, Port, Reason}}
    end.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(Reason, #state{sock=LSock}) ->
    ?WARNING("Socket:~w close,Reason:~w",[LSock,Reason]),
    gen_tcp:close(LSock),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
