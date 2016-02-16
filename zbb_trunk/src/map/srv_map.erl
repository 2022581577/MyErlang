%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.02.16
%%% @desc   : 地图模块
%%%----------------------------------------------------------------------

-module(srv_map).
-behaviour(gen_server2).
-compile(inline).

-include("common.hrl").
-include("record.hrl").

-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).

-export([start/2, start_link/2, stop/1, sync_stop/1, cast/2, call/2]).
-export([sync_apply/2,sync_mfa_apply/4,i/1,p/1]).		%% call 接口
-export([apply/2,mfa_apply/4]).	                        %% cast接口

-export([set_last_active/0,
         get_last_active/0
        ]).

-define(MAP_LOOP_CHECK_SEND,((10 * 1000) div ?MAP_LOOP_TICK)).  %% 发送进程检查时间
-define(MAP_LOOP_CHECK,(1000 div ?MAP_LOOP_TICK)).              %% 发送进程检查时间
-define(MAP_LOOP_DAOFA,(400 div ?MAP_LOOP_TICK)).               %% 道法更新
-define(MAP_LOOP_CHECK_PVP,(200 div ?MAP_LOOP_TICK)).              %% 发送进程检查时间
-define(DUPLICATION_ADD_LIVE_TIME, 180).                        %% 额外给地图多180s的存活时间

%% @doc 开启地图API
start(MapID, MapIndexID) ->
    ProcessName = lib_map_api:get_map_process_name(MapOnlyID),
    case erlang:whereis(ProcessName) of
        undefined ->
            server_sup:start_map([MapID, MapIndexID]);
        Pid ->
            mod_map:mfa_apply(Pid, srv_map, set_last_active, []),   
            {ok,Pid}
    end.

start_link(MapID, MapIndexID) ->
    ProcessName = lib_map_api:get_map_process_name(MapOnlyID),
    gen_server2:start_link({local,ProcessName}, ?MODULE, [MapID, MapIndexID], []).

do_init([MapID, MapIndexID]) ->
    ?INFO("Start Map, MapID:~w, MapIndexID:~w",[MapID, MapIndexID]),
    process_flag(trap_exit,true),
    
    erlang:send_after(?MAP_LOOP_TICK, self(), {loop,1}),
    

    lib_trap_block:set_block_trap_list([]),

    lib_map_point:init(MapID),
            

    TimeStamp = util:timestamp(),

    MapInfo = #map_info{map_inst_id = {MapID, MapIndexID}
                        ,map_id = MapID
                        ,map_index_id = MapIndexID
                        ,map_pid = self()},
    lib_map_counter:save_map_state(MapState),
    set_last_active(),

    MapTpl = data_map:get(MapID),

    Map = #map{
            ,map_id = MapID
            ,map_index_id = MapIndexID 
            ,map_type = MapTpl#tpl_map.map_type
            ,map_sub_type = MapTpl#tpl_map.map_sub_type
            %,aoi_map = aoi:create_map({0, 0}, {MapConfigTpl#tpl_map_config.width, MapConfigTpl#tpl_map_config.height})
            ,create_time = util:longunixtime()
        },
    {true, NewMap} = map:create_mon([Map, NewMonList]),
    {ok, NewMap}.

do_call(Info, _From, State) -> 
    ?WARNING("Not done do_call:~w",[Info]),
	{reply, error, State}.

do_cast({change_state,ID,Type,NextState,NextSpeed,DelayTime},#map_state{start_timestamp = StartTimeStamp} = State) ->
    TimeStamp = util:timestamp(),
    case lib_duplication_move:check_change_state(DelayTime,ID,Type,NextState,NextSpeed,TimeStamp) of
        {true,NextSpeed2,NextYSpeed} ->
            NewTicker = TimeStamp - StartTimeStamp,
            HasGravity =
            case NextState of
                ?MOVE_STATE_MOVE ->
                    ?MOVE_NO_GRAVITY;
                ?MOVE_STATE_USER_CONTROL ->
                    ?MOVE_NO_GRAVITY;
                _ ->
                    ?MOVE_HAS_GRAVITY
            end,
            lib_duplication_move:add_state(ID,Type,DelayTime,NextState,NextSpeed2,NextYSpeed,NewTicker,HasGravity),
            lib_send_pvp:send_all();
         {false,_,_} ->
             ?INFO("++++++++++++++ ID:~w,Type:~w,State:~w Move In attack +++++++++++++++",[ID,Type,NextState])
             %case Type of
             %    ?OBJECT_TYPE_USER ->
             %       lib_send:send_hint(ID,16014);
             %    _ ->
             %        skip
             %end
     end,
    {noreply,State};

do_cast({change_direction,ID,Type,Direction},State) ->
    lib_duplication_move:change_direction(ID,Type,Direction),
    {noreply,State};

do_cast({battle_attack,SkillID,UserID,ActorType},#map_state{start_timestamp = StartTimeStamp,dup_type = DupType} = State) ->
    case DupType of
        ?DUPLICATION_FLAG ->
            lib_flag_map:interrupt_collect(UserID),
            lib_flag_map:del_user_collect(UserID);
        _ ->
            skip
    end,
    TimeStamp = util:timestamp(),
    NewTicker = TimeStamp - StartTimeStamp,
    lib_duplication_move:update_state(NewTicker),
    lib_battle:attack(SkillID,UserID,ActorType,TimeStamp,NewTicker),
    {noreply,State};

do_cast({generals_attack,UserID,SkillID},#map_state{start_timestamp = StartTimeStamp} = State) ->
    case lib_battle_generals:get_user_generals(UserID,?GENERALS_REN) of
        #battle_generals{id = ID,skill_id = SkillIDList} ->
            case lists:member(SkillID,SkillIDList) of
                true ->
                    TimeStamp = util:timestamp(),
                    NewTicker = TimeStamp - StartTimeStamp,
                    lib_duplication_move:update_state(NewTicker),
                    lib_battle:attack(SkillID,ID,?OBJECT_TYPE_WUJIANG,TimeStamp,NewTicker);
                false ->
                    ?WARNING("Generals Attack Fail,UserID:~w",[UserID])
            end;
        false ->
            ?WARNING("Generals Attack Fail,UserID:~w",[UserID])
    end,
    {noreply,State};

do_cast(Info, State) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
	{noreply, State}.

do_info({loop,T},#map_state{start_timestamp = StartTimeStamp, pvp = Pvp} = State) ->
    
    erlang:send_after(?MAP_LOOP_TICK, self(), {loop,T + 1}),
    
    TimeStamp = util:timestamp(),
            
    NewTicker = TimeStamp - StartTimeStamp,

    MapUserIDS = lib_map:get_map_user_ids(),
    NewState =
    case T rem ?MAP_LOOP_CHECK of
        0 ->
            case lib_map:get_dup_type() of
                ?DUPLICATION_FML ->
                    lib_world_boss:check_hurt_list();
                ?DUPLICATION_GUILD_BEAST_SHILIAN ->
                    lib_guild_duplication:check_hurt_list();
                ?DUPLICATION_GUILD_ZB ->
                    skip;
                ?DUPLICATION_YZCM ->
                    lib_duplication_yzcm:loop(NewTicker div 1000);
                ?DUPLICATION_FLAG ->
                    %?D("====================== CloseTime:~w ===========",[CloseTime-?DUPLICATION_ADD_LIVE_TIME]),
                    lib_flag_map:loop(NewTicker div 1000);
                _ ->
                    skip
            end,
            map_loop(T,State,MapUserIDS);
        _ ->
            State
    end, 
    case Pvp of
        ?PVP ->
            %% 行走检查
            lib_duplication_move:update_state(NewTicker),
            
            %% 攻击检查
            lib_battle_attack:check_attack(TimeStamp), 

            lib_battle_move_block:check_block(), 
                     
            lib_battle_def:check_def(TimeStamp),

            case T rem ?MAP_LOOP_CHECK_PVP of
                0 ->
                     %% 连击数检查
                     lib_battle_last_att:check_last_att(TimeStamp),
                     lib_battle_state:check_attack_protect_list(TimeStamp),
                     
                     %% 怪物AI
                     lib_mon_group:loop(TimeStamp),
                     lib_mon:active(TimeStamp,NewTicker),

                     %% 机关陷阱检查
                     lib_trap:loop(TimeStamp,NewTicker),
                     
                     %% 生成武将检查
                     lib_battle_generals:check_generals(),

                     %% 踏台面上目标检查
                     lib_trap_block:check_block_top_objs(),
            
                     lib_battle_zhexian:loop(TimeStamp),

                     case T rem 4 of
                         0 ->
                             %% 飞弹检查
                             lib_battle_tracer:loop(TimeStamp);
                         _ ->
                             skip
                     end,

                     case lib_map:get_dup_type() of
                         ?DUPLICATION_FLAG ->    %% 夺旗副本200ms检测中断采旗
                             lib_flag_map:check_interrupt_collect();
                         ?DUPLICATION_TTDB ->   %% 夺宝奇兵检测
                             lib_ttdb_map:loop(TimeStamp);
                         _ ->
                             skip
                     end,

                     %% 采集检查
                     lib_map_collect:check_interrupt_collect(),
                     
                     ok;
                 _ ->
                     skip
             end,
                   
             case T rem ?MAP_LOOP_DAOFA of
                 0 ->
                     %% 道法更新
                     lib_map_loop:dao_fa_loop(TimeStamp);
                 _ ->
                     skip
             end,
                     

            case T rem ?MAP_LOOP_CHECK of
                0 ->
                    lib_battle_buff:buff_loop(),
                    %% 移屏检查
                    lib_duplication_devide:auto_devide(),
                    
                    ok;
                _ ->
                    skip
            end,
            lib_send_pvp:send_all(),
            ok;
        ?PVE ->
            case T rem 4 of
                0 ->
                    lib_send_cache:send_all(MapUserIDS);
                _ ->
                    skip
            end,
            skip
    end,
    {noreply,NewState};

do_info({mon_attack,ID},#map_state{start_timestamp = StartTimeStamp} = State) ->
    case lib_mon_util:get_mon(ID) of
        #mon{skill_id = SkillID,hp = Hp} = Mon when Hp > 0 andalso SkillID > 0 ->
            TimeStamp = util:timestamp(),
            NewTicker = TimeStamp - StartTimeStamp,
            lib_battle:attack(SkillID,ID,?OBJECT_TYPE_MON,TimeStamp,NewTicker),
            
            #battle_skill{yinchang = YinChange, mingzhong = MingZhong ,shoudao = Shoudao} = data_battle_skill:get(SkillID),                       
            AttackTime = TimeStamp + YinChange + MingZhong + Shoudao +  ?MOVE_DELAY_TIME,
            NewMon = Mon#mon{last_attack_time = AttackTime,last_move_time = AttackTime,is_tracing = false},
            lib_mon_util:set_mon(NewMon); 
        _ ->
            skip
    end,
    {noreply,State};

%% @doc 开始副本
do_info({start_duplication, UserID}, #map_state{map_id = MapID, map_type = ?MAP_TYPE_DUPLICATION} = State) ->
    %% 检测副本开启
    lib_duplication_start:start_dup(),
    %% 发送副本时间
    #data_duplication{finish_time = FinishTime} = data_duplication:get(MapID),
    TimeStamp = util:timestamp(),
    StartTimeStamp = lib_duplication_start:get_dup_start_tick(),
    NewTicker = TimeStamp - StartTimeStamp,
    OpenTime = NewTicker div 1000,
    LeaveTime = max(0, FinishTime - OpenTime),
    Now = mod_timer:unixtime(),
    FinishUnixTime = Now + LeaveTime,
    ?INFO("start_duplication Now:~w, FinishTime:~w, LeaveTime:~w, FinishUnixTime:~w", [Now, FinishTime, LeaveTime, FinishUnixTime]),
    {ok, Bin} = pt_14:write(?PP_DUPLICATION_PVP_ENTER_TIME, FinishUnixTime),
    lib_send:send_to_pid(UserID, Bin),
    {noreply, State};

%% 改变玩家的阵营
do_info({change_camp, UserList}, State) ->
    ?INFO("change_camp:~w", [UserList]),
    [begin
            {ok,Bin} = pt_13:write(?PP_BATTLE_CHANGE_CAMP,[E, Camp]),
            lib_map_api:do_update_map_user(E, [{#map_user.camp, Camp}],Bin)
    end || {E, Camp} <- UserList],
    {noreply, State};

do_info({change_camp, UserList, Camp}, State) ->
    [begin
            {ok,Bin} = pt_13:write(?PP_BATTLE_CHANGE_CAMP,[E,Camp]),
            lib_map_api:do_update_map_user(E, [{#map_user.camp, Camp}],Bin) 
    end|| E <- UserList],
    {noreply, State};

%% @doc 检测采集成功
do_info({flag_collect, UserID}, State) ->
    lib_flag_map:check_collect_success(UserID),
    {noreply, State};

%% @doc 采集
do_info({collect, UserID, Type}, #map_state{start_timestamp=StartTimeStamp}=State) ->
    TimeStamp = util:timestamp(),
    NewTicker = TimeStamp - StartTimeStamp,
    lib_map_collect:check_collect_success(UserID, Type, TimeStamp, NewTicker),
    {noreply, State};

do_info({mfa_apply,Mod,Fun,Args},State) when Mod =/= os ->
	erlang:apply(Mod,Fun,Args),
	{noreply,State};	

do_info(Info, State) -> 
    ?WARNING("Not done do_info:~w",[Info]),
	{noreply, State}.

do_terminate(Reason, #map_state{map_only_id = MapOnlyID,map_id = MapID}) ->
	?INFO("~w stop,MapID:~w,MapOnlyID:~w,Reason:~w...",[?MODULE,MapID,MapOnlyID, Reason]),
    lib_map_counter:remove_map_state(MapOnlyID,MapID),
    ok.

	
%% @doc 停止进程 cast 方式
stop(ID) ->
	cast(ID,stop).
	
%% @doc 同步停止进程
sync_stop(ID) ->
	call(ID,stop).

%% @doc cast 接口调用
cast(ID,Msg) when is_integer(ID) ->
    case lib_map_api:get_pid(ID) of
		undefined ->
			undefined;
	    Pid ->
			cast(Pid,Msg)
	end;
cast(Pid,Msg) ->
	gen_server:cast(Pid,Msg).

%% @doc call接口调用
call(ID,Msg) when is_integer(ID) ->
    case lib_map_api:get_pid(ID) of
		undefined ->
			undefined;
		Pid ->
			call(Pid,Msg)
	end;
call(Pid,Msg) ->
	gen_server:call(Pid,Msg).

%% @doc 函数调用
sync_apply(ID,Fun) ->
	call(ID,{apply,Fun}).
%% @doc MFA函数调用
sync_mfa_apply(ID,Mod,Fun,Args) ->
	call(ID,{mfa_apply,Mod,Fun,Args}).

%% @doc fun 调用
apply(ID,Fun) ->
	cast(ID,{apply,Fun}).
%% @doc MFA函数调用
mfa_apply(ID,Mod,Fun,Args) ->
	cast(ID,{mfa_apply,Mod,Fun,Args}).

%% @doc 调试接口,获取状态
i(ID) ->
	call(ID,get_status).
p(ID) ->
	case i(ID) of
		undefined ->
			undefined;
		State ->
			io:format("~p~n",[lib_record:fields_value(State)])
	end.

%% 地图循环
map_loop(T,#map_state{start_timestamp = StartTimeStamp,
                      time = Time,
                      map_id=MapID, 
                      map_type = MapType, 
                      count = Count
                     } = State,MapUserIDS) ->
    case MapUserIDS of
        [] ->
            is_close_map(MapID, MapType, StartTimeStamp);
        _ ->
            skip
    end,
    Count2 = length(MapUserIDS) + lib_map:check_loading_users(),
    NewState =
    case MapType of
        ?MAP_TYPE_DUPLICATION ->
            LeaveTime = lib_map_loop:duplication_loop(T, Time),
            State#map_state{time = LeaveTime,count = Count2};
        _ ->
            State#map_state{count = Count2}
    end,
    case Count2 of
        Count ->
            skip;
        _ ->
            lib_map_counter:save_map_state(NewState)
    end,
    NewState.


%% @doc 设置地图最后访问时间，用于关闭无用的地图进程
-define(MAP_LAST_ACTIVE_TIME,map_last_active_time).
-define(MAP_NONE_ACTIVE_TIME, (10 * 60)). %% 非活动地图存活时间
get_last_active() ->
    get(?MAP_LAST_ACTIVE_TIME).
set_last_active() ->
    %% Time = mod_timer:unixtime(),
    Time = util:timestamp() div 1000,
    set_last_active(Time).
set_last_active(Time) ->
    put(?MAP_LAST_ACTIVE_TIME,Time).

%% 地图没人时检查关闭地图
is_close_map(MapID, MapType, StartTimeStamp) ->
    Now = util:timestamp() div 1000,
    LastActiveTime = get_last_active(),
    %% ?INFO("Now:~w,LastActiveTime:~w,Diff:~w",[Now,LastActiveTime,Now - LastActiveTime]),
    case Now - ?MAP_NONE_ACTIVE_TIME > LastActiveTime  of
        true ->
            case MapType of
                ?MAP_TYPE_DUPLICATION ->
                    #data_duplication{type = DupType, finish_time = FinishTime} = data_duplication:get(MapID),
                    case DupType of
                        ?DUPLICATION_GUILD_BEAST_SHILIAN ->
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        ?DUPLICATION_GUILD_STATION ->           %% 帮派驻地战副本
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        ?DUPLICATION_GUILD_ZB ->
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        ?DUPLICATION_GUILD_QUALIFIER ->
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        ?DUPLICATION_GUILD_XYSQ ->            %% 帮派硝烟四起副本
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        ?DUPLICATION_YZCM ->
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        ?DUPLICATION_FLAG ->
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        ?DUPLICATION_WDH_JS ->
                            check_close_world_map(Now, StartTimeStamp,FinishTime);
                        _ ->
                            ?D("=========== Now:~w, StartTime:~w, FinishTime:~w =====",[Now,StartTimeStamp div 1000,FinishTime]),
                            stop(self())
                    end;
                _ ->
                    stop(self())
            end;
        false ->
            skip
    end.

%% @doc 世界boss、帮派战等地图检测关闭
check_close_world_map(Now, StartTimeStamp, FinishTime) ->
    StartTime = StartTimeStamp div 1000,
    case Now - StartTime > FinishTime + ?MAP_NONE_ACTIVE_TIME of
        true ->
            ?D("=========== Now:~w, StartTime:~w, FinishTime:~w =====",[Now,StartTime,FinishTime]),
            stop(self());
        false ->
            skip
    end,
    ok.

