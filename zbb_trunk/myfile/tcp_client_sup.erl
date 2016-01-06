%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : 客户端服务 spuervisor
%%%----------------------------------------------------------------------

-module(tcp_client_sup).
-author('kongqingquan <kqqsysu@gmail.com>').
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).
start_link() ->
    supervisor:start_link({local,?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {{simple_one_for_one, 10, 10},
          [{mod_reader, {mod_reader,start_link,[]},
            temporary, brutal_kill, worker, [mod_reader]}]}}.
