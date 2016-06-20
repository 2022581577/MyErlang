%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.6.18
%%% @desc   : 主 supervisor
%%%----------------------------------------------------------------------

-module(server_sup).
-behaviour(supervisor).

-define(SRV_SUPERVISOR(Name),
    {
        util:to_atom(util:to_list(Name) ++ "_sup"),
        {srv_sup, start_link, [Name]},
        transient,
        infinity,
        supervisor,
        [srv_sup]
    }).

-export([start_link/0]).
-export([start_child/1]).
-export([start_child/2]).
-export([start_child/3]).
-export([start_sup_child/1]).
-export([init/1]).

start_link() ->
    {ok, Sup} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    {ok, Sup}.

start_child(Mod) -> 
    start_child(Mod, []).
start_child(Mod, Args) ->
    start_child(Mod, Mod, Args).
start_child(ID, Mod, Args) ->
    supervisor:start_child(?MODULE,
                           {
                               ID,
                               {Mod, start_link, Args},
                               transient,
                               5000,
                               worker,
                               [Mod]
                           }).

start_sup_child(SrvSupList) when is_list(SrvSupList) ->
    [start_sup_child(SrvSup) || SrvSup <- SrvSupList],
    ok;
start_sup_child(SrvSup) ->
    supervisor:start_child(?MODULE, ?SRV_SUPERVISOR(SrvSup)).

init([]) -> 
    {ok, {{one_for_one, 3, 10}, []}}.