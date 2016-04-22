%%-----------------------------------------------------
%% @Module:triangle 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-4
%% @Desc:
%%-----------------------------------------------------

-module(triangle).
-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).


%% @doc 顺时针
new(PointA, PointB, PointC) ->
	Temp1 = vector2f:add(vector2f:add(PointA, PointB), PointC),
	Center = vector2f:mult(Temp1, 1.0/3.0),
	SideAB = line2d:new(PointA, PointB),
	SideBC = line2d:new(PointB, PointC),
	SideCA = line2d:new(PointC, PointA),
	#triangle{
		center = Center
		,point_a = PointA
		,point_b = PointB
		,point_c = PointC
		,sides = [SideAB, SideBC, SideCA]
	}.

%% @doc 根据索引得到三角形的顶点0-a 1-b 2-c
get_vertex(Triangle, Index) ->
	erlang:element(3+Index, Triangle).

%% @doc 根据索引得到三角形的边0-AB 1-BC 2-CA
get_side(Triangle, Index) ->
	lists:nth(Index, Triangle#triangle.sides).

%% @doc 判断点是否在三角形内(点在所有边的右边)
is_point_in(Triangle, Point) ->
	F = fun(X, Acc) ->
		case line2d:classify_point(X, Point) of
			?POINT_LEFT_SIDE ->
				false;
			_ ->
				Acc
		end
	end,
	lists:foldl(F, true, Triangle#triangle.sides).
%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------


