%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : Record 转换模块
%%%----------------------------------------------------------------------

-module(lib_record).
-author('kongqingquan <kqqsysu@gmail.com>').

-export([fields_list/1]).
-export([fields_value/1]).
-export([print_record/1]).

-include("common.hrl").
-include("record.hrl").

%% @doc 获取字段列表
fields_list(RecordName) ->
    case lists:keyfind(RecordName, 1, ?ALL_RECORD_FIELDS) of
        {RecordName, Fields} ->
            {ok, Fields};
        _ ->
            ?FALSE
    end.

%% @doc 将record转换为 [{field,Val} ...] 形式
fields_value(Record) ->
    [RecordName | Value] = tuple_to_list(Record),
    case fields_list(RecordName) of
        {ok, Fields} ->
            [RecordName | lists:zip(Fields, Value)];
        false ->
            ?WARNING("Get Record Fields Value Fail,Record:~w",[Record]),
            no_defined
    end.

print_record(Record) ->
    FieldsValue = fields_value(Record),
    io:format("~p~n",[FieldsValue]).

%fields_value(user_state,UserStatus) ->
%    Fields = ?RECORD_FIELDS(user_state),
%    do_fields_value(Fields,UserStatus).
%do_fields_value(Fields,Val) ->
%    [RecordName | Val2] = tuple_to_list(Val),
%    [RecordName | lists:zip(Fields,Val2)].
