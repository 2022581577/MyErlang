%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.15.
%%% @desc   : 人物主进程
%%%----------------------------------------------------------------------

-module(srv_user).
-author('zhongbinbin <binbinjnu@163.com>').
-behaviour(behaviour_gen_server).
-compile(inline).

-include("common.hrl").
-include("record.hrl").

-export([do_init/1
        ,do_call/3
        ,do_cast/2
        ,do_info/2
        ,do_terminate/2]).

-export([start/1
        ,start_link/1]).

-export([after_routine/1]).

%% cast接口
-export([cast/2
        ,cast_stop/2
        ,cast_apply/2
        ,cast_state_apply/2]).
%% call 接口
-export([call/2
        ,call_stop/2
        ,call_apply/2
        ,call_state_apply/2
        ,stop_all/0
        ,i/1
        ,p/1]).    

-define(MODULE_LOOP_TICK,        ?USER_LOOP_TICK).          %% 玩家循环时间 5秒
-define(MODULE_TINY_LOOP_TICK,   ?USER_TINY_LOOP_TICK).     %% 玩家小循环时间 200毫秒

start(UserID) ->
    srv_sup:start_child(?MODULE, [UserID]).

start_link(UserID) ->
    behaviour_gen_server:start_link(?MODULE, [UserID], []).


do_init([UserID]) ->
    case user_api:get_user_pid(UserID) of
        false ->
            {ok, User} = user_base:init(UserID),
            process_flag(trap_exit, true),
            erlang:register(user_api:get_user_process_name(UserID), self()),
            %% loop最好在前端请求了玩家初始化协议后开启（需要注意重连时loop的处理）
            erlang:send_after(?MODULE_LOOP_TICK, self(), {loop, ?USER_LOOP_INCREASE}),
            %% erlang:send_after(?MODULE_TINY_LOOP_TICK, self(), tiny_loop),
            {ok, User};
        {ok, Pid} ->
            ?WARNING("User Has been Started,UserID:~w,Pid:~w",[UserID,Pid]),
            process_exist
    end. 

do_cast({stop_user, Type}, User) ->
    ?INFO("cast stop user!"),
    {stop, normal, User#user{logout_type = Type}};

%% Socket 控制转移
do_cast({set_socket, Socket, Time, Index}, User) ->
    #user{user_id = _UserID
        ,other_data = #user_other{socket = UserSocket} = UserOther} = User,
        %% 判断顶号退出
    _LoginType = 
        case is_port(UserSocket) of
            true ->
                %% 关闭原有 Socket
                catch gen_tcp:close(UserSocket),
                duplicate_login;
            false ->
                normal_login
        end,

    packet_encode:save_packet_index(Time,Index,0,0),
    %% 消息处理
    async_recv(Socket,?HEADER_LENGTH,?HEART_TIMEOUT),


    %%% 重置心跳包错误时间
    %lib_packet_monitor:set_heartbeat_error(0),
    %lib_packet_monitor:set_heartbeat_notice(false),

    %%% 玩家时间初始化(放在此处初始化是因为顶号时也算一次登陆)
    %lib_user_timer:init(UserID, Lv),

    IP = util:socket_to_ip(Socket), %% 保存期本次登陆的IP
    {noreply,User#user{ip = IP, other_data = UserOther#user_other{socket = Socket}}};


do_cast(Info, User) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
    {noreply, User}.

do_call({stop_user, Type}, _From, User) ->
    ?INFO("call stop user!"),
    {stop, normal, User#user{logout_type = Type}};

do_call(Info, _From, User) -> 
    ?WARNING("Not done do_call:~w",[Info]),
    {reply, ok, User}.

%% 数据接收, 上行数据包不能大于 2^16(64K)
do_info({inet_async,Socket,_Ref,{ok,<<0:16,Len:16>>}},#user{other_data = #user_other{socket = Socket}} = User) ->
    %% ?INFO("Recevie Packet Length:~w",[Len]),
    _NewRef = async_recv(Socket,Len - ?HEADER_LENGTH ,?HEART_TIMEOUT),
    {noreply,User};

do_info({inet_async,Socket,_Ref,{ok,Bin}},#user{user_id = UserID, other_data = #user_other{socket = Socket}} = User) ->
    case protobuf_encode:decode(Bin) of
        {Cmd,Data} ->
            _NewRef = async_recv(Socket,?HEADER_LENGTH,?HEART_TIMEOUT),    

            lib_packet_monitor:check_packet_count(Cmd),
            case user_routing:routing(Cmd, Data, User) of
                {ok, #user{} = NewUser} ->
                    {ok, NewUser1} = after_routine(NewUser),    %% 按事务处理完后
                    {noreply, NewUser1};
                {ok, ErrorUser} ->
                    ?WARNING("Return Error User:~w",[ErrorUser]),
                    {noreply, User};
                ErrorRes ->
                    ?WARNING("Return Error Res:~w",[ErrorRes]),
                    {noreply, User}
            end;
        Error ->
            ?WARNING("Receive Data Error:~w,UserID:~w,Ip:~p,Bin:~w",
                [Error, UserID, user_api:get_ip(), Bin]),
            cast_stop(self(), data_error),
            {noreply,User}
    end;

do_info({inet_async,Socket,_Ref,{ok,Bin}},#user{user_id = UserID, acc_name = AccName, other_data = #user_other{socket = UserSocket}} = User) ->
    %% Socket 不匹配
    ?WARNING("Socket not match, UserID:~w,AccName:~w,Socket:~w,UserSocket:~w,Bin:~w",[UserID,AccName,Socket,UserSocket,Bin]),
    cast_stop(self(), socket_not_match),
    {noreply,User};

%% 关闭处理
do_info({inet_async,Socket,_Ref,{error,closed}},#user{user_id = UserID, other_data = #user_other{socket = UserSocket} = UserOther} = User) ->
    case Socket of
        UserSocket ->
            ?INFO("UserID:~w Socket Close...",[UserID]),
            NewSocket = close_socket(Socket),
            cast_stop(self(), socket_close),
            {noreply,User#user{other_data = UserOther#user_other{socket = NewSocket}}};
        _ ->
            ?WARNING("Invalue Socket:~w,UserSocket:~w Closed",[Socket,UserSocket]),
            {noreply,User}
    end;

%% 接收数据
do_info({inet_async,Socket,_Ref,{error,Reason}},#user{user_id = UserID, other_data = #user_other{socket = UserSocket} = UserOther} = User) ->
    case Socket of
        UserSocket ->
            ?WARNING("UserID:~w Socket Error, Reason:~w",[UserID, Reason]),
            NewSocket = close_socket(Socket),
            cast_stop(self(), socket_error),
            {noreply,User#user{other_data = UserOther#user_other{socket = NewSocket}}};
        _ ->
            ?WARNING("Invalue Socket:~w,UserSocket:~w,Reason:~w",[Socket,UserSocket,Reason]),
            {noreply,User}
    end;
    
do_info({inet_reply,_Socket,ok},User) ->
    {noreply,User};

%% 网络层出错
do_info({inet_reply,Socket,{error,Reason}},#user{user_id = UserID, other_data = #user_other{socket = Socket} = UserOther} = User) ->
    ?WARNING("UserID:~w Newwork Error,Reason:~w",[UserID,Reason]),
    %?RCD_LOGOUT_TYPE(UserID, ?LOGOUT_TYPE_SOCKET_ERR),
    NewSocket = close_socket(Socket),
    cast_stop(self(), netword_error),
    {noreply,User#user{other_data = UserOther#user_other{socket = NewSocket}}};


do_info({loop, Time}, #user{other_data = #user_other{is_loop = 0}} = User) ->
    erlang:send_after(?MODULE_LOOP_TICK, self(), {loop, Time}),
    {noreply, User};
do_info({loop, Time}, User) ->  %% 前端确认登录完成后才进行loop
    %% 加个判断，判断是否在socket断掉的时候，考虑是否需要断掉loop
    erlang:send_after(?MODULE_LOOP_TICK, self(), {loop, Time + ?USER_LOOP_INCREASE}),
    {ok, NewUser} = user_base:loop(User,Time),
    {noreply,NewUser};

%do_info(tiny_loop, User) ->
%    erlang:send_after(?MODULE_TINY_LOOP_TICK, self(), tiny_loop),
%    {ok, UserN} = user_send:send_msg(User),
%    {noreply, UserN};

do_info(Info, User) -> 
    ?WARNING("Not done do_info:~w",[Info]),
    {noreply, User}.

do_terminate(Reason, #user{user_id = UserID} = User) ->
    ?INFO("~w stop,UserID:~w,Reason:~w",[?MODULE,UserID,Reason]),
    %% 玩家下线处理
    {ok, _User1} = user_base:logout(User),
    ok.

%%% ----------------------
%%%     socket相关
%%% ----------------------
async_recv(Sock, Length, Timeout) when is_port(Sock) ->
    case prim_inet:async_recv(Sock, Length, Timeout) of
        {error, Reason} -> 
            ?WARNING("asyn_recv Error,Reasion:~w",[Reason]),
            cast_stop(self(), asyn_recv_error);
        {ok, Res} -> 
            Res
    end.

%% 关闭socket
close_socket(Socket) ->
    NewSocket = undefined,
    catch gen_tcp:close(Socket),
    NewSocket.
%%% ----------------------
%%%     socket相关
%%% ----------------------


%%% ----------------------
%%%     处理事务相关
%%% ----------------------
after_routine(User) ->
    %% 发消息
    {ok, User1} = user_send:send_msg(User),
    %% 下发事件
    {ok, UserN} = user_event:send_event(User1),
    %% 日志累积在loop中和数据一起save
    {ok, UserN}.

%%% ----------------------
%%%     处理事务相关
%%% ----------------------

%%% -------------------------------------------
%%%             -----API-----
%%% -------------------------------------------
%% @doc 踢出所有玩家
stop_all() ->
    OnlineL = user_online:online_list(),
    stop_all(OnlineL).
stop_all([#user_online{pid = Pid} | T]) ->
    catch call_stop(Pid, kick_out),
    stop_all(T);
stop_all([]) ->
    ok.

%% @doc 停止进程 cast 方式
cast_stop(UserX, Type) ->
    case analyze_user_x(UserX) of
        {false, R} ->   
            ?WARNING("cast stop user false, UserX:~w, Type:~w, R:~w", [UserX, Type, R]);
        UserPid ->
            behaviour_gen_server:cast(UserPid, {stop_user, Type})
    end.

%% @doc 同步停止进程
call_stop(UserX, Type) ->
    case analyze_user_x(UserX) of
        {false, R} ->   
            ?WARNING("call stop user false, UserX:~w, Type:~w, R:~w", [UserX, Type, R]);
        UserPid ->
            behaviour_gen_server:call(UserPid, {stop_user, Type})
    end.


%% @param UserX: User | UserPid | UserID
%% @param Callback {M, F, A} | {F, A} | F
%% @return ok | {false, Res}
%% 如果是#user{}和UserID，需要在玩家进程所在节点调用，Pid可在任意节点调用
cast_state_apply(UserX, Callback) ->      
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("cast state apply user false, UserX:~w, Callback:~w, R:~w", [UserX, Callback, R]),
            {false, R};
        UserPid ->
            {M, F, A} = util:transform_callback(Callback),
            behaviour_gen_server:cast_state_apply(UserPid, M, F, A)
    end.
cast_apply(UserX, Callback) ->      
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("cast apply user false, UserX:~w, Callback:~w, R:~w", [UserX, Callback, R]),
            {false, R};
        UserPid ->
            {M, F, A} = util:transform_callback(Callback),
            behaviour_gen_server:cast_apply(UserPid, M, F, A)
    end.

%% @param UserX: User | UserPid | UserID
%% @param msg
%% @return ok | {false, Res}
%% 如果是#user{}和UserID，需要在玩家进程所在节点调用，Pid可在任意节点调用
cast(UserX, Msg) ->
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("cast user false, UserX:~w, Msg:~w, R:~w", [UserX, Msg, R]),
            {false, R};
        UserPid ->
            behaviour_gen_server:cast(UserPid, Msg)
    end.


%% @param UserX: User | UserPid | UserID
%% @param Callback {M, F, A} | {F, A} | F
%% @return ok | {false, Res}
%% 如果是#user{}和UserID，需要在玩家进程所在节点调用，Pid可在任意节点调用
call_state_apply(UserX, Callback) ->      
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("call state apply user false, UserX:~w, Callback:~w, R:~w", [UserX, Callback, R]),
            {false, R};
        UserPid ->
            {M, F, A} = util:transform_callback(Callback),
            behaviour_gen_server:call_state_apply(UserPid, M, F, A)
    end.
call_apply(UserX, Callback) ->      
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("call apply user false, UserX:~w, Callback:~w, R:~w", [UserX, Callback, R]),
            {false, R};
        UserPid ->
            {M, F, A} = util:transform_callback(Callback),
            behaviour_gen_server:call_apply(UserPid, M, F, A)
    end.

%% @param UserX: User | UserPid | UserID
%% @param msg
%% @return ok | {false, Res}
%% 如果是#user{}和UserID，需要在玩家进程所在节点调用，Pid可在任意节点调用
call(UserX, Msg) ->
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("call user false, UserX:~w, Msg:~w, R:~w", [UserX, Msg, R]),
            {false, R};
        UserPid ->
            behaviour_gen_server:call(UserPid, Msg)
    end.


%% @doc 调试接口,获取状态
i(ID) ->
    call(ID, get_state).
p(ID) ->
    case i(ID) of
        #user{} = User ->
            lib_record:print_record(User);
        R ->
            R
    end.

%% user_x解析UserPid
analyze_user_x(#user{other_data = #user_other{pid = UserPid}}) ->
    UserPid;
analyze_user_x(UserID) when is_integer(UserID) ->
    case user_api:get_user_pid(UserID) of
        false ->
            {false, offline};
        {ok, UserPid} ->
            UserPid
    end;
analyze_user_x(UserPid) when is_pid(UserPid) ->
    UserPid;
analyze_user_x(_) ->
    {false, error_arg}.

%%% -------------------------------------------
%%%             -----API-----
%%% -------------------------------------------
