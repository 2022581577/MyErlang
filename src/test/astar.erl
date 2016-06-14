%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 六月 2016 18:30
%%%-------------------------------------------------------------------
-module(astar).
-author("Administrator").

%% include

%% export
-export([]).
-compile(export_all).

%% record and define
%%-record(astar_node, {
%%    key         %% 主键{x,y}
%%    ,x
%%    ,y
%%    ,parent     %% 父节点的主键
%%    ,g          %% g值   当前格子到起点的移动耗费
%%    ,h          %% h值   当前格子到终点的移动耗费
%%    ,f          %% f值
%%    ,state      %% 状态 0表示在close列表，1表示在open列表
%%    ,layer      %% 层
%%}).

-define(COST_STRAIGHT, 10).         %% 垂直方向或水平方向移动的路径评分
-define(COST_DIAGONAL, 14).         %% 斜向移动的路径评分

%% A星寻路算法 节点
-record(astar_node, {
    key                         %% 没有实际意义，纯粹为了加快lists检索效率 y*width + x
    ,x                          %% 格子在X轴上的坐标,即第几列
    ,y                          %% 格子在Y轴上的坐标,即第几行
    ,g = 0                      %% 当前格子到起点的移动耗费
    ,h = 0                      %% 当前格子到终点的移动耗费，即曼哈顿距离，即|x1-x2|+|y1-y2|(忽略障碍物)
    ,f = 0                      %% f=g+h
    ,flag = 1                   %% 0表示不可行区域,1表示可行区域
    ,visit = 0                  %% 是否在关闭列表中,1表示在关闭列表中
%%     ,open_index = 0          %% 该节点在开启列表中索引位置
    ,parent = -1                %% 父格子，存储父格子的key
}).

-define(A_MAP_WIDTH,     20).
-define(A_MAP_HEIGHT, 20).

-define(PATH_DATA, [
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,
    1,1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,
    1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,
    1,1,1,1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,
    1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,1,1,1,1,
    1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
]).

%% ========================================================================
%% API functions
%% ========================================================================


%%=========================外部调用接口函数=====================================
%% @doc A星寻路
%% @return {ok,ResultList}|{false.Msg}
%% @X1、Y1 起点的坐标
%% @X2、Y2 终点的坐标
search_path(FromX, FromY, ToX, ToY, MapW, MapH, PathData) ->
    case get_grid(ToX, ToY, MapW, PathData) of
        #astar_node{flag = Flag} = EndNode when Flag > 0 ->
            case get_grid(FromX, FromY, MapW, PathData) of
                #astar_node{} = StartNode ->
                    search_path1(StartNode, EndNode, MapW, MapH, PathData);
                _ ->
                    {false, <<"start node not exist">>}
            end;
        #astar_node{} ->
            {false, <<"target unwalkable">>};
        _ ->
            {false, <<"target node not exist">>}
    end.

search_path1(StartNode, EndNode, MapW, MapH, PathData)->
    StartTime = erlang:timestamp(),
    %% StartNode加入OpenList
    OpenList = [StartNode],
    case search(OpenList, EndNode, MapW, MapH, PathData, 0) of
        {ok, ResultList} ->
            EndTime = erlang:timestamp(),
            Time    = timer:now_diff(EndTime, StartTime),
            io:format("time:~w~n",[Time]),
            {ok, ResultList};
        Error ->
            Error
    end.


search([],_EndNode,_MapW,_MapH,_PathData,Count) ->
    io:format("not find Count:~w~n", [Count]),
    {ok,[]};
search(OpenList, EndNode, MapW, MapH, PathData, Count) ->
    case get_open_node_by_min_f(OpenList) of
        {ok, []} ->
            {ok, []};
        {ok, HNode} ->
            #astar_node{x = EndX, y = EndY} = EndNode,
            #astar_node{key = HKey, x = HX, y = HY} = HNode,
            case HX =:= EndX andalso HY =:= EndY of
                true -> %% 已经找到目标点
                    io:format("success find Count:~w~n", [Count]),
                    ResultList = get_path([], HNode, PathData),
                    {ok,ResultList};
                _ ->    %% 未到目标点
                    %% 选择8个方向的可行区域
                    Directions = [
                        {HX - 1,    HY,         ?COST_STRAIGHT},    %% 左
                        {HX + 1,    HY,         ?COST_STRAIGHT},    %% 右
                        {HX,        HY - 1,     ?COST_STRAIGHT},    %% 上
                        {HX,        HY + 1,     ?COST_STRAIGHT},    %% 下
                        {HX - 1,    HY - 1,     ?COST_DIAGONAL},    %% 左上
                        {HX - 1,    HY + 1,     ?COST_DIAGONAL},    %% 左下
                        {HX + 1,    HY - 1,     ?COST_DIAGONAL},    %% 右上
                        {HX + 1,    HY + 1,     ?COST_DIAGONAL}     %% 右下
                    ],
                    {OpenList1, PathData1} =
                        check_dir_path(Directions, HNode, EndNode, MapW, MapH, OpenList, PathData),
                    %% 从open列表中删除当前节点 将其添加进closed列表
                    OpenList2 = delete_open_node_by_key(HKey, OpenList1),
                    PathData2 = array:set(HKey, HNode#astar_node{visit = 1}, PathData1),
                    search(OpenList2, EndNode, MapW, MapH, PathData2, Count + 1)
            end
    end.

check_dir_path([], _HNode, _EndNode, _MapW, _MapH, OpenList, PathData) ->
    {OpenList, PathData};
check_dir_path([{X, Y, Cost} | T], HNode, EndNode, MapW, MapH, OpenList, PathData) ->
    {OpenList1, PathData1} =
        check_path(X, Y, Cost, HNode, EndNode, MapW, MapH, OpenList, PathData),
    check_dir_path(T, HNode, EndNode, MapW, MapH, OpenList1, PathData1).


check_path(X, Y, Cost, ParentNode, EndNode, MapW, MapH, OpenList, PathData) ->
    case X < 0 orelse Y < 0 orelse X >= MapW orelse Y >= MapH of
        true ->
            {OpenList, PathData};
        _ ->
            %检查当前格子是否为可行区域
            case get_grid(X, Y, MapW, PathData) of
                #astar_node{flag = Flag} = CurNode when Flag =/= 0 ->   %% 可行
                    check_path1(Cost, ParentNode, CurNode, EndNode, OpenList, PathData);
                #astar_node{key = CurKey} = CurNode ->  %% 不可行 添加到关闭列表中
                    PathData1 = array:set(CurKey, CurNode#astar_node{visit = 1}, PathData),
                    {OpenList, PathData1};
                _ ->
                    {OpenList, PathData}
            end
    end.

%% @doc 检查节点是否在关闭列表中
%% @doc 如果在关闭列表中 忽略该节点
check_path1(Cost, ParentNode, CurNode, EndNode, OpenList, PathData)->
    case CurNode#astar_node.visit of
        1  ->
            {OpenList, PathData};
        _ ->
            check_path2(Cost, ParentNode, CurNode, EndNode, OpenList, PathData)
    end.

%% @doc 检查节点是否在开启列表中
%% @doc 如果在开启列表中 根据当前路径判断G值是否更小 如果是则更新 否则忽略
%% @doc 如果不在开启列表中 添加进开启列表
check_path2(Cost, ParentNode, CurNode, EndNode, OpenList, PathData) ->
    #astar_node{key = CurKey, x = CurX, y = CurY} = CurNode,
    #astar_node{x = EndX, y = EndY} = EndNode,
    H = abs(CurX - EndX) + abs(CurY - EndY),
    case get_open_node_by_key(CurKey, OpenList) of
        {ok, #astar_node{g = OldG}} ->
            #astar_node{key = ParentKey, g = ParentG} = ParentNode,
            %% 在开启列表中
            case ParentG + Cost < OldG of
                true ->
                    %% 如果node已经在open列表中：当我们使用当前生成的路径到达那里时，检查G值是否更小。
                    %% 如果是，更新它的G值和它的父节点
                    NewNode =
                        CurNode#astar_node{parent   = ParentKey
                                           ,g       = ParentG + Cost
                                           ,h       = H
                        },
                    OpenList1 = replace_open_node_by_key(NewNode, OpenList),
                    PathData1 = array:set(NewNode#astar_node.key, NewNode, PathData),
                    {OpenList1, PathData1};
                _ ->
                    {OpenList, PathData}
            end;
        _ ->
            %%不在开启列表中
            #astar_node{key = ParentKey, g = ParentG} = ParentNode,
            NewNode =
                CurNode#astar_node{parent   = ParentKey
                                   ,g       = ParentG + Cost
                                   ,h       = H
                                },
            OpenList1 = add_open_node(NewNode, OpenList),
            PathData1 = array:set(NewNode#astar_node.key, NewNode, PathData),
            {OpenList1, PathData1}
    end.


get_path(ResultList, #astar_node{parent = 1} = Node, _PathData) ->
    lists:reverse([Node | ResultList]);
get_path(ResultList, #astar_node{parent = ParentKey} = Node, PathData) ->
    ParentNode = array:get(ParentKey, PathData),
    get_path([Node | ResultList], ParentNode, PathData).

%% ========================================================================
%% Local functions
%% ========================================================================
%%根据格子的索引坐标找到格子
get_grid(X, Y, MapW, PathData) ->
    %?DEBUG("X:~w,Y:~w,Index:~w~n",[X,Y,(Y * MapW + X)]),
    Index = Y * MapW + X,
    Size  = array:size(PathData),
    case Index >= 0 andalso Index < Size of
        true ->
            case array:get(Index, PathData) of
                #astar_node{} = Node ->
                    Node;
                _ ->
                    error
            end;
        _ ->
            error
    end.


%% @doc 从开启列表获取最小f值的node
get_open_node_by_min_f([]) ->
    {ok, []};
get_open_node_by_min_f([HNode | T]) ->
    MinNode = get_open_node_by_min_f1(T, HNode),
    {ok, MinNode}.

get_open_node_by_min_f1([], MinNode) ->
    MinNode;
get_open_node_by_min_f1([H | T], MinNode) ->
    #astar_node{g = Hg, h = Hh} = H,
    #astar_node{g = Mg, h = Mh} = MinNode,
    case (Hg + Hh) < (Mg + Mh) of
        true ->
            get_open_node_by_min_f1(T, H);
        _ ->
            get_open_node_by_min_f1(T, MinNode)
    end.



%% @doc 将节点加入开启列表
add_open_node(Node,OpenNodeList) ->
    [Node | OpenNodeList].

%% @doc 将节点从开启列表移除
delete_open_node_by_key(Key,OpenNodeList) ->
    lists:keydelete(Key, #astar_node.key, OpenNodeList).

%% @doc 用新节点替换开启列表中的信息
replace_open_node_by_key(NewNode,OpenNodeList) ->
    lists:keyreplace(NewNode#astar_node.key, #astar_node.key, OpenNodeList, NewNode).

%% @doc 查询open_node
get_open_node_by_key(Key, OpenNodeList) ->
    case lists:keyfind(Key, #astar_node.key, OpenNodeList) of
        false -> false;
        Node  -> {ok,Node}
    end.


%% ========================================================================
%% Test functions
%% ========================================================================
test_start(Max) ->
    PathData0 = array:new([{size, (?A_MAP_WIDTH * ?A_MAP_HEIGHT)}, {default,0}, {fixed, true}]),
    PathData1 = init_path_data(?PATH_DATA, 0, {?A_MAP_WIDTH, ?A_MAP_HEIGHT}, PathData0),
    StratTime = erlang:timestamp(),
    test(Max,PathData1),
    EndTime = erlang:timestamp(),
    Time = timer:now_diff(EndTime, StratTime),
    io:format("use time:~w~n",[Time]).

test(0, _) -> ok;
test(Max, PathData) ->
%%    test(5,0,10,9,PathData),
    test(0, 0, 19, 19, PathData),
    test(Max - 1, PathData).

test(X1, Y1, X2, Y2, PathData) ->
    case search_path(X1, Y1, X2, Y2, ?A_MAP_WIDTH, ?A_MAP_HEIGHT, PathData) of
        {ok, ResultList} ->
%%            show_result(0,ResultList,PathData),
%%            io:format("result list:~p~n",[ResultList]),
            ResultList;
        {false, Msg} ->
            io:format("error:~p!",[Msg])
    end.

init_path_data([], _, _, Arr) -> Arr;
init_path_data([H|T], Index, {MapW,MapH}, Arr) ->
    X = Index rem MapW,
    Y = Index div MapW,
    NewArr = array:set(Index, #astar_node{key = Index, x = X, y = Y, flag = H}, Arr),
    init_path_data(T, Index + 1, {MapW,MapH}, NewArr).

show_result(Index, ResultList, PathData) ->
    if
        Index >= ?A_MAP_WIDTH * ?A_MAP_HEIGHT ->
            ok;
        true ->
            case array:get(Index, PathData) of
                Node when is_record(Node,astar_node) andalso Node#astar_node.flag =:= 0 ->
                    io:format("0");
                _ ->
                    case lists:keyfind(Index,#astar_node.key,ResultList) of
                        false -> io:format("1");
                        _     -> io:format("*")
                    end
            end,
            if
                (Index + 1) rem ?A_MAP_WIDTH =:= 0 ->
                    io:format("~n");
                true ->
                    ok
            end,
            show_result(Index+1,ResultList,PathData)
    end.