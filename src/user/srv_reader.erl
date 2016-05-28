%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.15.
%%% @desc   : 网络处理层
%%%----------------------------------------------------------------------

-module(srv_reader).
-author('zhongbinbin <binbinjnu@163.com>').
-behaviour(behaviour_gen_server).
-compile(inline).

-include("common.hrl").
-include("record.hrl").

-define(FLASH_POLICY_REQ, <<"<pol">>).
-define(FLASH_POLICY_REQ_LEN, 22).
-define(FLASH_POLICY_FILE, <<"<cross-domain-policy><allow-access-from domain='*' to-ports='*' /></cross-domain-policy>\0">>).
-define(LIMIT_PACKET_NUM,1000).     %% 登陆流程数据包上限

-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).

-export([start_link/1,stop/1]).


start_link(Type) ->
    behaviour_gen_server:start_link(?MODULE, [Type], []).

stop(Pid) ->
    gen_server:cast(Pid,stop).

do_init([Type]) ->
    %% ?INFO("Init ~w",[?MODULE]),
	packet_encode:init_packet_index(),
	{ok, #reader_state{type = Type}}.

do_cast({set_socket,Socket},State) ->    
    ?INFO("Set Socket:~w",[Socket]),    
    %% 开始接收消息头长度为4的消息
    async_recv(Socket,?HEADER_LENGTH,?HEART_TIMEOUT),    
    %lib_login:save_reader_info(#reader_info{socket = Socket}),    
    {noreply,State#reader_state{socket = Socket}};

do_cast(Info, State) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
	{noreply, State}.

do_call(Info, _From, State) -> 
    ?WARNING("Not done do_call:~w",[Info]),
	{reply, ok, State}.

%%% inet_async,接收prim_inet:async_recv的反馈
%% 接收安全沙箱信息
do_info({inet_async,Socket,_Ref,{ok,?FLASH_POLICY_REQ}},#reader_state{socket = Socket} = State) ->
    %?INFO("++++++++++++++++++ Send Prolicy ++++++++++++++++",[]),
    gen_tcp:send(Socket,?FLASH_POLICY_FILE),
	% async_recv(Socket,?FLASH_POLICY_REQ_LEN,?HEART_TIMEOUT),
    %% 5s后关闭连接，立刻关可能会导致消息没发出就关闭socket
    erlang:send_after(5000,self(),stop),
    {noreply,State};

%% 数据包不能大于 2^16-1(64K)
do_info({inet_async,Socket,_Ref,{ok,<<0:16,Len:16>>}},#reader_state{socket = Socket,packet_len = 0} = State) ->
    ?INFO("Len:~w", [Len]),
    %% _NewRef = async_recv(Socket,Len - ?HEADER_LENGTH ,?HEART_TIMEOUT),
    %% Len约定是已经去掉了消息头信息的长度
    _NewRef = async_recv(Socket, Len, ?HEART_TIMEOUT),  
    {noreply,State#reader_state{packet_len = Len}};

do_info({inet_async,Socket,_Ref,{ok,Bin}},#reader_state{socket = Socket,packet_len = 0} = State) ->
    ?INFO("Recevie Packet Length ~w,Bin:~w",[size(Bin),Bin]),
    %% 匹配不成功，在packet为0时收到非{ok,<<0:16,Len:16>>}的数据，继续接收消息头长度为4的消息
    _NewRef = async_recv(Socket,?HEADER_LENGTH,?HEART_TIMEOUT),
    {noreply,State#reader_state{packet_len = 0}};

%% 接收协议体数据
do_info({inet_async,Socket,_Ref,{ok,Bin}},#reader_state{socket = Socket} = State) ->
    ?INFO("Recevie Packet Length ~w,Bin:~w",[size(Bin),Bin]),
	case protobuf_encode:decode(Bin) of
		{Cmd,Data} ->
            %% lib_packet_monitor:check_packet_count(Cmd),
			case routing(State, Cmd, Data) of
                {ok, State1} ->
                    _NewRef = async_recv(Socket,?HEADER_LENGTH,?HEART_TIMEOUT),
                    {noreply, State1#reader_state{packet_len = 0}};
                {?FALSE, Res} ->
                    %% 登陆出错了
                    ?WARNING("Error Socket:~w,Ip:~p,Res:~w",[Socket,util:get_ip(Socket),Res]),
                    {stop,normal,State}
            end;
		Error ->
			?WARNING("Receive Data Error:~w,Ip:~p",[Error,util:get_ip(Socket)]),
			{stop,normal,State}
	end;
	
%% 接收出错处理
do_info({inet_async,_Socket,_Ref,{error,closed}},State) ->
    %% ?INFO("Socket Close...",[]),
    {stop,normal,State};

%% 接收数据
do_info({inet_async,_Socket,_Ref,{error,Reason}},State) ->
    ?WARNING("Socket Error:~w",[Reason]),
    {stop,normal,State};

do_info({inet_reply,_Socket,ok},State) ->
    {noreply,State};


do_info(Info, State) -> 
    ?WARNING("Not done do_info:~w",[Info]),
	{noreply, State}.

do_terminate(_Reason, #reader_state{socket=Socket}) ->
	%% ?INFO("~w stop...",[?MODULE]),
	case is_port(Socket) of
		true ->
			gen_tcp:close(Socket);
		false ->
			skip
	end,
    ok.

async_recv(Sock, Length, Timeout) when is_port(Sock) ->
    case prim_inet:async_recv(Sock, Length, Timeout) of
        {error, Reason} -> throw({Reason});
        {ok, Res}       -> Res
    end.

routing(State, Cmd, Bin) ->
    case Cmd div 1000 of
        10 ->
            {ok, Data} = pt_10:read(Cmd, Bin),
            pp_login:handle(Cmd, Data, State);
        _ ->
            {?FALSE, routing_error}
    end.

%% 检查数据包总数,是否高于上限
%check_cmd(Socket) ->
%    {_Time,Packet,_NewIndex,_NewIndex} = packet_encode:get_packet_index(),
%    case Packet > ?LIMIT_PACKET_NUM of
%        true ->
%            ?WARNING("To Many Login Packet:~w,IP:~s",[Packet,util:get_ip(Socket)]),
%            stop(self());
%        false ->
%            skip
%    end.
