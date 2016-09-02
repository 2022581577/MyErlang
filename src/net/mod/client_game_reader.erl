%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.15.
%%% @desc   : 游戏服网络处理层
%%%----------------------------------------------------------------------

-module(client_game_reader).
-author('zhongbinbin <binbinjnu@163.com>').
-behaviour(behaviour_client).

-include("common.hrl").
-include("record.hrl").


-export([init/0]).
-export([set_socket/2]).
-export([handle/2]).

init() ->
    #game_reader_state{}.

set_socket(State, Socket) ->
    State#game_reader_state{socket = Socket}.

handle(State, Bin) ->
    case protobuf_encode:decode(Bin) of
        {Cmd, Data} ->
            case routing(State, Cmd, Data) of
                {ok, State1} ->
                    {ok, State1};
                {?FALSE, Res} ->
                    {?FALSE, Res}
            end;
        Error ->
            {?FALSE, Error}
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
