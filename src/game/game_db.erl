%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 五月 2016 17:09
%%%-------------------------------------------------------------------
-module(game_db).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").
-include("mmdb.hrl").

%% export
-export([init/0]).
-export([preload/0]).
-export([get_account_info/1]).
-export([new_value/1]).
-export([new_value/3]).
-export([get_value/2]).
-export([save_value/1]).
-export([save_value/2]).
-export([del_value/2]).
-export([del_value/3]).
-export([load_all_value/1]).
-export([load_all_value/2]).

%% record and define

%% ========================================================================
%% API functions
%% ========================================================================
%% 对应内存数据库的ets初始化
init() ->
    ets:new(?ETS_ACCOUNT_INFO,[{keypos,#account_info.acc_name} | ?ETS_OPT]),
    [ets:new(util:to_ets_name(Name), [{keypos, KeyPos} | ?ETS_OPT])
        || #durable_record{rec_name = Name, ets_key = KeyPos} <- ?DURABLE_RECORD_LIST],
    ok.


%% 对应内存数据库的预加载
preload() ->
    [load_all_value(DR)
        || #durable_record{is_preload = ?TRUE} = DR <- ?DURABLE_RECORD_LIST],
    ok.


%% @doc 特殊ets信息，玩家账号和id的映射表
get_account_info(AccName) ->
    case ets:lookup(?ETS_ACCOUNT_INFO, AccName) of
        [#account_info{} = AccountInfo] ->
            {ok, AccountInfo};
        [] ->
            false
    end.

%% 新建信息存到ets和数据库中
new_value(Record) ->
    db_action(insert, Record).

new_value(EtsName, Key, RecordList) ->
    db_batch_action(insert, RecordList, Key, EtsName).


%% 获取数据，ets中有直接取ets，ets中没有则根据规则取数据库
get_value(EtsName, Key) ->
    RecName = util:from_ets_name(EtsName),
    case lists:keyfind(RecName, #durable_record.rec_name, ?DURABLE_RECORD_LIST) of
        #durable_record{db_key = KeyName, is_preload = IsPreLoad, is_list = IsList} ->
            case ets:lookup(EtsName, Key) of
                [{Key, Value}] when IsList andalso is_list(Value) ->
                    ?DEBUG("1"),
                    {ok, Value};
                [Value] when not IsList ->
                    ?DEBUG("Value:~w", [Value]),
                    case is_record(Value, RecName) of
                        ?TRUE ->
                            {ok, Value};
                        _ ->
                            ?WARNING("get ~w value false! Key:~w, IsList:~w Value:~w",
                                [EtsName, Key, IsList, Value]),
                            ?FALSE
                    end;
                _ when IsPreLoad ->    %% 已从数据库加载，如果ets没有数据，返回false
                    ?WARNING("Preloaded but no data! EtsName:~w, Key:~w", [EtsName, Key]),
                    ?FALSE;
                _ ->    %%  未从数据库加载，当前可加载
                    db_get(RecName, KeyName, Key, IsList)
            end;
        _ ->
            ?WARNING("get ~w value false, no durable record!", [EtsName]),
            ?FALSE
    end.

%% 保存数据到ets和数据库
save_value(Record) when is_tuple(Record) ->
    db_action(update, Record);
save_value(RecordList) when is_list(RecordList) ->
    save_value(?UNDEFINED, RecordList).
%% Key：undefined时表示为ets中的多条record 如 ets_global_data
%% Key：ets_key = 1时为{Key, RecordList}格式中的Key  如 {UserID, ItemList}
save_value(Key, RecordList) when is_list(RecordList) ->
    db_batch_action(replace, RecordList, Key).

%% 删除数据(有些ets不需要处理的)(key如果需要term_to_bitstring的需要在外层自行处理)
del_value(EtsName, Key) ->
    del_value(EtsName, Key, Key).
del_value(EtsName, Key, DbKey) ->
    RecName = util:from_ets_name(EtsName),
    case lists:keyfind(RecName, #durable_record.rec_name, ?DURABLE_RECORD_LIST) of
        #durable_record{db_key = KeyName, is_list = IsList} ->
            db_del(RecName, KeyName, Key, DbKey, IsList);
        _ ->
            ?WARNING("del value false, no durable record! EtsName:~w, Key:~w", [EtsName, Key])
    end,
    ok.


%% ========================================================================
%% Local functions
%% ========================================================================
%% 根据数据库名加载多有数据并转化成游戏内使用的record，存ets
load_all_value(#durable_record{rec_name = Name, is_list = ?FALSE}) ->
    load_all_value(Name);
load_all_value(#durable_record{rec_name = Name, db_key = KeyName}) ->
    load_all_value(Name, KeyName);

%% 加载ets单条数据格式为#record{}的数据
load_all_value(Name) ->
    DbValueList = edb_util:get_all(Name),
    EtsName     = util:to_ets_name(Name),
    RecordList =
        [begin
             DbRecord   = util:to_tuple([Name | E]),
             Record     = game_db_deps:db_to_record(DbRecord),
             add_mapping(Record),
             Record
         end || E <- DbValueList],
    ets:insert(EtsName, RecordList),
    {ok, RecordList}.

%% 加载ets单条数据格式{Key, RecordList}的数据
load_all_value(Name, KeyName) ->
    %% 先获取
    KeyList = edb_util:execute(io_lib:format("select distinct ~s from ~s;", [KeyName, Name])),
    F = fun([Key], AccIn) ->
        {ok, RecordList} = db_get(Name, KeyName, Key, ?TRUE),
        [{Key, RecordList} | AccIn]
        end,
    ValueList = lists:foldl(F, [], KeyList),
    {ok, ValueList}.


db_get(TabName, KeyName, Key, _IsList = ?TRUE) ->   %% 列表
    DbValueList = edb_util:get_all(TabName, [{KeyName, Key}]),
    RecordList  =
        [begin
             DbRecord  = util:to_tuple([TabName | E]),
             game_db_deps:db_to_record(DbRecord)
         end || E <- DbValueList],
    ets:insert(util:to_ets_name(TabName), {Key, RecordList}),
    {ok, RecordList};
db_get(TabName, KeyName, Key, _IsList) ->           %% 非列表
    case edb_util:get_one(TabName, [{KeyName, Key}]) of
        Values when is_list(Values) ->
            DbRecord  = util:to_tuple([TabName | Values]),
            Record    = game_db_deps:db_to_record(DbRecord),
            ets:insert(util:to_ets_name(TabName), Record),
            {ok, Record};
        _ ->
            ?WARNING("No such value! TabName:~w, KeyName:~w, KeyValue:~w", [TabName, KeyName, Key]),
            ?FALSE
    end.


%% 有些数据需要添加映射信息
add_mapping(#user{user_id = UserID, acc_name = AccName}) ->
    add_account_mapping(AccName, UserID);
add_mapping(_ ) ->
    skip.

add_account_mapping(AccName, UserID) ->
    AccountInfo1 =
        case get_account_info(AccName) of
            #account_info{user_ids = UserIDs} = AccountInfo ->
                AccountInfo#account_info{user_ids = [UserID | lists:delete(UserID,UserIDs)]};
            false ->
                #account_info{acc_name = AccName, user_ids = [UserID]}
        end,
    ets:insert(?ETS_ACCOUNT_INFO, AccountInfo1).


%% 单条操作 insert or replace or update
db_action(Action, Record)
    when Action =:= insert orelse Action =:= replace orelse Action =:= update ->
    DbRecord = game_db_deps:record_to_db(Record),
    [RecName | Fields] = lib_record:fields_value(DbRecord),
    EtsName = util:to_ets_name(RecName),
    %% 先进行ets操作，防止数据库操作时间过长
    ets:insert(EtsName, Record),

    case Action of
        update ->   %% update操作的话Fields的第一个字段为主键
            [KeyField | Fields1] = Fields,
            edb_util:Action(RecName, Fields1, [KeyField]);
        _ ->
            edb_util:Action(RecName, Fields)
    end,
    ok.


%% 批量操作 insert or replace (批量一般不需要update操作)
db_batch_action(Action, RecordList, EtsKey) ->
    db_batch_action(Action, RecordList, EtsKey, ?UNDEFINED).

db_batch_action(Action, RecordList, EtsKey, DefEtsName)
    when Action =:= insert orelse Action =:= replace ->
    F = fun(Record, {NameAccIn, SqlAccIn, EtsAccIn}) ->
        case game_db_deps:check_dirty(Record) of
            {?TRUE, Record1} ->
                DbRecord        = game_db_deps:record_to_db(Record1),
                [RecName | ValueList] = util:to_list(DbRecord),
                ValueSql = edb_util:make_value_sql(ValueList),
                Head = ?IF(SqlAccIn =:= [], "(", ", ("),
                ValueSql1 = Head ++ ValueSql ++ ")",
                {RecName, [ValueSql1 | SqlAccIn], [Record1 | EtsAccIn]};
            _ ->
                {NameAccIn, SqlAccIn, [Record | EtsAccIn]}
        end
        end,
    case lists:foldl(F, {?UNDEFINED, [], []}, RecordList) of
        {?UNDEFINED, _SqlList, _EtsList} when DefEtsName =/= ?UNDEFINED ->
            %% 空list，但有EtsName
            case EtsKey of
                ?UNDEFINED ->   %% 一条记录就为1条ets信息
                    skip;
                _ ->            %% ets信息结构为{Key, ValueList}
                    ets:insert(DefEtsName, {EtsKey, []})
            end;
        {?UNDEFINED, _SqlList, _EtsList} ->
            ?WARNING("db_batch_action nothing, RecordList:~w", [RecordList]);
        {TabName, SqlList, EtsList} ->
            %% 先进行ets操作，防止数据库操作时间过长
            EtsName = util:to_ets_name(TabName),
            case EtsKey of
                ?UNDEFINED ->   %% 一条记录就为1条ets信息
                    ets:insert(EtsName, EtsList);
                _ ->            %% ets信息结构为{Key, ValueList}
                    ets:insert(EtsName, {EtsKey, EtsList})
            end,

            SqlHead = io_lib:format("~p into ~p values ", [Action, TabName]),
            Sql = [SqlHead | lists:reverse(SqlList)],
            edb_util:execute(Sql)
    end,
    ok.


%% 删除操作
db_del(TabName, KeyName, Key, DbKey, IsList) ->
    edb_util:delete(TabName, [{KeyName, DbKey}]),
    case IsList of
        ?TRUE ->    %% 一般是list的ets格式为{Key, RecordList}，删除单条数据时不需要删ets
            skip;
        _ ->
            EtsName = util:to_ets_name(TabName),
            ets:delete(EtsName, Key)
    end,
    ok.