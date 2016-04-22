%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.6.18
%%% @desc   : listener supervisor
%%%           init tcp_listen and tcp_accetpor_sup
%%%----------------------------------------------------------------------

-module(tcp_listener_sup).
-behaviour(supervisor).

-export([start/4]).

-export([start_link/3
        ,init/1]).

start(Sup, IP, Port, TcpOpt) ->
    ChildSpec = 
        {?MODULE
         ,{?MODULE, start_link, [IP, Port, TcpOpt]}
         ,transient
         ,infinity
         ,supervisor
         ,[?MODULE]},
    {ok, _} = supervisor:start_child(Sup, ChildSpec),
    ok. 

start_link(IP, Port, TcpOpt) ->
    supervisor:start_link({local,?MODULE}, ?MODULE, {IP, Port, TcpOpt}).

init({IP, Port, TcpOpt}) ->
    %% tcp_acceptor_sup需要在tcp_listener之前开启，tcp_listener有用到tcp_acceptor_sup
    ChildSpec1 = 
        {tcp_acceptor_sup
         ,{tcp_acceptor_sup, start_link, []}
         ,transient
         ,infinity
         ,supervisor
         ,[tcp_acceptor_sup]},
    ChildSpec2 =    %% 监听游戏主端口
        {tcp_listener_main
         ,{tcp_listener, start_link, [IP, Port, TcpOpt]}
         ,transient
         ,16#ffffffff
         ,worker
         ,[tcp_listener]},
    ChildSpec3 =    %% 监听地图端口
        {tcp_listener_map
         ,{tcp_listener, start_link, [IP, Port + 1, TcpOpt]}
         ,transient
         ,16#ffffffff
         ,worker
         ,[tcp_listener]},
    {ok, {{one_for_all, 10, 10}, [ChildSpec1, ChildSpec2, ChildSpec3]}}.
