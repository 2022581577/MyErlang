%%-----------------------------------------------------
%% @Module:game_geom_astar 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-6-10
%% @Desc:
%%-----------------------------------------------------

-module(game_geom_astar).
-compile(export_all).


-define(COST_STRAIGHT,10). 		%% 垂直方向或水平方向移动的路径评分
-define(COST_DIAGONAL,14). 		%% 斜向移动的路径评分

%% A星寻路算法 节点
-record(astar_node, {
	key 						%% 	没有实际意义，纯粹为了加快lists检索效率 y*width + x
	,x	   						%% 	格子在X轴上的坐标,即第几列
	,y	   						%% 	格子在Y轴上的坐标,即第几行
    ,g = 0     					%%	当前格子到起点的移动耗费
    ,h = 0     					%%	当前格子到终点的移动耗费，即曼哈顿距离，即|x1-x2|+|y1-y2|(忽略障碍物)
    ,f = 0     					%%	f=g+h
    ,flag = 1   				%%	0表示不可行区域,1表示可行区域
    ,visit = 0 					%%	是否在关闭列表中,1表示在开启列表中，其它表示在关闭列表中
%%     ,open_index = 0 			%%	该节点在开启列表中索引位置
	,parent = -1 				%%	父格子，存储父格子的key
}).
%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([]).

-define(MAP_WIDTH, 	20).
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
	StratTime = erlang:timestamp(),
	test(Max,PathData1),
	EndTime = erlang:timestamp(),
	Time = timer:now_diff(EndTime, StratTime),			
    io:format("use time:~w~n",[Time]).

test(0,_) -> ok;
test(Max,PathData) ->
%% 	test(5,0,10,9,PathData),
	test(0,0,19,19,PathData),
	test(Max - 1,PathData).

test(X1,Y1,X2,Y2,PathData) ->
    case search_path(X1,Y1,X2,Y2,?MAP_WIDTH,?MAP_HEIGHT,PathData) of
        {ok,ResultList} ->
%% 			show_result(0,ResultList,PathData),
%% 			io:format("result list:~p~n",[ResultList]),
			ResultList;
        {false,Msg} ->
            io:format("error:~p!",[Msg])
    end.

init_path_data([], _, _, Arr) -> Arr;
init_path_data([H|T], Index, {MapW,MapH}, Arr) ->
    X = Index rem MapW,
    Y = Index div MapW,
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
	case get_grid(ToX,ToY,MapW,PathData) of       
  		EndNode when is_record(EndNode,astar_node) ->
       		if 
				EndNode#astar_node.flag > 0 ->
               		case get_grid(FromX,FromY,MapW,PathData) of
                   		StartNode when is_record(StartNode,astar_node) -> 
							search_path2(FromX,FromY,ToX,ToY,StartNode,EndNode,MapW,MapH,PathData);
                   		_ -> 
							{false, <<"start node not exist">>}
                   	end;
               	true ->
               		{false, <<"target unwalkable">>}
           	end;
       	_ ->  
			{false, <<"target node not exist">>}
   end.
   
search_path2(_FromX,_FromY,ToX,ToY,StartNode,EndNode,MapW,MapH,PathData)->
	StartTime = erlang:timestamp(),
	%% StartNode加入OpenList
	OpenList = [StartNode],
  	case search(OpenList,ToX,ToY,EndNode,MapW,MapH,PathData,0) of
   		{ok,ResultList} ->
			EndTime = erlang:timestamp(),
			Time = timer:now_diff(EndTime, StartTime),			
    		io:format("X1:~p,Y1:~p,X2:~p,Y2:~p per use time:~w~n",[_FromX,_FromY,ToX,ToY,Time]),			
    		{ok,ResultList};
       	Error ->
         	Error
  	end.


search([],_EndX,_EndY,_EndNode,_MapW,_MapH,_PathData,Count) ->
	io:format("not find Count:~w~n", [Count]),
	{ok,[]};
search(OpenList,EndX,EndY,EndNode,MapW,MapH,PathData,Count) ->
	case get_open_node_by_min_f(OpenList) of
   		{ok,[]} ->
	   		{ok,[]};
   		{ok,HNode} ->
			if 
				HNode#astar_node.x =:= EndX andalso HNode#astar_node.y =:= EndY ->
					io:format("success find Count:~w~n", [Count]),
		            %% 已经找到目标点
		            ResultList = get_path([],HNode,PathData),
		            {ok,ResultList};
		        true ->
		            %% 未到目标点
		            %% 选择8个方向的可行区域
		            Directions = [
								  {-1,0,	?COST_STRAIGHT},	%% 左
		                          {1,0,		?COST_STRAIGHT},	%% 右
		                          {0,-1,	?COST_STRAIGHT},	%% 上
		                          {0,1,		?COST_STRAIGHT},	%% 下
		                          {-1,-1,	?COST_DIAGONAL},	%% 左上
		                          {-1,1, 	?COST_DIAGONAL},	%% 左下
		                          {1,-1, 	?COST_DIAGONAL},	%% 右上
		                          {1,1,  	?COST_DIAGONAL} 	%% 右下
		                          ],
	              	CheckFun = 
						fun({AddX,AddY,Cost},{OpenListTmp,PathDataTmp}) ->
                     		check_path(HNode#astar_node.x + AddX,HNode#astar_node.y + AddY,OpenListTmp,HNode,EndNode,Cost,MapW,MapH,PathDataTmp)
                 		end,
	              	{OpenList1,PathData1} = lists:foldl(CheckFun, {OpenList,PathData},Directions),
					%% 从open列表中删除当前节点 将其添加进closed列表
					OpenList2 = delete_open_node_by_key(HNode#astar_node.key,OpenList1),
                	PathData2 = array:set(HNode#astar_node.key,HNode#astar_node{visit=1},PathData1),
                	search(OpenList2,EndX,EndY,EndNode,MapW,MapH,PathData2,Count+1)
			end
	end.

%%根据格子的索引坐标找到格子
get_grid(X,Y,MapW,PathData) ->
    %?DEBUG("X:~w,Y:~w,Index:~w~n",[X,Y,(Y * MapW + X)]),
    Index = Y * MapW + X,
    Size  = array:size(PathData),
    if Index < 0 orelse Index >= Size -> error;
       true ->
        case array:get(Index, PathData) of
              Node when is_record(Node,astar_node) -> Node;
              _ -> error
           end
    end.

check_path(X,Y,OpenList,ParentNode,EndNode,Cost,MapW,MapH,PathData) ->
	if 
		X < 0 orelse Y < 0 orelse X >= MapW orelse Y >= MapH -> 
			{OpenList,PathData};
        true ->
            %检查当前格子是否为可行区域
        	case get_grid(X,Y,MapW,PathData) of
         		CurNode when is_record(CurNode,astar_node) ->
	         		if 
				 		CurNode#astar_node.flag =/= 0 ->
							%% 可行
	                 		check_path1(X,Y,OpenList,ParentNode,CurNode,EndNode,Cost,PathData);
		             	true ->
							%% 不可行 添加到关闭列表中
		                 	CurNode1  = CurNode#astar_node{visit = 1},
		                 	PathData1 = array:set(CurNode1#astar_node.key, CurNode1, PathData),
		                 	{OpenList,PathData1}
		         	end;
         		_  ->
             		{OpenList,PathData}
			end
    end.

%% @doc 检查节点是否在关闭列表中
%% @doc 如果在关闭列表中 忽略该节点
check_path1(X,Y,OpenList,ParentNode,CurNode,EndNode,Cost,PathData)->
    case CurNode#astar_node.visit of
    	1  ->
        	{OpenList,PathData};
        _ ->
           check_path2(X,Y,OpenList,ParentNode,CurNode,EndNode,Cost,PathData)
    end.

%% @doc 检查节点是否在开启列表中
%% @doc 如果在开启列表中 根据当前路径判断G值是否更小 如果是则更新 否则忽略
%% @doc 如果不在开启列表中 添加进开启列表
check_path2(_X,_Y,OpenList,ParentNode,CurNode,EndNode,Cost,PathData) ->
    H = abs(CurNode#astar_node.x - EndNode#astar_node.x) + abs(CurNode#astar_node.y - EndNode#astar_node.y),
     case get_open_node_by_key(CurNode#astar_node.key,OpenList) of
        false ->
       		%%不在开启列表中
       		Node = CurNode#astar_node{ 
				parent = ParentNode#astar_node.key
				,g = ParentNode#astar_node.g + Cost
				,h = H
			},
           	NewOpenList = add_open_node(Node,OpenList),
       		{NewOpenList,PathData};
     	{ok, OldNode} when is_record(OldNode,astar_node) ->
      		%%在开启列表中
          	if
				ParentNode#astar_node.g + Cost < OldNode#astar_node.g ->
					%% 如果node已经在open列表中：当我们使用当前生成的路径到达那里时，检查G值是否更小。
					%% 如果是，更新它的G值和它的父节点
              		Node1 = CurNode#astar_node{
						parent = ParentNode#astar_node.key
					  	,g=ParentNode#astar_node.g + Cost
						,h=H
					},
					PathData1 = array:set(Node1#astar_node.key, Node1, PathData),
                    NewOpenList = replace_open_node_by_key(Node1,OpenList),
              		{NewOpenList,PathData1};
              	true ->
                  	{OpenList,PathData}
          	end
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
get_open_node_by_key(Key,OpenNodeList) ->
    case lists:keyfind(Key,#astar_node.key,OpenNodeList) of
    	false -> false;
        Node  -> {ok,Node}
    end.

%% @doc 从开启列表获取最小f值的node
get_open_node_by_min_f(OpenNodeList) when is_list(OpenNodeList) ->
    case OpenNodeList of
    	[] -> 
			{ok,[]};
        _List ->
			[HNode|_T] = OpenNodeList,
         	MinNode = get_open_node_by_min_f1(OpenNodeList,HNode),
           	{ok, MinNode}
    end.

get_open_node_by_min_f1([],MinNode) -> MinNode;
get_open_node_by_min_f1([H|T],MinNode) ->
    case (H#astar_node.g + H#astar_node.h) < (MinNode#astar_node.g + MinNode#astar_node.h) of
    	true ->
            get_open_node_by_min_f1(T,H);
        _ ->
            get_open_node_by_min_f1(T,MinNode)
    end.

%% %% @doc 按F值对开启列表排序
%% sort_open_node_list(OpenNodeList) ->
%% 	lists:sort(fun(X1,X2) -> (X1#astar_node.g + X1#astar_node.h) < (X2#astar_node.g + X2#astar_node.h) end, OpenNodeList).

get_path(ResultList,Node,_PathData) when Node#astar_node.parent =:= -1 ->
	[Node|ResultList];
get_path(ResultList,Node,PathData) ->
	Parent = array:get(Node#astar_node.parent, PathData),
	get_path([Node|ResultList], Parent, PathData).

save(Index, Node) ->
	put({node,Index},Node).

get_node(Index) ->
	get({node,Index}).
  
  
  

