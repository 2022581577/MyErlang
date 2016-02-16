%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.15.
%%% @desc   : 控制模块
%%%----------------------------------------------------------------------

-module(game_ctl).
-author('zhongbinbin <binbinjnu@163.com>').

-export([start/0,
		 init/0,
		 process/1]).

-include("common.hrl").

%%-----------------------------
%% Module
%%-----------------------------

start() ->
    case init:get_plain_arguments() of
	[SNode | Args] ->
	    SNode1 = case string:tokens(SNode, "@") of
			 [_Node, _Server] ->
			     SNode;
			 _ ->
			     case net_kernel:longnames() of
				 true ->
				     SNode ++ "@" ++ inet_db:gethostname() ++
					 "." ++ inet_db:res_option(domain);
				 false ->
				     SNode ++ "@" ++ inet_db:gethostname();
				 _ ->
				     SNode
			     end
		     end,
	    Node = list_to_atom(SNode1),
	    Status = case rpc:call(Node, ?MODULE, process, [Args]) of
             {badrpc,nodedown} ->
                ?GAME_STATUS_NORUN;
			 {badrpc, _Reason} ->
			     %% ?PRINT("Failed RPC connection to the node ~p: ~p~n", [Node, Reason]),
			     %% TODO: show minimal start help
			     ?GAME_STATUS_BADRPC;
			 S ->
			     S
		     end,
	    halt(Status);
	_ ->
		?PRINT("~w Start fail...~n",[?MODULE]),
	    halt(?GAME_STATUS_USAGE)
    end.

init() ->
	ok.

%%-----------------------------
%% Process
%%-----------------------------

%% The commands status, stop and restart are defined here to ensure
%% they are usable even if ejabberd is completely stopped.
process(["status"]) ->
	node_interface:status();

process(["stop",_Time]) ->
    timer:apply_after(10,main,stop,[]),
    ?GAME_STATUS_SUCCESS;

process(["reload", "code"]) ->
    game_reloader:reload(),
    ?GAME_STATUS_SUCCESS;

process(["reload", "config"]) ->
    game_config:reload(),
    ?GAME_STATUS_SUCCESS;

process(["count"]) ->
    Count = user_online:count(),
    ?PRINT("~w~n",[Count]),
    Count;

%process(["version"]) ->
%    ?PRINT("Server:~p Client:~p~n",[?SERVER_VERSION,?CLIENT_VERSION]),
%    ?GAME_STATUS_SUCCESS;
%
%process(["switch_db"]) ->
%    erlang:group_leader(erlang:whereis(user),self()),
%    ?SYSLOG("Reload Config,Switch DB,ServerType:~s",[?CONFIG_SERVER_TYPE]),
%    game_config:reload(),
%    Res =
%    case ?CONFIG_SERVER_TYPE of
%        ?SERVER_TYPE_GAME ->
%            mongo_tool:switch_db();
%        ?SERVER_TYPE_LOG_SERVER ->
%            db:switch_db();
%        _ ->
%            ?SYSLOG("Switch DB Fail,No Config"),
%            false
%    end,
%    case Res of
%        true ->
%            ?GAME_STATUS_SUCCESS;
%        false ->
%            ?GAME_STATUS_ERROR
%    end;
%
%process(["check_db"]) ->
%    Res2 =
%    case ?CONFIG_SERVER_TYPE of
%        ?SERVER_TYPE_GAME ->
%            DbConfig = ?GLOBAL_DATA_RAM:get(db_config,?CONFIG(db_config)),
%            {Res, _Msg} = db_agent_test:test(),          %% 数据库链接状态
%            Res == 1;
%        ?SERVER_TYPE_LOG_SERVER ->
%            DbConfig = ?GLOBAL_DATA_RAM:get(db_config,{?CONFIG(db_host),?CONFIG(db_port)}),
%            db_util:check_db_state() /= false;
%        _ ->
%            DbConfig = undefined,
%            false
%    end,
%    DbName = ?GLOBAL_DATA_RAM:get(db_name,?CONFIG(db_name)),
%    ?PRINT("Host:~p,Name:~w,State:~w~n",[DbConfig,DbName,Res2]),
%    case Res2 of
%        true ->
%            ?GAME_STATUS_SUCCESS;
%        false ->
%            ?GAME_STATUS_ERROR
%    end;

process(Args) ->
	?PRINT("Process NOT done Args:~p~n",[Args]).

