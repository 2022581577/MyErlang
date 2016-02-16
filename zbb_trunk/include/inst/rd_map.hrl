-ifndef(RD_MAP_HRL).
-define(RD_MAP_HRL, "rd_map.hrl").


%% 地图地图信息
-record(map_info, {map_inst_id          %% {map_id, map_index_id}
                   ,map_id
                   ,map_index_id
                   ,map_pid = none
                   ,count = 0              %% 地图人数
                }). 

%% 地图装备
-record(map, {
             map_id
             ,map_index_id
             ,map_type
             ,map_sub_type
             ,user_count = 0         %%  场景玩家数
             ,create_time = 0        %%  地图创建时间(ms)
             ,aoi_map                %%  场景AOI数据
             ,loop_count = 0         %%  地图当前帧
             ,loop_time = 0          %%  当前帧时间
             ,last_loop_count = 0    %%  上次同步时的帧数
             ,last_user_count = 0    %%  上次同步时的场景玩家数
             ,ai_mon_list = []       %%  进入AI行为的怪物实例ID列表
             ,loop_user_list = []    %%  需要帧处理的玩家ID列表
             ,create_mon_list = []   %%  要创建的怪物列表
             ,block_list = []        %%  阻挡区[#polygon{},....]
             ,interval_timer         %%  map timer:当怪物进入AI行为或玩家有BUFF效果时有效
             ,mon_dict = dict:new()
             ,user_dict = dict:new()
             ,drop_dict = dict:new()
             ,mon_seq = 1            %%  怪物实例ID最大值
             ,parent_pid = undefined %%  父进程(副本进程/活动进程)
             ,dup = undefined
             ,ai_flag = 0            %%  0-未激活AI 1-已激活AI
             ,quit_timer             %%  xx毫秒退出地图的TIMER
             ,state = 0              %%  ?MAP_STATE_QUIT
             ,team_info = []
             ,map_refresh
             ,chest_info = []
         }).


-endif.
