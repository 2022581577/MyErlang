%%-----------------------------------------------------
%% @Module:delaunay 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-5
%% @Desc:
%%-----------------------------------------------------

-module(delaunay).

-compile(export_all).

-include("game_geom.hrl").

%% -record(delaunay,{
%%     out_edge_vec_num        %% 区域外边界顶点数
%%     ,vertexs                %% 顶点
%%       ,edges                    %% 约束边
%%     ,lines                    %% 线段
%%     ,triangles                %% 生成的Delaunay三角形
%% }).
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).

%% @doc delaunay三角剖分
%% @return [#triangle{},....]
create_delaunay(PolygonList) ->
    {OutEdgeVecNum, {VertexList, EdgeList}} = init_data(PolygonList),
    InitEdge = get_init_out_edge(EdgeList, VertexList, OutEdgeVecNum),
%%     ?DEBUG("OutEdgeVecNum:~w~n VertexList:~w~n EdgeList:~w~n InitEdge:~w~n", [OutEdgeVecNum, VertexList, EdgeList, InitEdge]),
    create([InitEdge], VertexList, EdgeList, []).

create([], _VertexList, _EdgeList, TriangleList) ->
    lists:reverse(TriangleList);
create([Line|LineList], VertexList, EdgeList, TriangleList) ->
    case find_dt(Line, VertexList, EdgeList) of
        no_find ->
            create(LineList, VertexList, EdgeList, TriangleList);
        P3 when is_record(P3, vector2f) ->
            Line13 = line2d:new(Line#line2d.point_a, P3),
            Line32 = line2d:new(P3, Line#line2d.point_b),
            Triangle = triangle:new(Line#line2d.point_a, Line#line2d.point_b, P3),


%%                 //Step4.    如果新生成的边 p1p3 不是约束边，若已经在堆栈中，
%%                 //            则将其从中删除；否则，将其放入堆栈；类似地，可处理 p3p2.
            NewLineList1 = new_line_list(Line13, LineList, EdgeList),
            NewLineList2 = new_line_list(Line32, NewLineList1, EdgeList),
            create(NewLineList2, VertexList, EdgeList, [Triangle|TriangleList])
    end.

new_line_list(Line, LineList, EdgeList) ->
    case index_of_lines(Line, EdgeList) < 0 of
        true ->
            case index_of_lines(Line, LineList) > -1 of
                true ->
                    delete_of_lines(Line, LineList);
                _ ->
                    [Line|LineList]
            end;
        _ ->
            LineList
    end.

index_of_lines(TestLine, LineList) ->
    index_of_lines(TestLine, LineList, 0, false).
index_of_lines(_TestLine, _LineList, Index, true) ->
    Index;
index_of_lines(_TestLine, [], _Index, false) ->
    -1;
index_of_lines(TestLine, [Line|LineList], Index, Flag) ->
    case line2d:equal(TestLine, Line) of
        true ->
            index_of_lines(TestLine, LineList, Index, true);
        _ ->
            index_of_lines(TestLine, LineList, Index+1, Flag)
    end.

delete_of_lines(TestLine, LineList) ->
    delete_of_lines(TestLine, LineList, [], false).
delete_of_lines(_TestLine, _LineList, LeavingLineList, true) ->
    LeavingLineList;
delete_of_lines(_TestLine, [], LeavingLineList, false) ->
    LeavingLineList;
delete_of_lines(TestLine, [Line|LineList], LeavingLineList, Flag) ->
    case line2d:equal(TestLine, Line) of
        true ->
            delete_of_lines(TestLine, LineList, LeavingLineList++LineList, true);
        _ ->
            delete_of_lines(TestLine, LineList, [Line|LeavingLineList], Flag)
    end.

%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------
%% @doc 
%% @param 所有多边形,第0个元素为区域外边界 (输入数据)
%% @return {OutEdgeVecNum, VertexList, EdgeList} 
init_data(PolygonList) ->
    %% 区域外边界多边形
    OutPolygon = erlang:hd(PolygonList),
    {OutPolygon#polygon.vertex_num, init_data(PolygonList, [], [])}.

init_data([], VertexList, EdgeList) ->
    {lists:flatten(lists:reverse(VertexList)), lists:flatten(lists:reverse(EdgeList))};
init_data([Polygon|PolygonList], VertexList, EdgeList) ->
    init_data(PolygonList, [Polygon#polygon.vertexs|VertexList], [put_edge(Polygon#polygon.vertexs, erlang:hd(Polygon#polygon.vertexs), [])|EdgeList]).

put_edge([LastVertex], FirstVertex, EdgeList) ->
    lists:reverse([line2d:new(LastVertex, FirstVertex)|EdgeList]);
put_edge([StartVertex,EndVertex|VertexList], First, EdgeList) ->
    put_edge([EndVertex|VertexList], First, [line2d:new(StartVertex, EndVertex)|EdgeList]).

get_init_out_edge(EdgeList, VertexList, OutEdgeVecNum) ->
    case get_init_out_edge(EdgeList, VertexList, OutEdgeVecNum, 0) of
        no_find ->
            erlang:hd(EdgeList);
        InitEdge when is_record(InitEdge, line2d) ->
            InitEdge
    end.

get_init_out_edge(_EdgeList, _VertexList, OutEdgeVecNum, Num) when Num < OutEdgeVecNum ->
    no_find;
get_init_out_edge([InitEdge|EdgeList], VertexList, OutEdgeVecNum, Num) ->
    case search_out_edge(InitEdge, VertexList, true) of
        true ->
            InitEdge;
        _ ->
            get_init_out_edge(EdgeList, VertexList, OutEdgeVecNum, Num+1)
    end.

search_out_edge(_Edge, _VertexList, false) ->
    false;
search_out_edge(_Edge, [], Flag) ->
    Flag;
search_out_edge(Edge, [Vertex|VertexList], Flag) ->
    case {vertex2f:equal(Edge#line2d.point_a,Vertex),vertex2f:equal(Edge#line2d.point_b,Vertex)} of
        {false, false} ->
            %% Vertex不为InitEdge的端点
            case line2d:classify_point(Edge, Vertex) == ?POINT_ON_LINE of
                true ->
                    %% Vertex在InitEdge上 不符合要求
                    search_out_edge(Edge, VertexList, false);
                _ ->
                    search_out_edge(Edge, VertexList, Flag)
            end;
        _ ->
            search_out_edge(Edge, VertexList, false)
    end.

%% @doc 返回顶角在o点,起始边为os,终止边为oe的夹角, 即∠soe (单位：弧度) 
%% @return Angle 角度小于pi,返回正值;角度大于pi,返回负值 
line_angle(_S = #vector2f{x = SX, y = SY}, _O = #vector2f{x = OX, y = OY}, _E = #vector2f{x = EX, y = EY}) ->
    DSX = SX - OX,
    DSY = SY - OY,
    DEX = EX - OX,
    DEY = EY - OY,
    Dot = DSX*DEX + DSY*DEY,
    %% os dot oe = os*cos(angle)*oe
    Cos = Dot / math:sqrt((DSX*DSX + DSY*DSY) * (DEX*DEX + DEY*DEY)),
    if
        Cos >= 1.0 ->
            0;
        Cos =< -1.0 ->
            -math:pi();
        true ->
            Angle = math:acos(Cos),
            case DSX*DEY - DSY*DEX > 0 of
                true ->
                    %% 矢量os在矢量oe的顺时针方向
                    Angle;
                _ ->
                    -Angle
            end
    end.


%% @doc 计算DT点
%% @return Vertex|not_find
find_dt(Line, VertexList, EdgeList) ->
    AllVisiblePoint = search_all_visible_point4line(Line, VertexList, EdgeList),
    case length(AllVisiblePoint) > 0 of
        true ->
%%             no_find;
            find_dt1(Line, AllVisiblePoint, AllVisiblePoint, erlang:hd(AllVisiblePoint));
        _ ->
            no_find
    end.

find_dt1(_Line, _OrginVisiblePointList, [], P3) ->
    P3;
find_dt1(Line = #line2d{point_a = P1, point_b = P2}, OrginVisiblePointList, [TestP3|VisiblePointList], P3) ->
    %% Step1. 构造 Δp1p2p3 的外接圆 C（p1，p2，p3）及其网格包围盒 B（C（p1，p2，p3））
    Circle = circle:new(P1, P2, P3),
    Rectangle = rectangle:new(Circle#circle.center#vector2f.x - Circle#circle.r,
                              Circle#circle.center#vector2f.y - Circle#circle.r,
                              2*Circle#circle.r, 2*Circle#circle.r),
    %% Step2. 依次访问网格包围盒内的每个网格单元：
    %% 若某个网格单元中存在可见点 p, 并且 ∠p1pp2 > ∠p1p3p2，则令 p3=p，转Step1；否则，转Step3.
    Angle132 = erlang:abs(line_angle(P1, P3, P2)),
    case {vector2f:equal(P1, TestP3), vector2f:equal(P2, TestP3), vector2f:equal(P3, TestP3), rectangle:is_contain(Rectangle, TestP3)} of
        {false, false, false, true} ->
            %% TestP3不等于P1、P2、P3 并且在 Rectangle包围盒中
            TestAngle132 = erlang:abs(line_angle(P1, TestP3, P2)),
            case TestAngle132 > Angle132 of
                true ->

                    find_dt1(Line, OrginVisiblePointList, VisiblePointList, TestP3);
                _ ->
                    find_dt1(Line, OrginVisiblePointList, VisiblePointList, P3)
            end;
        _ ->
            find_dt1(Line, OrginVisiblePointList, VisiblePointList, P3)
    end.

%% @doc 搜索Line的所有可见点
search_all_visible_point4line(Line, VertexList, EdgeList) ->
    search_all_visible_point4line(Line, VertexList, EdgeList, []).

search_all_visible_point4line(_Line, [], _EdgeList, VisibleVertexList) ->
    lists:reverse(VisibleVertexList);
search_all_visible_point4line(Line, [Vertex|VertexList], EdgeList, VisibleVertexList) ->
    case is_visible_point4line(Vertex, Line, EdgeList) of
        true ->
            search_all_visible_point4line(Line, VertexList, EdgeList, [Vertex|VisibleVertexList]);
        _ ->
            search_all_visible_point4line(Line, VertexList, EdgeList, VisibleVertexList)
    end.


%% @doc 判断点是否为Line的可见点
%% @return true|false
is_visible_point4line(Point, Line, EdgeList) ->
    case {vector2f:equal(Point, Line#line2d.point_a),vector2f:equal(Point, Line#line2d.point_b)} of
        {false,false} ->
            is_visible_point4line1(Point, Line, EdgeList);
        _ ->
            false
    end.
is_visible_point4line1(Point, Line, EdgeList) ->
    case line2d:classify_point(Line, Point) of
        ?POINT_RIGHT_SIDE ->
            is_visible_point4line2(Point, Line, EdgeList);
        _ ->
            false
    end.
is_visible_point4line2(Point, Line, EdgeList) ->
    case is_visible_in2point(Point, Line#line2d.point_a, EdgeList) of
        true ->
            is_visible_point4line3(Point, Line, EdgeList);
        _ ->
            false
    end.
is_visible_point4line3(Point, Line, EdgeList) ->
    case is_visible_in2point(Point, Line#line2d.point_b, EdgeList) of
        true ->
            true;
        _ ->
            false
    end.


%% @doc 点A和点B是否可见
%% @return true|false
is_visible_in2point(PointA, PointB, EdgeList) ->
    Line = line2d:new(PointA, PointB),
    is_visible_in2point1(Line, EdgeList, true).

is_visible_in2point1(_Line, _EdgeList, false) ->
    false;
is_visible_in2point1(_Line, [], Flag) ->
    Flag;
is_visible_in2point1(Line, [Edge|EdgeList], Flag) ->
    case line2d:intersection(Line, Edge) of
        {?SEGMENTS_INTERSECT, IntersectPoint} ->
            %% 相交
            case {vector2f:equal(IntersectPoint, Line#line2d.point_a), vector2f:equal(IntersectPoint, Line#line2d.point_b)} of
                {false, false} ->
                    %% 交点不是测试边的端点
                    is_visible_in2point1(Line, EdgeList, false);
                _ ->
                    is_visible_in2point1(Line, EdgeList, Flag)
            end;
        _ ->
            is_visible_in2point1(Line, EdgeList, Flag)
    end.

























