%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.23
%%% @desc   : 玩家网络消息发送模块，网络发次缓存分玩家模块和广播消息(如地图)模块
%%%			  玩家模块在 user_send 中处理，广播模块在 send_cache中处理
%%%----------------------------------------------------------------------

-module(user_send).
-include("common.hrl").
-include("record.hrl").

-export([delay_send/2
        ,nodelay_send/1
        ,nodelay_send/2]).

-define(DIC_SEND_BUFFER, dic_send_buffer).  %% 消息发送缓冲区进程字典
-define(MAX_SEND_BUFFER_SIZE, 1400).        %% 最大发缓冲区大小(字节)
-define(USER_SEND_DELAY_TIME, 200).         %% 延迟200毫秒发送

%% @doc 添加发送消息，如果消息缓冲区已满，则立刻发送；未满则加入到缓冲区延迟发送
delay_send(#user{other_data = #user_other{socket = Socket}} = _User, Bin) ->
  	L = get_buffer(),
  	NewList = [Bin | L],
  	case iolist_size(NewList) > ?MAX_SEND_BUFFER_SIZE of
  		true ->
  			save_buffer([]),
  			erlang:port_command(Socket, lists:reverse(NewList));
  		false ->
  			save_buffer(NewList),
            case L of
                [] ->   
                    erlang:send_after(?USER_SEND_BUFFER_TIME, self(), {state_apply, ?MODULE, nodelay_send, []});
                _ ->
                    skip
            end
  	end.
	
%% @doc 立刻把消息发送出去(一般地图相关的消息才需要nodelay_send)
nodelay_send(#user{other_data = #user_other{socket = Socket}} = _User) ->
    case get_buffer() of
        [] ->   skip;
        L ->
            erlang:port_command(Socket, lists:reverse(L))
    end.
nodelay_send(#user{other_data = #user_other{socket = Socket}} = _User, Bin) ->
    erlang:port_command(Socket, Bin).

get_buffer() ->
	case get(?DIC_SEND_BUFFER) of
		undefined ->
			[];
		L ->
			L
	end.
save_buffer(List) ->
	put(?DIC_SEND_BUFFER,List).

