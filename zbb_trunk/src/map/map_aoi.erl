%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.19
%%% @desc   : 基于网格的场景管理(dict)
%%%----------------------------------------------------------------------

-module(map_aoi).

-include("common.hrl").
-include("record.hrl").

%-export([batch_insert_actor/2
%		,insert_actor/5
%		,insert_actor/6
%		,delete_actor/5
%		,update_actor/7
%		,get_grids_object/3
%		,get_grids_object/4
%		,update_sender/6
%		]).
%
%-export([get_aoi/4]).


-export([create_map_aoi/2
        ,get_aoi_grid/3
        ,get_grids/2
        ,get_grids/4
        ,get_default_9_grid/2
        ,get_grid_index_by_pos/2
        ]).

%% @doc 创建地图数据
%% @return #aoi_map{}
create_map_aoi(TopLeft = {TopLeftX, TopLeftY}, BottomRight = {BottomRightX, BottomRightY}) ->
	Width = abs(TopLeftX - BottomRightX),
	Height = abs(TopLeftY - BottomRightY),
	XCount = Width div ?GRID_WIDTH,
	YCount = Height div ?GRID_HEIGHT,	
	#aoi_map{
		top_left = TopLeft
		,bottom_right = BottomRight
		,x_count = XCount
		,y_count = YCount
	}.

%% @doc 根据节点index得到节点信息
%% @return {true, AoiGrid}|false
get_aoi_grid(AoiMap, IndexX, IndexY) ->
	case dict:find({IndexX, IndexY}, AoiMap#aoi_map.grid_dict) of
		{ok, AoiGrid} ->
			{true, AoiGrid};
		_ ->
			false
	end.

%% @doc 返回点所在区域的grids_list
%% 当前为默认9宫格的大格子列表
%% @return GridsList
get_grids(PosX, PosY) ->
	{IndexX, IndexY} = get_grid_index_by_pos(PosX, PosY),
	get_default_9_grid(IndexX, IndexY).

%% @doc 返回矩形区域的grids_list
%% @return GridsList
get_grids(StartX, StartY, EndX, EndY) ->
	{StartIndexX, StartIndexY} = get_grid_index_by_pos(StartX, StartY),
	{EndIndexX, EndIndexY} = get_grid_index_by_pos(EndX, EndY),
	F = fun(GridIndexY, Acc) ->
			lists:foldl(fun(GridIndexX, TempAcc) -> 
							[{GridIndexX, GridIndexY} | TempAcc]
						end, 
				 Acc, lists:seq(erlang:min(StartIndexX, EndIndexX), erlang:max(StartIndexX, EndIndexX)))
		end,
	lists:foldl(F, [], lists:seq(erlang:min(StartIndexY, EndIndexY), erlang:max(StartIndexY, EndIndexY))).


%% @doc 获得默认的九宫格
%% @return [{IndexX,IndexY},....] 
get_default_9_grid(IndexX, IndexY) ->	
	[?LEFTUP(IndexX, IndexY),   ?UP(IndexX, IndexY),   ?RIGHTUP(IndexX, IndexY), 
     ?LEFT(IndexX, IndexY),     {IndexX, IndexY},      ?RIGHT(IndexX, IndexY),
     ?LEFTDOWN(IndexX, IndexY), ?DOWN(IndexX, IndexY), ?RIGHTDOWN(IndexX, IndexY)].

%% @doc 根据坐标计算节点index
%% @return {GridIndexX, GridIndexY}
get_grid_index_by_pos(X, Y) ->
	{X div ?GRID_WIDTH, Y div ?GRID_HEIGHT}.


%%% @doc 重连时更新AOI中的sender
%%% @return false|{true,NewAoiMap,SeeMeGridsList}
%update_sender(AoiMap, Id, Type, X, Y, NewSender) ->
%	{GridIndexX, GridIndexY} = get_grid_index_by_pos(X, Y),
%	case get_grid(AoiMap, GridIndexX, GridIndexY) of
%		false ->
%			%% X,Y上无节点
%			false;
%		{true,AoiGrid} when is_record(AoiGrid, aoi_grid) ->
%			ObjectDict = AoiGrid#aoi_grid.object_dict,
%			ObjectList = 
%				case dict:find(Type, ObjectDict) of
%					{ok,V} ->
%						V;
%					_ ->
%						[]
%				end,
%			case lists:keyfind({Id,Type}, #aoi_obj.key, ObjectList) of
%				false ->
%					false;
%				AoiObj when is_record(AoiObj, aoi_obj) ->					
%					NewAoiGrid = AoiGrid#aoi_grid{
%						object_dict = dict:store(Type, lists:keystore({Id,Type}, #aoi_obj.key, ObjectList, AoiObj#aoi_obj{sender = NewSender}), ObjectDict)								  
%					},
%					NewAoiMap = save_grid(AoiMap, NewAoiGrid),
%					{true, NewAoiMap, get_default_9_grid(GridIndexX, GridIndexY)}
%			end
%	end.	
%	
%
%%% @doc 插入obj
%%% @return {true, NewAoiMap, SeeMeGridsList}
%insert_actor(AoiMap, Id, Type, X, Y) ->
%	insert_actor(AoiMap, Id, Type, X, Y, undefined).
%insert_actor(AoiMap, Id, Type, X, Y, Sender) ->
%	{GridIndexX, GridIndexY} = get_grid_index_by_pos(X, Y),
%	{true, NewAoiMap} = local_insert_actor(AoiMap, Id, Type, X, Y, Sender),
%	{true, NewAoiMap, get_default_9_grid(GridIndexX, GridIndexY)}.
%
%
%%% @doc 批量插入obj
%%% @return {true, NewAoiMap} 
%batch_insert_actor(AoiMap, List) ->
%	F = fun({Id,Type,X,Y},Acc) ->
%		{true,Acc1} = local_insert_actor(Acc, Id, Type, X, Y, undefined),
%		Acc1
%	end,
%	{true, lists:foldl(F, AoiMap, List)}.
%
%local_insert_actor(AoiMap, Id, Type, X, Y, Sender) ->
%	{GridIndexX, GridIndexY} = get_grid_index_by_pos(X, Y),
%	AoiObject = #aoi_obj{
%		key = {Id,Type}
%		,id = Id
%		,obj_type = Type
%		,sender = Sender	  
%	},	
%	case get_grid(AoiMap, GridIndexX, GridIndexY) of
%		false ->
%			%% 无节点
%			AoiGrid = #aoi_grid{
%				grid_index_x = GridIndexX
%				,grid_index_y = GridIndexY
%				,object_dict = dict:store(Type, [AoiObject], dict:new())	
%			},
%			
%			{true, save_grid(AoiMap, AoiGrid)};
%		{true,AoiGrid} when is_record(AoiGrid, aoi_grid) ->
%			ObjectDict = AoiGrid#aoi_grid.object_dict,
%			ObjectList = 
%				case dict:find(Type, ObjectDict) of
%					{ok,V} ->
%						V;
%					_ ->
%						[]
%				end,	
%			NewL = lists:keystore({Id,Type}, #aoi_obj.key, ObjectList, AoiObject),
%			NewAoiGrid = AoiGrid#aoi_grid{
%				object_dict = dict:store(Type, NewL, ObjectDict)								  
%			},
%			{true, save_grid(AoiMap, NewAoiGrid)}
%	end.
%
%%% @doc 删除obj
%%% @return {true,NewAoiMap,SeeMeGridList}|false SeeMeList:obj所在九宫格的对象列表(包含自己)
%delete_actor(AoiMap, Id, Type, X, Y) ->
%	{GridIndexX, GridIndexY} = get_grid_index_by_pos(X, Y),
%	case get_grid(AoiMap, GridIndexX, GridIndexY) of
%		false ->
%			%% X,Y上无节点
%			false;
%		{true,AoiGrid} when is_record(AoiGrid, aoi_grid) ->
%			ObjectDict = AoiGrid#aoi_grid.object_dict,
%			ObjectList = 
%				case dict:find(Type, ObjectDict) of
%					{ok,V} ->
%						V;
%					_ ->
%						[]
%				end,
%			NewAoiGrid = AoiGrid#aoi_grid{
%				object_dict = dict:store(Type, lists:keydelete({Id,Type}, #aoi_obj.key, ObjectList), ObjectDict)								  
%			},
%			NewAoiMap = save_grid(AoiMap, NewAoiGrid),
%			{true, NewAoiMap, get_default_9_grid(GridIndexX, GridIndexY)}
%	end.
%
%
%
%
%%% @doc 更新aoi_obj的坐标
%%% @return {true, cross_grid, NewAoiMap, NewGridList, OldGridList}|{true, one_grid}|false
%update_actor(AoiMap, Id, Type, OldX, OldY, NewX, NewY) ->
%	{OldIndexX, OldIndexY} = get_grid_index_by_pos(OldX, OldY),
%	{NewIndexX, NewIndexY} = get_grid_index_by_pos(NewX, NewY),
%	case abs(OldIndexX - NewIndexX) =< 1 andalso abs(OldIndexY - NewIndexY) =< 1 of
%		true ->
%			case OldIndexX == NewIndexX andalso OldIndexY == NewIndexY of
%				true ->
%					%% 同一格
%					{true, one_grid};
%				_ ->
%%% 					io:format("Id:~w Type:~w OldX:~w, OldY:~w, NewX:~w, NewY:~w OldIndexX:~w, OldIndexY:~w NewIndexX:~w, NewIndexY:~w~n", [Id, Type, OldX, OldY, NewX, NewY, OldIndexX, OldIndexY, NewIndexX, NewIndexY]),					
%					%% 跨越了单元格
%					NewAoiMap = change_actor_grid_index(AoiMap, Id, Type, OldIndexX, OldIndexY, NewIndexX, NewIndexY),
%					
%					{NewGridList, OldGridList} = compute_grid(OldIndexX, OldIndexY, NewIndexX, NewIndexY, AoiMap#aoi_map.x_count, AoiMap#aoi_map.y_count),
%		%% 			io:format("NewGridList:~w, OldGridList:~w", [NewGridList, OldGridList]),
%%% 					F = fun({IndexX, IndexY}, Acc) ->
%%% 						case get_grid(NewAoiMap, IndexX, IndexY) of
%%% 							{true, AoiGrid} ->
%%% 								[AoiGrid#aoi_grid.object_list|Acc];
%%% 							_ ->
%%% 								Acc
%%% 						end
%%% 					end,
%%% 					NewList2 = lists:flatten(lists:foldl(F, [], NewGridList)), 
%%% 					OldList2 = lists:flatten(lists:foldl(F, [], OldGridList)),							
%					{true, cross_one_grid, NewAoiMap, NewGridList, OldGridList}
%			end;
%		false ->
%			%% 跳格 非法操作
%%%			io:format("Id:~w, OldIndexX:~w, OldIndexY:~w, NewIndexX:~w, NewIndexY:~w, NewX:~w, NewY:~w", [Id, OldIndexX, OldIndexY, NewIndexX, NewIndexY, NewX, NewY]),
%			OldGridList = get_default_9_grid(OldIndexX, OldIndexY),
%			NewGridList = get_default_9_grid(NewIndexX, NewIndexY),
%			NewAoiMap = change_actor_grid_index(AoiMap, Id, Type, OldIndexX, OldIndexY, NewIndexX, NewIndexY),
%			{true, cross_multi_grid, NewAoiMap, NewGridList, OldGridList}
%	end.
%
%change_actor_grid_index(AoiMap, Id, Type, OldIndexX, OldIndexY, NewIndexX, NewIndexY) ->
%	{true, OldGrid} = get_grid(AoiMap, OldIndexX, OldIndexY),
%	OldObjectDict = OldGrid#aoi_grid.object_dict,
%	OldObjectList = 
%		case dict:find(Type, OldObjectDict) of
%			{ok,V} ->
%				V;
%			_ ->
%				[]
%		end,
%	#aoi_obj{sender = Sender} = lists:keyfind({Id, Type}, #aoi_obj.key, OldObjectList),
%	OldGrid1 = OldGrid#aoi_grid{
%		object_dict = dict:store(Type, lists:keydelete({Id, Type}, #aoi_obj.key, OldObjectList), OldObjectDict)
%	},
%	AoiMap0 = save_grid(AoiMap, OldGrid1), 
%	case get_grid(AoiMap0, NewIndexX, NewIndexY) of
%		{true, NewGrid} ->
%			NewObjectDict = NewGrid#aoi_grid.object_dict,
%			NewObjectList = 
%				case dict:find(Type, NewObjectDict) of
%					{ok,V1} ->
%						V1;
%					_ ->
%						[]
%				end,
%			NewGrid1 = NewGrid#aoi_grid{
%				object_dict = dict:store(Type, lists:keystore({Id, Type}, #aoi_obj.key, NewObjectList, #aoi_obj{key = {Id,Type},id = Id,obj_type = Type,sender = Sender}), NewObjectDict)
%			},
%			save_grid(AoiMap0, NewGrid1);
%		false ->
%			NewGrid1 = #aoi_grid{
%				grid_index_x = NewIndexX
%				,grid_index_y = NewIndexY
%				,object_dict = dict:store(Type, [#aoi_obj{key = {Id,Type},id = Id,obj_type = Type,sender = Sender}], dict:new())
%			},
%			save_grid(AoiMap0, NewGrid1)
%	end.
%
%%% ------------------------------------------------------------------------------------------
%%% Internal functions
%%% ------------------------------------------------------------------------------------------
%%% compute_grid1(IndexX, IndexY, NewIndexX, NewIndexY, _MaxIndexX, _MaxIndexY) ->
%%% 	NewGridList = get_default_9_grid(NewIndexX, NewIndexY),
%%% 	OldGridList = get_default_9_grid(IndexX, IndexY),
%%% 	{util:list_minus(NewGridList, OldGridList), util:list_minus(OldGridList, NewGridList)}.
%
%%% @doc 计算网格{Index, Index}按方向移动1格后相应的变化值
%%% @return {NewGridList, OldGridList}
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, MaxIndexX, _MaxIndexY) when NewIndexX > IndexX,NewIndexY == IndexY ->
%	%% 右
%	case NewIndexX == MaxIndexX of
%		true ->
%			%% 右边界
%			{
%				[], 
%				[?LeftDown(IndexX,IndexY), ?Left(IndexX,IndexY), ?LeftUp(IndexX,IndexY)]
%			};
%		_ ->
%			{
%				[?RightUp(NewIndexX,NewIndexY), ?Right(NewIndexX,NewIndexY), ?RightDown(NewIndexX,NewIndexY)], 
%				[?LeftDown(IndexX,IndexY), ?Left(IndexX,IndexY), ?LeftUp(IndexX,IndexY)]
%			}
%	end;
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, MaxIndexX, MaxIndexY) when NewIndexX > IndexX, NewIndexY > IndexY ->
%	%% 右下
%	case {NewIndexX == MaxIndexX, NewIndexY == MaxIndexY} of
%		{true, true} ->
%			%% 右下边界	
%			{
%				[], 
%				[?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY)]
%			};
%		{true, _} ->
%			%% 右边界
%			{
%				[?Down(NewIndexX,NewIndexY), ?LeftDown(NewIndexX,NewIndexY)],
%				[?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY)]
%			};
%		{_, true} ->
%			%% 下边界
%			{
%				[?RightUp(NewIndexX,NewIndexY), ?Right(NewIndexX,NewIndexY)],
%				[?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY)]
%			};
%		_ ->
%			{
%				[?RightUp(NewIndexX, NewIndexY), ?Right(NewIndexX, NewIndexY), ?RightDown(NewIndexX, NewIndexY), ?Down(NewIndexX, NewIndexY), ?LeftDown(NewIndexX, NewIndexY)],
%				[?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY)]
%			}
%	end;
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, _MaxIndexX, MaxIndexY) when NewIndexX == IndexX,NewIndexY > IndexY ->
%	%% 下
%	case NewIndexY == MaxIndexY of
%		true ->
%			%% 下边界
%			{
%				[], 
%				[?LeftUp(IndexX,IndexY), ?Up(IndexX,IndexY), ?RightUp(IndexX,IndexY)]
%			};
%		_ ->
%			{
%				[?RightDown(NewIndexX,NewIndexY), ?Down(NewIndexX,NewIndexY), ?LeftDown(NewIndexX,NewIndexY)],
%				[?LeftUp(IndexX,IndexY), ?Up(IndexX,IndexY), ?RightUp(IndexX,IndexY)]
%			}
%	end;
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, _MaxIndexX, MaxIndexY) when NewIndexX < IndexX, NewIndexY > IndexY ->
%	%% 左下
%	case {NewIndexX == 0, NewIndexY == MaxIndexY} of
%		{true, true} ->
%			%% 左下边界	
%			{
%				[], 
%				[?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY)]
%			};
%		{true, _} ->
%			%% 左边界
%			{
%				[?RightDown(NewIndexX, NewIndexY), ?Down(NewIndexX, NewIndexY)],
%				[?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY)]
%			};
%		{_, true} ->
%			%% 下边界
%			{
%				[?Left(NewIndexX, NewIndexY), ?LeftUp(NewIndexX, NewIndexY)],
%				[?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY)]
%			};
%		_ ->
%			{
%				[?RightDown(NewIndexX, NewIndexY), ?Down(NewIndexX, NewIndexY), ?LeftDown(NewIndexX, NewIndexY), ?Left(NewIndexX, NewIndexY), ?LeftUp(NewIndexX, NewIndexY)],
%				[?LeftUp(IndexX, IndexY), ?Up(IndexX, IndexY), ?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY)]
%			}
%	end;
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, _MaxIndexX, _MaxIndexY) when NewIndexX < IndexX,NewIndexY == IndexY ->
%	%% 左
%	case NewIndexX == 0 of
%		true ->
%			%% 左边界
%			{
%				[],
%				[?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY)]
%			};
%		_ ->
%			{
%				[?LeftDown(NewIndexX, NewIndexY), ?Left(NewIndexX, NewIndexY), ?LeftUp(NewIndexX, NewIndexY)],
%				[?RightUp(IndexX,IndexY), ?Right(IndexX,IndexY), ?RightDown(IndexX,IndexY)]
%			}
%	end;
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, _MaxIndexX, _MaxIndexY) when NewIndexX < IndexX, NewIndexY < IndexY ->
%	%% 左上
%	case {NewIndexX == 0, NewIndexY == 0} of
%		{true, true} ->
%			%% 左上边界	
%			{
%				[], 
%				[?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY)]
%			};
%		{true, _} ->
%			%% 左边界
%			{
%				[?Up(NewIndexX, NewIndexY), ?RightUp(NewIndexX, NewIndexY)],
%				[?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY)]
%			};
%		{_, true} ->
%			%% 上边界
%			{
%				[?LeftDown(NewIndexX, NewIndexY), ?Left(NewIndexX, NewIndexY)],
%				[?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY)]
%			};
%		_ ->
%			{
%				[?LeftDown(NewIndexX, NewIndexY), ?Left(NewIndexX, NewIndexY), ?LeftUp(NewIndexX, NewIndexY), ?Up(NewIndexX, NewIndexY), ?RightUp(NewIndexX, NewIndexY)],
%				[?RightUp(IndexX, IndexY), ?Right(IndexX, IndexY), ?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY)]
%			}
%	end;
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, _MaxIndexX, _MaxIndexY) when NewIndexX == IndexX,NewIndexY < IndexY ->
%	%% 上
%	case NewIndexY == 0 of
%		true ->
%			%% 上边界
%			{
%				[],
%				[?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY)]
%			};
%		_ ->
%			{
%				[?LeftUp(NewIndexX, NewIndexY), ?Up(NewIndexX, NewIndexY), ?RightUp(NewIndexX, NewIndexY)],
%				[?RightDown(IndexX,IndexY), ?Down(IndexX,IndexY), ?LeftDown(IndexX,IndexY)]
%			}
%	end;
%compute_grid(IndexX, IndexY, NewIndexX, NewIndexY, MaxIndexX, _MaxIndexY) when NewIndexX > IndexX, NewIndexY < IndexY ->
%	%% 右上
%	case {NewIndexX == MaxIndexX, NewIndexY == 0} of
%		{true, true} ->
%			%% 右上边界	
%			{
%				[], 
%				[?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY)]
%			};
%		{true, _} ->
%			%% 右边界
%			{
%				[?LeftUp(NewIndexX, NewIndexY), ?Up(NewIndexX, NewIndexY)],
%				[?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY)]
%			};
%		{_, true} ->
%			%% 上边界
%			{
%				[?Right(NewIndexX, NewIndexY), ?Right(NewIndexX, NewIndexY)],
%				[?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY)]
%			};
%		_ ->
%			{
%				[?LeftUp(NewIndexX, NewIndexY), ?Up(NewIndexX, NewIndexY), ?RightUp(NewIndexX, NewIndexY), ?Right(NewIndexX, NewIndexY), ?RightDown(NewIndexX, NewIndexY)],
%				[?RightDown(IndexX, IndexY), ?Down(IndexX, IndexY), ?LeftDown(IndexX, IndexY), ?Left(IndexX, IndexY), ?LeftUp(IndexX, IndexY)]
%			}
%	end;
%compute_grid(_IndexX, _IndexY, _NewIndexX, _NewIndexY, _MaxIndexX, _MaxIndexY) ->
%	{[], []}.
%
%%% %% @doc 获得九宫格(做过边界处理)
%%% %% @return [{IndexX,IndexY},....]
%%% get_9_grid(IndexX, IndexY, MaxIndexX, _MaxIndexY) when IndexX == MaxIndexX,IndexY == 0 ->
%%% 	%% 右上角落 向左下平移1格即为9宫格范围
%%% 	lists:map(fun({X,Y}) -> {X-1, Y+1} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, MaxIndexX, MaxIndexY) when IndexX == MaxIndexX,IndexY == MaxIndexY ->
%%% 	%% 右下
%%% 	lists:map(fun({X,Y}) -> {X-1, Y-1} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, _MaxIndexX, MaxIndexY) when IndexX == 0,IndexY == MaxIndexY ->
%%% 	%% 左下
%%% 	lists:map(fun({X,Y}) -> {X+1, Y-1} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, _MaxIndexX, _MaxIndexY) when IndexX == 0,IndexY == 0 ->
%%% 	%% 左上
%%% 	lists:map(fun({X,Y}) -> {X+1, Y+1} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, MaxIndexX, _MaxIndexY) when IndexX == MaxIndexX ->
%%% 	%% 右
%%% 	lists:map(fun({X,Y}) -> {X-1, Y} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, _MaxIndexX, MaxIndexY) when IndexY == MaxIndexY ->
%%% 	%% 下
%%% 	lists:map(fun({X,Y}) -> {X, Y-1} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, _MaxIndexX, _MaxIndexY) when IndexX == 0 ->
%%% 	%% 左
%%% 	lists:map(fun({X,Y}) -> {X+1, Y} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, _MaxIndexX, _MaxIndexY) when IndexY == 0 ->
%%% 	%% 上
%%% 	lists:map(fun({X,Y}) -> {X, Y+1} end, get_default_9_grid(IndexX, IndexY));
%%% get_9_grid(IndexX, IndexY, _MaxIndexX, _MaxIndexY) ->
%%% 	get_default_9_grid(IndexX, IndexY).
%
%%%  {-1,-1} {0,-1} {1,-1}
%%%  {-1, 0} {0, 0} {1, 0}
%%%  (-1, 1) {0, 1} {1, 1}
%
%
%save_grid(AoiMap, AoiGrid = #aoi_grid{grid_index_x = X, grid_index_y = Y, object_dict = Dict}) ->
%	Data =
%	case dict:size(Dict) == 0 of
%		true ->
%			dict:erase({X,Y}, AoiMap#aoi_map.dict);
%		_ ->
%			dict:store({X,Y}, AoiGrid, AoiMap#aoi_map.dict)
%	end,
%	AoiMap#aoi_map{
%		dict = Data 		   
%	}.
%
%get_grids_object(AoiMap, GridsList, Type) ->
%	get_grids_object(AoiMap, GridsList, Type, undefined).
%
%get_grids_object(AoiMap, GridsList, Type, CheckFun) ->
%	lists:foldl(fun({IndexX,IndexY},Acc) ->
%					case (IndexX >=0 andalso IndexX =< AoiMap#aoi_map.x_count 
%						andalso IndexY >= 0 andalso IndexY =< AoiMap#aoi_map.y_count) of
%						true ->
%							case get_grid(AoiMap,IndexX,IndexY) of
%								{true,AoiGrid} ->
%									ObjectList = 
%										case dict:find(Type, AoiGrid#aoi_grid.object_dict) of
%											{ok,V} ->
%												V;
%											_ ->
%												[]
%										end,
%									Fun = 
%										case CheckFun of 
%								 		undefined -> 
%									 		fun(Obj,AccTemp) ->
%												[Obj|AccTemp]
%											end;
%								 		_ ->
%											fun(Obj,AccTemp) ->
%												case CheckFun(Obj) of
%													true -> [Obj|AccTemp];
%													false -> AccTemp
%												end
%											end
%								 	end,
%									lists:foldl(Fun, Acc, ObjectList);
%								_ ->
%									Acc
%							end;
%						false ->
%							Acc
%					end
%				end, [], GridsList).
%
%
%%% ------------------------------------------------------------------------------------------
%%% Test functions
%%% ------------------------------------------------------------------------------------------
%get_aoi(AoiMap, X, Y, Type) ->
%	{GridIndexX, GridIndexY} = get_grid_index_by_pos(X, Y),
%	case get_grid(AoiMap, GridIndexX, GridIndexY) of
%		false ->
%			%% X,Y上无节点
%			false;
%		{true,AoiGrid} when is_record(AoiGrid, aoi_grid) ->
%			ObjectDict = AoiGrid#aoi_grid.object_dict,
%			case dict:find(Type, ObjectDict) of
%				{ok,V} ->
%					V;
%				_ ->
%					[]
%			end
%	end.
%
