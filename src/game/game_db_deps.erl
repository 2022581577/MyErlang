%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 五月 2016 14:47
%%%-------------------------------------------------------------------
-module(game_db_deps).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([record_to_db/1]).
-export([db_to_record/1]).
-export([check_dirty/1]).
-export([add_mapping/1]).
-compile(export_all).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
%% 正常record的字段转换成存db的字符类型
record_to_db(#user{} = User) ->
    User#user{other_data = <<>>};
record_to_db(#global_data{global_key = Key, value = Value} = GlobalData) ->
    Key1    = util:term_to_bitstring(Key),
    Value1  = util:term_to_bitstring(Value),
    GlobalData#global_data{global_key = Key1, value = Value1};
record_to_db(Record) ->
    Record.


%% db的字符类型转换成正常的record字段
db_to_record(#global_data{global_key = Key, value = Value} = GlobalData) ->
    Key1    = util:bitstring_to_term(Key),
    Value1  = util:bitstring_to_term(Value),
    GlobalData#global_data{global_key = Key1, value = Value1};
db_to_record(Record) ->
    Record.


%% 判断is_dirty
check_dirty(#global_data{is_dirty = IsDirty} = Record) ->
    {IsDirty =:= 1, Record#global_data{is_dirty = 0}};

check_dirty(#user_item{is_dirty = IsDirty} = Record) ->
    {IsDirty =:= 1, Record#user_item{is_dirty = 0}};

check_dirty(#user_misc{is_dirty = IsDirty} = Record) ->
    {IsDirty =:= 1, Record#user_misc{is_dirty = 0}};

check_dirty(Record) ->
    {?TRUE, Record}.


%% 有些数据需要添加映射信息
add_mapping(#user{user_id = UserID, acc_name = AccName}) ->
    add_account_mapping(AccName, UserID);
add_mapping(_) ->
    skip.

%% ========================================================================
%% Local functions
%% ========================================================================
add_account_mapping(AccName, UserID) ->
    AccountInfo1 =
        case game_db:get_account_info(AccName) of
            {ok, #account_info{user_ids = UserIDs} = AccountInfo} ->
                AccountInfo#account_info{user_ids = [UserID | lists:delete(UserID,UserIDs)]};
            false ->
                #account_info{acc_name = AccName, user_ids = [UserID]}
        end,
    ets:insert(?ETS_ACCOUNT_INFO, AccountInfo1).


