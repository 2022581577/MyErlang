%%-----------------------------------------------------
%% @Module:line2d 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-4
%% @Desc:
%%-----------------------------------------------------

-module(line2d).

-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([
            new/2
            ,set_point_a/2
            ,set_point_b/2
            ,length/1
            ,length/2
            ,length_squared/1
            ,length_squared/2
            ,direction/1
            ,compute_normal/1
            ,signed_distance/2
            ,classify_point/2
            ,intersection/2
            ,equal/2
        ]).

%% @doc PointA->PointB
new(PointA, PointB) ->
    Line2d = #line2d{
        point_a = PointA
        ,point_b = PointB
    },
    compute_normal(Line2d).

set_point_a(Line, PointA) ->
    compute_normal(Line#line2d{
        point_a = PointA
    }).

set_point_b(Line, PointB) ->
    compute_normal(Line#line2d{
        point_b = PointB
    }).

length(_Line2d = #line2d{point_a = PointA, point_b = PointB}) ->
    length(PointA, PointB).

length(PointA, PointB) ->
    vector2f:distance(PointA, PointB).

length_squared(_Line2d = #line2d{point_a = PointA, point_b = PointB}) ->
    length_squared(PointA, PointB).

length_squared(PointA, PointB) ->
    vector2f:distance_squared(PointA, PointB).

direction(_Line2d = #line2d{point_a = PointA, point_b = PointB}) ->
    Pt = vector2f:subtract(PointB, PointA),
    vector2f:normalize(Pt).

compute_normal(Line2d) ->
    %% get normailized direction from A to B
    Normal = direction(Line2d),
    %% Rotate by +90 degrees to get normal of line
    OldYValue = Normal#vector2f.y,
    NewNormal = Normal#vector2f{
        y = Normal#vector2f.x
        ,x = -OldYValue
    },
    Line2d#line2d{
        normal = NewNormal
        ,normal_calculated = true
    }.


%% @doc 给定点到直线的带符号距离，从a点朝向b点，右向为正，左向为负
%% @return Distance
signed_distance(Line, Point) ->
    %% AP
    Vector2f = vector2f:subtract(Point, Line#line2d.point_a),
    vector2f:dot(Vector2f, Line#line2d.normal).

%% @doc 判断点与直线的关系，假设你站在a点朝向b点，
%% @doc 则输入点与直线的关系分为：Left, Right or Centered on the line
classify_point(Line, Point) ->
    Epsilon = 0.000001,
    Distance = signed_distance(Line, Point),
%%     ?DEBUG("PointA:~w PointB:~w TestPoint:~w D:~w normal:~w", [Line#line2d.point_a, Line#line2d.point_b, Point, Distance, Line#line2d.normal]),
    if
        Distance > Epsilon ->
            ?POINT_RIGHT_SIDE;
        Distance < -Epsilon ->
            ?POINT_LEFT_SIDE;
        true ->
            ?POINT_ON_LINE
    end.


%% @doc 判断Line和OtherLine是否相交
intersection(Line, OtherLine) ->
    %% AB与OtherAB的叉积
    Denom = (Line#line2d.point_b#vector2f.x-Line#line2d.point_a#vector2f.x)
                *
            (OtherLine#line2d.point_b#vector2f.y-OtherLine#line2d.point_a#vector2f.y)
                    -
            (OtherLine#line2d.point_b#vector2f.x-OtherLine#line2d.point_a#vector2f.x)
                *
            (Line#line2d.point_b#vector2f.y-Line#line2d.point_a#vector2f.y),
    %% ??
    U0 = (OtherLine#line2d.point_b#vector2f.x-OtherLine#line2d.point_a#vector2f.x)
            *
         (Line#line2d.point_a#vector2f.y-OtherLine#line2d.point_a#vector2f.y)
                -
         (OtherLine#line2d.point_b#vector2f.y-OtherLine#line2d.point_a#vector2f.y)
            *
         (Line#line2d.point_a#vector2f.x-OtherLine#line2d.point_a#vector2f.x),
    %% AOtherA与BOtherB的叉积
    U1 = (OtherLine#line2d.point_a#vector2f.x-Line#line2d.point_a#vector2f.x)
            *
         (Line#line2d.point_b#vector2f.y-Line#line2d.point_a#vector2f.y)
                -
         (OtherLine#line2d.point_a#vector2f.y-Line#line2d.point_a#vector2f.y)
            *
         (Line#line2d.point_b#vector2f.x-Line#line2d.point_a#vector2f.x),

    %% if parallel
    if
        Denom == 0.0 ->
            %% if collinear
            if
                U0 == 0.0 andalso U1 == 0.0 ->
                    ?COLLINEAR;
                true ->
                    ?PARALELL
            end;
        true ->
            %% check if they intersect
            Newu0 = U0/Denom,
            Newu1 = U1/Denom,

            _IntersectionX = Line#line2d.point_a#vector2f.x + Newu0*(Line#line2d.point_b#vector2f.x - Line#line2d.point_a#vector2f.x),
            _IntersectionY = Line#line2d.point_a#vector2f.y + Newu0*(Line#line2d.point_b#vector2f.y - Line#line2d.point_a#vector2f.y),

            %% now determine the type of intersection
            if
                ((Newu0 >= 0.0) andalso (Newu0 =< 1.0) andalso (Newu1 >= 0.0) andalso (Newu1 =< 1.0)) ->
                    {?SEGMENTS_INTERSECT, vector2f:new(_IntersectionX, _IntersectionY)};
                (Newu1 >= 0.0) andalso (Newu1 =< 1.0) ->
                    ?A_BISECTS_B;
                (Newu0 >= 0.0) andalso (Newu0 =< 1.0) ->
                    ?B_BISECTS_A;
                true ->
                    ?LINES_INTERSECT
            end
    end.

%% @doc 判断线段是否相等 忽略方向
equal(_Line1 = #line2d{point_a = PA1, point_b = PB1}, _Line2 = #line2d{point_a = PA2, point_b = PB2}) ->
    (vector2f:equal(PA1, PA2) andalso vector2f:equal(PB1, PB2))
        orelse
    (vector2f:equal(PA1, PB2) andalso vector2f:equal(PB1, PA2)).
%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------


