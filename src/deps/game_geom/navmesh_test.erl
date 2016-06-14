%%-----------------------------------------------------
%% @Module:navmesh_test 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-5
%% @Desc:
%%-----------------------------------------------------

-module(navmesh_test).

-compile(export_all).

-include("game_geom.hrl").
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).


%% {0,0},{950,0},{950,520},{0,520}
%% 
%% {66.4,60.7},{295.8,89.4},{421.6,189.7},{109.9,266.4}
test() ->
    OutPolygon = #polygon{
        vertex_num = 4
        ,vertexs = [vector2f:new(0, 0), vector2f:new(950, 0), vector2f:new(950, 520), vector2f:new(0, 520)]
    },
%%     Polygon = #polygon{
%%         vertex_num = 4
%%         ,vertexs = [vector2f:new(269.6, 166.7), vector2f:new(464.4, 204.4), vector2f:new(532.8, 323.9), vector2f:new(283.6, 302.8)]
%%     },
    Polygon1 = #polygon{
        vertex_num = 3
        ,vertexs = [
                    vector2f:new(288.1, 44.7)
                       ,vector2f:new(582.6, 51.0)
                       ,vector2f:new(398.0, 100.9)
                   ]
    },
    Polygon2 = #polygon{
        vertex_num = 3
        ,vertexs = [
                    vector2f:new(612.6, 77.9)
                       ,vector2f:new(760.2, 88.2)
                       ,vector2f:new(719.3, 161.6)
                   ]
    },
    Polygon3 = #polygon{
        vertex_num = 4
        ,vertexs = [
                    vector2f:new(479.1, 106.7)
                       ,vector2f:new(675.2, 220.4)
                       ,vector2f:new(724.4, 401.2)
                       ,vector2f:new(569.8, 372.4)
                       ,vector2f:new(512.3, 257.4)
                   ]
    },
    Polygon4 = #polygon{
        vertex_num = 4
        ,vertexs = [
                    vector2f:new(461.9, 413.3)
                       ,vector2f:new(695.0, 457.4)
                       ,vector2f:new(608.2, 473.4)
                    ,vector2f:new(102.8, 447.2)
                   ]
    },
    Polygon5 = #polygon{
        vertex_num = 5
        ,vertexs = [
                    vector2f:new(405.0, 212.1)
                       ,vector2f:new(420.3, 310.5)
                       ,vector2f:new(241.5, 411.4)
                    ,vector2f:new(180.8, 339.2)
                       ,vector2f:new(268.9, 273.4)
                   ]
    },
    Polygon6 = #polygon{
        vertex_num = 5
        ,vertexs = [
                    vector2f:new(135.4, 104.1)
                       ,vector2f:new(329.0, 122.7)
                       ,vector2f:new(224.9, 180.1)
                    ,vector2f:new(180.1, 222.3)
                       ,vector2f:new(120.1, 171.8)
                   ]
    },
    Polygon7 = #polygon{
        vertex_num = 3
        ,vertexs = [
                    vector2f:new(75.4, 138.0)
                       ,vector2f:new(111.2, 375.6)
                       ,vector2f:new(56.2, 412.5)
                   ]
    },
    path_cell:create_cells([OutPolygon, Polygon1, Polygon2, Polygon3, Polygon4, Polygon5, Polygon6, Polygon7]).

test1(Max) ->
    CellArray = test(),
    StratTime = erlang:timestamp(),
    lists:foreach(fun(_) -> navmesh:find_path(CellArray, vector2f:new(0, 0), vector2f:new(950, 520)) end, lists:seq(0, Max)),
    EndTime = erlang:timestamp(),
    Time = timer:now_diff(EndTime, StratTime),
    io:format("use time:~w~n",[Time]),

%%     R = navmesh:find_path(CellArray, vector2f:new(0, 0), vector2f:new(930, 500)), ?DEBUG("Path:~w",[R]),
    ok.

test2() ->
    OpenList = binary_heap:new(fun(X1,X2) -> X1#path_cell.f < X2#path_cell.f end),
    A1 = binary_heap:put(OpenList, #path_cell{index = 1}),
    {true, _Result, _NewA1} = binary_heap:pop(A1),
    ok.

%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------


