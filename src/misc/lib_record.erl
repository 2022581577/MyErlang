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

%% 需要record_info转换的record名
-define(RECORD_NAME_FIELDS(FieldsRecordName), {FieldsRecordName, ?RECORD_FIELDS(FieldsRecordName)}).

-define(ALL_RECORD_FIELDS,
    [?RECORD_NAME_FIELDS(global_data)
    ,?RECORD_NAME_FIELDS(user)
    ,?RECORD_NAME_FIELDS(user_item)
    ,?RECORD_NAME_FIELDS(guild)
    ]).

%% @doc 获取字段列表
fields_list(RecName) ->
    case lists:keyfind(RecName, 1, ?ALL_RECORD_FIELDS) of
        {RecName, Fields} ->
            {ok, Fields};
        _ ->
            ?FALSE
    end.

%% @doc 将record转换为 [{field,Val} ...] 形式
fields_value(Record) ->
    [RecName | Value] = tuple_to_list(Record),
    case fields_list(RecName) of
        {ok, Fields} ->
            [RecName | lists:zip(Fields, Value)];
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
