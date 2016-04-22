%%%-----------------------------------
%%% @Module  : util
%%% @Description: 公共函数
%%%-----------------------------------

-module(util).
-include("common.hrl").

%% 时间函数
-export([
	        unixtime/0
			,longunixtime/0
            ,unixdays/0
            ,date/0
	        ,seconds_to_localtime/1
	        ,localtime_to_seconds/1
            ,days_to_unixtime/1
	        ,get_day_of_the_week/0
	        ,is_same_date/2
	        ,is_same_week/2
            ,is_same_month/2
            ,is_admin_ip/1
	        ,get_midnight_seconds/1
	        ,get_next_day_seconds/1
	        ,get_diff_days/2
	        ,get_today_current_second/0
			,diff_hours/2
			,get_next_day_diff_seconds/0				 
            ,check_cd/2
            ,reset_cd/1
            ,reset_cd/2
            ,erase_cd/1
			,get_month_days/2
            ,server_open_time/0
            ,server_open_date/0
            ,server_open_days/0
            ,server_merge_time/0
            ,server_merge_date/0
            ,server_merge_days/0
		]).
%% 数据类型转换
-export([
		 	to_atom/1
			,to_list/1
			,to_binary/1
			,to_integer/1
			,to_bool/1
			,to_tuple/1
			,f2s/1	
			,dict2list/1 
            ,one_to_two/1
		]).
%% 列表操作
-export([
			implode/2
			,implode/3
			,explode/2
			,explode/3
			,for/2
			,for/3
			,for/4
			,forFunc/2
			,forFunc1/2
			,forlist/3
			,shuffle_list/1
			,is_all_equal/1
			,list_minus/2
			,keyadd/3
			,keyadd/1
			,get_value_pos/2
			,merge_kv_list/2	 
            ,overlap_tuple_list/3
		]).
%% 数学
-export([
	        ceil/1
			,floor/1
			,round_float/1	
            ,correct_float/1
        ,get_by_bit/2
        ,update_by_bit/3
		]).
%% 字符串相关
-export([
	        string_to_term/1
			,bitstring_to_term/1
			,term_to_string/1
			,term_to_bitstring/1
	        ,bitstring_to_spec_list/1
	        ,bitstring_to_spec_term/1				 
	        ,make_sql_value_string/1				 
	        ,make_sql_ids_string/1				 
		]).
%% 随机相关
-export([
	        rand/2
			,random_from_list/2
			,my_rand/2
			,my_rand_list/3
			,get_random_thing/1
			,get_random_thing/2				 
		]).
%% http相关
-export([
        	get_http_content/1
			,url_decode/1
			,url_encode/1
			,http_request/4
		]).
%% IP格式转换相关
-export([
            get_ip/1
			,get_ip_str/1
			,get_ip_long/1
			,get_ip_long1/1
			,ip_to_binary/1
			,ip_to_string/1
			,ip/1
			,ip_str/1		 
		]).
%% 其他
-export([
			eval/1
			,md5/1
			,byte2hexstr/1
			,sleep/1
			,sleep/2
			,get_countdown/1
			,cancel_timer/1
			,quick_sort/1
            ,is_function_exported/3
			,sync_apply/4
			,rsync_apply/1
            ,apply_user/4
            ,hmac/2
        ]).

%%
%% 时间函数
%%
%% 取得当前的unix时间戳，单位为s
unixtime() ->
    game_timer:now_seconds().
%% 取得当前的unix时间戳，单位为ms
longunixtime() ->
    game_timer:now_milseconds().

%% @doc 获取1970年以来的天数
unixdays() ->
    {{Year, Month, Day}, _} = seconds_to_localtime(unixtime()),
    calendar:date_to_gregorian_days(Year, Month, Day).

%% 获取当前的unix日期
date() ->
    seconds_to_localtime(game_timer:now_seconds()).

%% @doc 根据1970年以来的秒数获得日期
seconds_to_localtime(Seconds) ->
    DateTime = calendar:gregorian_seconds_to_datetime(Seconds+?DIFF_SECONDS_0000_1900),
    calendar:universal_time_to_local_time(DateTime).

%% 根据日期和时间获得1979年以来的秒数
%% LocalTime::datetime1970()
localtime_to_seconds(LocalTime) ->
    calendar:datetime_to_gregorian_seconds(erlang:localtime_to_universaltime(LocalTime)) - ?DIFF_SECONDS_0000_1900.

%% 根据1970年以来的天数获得对应时间戳
days_to_unixtime(Days) ->
    Date = calendar:gregorian_days_to_date(Days),
    localtime_to_seconds({Date, {0,0,0}}).

%% @doc 判断是星期几
%% @return (1 = 周一, ..., 6 = 周六, 7 = 周日)
get_day_of_the_week() ->
    UnixTime = unixtime(),
    {Date, _Time} = seconds_to_localtime(UnixTime),
    %% {Date, _Time} = erlang:localtime(),
    % 星期几
    calendar:day_of_the_week(Date).


%% @doc 判断是否同一天
is_same_date(Seconds1, Seconds2) ->
    {{Year1, Month1, Day1}, _Time1} = seconds_to_localtime(Seconds1),
    {{Year2, Month2, Day2}, _Time2} = seconds_to_localtime(Seconds2),
    Year1 == Year2 andalso Month1 == Month2 andalso Day1 == Day2.


%% @doc 判断是否同一星期
is_same_week(Seconds1, Seconds2) ->
    {{Year1, Month1, Day1}, Time1} = seconds_to_localtime(Seconds1),
    % 星期几
    Week1  = calendar:day_of_the_week(Year1, Month1, Day1),
    % 从午夜到现在的秒数
    Diff1  = calendar:time_to_seconds(Time1),
    Monday = Seconds1 - Diff1 - (Week1-1)*?ONE_DAY_SECONDS,
    Sunday = Seconds1 + (?ONE_DAY_SECONDS-Diff1) + (7-Week1)*?ONE_DAY_SECONDS,
    Seconds2 >= Monday andalso Seconds2 < Sunday.

%% @doc 判断是否同一个月
is_same_month(Seconds1, Seconds2) ->
    {{Year1, Month1, _Day1}, _Time1} = seconds_to_localtime(Seconds1),
    {{Year2, Month2, _Day2}, _Time2} = seconds_to_localtime(Seconds2),
    Year1 == Year2 andalso Month1 == Month2.

%% @doc 相差XX小时
diff_hours(Seconds1,Seconds2) when Seconds1 > Seconds2 ->
	diff_hours(Seconds2,Seconds1);
diff_hours(Seconds1,Seconds2) ->
	{{Year1, Month1, Day1}, {Hour1,_,_}} = seconds_to_localtime(Seconds1),
	{{Year2, Month2, Day2}, {Hour2,_,_}} = seconds_to_localtime(Seconds2),
    Days1 = calendar:date_to_gregorian_days(Year1, Month1, Day1),
    Days2 = calendar:date_to_gregorian_days(Year2, Month2, Day2),
	DiffDay = Days2 - Days1,
	DiffDay*24 + (Hour2 - Hour1).

%% @doc 获取当天0点和第二天0点
%% return {Today, NextDay}
get_midnight_seconds(Seconds) ->
    {{_Year, _Month, _Day}, Time} = seconds_to_localtime(Seconds),
    % 从午夜到现在的秒数
    Diff   = calendar:time_to_seconds(Time),
    % 获取当天0点
    Today  = Seconds - Diff,
    % 获取第二天0点
    NextDay = Seconds + (?ONE_DAY_SECONDS-Diff),
    {Today, NextDay}.

%% @doc 获取下一天开始的时间
get_next_day_seconds(Now) ->
	{{_Year, _Month, _Day}, Time} = seconds_to_localtime(Now),
    % 从午夜到现在的秒数
   	Diff = calendar:time_to_seconds(Time),
	Now + (?ONE_DAY_SECONDS - Diff).

%% @doc 获取现在距离下一天0点相隔的时间(S)
get_next_day_diff_seconds() ->
	Now = unixtime(),
	Next0 = get_next_day_seconds(Now),
	Next0 - Now.


%% @doc 计算相差的天数
get_diff_days(Seconds1, Seconds2) ->
    {{Year1, Month1, Day1}, _} = seconds_to_localtime(Seconds1),
    {{Year2, Month2, Day2}, _} = seconds_to_localtime(Seconds2),
    Days1 = calendar:date_to_gregorian_days(Year1, Month1, Day1),
    Days2 = calendar:date_to_gregorian_days(Year2, Month2, Day2),
    abs(Days2-Days1).

%% @doc 获取从午夜到现在的秒数
get_today_current_second() ->
    {_, Time} = calendar:now_to_local_time(unixtime()),
    NowSec = calendar:time_to_seconds(Time),
    NowSec.

%% @doc获取设置CD
-define(CD,cd).
check_cd(Key,CdTime) ->
    case get({?CD,Key}) of
        undefined ->
            true;
        T ->
            LongUnixTime = longunixtime(),
            T + CdTime =< LongUnixTime
    end.
reset_cd(Key) ->
    LongUnixTime = longunixtime(),
    put({?CD,Key},LongUnixTime).
reset_cd(Key,LongUnixTime) ->
    put({?CD,Key},LongUnixTime).
erase_cd(Key) ->
    put({?CD,Key},0).

%% @doc 获取某年某月的天数
get_month_days(Year, Month) ->
	case lists:member(Month, [1,3,5,7,8,10,12]) of
		true ->	31;
		_ when Month == 2 ->
			case Year rem 100 of
				0 when Year rem 400 == 0 ->	%% 闰年
					29;
				0 ->	28;
				_ when Year rem 4 == 0 ->	%% 闰年
					29;
				_ ->	28
			end;
		_ ->	30
	end.

%% @doc 开服时间
server_open_time() ->
    srv_param:get_value(?ETS_GLOBAL_PARAM, service_start_time).
%% @doc 开服日期
server_open_date() ->
    Time = server_open_time(),
    seconds_to_localtime(Time).
%% @doc 开服天数
server_open_days() ->
    {{Year, Month, Day}, _} = util:server_open_date(),
    OpenDays = calendar:date_to_gregorian_days(Year, Month, Day),
    UnixDays = unixdays(),
    UnixDays - OpenDays + 1.

%% @doc 合服时间
server_merge_time() ->
    #server_config{merge_time = MergeTime} = srv_param:get_value(?ETS_GLOBAL_PARAM, server_config),
    NowTime = unixtime(),
    ?IF(MergeTime > NowTime, 0, MergeTime).
%% @doc 合服日期
server_merge_date() ->
    seconds_to_localtime(server_merge_time()).
server_merge_days() ->
    {{Year, Month, Day}, _} = util:server_merge_date(),
    OpenDays = calendar:date_to_gregorian_days(Year, Month, Day),
    UnixDays = unixdays(),
    UnixDays - OpenDays + 1.

%% @return bool()
is_admin_ip(IpTuple) ->
    {A,B,C,D} = IpTuple,
    IpString = integer_to_list(A)++"."++integer_to_list(B)++"."++integer_to_list(C)++"."++integer_to_list(D),
    L =
        case srv_param:get_value(?ETS_GLOBAL_PARAM, admin_ips) of
            List when is_list(List) ->
                ["127.0.0.1"|List];
            _ ->
                ["127.0.0.1"]
        end,
    lists:member(IpString, L).

%%
%% 数据类型转换
%%
%% @doc convert other type to atom
to_atom(Msg) when is_atom(Msg) -> 
	Msg;
to_atom(Msg) when is_binary(Msg) -> 
	list_to_atom2(binary_to_list(Msg));
to_atom(Msg) when is_list(Msg) -> 
    list_to_atom2(Msg);
to_atom(_) -> 
    throw(other_value).  %%list_to_atom("").

%% @doc convert other type to list
to_list(Msg) when is_list(Msg) -> 
    Msg;
to_list(Msg) when is_atom(Msg) -> 
    atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) -> 
    binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) -> 
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) -> 
    f2s(Msg);
to_list(Msg) when is_tuple(Msg) ->
	tuple_to_list(Msg);
to_list(_) ->
    throw(other_value).

%% @doc convert other type to binary
to_binary(Msg) when is_binary(Msg) -> 
    Msg;
to_binary(Msg) when is_atom(Msg) ->
	list_to_binary(atom_to_list(Msg));
	%%atom_to_binary(Msg, utf8);
to_binary(Msg) when is_list(Msg) -> 
	list_to_binary(Msg);
to_binary(Msg) when is_integer(Msg) -> 
	list_to_binary(integer_to_list(Msg));
to_binary(Msg) when is_float(Msg) -> 
	list_to_binary(f2s(Msg));
to_binary(Msg) when is_tuple(Msg) ->
	list_to_binary(tuple_to_list(Msg));
to_binary(_Msg) ->
    throw(other_value).

%% @doc convert other type to float
%% to_float(Msg)->
%% 	Msg2 = to_list(Msg),
%% 	list_to_float(Msg2).

%% @doc convert other type to integer
-spec to_integer(Msg :: any()) -> integer().
to_integer(Msg) when is_integer(Msg) -> 
    Msg;
to_integer(Msg) when is_binary(Msg) ->
	Msg2 = binary_to_list(Msg),
    list_to_integer(Msg2);
to_integer(Msg) when is_list(Msg) -> 
    list_to_integer(Msg);
to_integer(Msg) when is_float(Msg) -> 
    round(Msg);
to_integer(_Msg) ->
    throw(other_value).

to_bool(D) when is_integer(D) ->
	D =/= 0;
to_bool(D) when is_list(D) ->
	length(D) =/= 0;
to_bool(D) when is_binary(D) ->
	to_bool(binary_to_list(D));
to_bool(D) when is_boolean(D) ->
	D;
to_bool(_D) ->
	throw(other_value).

%% @doc convert other type to tuple
to_tuple(T) when is_tuple(T) -> T;
to_tuple(T) when is_list(T) -> 
	list_to_tuple(T);
to_tuple(T) -> {T}.

list_to_atom2(List) when is_list(List) ->
	case catch(list_to_existing_atom(List)) of
		{'EXIT', _} -> erlang:list_to_atom(List);
		Atom when is_atom(Atom) -> Atom
	end.

%% @doc convert float to string,  f2s(1.5678) -> 1.57
f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]),
	A.

























%%
%% 列表操作
%%
%% 在List中的每两个元素之间插入一个分隔符
implode(_S, [])->
	[<<>>];
implode(S, L) when is_list(L) ->
    implode(S, L, []).
implode(_S, [H], NList) ->
    lists:reverse([thing_to_list(H) | NList]);
implode(S, [H | T], NList) ->
    L = [thing_to_list(H) | NList],
    implode(S, T, [S | L]).

%% 字符->列
explode(S, B)->
    re:split(B, S, [{return, list}]).
explode(S, B, int) ->
    [list_to_integer(Str) || Str <- explode(S, B), length(Str) > 0].

thing_to_list(X) when is_integer(X) -> integer_to_list(X);
thing_to_list(X) when is_float(X)   -> float_to_list(X);
thing_to_list(X) when is_atom(X)    -> atom_to_list(X);
thing_to_list(X) when is_binary(X)  -> binary_to_list(X);
thing_to_list(X) when is_list(X)    -> X.

%% @doc for循环
for(Max, Max, F) ->
    F(Max);
for(I, Max, F)   ->
    F(I),
    for(I+1, Max, F).

%% @doc 生成列表
forlist(Max, Max, F) ->
    [F(Max)];
forlist(I, Max, F)   ->
    [F(I)|forlist(I+1, Max, F)].

%% @doc 提前返回for
for([],F) ->
	F([]);
for([HEAD|TAIL],F) ->
	case F(HEAD) of
		true ->
			F(TAIL);
		false ->
			false
	end.

%% @doc 带返回状态的for循环
%% @return {ok, State}
for(Max, Min, _F, State) when Min<Max -> {ok, State};
for(Max, Max, F, State) -> F(Max, State);
for(I, Max, F, State)   -> {ok, NewState} = F(I, State), for(I+1, Max, F, NewState).

%% @doc 循环直接List 中的函数 ， 直到返回第一个非true 终止
forFunc([], _)->
	true ;
forFunc( [Fun|T], Args)->
	case apply(Fun, Args) of
	%case Fun(Args) of
		true -> forFunc(T, Args) ;
		Fail ->  Fail
	end .
%% @doc 提前返回for
forFunc1([],_F) ->
	true;
forFunc1([HEAD|TAIL],F) ->
	case apply(F, HEAD) of
		true ->
			forFunc1(TAIL, F);
		Error ->
			Error
	end.

%% 随机排列列表
shuffle_list(L) ->
    F = fun(_, _) ->
            case rand(1, 2) of
                1 ->    true;
                _ ->    false
            end
        end,
    lists:sort(F, L).

%% 判断列表元素是否全部相等
is_all_equal([]) ->
	true;
is_all_equal([HEAD|TAIL]) ->
	is_all_equal(HEAD,TAIL).

is_all_equal(_Ele,[]) ->
	true;
is_all_equal(Ele,[HEAD|TAIL]) ->
	case Ele =:= HEAD of
		true ->
			is_all_equal(Ele,TAIL);
		false ->
			false
	end.

%% List1 - List2 返回List1有而List2没有的元素列表
%% @return List
list_minus(IndexList1,IndexList2) ->
    {_Same,Diff} = lists:partition(fun(X) -> lists:member(X,IndexList2) end, IndexList1),
    Diff.


keyadd(Key,Add,List) ->
	case lists:keyfind(Key, 1, List) of
		{Key,Value} -> lists:keystore(Key, 1, List, {Key,Value + Add});
		false -> [{Key,Add}|List]
	end.

keyadd(List) ->
	lists:reverse(lists:foldl(fun({Id,Value}, Acc) ->
								case Acc of
									[{Id, Value0}|Left] -> [{Id,Value + Value0}|Left];
									_ -> [{Id,Value}|Acc]
								end
							  end, [], lists:keysort(1, List))).

get_value_pos(List, Value) ->
	get_value_pos(List, Value, 0).

get_value_pos([], _Value, _Seq) ->
	0;
get_value_pos([V|_List], V, Seq) ->
	Seq + 1;
get_value_pos([_V|List], Value, Seq) ->
	get_value_pos(List, Value, Seq+1).
	

merge_kv_list(L1,L2) ->
	lists:foldl(fun({K,V},Acc) -> 
					case lists:keyfind(K, 1, Acc) of
						false ->
							[{K,V}|Acc];
						{K,V0} ->
							lists:keystore(K, 1, Acc, {K,V+V0})
					end
				end, L2, L1).




%%
%% 数学操作
%%
%% @doc 向上取整
ceil(N) when is_integer(N) -> N;
ceil(N) ->
    N1 = correct_float(N),
    T = trunc(N1),
    case N1 == T of
        true  -> T;
        false -> 1 + T
    end.

%% @doc 向下取整
floor(X) when is_integer(X) -> X;
floor(X) ->
    X1 = correct_float(X),
    T = trunc(X1),
    case (X1 < T) of
        true -> T - 1;
        _ -> T
    end.

%% 浮点数保留6位小数
round_float(F) ->
    correct_float(F).

correct_float(N) ->
    list_to_float(float_to_list(N, [{decimals, 6}])).






%%
%% 字符串相关
%%
%% @doc term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]"
term_to_string(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~w", [Term]))).

%% @doc term序列化，term转换为bitstring格式，e.g., [{a},1] => <<"[{a},1]">>
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).

%% @doc term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> undefined
            end;
        _Error ->
            undefined
    end.

%% @doc term反序列化，bitstring转换为term，e.g., <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).


%% @doc 解码数据(读模板表使用)
%% <<"1,2,3|4,5,6">> -> [{1,2,3},{4,5,6}]
%% @Param Bin:binary
%% @return list
bitstring_to_spec_list(Bin) ->
    case Bin of
        undefined -> [];
        <<>> -> [];
        _ ->
            NewBin = list_to_binary([
                <<"[{">>
               ,re:replace(Bin, "\\|", "},{", [global, {return, binary}])
               ,<<"}]">>
            ]),
            bitstring_to_spec_term(NewBin)
    end.

%% @doc 解码数据(读实例表使用)
%% <<"[1,2,3]">> -> [1,2,3]
%% <<"{1,2,3}">> -> {1,2,3}
%% @Param BitString:binary
%% @return list
bitstring_to_spec_term(BitString) ->
    List = bitstring_to_term(BitString),
    case is_list(List) orelse is_tuple(List) of
        true -> List;
        false -> []
    end.
















%%
%% 随机相关
%%
%% @doc 产生一个介于Min到Max之间的随机整数
rand(Same, Same) -> Same;
rand(Min, Max) ->
    %% 如果没有种子，将从核心服务器中去获取一个种子，以保证不同进程都可取得不同的种子
    case get("rand_seed") of
        undefined ->
            RandSeed = game_rand:get_seed(),
            random:seed(RandSeed),
            put("rand_seed", RandSeed);
        _ -> skip
    end,
    %% random:seed(erlang:now()),
    M = Min - 1,
    random:uniform(Max - M) + M.

my_rand(Min,Max) ->
	random:seed(erlang:now()),
	Seed = {random:uniform(99999), random:uniform(999999), random:uniform(999999)},
	random:seed(Seed),
	M = Min - 1,
	random:uniform(Max - M) + M.

%% @doc 取得一个随机数列表
my_rand_list(Min,Max, Num)->
	lists:foldl(fun(_, Acc)->
						Tmp = my_rand(Min,Max),
						[Tmp|Acc]
						end,	 [],  lists:duplicate(Num, 1)) .


%% @doc 随机获取list中的N个元素
random_from_list(L,N) when length(L) >= N ->
	random_from_list(L,[],N);
random_from_list(_L,_N) ->
	[].

random_from_list(_L,E,0) -> E;
random_from_list(L,E,N) ->
	Thing = lists:nth(rand(1,length(L)), L),
	random_from_list(lists:delete(Thing, L),[Thing|E], N-1).

%% @doc 根据概率分布随机
get_random_thing(RatioList) ->
	get_random_thing(RatioList, [], 1).
get_random_thing(RatioList, Num) ->
	get_random_thing(RatioList,[], Num).

get_random_thing(_RatioList, ResList, 0) -> ResList;
get_random_thing(RatioList, ResList, Num) ->
    F = fun({X,Ratio},{NewX,SumRatio})->
			{[{X,SumRatio,SumRatio+Ratio}|NewX],SumRatio + Ratio}
		end,
    {NewRatioList,Sum} = lists:foldl( F,{[],0},RatioList),
    Random = Sum*random:uniform(),
    if
    	Random == 0 ->
    		[Res] = [Type|| { Type,Min,_} <- NewRatioList, Min == 0 ];
    	true -> 
    		[Res] = [Type|| { Type,Min,Max} <- NewRatioList, Random > Min,Random =< Max ]
    end,
    get_random_thing(lists:keydelete(Res, 1, RatioList), [Res|ResList], Num - 1 ).












%%
%% http相关
%%
get_http_content(Url) ->
	case httpc:request(get, {Url, []}, [{timeout, 5000}], []) of
		{ok, {_Status, _Headers, Raw}} ->
			Raw;
		{error, Reason} ->
			{error, Reason}
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

url_encode(String)->
	url_encode(String,[]).

-define(QS_SAFE(C), ((C >= $a andalso C =< $z) orelse
                     (C >= $A andalso C =< $Z) orelse
                     (C >= $0 andalso C =< $9) orelse
                     (C =:= $. orelse C =:= $- orelse C =:= $~ orelse
                      C =:= $_))).
url_encode([], Acc) ->
    lists:reverse(Acc);
url_encode([C | Rest], Acc) when ?QS_SAFE(C) ->
    url_encode(Rest, [C | Acc]);
url_encode([$\s | Rest], Acc) ->
    url_encode(Rest, [$+ | Acc]);
url_encode([C | Rest], Acc) ->
    <<Hi:4, Lo:4>> = <<C>>,
    url_encode(Rest, [hexdigit(Lo), hexdigit(Hi), $% | Acc]).
hexdigit(C) when C < 10 -> $0 + C;
hexdigit(C) when C < 16 -> $A + (C - 10).





%% return 0 || 1
get_by_bit(Int32, N) when N>0,N<33->
    Max = 32,
    Start = N-1,
    End = Max-N,
    <<_Head:End/binary-unit:1, State:1, _Body:Start/binary-unit:1>> = <<Int32:32>>,
    State.

%% v = 1 || 0
%% return Int32
update_by_bit(Int32, N, V) when N>0 andalso N<33 andalso (V=:=0 orelse V=:=1) ->
    Max = 32,
    Start = N-1,
    End = Max-N,
    <<Head:End/binary-unit:1, _:1, Body:Start/binary-unit:1>> = <<Int32:32>>,
    <<NewInt32:32>> = <<Head:End/binary-unit:1, V:1, Body:Start/binary-unit:1>>,
    NewInt32.









%%
%% IP格式转换
%%
%% @doc get IP address string from Socket
ip(Socket) ->
  	{ok, {IP, _Port}} = inet:peername(Socket),
  	{Ip0,Ip1,Ip2,Ip3} = IP,
	list_to_binary(integer_to_list(Ip0)++"."++integer_to_list(Ip1)++"."++integer_to_list(Ip2)++"."++integer_to_list(Ip3)).

%% 获取来源IP 
get_ip(Socket) ->
	case inet:peername(Socket) of 
		{ok, {PeerIP,_Port}} ->
			ip_to_binary(PeerIP);
		{error, _NetErr} -> 
			""
	end.

get_ip_str(Socket) ->
    case inet:peername(Socket) of
        {ok,{PeerIP,_Port}} ->
            IP = ip_str(PeerIP),
            to_list(IP);
        {error,_NetErr} ->
            ""
    end.

%% @return int ip
get_ip_long1(Socket) ->
    case inet:peername(Socket) of
        {ok, {{A1,A2,A3,A4},_Port}} ->
            A1*256*256*256+A2*256*256+A3*256+A4;
        {error, _NetErr} ->
                0
    end.

%% @return ip :: {A,B,C,D} || false
get_ip_long(Scoket) ->
    case inet:peername(Scoket) of
        {ok, {{A1,A2,A3,A4},_Port}} ->
            {A1,A2,A3,A4};
        _ ->
            false
    end.

ip_to_binary(Ip) ->
	case Ip of 
		{A1,A2,A3,A4} -> 
			[ integer_to_list(A1), ".", integer_to_list(A2), ".", integer_to_list(A3), ".", integer_to_list(A4) ];
		_ -> 
			"-"
	end.

%% Args Ip :: integer
%% return Ip like "192.168.1.1"
ip_to_string(Ip) when is_integer(Ip) ->
    <<A:8, B:8, C:8, D:8>> = <<Ip:32>>,
    lists:concat([A, ".", B, ".", C, ".", D]).

ip_str(IP) ->
	case IP of
		{A, B, C, D} ->
			lists:concat([A, ".", B, ".", C, ".", D]);
		{A, B, C, D, E, F, G, H} ->
			lists:concat([A, ":", B, ":", C, ":", D, ":", E, ":", F, ":", G, ":", H]);
		Str when is_list(Str) ->
			Str;
		_ ->
			[]
	end.

%% @args List :: tuple list
%% @args Key 唯一key的位置
%% @args OverlapN 叠加字段的位置
overlap_tuple_list(List, Key, OverlapN) ->
    lists:foldl(fun(E, L) ->
                        Id = element(Key, E),
                        OldValue =
                            case lists:keyfind(Id, Key, L) of
                                false ->
                                    0;
                                OldE ->
                                    element(OverlapN, OldE)
                            end,
                        NewE = setelement(OverlapN, E, OldValue+element(OverlapN, E)),
                        lists:keystore(Id, Key, L, NewE)
                end, [], List).



%%
%% 其他
%%
%% @doc 转换成HEX格式的md5
md5(S) ->
    byte2hexstr(erlang:md5(S)).

byte2hexstr(Bin) ->
	%% 2(2个字符).16.0B(16进制 不足位0补齐)
    lists:flatten([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(Bin)]).

%% @doc 转换成HEX格式的hmac
hmac(Key, Data) ->
    Binary = crypto:hmac(sha, Key, Data),
    byte2hexstr(Binary).

sleep(T) ->
	receive
    after T -> ok
    end.

sleep(T, F) ->
    receive
    after T -> F()
    end.

get_countdown(Time) ->
	Now = unixtime(),
	case Time > Now of
		true ->
			Time - Now;
		_ ->
			0
	end.
    
eval(S) ->
    {ok,Scanned,_} = erl_scan:string(S),
    {ok,Parsed} = erl_parse:parse_exprs(Scanned),
    {value, Value,_} = erl_eval:exprs(Parsed,[]),
    Value.

cancel_timer(Timer) ->
	case get(Timer) of
        undefined -> skip;
		Timer1 ->
            erlang:cancel_timer(Timer1)
	end.

%% @doc quick sort
quick_sort([]) ->
	[];
quick_sort([H|T]) -> 
	quick_sort([X||X<-T,X<H]) ++ [H] ++ quick_sort([X||X<-T,X>=H]).

%% return bool()
is_function_exported(Module, Function, ArgsNum) ->
  case erlang:module_loaded(Module) of
    true ->
      next;
    _ ->
      code:load_file(Module)
  end,
  erlang:function_exported(Module, Function, ArgsNum).

%% RecordList [Record|..], Record's string field must be binary
%% return IoList
%% IoList :: sql string, like (1,2,3),(3,4,5)
make_sql_value_string(RecordList) when RecordList=/=[] ->
    [One|Ret] = RecordList,
    Body = [make_sql_string_one(One)|[[","|make_sql_string_one(X)]||X<-Ret]],
    iolist_to_binary([" "|Body]).
make_sql_string_one(Tuple) when is_tuple(Tuple) ->
    [_Tag, Id|Info] = tuple_to_list(Tuple),
    Body = lists:foldl(fun(X, L) ->
                             if
                                 is_integer(X) ->
                                     [",",integer_to_list(X)|L];
                                 is_bitstring(X) ->
                                     [",'",X,"'"|L];
                                 true ->
                                     [",'",util:term_to_bitstring(X),"'"|L]
                             end
                       end, [")"], lists:reverse(Info)),
    ["(",integer_to_list(Id)|Body].

make_sql_ids_string(IdList) when IdList=/=[] ->
    [$[|Ret1] = term_to_string(IdList),
    [$]|Ret2] = lists:reverse([$ ,$(|Ret1]),
    lists:reverse([$)|Ret2]).


one_to_two(One) ->
    Two = io_lib:format("~2..0B", [One]),
    lists:flatten(Two).

dict2list(Dict) ->
	dict:fold(fun(_,Value,Acc) -> [Value|Acc] end, [], Dict).



%% 调试使用
sync_apply(Pid, M, F, A) ->
	game_gen_server:call(Pid, util, rsync_apply, [M, F, A]).

rsync_apply([_, M, F, A]) ->
	Res = erlang:apply(M, F, A),
	{true, Res}.

apply_user(UserID, M, F, A) ->
    Fun = 
        fun([User]) ->
            erlang:apply(M, F, [User | A])
        end,
    srv_user:cast(UserID, {Fun, []}).


%% @doc http请求
%% @return {true, Body}|{error, Msg}
http_request(Transport, Method, URL, Params)->
    ParamsStr = params_join(Params),
    UrlAndParams = string:join([URL, ParamsStr], "?"),
    case do_method(Transport, Method, UrlAndParams) of
        {ok,{{"HTTP/1.1",200,"OK"}, _Header, Body}} ->
            {true, Body};
        {error, Msg} ->
            {error, Msg}
    end.

do_method(?HTTP, ?HTTP_METHOD_GET, URLAndParams) ->
    httpc:request(get, {URLAndParams, []}, [{timeout, 5000}], []);
do_method(?HTTP, ?HTTP_METHOD_POST, URLAndParams) ->
    httpc:request(post, {URLAndParams, []}, [{timeout, 5000}], []);
do_method(?HTTPS, ?HTTP_METHOD_GET, URLAndParams) ->
    httpc:request(get, {URLAndParams, []}, [{ssl,[{verify,0}]},{timeout, 5000}], []);
do_method(?HTTPS, ?HTTP_METHOD_POST, URLAndParams) ->
    httpc:request(post, {URLAndParams, []}, [{ssl,[{verify,0}]},{timeout, 5000}], []);
do_method(_, _, _URLAndParams) ->
	ok.

params_join([]) -> [];
%% @doc 合并参数, 当参数是元组时如[{"username","zengfeng"}, {"passowrd", "123455"}]
params_join([Head|_T] = L) when is_tuple(Head) ->
    List = params_join_key_value(L, []),
    params_join(List);
%% 合并参数, 当参数是列表时如["username=zengfeng", "password=1234"]
%% 将会返回这种方试 "username=zengfeng&password=1234"
params_join([Head|T] = L) ->
    case T of
        [] -> 
			Head;
        _Other ->
    		string:join(L, "&")
    end.


params_join_key_value([{Key, Value}|T], Result) ->
    case T of
        [] ->
            [(string:join([Key, url_encode(util:to_list(Value))], "="))|Result];
        [{_Key, _Value}|_T] ->
            params_join_key_value(T, [(string:join([Key, url_encode(util:to_list(Value))], "="))|Result])
    end.





