
%% 玩家在进程中的零时数据
-record(user_other, {pid
                    ,socket
    }).

%    ,map_pid
%    ,next_map_pid
%    ,map_inst_id                    %%  所在地图实例ID {map_id,line,index}
%    ,old_map_pos                    %%  {map_inst_id, pos_x, pos_y}  
%    ,attr_list = []                 %%  [{?ATTR_CHGTYPE, ATTR_LIST},....]
%    ,total_attr                     %%  #user_attr{}
%    ,passive_skill_list = []        %%  [{?ATTR_CHGTYPE, SKILL_LIST},....]
%    ,infant_state = 1               %%  0:未知  1:成年  2:登记但未成年 3未登记
%    ,real_stop_timer = undefined
%    ,revive_timer = undefined
%    ,login_state = 1                %%  0-等待重连 1-正常登陆 2-登录完成 3-重连登陆
%    ,misc_dict = dict:new()         %%  user_misc对应的字典
%    ,local_misc_dict = dict:new()   %%  内部字典
%    ,clothes_id = 0                 %%  衣服
%    ,weapon_id = 0                  %%  武器
%    ,weapon_stren = 0               %%  武器强化等级
%    ,stren_suit = 0                 %%  全身强化等级
%    ,is_transform = 0               %%  是否变身
%    ,team_pid                       %%  队伍进程PID
%    ,skill_info                     %%  技能信息
%    ,grow_dict = dict:new()         %%  成长系统
%    ,vestment_info                  %%  圣衣系统
%    ,vestment_id = 0                %%  圣衣ID
%    ,grow_shape = []                %%  成长系统外形
%    ,escort                         %%  护送
%    ,battle_time = 0                %%  pvp战斗时间
%    ,pve_battle_time = 0            %%  pve战斗时间
%    ,loop_task = []                 %%  日常任务    [{Type,#user_loop_task{}},....]
%    ,msg_list = []                  %%  未处理消息列表  [#user_msg{},....]
%    ,title_dict = dict:new()        %%  称号信息
%    ,title_list = []                %%  所选称号列表
%    ,honor_level = 0                %%  头衔等级
%    ,dup_tpl_id = 0                 %%  所处的副本模板ID
%    ,camp = 0 
%    ,fashion_weapon_id = 0          %%  时装武器ID
%    ,fashion_clothes_id = 0         %%  时装衣服ID
%    ,dup_room = {0,0}               %%  多人副本房间信息{RoomId,CreateUserId}
%    ,temp_hp = 0 
%    ,dup_exp = {0,0}                %%  {金币鼓舞次数,钻石鼓舞次数}
%    ,team_id = 0                    %%  挂机队伍
%    ,team_member_num = 0 
%    ,team_member_ids = []
%    ,meditation = 0                 %% 冥想状态
%    ,buff_list = []                 %% 玩家buff 经验药水等
%    ,statistic_dict = dict:new()    %% 玩家统计类数据
%    ,server_no_string               %% 玩家服务器
%    ,logout_code = 0                %% 玩家离线code
%    ,logout_reason = ""             %% 玩家离线reason
%    ,activity_list = []             %% 玩家活动数据
%    ,platform_info = #user_platform{}
%    ,platform_login_param = #platform_login_param{}
%    ,battle_3v3 = #user_battle_3v3{}
%    ,is_hook = 0                    %% 0 否 1 挂机状态
%    ,hook = none
%    ,heart_time = 0                 %% 13100 初始化 60001 更新


%% 需要存库的数据
-record(user, {user_id = 0
              ,name = <<>>
              ,acc_name = <<>>
              ,server_no = 1
              ,user_type = 0                  %% 玩家类型:0、普通玩家，1、新手指导员，2、GM
              ,ip = ""

              ,reg_time = 0
              ,is_online = 0 
              ,online_time = 0                %%  在线时间
              ,total_online_time = 0          %%  累计在线时间
              ,login_time = 0 
              ,last_online_time = 0 
              ,last_update_time = 0           %%  save db time

              ,recharge_gold = 0    
              ,gold = 0 
              ,bind_gold = 0 
              ,gm_gold = 0 
              ,coin = 0 
              ,bind_coin = 0 

              ,map_id
              ,pos_x
              ,pos_y    

              ,sex = 1
              ,career = 1
              ,lv = 1
              ,exp = 0 

              ,hp = 0    
              ,mp = 0

              ,guild_id = 0         %% 帮派id
              ,guild_position = 0   %% 帮派位置

              ,other_data = #user_other{}    %% 存库时该字段清空
         }).
