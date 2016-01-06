%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : listner supervisor
%%%----------------------------------------------------------------------

-module(tcp_listener_sup).
-author('kongqingquan <kqqsysu@gmail.com>').
-behaviour(supervisor).

-export([start_link/3]).

-export([init/1]).


start_link(IPAddress, Port, SocketOpts) ->
    supervisor:start_link({local,?MODULE},?MODULE, {IPAddress, Port, SocketOpts}).

init({IPAddress, Port, SocketOpts}) ->
    {ok, {{one_for_all, 10, 10},
          [{tcp_acceptor_sup, {tcp_acceptor_sup, start_link, []},
            transient, infinity, supervisor, [tcp_acceptor_sup]},
           {tcp_listener, {tcp_listener, start_link,
                           [IPAddress, Port, SocketOpts]},
            transient, 16#ffffffff, worker, [tcp_listener]}]}}.
