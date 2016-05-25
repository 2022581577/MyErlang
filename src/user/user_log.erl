%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.04.22
%%% @desc   : 玩家日志 在定时和下线save的时候在把日志发给srv_log
%%%           保证即使在崩服时玩家数据和也日志一致
%%%----------------------------------------------------------------------

-module(user_log).
-include("common.hrl").
-include("record.hrl").

-export([add_log/2]).
-export([save/1]).

%% @doc 添加玩家日志到log_list中
%% 玩家进程内部调用
add_log(#user{other_data = #user_other{log_list = LogList} = UserOther} = User, Log) ->
    User1 = User#user{other_data = UserOther#user_other{log_list = [Log | LogList]}},
    {ok, User1}.

%% @doc 定时或下线时，日志发送到srv_log中
save(#user{other_data = #user_other{log_list = LogList} = UserOther} = User) ->
    srv_log:add_log(LogList),
    User1 = User#user{other_data = UserOther#user_other{log_list = []}},
    {ok, User1}.

