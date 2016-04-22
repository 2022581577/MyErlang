-module(a_star).

-export([a_star/3]).

-define(OPEN_LIST, open_list).
-define(CLOSE_LIST, close_list).
-define(PATH_LIST, path_list).
%% {Father, Self} 开始点为{Self, Self}

a_star(A, B, BlockList) ->
    put(?OPEN_LIST, []),
    put(?CLOSE_LIST, []),
    put(?PATH_LIST, []),
    add_open_list([A]),
    add_close_list([{A, A}]),
    a_star_loop(A, B, BlockList).

a_star_loop(A, B, BlockList) ->
    case get_open_list() of
        [] ->   false;
        OpenList ->
            reset_open_list(),
            case a_star_loop1(OpenList, B, BlockList) of
                false ->    a_star_loop(A, B, BlockList);
                true ->
                    CloseList = get_close_list(),
                    find_path(A, B, CloseList)
            end
    end.

find_path(StartPos, Pos, CloseList) ->
    PathList = get(?PATH_LIST),
    case lists:keyfind(Pos, 2, CloseList) of
        {StartPos, Pos} ->
            [{StartPos, Pos} | PathList];
        {Father, Pos} ->
            put(?PATH_LIST, [{Father, Pos} | PathList]),
            find_path(StartPos, Father, CloseList);
        _ ->
            PathList
    end.
    

a_star_loop1([], _, _) ->
    false;
a_star_loop1([H | T], B, BlockList) ->
    EightPosList = get_eight_pos(H),
    case lists:member(B, EightPosList) of
        true ->
            add_close_list([{H, B}]),
            true;
        _ ->
            add_open_list(EightPosList -- BlockList),
            add_close_list([{H, E} || E <- EightPosList -- BlockList]),
            a_star_loop1(T, B, BlockList)
    end.

get_eight_pos({X, Y}) ->
    L = 
    [          {X,Y+1},
     {X-1,Y},          {X+1,Y},
               {X,Y-1},
     {X-1,Y+1},        {X+1,Y+1},
        
     {X-1,Y-1},        {X+1,Y-1}],
    CloseList = get_close_list(),
    [E || E = {PosX, PosY} <- L, 
            case lists:keyfind(E, 2, CloseList) of
                false -> PosX >= 0 andalso PosY >= 0;
                _ ->    false
            end].

reset_open_list() ->
    put(?OPEN_LIST, []).
add_open_list(L) ->
    OldL = get_open_list(),
    put(?OPEN_LIST, OldL ++ L).
get_open_list() ->
    case get(?OPEN_LIST) of
        undefined ->    [];
        L ->            L
    end.

add_close_list(L) ->
    OldL = get_close_list(),
    put(?CLOSE_LIST, OldL ++ L).
get_close_list() ->
    case get(?CLOSE_LIST) of
        undefined ->    [];
        L ->            L
    end.
