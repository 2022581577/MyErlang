%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2014.11.10
%%% @desc   : 获取record信息
%%%----------------------------------------------------------------------

%%% <pre>
%%% get_value(field_name, Record) ->
%%%     Record#record_name.field_name.
%%%
%% set_value(field_name, Value, Record) when is_record(Record, record_name) ->
%%     Record#record_name{field_name = Value}.
%%
%%% records() ->
%%%     [record_name1, record_name2, ...].
%%%
%%% fields(record_name) ->
%%%     [field_name1, field_name2, ...].
%%%
%%% new_record(record_name) ->
%%%     #record_name{}.
%%% </pre>
%%%

-module(record_info).
-author('kongqingquan <kqqsysu@gmail.com>').

-include("record.hrl").

-compile({parse_transform, dynarec}).

-export([]).
