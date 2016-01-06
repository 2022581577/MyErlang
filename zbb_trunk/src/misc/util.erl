%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 
%%-----------------------------------------------------

-module(util).
-include("common.hrl").

-export([log_filename/1]).

-export([to_integer/1
        ,to_binary/1
        ,to_float/1
        ,to_atom/1
        ,to_list/1
        ,f2s/1
        ,one_to_two/1
        ,to_utf8_list/1
        ,term_to_string/1
        ,term_to_bitstring/1
        ,string_to_term/1
        ,bitstring_to_term/1
        ]).

%% 游戏输出日志文件名
log_filename(BaseDir) ->
    log_filename(lists:concat([BaseDir,?CONFIG(server_type),"_",?CONFIG(platform),"_",?CONFIG(prefix),?CONFIG(server_id),"_"]), ".log").

log_filename(FilePrefix, FileSuffix) ->
    {{Y, M, D}, {H, MM, S}} = erlang:localtime(),
    NewM = one_to_two(M),
    NewD = one_to_two(D),
    NewH = one_to_two(H),
    NewMM = one_to_two(MM),
    NewS = one_to_two(S),
    lists:concat([FilePrefix,Y,NewM,NewD,"-",NewH,NewMM,NewS,FileSuffix]).

one_to_two(One) ->
    Two = io_lib:format("~2..0B", [One]),
    lists:flatten(Two).

%%f2s(N) when is_integer(N) ->
%%    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]), A.

%% @doc 转换为AcsII list(一般传入binary)
to_utf8_list(Msg) ->
    {ok, L} = asn1rt:utf8_binary_to_list(to_binary(Msg)),
    L.

term_to_string(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~w",[Term]))).

term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).

string_to_term(String) ->
    case erl_scan:string(String ++ ".") of
      {ok, Tokens, _} ->
          case erl_parse:parse_term(Tokens) of
              {ok, Term} -> 
                  Term;
              Err -> 
                  ?WARNING2("Parse Term Error,String:~w,Err:~w",[String,Err]),
                  undefined
          end;
      Error -> 
          ?WARNING("erl Scan Error,String:~w,Err:~w",[String,Error]),
          undefined
    end.

bitstring_to_term(undefined) -> undefined;
bitstring_to_term(BitString) when is_binary(BitString) ->
    string_to_term(binary_to_list(BitString)).

to_integer(Msg) when is_integer(Msg) -> Msg;
to_integer(Msg) when is_binary(Msg) ->
    Msg2 = binary_to_list(Msg), list_to_integer(Msg2);
to_integer(Msg) when is_list(Msg) ->
    list_to_integer(Msg);
to_integer(Msg) when is_float(Msg) -> round(Msg);
to_integer(_Msg) -> throw(other_value).

to_float(Msg) when is_integer(Msg) -> Msg;
to_float(Msg) when is_binary(Msg) ->
    to_float(to_list(Msg));
to_float(Msg) when is_float(Msg) -> Msg;
to_float(Msg) when is_list(Msg) -> 
    try 
        erlang:list_to_float(Msg)
    catch _:_ ->
        erlang:list_to_integer(Msg)
    end;
to_float(_Msg) -> throw(other_value).

to_binary(Msg) when is_binary(Msg) -> Msg;
to_binary(Msg) when is_atom(Msg) ->
    list_to_binary(atom_to_list(Msg));
to_binary(Msg) when is_list(Msg) -> list_to_binary(Msg);
to_binary(Msg) when is_integer(Msg) ->
    list_to_binary(integer_to_list(Msg));
to_binary(Msg) when is_float(Msg) ->
    list_to_binary(f2s(Msg));
to_binary(Msg) when is_tuple(Msg) ->
    list_to_binary(tuple_to_list(Msg));
to_binary(_Msg) -> throw(other_value).

to_atom(Msg) when is_atom(Msg) -> Msg;
to_atom(Msg) when is_binary(Msg) ->
    list_to_atom2(binary_to_list(Msg));
to_atom(Msg) when is_list(Msg) ->
    list_to_atom2(Msg);
to_atom(_) -> throw(other_value).

list_to_atom2(List) when is_list(List) ->
    case catch list_to_existing_atom(List) of
      {'EXIT', _} -> erlang:list_to_atom(List);
      Atom when is_atom(Atom) -> Atom
    end.

to_list(Msg) when is_list(Msg) -> Msg;
to_list(Msg) when is_atom(Msg) -> atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) -> binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) ->
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) -> f2s(Msg);
to_list(Msg) when is_tuple(Msg) -> tuple_to_list(Msg);
to_list(_) -> throw(other_value).
