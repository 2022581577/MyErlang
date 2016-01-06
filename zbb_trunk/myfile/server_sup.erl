%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : 主 supervisor
%%%----------------------------------------------------------------------

-module(server_sup).
-author('kongqingquan <kqqsysu@gmail.com>').
-behaviour(supervisor).

-define(SUPERVISOR(Id, Name, Tag), {Id, {supervisor, start_link, [{local, Name}, ?MODULE, Tag]}, transient, infinity, supervisor, [?MODULE]}).
%% 启动监督树列表
-define(SUP_LIST,[
				  {user_sup, user},
				  {map_sup, map},
				  {send_sup, send},
                  {across_client_sup, across_client}
				  ]).	

-export([start_link/0, 
		 start_child/1, 
		 start_child/2,
		 start_child/3,
		 start_user/1,
		 start_map/1,
		 start_send/1,
         start_across_client/1,
	     init/1]).

start_link() ->
    {ok, Supervisor} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
	lists:foreach(fun({Name,Tag}) ->
					{ok, _} = supervisor:start_child(Supervisor, ?SUPERVISOR(Name, Name,Tag))
				  end,?SUP_LIST),
	{ok, Supervisor}.

start_child(Mod) -> 
	start_child(Mod, []).

start_child(Mod, Args) ->
    start_child(Mod,Mod,Args).
start_child(ID,Mod, Args) ->
	supervisor:start_child(?MODULE,
						   {ID, {Mod, start_link, Args}, transient,
							5000, worker, [Mod]}).

start_user(Args) ->
    supervisor:start_child(user_sup,Args).
start_map(Args) ->
    supervisor:start_child(map_sup,Args).
start_send(Args) ->
    supervisor:start_child(send_sup,Args).
start_across_client(Args) ->
    supervisor:start_child(across_client_sup,Args).

init([]) -> 
	{ok, {{one_for_one, 3, 10}, []}};
init(user) -> 
	{ok, {{simple_one_for_one, 3, 10},
			[{mod_user, {mod_user, start_link, []},temporary, 5000, worker, [mod_user]}]
		}};
init(map) -> 
	{ok, {{simple_one_for_one, 3, 10}, 
		  [{mod_map, {mod_map, start_link, []},temporary, 5000, worker, [mod_map]}]
		 }};
init(send) -> 
	{ok, {{simple_one_for_one, 3, 10}, 
		  [{mod_send, {mod_send, start_link, []},permanent, 5000, worker, [mod_send]}]
		 }};
init(across_client) -> 
	{ok, {{simple_one_for_one, 3, 10},
			[{mod_across_client, {mod_across_client, start_link, []},temporary, 5000, worker, [mod_across_client]}]
		}}.
