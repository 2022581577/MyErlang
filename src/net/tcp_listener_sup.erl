%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.6.18
%%% @desc   : listener supervisor
%%%           init tcp_listen and tcp_accetpor_sup
%%%----------------------------------------------------------------------

-module(tcp_listener_sup).
-behaviour(supervisor).

-define(TCP_LISTENER_NAME(Type),
    list_to_atom(atom_to_list(tcp_listener_) ++ atom_to_list(Type))).

-export([start/2]).

-export([start_link/1
        ,init/1]).

start(Sup, NetAddressL) ->
    ChildSpec = 
        {?MODULE
         ,{?MODULE, start_link, [NetAddressL]}
         ,transient
         ,infinity
         ,supervisor
         ,[?MODULE]},
    {ok, _} = supervisor:start_child(Sup, ChildSpec),
    ok. 

start_link(NetAddressL) ->
    supervisor:start_link({local,?MODULE}, ?MODULE, NetAddressL).

init(NetAddressL) ->
    %% tcp_acceptor_sup需要在tcp_listener之前开启，tcp_listener有用到tcp_acceptor_sup
    ChildSpec1 = 
        {tcp_acceptor_sup
         ,{tcp_acceptor_sup, start_link, []}
         ,transient
         ,infinity
         ,supervisor
         ,[tcp_acceptor_sup]},
    ListenerChildSpecL =
        [
            {?TCP_LISTENER_NAME(Type)
            ,{tcp_listener, start_link, [Type, IP, Port, TcpOpt]}
            ,transient
            ,16#ffffffff
            ,worker
            ,[tcp_listener]} || {Type, IP, Port, TcpOpt} <- NetAddressL
        ],
    {ok, {{one_for_all, 10, 10}, [ChildSpec1 | ListenerChildSpecL]}}.
