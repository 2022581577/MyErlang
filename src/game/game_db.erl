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

%% record and define

%% ========================================================================
%% API functions
%% ========================================================================
%% 对应内存数据库的ets初始化
init() ->
    ets:new(?ETS_ACCOUNT_INFO,[{keypos,#account_info.acc_name} | ?ETS_OPT]),
    [ets:new(util:ets_name(Name), [{keypos, KeyPos} | ?ETS_OPT])
        || #durable_record{rec_name = Name, ets_key = KeyPos} <- ?DURABLE_RECORD_LIST],
    ok.


%% 对应内存数据库的预加载
preload() ->
    [load_all_value(RecName)
        || #durable_record{rec_name = RecName
                           ,is_preload = ?TRUE} <- ?DURABLE_RECORD_LIST],
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
                [Value] when is_record(Value, RecName) ->
                    {ok, Value};
                [Value] ->
                    ?WARNING("get ~w value false, error record! Value:~w", [EtsName, Value]),
                    ?FALSE;
                _ when IsPreLoad ->    %% 已从数据库加载，如果ets没有数据，返回false
                    ?FALSE;
                _ ->    %%  未从数据库加载，当前可加载
                    db_get(RecName, KeyName, Key, IsList)
            end;
        _ ->
            ?WARNING("get ~w value false, no durable record!", [EtsName]),
            ?FALSE
    end.

%% 保存数据到ets和数据库
save_value(Record) ->
    db_action(update, Record).
%% Key：undefined或者{Key, RecordList}格式中的Key
%% 如果类似ets_global_data那样一条数据一条ets，但需要批量save的话，Key为undefined
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


%% 根据数据库名加载多有数据并转化成游戏内使用的record，存ets
load_all_value(Name) ->
    DbValueList = edb_util:get_all(Name),
    RecordList =
        [begin
             DbRecord   = util:to_tuple([Name | E]),
             Record     = game_db_deps:db_to_record(DbRecord),
             ets:insert(util:to_ets_name(Name), Record),
             add_mapping(Record),
             Record
         end || E <- DbValueList],
    {ok, RecordList}.

%% ========================================================================
%% Local functions
%% ========================================================================
db_get(TabName, KeyName, Key, _IsList = ?TRUE) ->   %% 列表
    DbValueList = edb_util:get_all(TabName, [{KeyName, KeyName}]),
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
            ?WARNING("No such value! Name:~w, KeyName:~w, KeyValue:~w", [Name, KeyName, Key]),
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
    [RecName, Fields] = lib_record:fields_value(DbRecord),
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

db_batch_action(Action, RecordList, EtsKey, EtsName)
    when Action =:= insert orelse Action =:= replace ->
    F = fun(Record, {NameAccIn, SqlAccIn, EtsAccIn}) ->
        case game_db_deps:check_dirty(Record) of
            {?TRUE, Record1} ->
                DbRecord        = game_db_deps:record_to_db(Record1),
                [RecName | ValueList] = util:to_list(DbRecord),
                ValueSql = edb_util:make_value_sql(ValueList),
                case Action of
                    insert ->   %% 自增id
                        Head = ?IF(SqlAccIn =:= [], "(0, ", ", (0, "),
                        ValueSql1 = Head ++ ValueSql ++ ")",
                        {RecName, [ValueSql1 | SqlAccIn], [Record1 | EtsAccIn]};
                    _ ->
                        Head = ?IF(SqlAccIn =:= [], "(", ", ("),
                        ValueSql1 = Head ++ ValueSql ++ ")",
                        {RecName, [ValueSql1 | SqlAccIn], [Record1 | EtsAccIn]}
                end;
            _ ->
                {NameAccIn, SqlAccIn, [Record | EtsAccIn]}
        end
        end,
    case lists:foldl(F, {?UNDEFINED, [], []}, RecordList) of
        {?UNDEFINED, _SqlList, _EtsList} when EtsName =/= ?UNDEFINED ->
            %% 空list，但有EtsName
            case EtsKey of
                ?UNDEFINED ->   %% 一条记录就为1条ets信息
                    skip;
                _ ->            %% ets信息结构为{Key, ValueList}
                    ets:insert(EtsName, {EtsKey, []})
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