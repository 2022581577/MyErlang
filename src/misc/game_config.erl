%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 
%%-----------------------------------------------------

-module(game_config).

-define(GAME_CONF, game_conf).
-define(GAME_CONF_FILE, "./config/game.config").

-export([init/0
        ,reload/0
        ,get_config/1
        ,get_config/2
        ,list_config/0]).

init() ->
    load_game_config().

reload() ->
    load_game_config().

get_config(Key) ->
    wg_dynamic_config:get(?GAME_CONF, Key).

get_config(Key, Default) ->
    wg_dynamic_config:get(?GAME_CONF, Key, Default).

list_config() ->
    wg_dynamic_config:list(?GAME_CONF).

load_game_config() ->
    case os:getenv("GAME_CONF_FILE") of
        false ->
            ConfigFile = ?GAME_CONF_FILE;
        ConfigFile ->
            ok
    end,
    {ok, List} = file:consult(ConfigFile),
    NewList = reset_list(List),
    wg_dynamic_config:compile_kv(?GAME_CONF, NewList),
    ok.

%% 重置列表，做合法性检查
reset_list(List) ->
    ServerType  = proplists:get_value(server_type, List),
    ServerID    = proplists:get_value(server_id, List),
    Platform    = proplists:get_value(platform, List),
    reset_list(ServerType, Platform, ServerID, List).
reset_list(ServerType, Platform, ServerID, List) ->
    case lists:keyfind(db_name, 1, List) of
        {db_name, _DBName} ->
            List;
        _ ->
            DBName = lists:concat([ServerType, "_", Platform, "_", ServerID]),
            lists:keystore(db_name, 1, List, {db_name, DBName})
    end.

