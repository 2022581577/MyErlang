%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : acceptor supervisor
%%%----------------------------------------------------------------------

-module(tcp_acceptor_sup).
-author('kongqingquan <kqqsysu@gmail.com>').
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-include("common.hrl").

start_link() ->
    supervisor:start_link({local,?MODULE}, ?MODULE, []).

init([]) ->
    ?INFO("+++++++++++++ OK +++++++++",[]),
    {ok, {{simple_one_for_one, 10, 10},
          [{tcp_acceptor, {tcp_acceptor, start_link, []},
            transient, brutal_kill, worker, [tcp_acceptor]}]}}.
