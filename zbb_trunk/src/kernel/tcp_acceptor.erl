%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : accept 模块
%%%----------------------------------------------------------------------

-module(tcp_acceptor).
-author('kongqingquan <kqqsysu@gmail.com>').
-behaviour(gen_server).

-include("common.hrl").

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {sock, ref}).

%%--------------------------------------------------------------------

start_link(LSock) ->
    gen_server:start_link(?MODULE, LSock, []).

%%--------------------------------------------------------------------

init(LSock) ->
    ?INFO("+++++++++++ LSock:~w +++++++++++",[LSock]),
    gen_server:cast(self(), accept),
    {ok, #state{sock=LSock}}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(accept, State) ->
    accept(State);

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({inet_async, LSock, Ref, {ok, Sock}}, State = #state{sock=LSock, ref=Ref}) ->
    %% accept more
    %% ?INFO("Accept Sock:~w,Ip:~w",[Sock,inet:peername(Sock)]),
    case set_sockopt(LSock,Sock) of
        ok ->
            start_client(Sock);
        Error ->
            ?WARNING2("Accept Sock fail,Socket:~w,Error:~w",[Sock,Error])
    end,
    accept(State);

handle_info({inet_async, LSock, Ref, {error, closed}},State=#state{sock=LSock, ref=Ref}) ->
    %% It would be wrong to attempt to restart the acceptor when we
    %% know this will fail.
    ?WARNING("LSock Colsed:~w",[LSock]),
    {stop, normal, State};

handle_info({inet_async, LSock, Ref, {error, Reason}},State=#state{sock=LSock, ref=Ref}) ->
    ?WARNING("LSock Error SOcket:~w,Reason:~w",[LSock,Reason]),
    {noreply,State};
    %%{stop, {accept_failed, Reason}, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------

accept(State = #state{sock=LSock}) ->
    case prim_inet:async_accept(LSock, -1) of
        {ok, Ref} -> 
            {noreply, State#state{ref=Ref}};
        Error -> 
            ?WARNING2("accept fail,LSock:~w,Error:~w",[LSock,Error]),
            {stop, {cannot_accept, Error}, State}
    end.


set_sockopt(LSock, Sock) ->
    true = inet_db:register_socket(Sock, inet_tcp),
    case prim_inet:getopts(LSock, [active, nodelay, keepalive, delay_send, priority, tos]) of
        {ok, Opts} ->
            case prim_inet:setopts(Sock, Opts) of
                ok    -> ok;
                Error ->
                    ?WARNING2("set socket fail,Socket:~w,Error:~w",[Sock,Error]),
                    gen_tcp:close(Sock),
                    Error
            end;
        Error ->
            ?WARNING2("set socket fail,Socket:~w,Error:~w",[Sock,Error]),
            gen_tcp:close(Sock),
            Error
    end.

%% 开启客户端服务
start_client(Sock) ->
    {ok, Child} = supervisor:start_child(tcp_client_sup, []),
    ok = gen_tcp:controlling_process(Sock, Child),
    gen_server:cast(Child,{set_socket, Sock}).

