%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2015.6.18
%%% @desc   : 不同类型进程的主监考树
%%%----------------------------------------------------------------------

-module(srv_sup).
-behaviour(supervisor).

-export([start_link/1]).
-export([start_child/2]).
-export([init/1]).

start_link(Mod) ->
    Name = util:to_atom(util:to_list(Mod) ++ "_sup"),
    {ok, Sup} = supervisor:start_link({local, Name}, ?MODULE, Mod),
    {ok, Sup}.

start_child(Mod, Args) ->
    supervisor:start_child(Mod, Args).

init([Name, Mod, Modules]) ->
    {ok, {{simple_one_for_one, 3, 10},
            [{Name, {Mod, start_link, []},temporary, 5000, worker, Modules}]
        }};
init(Mod) ->
    init([Mod, Mod, [Mod]]).
