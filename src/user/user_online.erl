%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2013.06.27
%%% @desc   : 在线玩家处理模块
%%%----------------------------------------------------------------------

-module(user_online).
-include("common.hrl").
-include("record.hrl").

-export([
        add/1
        ,delete/1
        ,online_list/0
        ,pid_list/0
        ,id_list/0
%       ,send_to_all/1
        ,count/0
         ]).


add(#user_online{} = UserOnline) ->
    ets:insert(?ETS_USER_ONLINE, UserOnline).

delete(UserID) ->
    ets:delete(?ETS_USER_ONLINE, UserID).

online_list() ->
    ets:tab2list(?ETS_USER_ONLINE).

pid_list() ->
    L = ets:tab2list(?ETS_USER_ONLINE),
    [Pid || #user_online{pid = Pid} <- L].

id_list() ->
    L = ets:tab2list(?ETS_USER_ONLINE),
    [UserID || #user_online{user_id = UserID} <- L].

%send_to_all(Bin) ->
%    L = ets:tab2list(?ETS_USER_ONLINE),
%    [lib_send:send_to_pid(Pid,Bin) || #user_online{pid = Pid} <- L].

count() ->
    ets:info(?ETS_USER_ONLINE,size).


