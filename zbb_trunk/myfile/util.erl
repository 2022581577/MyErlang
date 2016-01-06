%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : 工具模块
%%%----------------------------------------------------------------------

-module(util).
-author('kongqingquan <kqqsysu@gmail.com>').
-include("common.hrl").
-include("record.hrl").

-export([ 
		md5/1, 
        rand/1,
		rand/2,
        rand_one/1,
        weight_rand/3,
		ceil/1, 
		floor/1, 
		sleep/1, 
		sleep/2,
		get_list/2, 
        to_utf8_list/1,
		string_to_term/1, 
		bitstring_to_term/1,
		term_to_string/1, 
		term_to_bitstring/1, 
		to_integer/1, 
        to_float/1,
		to_binary/1, 
		get_index_of/2,
		to_atom/1, 
		list_to_atom2/1,
        log_timename/0,
		time_format/1, 
		log_filename/1, 
        log_filename/2,
		to_list/1,
		is_same_date/2, 
        is_same_week/2,
        seconds_to_localtime/1,
        get_ip/1,
        one_to_two/1,
        implode/2,
        explode/2,
        explode/3,
        check_cd/2,
        reset_cd/1,
        reset_cd/2,
        erase_cd/1,
        timestamp/0,
        timestamp/1,
        mutex_rand/1,
        suitable_num/2,
        dets_foldl/3,
        dets_foldr/3,
        url_decode/1,
        get_http_content/3,
        int8/1,
        int16/1,
        int32/1,
        mess_list/1,
        list_elem_nth/2,
        get_base_xishu/2,
        get_base_xishu/1,
        get_week/0,
        get_begin_tick/0,
        get_over_tick/0,
        get_begin_tick/1,
        get_over_tick/1,
        record_to_json/2,
        open_date/0,
        open_time/0,
        open_days/0,
        open_week/0,
        day_difference/2,
        merger_date/0,
        merger_time/0,
        int64_format/1,
        set_world_lv/1,
        get_world_lv/0,
        get_new_name/0
    ]).

%% 开服时间
%% {{Y, M, D}, {H, M, S}}
open_date() ->
    ?CONFIG(open_date).
%% 开服时间戳
open_time() ->
    timestamp(open_date()).
%% 开服天数
open_days() ->
    {Date, _Time} = open_date(),
    {NowDate, _} = mod_timer:localtime(),
    max(0, calendar:date_to_gregorian_days(NowDate) - calendar:date_to_gregorian_days(Date) + 1).
%% 开服星期
open_week() ->
    {{Y, M, D}, _} = open_date(),
    calendar:day_of_the_week(Y,M,D).

%% 2个时间戳的天数差
day_difference(T1, T2) ->
    {D1,_} = calendar:seconds_to_daystime(T1 + 8 * ?TIMER_ONE_HOUR_SEC),
    {D2,_} = calendar:seconds_to_daystime(T2 + 8 * ?TIMER_ONE_HOUR_SEC),
    abs(D2 - D1).

%% 合服时间
%% {{Y, M, D}, {H, M, S}}
-define(BASE_MERGER_DATE, {{0,0,0},{0,0,0}}).
merger_date() ->
    case ?GLOBAL_DATA_DISK:get(?SERVER_MERGER_DATE) of
        {{_Year,_Month,_Day},{_H,_M,_S}} = DateTime -> DateTime;
        _ -> ?BASE_MERGER_DATE
    end.
%% 合服时间戳
merger_time() ->
    case merger_date() of
        ?BASE_MERGER_DATE ->
            0;
        Date ->
            timestamp(Date)
    end.

%% @doc 在List中的每两个元素之间插入一个分隔符
implode(_S, [])-> 
    [<<>>];
implode(S, L) when is_list(L) ->    
    implode(S, L, []).
implode(_S, [H], NList) ->
    lists:reverse([thing_to_list(H) | NList]);
implode(S, [H | T], NList) ->
    L = [thing_to_list(H) | NList],
    implode(S, T, [S | L]).

%% @doc 字符->列
explode(S, B)->
    re:split(B, S, [{return, list}]).
explode(S, B, int) ->
    [list_to_integer(Str) || Str <- explode(S, B),length(Str) > 0].

md5(S) ->
    lists:flatten([io_lib:format("~2.16.0b", [N])
		   || N <- binary_to_list(erlang:md5(S))]).

thing_to_list(X) when is_integer(X) ->
    integer_to_list(X);
thing_to_list(X) when is_float(X)   ->
    float_to_list(X);
thing_to_list(X) when is_atom(X)    -> 
    atom_to_list(X);
thing_to_list(X) when is_binary(X)  -> 
    binary_to_list(X);
thing_to_list(X) when is_list(X)    -> 
    X.

rand(N) when is_integer(N) ->
    rand(1,N);
rand([]) ->
    [];
rand([_ | _] = L) ->
    Nth = rand(length(L)),
    lists:nth(Nth, L).

rand(Same, Same) -> Same;
rand(Value1, Value2) ->
    Min = min(Value1, Value2),
    Max = max(Value1, Value2),
    case get(random_seed) of
      undefined ->
          random:seed(now());
      	_ -> 
          skip
    end,
    M = Min - 1, 
    random:uniform(Max - M) + M.

rand_one([]) ->
    [];
rand_one([H]) ->
    H;
rand_one(L) when is_list(L) ->
    Len = length(L),
    N = rand(1,Len),
    lists:nth(N,L).

weight_rand(Rand, L, Res) ->
    weight_rand(Rand, L, 0, Res).
weight_rand(Rand, [{R, S} | T], N, Res) ->
    case Rand >= N andalso Rand < N + R of
        true -> S;
        _ ->    weight_rand(Rand, T, N + R, Res)
    end;
weight_rand(_Rand, [], _N, Res) ->
    Res.

ceil(N) ->
    T = trunc(N),
    case N == T of
      true -> T;
      false -> 1 + T
    end.

floor(X) ->
    T = trunc(X),
    case X < T of
      true -> T - 1;
      _ -> T
    end.

sleep(T) -> receive  after T -> ok end.

sleep(T, F) -> receive  after T -> F() end.

get_list([], _) -> [];
get_list(X, F) -> F(X).

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

len_pos(X, [H | T]) when X =:= H -> length(T) + 1;
len_pos(X, [H | T]) when X =/= H -> len_pos(X, T).

get_index_of(X, List) ->
    NewList = lists:reverse(List),
    Index = len_pos(X, NewList),
    Index.

one_to_two(One) ->
    Two = io_lib:format("~2..0B", [One]),
    lists:flatten(Two).

time_format(Now) ->
    {{Y, M, D}, {H, MM, S}} = calendar:now_to_local_time(Now),
    lists:concat([Y, "-", one_to_two(M), "-", one_to_two(D)," ", one_to_two(H), ":", one_to_two(MM), ":", one_to_two(S)]).

log_timename() ->
    {{Y, M, D}, {H, MM, S}} = mod_timer:localtime(),
    lists:concat([Y, one_to_two(M), one_to_two(D),"-", one_to_two(H), one_to_two(MM),one_to_two(S)]).

%% 游戏输出日志文件名
log_filename(BaseDir) ->
    log_filename(lists:concat([BaseDir,?CONFIG(server_type),"_",?CONFIG(platform),"_",?CONFIG(prefix),?CONFIG(server_id),"_"]), ".log").

log_filename(FilePrefix, FileSuffix) ->
    {{Y, M, D}, {H, MM, S}} = mod_timer:localtime(),
	NewM = one_to_two(M),
	NewD = one_to_two(D),
	NewH = one_to_two(H),
	NewMM = one_to_two(MM),
	NewS = one_to_two(S),
    lists:concat([FilePrefix,Y,NewM,NewD,"-",NewH,NewMM,NewS,FileSuffix]).

is_same_date(Seconds1, Seconds2) when Seconds1 > Seconds2 ->
    is_same_date(Seconds2,Seconds1);
is_same_date(Seconds1, Seconds2) ->
    case Seconds2 - Seconds1 of
        Diff when Diff > 86400 ->   %% 相差大于 86400,不是同一天
            false;
        Diff ->
            {_YearMonDay, {Hour,Min,Sec}} = seconds_to_localtime(Seconds1), 
            Hour * 3600 + Min * 60 + Sec + Diff < 86400
    end.

%% @doc 是否同一周
is_same_week(Seconds1, Seconds2) ->
    WeekDay1 = ceil((Seconds1 - ?TIMER_WEEK_BEGIN_STAMP) / ?TIMER_ONE_WEEK_SEC),
    WeekDay2 = ceil((Seconds2 - ?TIMER_WEEK_BEGIN_STAMP) / ?TIMER_ONE_WEEK_SEC),
    WeekDay1 == WeekDay2.

%% @doc 获取现在是周几
get_week() ->
    {{Y, M, D}, _} = mod_timer:localtime(),
    calendar:day_of_the_week(Y,M,D).

seconds_to_localtime(Seconds) ->
    calendar:now_to_local_time({Seconds div 1000000,Seconds rem 1000000,0}).

get_ip(Socket) ->
    case inet:peername(Socket) of
        {ok,{{A,B,C,D}, _Port}} ->
            lists:concat([A,".",B,".",C,".",D]);
        {error,Reason} ->
            ?WARNING("get_ip fail,Socket:~w,Reason:~w",[Socket,Reason]),
            ""
    end.

%% @doc获取设置CD
-define(CD,cd).
check_cd(Key,CdTime) ->
    case get({?CD,Key}) of
        undefined ->
            true;
        T ->
            LongUnixTime = mod_timer:long_unixtime(),
            T + CdTime =< LongUnixTime
    end.
reset_cd(Key) ->
    LongUnixTime = mod_timer:long_unixtime(),
    put({?CD,Key},LongUnixTime).
reset_cd(Key,LongUnixTime) ->
    put({?CD,Key},LongUnixTime).
erase_cd(Key) ->
    put({?CD,Key},0).

%% 获取timestamp
timestamp() ->
    {M,S,MM} = os:timestamp(),
    M * (1000000 * 1000) + S * 1000 + MM div 1000.

%% @doc 根据{{{year, month, day},{hour,minute,second}}获取timestamp
timestamp({{_, _, _}, {_, _, _}} = DateTime) ->
    NowSec = calendar:datetime_to_gregorian_seconds(DateTime),
    NowSec - ?TIMER_19700101080000_SEC.

%% @doc 获取互斥类型概率下标
mutex_rand([_]) ->
    1;
mutex_rand(L) ->
    {Sum,NewList} = 
    lists:foldl(fun(N,{AccInSum,AccInList}) ->
                        NewAccINSum = N + AccInSum,
                        NewAccInList = [{AccInSum,NewAccINSum} | AccInList],
                        {NewAccINSum,NewAccInList}
                end,{0,[]},L),
    NewList2 = lists:reverse(NewList),
    Rand = Sum * random:uniform(),
    mutex_rand(NewList2,Rand,1).
mutex_rand([{Start,End} | T],Rand,Index) ->
    case Start =< Rand andalso End >= Rand of
        true ->
            Index;
        false ->
            mutex_rand(T,Rand,Index + 1)
    end.

suitable_num(Value, List) ->
    suitable_num(Value, List, 1).
suitable_num(Value, [H | L], N) ->
    case Value =< H of
        true ->
            N;
        _ ->
            suitable_num(Value, L, N + 1)
    end;
suitable_num(_Value, [], N) ->
    N - 1.

%% @doc dets的fold方法重构，
dets_foldl(F, AccIn0, Tab) ->
    try 
        Res = dets:foldl(F, AccIn0, Tab),
        dets:safe_fixtable(Tab, false),
        Res
    catch 
        _Err:_Res ->
            ?WARNING2("util fold error:~w, Res:~w", [_Err, _Res]),
            dets:safe_fixtable(Tab, false)
    end.
dets_foldr(F, AccIn0, Tab) ->
    try
        Res = dets:foldr(F, AccIn0, Tab),
        dets:safe_fixtable(Tab, false),
        Res
    catch 
        _Err:_Res ->
            ?WARNING2("util fold error:~w, Res:~w", [_Err, _Res]),
            dets:safe_fixtable(Tab, false)
    end.

url_decode(URL) ->    
    url_decode(URL, []).

url_decode([], Acc) ->    
    lists:reverse(Acc);
url_decode([37,H,L|T], Acc) ->    
    url_decode(T, [erlang:list_to_integer([H,L], 16) | Acc]);
url_decode([$+|T], Acc) ->    
    url_decode(T, [32|Acc]);
url_decode([H|T], Acc) ->    
    url_decode(T, [H|Acc]).

%% @doc httpc
get_http_content(post, Url, HttpOptions) ->
    case httpc:request(post, {Url,[],[],[]}, http_options(HttpOptions), []) of
        {ok, {_Status, _Headers, Body}} ->
            Body;
        {error, Reason} ->
            ?WARNING("httpc request error Reason:~w",[Reason]),
            ""
    end;
get_http_content(put, Url, HttpOptions) ->
    case httpc:request(put, {Url,[],[],[]}, http_options(HttpOptions), []) of
        {ok, {_Status, _Headers, Body}} ->
            Body;
        {error, Reason} ->
            ?WARNING("httpc request error Reason:~w",[Reason]),
            ""
    end;
get_http_content(Type, Url, HttpOptions) ->
    case httpc:request(Type, {Url, []}, http_options(HttpOptions), []) of
        {ok, {_Status, _Headers, Body}} ->
            Body;
        {error, Reason} ->
            ?WARNING("httpc request error Reason:~w",[Reason]),
            ""
    end.

http_options(HttpOptions) ->
    HttpOptions.
   % case lists:keyfind(version,1,HttpOptions) of
   %     {version,_} ->
   %         HttpOptions;
   %     false ->
   %         [{version,"HTTP/1.0"} | HttpOptions]
   % end.


%% @doc 将无符号数转为有符号整数
int8(N) when N < 256 ->
    case N < 128 of
        true ->
            N;
        false ->
            N - 256
    end.
int16(N) when N < 65536 ->
    case N < 32768 of
        true ->
            N;
        false ->
            N - 65536
    end.
int32(N) when N < 4294967296 ->
    case N < 2147483648 of
        true ->
            N;
        false ->
            N - 4294967296
    end.

%% @doc 打乱排序
mess_list(L) when is_list(L) ->
    F = fun(_, _) ->
            case rand(2) of
                1 ->    true;
                _ ->    false
            end
        end,
    lists:sort(F, L).

%% @doc 元素在list中的位置
list_elem_nth(List, Elem) ->
    list_elem_nth(List, Elem, 0).
list_elem_nth([Elem | _], Elem, N) ->
    N + 1;
list_elem_nth([_ | T], Elem, N) ->
    list_elem_nth(T, Elem, N + 1);
list_elem_nth([], _, _) ->
    0.

%% @doc 获得基础系数
get_base_xishu(ID) ->
    get_base_xishu(ID,undefined).
get_base_xishu(ID,Default) ->
    case data_misc:get(ID) of
        [ID, Value] ->
            Value;
        _ ->
            Default
    end.

%% @doc 获取某个时间所在当天的开始时间戳，即当天0:00
get_begin_tick() ->
    get_begin_tick(mod_timer:unixtime()).

get_begin_tick(T) ->
    Rem = abs((T - ?TIMER_REFRESH_BASE_STAMP) rem ?TIMER_ONE_DAY_SEC),
    T - Rem.    
    
%% @doc 获取某个时间所在当天的结束时间戳，即当天24:00（第二天0:00）
get_over_tick() ->
    get_over_tick(mod_timer:unixtime()).

get_over_tick(T) ->
    get_begin_tick(T + ?TIMER_ONE_DAY_SEC).

%% 把Record中的Fields,#record{} 映射成 json
record_to_json(RecordFields,Record) ->
    [_ | Vals] = tuple_to_list(Record),
    %% ?INFO("INFO:~w", [lists:zip(RecordFields,Vals)]),
    iolist_to_binary(mochijson2:encode(lists:zip(RecordFields,Vals))).

%% int64转为前端编码
%int64_format(Num) ->
%    <<Hight:32,Low:32>> = <<Num:64>>,
%    StrHight = to_list(Hight),
%    StrLow = to_list(Low),
%    DupNum = max(0,10 - length(StrLow)),                %% int32最大为32位
%    NewStrLow = string:copies("0",DupNum) ++ StrLow,    %% 补0
%    to_binary(StrHight ++ NewStrLow).
int64_format(Num) ->
    <<Hight:32,Low:32>> = <<Num:64>>,
    StrHight = to_list(Hight),
    StrLow = to_list(Low),
    to_binary(StrHight ++ "_" ++  StrLow).

%% @doc 世界等级
set_world_lv(Lv) ->
    ?GLOBAL_DATA_DISK:set(?WORLD_LEVEL, Lv).
get_world_lv() ->
    case ?GLOBAL_DATA_DISK:get(?WORLD_LEVEL, 1) of
        0 ->
            set_world_lv(1),
            1;
        R ->
            R
    end.

%% @doc 随机获取一个当前服务器没用过的名字
get_new_name() ->
    Name = rand_name(),
    case lib_ets:get_user_id_by_name(Name) > 0 of
        true ->
            get_new_name();
        _ ->
            Name
    end.
%% 随机出名字
rand_name() ->
    FirstList = data_name:get_id_by_type(1),
    SecList = data_name:get_id_by_type(2),
    ThirdList = data_name:get_id_by_type(3),
    #data_name{content=FirstName} = data_name:get(rand_one(FirstList)),
    #data_name{content=SecName} = data_name:get(rand_one(SecList)),
    #data_name{content=ThirdName} = data_name:get(rand_one(ThirdList)),
    L1 = binary_to_list(FirstName),
    L2 = binary_to_list(SecName),
    L3 = binary_to_list(ThirdName),
    L4 = L1++L2++L3,
    to_binary(L4).

