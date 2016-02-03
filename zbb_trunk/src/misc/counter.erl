%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.20
%%% @desc   : 计数器模块
%%%----------------------------------------------------------------------

-module(counter).
-author('kongqingquan <kqqsysu@gmail.com>').
-include("common.hrl").

-export([init/0,
        get_base_id/0]).

%%-export([
%%         init_user_id/1,
%%         init_clear_all/0,
%%         get_user_id/0,
%%         get_sys_mail_id/0,
%%         get_item_id/0,
%%         get_npc_id/0,
%%         get_sys_notice_id/0,
%%         get_team_id/0,
%%         get_guild_id/0,
%%         get_chat_item_id/0,
%%         get_log_file_id/0,
%%         get_db_pool_id/0,
%%         get_mail_id/0,
%%         get_login_logout_id/0,
%%         get_user_increase/0
%%        ]).

%% ID宏定义
-define(COUNTER_USER_ID,counter_user_id).
-define(COUNTER_SYS_MAIL_ID, counter_sys_mail_id).
-define(COUNTER_NPC_ID, counter_npc_id).
-define(COUNTER_ITEM_ID, counter_item_id).
-define(COUNTER_SYS_NOTICE_ID, counter_sys_notice_id).
-define(COUNTER_GUILD_ID, counter_guild_id).
-define(COUNTER_CHAT_ITEM_ID, counter_chat_item_id).
-define(COUNTER_LOG_FILE_ID, counter_log_file_id).
-define(COUNTER_DB_POOL,counter_db_pool).
-define(COUNTER_MAIL_ID, counter_mail_id).
-define(COUNTER_LOGIN_LOGOUT_ID, counter_login_logout_id).
-define(COUNTER_USER_INCREACE, counter_user_increase).

init() ->
    ets:new(?ETS_COUNTER,[{keypos,1},named_table,public,set,{read_concurrency,true}]),
    init_val(),
    ok.

init_val() ->
    init_user_id(),

    %%ets:insert(?ETS_COUNTER,{?COUNTER_NPC_ID, 0}),
    %%ets:insert(?ETS_COUNTER,{?COUNTER_ITEM_ID, 0}),
    %%ets:insert(?ETS_COUNTER,{?COUNTER_TEAM_ID, 0}),
    %%ets:insert(?ETS_COUNTER,{?COUNTER_CHAT_ITEM_ID, 0}),
    %%ets:insert(?ETS_COUNTER,{?COUNTER_LOG_FILE_ID, 0}),
    %%%% 初始化系统邮件id
    %%init_sys_mail_id(), 
    %%%% 初始化物品id
    %%init_item_id(),
    %%%% 初始化系统公告id
    %%init_sys_notice_id(),
    %%%% 初始化帮派ID
    %%init_guild_id(),
    %%%% 初始化邮件id
    %%init_mail_id(),
    %%%% 初始化登陆登出日志id
    %%init_login_logout_id(),
    %%%% 初始化玩家自增
    %%init_user_increase(),
    ok.

%% 初始化玩家id，跟server_no有关
init_user_id() ->
    ServerNoIDList = edb_util:execute("select server_no, max(user_id) as id from user group by server_no"),
    [ets:insert(?ETS_COUNTER, {{?COUNTER_USER_ID, ServerNo}, MaxID}) || [ServerNo, MaxID] <- ServerNoIDList],
    ok.

%% @doc 获取玩家id，跟server_no有关
get_user_id(ServerNo) ->
    ets:update_counter(?ETS_COUNTER, {?COUNTER_USER_ID, server_no}, 1).


%%%% 玩家自增
%%init_user_increase() ->
%%    MaxID = ?GLOBAL_DATA_DISK:get(?COUNTER_USER_INCREACE, 0),
%%    ets:insert(?ETS_COUNTER, {?COUNTER_USER_INCREACE, MaxID}).
%%get_user_increase() ->
%%    MaxID = ets:update_counter(?ETS_COUNTER, ?COUNTER_USER_INCREACE, 1),
%%    ?GLOBAL_DATA_DISK:set(?COUNTER_USER_INCREACE, MaxID),
%%    MaxID.
%%
%%%% 玩家id
%%init_user_id(UserID) ->
%%    BaseUserID = get_base_id(),
%%    NewUserID = max(UserID,BaseUserID),
%%    ets:insert(?ETS_COUNTER,{?COUNTER_USER_ID,NewUserID}).
%%get_user_id() ->
%%    ets:update_counter(?ETS_COUNTER,?COUNTER_USER_ID,1).
%%
%%%% 系统邮件id
%%init_sys_mail_id() ->
%%    MaxID = ?GLOBAL_DATA_DISK:get(?COUNTER_SYS_MAIL_ID, 0),
%%    ets:insert(?ETS_COUNTER,{?COUNTER_SYS_MAIL_ID, MaxID}).
%%get_sys_mail_id() ->
%%    MaxID = ets:update_counter(?ETS_COUNTER,?COUNTER_SYS_MAIL_ID, 1),
%%    ?GLOBAL_DATA_DISK:set(?COUNTER_SYS_MAIL_ID, MaxID),
%%    MaxID.
%%
%%%% 帮派ID
%%init_guild_id() ->
%%    MaxID = ?GLOBAL_DATA_DISK:get(?COUNTER_GUILD_ID, 0),
%%    ets:insert(?ETS_COUNTER,{?COUNTER_GUILD_ID, MaxID}).
%%get_guild_id() ->
%%    MaxID = ets:update_counter(?ETS_COUNTER,?COUNTER_GUILD_ID, 1),
%%    ?GLOBAL_DATA_DISK:set(?COUNTER_GUILD_ID, MaxID),
%%    MaxID.
%%
%%%% 物品id
%%init_item_id() ->
%%    MaxID =
%%    case ?GLOBAL_DATA_DISK:get(?COUNTER_ITEM_ID, 0) of
%%        0 ->
%%            get_base_id();
%%        ID ->
%%            ID
%%    end,
%%    ets:insert(?ETS_COUNTER,{?COUNTER_ITEM_ID, MaxID}).
%%get_item_id() ->
%%    MaxID = ets:update_counter(?ETS_COUNTER, ?COUNTER_ITEM_ID, 1),
%%    ?GLOBAL_DATA_DISK:set(?COUNTER_ITEM_ID, MaxID),
%%    MaxID.
%%
%%%% 邮件id
%%init_mail_id() ->
%%    MaxID = ?GLOBAL_DATA_DISK:get(?COUNTER_MAIL_ID, 0),
%%    ets:insert(?ETS_COUNTER,{?COUNTER_MAIL_ID, MaxID}).
%%get_mail_id() ->
%%    MaxID = ets:update_counter(?ETS_COUNTER, ?COUNTER_MAIL_ID, 1),
%%    ?GLOBAL_DATA_DISK:set(?COUNTER_MAIL_ID, MaxID),
%%    MaxID.
%%
%%%% Login Logout日志id
%%init_login_logout_id() ->
%%    MaxID = ?GLOBAL_DATA_DISK:get(?COUNTER_LOGIN_LOGOUT_ID, 0),
%%    ets:insert(?ETS_COUNTER,{?COUNTER_LOGIN_LOGOUT_ID, MaxID}).
%%get_login_logout_id() ->
%%    MaxID = ets:update_counter(?ETS_COUNTER, ?COUNTER_LOGIN_LOGOUT_ID, 1),
%%    ?GLOBAL_DATA_DISK:set(?COUNTER_LOGIN_LOGOUT_ID, MaxID),
%%    MaxID.
%%
%%%% 后台系统公告id
%%init_sys_notice_id() ->
%%    MaxID =
%%    case ?GLOBAL_DATA_DISK:get(?COUNTER_SYS_NOTICE_ID, 0) of
%%        0 ->
%%            get_base_id();
%%        ID ->
%%            ID
%%    end,
%%    ets:insert(?ETS_COUNTER,{?COUNTER_SYS_NOTICE_ID, MaxID}).
%%get_sys_notice_id() ->
%%    MaxID = ets:update_counter(?ETS_COUNTER, ?COUNTER_SYS_NOTICE_ID, 1),
%%    ?GLOBAL_DATA_DISK:set(?COUNTER_SYS_NOTICE_ID, MaxID),
%%    MaxID.
%%
%%get_npc_id() ->
%%    ets:update_counter(?ETS_COUNTER,?COUNTER_NPC_ID,1).
%%
%%get_chat_item_id() ->
%%    ets:update_counter(?ETS_COUNTER,?COUNTER_CHAT_ITEM_ID,1).
%%
%%get_team_id() ->
%%    ets:update_counter(?ETS_COUNTER,?COUNTER_TEAM_ID,1).
%%
%%get_log_file_id() ->
%%    N = ets:update_counter(?ETS_COUNTER, ?COUNTER_LOG_FILE_ID, 1),
%%    N rem 10.
%%
%%%% @doc 根据平台、服务器获取玩家id、物品id等唯一id基数
%%%% id为64位，
%%get_base_id() ->
%%    #data_platform{platform_id = PlatformID} = data_platform:get(?CONFIG_PLATFORM),
%%    ServerID = ?CONFIG_SERVER_ID,
%%    PlatformNum = PlatformID bsl 46,
%%
%%    %% 合服标识
%%    MergerNum = 
%%    case ?CONFIG_PREFIX of
%%        x ->
%%            1 bsl 45;
%%        _ ->
%%            0
%%    end,
%%    ServerNum = ServerID bsl 32,
%%    ?INFO("base id PlatformNum:~w, ServerNum:~w", [PlatformNum, ServerNum]),
%%    PlatformNum + MergerNum + ServerNum.
%%    
%%get_db_pool_id() ->
%%    ets:update_counter(?ETS_COUNTER,?COUNTER_DB_POOL,1).
%%
