%%-----------------------------------------------------
%% @Module:
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-9-3
%% @Desc:   protobuf解析
%%-----------------------------------------------------
-module(protobuf_encode).

-compile(export_all).
%%
%% Include files
%%
-include("common.hrl").

-define(PROTO_DATA_NO_ENCRYPT, 0).
-define(PROTO_DATA_RC4_ENCRYPT, 1).


%%
%% Exported Functions
%%
-export([
	 	 encode/2
		 ,encode/4
		 ,decode/1
	 	 ,decode/4
		]).

%% ==============================
%% encode 打包数据
%% ==============================
encode(Cmd, Data) ->
	encode(?PROTO_DATA_NO_ENCRYPT, <<>>, Cmd, Data).
encode(EncryptMode, Key, Cmd, Data) when is_tuple(Data) ->
	Mod = get_mod(Cmd),
	Mod1 = util:to_atom(Mod ++ "_pb"),
	BodyIoList = Mod1:encode(Data),
	PackageSequence = 0,
	IsZip = 0,
	%% 打包先压缩 再加密
	IoList1 = [encode_header(PackageSequence, Cmd), BodyIoList],
	EncryptBinary = encode_mode(EncryptMode, Key, IoList1),
    FinalBinary = [<<EncryptMode:8,IsZip:8>>, EncryptBinary],
    Len = iolist_size(FinalBinary),
	{ok, [<<Len:32>>, FinalBinary]}.

encode_header(PackageSequence, Cmd)->
	TimeStamp = util:unixtime(),
	<<TimeStamp:32, PackageSequence:32, Cmd:16>>.

encode_mode(?PROTO_DATA_RC4_ENCRYPT, Key, Binary)->
	State = crypto:stream_init(rc4, Key),
	{_, Bin} = crypto:stream_encrypt(State, Binary),
	Bin;
encode_mode(_, _Key, Binary)->
	Binary.


%% @doc 解析数据
%% @return {ok, Cmd, Data, TimeStamp}|{fail, Msg}
decode(<<EncryptMode:8, Key:8, DataBin/binary>>) ->
	decode(EncryptMode, Key, DataBin, "c2s").

decode(EncryptMode, Key, DataBin, Direction) ->
	case EncryptMode of
		?PROTO_DATA_NO_ENCRYPT ->
			decode_no_decrypt(DataBin, Direction);		
		?PROTO_DATA_RC4_ENCRYPT ->
			State = crypto:stream_init(rc4, Key),
		 	{_,DecodeBinary} = crypto:stream_decrypt(State, DataBin),	
	 		decode_no_decrypt(DecodeBinary, Direction)
	end.

%% <<TimeStamp:32, PackageSequence:32, Cmd:32>>

decode_no_decrypt(Binary, Direction)->
	%% 解包先解密 再解压
	<<TimeStamp:32, PackageSequence:32, Cmd:16, Rest/binary>> = Binary,
%%  	?DEBUG(connection, "TimeStamp:~w PackageSequence:~w Cmd:~w Rest:~w",[TimeStamp, PackageSequence, Cmd, Rest]),
	case Cmd div 1000 of
		61 when size(Rest)=:=0 -> {ok, admin, Cmd, [], TimeStamp};
        61 ->
			case rfc4627:decode(Rest) of
				{ok, {obj,Param}, []} -> {ok, admin, Cmd, Param, TimeStamp};
                {ok,[],[]} -> {ok, admin, Cmd, [], TimeStamp};
				_ ->
					{fail, unpack_json_error}
			end;
		_  ->
			TmpA = TimeStamp rem 59,
			TmpB = PackageSequence - TmpA,
			case check_packet_seq(TmpB) of
				true ->
					{ok, Cmd, ArgList} = decode_body(Cmd, Rest, Direction),
					{ok, Cmd, ArgList,TimeStamp};
				false ->
					{fail, error_sequence}
			end
	end.



%% @doc decode body
%% @return {ok, Cmd, ArgList}
decode_body(Cmd, DataBin, Direction) ->
	Mod = get_mod(Cmd),
	Mod1 = util:to_atom(Mod ++ "_pb"),
	ArgList = Mod1:decode(util:to_atom(lists:concat([Direction,Cmd])), DataBin),
	{ok, Cmd, ArgList}.

%%
%% Local Functions
%%
check_packet_encrypt(Cmd, Md5, Binary)->
	case check_cmd_need_encrypt(Cmd) of
		true ->
			util:md5(Binary) == Md5;
		false -> %不需要加密
			true
	end.

check_cmd_need_encrypt(_Cmd)->
	false.

%% @doc check seq
%% @return true|false
check_packet_seq(_Seq)->
%% 	case get_packet_seq() of
%% 		undefined ->
%% 			put_packet_seq(Seq),
%% 			true;
%% 		V->
%% 			put_packet_seq(Seq),
%% 			Seq == V + 1 
%% 	end.
	true.

get_packet_seq()->
 	get(packet_seq) .
put_packet_seq(Seq)->
	put(packet_seq, Seq).

pack_list(L) -> 
	[[Id,Value]||{Id,Value} <- L].

zip_compress(Binary) ->
	Len = erlang:iolist_size(Binary),
	case Len > 50 of
		true ->
			ZipCompress = zlib:compress(Binary),
			ZipLen = byte_size(ZipCompress),
			{1, ZipLen, ZipCompress};
		_ ->
			{0, Len, Binary} 
	end.

get_mod(Cmd) ->
    H1 = Cmd div 10000,
    H2 = (Cmd - H1 * 10000) div 1000,
    "proto_" ++ [$0+H1,$0+H2].



