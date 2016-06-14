%%-----------------------------------------------------
%% @Module:game_geom_bstar 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-6-10
%% @Desc:
%%-----------------------------------------------------

-module(game_geom_bstar).
-compile(export_all).


-define(COST_STRAIGHT,10).         %% 垂直方向或水平方向移动的路径评分
-define(COST_DIAGONAL,14).         %% 斜向移动的路径评分

%% 节点类型
-define(NODE_TYPE_FREE,     0).        %% 自由节点
-define(NODE_TYPE_LEFT,     1).        %% 探索节点(左)
-define(NODE_TYPE_RIGHT,     2).        %% 探索节点(右)

%% 节点状态
-define(NODE_S_NONE,        0).        %% 空节点
-define(NODE_S_OPEN,        1).        %% 开启节点
-define(NODE_S_CLOSED,        2).        %% 关闭节点

-define(MAX_DIRECTION,        4).

%% 方向
-define(DIRECTION_DOWN,        0).
-define(DIRECTION_LEFT,        1).
-define(DIRECTION_UP,        2).
-define(DIRECTION_RIGHT,    3).


%% A星寻路算法 节点
-record(astar_node, {
    key                         %%     没有实际意义，纯粹为了加快lists检索效率 y*width + x
    ,x                               %%     格子在X轴上的坐标,即第几列
    ,y                               %%     格子在Y轴上的坐标,即第几行
    ,g = 0                         %%    当前格子到起点的移动耗费
%%     ,h = 0                         %%    当前格子到终点的移动耗费，即曼哈顿距离，即|x1-x2|+|y1-y2|(忽略障碍物)
%%     ,f = 0                         %%    f=g+h
    ,flag = 1                   %%    0表示不可行区域,1表示可行区域
    ,type = 0                    %%  0-free 1-left 2-right
    ,state = 0                     %%    0-none 1-open 2-closed
    ,direction = -1                %%  移动方向
    ,reel = 0
    ,angle = 0
%%     ,open_index = 0             %%    该节点在开启列表中索引位置
    ,parent = -1                 %%    父格子，存储父格子的key
    ,is_start = 0                %%    1-start_node
}).
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).

-define(MAP_WIDTH,     20).
-define(MAP_HEIGHT, 20).

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



%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------
test_start(Max) ->
    PathData0 = array:new( [{size,(?MAP_WIDTH * ?MAP_HEIGHT)},{default,0},{fixed,true}] ),
    PathData1 = init_path_data(?PATH_DATA, 0, {?MAP_WIDTH,?MAP_HEIGHT}, PathData0),
    Time = test(Max,PathData1,0),
    io:format("use time:~w~n",[Time]).

test(0,_,TotalTime) -> TotalTime;
test(Max,PathData,TotalTime) ->
%%     test(5,0,10,9,PathData),
%%     test(5,0,13,11,PathData),
    {Time, _} = test(0,0,19,19,PathData),
    test(Max - 1,PathData,TotalTime+Time).

test(X1,Y1,X2,Y2,PathData) ->
    StratTime = erlang:timestamp(),
    case search_path(X1,Y1,X2,Y2,?MAP_WIDTH,?MAP_HEIGHT,PathData) of
        {ok,ResultList} ->
            EndTime = erlang:timestamp(),
            Time = timer:now_diff(EndTime, StratTime),
%%             io:format("X1:~p,Y1:~p,X2:~p,Y2:~p per use time:~w~n",[X1,Y1,X2,Y2,Time]),
%%             show_result(0,ResultList,PathData),
%%             io:format("result list:~p~n",[ResultList]),
            {Time, ResultList};
        {false,Msg} ->
            io:format("error:~p!",[Msg])
    end.

init_path_data([], _, _, Arr) -> Arr;
init_path_data([H|T], Index, {MapW,MapH}, Arr) ->
    X = Index rem MapW,
    Y = Index div MapH,
    NewArr = array:set(Index, #astar_node{key = Index, x = X,y = Y,flag = H}, Arr),
    init_path_data(T, Index + 1, {MapW,MapH}, NewArr).

show_result(Index, ResultList, PathData) ->
    if 
        Index >= ?MAP_WIDTH * ?MAP_HEIGHT ->
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
                   (Index + 1) rem ?MAP_WIDTH =:= 0 ->
                       io:format("~n");
                   true ->
                       ok
               end,
            show_result(Index+1,ResultList,PathData)
    end.

%%=========================外部调用接口函数=====================================
%% @doc A星寻路
%% @return {ok,ResultList}|{false.Msg}
%% @X1、Y1 起点的坐标
%% @X2、Y2 终点的坐标
search_path(FromX,FromY,ToX,ToY,MapW,MapH,PathData) ->
    case get_node(ToX,ToY,MapW,PathData) of
          EndNode when is_record(EndNode,astar_node) ->
               if
                EndNode#astar_node.flag > 0 ->
                       case get_node(FromX,FromY,MapW,PathData) of
                           StartNode when is_record(StartNode,astar_node) ->
                            NewStartNode = StartNode#astar_node{is_start = 1},
                            search_path2(FromX,FromY,ToX,ToY,StartNode,EndNode,MapW,MapH,save_node(PathData, NewStartNode));
                           _ ->
                            {false, <<"start node not exist">>}
                       end;
                   true ->
                       {false, <<"target unwalkable">>}
               end;
           _ ->
            {false, <<"target node not exist">>}
   end.
   
search_path2(_FromX,_FromY,_ToX,_ToY,StartNode,EndNode,MapW,MapH,PathData)->
    %% StartNode加入OpenList
    OpenList = [StartNode],
      case search(OpenList,StartNode,EndNode,MapW,MapH,PathData) of
           {ok,ResultList} ->
            {ok,ResultList};
           Error ->
             Error
      end.

search(OpenList,StartNode,EndNode,MapW,MapH,PathData) ->
    search(OpenList,StartNode,EndNode,MapW,MapH,PathData,[],0).

search([], _StartNode, _EndNode,_MapW,_MapH,_PathData,[],_Count) ->
    {ok,[]};
search([], _StartNode,_EndNode,_MapW,_MapH,_PathData,BackupList,Count) ->
    search(BackupList,_StartNode, _EndNode,_MapW,_MapH,_PathData,[],Count);
search([CurrentNode|OpenList],StartNode,EndNode,MapW,MapH,PathData,BackupList,Count) ->
    Result =
        case CurrentNode#astar_node.type of
            ?NODE_TYPE_FREE ->
                search_free(CurrentNode, StartNode, EndNode, MapW, MapH, PathData, BackupList);
            _ ->
                search_explore(CurrentNode, StartNode, EndNode, MapW, MapH, PathData, BackupList)
        end,
    case Result of
        {true, FinalEndNode, NewPathData} ->
%%             io:format("success find Count:~w~n", [Count]),
            _S = get_node(5,0,MapW,PathData),
%%             io:format("FinalEndNode:~w StartNode:~w~n", [FinalEndNode,S]),
            ResultList = get_path([],FinalEndNode,NewPathData),
            {ok,ResultList};
        {false, NewPathData, NewBackupList} ->
            search(OpenList,StartNode,EndNode,MapW,MapH,NewPathData,NewBackupList,Count+1)
    end.

%% @doc 自由节点探索
%% @return {true, FinalEndNode, NewPathData}|{false, NewPathData, NewBackupList}
search_free(CurrentNode, StartNode, EndNode, MapW, MapH, PathData, BackupList) ->
    case get_next_pos_by_search_free(CurrentNode, EndNode, MapW, MapH) of
        {-1,_,_} ->
            {false, PathData, BackupList};
        {Direction,NextX, NextY} ->
            NextNode0 = get_node(NextX,NextY,MapW,PathData),
            NextNode = NextNode0#astar_node{direction = Direction},
            if
                NextNode#astar_node.x =:= EndNode#astar_node.x andalso NextNode#astar_node.y =:= EndNode#astar_node.y ->
                    %% 找到目标
                    NewEndNode = NextNode#astar_node{
                        parent = CurrentNode#astar_node.key
                        ,g = CurrentNode#astar_node.g + 1
                    },
                    {true, NewEndNode, save_node(PathData, NewEndNode)};
                NextNode#astar_node.state =:= ?NODE_S_OPEN ->
                    NewNextNode = NextNode#astar_node{
                        state = ?NODE_S_CLOSED
                    },
                    {false, save_node(PathData, NewNextNode), BackupList};
                NextNode#astar_node.state =:= ?NODE_S_CLOSED ->
                    {false, PathData, BackupList};
                true ->
                    %% 空闲节点
                    case NextNode#astar_node.flag > 0 of
                        true ->
                            %% 可前进
                            NewNextNode = NextNode#astar_node{
                                parent = CurrentNode#astar_node.key
                                ,g = CurrentNode#astar_node.g + 1
                                ,state = ?NODE_S_OPEN
                            },
%%                             io:format("FreeNodeX:~w FreeNodeY:~w Parent:~w Type:~w State:~w~n",
%%                                       [
%%                                        NewNextNode#astar_node.x,
%%                                        NewNextNode#astar_node.y,
%%                                        NewNextNode#astar_node.parent,
%%                                        NewNextNode#astar_node.type,
%%                                        NewNextNode#astar_node.state
%%                                       ]),
                            {false, save_node(PathData, NewNextNode), [NewNextNode|BackupList]};
                        _ ->
                            %% 阻挡
                            search_free_block(StartNode, CurrentNode, NextNode, MapW, MapH, PathData, BackupList)
                    end
             end
    end.


%% @doc 获得自由节点的下一个节点
%% @return {Direction,NextX,NextY}
get_next_pos_by_search_free(CurrentNode, EndNode, MapW, MapH) ->
    get_next_pos_by_search_free(CurrentNode, EndNode, MapW, MapH, ?DIRECTION_DOWN).
get_next_pos_by_search_free(_CurrentNode, _EndNode, _MapW, _MapH, ?MAX_DIRECTION) ->
    {-1,-1,-1};
get_next_pos_by_search_free(CurrentNode, EndNode, MapW, MapH, Direction) ->
    {DeltaX, DeltaY} = direction_delta(Direction),
    NextX = CurrentNode#astar_node.x + DeltaX,
    NextY = CurrentNode#astar_node.y + DeltaY,
    case is_valid(NextX, NextY, MapW, MapH) of
        true ->
            DirDiff = math_util:get_dir_diff(CurrentNode#astar_node.x, CurrentNode#astar_node.y,
                                             EndNode#astar_node.x, EndNode#astar_node.y,
                                             NextX, NextY),
            case DirDiff =< 8 of
                true ->
                    {Direction,NextX, NextY};
                _ ->
                    get_next_pos_by_search_free(CurrentNode, EndNode, MapW, MapH, Direction+1)
            end;
        _ ->
            get_next_pos_by_search_free(CurrentNode, EndNode, MapW, MapH, Direction+1)
    end.


%% @doc 自由探索 遇到阻挡 分出两个分支进行处理
search_free_block(StartNode, CurrentNode, BlockNode, MapW, MapH, PathData, BackupList) ->
    F = fun(NodeType,{PathDataAcc, BackupListAcc}) ->
            case search_free_explore_node(CurrentNode,BlockNode#astar_node.direction, NodeType, MapW, MapH, PathData) of
                {AddReel, ExploreNode} when is_record(ExploreNode, astar_node) ->
                    ExploreNode1 = ExploreNode#astar_node{
                        type = NodeType
                    },
                    Result =
                        case ExploreNode1#astar_node.state of
                            ?NODE_S_NONE ->
                                ExploreNode2 = ExploreNode1#astar_node{
                                    parent = CurrentNode#astar_node.key
                                    ,g = CurrentNode#astar_node.g + 1
                                },
                                {true, ExploreNode2};
                            ?NODE_S_OPEN ->
                                case ExploreNode1#astar_node.g > CurrentNode#astar_node.g + 1 of
                                    true ->
                                        ExploreNode2 = ExploreNode1#astar_node{
                                            parent = CurrentNode#astar_node.key
                                            ,g = CurrentNode#astar_node.g + 1
                                        },
                                        {true, ExploreNode2};
                                    _ ->
                                        {true, ExploreNode1}
                                end;
                            ?NODE_S_CLOSED ->
                                if
                                    ExploreNode1#astar_node.type =:= ((NodeType + 1) rem 2) andalso
                                    ExploreNode1#astar_node.parent =:= CurrentNode#astar_node.key ->
                                        false;
                                    ExploreNode1#astar_node.g > CurrentNode#astar_node.g + 1 ->
                                        ExploreNode2 = ExploreNode1#astar_node{
                                            parent = CurrentNode#astar_node.key
                                            ,g = CurrentNode#astar_node.g + 1
                                        },
                                        {true, ExploreNode2};
                                    true ->
                                        {true, ExploreNode1}
                                end
                        end,
                    case Result of
                        {true,NewExploreNode} ->
%%                             io:format("1.... NextExploreX:~w NextExploreY:~w Parent:~w Type:~w State:~w~n",
%%                                       [
%%                                        NewExploreNode#astar_node.x,
%%                                        NewExploreNode#astar_node.y,
%%                                        NewExploreNode#astar_node.parent,
%%                                        NewExploreNode#astar_node.type,
%%                                        NewExploreNode#astar_node.state
%%                                       ]),
                            search_free_block_1(StartNode, CurrentNode, BlockNode, NewExploreNode, AddReel, PathDataAcc, BackupListAcc);
                        _ ->
                            {PathDataAcc, BackupListAcc}
                    end;
                _ ->
                    {PathDataAcc, BackupListAcc}
            end
    end,
    {NewPathData, NewBackupList} = lists:foldl(F, {PathData, BackupList}, [?NODE_TYPE_LEFT, ?NODE_TYPE_RIGHT]),
    {false, NewPathData, NewBackupList}.

search_free_block_1(StartNode, _CurrentNode, BlockNode, ExploreNode, AddReel, PathData, BackupList) ->
    Angle = math_util:get_dir_angle(StartNode#astar_node.x, StartNode#astar_node.y,
                                    ExploreNode#astar_node.x, ExploreNode#astar_node.y,
                                    BlockNode#astar_node.x, BlockNode#astar_node.y),
    NewAngle =
        case Angle > 32 of
            true ->
                64 - Angle;
            _ ->
                -Angle
        end,
    ExploreNode1 = ExploreNode#astar_node{
        reel = AddReel + 1
        ,angle = NewAngle
        ,state = ?NODE_S_OPEN
    },
    {save_node(PathData, ExploreNode1), [ExploreNode1|BackupList]}.


%% @doc 自由节点找探索节点的方向及坐标
search_free_explore_node(FreeNode,BlockDirection,NodeType,MapW, MapH, PathData) ->
    search_free_explore_node_1(branch_start_test_direction(NodeType, BlockDirection), FreeNode, NodeType, MapW, MapH, PathData).

search_free_explore_node_1([], _FreeNode, _NodeType, _MapW, _MapH, _PathData) ->
    false;
search_free_explore_node_1([{Direction,Reel}|List], FreeNode, NodeType, MapW, MapH, PathData) ->
    {DeltaX, DeltaY} = direction_delta(Direction),
    NextX = FreeNode#astar_node.x + DeltaX,
    NextY = FreeNode#astar_node.y + DeltaY,
    NextNode = get_node(NextX,NextY,MapW,PathData),
    IsValid = is_valid(NextX, NextY, MapW, MapH),
    if
        IsValid andalso NextNode#astar_node.flag > 0 ->
            {Reel, NextNode#astar_node{direction = Direction}};
        true ->
            search_free_explore_node_1(List, FreeNode, NodeType, MapW, MapH, PathData)
    end.






%% @doc 探索攀爬节点
%% @return {true, FinalEndNode, NewPathData}|{false, NewPathData, NewBackupList}
search_explore(CurrentNode, _StartNode, EndNode, MapW, MapH, PathData, BackupList) ->
    case search_explore_next_node(CurrentNode, MapW, MapH, PathData) of
        {AddReel, NextDirection, NextExploreNode} ->
            if
                NextExploreNode#astar_node.x =:= EndNode#astar_node.x andalso
                NextExploreNode#astar_node.y =:= EndNode#astar_node.y ->
                    %% 找到目标
                    ExploreNode1 = NextExploreNode#astar_node{
                        parent = CurrentNode#astar_node.key
                        ,g = CurrentNode#astar_node.g + 1
                    },
                    {true, ExploreNode1, save_node(PathData, ExploreNode1)};
                true ->
                    search_explore_1(CurrentNode, NextExploreNode, AddReel, NextDirection, PathData, BackupList)
            end;
        _ ->
            {false, PathData, BackupList}
    end.

search_explore_1(CurrentNode, NextExploreNode, AddReel, NextDirection, PathData, BackupList) ->
%%     io:format("CurrentX:~w CurrentY:~w Parent:~w Type:~w State:~w~n",
%%               [
%%                CurrentNode#astar_node.x,
%%                CurrentNode#astar_node.y,
%%                CurrentNode#astar_node.parent,
%%                CurrentNode#astar_node.type,
%%                CurrentNode#astar_node.state
%%               ]),
%%     io:format("NextExploreX:~w NextExploreY:~w Parent:~w Type:~w State:~w~n",
%%               [
%%                NextExploreNode#astar_node.x,
%%                NextExploreNode#astar_node.y,
%%                NextExploreNode#astar_node.parent,
%%                NextExploreNode#astar_node.type,
%%                NextExploreNode#astar_node.state
%%               ]),
    Result =
        case NextExploreNode#astar_node.state of
            ?NODE_S_NONE ->
                ExploreNode1 = NextExploreNode#astar_node{
                    parent = CurrentNode#astar_node.key
                    ,g = CurrentNode#astar_node.g + 1
                },
                {true, ExploreNode1};
            ?NODE_S_OPEN ->
                if
                    NextExploreNode#astar_node.type =:= CurrentNode#astar_node.type andalso
                    NextExploreNode#astar_node.direction =:= NextDirection ->
                        false;
                       CurrentNode#astar_node.parent =:= NextExploreNode#astar_node.key ->
                        %% 当前节点的父亲是下一探索节点
                        false;
                    true ->
%%                         io:format("2....CurrentNode:~w NextExploreNode:~w~n", [CurrentNode,NextExploreNode]),
                        ExploreNode1 = NextExploreNode#astar_node{
                            parent = CurrentNode#astar_node.key
                            ,g = CurrentNode#astar_node.g + 1
                        },
                        {true, ExploreNode1}
                end;
            ?NODE_S_CLOSED ->
                if
                    NextExploreNode#astar_node.type =:= ((CurrentNode#astar_node.type + 1) rem 2) andalso
                    CurrentNode#astar_node.parent =:= NextExploreNode#astar_node.key andalso
                    NextExploreNode#astar_node.direction =/= NextDirection ->
                        false;
                    NextExploreNode#astar_node.type =:= CurrentNode#astar_node.type andalso
                    NextExploreNode#astar_node.direction =:= NextDirection ->
                        false;
                    NextExploreNode#astar_node.type =:= ?NODE_TYPE_FREE andalso
                    NextExploreNode#astar_node.g > CurrentNode#astar_node.g ->
                        false;
                    NextExploreNode#astar_node.g > CurrentNode#astar_node.g + 1 ->
                        io:format("3....CurrentNode:~w NextExploreNode:~w~n", [CurrentNode,NextExploreNode]),
                        ExploreNode1 = NextExploreNode#astar_node{
                            parent = CurrentNode#astar_node.key
                            ,g = CurrentNode#astar_node.g + 1
                        },
                        {true, ExploreNode1};
                    true ->
                        false
                end
        end,
    case Result of
        {true, NextExploreNode1} ->
%%             io:format("NewNextExploreX:~w NewNextExploreY:~w Parent:~w Type:~w State:~w~n",
%%                       [
%%                        NextExploreNode1#astar_node.x,
%%                        NextExploreNode1#astar_node.y,
%%                        NextExploreNode1#astar_node.parent,
%%                        NextExploreNode1#astar_node.type,
%%                        NextExploreNode1#astar_node.state
%%                       ]),
            search_explore_2(CurrentNode, NextExploreNode1, AddReel, NextDirection, PathData, BackupList);
        _ ->
            {false, PathData, BackupList}
    end.

search_explore_2(CurrentNode, NextExploreNode, AddReel, NextDirection, PathData, BackupList) ->
    Angle = math_util:get_dir_angle(CurrentNode#astar_node.x,
                                    CurrentNode#astar_node.y,
                                    NextExploreNode#astar_node.x,
                                    NextExploreNode#astar_node.y,
                                    CurrentNode#astar_node.x,
                                    CurrentNode#astar_node.y),
    AddAngle =
        case Angle > 32 of
            true ->
                64 - Angle;
            _ ->
                -Angle
        end,
    NewAngle = NextExploreNode#astar_node.angle + AddAngle,
    NewReel = erlang:max(0, NextExploreNode#astar_node.reel + AddReel),
    {NewAngle1, NewReel1} =
        if
            NewAngle >= 64 ->
                {NewAngle-64, NewReel-4};
            true ->
                {NewAngle, NewReel}
        end,
    NextExploreNode1 =
        case NewReel1 > 0 of
            true ->
                NextExploreNode#astar_node{
                    reel = NewReel1
                    ,state = ?NODE_S_OPEN
                    ,angle = NewAngle1
                    ,type = CurrentNode#astar_node.type
                    ,direction = NextDirection
                };
            _ ->
                NextExploreNode#astar_node{
                    reel = 0
                    ,state = ?NODE_S_OPEN
                    ,angle = 0
                    ,type = ?NODE_TYPE_FREE
                    ,direction = -1
                }
        end,
    {false, save_node(PathData, NextExploreNode1), [NextExploreNode1|BackupList]}.

%% @doc 获得攀爬节点的下一个节点
%% @return {AddReel, NextExploreNode}
%% @doc 自由节点找探索节点的方向及坐标
search_explore_next_node(ExploreNode, MapW, MapH, PathData) ->
    search_free_explore_node_1(branch_start_test_direction_explore(ExploreNode#astar_node.type, ExploreNode#astar_node.direction),
                               ExploreNode, MapW, MapH, PathData).

search_free_explore_node_1([], _ExploreNode, _MapW, _MapH, _PathData) ->
    false;
search_free_explore_node_1([{Direction,Reel}|List], ExploreNode, MapW, MapH, PathData) ->
    {DeltaX, DeltaY} = direction_delta(Direction),
    NextX = ExploreNode#astar_node.x + DeltaX,
    NextY = ExploreNode#astar_node.y + DeltaY,
    NextNode = get_node(NextX,NextY,MapW,PathData),
    IsValid = is_valid(NextX, NextY, MapW, MapH),
    if
        IsValid andalso NextNode#astar_node.flag > 0 ->
            {Reel, Direction, NextNode};
        true ->
            search_free_explore_node_1(List, ExploreNode, MapW, MapH, PathData)
    end.
 
%% @doc 根据节点的索引坐标找到节点
get_node(X,Y,MapW,PathData) ->
    Index = Y * MapW + X,
    Size  = array:size(PathData),
    if Index < 0 orelse Index >= Size -> error;
       true ->
           case array:get(Index, PathData) of
              Node when is_record(Node,astar_node) -> Node;
              _ -> error
           end
    end.

%% @doc 保存节点
save_node(PathData,Node) ->
    array:set(Node#astar_node.key, Node, PathData).
 
%% @doc 根据方向得到位移
direction_delta(?DIRECTION_DOWN) ->
    {0, 1};
direction_delta(?DIRECTION_LEFT) ->
    {-1, 0};
direction_delta(?DIRECTION_UP) ->
    {0, -1};
direction_delta(?DIRECTION_RIGHT) ->
    {1, 0}.

%% @doc 格子是否处于合法区域
is_valid(X, Y, MapW, MapH) ->
    X >= 0 andalso X < MapW andalso Y >= 0 andalso Y < MapH.


branch_direction(?NODE_TYPE_LEFT) ->
    [0,3,2,1];
branch_direction(?NODE_TYPE_RIGHT) ->
    [0,1,2,3].


branch_direction(NodeType, Index) ->
    lists:nth(Index+1, branch_direction(NodeType)).


%% @doc 根据探索节点类型/自由节点遇到阻挡的方向 获得探索节点的尝试方向
%% @doc 尝试方向无效 index+1 取新方向继续尝试
%% 左 逆时针
%% 右 顺时针
%% @return {Direction, AddReel}
branch_start_test_direction(?NODE_TYPE_LEFT, ?DIRECTION_DOWN) ->
    [{?DIRECTION_RIGHT, 0}, {?DIRECTION_UP, 1}, {?DIRECTION_LEFT, 2}];
branch_start_test_direction(?NODE_TYPE_LEFT, ?DIRECTION_LEFT) ->
    [{?DIRECTION_DOWN, 0}, {?DIRECTION_RIGHT, 1}, {?DIRECTION_UP, 2}];
branch_start_test_direction(?NODE_TYPE_LEFT, ?DIRECTION_UP) ->
    [{?DIRECTION_LEFT, 0}, {?DIRECTION_DOWN, 1}, {?DIRECTION_RIGHT, 2}];
branch_start_test_direction(?NODE_TYPE_LEFT, ?DIRECTION_RIGHT) ->
    [{?DIRECTION_UP, 0}, {?DIRECTION_LEFT, 1}, {?DIRECTION_DOWN, 2}];
branch_start_test_direction(?NODE_TYPE_RIGHT, ?DIRECTION_DOWN) ->
    [{?DIRECTION_LEFT, 0},{?DIRECTION_UP, 1},{?DIRECTION_RIGHT, 2}];
branch_start_test_direction(?NODE_TYPE_RIGHT, ?DIRECTION_LEFT) ->
    [{?DIRECTION_UP, 0}, {?DIRECTION_RIGHT, {?DIRECTION_DOWN, 2}}];
branch_start_test_direction(?NODE_TYPE_RIGHT, ?DIRECTION_UP) ->
    [{?DIRECTION_RIGHT, 0}, {?DIRECTION_DOWN, 1}, {?DIRECTION_LEFT, 2}];
branch_start_test_direction(?NODE_TYPE_RIGHT, ?DIRECTION_RIGHT) ->
    [{?DIRECTION_DOWN, 0}, {?DIRECTION_LEFT, 1}, {?DIRECTION_UP, 2}].


branch_start_test_direction_explore(?NODE_TYPE_LEFT, ?DIRECTION_DOWN) ->
    [{?DIRECTION_LEFT, -1}, {?DIRECTION_DOWN, 0}, {?DIRECTION_RIGHT, 1}, {?DIRECTION_UP, 2}];
branch_start_test_direction_explore(?NODE_TYPE_LEFT, ?DIRECTION_LEFT) ->
    [{?DIRECTION_UP, -1}, {?DIRECTION_LEFT, 0}, {?DIRECTION_DOWN, 1}, {?DIRECTION_UP, 2}];
branch_start_test_direction_explore(?NODE_TYPE_LEFT, ?DIRECTION_UP) ->
    [{?DIRECTION_RIGHT, -1}, {?DIRECTION_UP, 0}, {?DIRECTION_LEFT, 1}, {?DIRECTION_DOWN, 2}];
branch_start_test_direction_explore(?NODE_TYPE_LEFT, ?DIRECTION_RIGHT) ->
    [{?DIRECTION_DOWN, -1}, {?DIRECTION_RIGHT, 0}, {?DIRECTION_UP, 1}, {?DIRECTION_LEFT, 2}];

branch_start_test_direction_explore(?NODE_TYPE_RIGHT, ?DIRECTION_DOWN) ->
    [{?DIRECTION_RIGHT, -1}, {?DIRECTION_DOWN, 0}, {?DIRECTION_LEFT, 1}, {?DIRECTION_UP, 2}];
branch_start_test_direction_explore(?NODE_TYPE_RIGHT, ?DIRECTION_LEFT) ->
    [{?DIRECTION_DOWN, -1}, {?DIRECTION_LEFT, 0}, {?DIRECTION_UP, 1}, {?DIRECTION_RIGHT, 2}];

branch_start_test_direction_explore(?NODE_TYPE_RIGHT, ?DIRECTION_UP) ->
    [{?DIRECTION_RIGHT, 0}, {?DIRECTION_DOWN, 1}, {?DIRECTION_LEFT, 2}];
branch_start_test_direction_explore(?NODE_TYPE_RIGHT, ?DIRECTION_RIGHT) ->
    [{?DIRECTION_DOWN, 0}, {?DIRECTION_LEFT, 1}, {?DIRECTION_UP, 2}].

%% %% @doc 根据探索节点类型和当前尝试方向获取下一个尝试方向
%% %% 左 减1尝试
%% %% 右 加1尝试
%% branch_next_test_direction(?NODE_TYPE_LEFT, CurrentTestDirection) ->
%%     Next = CurrentTestDirection - 1,
%%     if
%%         Next < 0 ->
%%             Next + 4;
%%         true ->
%%             Next
%%     end;
%% branch_next_test_direction(?NODE_TYPE_RIGHT, CurrentTestDirection) ->
%%     Next = CurrentTestDirection + 1,
%%     if
%%         Next > 4 ->
%%             Next - 4;
%%         true ->
%%             Next
%%     end.
  
get_path(ResultList,Node,_PathData) when Node#astar_node.is_start =:= 1 ->
    [Node|ResultList];
get_path(ResultList,Node,PathData) ->
    Parent = array:get(Node#astar_node.parent, PathData),
%%     io:format("Parent:~w~n",[Parent]),
    get_path([Node|ResultList], Parent, PathData).

