%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.04.22
%%% @desc   : 玩家日志 tiny_loop中转储到进程字典中
%%%           在定时和下线save的时候在把日志发给srv_log
%%%----------------------------------------------------------------------

-module(user_log).
-include("common.hrl").
-include("record.hrl").

-export([add_log/2]).
-export([store_log/1]).
-export([save/1]).

%% @doc 添加玩家日志到log_list中
%% 玩家进程内部调用
add_log(#user{other_data = #user_other{log_list = LogList} = UserOther} = User, Log) ->
    User1 = #user{other_data = UserOther#user_other{log_list = [Log | LogList]}},
    {ok, User1}.

%% @doc 把log_list中的日志转储到dic中
%% 玩家进程内部调用，tiny_loop中调用
%% 玩家下线时也需要调用
store_log(#user{other_data = #user_other{log_list = []}} = User) ->
    {ok, User};
store_log(#user{other_data = #user_other{log_list = LogList} = UserOther} = User) ->
    OldLogList = get_dic_log_list(),
    NewLogList = LogList ++ OldLogList,
    set_dic_log_list(NewLogList),
    User1 = User#user{other_data = UserOther#user_other{log_list = []}},
    {ok, User1}.

%% @doc 定时或下线时，日志发送到srv_log中
save(#user{other_data = #user_other{log_list = LogList} = UserOther} = User) ->
    OldLogList = get_dic_log_list(),
    NewLogList = LogList ++ OldLogList,
    srv_log:add_log(NewLogList),
    set_dic_log_list([]),
    User1 = User#user{other_data = UserOther#user_other{log_list = []}},
    {ok, User1}.

%% @doc 把日志放到缓存中，避免log_list太长
-define(DIC_LOG_LIST, dic_log_list).
get_dic_log_list() ->
    case get(?DIC_LOG_LIST) of
        ?UNDEFINED ->   [];
        L ->            L
    end.
set_dic_log_list(L) ->
    put(?DIC_LOG_LIST, L).

