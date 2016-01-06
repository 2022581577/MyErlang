%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 
%%-----------------------------------------------------

-module(game_config).

-define(GAME_CONF, game_conf).
-define(GAME_CONFIG_FILE, "./config/game.config").

-export([init/0
        ,get_config/1
        ,get_config/2
        ,list_config/0]).

init() ->
    load_game_config().

get_config(Key) ->
    wg_dynamic_config:get(?GAME_CONF, Key).

get_config(Key, Default) ->
    wg_dynamic_config:get(?GAME_CONF, Key, Default).

list_config() ->
    wg_dynamic_config:list(?GAME_CONF).

load_game_config() ->
    case os:getenv("GAME_CONFIG_FILE") of
        false ->
            ConfigFile = ?GAME_CONFIG_FILE;
        ConfigFile ->
            ok
    end,
    {ok, List} = file:consult(ConfigFile),
    NewList = reset_list(List),
    wg_dynamic_config:compile_kv(?GAME_CONF, NewList),
    io:format("ListConfig:~p~n", [list_config()]),
    io:format("server_port:~p~n", [get_config(server_port)]),
    ok.

%% 重置列表，做合法性检查
reset_list(List) ->
    {server_id,ServerID} = lists:keyfind(server_id,1,List),
    {platform,Platform} = lists:keyfind(platform,1,List),
    reset_list(Platform,ServerID,List).
reset_list(Platform, ServerID, List) ->
    case lists:keyfind(db_name,1,List) of
        {db_name,DBName} ->
            lists:keystore(db_name,1,List,{db_name,util:to_list(DBName)});
        false ->
            DBName = lists:concat([Platform,"_",ServerID]),
            [{db_name,DBName} | List]
    end.

