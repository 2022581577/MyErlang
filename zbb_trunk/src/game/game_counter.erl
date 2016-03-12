%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.20
%%% @desc   : 计数器模块
%%%----------------------------------------------------------------------

-module(game_counter).
-author('zhongbinbin <binbinjnu@163.com>').
-include("common.hrl").

-export([init/0]).

-export([get_user_id/0
        ,get_map_index_id/1]).

%% ID宏定义
-define(COUNTER_USER_ID,counter_user_id).
-define(COUNTER_SYS_MAIL_ID, counter_sys_mail_id).
-define(COUNTER_NPC_ID, counter_npc_id).
-define(COUNTER_ITEM_ID, counter_item_id).
-define(COUNTER_SYS_NOTICE_ID, counter_sys_notice_id).
-define(COUNTER_GUILD_ID, counter_guild_id).
-define(COUNTER_MAIL_ID, counter_mail_id).
-define(COUNTER_TEAM_ID, counter_team_id).
-define(COUNTER_MAP_INDEX_ID, counter_map_index_id).

-define(COUNTER_COMMON_LIST, 
        [?COUNTER_NPC_ID
        ,?COUNTER_TEAM_ID
        ]).

%% {ID宏定义, db_table, db_id, bitN, bslN}
-define(COUNTER_SPECIAL_LIST, 
        [{?COUNTER_USER_ID, user, user_id, 64, 32}
        ,{?COUNTER_ITEM_ID, user_item, item_id, 64, 32}
        ,{?COUNTER_GUILD_ID, guild, id, 32, 18}]).


init() ->
    ets:new(?ETS_COUNTER,[{keypos,1},named_table,public,set,{read_concurrency,true}]),
    init_id(),
    ok.

init_id() ->
    [ets:insert(?ETS_COUNTER,{E, 0}) || E <- ?COUNTER_COMMON_LIST],
    init_special_id(),
    ok.

%% 初始化ID
init_special_id() ->
    [init_special_id(Type, DbTable, DBID, BitN, BslN) || {Type, DbTable, DBID, BitN, BslN} <- ?COUNTER_SPECIAL_LIST].
init_special_id(Type, DbTable, DBID, BitN, BslN) ->
    BaseMaxID = bit_move(BitN, BslN),
    Sql = io_lib:format("select max(~s) from ~s", [DBID, DbTable]),
    MaxID = 
        case edb_util:execute(Sql) of
            [[DbMaxID]] when is_integer(DbMaxID) ->   max(BaseMaxID, DbMaxID);
            _ ->        BaseMaxID
        end,
    ets:insert(?ETS_COUNTER, {Type, MaxID}),
    ok.

%% @doc 根据服务器唯一编号
bit_move(_BitN, BslN) ->
    GolbalServerID = ?CONFIG(global_server_id),
    (GolbalServerID - 1) bsl BslN.

%% @doc 获取玩家id，跟server_no有关
get_user_id() ->
    ets:update_counter(?ETS_COUNTER, ?COUNTER_USER_ID, 1).

%% @doc 根据map_id获取地图index_id
get_map_index_id(MapID) ->
    case ets:lookup(?ETS_COUNTER, {?COUNTER_MAP_INDEX_ID, MapID}) of
        [] ->   
            ets:insert(?ETS_COUNTER,{{?COUNTER_MAP_INDEX_ID, MapID}, 1}),
            1;
        _ ->
            ets:update_counter(?ETS_COUNTER, {?COUNTER_MAP_INDEX_ID, MapID}, 1)
    end.
