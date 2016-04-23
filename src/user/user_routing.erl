%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.04.22
%%% @desc   : 玩家数据加载
%%%----------------------------------------------------------------------

-module(user_routing).
-include("common.hrl").
-include("record.hrl").

-export([routing/3]).

routing(User, Cmd, Data) ->
    case Cmd div 1000 of
        11 ->
            pp_user:handle(User, Data);
        _ ->
            ?WARNING("No Hnadle User:~w, Cmd:~w, Data:~w",[User, Cmd, Data]),
            srv_user:cast_stop(self(), routing_cmd),
            {ok, User}
    end.

