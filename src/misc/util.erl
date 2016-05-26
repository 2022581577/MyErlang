%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 
%%-----------------------------------------------------

-module(util).
-include("common.hrl").

-export([lager_filename/2]).
-export([log_filename/1]).

-export([to_integer/1
        ,to_binary/1
        ,to_float/1
        ,to_atom/1
        ,to_tuple/1
        ,to_list/1
        ,f2s/1
        ,one_to_two/1
        ,to_utf8_list/1
        ,term_to_string/1
        ,term_to_bitstring/1
        ,string_to_term/1
        ,bitstring_to_term/1

        ,prefix_server_id_str2server_id/1
        ]).

-export([socket_to_ip/1
        ,md5/1]).

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
        %,server_open_time/0
        %,server_open_date/0
        %,server_open_days/0
        %,server_merge_time/0
        %,server_merge_date/0
        %,server_merge_days/0
		]).

-export([transform_callback/1]).

%%
%% 时间函数
%%
%% 取得当前的unix时间戳，单位为s
unixtime() ->
    srv_timer:now_seconds().

%% 取得当前的unix时间戳，单位为ms
longunixtime() ->
    srv_timer:now_milseconds().

%% @doc 获取1970年以来的天数
unixdays() ->
    {{Year, Month, Day}, _} = seconds_to_localtime(unixtime()),
    calendar:date_to_gregorian_days(Year, Month, Day).

%% 获取当前的unix日期
date() ->
    seconds_to_localtime(srv_timer:now_seconds()).

%% @doc 根据1970年以来的秒数获得日期
seconds_to_localtime(Seconds) ->
    DateTime = calendar:gregorian_seconds_to_datetime(Seconds + ?DIFF_SECONDS_0000_1970),
    calendar:universal_time_to_local_time(DateTime).

%% 根据日期和时间获得1970年以来的秒数
%% LocalTime::datetime1970()
localtime_to_seconds(LocalTime) ->
    calendar:datetime_to_gregorian_seconds(erlang:localtime_to_universaltime(LocalTime)) - ?DIFF_SECONDS_0000_1970.

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
    Monday = Seconds1 - Diff1 - (Week1-1) * ?TIMER_ONE_DAY_SEC,
    Sunday = Seconds1 + (?TIMER_ONE_DAY_SEC - Diff1) + (7 - Week1) * ?TIMER_ONE_DAY_SEC,
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
    NextDay = Seconds + (?TIMER_ONE_DAY_SEC - Diff),
    {Today, NextDay}.

%% @doc 获取下一天开始的时间
get_next_day_seconds(Now) ->
	{{_Year, _Month, _Day}, Time} = seconds_to_localtime(Now),
    % 从午夜到现在的秒数
   	Diff = calendar:time_to_seconds(Time),
	Now + (?TIMER_ONE_DAY_SEC - Diff).

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

%%%% @doc 开服时间
%%server_open_time() ->
%%    srv_param:get_value(?ETS_GLOBAL_PARAM, service_start_time).
%%%% @doc 开服日期
%%server_open_date() ->
%%    Time = server_open_time(),
%%    seconds_to_localtime(Time).
%%%% @doc 开服天数
%%server_open_days() ->
%%    {{Year, Month, Day}, _} = util:server_open_date(),
%%    OpenDays = calendar:date_to_gregorian_days(Year, Month, Day),
%%    UnixDays = unixdays(),
%%    UnixDays - OpenDays + 1.

%%%% @doc 合服时间
%%server_merge_time() ->
%%    #server_config{merge_time = MergeTime} = srv_param:get_value(?ETS_GLOBAL_PARAM, server_config),
%%    NowTime = unixtime(),
%%    ?IF(MergeTime > NowTime, 0, MergeTime).
%%%% @doc 合服日期
%%server_merge_date() ->
%%    seconds_to_localtime(server_merge_time()).
%%server_merge_days() ->
%%    {{Year, Month, Day}, _} = util:server_merge_date(),
%%    OpenDays = calendar:date_to_gregorian_days(Year, Month, Day),
%%    UnixDays = unixdays(),
%%    UnixDays - OpenDays + 1.


%% lager filename
lager_filename(BaseDir, Level) ->
    BaseDir ++ to_list(Level) ++ ".log".
%lager_filename(BaseDir, Level) ->
%    log_filename(lists:concat([BaseDir,?CONFIG(server_type),"_",?CONFIG(platform),"_",?CONFIG(prefix),?CONFIG(server_id),"_"]), 
%        "." ++ to_list(Level) ++ ".log").


%% 游戏输出日志文件名
log_filename(BaseDir) ->
    log_filename(lists:concat([BaseDir,?CONFIG(server_type),"_",?CONFIG(platform),"_",?CONFIG(prefix),?CONFIG(server_id),"_"]), ".log").

log_filename(FilePrefix, FileSuffix) ->
    {{Y, M, D}, {H, MM, S}} = erlang:localtime(),
    NewM = one_to_two(M),
    NewD = one_to_two(D),
    NewH = one_to_two(H),
    NewMM = one_to_two(MM),
    NewS = one_to_two(S),
    lists:concat([FilePrefix,Y,NewM,NewD,"-",NewH,NewMM,NewS,FileSuffix]).

one_to_two(One) ->
    Two = io_lib:format("~2..0B", [One]),
    lists:flatten(Two).

%%f2s(N) when is_integer(N) ->
%%    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]), A.

%% @doc 转换为AcsII list(一般传入binary)
to_utf8_list(Msg) ->
    L = unicode:characters_to_list(to_binary(Msg)),
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

%% @doc convert other type to tuple
to_tuple(T) when is_tuple(T) -> T;
to_tuple(T) when is_list(T) -> 
	list_to_tuple(T);
to_tuple(T) -> {T}.

to_list(Msg) when is_list(Msg) -> Msg;
to_list(Msg) when is_atom(Msg) -> atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) -> binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) ->
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) -> f2s(Msg);
to_list(Msg) when is_tuple(Msg) -> tuple_to_list(Msg);
to_list(_) -> throw(other_value).

socket_to_ip(Socket) ->
    case inet:peername(Socket) of
        {ok,{{A,B,C,D}, _Port}} ->
            lists:concat([A,".",B,".",C,".",D]);
        {error,Reason} ->
            ?WARNING("get_ip fail,Socket:~w,Reason:~w",[Socket,Reason]),
            ""
    end.

md5(S) ->
    lists:flatten([io_lib:format("~2.16.0b", [N]) || N <- binary_to_list(erlang:md5(S))]).

%% @doc 回调函数参数解析
transform_callback({M, F, A}) ->
    {M, F, A};
transform_callback({F, A}) ->
    {undefined, F, A};
transform_callback(F) when is_function(F) ->
    {undefined, F, []};
transform_callback(_) ->
    erlang:error(badargs).

prefix_server_id_str2server_id(PrefixServerIDStr) ->
    util:to_integer(PrefixServerIDStr -- util:to_list(?CONFIG(prefix))).
