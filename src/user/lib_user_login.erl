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

-compile(export_all).

%% record and define
%% 1：成功 2：服务器不允许登陆 3：ip封禁 4：账号封禁 5:防沉迷
-define(LOGIN_SUCCESS,          1).
-define(LOGIN_ERROR_CLOSE,      2).
-define(LOGIN_ERROR_IP_FORBID,  3).
-define(LOGIN_ERROR_ACC_FORBID, 4).
-define(LOGIN_ERROR_INFANT,     5).

%% ========================================================================
%% API functions
%% ========================================================================
login(State, AccName, Infant, TimeStamp, Sign, ServerID) ->
    #reader_state{socket = Sock} = State,
    case check_login(State, AccName, Infant, TimeStamp, Sign, ServerID) of
        {ok, Res} ->
            SimpleUsers = get_simple_users(AccName),
            Data        = #s2c10001{result = Res, users = SimpleUsers},
            game_pack_send:send_to_socket(Sock, Data),
            {ok, State};
        {?FALSE, Res} ->
            Data = #s2c10001{result = Res, users = []},
            game_pack_send:send_to_socket(Sock, Data),
            {?FALSE, login_false}
    end.

%% ========================================================================
%% Local functions
%% ========================================================================
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
    _UserIDList =
        case game_mmdb:get_account_info(AccName) of
            ?FALSE ->   [];
            #account_info{user_ids = L} ->  L
        end,
    [].