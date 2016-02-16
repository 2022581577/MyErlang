%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2013.06.18
%%% @desc   : 协议包解密处理
%%%----------------------------------------------------------------------
-module(packet_encode).
-author('zhongbinbin <binbinjnu@163.com>').
-include("common.hrl").

-define(PACKET_KEY,<<16#E1A8C7A63CDC721C:64>>).	%% 定义密钥
-define(PACKET_KEY_INVC,<<0:64>>).		%% 定义密钥
-define(PACKET_INDEX,packet_index).		%% 客户端上来的序列号，{时间，包序列}

-export([decode/1,
         decode/2,
		 encode/1
		]).
-export([init_packet_index/0
		 ,save_packet_index/4
         ,get_packet_index/0
%         reset_packet_index/1
		]).

%% @doc 客户端消息解密,返回 {Cmd,Data} 或 error_encry,error_crc32,packet_error,error_data
%-ifdef(DEBUG).
%%% DEBUG版本不验证，方便测试
%decode(Data) ->
%    decode(Data,?PACKET_KEY_INVC).
%decode(<<_Crc:32,_Encry:8/binary-unit:8,Data/binary>>,_Key) ->
%    decode_cmd_body(Data);
%decode(Data,_Key) ->
%	?WARNING("decode Error Data:~w",[Data]),
%	error_data.
%-else.
decode(Data) ->
    decode(Data,?PACKET_KEY).
decode(<<Crc:32,Encry:8/binary-unit:8,Data/binary>>,Key) ->
	case erlang:crc32(Data) of
		Crc ->
			case check_encry(Encry,Key) of
				true ->
					decode_cmd_body(Data);
				false ->
					error_encry
			end;
		Error ->
			?WARNING("Error Crc32:~w,ClientCrc32:~w,Data:~w",[Error,Crc,Data]),
			error_crc32
	end;
decode(Data,_Key) ->
	?WARNING("decode Error Data:~w",[Data]),
	error_data.

%% @doc 获取数据Crc信息
check_encry(Encry,Key) ->
	<<Time:32,Index:32>> = crypto:block_decrypt(des_cbc,Key,?PACKET_KEY_INVC, Encry),
	{ServerTime,ServerIndex,SetIndex,NewIndex} = get_packet_index(),
	save_packet_index(Time,Index,SetIndex,NewIndex),
	%% ?INFO("Time:~w,ServerTime:~w,Index:~w,ServerIndex:~w",[Time,ServerTime,Index,ServerIndex]),
	Time >= ServerTime andalso Index == (ServerIndex + 1).
%-endif.

%% 24位长度的包
decode_cmd_body(<<0:8,_Len:24,Cmd:16,Data/binary>>) ->
    {Cmd,Data};
decode_cmd_body(<<_Len:8,Cmd:16,Data/binary>>) ->
    %% 长度检查
    {Cmd,Data};
decode_cmd_body(Data) ->
	?WARNING("Paceck Error,Data:~w",[Data]),
	packet_error.

%% @doc 数据包加密
encode(Bin) ->
	Encry = get_encry(),
	Crc32 = erlang:crc32(Bin),
	NewBin = <<Crc32:32,Encry/binary,Bin/binary>>,
	Len = byte_size(NewBin),
	<<Len:32,NewBin/binary>>.

get_encry() ->
	{Time,Index,SetIndex,NewIndex} = get_packet_index(),
	save_packet_index(Time + 1,Index + 1,SetIndex,NewIndex),
	crypto:block_encrypt(des_cbc,?PACKET_KEY,?PACKET_KEY_INVC,<<Time:32,Index:32>>).

%% -----------------------------------------------------
init_packet_index()->
	save_packet_index(0,0,0,0).
get_packet_index() ->
	case get(?PACKET_INDEX) of
		{Time,Index,SetIndex,NewIndex} ->
			{Time,Index,SetIndex,NewIndex};
		undefined ->
			{0,0,0,0}
	end.
save_packet_index(Time,Index,SetIndex,NewIndex) ->
    case Index of
        SetIndex ->
            put(?PACKET_INDEX,{Time,NewIndex,0,0});
        _ ->
            put(?PACKET_INDEX,{Time,Index,SetIndex,NewIndex})
    end.
%	
%reset_packet_index(UserID) ->
%    case get_packet_index() of
%        {Time,Index,0,N} when N > 0 ->
%            SetIndex = Index + util:rand(30,100),
%            NewIndex = util:rand(10,10000),
%            save_packet_index(Time,Index,SetIndex,NewIndex),
%            %% ?INFO("+++++++++++++UserID:~w,Index:~w,SetIndex:~w,NewIndex:~w +++++++++++++",[UserID,Index,SetIndex,NewIndex]),
%            {ok,Bin} = pt_11:write(?PP_USER_PACKET_INDEX,[SetIndex + 1,NewIndex + 1]),
%            lib_send:send_to_pid(UserID,Bin);
%        {Time,Index,0,_N}  ->
%            save_packet_index(Time,Index,0,1);
%        _ ->
%            skip
%    end.


