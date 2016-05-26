%% Author: Administrator
%% Created: 2012-12-13
%% Description: TODO: Add description to r
-module(game_reloader).

%%
%% Include files
%%
-include_lib("kernel/include/file.hrl").
-include("common.hrl").
%%
%% Exported Functions
%%
-export([
		 	reload_modules/1
			,all_changed/0
			,is_changed/1
			,reload/0
			,reload_2/0
%% 			,c/0
%% 			,c/1
		 ]).

%%
%% API Functions
%%
%% @spec reload_modules([atom()]) -> [{module, atom()} | {error, term()}]
%% @doc code:purge/1 and code:load_file/1 the given list of modules in order,
%%      return the results of code:load_file/1.
reload_modules(Modules) ->
    [begin code:purge(M), code:load_file(M) end || M <- Modules].

%% @spec all_changed() -> [atom()]
%% @doc Return a list of beam modules that have changed.
all_changed() ->
    [M || {M, Fn} <- code:all_loaded(), is_list(Fn), is_changed(M)].

%% @spec is_changed(atom()) -> boolean()
%% @doc true if the loaded module is a beam with a vsn attribute
%%      and does not match the on-disk beam file, returns false otherwise.
is_changed(M) ->
    try
        module_vsn(M:module_info()) =/= module_vsn(code:get_object_code(M))
    catch _:_ ->
            false
    end.

reload_2() ->
	[{last_version_time, LastVersionTime}] = ets:lookup(ets_global_param, last_version_time),
	io:format("LastVersionTime:~w~n", [LastVersionTime]),
	NowTime = stamp(),
	ets:insert(ets_global_param, {last_version_time, NowTime}),
	doit(LastVersionTime,NowTime),
	ok.
%% 	[reload(M) || M <- all_changed()].

reload() ->
	erlang:group_leader(erlang:whereis(user), self()),
	Modules = all_changed(),
	?INFO("all module:~p",[Modules]),
	[reload(Module) || Module <- Modules].

%%
%% Local Functions
%%
module_vsn({M, Beam, _Fn}) ->
    {ok, {M, Vsn}} = beam_lib:version(Beam),
    Vsn;
module_vsn(L) when is_list(L) ->
    {_, Attrs} = lists:keyfind(attributes, 1, L),
    {_, Vsn} = lists:keyfind(vsn, 1, Attrs),
    Vsn.

doit(From, To) ->
	io:format("From:~w, To:~w~n", [From, To]),
    [case file:read_file_info(Filename) of
         {ok, #file_info{mtime = Mtime}} when Mtime >= From, Mtime =< To ->
             reload(Module);
         {ok, _File} ->
             unmodified;
         {error, enoent} ->
             %% The Erlang compiler deletes existing .beam files if
             %% recompiling fails.  Maybe it's worth spitting out a
             %% warning here, but I'd want to limit it to just once.
             gone;
         {error, Reason} ->
             io:format("Error reading ~s's file info: ~p~n",[Filename, Reason]),
             error
     end || {Module, Filename} <- code:all_loaded(), is_list(Filename)].

reload(Module) ->
    ?INFO("Node:~w Reloading ~p ...", [node(), Module]),
    case code:soft_purge(Module) of
		true ->
		    case code:load_file(Module) of
		        {module, Module} ->
					?INFO("Node:~w,Reload:~p,ok~n", [node(), Module]),
                    if
                        Module=:=data_switch ->
                            cron:reload();
                        true -> ok
                    end,
		            case erlang:function_exported(Module, test, 0) of
		                true ->
		                    ?INFO(" - Calling ~p:test() ...", [Module]),
		                    case catch Module:test() of
		                        ok ->
		                            ?INFO("reload ~p ok.",[Module]);
		                        Reason ->
		                            ?WARNING("reload ~p ok but call test fail: ~p.", [Module,Reason])
		                    end;
		                false ->
		                    ?INFO("reload ~p ok.",[Module])
		            end;
		        {error, Reason} ->
		            ?WARNING("reload ~p fail: ~p.", [Module,Reason])
		    end;
		_ ->
			?WARNING("reload ~p fail: processes linger in it.~n", [Module])
	end.


stamp() ->
    erlang:localtime().

%% c() ->
%% 	Result = os:cmd("svn update ../../../docs/"),
%% 	io:format("~ts",[Result]),
%% 	{ok,L} = file:list_dir("../../../docs/" ++ [37197,32622,25968,25454] ++ "/erlang"),
%% 	c([ X|| X <- L, string:str(Result, X) > 0 ]),
%% 	{ok,LP} = file:list_dir("../../../docs/" ++ [37197,32622,25968,25454] ++ "/erlang_public"),
%% 	c_p( [X||X <- LP,  string:str(Result, X) > 0]).
%% 
%% c([]) ->
%% 	?DEBUG("finished",[]);
%% c([FileName|L])->
%% 	Source = "../../../docs/" ++ [37197,32622,25968,25454] ++ "/erlang/" ++ FileName,
%% 	Destination = "../src/data_cn/" ++ FileName,
%% 	file:copy(Source, Destination),
%% 	c:c(Destination, [debug_info,{i, "../include"},{outdir, "../ebin"}]),
%% 	?DEBUG("~s...ok",[FileName]),
%% 	c(L).
%% 
%% 
%% c_p([]) ->
%% 	?DEBUG("finished",[]);
%% c_p([FileName|L])->
%% 	Source = "../../../docs/" ++ [37197,32622,25968,25454] ++ "/erlang_public/" ++ FileName,
%% 	Destination = "../src/data/" ++ FileName,
%% 	file:copy(Source, Destination),
%% 	c:c(Destination, [debug_info,{i, "../include"},{outdir, "../ebin"}]),
%% 	?DEBUG("~s...ok",[FileName]),
%% 	c_p(L).
