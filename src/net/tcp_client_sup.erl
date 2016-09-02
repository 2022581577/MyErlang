%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.6.18
%%% @desc   : 客户端服务 spuervisor
%%%----------------------------------------------------------------------

-module(tcp_client_sup).

-behaviour(supervisor).

-export([start/2]).

-export([start_link/1
        ,init/1]).

start(Sup, ClientModule) ->
    ChildSpec = 
        {?MODULE
         ,{?MODULE, start_link, [ClientModule]}
         ,transient
         ,infinity
         ,supervisor
         ,[?MODULE]},
    {ok, _} = supervisor:start_child(Sup, ChildSpec),
    ok.

start_link(ClientModule) ->
    supervisor:start_link({local,?MODULE}, ?MODULE, [ClientModule]).

init([ClientModule]) ->
    ChildSpec = 
        {tcp_client
         ,{tcp_client, start_link, []}
         ,temporary
         ,brutal_kill
         ,worker
         ,[ClientModule]},
    {ok, {{simple_one_for_one, 10, 10}, [ChildSpec]}}.
