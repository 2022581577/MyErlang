%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.22
%%% @desc   : 排序算法
%%%----------------------------------------------------------------------

-module(sort_test).

-export([insert_sort/1
        ,select_sort/1
        ,double_select_sort/1
        ,bubble_sort/1
    ]).

%%% --------
%%% 插入排序
%%% --------
%% @doc 直接插入排序
insert_sort(L) ->
    insert_sort(L, []).

insert_sort([], L) ->
    L;
insert_sort([H | T], L) ->
    L1 = insert_sort(L, H, []),
    insert_sort(T, L1).

insert_sort([], V, L) ->
    lists:reverse([V | L]);
insert_sort([H | T], V, L) ->
    case H =< V of
        true ->
            insert_sort(T, V, [H | L]);
        _ ->
            lists:reverse(L) ++ [V, H | T]
    end.

%shell_insert_sort(L) ->
%    shell_insert_sort(L, []).
%
%shell_insert_sort([], L) ->
%    L;


%%% --------
%%% 插入排序
%%% --------


%%% --------
%%% 选择排序
%%% --------
%% @doc 普通选择排序
select_sort(L) ->
    select_sort(L, []).

select_sort([], L) ->
    L;
select_sort([H | T], L) ->
    {T1, Max} = select_sort1(T, [], H),
    select_sort(T1, [Max | L]).

select_sort1([], L, Max) ->
    {L, Max};
select_sort1([H | T], L, Max) ->
    case Max >= H of
        true ->
            select_sort1(T, [H | L], Max);
        _ ->
            select_sort1(T, [Max | L], H)
    end.

%% @doc 二元选择排序
double_select_sort(L) ->
    double_select_sort(L, [], []).

double_select_sort([], MinL, MaxL) ->
    lists:reverse(MinL) ++ MaxL;
double_select_sort([M], MinL, MaxL) ->
    lists:reverse(MinL) ++ [M | MaxL];
double_select_sort([H1, H2 | T], MinL, MaxL) ->
    {T1, Min, Max} = double_select_sort1(T, min(H1, H2), max(H1, H2), []),
    double_select_sort(T1, [Min | MinL], [Max | MaxL]).

double_select_sort1([], Min, Max, L) ->
    {L, Min, Max};
double_select_sort1([H | T], Min, Max, L) ->
    case H < Min of
        true ->
            double_select_sort1(T, H, Max, [Min | L]);
        _ ->
            case H > Max of
                true ->
                    double_select_sort1(T, Min, H, [Max | L]);
                _ ->
                    double_select_sort1(T, Min, Max, [H | L])
            end
    end.


%%% --------
%%% 选择排序
%%% --------

%%% --------
%%% 交换排序
%%% --------
%% @doc 冒泡排序
bubble_sort(L) ->
    put(bubble_sort, sort),
    bubble_sort(L, []).

bubble_sort([], SortL) ->
    SortL;
bubble_sort([A], SortL) ->
    [A | SortL];
bubble_sort(L, SortL) ->
    {L1, Max} = bubble_sort1(L, []),
    case get(bubble_sort) of
        sort ->
            io:format("bubble_sort sort!~n"),
            L;
        _ ->
            bubble_sort(L1, [Max | SortL])
    end.


bubble_sort1([V], L) ->
    {L, V};
bubble_sort1([A, B | T], L) ->
    case A > B of
        true ->
            put(bubble_sort, unsort),
            bubble_sort1([A | T], [B | L]);
        _ ->
            bubble_sort1([B | T], [A | L])
    end.

    


