%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.6.18
%%% @desc   : 客户端服务 spuervisor
%%%----------------------------------------------------------------------

-module(tcp_client_sup).

-behaviour(supervisor).

-export([start/1]).

-export([start_link/0
        ,init/1]).

start(Sup) ->
    ChildSpec = 
        {?MODULE
         ,{?MODULE, start_link, []}
         ,transient
         ,infinity
         ,supervisor
         ,[?MODULE]},
    {ok, _} = supervisor:start_child(Sup, ChildSpec),
    ok.

start_link() ->
    supervisor:start_link({local,?MODULE}, ?MODULE, []).

init([]) ->
    ChildSpec = 
        {srv_reader
         ,{srv_reader, start_link, []}
         ,temporary
         ,brutal_kill
         ,worker
         ,[srv_reader]},
    {ok, {{simple_one_for_one, 10, 10}, [ChildSpec]}}.
