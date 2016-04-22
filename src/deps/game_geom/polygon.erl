%%-----------------------------------------------------
%% @Module:polygon 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-4
%% @Desc:
%%-----------------------------------------------------

-module(polygon).
-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([
		 	new/1
			,is_point_in/2
			,get_rectangle/1
			,intersection/2
		]).



%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------


new(PointList = [P|L]) ->
	#polygon{
		vertex_num = length(PointList)
		,vertexs = PointList
		,sides = sides(L,P,P,[])
	}.

sides([],PrevPoint,FirstPoint,LineList) ->
	[line2d:new(PrevPoint, FirstPoint)|LineList];
sides([Point|List], PrevPoint, FirstPoint, LineList) ->
	sides(List, Point, FirstPoint, [line2d:new(PrevPoint, Point)|LineList]).


%% @doc 顺时针
is_cw(_PointList) ->
	ok.


%% @doc 返回矩形包围盒
get_rectangle(_Polygon = #polygon{vertexs = [Point|List]}) ->
	F = fun(X, {LX, RX, TY, BY}) ->
		LX1 =
			case X#vector2f.x < LX of
				true ->
					X#vector2f.x;
				_ ->
					LX
			end,
		TY1 =
			case X#vector2f.y < TY of
				true ->
					X#vector2f.y;
				_ ->
					TY
			end,
		RX1 =
			case X#vector2f.x > RX of
				true ->
					X#vector2f.x;
				_ ->
					RX
			end,
		BY1 =
			case X#vector2f.y > BY of
				true ->
					X#vector2f.y;
				_ ->
					BY
			end,
		{LX1, RX1, TY1, BY1}
	end,
	{NewLX, NewRX, NewTY, NewBY} = lists:foldl(F, {Point#vector2f.x, Point#vector2f.x, Point#vector2f.y, Point#vector2f.y}, List),
	rectangle:new(NewLX, NewTY, NewRX - NewLX, NewBY - NewTY).

%% @doc 判断直线和多边形是否相交
%% @return true|false
intersection(Polygon, Line) ->
	intersection(Polygon#polygon.sides, Line, false).

intersection([], _Line, Result) ->
	Result;
intersection([Side|L], Line, Result) ->
	case line2d:intersection(Line, Side) of
		{?SEGMENTS_INTERSECT, _IntersectPoint} ->
			true;
		_ ->
			intersection(L, Line, Result)
	end.

%% @doc 判断点是否多边形内(点在所有边的右边)
%% @return true|false
is_point_in(Polygon, Point) when is_record(Polygon,polygon) ->
	is_point_in(Polygon#polygon.sides, Point);
is_point_in([], _Point) ->
	true;
is_point_in([Side|Left], Point) -> 
	case line2d:classify_point(Side, Point) of
		?POINT_LEFT_SIDE ->
			false;
		_ ->
			is_point_in(Left, Point)
	end.




    

