%% ETS定义
-ifndef(ETS_HRL).
-define(ETS_HRL,"ets.hrl").

-define(ETS_COUNTER,            ets_counter).           %% 计数器
-define(ETS_USER_ONLINE,        ets_user_online).       %% 玩家在线信息
-define(ETS_MAP_INFO,           ets_map_info).          %% 地图信息
-define(ETS_MAP_ID_LIST,        ets_map_id_list).       %% 地图id映射
-define(ETS_MAP_CONFIG,         ets_map_config).        %% 地图配置数据

%%% 内存数据库相关ets
%% 玩家相关
-define(ETS_USER,               ets_user).              %% 玩家数据的ets    #user{}
-define(ETS_ACCOUNT_INFO,       ets_account_info).      %% 玩家账号数据信息
-define(ETS_USER_ITEM,          ets_user_item).         %% 玩家道具数据的ets    {user_id, [#user_item{} | _]}
%% 公共数据
-define(ETS_GUILD,              ets_guild).             %% 公会数据的ets    #guild{}


-endif.
