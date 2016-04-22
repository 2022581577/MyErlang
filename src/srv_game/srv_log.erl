%%%----------------------------------------------------------------------
%%% @author : zhongbinbin
%%% @date   : 2016.02.05
%%% @desc   : 日志进程
%%%----------------------------------------------------------------------


-module(srv_log).
-behaviour(game_gen_server).

-export([do_init/1
        ,do_call/3
        ,do_cast/2
        ,do_info/2
        ,do_terminate/2]).

-export([start_link/0]).

-export([add_log/1]).
-export([add_log/3]).

-include("common.hrl").
-include("log.hrl").

%-define(MODULE_LOOP_TICK, 60000).		%% 循环时间
-define(MODULE_LOOP_TICK, 5000).		%% 循环时间
-define(BATCH_NUM, 20).                 %% 批量值


-record(state, {insert_dict = dict:new(), replace_dict = dict:new()}).

-record(log_table,{table_name, size = 0, value_list}).

%% @doc 日志
add_log(LogList) ->
    game_gen_server:cast(?MODULE, {add_log, LogList}).

add_log(Operation, TableName, Value) ->
    game_gen_server:cast(?MODULE, {add_log, Operation, TableName, Value}).


start_link() ->
    game_gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


do_init([]) ->
    process_flag(trap_exit,true),
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    {ok, #state{}}.


do_cast({add_log, LogList}, State) ->
    F = fun({Operation, TableName, Value}, {ok, StateIn}) ->
            do_add_log(StateIn, Operation, TableName, Value)
        end,
    {ok, NewState} = lists:foldl(F, {ok, State}, LogList),
    {noreply, NewState};

do_cast({add_log, Operation, TableName, Value}, State) ->
    {ok, NewState} = do_add_log(State, Operation, TableName, Value),
    {noreply, NewState};

do_cast(Info, State) -> 
    ?WARNING("Not done do_cast:~w",[Info]),
	{noreply, State}.


do_call(Info, _From, State) -> 
    ?WARNING("Not done do_call:~w",[Info]),
	{reply, ok, State}.


do_info(loop, State) ->
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    NewState = save(State),
    {noreply, NewState};

do_info(Info, State) -> 
    ?WARNING("Not done do_info:~w",[Info]),
	{noreply, State}.


do_terminate(_Reason, State) ->   
    save(State),
    ok.


do_add_log(#state{insert_dict = InsertDict, replace_dict = ReplaceDict} = State, Operation, TableName, Value) ->
    Value1 = edb_util:make_value_sql(Value),
    case Operation of
        ?OPERATION_INSERT ->
            NewInsertDict = do_add_log1(Operation, TableName, "(0, " ++ Value1 ++ ")", InsertDict),
            NewState = State#state{insert_dict = NewInsertDict};
        _ ->
            NewReplaceDict = do_add_log1(Operation, TableName, "(" ++ Value1 ++ ")", ReplaceDict),
            NewState = State#state{replace_dict = NewReplaceDict}
    end,
    {ok, NewState}.

do_add_log1(Operation, TableName, Value, Dict) ->
    case dict:find(TableName, Dict) of
        {ok, #log_table{size = Size, value_list = ValueList}} when Size >= ?BATCH_NUM ->
            Value1 = [$, | Value],
            batch_save(Operation, TableName, [Value1 | ValueList]),
            dict:erase(TableName, Dict);
        {ok, #log_table{size = Size, value_list = ValueList} = LogTable} ->
            Value1 = [$, | Value],
            dict:store(TableName, LogTable#log_table{size = Size + 1, value_list = [Value1 | ValueList]}, Dict);
        _ ->
            dict:store(TableName, #log_table{table_name = TableName, size = 1, value_list = [Value]}, Dict)
    end.

%% 全部数据存库
save(State) ->
	[batch_save(?OPERATION_INSERT, TableName, ValueList)|| {TableName,#log_table{value_list=ValueList}} <- dict:to_list(State#state.insert_dict)],
	[batch_save(?OPERATION_INSERT, TableName, ValueList)|| {TableName,#log_table{value_list=ValueList}} <- dict:to_list(State#state.replace_dict)],
	State#state{insert_dict=dict:new(),replace_dict=dict:new()}.

batch_save(_, _, []) ->
	ok;
batch_save(Operation, TableName, ValueList) ->
	Header = io_lib:format("~p into ~p values ", [Operation, TableName]),
    Sql = [Header | lists:reverse(ValueList)],
    ?INFO("Sql:~w", [Sql]),
    case catch edb_util:execute(Sql) of
        {ErrorType, Msg} ->
            ?ERROR("batch save error, ErrorType:~w, Msg:~w", [ErrorType, Msg]);
        _ ->
            ok
    end.
