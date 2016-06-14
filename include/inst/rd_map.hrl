-ifndef(RD_MAP_HRL).
-define(RD_MAP_HRL, "rd_map.hrl").


%% 地图地图信息
-record(map_info, {map_inst_id          %% {map_id, map_index_id}
                   ,map_id
                   ,map_index_id
                   ,map_pid         = none
                   ,count           = 0              %% 地图人数
                }). 

%% 地图装备
-record(map, {map_id
             ,map_index_id
             ,map_type
             ,map_sub_type
             ,module
             ,user_count        = 0     %% 场景玩家数
             ,create_time       = 0     %% 地图创建时间(ms)
             ,longunixtime      = 0     %% 当前时间(ms)
             ,unixtime          = 0     %% 当前时间(s)
             ,last_active       = 0     %% 上次活跃时间(ms)
             ,loop_count        = 0     %% 地图当前帧
             ,loop_time         = 0     %% 当前帧时间
             ,aoi                       %% 场景AOI数据
             ,last_loop_count   = 0     %% 上次同步时的帧数
             ,last_user_count   = 0     %% 上次同步时的场景玩家数
             ,ai_mon_list       = []    %% 进入AI行为的怪物实例ID列表
             ,loop_user_list    = []    %% 需要帧处理的玩家ID列表
             ,create_mon_list   = []    %% 要创建的怪物列表
             ,block_list        = []    %% 阻挡区[#polygon{},....]
             ,interval_timer            %% map timer:当怪物进入AI行为或玩家有BUFF效果时有效
             ,user_dict         = dict:new()
             ,mon_dict          = dict:new()
             ,drop_dict         = dict:new()
             ,mon_seq           = 1     %% 怪物实例ID最大值
             ,parent_pid        = undefined %% 父进程(副本进程/活动进程)
             ,dup               = undefined
             ,ai_flag           = 0     %% 0-未激活AI 1-已激活AI
             ,quit_timer                %% xx毫秒退出地图的TIMER
             ,state             = 0     %% ?MAP_STATE_QUIT
             ,team_info         = []
             ,map_refresh
             ,chest_info        = []
         }).

%% 地图中玩家信息
-record(map_user, {user_id
                  ,user_pid
              }).

%% 由地图编辑器生成的数据
-record(tpl_map_config, {source_id                  %% 资源id，不同地图id，可能对应相同的地图资源
                        ,map_type
                        ,map_sub_type   = 0
                        ,map_name
                        ,min_level      = 1
                        ,width
                        ,height
                        ,relive_point   = []          %% 重生点 [{PosX,PosY},....]
                        ,mon_list       = []              %% 怪物列表 [{MonTplId,PosX,PosY},....]
                        ,dup_mon_list   = []          %% 副本怪物列表 [[{MonTplId,PosX,PosY},....],....]
                        ,door_list      = []             %% 传送门 [{DoorId,PosX,PosY,TargetX,TargetY},....]
                        ,npc_list       = []              %% npc列表 [{NpcId,PosX,PosY},....]
                        ,collect_list   = []          %% 采集列表 [{MonTplId,PosX,PosY},....]
                        ,col_num        = 0                %% 横线格子数
                        ,row_num        = 0                %% 纵向格子数
                    }).

%%% --------------- 地图网格信息相关 ---------------
%% 地图网格信息
-record(aoi, {top_left                  %% 左上角坐标
             ,bottom_right              %% 右下角坐标
             ,x_count                   %% x轴grid的数量
             ,y_count                   %% y轴grid的数量
             ,grid_dict = dict:new()    %% key={grid_index_x,grid_index_y} value= #aoi_grid{}
             }).
     
%% 大格子信息
-record(aoi_grid, {key                      
                  ,grid_index_x     = 0
                  ,grid_index_y     = 0
                  ,obj_user_list    = []   %% #aoi_obj{obj_type = ?AOI_OBJ_TYPE_USER}
                  ,obj_mon_list     = []    %% #aoi_obj{obj_type = ?AOI_OBJ_TYPE_MON}
              }).

%% 地图内对象信息
-record(aoi_obj, {id 
                 ,obj_type = 0               %% MAP_OBJ_TYPE_XX
                 ,pid
             }).
%%% --------------- 地图网格信息相关 ---------------

-endif.
