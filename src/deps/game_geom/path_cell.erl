%%-----------------------------------------------------
%% @Module:path_cell 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-6
%% @Desc:
%%-----------------------------------------------------

-module(path_cell).

-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).

%% @doc 根据PolygonList生成CellArray navmesh:find_path的输入
create_cells(PolygonList) ->
	TriangleList = delaunay:create_delaunay(PolygonList),
	{CellList, _} = lists:foldl(fun(X, {L, Index}) -> {[#path_cell{triangle = X, index = Index}|L],Index+1} end, {[], 0}, TriangleList),
	link(CellList, CellList, array:new([{fixed, false}])).

link([], _CellList, CellArray) ->
	CellArray;
link([Cell|List], CellList, CellArray) ->
	NewCell = link1(Cell, CellList),
	link(List, CellList, array:set(NewCell#path_cell.index, NewCell, CellArray)).

link1(Cell, []) ->
	Cell;
link1(Cell, [TestCell|List]) ->
	case equal(Cell, TestCell) of
		false ->
			link1(check_and_link(Cell, TestCell), List);
		_ ->
			link1(Cell, List)
	end.

new(Index, Triangle = #triangle{point_a = PointA, point_b = PointB, point_c = PointC}) ->
	WallMidpoint0 = vector2f:new((PointA#vector2f.x + PointB#vector2f.x) / 2.0, (PointA#vector2f.y + PointB#vector2f.y) / 2.0),
	WallMidpoint1 = vector2f:new((PointC#vector2f.x + PointB#vector2f.x) / 2.0, (PointC#vector2f.y + PointB#vector2f.y) / 2.0),
	WallMidpoint2 = vector2f:new((PointA#vector2f.x + PointC#vector2f.x) / 2.0, (PointA#vector2f.y + PointC#vector2f.y) / 2.0),
	WallDistanceArray =
		lists:foldl(fun(X, {Index1, Array}) -> {Index1 + 1, array:set(Index, X, Array)} end, 
					{0, array:new(3, [{fixed, true}, {default, 0}])}, 
					[
						vector2f:length(vector2f:subtract(WallMidpoint0, WallMidpoint1)),
						vector2f:length(vector2f:subtract(WallMidpoint1, WallMidpoint2)),
						vector2f:length(vector2f:subtract(WallMidpoint2, WallMidpoint0))
					]),
	#path_cell{
		triangle = Triangle
		,index = Index
		,wall_distance_array = WallDistanceArray
	}.

equal(CellA, CellB) ->
	CellA#path_cell.index =:= CellB#path_cell.index.

%% @doc CellA连接CellB
%% @return NewCellA
check_and_link(CellA = #path_cell{link_array = LinkArray, triangle = #triangle{point_a = TestPointA, point_b = TestPointB, point_c = _TestPointC}}, 
			   CellB) ->
 	case {get_link(CellA, ?TRIANGLE_SIDE_AB) == -1, request_link(TestPointA, TestPointB, CellB)} of
		{true, true} ->
			CellA#path_cell{link_array = array:set(?TRIANGLE_SIDE_AB, CellB#path_cell.index, LinkArray)};
		_ ->
			check_and_link1(CellA, CellB)
	end.
check_and_link1(CellA = #path_cell{
			   triangle = #triangle{point_a = _TestPointA, point_b = TestPointB, point_c = TestPointC}
			   ,link_array = LinkArray}, CellB) ->
 	case {get_link(CellA, ?TRIANGLE_SIDE_BC) == -1, request_link(TestPointB, TestPointC, CellB)} of
		{true, true} ->
			CellA#path_cell{link_array = array:set(?TRIANGLE_SIDE_BC, CellB#path_cell.index, LinkArray)};
		_ ->
			check_and_link2(CellA, CellB)
	end.
check_and_link2(CellA = #path_cell{
			   triangle = #triangle{point_a = TestPointA, point_b = _TestPointB, point_c = TestPointC}
			   ,link_array = LinkArray}, CellB) ->
 	case {get_link(CellA, ?TRIANGLE_SIDE_CA) == -1, request_link(TestPointC, TestPointA, CellB)} of
		{true, true} ->
			CellA#path_cell{link_array = array:set(?TRIANGLE_SIDE_CA, CellB#path_cell.index, LinkArray)};
		_ ->
			CellA
	end.

%% Cell0 Cell1

%% @doc 设置cell的穿出边
%% @doc 从终点反向寻路时 current->adjacent 所以Adjacent的穿出边由current指定
%% @param AdjacentCellIndex 邻接CellIndex
%% @return NewCell -1,1,7
set_arrival_wall(AdjacentCell = #path_cell{link_array = LinkArray}, CurrentCellIndex) ->
	{NewAdjacentCell, _NewIndex} =
		lists:foldl(fun(X, {Acc, Index}) ->
						case X == CurrentCellIndex of  
							true ->  
								{Acc#path_cell{arrival_wall = Index}, Index+1};
							_ -> 
								{Acc, Index+1}
						end
					end, {AdjacentCell, 0}, array:to_list(LinkArray)),
	NewAdjacentCell.

%% @doc 获得邻接三角形Cell的index
get_adjacent_index(_Cell = #path_cell{link_array = LinkArray}, Side) ->
	array:get(Side, LinkArray).
%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------
get_link(_Cell = #path_cell{link_array = LinkArray}, Side) ->
	array:get(Side, LinkArray).

set_link(Cell = #path_cell{link_array = LinkArray}, Side, TargetIndex) ->
	NewLinkArray = array:set(Side, TargetIndex, LinkArray),
	Cell#path_cell{
		link_array = NewLinkArray
	}.

request_link(TestPointA, TestPointB, _TargetCell = #path_cell{triangle = #triangle{point_a = PointA, point_b = PointB, point_c = PointC}}) ->
	case {vector2f:equal(PointA, TestPointA), 
		  vector2f:equal(PointA, TestPointB), 
		  vector2f:equal(PointB, TestPointA), 
		  vector2f:equal(PointB, TestPointB), 
		  vector2f:equal(PointC, TestPointA), 
		  vector2f:equal(PointC, TestPointB)} of
		{true, _, _, true, _, _} ->
			%% ab
			true;
		{true, _, _, _, _, true} ->
			%% ac
			true;
		{_, true, true, _, _, _} ->
			%% ab
			true;
		{_, _, true, _, _, true} ->
			%% bc
			true;
		{_, true, _, _, true, _} ->
			%% ca
			true;
		{_, _, _, true, true, _} ->
			%% cb
			true;
		_ ->
			false
	end.











