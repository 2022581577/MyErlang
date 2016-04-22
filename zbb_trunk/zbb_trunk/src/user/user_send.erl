%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.23
%%% @desc   : 玩家网络消息发送模块，网络发次缓存分玩家模块和广播消息(如地图)模块
%%%			  玩家模块在 user_send 中处理，广播模块在 send_cache中处理
%%%----------------------------------------------------------------------

-module(user_send).
-include("common.hrl").
-include("record.hrl").

-export([send_bin/2]).

-export([add_msg/2]).
-export([send_msg/1]).

-define(DIC_SEND_BUFFER, dic_send_buffer).  %% 消息发送缓冲区进程字典
-define(MAX_SEND_BUFFER_SIZE, 1400).        %% 最大发缓冲区大小(字节)
-define(USER_SEND_DELAY_TIME, 200).         %% 延迟200毫秒发送

	
%% @doc 直接把bin消息发给socket
send_bin(#user{other_data = #user_other{socket = Socket}} = _User, Bin) ->
    erlang:port_command(Socket, Bin).


%%% -----------------------------------------------
%%% 玩家进程内部产生的数据
%%% 放入到#user.other_data#user_other.send_buff中
%%% 一般用于前后端协议交互时，最后返回使用
%%% 注意顺序
%%% DataList为消息顺序列表，列表前面的为先发送的
%%% msg_list为队列，先进先出，列表后面的为先发送的
%%% 可以200ms定时清空msg_list
%%% -----------------------------------------------
add_msg(User, []) ->
    {ok, User};
add_msg(#user{other_data = #user_other{msg_list = MsgList} = UserOther} = User, [Data | L]) ->
    User1 = User#user{other_data = UserOther#user_other{msg_list = [Data | MsgList]}},
    add_msg(User1, L);
add_msg(User, Data) ->
    add_msg(User, [Data]).

send_msg(#user{other_data = #user_other{msg_list = []}} = User) ->
    {ok, User};
send_msg(#user{other_data = #user_other{msg_list = MsgList, socket = Socket} = UserOther} = User) ->
    {ok, IoList} = game_pack_send:pack(lists:reverse(MsgList)), 
    erlang:port_command(Socket, IoList),
    {ok, User#user{other_data = UserOther#user_other{msg_list = []}}}.


