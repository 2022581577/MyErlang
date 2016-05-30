%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 五月 2016 15:59
%%%-------------------------------------------------------------------
-module(lib_user_login).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").
-include("proto_10_pb.hrl").

%% export
-export([login/6]).
-export([enter/2]).

-compile(export_all).

%% record and define
%% 1：成功 2：服务器不允许登陆 3：ip封禁 4：账号封禁 5:防沉迷
-define(LOGIN_SUCCESS,          1).
-define(LOGIN_ERROR_CLOSE,      2).
-define(LOGIN_ERROR_IP_FORBID,  3).
-define(LOGIN_ERROR_ACC_FORBID, 4).
-define(LOGIN_ERROR_INFANT,     5).

-define(ENTER_SUCCESS,          1).
-define(ENTER_ERROR_MULTI,      2).     %% 重复
-define(ENTER_ERROR_USERID,     3).     %% 没有对应userid
-define(ENTER_ERROR_SEAL,       4).     %% 角色封了
-define(ENTER_ERROR_INIT,       5).     %% 开启玩家进程错误

%% ========================================================================
%% API functions
%% ========================================================================
%% @doc 账号登陆
login(State, AccName, Infant, TimeStamp, Sign, ServerID) ->
    #reader_state{socket = Sock} = State,
    case check_login(State, AccName, Infant, TimeStamp, Sign, ServerID) of
        {ok, Res} ->
            SimpleUsers = get_simple_users(AccName),
            Data        = #s2c10001{result = Res, users = SimpleUsers},
            game_pack_send:send_to_socket(Sock, Data),
            {ok, State#reader_state{acc_name = AccName}};
        {?FALSE, Res} ->
            Data = #s2c10001{result = Res, users = []},
            game_pack_send:send_to_socket(Sock, Data),
            {?FALSE, login_false}
    end.


%% @doc 玩家进入游戏
%% TODO 后续需要确认同账号登陆，顶号，封号等
enter(#reader_state{socket = Sock} = State, UserID) ->
    case check_enter(State, UserID) of
        ?TRUE ->
            case user_util:get_user_pid(UserID) of
                {ok, Pid} ->    %% 已有角色登陆
                    State1 = State#reader_state{user_id = UserID, user_pid = Pid},
                    duplicate_enter(State1),
                    {ok, State1};
                _ ->
                    case srv_user:start(UserID) of
                        {ok, Pid} ->
                            State1 = State#reader_state{user_id = UserID, user_pid = Pid},
                            normal_enter(State1),
                            {ok, State1};
                        _ ->    %% TODO 此处最好发条消息给UserID stop掉进程
                            Data = #s2c10003{result = ?ENTER_ERROR_INIT},
                            game_pack_send:send_to_socket(Sock, Data),
                            {?FALSE, enter_false}
                    end
            end;
        {?FALSE, Res} ->
            Data = #s2c10003{result = Res},
            game_pack_send:send_to_socket(Sock, Data),
            {?FALSE, enter_false}
    end.

duplicate_enter(#reader_state{user_pid = _Pid, socket = _Sock} = State) ->
    %% TODO 发消息处理重复登陆问题
    normal_enter(State),
    ok.

normal_enter(#reader_state{user_pid = _Pid, socket = Sock}) ->
    Data = #s2c10003{result = ?ENTER_SUCCESS},
    game_pack_send:send_to_socket(Sock, Data),
    ok.

%% ========================================================================
%% Local functions
%% ========================================================================
%% 登陆检查
check_login(State, AccName, Infant, TimeStamp, Sign, ServerID) ->
    case is_server_status_allow() of
        ?TRUE ->
            check_login1(State, AccName, Infant, TimeStamp, Sign, ServerID);
        _ ->
            {?FALSE, ?LOGIN_ERROR_CLOSE}
    end.

check_login1(State, AccName, Infant, TimeStamp, Sign, ServerID) ->
    #reader_state{socket = Sock} = State,
    case is_ip_allow(Sock) of
        ?TRUE ->
            check_login2(State, AccName, Infant, TimeStamp, Sign, ServerID);
        _ ->
            {?FALSE, ?LOGIN_ERROR_IP_FORBID}
    end.

check_login2(State, AccName, Infant, TimeStamp, Sign, ServerID) ->
    case is_accname_allow() of
        ?TRUE ->
            check_login3(State, AccName, Infant, TimeStamp, Sign, ServerID);
        _ ->
            {?FALSE, ?LOGIN_ERROR_ACC_FORBID}
    end.

check_login3(_State, _AccName, _Infant, _TimeStamp, _Sign, _ServerID) ->
    case is_infant_allow() of
        ?TRUE ->
            {ok, ?LOGIN_SUCCESS};
        _ ->
            {?FALSE, ?LOGIN_ERROR_INFANT}
    end.

%% 进入游戏检查
check_enter(#reader_state{user_id = OldUserID} = State, UserID) ->
    case OldUserID of
        0 ->
            check_enter1(State, UserID);
        _ ->
            ?WARNING("User ~w enter false, OldUserID:~w", [UserID, OldUserID]),
            {?FALSE, ?ENTER_ERROR_MULTI}
    end.

check_enter1(#reader_state{acc_name = AccName} = State, UserID) ->
    UserIDList = get_user_id_list(AccName),
    case lists:member(UserID, UserIDList) of
        ?TRUE ->    %% ok
            check_enter2(State, UserID);
        _ ->
            ?WARNING("User ~w enter false, UserIDList:~w", [UserID, UserIDList]),
            {?FALSE, ?ENTER_ERROR_USERID}
    end.

check_enter2(_State, UserID) ->
    case game_db:get_user(UserID) of
        #user{} ->
            ?TRUE;
        _ ->
            {?FALSE, ?ENTER_ERROR_SEAL}
    end.


is_server_status_allow() ->
    ServerStatus = game_node_interface:status(),
    ServerStatus =:= ?GAME_STATUS_RUNNING.

is_ip_allow(Sock) ->
    IP = util:socket_to_ip(Sock),
    IP =/= "".

is_accname_allow() ->
    ?TRUE.

is_infant_allow() ->
    ?TRUE.

get_simple_users(AccName) ->
    UserIDList = get_user_id_list(AccName),
    F = fun(UserID, AccIn) ->
            case game_db:get_user(UserID) of
                #user{name = Name, career = Career, lv = Lv} ->
                    SimpleUser =
                        #simple_user{user_id    = UserID
                                    ,name       = Name
                                    ,career     = Career
                                    ,lv         = Lv},
                    [SimpleUser | AccIn];
                _ ->
                    AccIn
            end
        end,
    Users = lists:foldl(F, [], UserIDList),
    Users.


get_user_id_list(AccName) ->
    UserIDList =
        case game_db:get_account_info(AccName) of
            {ok, #account_info{user_ids = L}} ->
                L;
            _ ->
                []
        end,
    UserIDList.