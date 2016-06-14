%%-----------------------------------------------------
%% @Module:navmesh 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-6
%% @Desc:
%%-----------------------------------------------------

-module(navmesh).

-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([
            find_path/3
         ]).



%% @doc 导航网格寻路
find_path(CellArray, StartPoint, EndPoint) when is_record(StartPoint, vector2f), is_record(EndPoint, vector2f) ->
    case {find_closest_cell(array:to_list(CellArray), StartPoint), find_closest_cell(array:to_list(CellArray), EndPoint)} of
        {StartCell, EndCell} when is_record(StartCell, path_cell), is_record(EndCell, path_cell) ->
            case path_cell:equal(StartCell, EndCell) of
                true ->
                    [{StartPoint#vector2f.x, StartPoint#vector2f.y}, {EndPoint#vector2f.x, EndPoint#vector2f.y}];
                _ ->
                    build_path(CellArray, StartCell, EndCell, StartPoint, EndPoint)
            end;
        _ ->
            no_path
    end.

%% @return {NewCellArray, CloseList} 
build_path(CellArray, StartCell, EndCell, StartPoint, EndPoint) ->
    OpenList = binary_heap:new(fun(X1,X2) -> X1#path_cell.f < X2#path_cell.f end),
    %% if FindPathFlag==true StartCell=CloseList[0]
    case build_path1(CellArray, binary_heap:put(OpenList, EndCell), [], StartCell, EndCell) of
        {true, CloseList, _NewCellArray} ->
%%             ?DEBUG("CloseList:~w", [CloseList]),
            PathCellArray = get_cell_path(CloseList),
%%             ?DEBUG("PathCellArray:~w", [PathCellArray]),
            get_path(PathCellArray, StartPoint, EndPoint);
        _ ->
            no_path
    end.

build_path1(CellArray, OpenList, CloseList, StartCell, EndCell) ->
%%     ?DEBUG("OpenList:~w", [binary_heap:desc(OpenList, fun(X) -> X#path_cell.index end)]),
    case binary_heap:pop(OpenList) of
        {true, CurrentCell, NewOpenList} ->
            CellArray1 = array:set(CurrentCell#path_cell.index, CurrentCell#path_cell{is_open = true}, CellArray),
            case path_cell:equal(CurrentCell, StartCell) of
                true ->
                    {true, [CurrentCell|CloseList], CellArray1};
                _ ->
                    %% CurrentCell的三个可能的邻接节点
                    {NewCellArray, NewOpenList1} = build_path2(CellArray1, NewOpenList, CurrentCell, lists:seq(0, 2)),
                    build_path1(NewCellArray, NewOpenList1, [CurrentCell|CloseList], StartCell, EndCell)
            end;
        _ ->
            {false, CloseList, CellArray}
    end.

build_path2(CellArray, OpenList, _CurrentCell, []) ->
    {CellArray, OpenList};
build_path2(CellArray, OpenList, CurrentCell, [Index|IndexList]) ->
    AdjacentIndex = path_cell:get_adjacent_index(CurrentCell, Index),
    case AdjacentIndex < 0 of
        true ->
            %% 不可通行
            build_path2(CellArray, OpenList, CurrentCell, IndexList);
        _ ->
            AdjacentCell = get_cell(CellArray, AdjacentIndex),
%%             ?DEBUG("CurrentCellIndex:~w AdjacentCellIndex:~w", [CurrentCell#path_cell.index, AdjacentCell#path_cell.index]),
            case AdjacentCell#path_cell.is_open of
                false ->
%%                     如果该相邻节点不在开放列表中,则将该节点添加到开放列表中,
%%                     并将该相邻节点的父节点设为当前节点,同时保存该相邻节点的G和F值;
                    F = line2d:length_squared(CurrentCell#path_cell.triangle#triangle.center, AdjacentCell#path_cell.triangle#triangle.center),
                    NewAdjacentCell = AdjacentCell#path_cell{
                        parent = CurrentCell#path_cell.index
                        ,is_open = true
                        ,f = CurrentCell#path_cell.f + F
                    },
                    NewAdjacentCell1 = path_cell:set_arrival_wall(NewAdjacentCell, CurrentCell#path_cell.index),
                    build_path2(array:set(NewAdjacentCell1#path_cell.index, NewAdjacentCell1, CellArray), binary_heap:put(OpenList, NewAdjacentCell1), CurrentCell, IndexList);
                _ ->
%%                     如果该相邻节点在开放列表中,
%%                     则判断若经由当前节点到达该相邻节点的G值是否小于原来保存的G值,
%%                     若小于,则将该相邻节点的父节点设为当前节点,并重新设置该相邻节点的G和F值
                    NewF = CurrentCell#path_cell.f + line2d:length_squared(CurrentCell#path_cell.triangle#triangle.center, AdjacentCell#path_cell.triangle#triangle.center),
                    NewAdjacentCell =
                        case NewF < AdjacentCell#path_cell.f of
                            true ->
                                AdjacentCell#path_cell{
                                    parent = CurrentCell#path_cell.index
                                    ,f = NewF
                                };
                            _ ->
                                AdjacentCell
                        end,
                    build_path2(array:set(NewAdjacentCell#path_cell.index, NewAdjacentCell, CellArray), OpenList, CurrentCell, IndexList)
            end
    end.


%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------

%% @doc 找出给定点所在的三角型
%% @return Cell|false
find_closest_cell([], _Point) ->
    false;
find_closest_cell([Cell|CellList], Point) ->
    case triangle:is_point_in(Cell#path_cell.triangle, Point) of
        true -> Cell;
        _ -> find_closest_cell(CellList, Point)
    end.

get_cell(CellArray, Index) ->
    array:get(Index, CellArray).



%% @doc 根据CloseList生成三角形网格路径
%% @return Array
get_cell_path([Cell|CloseList]) ->
    get_cell_path(Cell, CloseList, array:new([{fixed, false}]), 0).
get_cell_path(Cell, _CloseList, PathCellArray, Seq) when Cell#path_cell.parent =:= -1 ->
    array:set(Seq, Cell#path_cell{seq = Seq}, PathCellArray);
get_cell_path(Cell, CloseList, PathCellArray, Seq) ->
    Parent = lists:keyfind(Cell#path_cell.parent, #path_cell.index, CloseList),
    get_cell_path(Parent, CloseList, array:set(Seq, Cell#path_cell{seq = Seq}, PathCellArray), Seq+1).

%% @doc 根据寻路网格返回路径点数组
get_path(PathCellArray, StartPoint, EndPoint) ->
    WayPoint = #way_point{
        position = StartPoint
        ,cell = array:get(0, PathCellArray)
    },
    get_path1(PathCellArray, WayPoint, EndPoint, [{StartPoint#vector2f.x, StartPoint#vector2f.y}]).

get_path1(PathCellArray, WayPoint, EndPoint, PathList) ->
    case vector2f:equal(WayPoint#way_point.position, EndPoint) of
        false ->
            %% 找下一个WayPoint
            NewWayPoint = get_further_way_point(PathCellArray, WayPoint, EndPoint),
            get_path1(PathCellArray, NewWayPoint, EndPoint, [{NewWayPoint#way_point.position#vector2f.x, NewWayPoint#way_point.position#vector2f.y}|PathList]);
        _ ->
            lists:reverse(PathList)
    end.

%% @doc 根据当前拐角点寻找下一个拐角点
get_further_way_point(PathCellArray, WayPoint, EndPoint) ->
    CurrentPoint = WayPoint#way_point.position,
    CurrentCell = WayPoint#way_point.cell,
    StartSeq = CurrentCell#path_cell.seq,
    Outside = lists:nth(CurrentCell#path_cell.arrival_wall+1, CurrentCell#path_cell.triangle#triangle.sides),
    LastPointA = Outside#line2d.point_a,
    LastPointB = Outside#line2d.point_b,
    LastLineA = line2d:new(CurrentPoint, LastPointA),
    LastLineB = line2d:new(CurrentPoint, LastPointB),
    get_further_way_point1(StartSeq+1, array:size(PathCellArray), PathCellArray, LastPointA, LastPointB, LastLineA, LastLineB, CurrentCell, EndPoint).


get_further_way_point1(StartSeq, Size, PathCellArray, LastPointA, LastPointB, LastLineA, LastLineB, LastCell, EndPoint) when StartSeq < Size ->
    Cell = get_cell(PathCellArray, StartSeq),
%%     ?DEBUG("ArrivalWall:~w Sides:~w", [Cell#path_cell.arrival_wall, Cell#path_cell.triangle#triangle.sides]),
    Outside = lists:nth(erlang:max(0, Cell#path_cell.arrival_wall) + 1, Cell#path_cell.triangle#triangle.sides),
    {TestPointA, TestPointB} =
        case StartSeq == Size - 1 of
            true ->
                {EndPoint, EndPoint};
            _ ->
                {Outside#line2d.point_a, Outside#line2d.point_b}
        end,
%%      ?DEBUG("LastPointA:~w LastPointB:~w TestPointA:~w, TestPointB:~w ", [LastPointA, LastPointB, TestPointA, TestPointB]),
    Result =
        case {vector2f:equal(LastPointA, TestPointA), vector2f:equal(LastPointB, TestPointB)} of
            {false, _} ->
                %% 左点不重合
                case line2d:classify_point(LastLineB, TestPointA) == ?POINT_RIGHT_SIDE of
                    true ->
                        %% 左点在右线的右边
                        %% find way_point
                        {true, #way_point{cell = LastCell, position = LastPointB}};
                    _ ->
                        %% 左点在右线的左边
                        case line2d:classify_point(LastLineA, TestPointA) =/= ?POINT_LEFT_SIDE of
                            true ->
                                %% 左点在左线的右边 更新左点 LastCell
                                {false, TestPointA, LastPointB, line2d:set_point_b(LastLineA, TestPointA), LastLineB, Cell};
                            _ ->
                                {false, LastPointA, LastPointB, LastLineA, LastLineB, LastCell}
                        end
                end;
            {_, false} ->
                %% 右点不重合
                case line2d:classify_point(LastLineA, TestPointB) == ?POINT_RIGHT_SIDE of
                    true ->
                        %% 右点在左线的左边
                        %% find way_point
                        {true, #way_point{cell = LastCell, position = LastPointA}};
                    _ ->
                        %% 右点在左线的右边
                        case line2d:classify_point(LastLineB, TestPointB) =/= ?POINT_RIGHT_SIDE of
                            true ->
                                %% 右点在右线的左边 更新右点 LastCell
                                {false, LastPointA, TestPointB, LastLineA, line2d:set_point_b(LastLineB, TestPointB), Cell};
                            _ ->
                                {false, LastPointA, LastPointB, LastLineA, LastLineB, LastCell}
                        end
                end
        end,
    case Result of
        {true, NewWayPoint} ->
            NewWayPoint;
        {false, NewLastPointA, NewLastPointB, NewLastLineA, NewLastLineB, NewLastCell} ->
            get_further_way_point1(StartSeq + 1, Size, PathCellArray, NewLastPointA, NewLastPointB, NewLastLineA, NewLastLineB, NewLastCell, EndPoint)
    end;
get_further_way_point1(_StartSeq, Size, PathCellArray, _LastPointA, _LastPointB, _LastLineA, _LastLineB, _LastCell, EndPoint) ->
    #way_point{cell = get_cell(PathCellArray, Size-1), position = EndPoint}.







