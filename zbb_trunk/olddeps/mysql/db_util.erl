%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : 数据库工具
%%%----------------------------------------------------------------------

-module(db_util).

-export([check_db_state/0,
        execute/1,
        execute/2]).

-export([
          get_all/1,
          get_all/3,
          get_all/4,
          get_all/5,
          get_limit/2,
          get_limit/4,
          get_limit/5,
          get_row/1,
          get_row/3,
          get_one/3]).

-export([
         replace/2,
         batch_replace_sql/3,
         insert/2,
         batch_insert_sql/3,
         update/3,
         delete/2,
         delete/3
         ]).

-export([make_fields_sql/1, 
        make_value_sql/1]).

-include("common.hrl").
-include("mysql.hrl").

-define(MYSQL_TIME_OUT, 5000).
-define(MYSQL_LAST_CONNECTION_TIME,mysql_last_connection_time). %% mysql上次重连时间

%%%  mysql:fetch(PoolId, Query, Timeout) ->
%%%         Result = {data, MySQLRes}    |
%%%                  {updated, MySQLRes} |
%%%                  {error, MySQLRes}
%%%         Where: MySQLRes = #mysql_result

%% @doc 检测数据库状态
check_db_state() ->
    try
        ?GLOBAL_DATA_RAM:set(?MYSQL_CONNECT_STATE,true),
        db_util:execute("SELECT * FROM global_data WHERE `key` = \"log_version\"")
    catch
        Err:Reason ->
            ?WARNING2("check_db_state Err! Err:~w, Reason:~w", [Err, Reason]),
            ?GLOBAL_DATA_RAM:set(?MYSQL_CONNECT_STATE,false),
            reconn_mysql(),
            false
    end.

reconn_mysql()->
    Diff = 60 * 1000,
    Now = util:timestamp(),
    LastTime = ?GLOBAL_DATA_RAM:get(?MYSQL_LAST_CONNECTION_TIME,0),
    case Now - LastTime > Diff of
        true ->
            ?GLOBAL_DATA_RAM:set(?MYSQL_LAST_CONNECTION_TIME,Now),
            db:switch_db();
        _ ->
            skip
    end,
    ok.

%% 执行sql 语句
execute(Sql) ->
    execute(Sql,?MYSQL_TIME_OUT).

execute(Sql,TimeOut) ->
    %% ?INFO("Sql:~s",[Sql]),
    case mysql:fetch(?MYSQL_POOL,Sql,TimeOut) of
        {data,#mysql_result{rows = Rows}} ->
            Rows;
        {updated,#mysql_result{affectedrows = AffectedRows}}->
            AffectedRows;
        {error,#mysql_result{error = Error}} ->
            ?WARNING2("Mysql Query Error:~w, Sql:~w",[Error,Sql]),
            throw({mysql_error, Error})
    end.

get_all(Sql) ->
    execute(Sql).

%% spec get_all(Table::atom(),Fields::[atom,atom..],WhereFields::[{field,Val} or {field,= < > ,Val}])
get_all(Table,Fields,WhereFields) ->
    get_all(make_query_sql(Table,Fields,WhereFields)).

get_all(Table,Fields,WhereFields,OrderFields) ->
    get_all(make_query_sql(Table,Fields,WhereFields,OrderFields,[])).

get_all(Table,Fields,WhereFields,OrderFields,Limit) ->
    get_all(make_query_sql(Table,Fields,WhereFields,OrderFields,Limit)).

get_limit(Sql,Limit) ->
    NewSql = lists:concat([Sql,make_limit_sql(Limit)]),
    get_all(NewSql).

get_limit(Table,Fields,WhereFields,Limit) ->
    get_all(make_query_sql(Table,Fields,WhereFields,[],Limit)).

get_limit(Table,Fields,WhereFields,OrderFields,Limit) ->
    get_all(make_query_sql(Table,Fields,WhereFields,OrderFields,Limit)).

get_row(Sql) ->
    case get_limit(Sql,[0,1]) of
        [H | _] ->
            H;
        _ ->
            []
    end.

get_row(Table,Fields,WhereFields)->
    case get_limit(Table,Fields,WhereFields,[0,1]) of
        [H | _T] ->
            H;
        _ ->
            []
    end.

get_one(Table,Field,WhereFields) ->
    case get_row(Table,[Field],WhereFields) of
        [H | _T] ->
            H;
        _->
            undefined
    end.

replace(Table,Fields) ->
    InsertSql = make_update_sql(Fields),
    Sql = lists:concat(["REPLACE `",Table,"` SET ",InsertSql]),
    execute(Sql).

insert(Table,Fields) ->
    InsertSql = make_update_sql(Fields),
    Sql = lists:concat(["INSERT INTO `",Table,"` SET ",InsertSql]),
    execute(Sql).

update(Table,Fields,WhereFields) ->
    UpdateSql = make_update_sql(Fields),
    WhereSql = make_where_sql(WhereFields),
    Sql = lists:concat(["UPDATE `",Table,"` SET ",UpdateSql,WhereSql]),
    execute(Sql).

delete(Table,WhereFields) ->
    delete(Table,WhereFields,[]).

delete(Table,WhereFields,Limit)->
    WhereSql = make_where_sql(WhereFields),
    LimitSql = make_limit_sql(Limit),
    Sql = lists:concat(["DELETE FROM `",Table,"` ",WhereSql,LimitSql]),
    execute(Sql).

make_query_sql(Table,Fields,WhereFields)->
   make_query_sql(Table,Fields,WhereFields,[],[]).
make_query_sql(Table,Fields,WhereFields,OrderFields,Limit)->
    FieldsSql = make_fields_sql(Fields),
    WhereSql = make_where_sql(WhereFields),
    OrderSql = make_order_sql(OrderFields),
    LimitSql = make_limit_sql(Limit),
    lists:concat(["SELECT ",FieldsSql," FROM `",Table,"`",WhereSql,OrderSql,LimitSql]).

make_fields_sql(Fields) ->
    make_fields_sql(Fields,"","").
make_fields_sql([],_Jion,FieldsSql) ->
    FieldsSql;
make_fields_sql([H | T],Join,FieldsSql)->
    NewFieldsSql = lists:concat([FieldsSql,Join,"`",H,"`"]),
    make_fields_sql(T,",",NewFieldsSql).

make_where_sql(Fields) ->
    make_where_sql(Fields,"WHERE ", "").
make_where_sql([],_Join,WhereSql) ->
    WhereSql;
make_where_sql([H | T],Join,WhereSql) ->
    NewWhereSql = 
    case H of
        {Field,Val} ->
            lists:concat([WhereSql,Join,"`",Field,"`=",mysql:encode(Val)]);
        {Field,Contion,Val} ->
            lists:concat([WhereSql,Join,"`",Field,"`",Contion,mysql:encode(Val)])
    end,
    make_where_sql(T,",",NewWhereSql).

make_order_sql(Fields)->
    make_order_sql(Fields," Order BY ","").
make_order_sql([],_Join,OrderSql)->
    OrderSql;
make_order_sql([H | T],Join,OrderSql)->
    NewOrderSql =
    case H of
        {Field,Sort} ->
            lists:concat([OrderSql,Join,"`",Field,"` ",Sort]);
        Field ->
            lists:concat([OrderSql,Join,"`",Field,"` DESC "])
    end,
    make_order_sql(T,",",NewOrderSql).

make_limit_sql([])->
    "";
make_limit_sql([Start,Num])->
    lists:concat([" limit ",Start,",",Num]);
make_limit_sql(Num) when erlang:is_integer(Num) ->
    lists:concat([" limit ",Num]).

make_update_sql(Fields) ->
    make_update_sql(Fields,"","").
make_update_sql([],_Join,UpdateSql)->
    UpdateSql;
make_update_sql([{Field,Val} | T],Join,UpdateSql) ->
    NewUpdateSql = lists:concat([UpdateSql,Join,"`",Field,"`=",mysql:encode(Val)]),
    make_update_sql(T,",",NewUpdateSql).

%make_value_sql(Value) ->
%    [[_ | F] | T] = [[$, | mysql:encode(H)] || H <- Value],
%    lists:concat([F | T]).
%    make_value_sql(Value, "", "").
%make_value_sql([], _, ValueSql) ->
%    ValueSql;
%make_value_sql([H | T], Join, ValueSql) ->
%    NewValueSql = lists:concat([ValueSql, Join, mysql:encode(H)]),
%    make_value_sql(T, ",", NewValueSql).

make_value_sql(Value) ->
    NewValue = lists:reverse(Value),
    make_value_sql(NewValue, "").
make_value_sql([H | T], ValueSql) ->
    NewValueSql = [$, | mysql:encode(H)] ++ ValueSql,
    make_value_sql(T, NewValueSql);
make_value_sql([], ValueSql) ->
    case ValueSql of
        [] ->
            "";
        [_ | T] ->
            T
    end.

%% @doc 批量插入
batch_insert_sql(Table, Fields, [[_ | FV] | T]) ->
    FieldsSql = make_fields_sql(Fields),
    ValuesSql = lists:concat([FV | T]),
    lists:concat(["INSERT INTO `", Table, "` (", FieldsSql, ")", " VALUES ", ValuesSql]).

batch_replace_sql(Table, Fields, [[_ | FV] | T]) ->
    FieldsSql = make_fields_sql(Fields),
    ValuesSql = lists:concat([FV | T]),
    lists:concat(["REPLACE `", Table, "` (", FieldsSql, ")", " VALUES ", ValuesSql]).
