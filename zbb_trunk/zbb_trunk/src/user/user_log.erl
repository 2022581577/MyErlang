%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.04.22
%%% @desc   : 玩家日志
%%%----------------------------------------------------------------------

-module(user_load).
-include("common.hrl").
-include("record.hrl").

-export([add_log/2]).
-export([send_log/1]).

%% @doc 添加玩家日志到log_list中
%% 玩家进程内部调用
add_log(#user{other_data = #user_other{log_list = LogList} = UserOther} = User, Log) ->
    User1 = #user{other_data = UserOther#user_other{log_list = [Log | LogList]}},
    {ok, User1}.

%% @doc 把log_list中的日志发送给srv_log
%% 玩家进程内部调用，tiny_loop中调用
%% 玩家下线时也需要调用
send_log(#user{other_data = #user_other{log_list = []}} = User) ->
    {ok, User};
send_log(#user{other_data = #user_other{log_list = LogList} = UserOther} = User) ->
    srv_log:add_log(LogList),
    User1 = User#user{other_data = UserOther#user_other{log_list = []}},
    {ok, User1}.

