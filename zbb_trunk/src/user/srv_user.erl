%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.15.
%%% @desc   : 人物主进程
%%%----------------------------------------------------------------------

-module(srv_user).
-author('zhongbinbin <binbinjnu@163.com>').
-behaviour(game_gen_server).
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

-define(MODULE_LOOP_TICK,5000).		%% 玩家循环时间5秒
%% 玩家每次循环的增数
-define(PLAYER_LOOP_INCREACE, 5).   

start(UserID) ->
	server_sup:start_user([UserID]).
start_link(UserID) ->
    game_gen_server:start_link(?MODULE, [UserID], []).


do_init([UserID]) ->
    case lib_user:get_user_pid(UserID) of
        false ->
            process_flag(trap_exit,true),
            %% loop最好在前端请求了玩家初始化协议后开启（需要注意重连时loop的处理）
            %erlang:send_after(?MODULE_LOOP_TICK, self(), {loop, ?PLAYER_LOOP_INCREACE}),
            ProcessName = lib_user:get_user_process_name(UserID),
            erlang:register(ProcessName, self()),
            %% 在init的时候就load data 还是 发送一条消息给自己load data  
            user_online:add(#user_online{user_id = UserID, pid = self()}),
            {ok,#user{user_id = UserID}};
        Pid ->  
            ?WARNING("User Has been Started,UserID:~w,Pid:~w",[UserID,Pid]),
            process_exist
    end. 

%do_cast({send_data,L},#user{socket = Socket} = User) ->
%    lib_send:send(Socket,lists:reverse(L)),
%    {noreply,User};

do_cast({stop_user, Type}, User) ->
    ?WARNING("cast stop user!"),
    {stop, normal, User#user{logout_type = Type}};
%    case lib_user:get_login_state() of
%        true -> %% 在顶号中退出
%            Ref = erlang:send_after(3000, self(), stop),
%            lib_user:set_logout_ref(Ref),
%            {noreply, User};
%        _ ->
%	        {stop,normal,User}
%    end;

%% Socket 控制转移
do_cast({set_socket,Socket,Time,Index},#user{user_id = _UserID, other_data = #user_other{socket = UserSocket} = UserOther} = User) ->
    %% 判断顶号退出
    %lib_user:set_login_state(false),
    %OldRef = lib_user:get_logout_ref(),
    %case erlang:is_reference(OldRef) of
    %    true ->
    %        erlang:cancel_timer(OldRef),
    %        lib_user:set_login_state(undefined);
    %    _ ->
    %        skip
    %end,
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
    ?WARNING("call stop user!"),
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
	case packet_encode:decode(Bin) of
		{Cmd,Data} ->
            lib_packet_monitor:check_packet_count(Cmd),
			_NewRef = async_recv(Socket,?HEADER_LENGTH,?HEART_TIMEOUT),	
			%% User2 = User#user{packet_len = 0},
            %% ?INFO("Recevie Data:~w",[Cmd]),
            case lib_routing:routing(Cmd, Data, User) of
				{ok,#user{} = NewUser} ->
					{noreply,NewUser};
				{ok,ErrorStatus} ->
					?WARNING("Return Error User:~w",[ErrorStatus]),
					{noreply,User};
				_ ->
					{noreply,User}
			end;
		Error ->
            ?WARNING("Receive Data Error:~w,UserID:~w,Ip:~p,Bin:~w",[Error,UserID,lib_user:get_ip(),Bin]),
            cast_stop(self(), data_error),
            {noreply,User}
	end;

do_info({inet_async,Socket,_Ref,{ok,Bin}},#user{user_id = UserID, acc_name = AccName, other_data = #user_other{socket = UserSocket}} = User) ->
    %% Socket 不匹配
    ?WARNING("Socket not match, UserID:~w,AccName:~w,Socket:~w,UserSocket:~w,Bin:~w",[UserID,AccName,Socket,UserSocket,Bin]),
    cast_stop(self(), socket_not_match),
    {noreply,User};

%% 接收出错处理
do_info({inet_async,Socket,_Ref,{error,closed}},#user{user_id = UserID, other_data = #user_other{socket = UserSocket} = UserOther} = User) ->
    case Socket of
        UserSocket ->
            ?WARNING("UserID:~w Socket Close...",[UserID]),
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
            ?INFO("Invalue Socket:~w,UserSocket:~w,Reason:~w",[Socket,UserSocket,Reason]),
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

%do_info({send,Bin},#user{other_data = #user_other{socket = Socket}} = User) ->
%    lib_user_send:send(Socket,Bin),
%    {noreply,User};
%
%do_info({nodelay_send,Bin},#user{other_data = #user_other{socket = Socket}} = User) ->
%    lib_send:send(Socket,Bin),
%	{noreply,User};
%
%do_info(send,#user{other_data = #user_other{socket = Socket}} = User)->
%    %% ?INFO("Send User Buff"),
%    lib_user_send:do_send(Socket),
%    lib_user_send:set_timer_ref(?NOT_TIMER_REF),
%    {noreply,User};
	
do_info({loop,Time},User) ->
    %% 加个判断，判断是否在socket断掉的时候，考虑是否需要断掉loop
	erlang:send_after(?MODULE_LOOP_TICK, self(), {loop, Time + ?PLAYER_LOOP_INCREACE}),
    NewUser = lib_user_loop:loop(User,Time),
	{noreply,NewUser};

do_info(Info, User) -> 
    ?WARNING("Not done do_info:~w",[Info]),
	{noreply, User}.

do_terminate(Reason, #user{user_id = UserID} = _User) ->   
    ?INFO("~w stop,UserID:~w,Reason:~w",[?MODULE,UserID,Reason]),
    %% 玩家下线处理
    %lib_logout:logout(User),
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
            game_gen_server:cast(UserPid, {stop_user, Type})
    end.
	
%% @doc 同步停止进程
call_stop(UserX, Type) ->
    case analyze_user_x(UserX) of
        {false, R} ->   
            ?WARNING("call stop user false, UserX:~w, Type:~w, R:~w", [UserX, Type, R]);
        UserPid ->
            game_gen_server:call(UserPid, {stop_user, Type})
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
            game_gen_server:cast_state_apply(UserPid, M, F, A)
    end.
cast_apply(UserX, Callback) ->      
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("cast apply user false, UserX:~w, Callback:~w, R:~w", [UserX, Callback, R]),
            {false, R};
        UserPid ->
            {M, F, A} = util:transform_callback(Callback),
            game_gen_server:cast_apply(UserPid, M, F, A)
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
            game_gen_server:cast(UserPid, Msg)
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
            game_gen_server:call_state_apply(UserPid, M, F, A)
    end.
call_apply(UserX, Callback) ->      
    case analyze_user_x(UserX) of
        {false, R} ->
            ?WARNING("call apply user false, UserX:~w, Callback:~w, R:~w", [UserX, Callback, R]),
            {false, R};
        UserPid ->
            {M, F, A} = util:transform_callback(Callback),
            game_gen_server:call_apply(UserPid, M, F, A)
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
            game_gen_server:call(UserPid, Msg)
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
    case lib_user:get_user_pid(UserID) of
        false ->    {false, offline};
        UserPid ->  UserPid
    end;
analyze_user_x(UserPid) when is_pid(UserPid) ->
    UserPid;
analyze_user_x(_) ->
    {false, error_arg}.

%%% -------------------------------------------
%%%             -----API-----
%%% -------------------------------------------
