%%%---------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.01.30
%%% @desc   : 玩家模块
%%%----------------------------------------------------------------------

-module(user_api).
-include("common.hrl").
-include("record.hrl").

-export([get_user_pid/1
        ,is_online/1
        ,get_user_process_name/1
    ]).

%% 玩家进程注册的名字只能本节点使用，
%% 不能确保是同节点的进程不能使用，
%% 需要把玩家PID带到对应进程中使用
%% @doc 获取玩家进程PID
get_user_pid(UserID) ->
    ProcessName = get_user_process_name(UserID),
    case whereis(ProcessName) of
        undefined ->
            ?FALSE;
        Pid ->
            case is_process_alive(Pid) of
                true ->
                    {ok, Pid};
                false ->
                    ?FALSE
            end 
    end.

%% @doc 玩家是否在线
is_online(UserID) ->
    ProcessName = get_user_process_name(UserID),
    case whereis(ProcessName) of
        undefined ->
            ?FALSE;
        Pid ->
            is_process_alive(Pid)
    end.

%% @doc 玩家进程名
get_user_process_name(UserID) ->
    util:to_atom(lists:concat(["user_",UserID])).
