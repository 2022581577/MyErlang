%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   :
%%%------------------------------------------------------------------------

-module(user_event).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([add_event/2]).
-export([send_event/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================

%% @doc 添加事件，在事务处理最后发送事件消息
%% 一般是玩家cast事件，调用srv_user:cast_state_apply(UserX, Callback)
%% 或者调用srv_user:cast_apply(UserX, Callback)
add_event(#user{other_data = #user_other{event_list = EventList} = UserOther} = User, 
    {cast_state_apply, _UseX, _CallBack} = Event) ->
    EventList1 = [Event | EventList],
    User1 = User#user{other_data = UserOther#user_other{event_list = EventList1}},
    {ok, User1};
add_event(#user{other_data = #user_other{event_list = EventList} = UserOther} = User, 
    {cast_apply, _UseX, _CallBack} = Event) ->
    EventList1 = [Event | EventList],
    User1 = User#user{other_data = UserOther#user_other{event_list = EventList1}},
    {ok, User1};
add_event(User, ErrorEvent) ->
    ?WARNING("user event add error event! ErrorEvent:~w", [ErrorEvent]),
    {ok, User}.


%% @doc 发送事件
send_event(#user{other_data = #user_other{event_list = EventList} = UserOther} = User) ->
    EventList1 = lists:reverse(EventList),
    [srv_user:Fun(UserX, Callback) || {Fun, UserX, Callback} <- EventList1],
    User1 = User#user{other_data = UserOther#user_other{event_list = []}},
    {ok, User1}.


%% ========================================================================
%% Local functions
%% ========================================================================

