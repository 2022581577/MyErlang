%%-----------------------------------------------------
%% @Module:math_util 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-6-13
%% @Desc:
%%-----------------------------------------------------

-module(math_util).

%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).
-compile(export_all).


%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------
%% 正弦表 (将浮点数 *1024 整型化)（从90度开始顺时针）
-define(SIN_TABLE, 
[
        1024,    1019,    1004,    979,    946,    903,    851,    791,
        724,    649,    568,    482,    391,    297,    199,    100,    
        0,       -100,    -199,    -297,    -391,    -482,    -568,    -649,    
        -724,    -791,    -851,    -903,    -946,    -979,    -1004,    -1019,    
        -1024,    -1019,    -1004,    -979,    -946,    -903,    -851,    -791,    
        -724,    -649,    -568,    -482,    -391,    -297,    -199,    -100,    
        0,         100,    199,    297,    391,    482,    568,    649,    
        724,    791,    851,    903,    946,    979,    1004,    1019
]).


%% 余弦表 (将浮点数 *1024 整型化)(-90度开始顺时针)
-define(COS_TABLE,
[
        0,        -100,    -199,    -297,    -391,    -482,    -568,    -649,    
        -724,    -791,    -851,    -903,    -946,    -979,    -1004,    -1019,    
        -1024,    -1019,    -1004,    -979,    -946,    -903,    -851,    -791,    
        -724,    -649,    -568,    -482,    -391,    -297,    -199,    -100,    
        0,         100,    199,    297,    391,    482,    568,    649,    
        724,    791,    851,    903,    946,    979,    1004,    1019,    
        1024,    1019,    1004,    979,    946,    903,    851,    791,    
        724,    649,    568,    482,    391,    297,    199,    100
]).

internal_dir_sin_cos(SinCosTable, Dir, MaxDir) ->
     case Dir < 0 orelse Dir >= MaxDir of
        true ->
            -1;
        _ ->    
            Index = util:floor((Dir bsl 6) rem MaxDir),
            lists:nth(Index, SinCosTable)
    end.

dir_sin(Dir, MaxDir) ->
    internal_dir_sin_cos(?SIN_TABLE, Dir, MaxDir).

dir_cos(Dir, MaxDir) ->
    internal_dir_sin_cos(?COS_TABLE, Dir, MaxDir).

get_distance(X1, Y1, X2, Y2) ->
    util:floor(math:sqrt((X1 - X2) * (X1 - X2) + (Y1 - Y2) * (Y1 - Y2))).

get_dir_index(X1, Y1, X2, Y2) ->
    case X1 =:= X2 andalso Y1 =:= Y2 of
        true ->
            -1;
        _ ->
            X1_1 = X1 bsl 6,
            Y1_1 = Y1 bsl 6,
            X2_1 = X2 bsl 6,
            Y2_1 = Y2 bsl 6,
            Distance = get_distance(X1_1, Y1_1, X2_1, Y2_1),
            case Distance of
                0 ->
                    -1;
                _ ->                    
                    DeltaY = Y2_1 - Y1_1,
                    Sin = util:floor((DeltaY bsl 10) / Distance),
                    {Index, Compensation} = a(Sin,lists:seq(0,31)),
                    case Index =/= 0 of
                        true ->
                            case X2_1 >= X1_1 of
                                true ->
                                    Index1 = 63 - Index,
                                    if 
                                        Compensation =:= 1 ->
                                            Index1 + 1;
                                        true ->
                                            Index1
                                    end;
                                _ ->
                                    Index
                            end;
                        _ ->
                            -1
                    end
            end
    end.

a(Sin,List) ->
    a(Sin,List,length(List), 0).
a(_Sin, _List, Length, Index) when Length =:= Index + 1 ->
    {Index-1, 0};
a(Sin,List,Length,Index) ->
    ListIndex = Index + 1,
    case Sin > lists:nth(ListIndex, ?SIN_TABLE) of
        true ->
            case Sin =:= lists:nth(ListIndex-1, ?SIN_TABLE) of
                true ->
                    {Index-1, 1};
                _ ->
                    {Index-1, 0}
            end;
        _ ->
            a(Sin, List, Length, Index+1)
    end.


get_dir_diff(OriginX, OriginY, TargetX, TargetY, TestX, TestY) ->
    TargetDir = get_dir_index(OriginX, OriginY, TargetX, TargetY),
    TestDir = get_dir_index(OriginX, OriginY, TestX, TestY),
    DirDiff = TargetDir - TestDir,
    if 
        DirDiff < 0 ->
            DirDiff + 64;
        DirDiff > 32 ->
            64 - DirDiff;
        true ->
            DirDiff
    end.

get_dir_angle(OriginX, OriginY, TargetX, TargetY, TestX, TestY) ->
    TargetDir = get_dir_index(OriginX, OriginY, TargetX, TargetY),
    TestDir = get_dir_index(OriginX, OriginY, TestX, TestY),
    DirAngle = TargetDir - TestDir,
    if 
        DirAngle < 0 ->
            DirAngle + 64;
        true ->
            DirAngle
    end.
