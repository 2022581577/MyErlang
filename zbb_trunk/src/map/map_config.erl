%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.19
%%% @desc   : 地图配置相关，用于地图初始化，一般由地图编辑器生成
%%%           (需和前端商量好数据格式)
%%%           地图坐标的放置，现暂定左上角topleft{0,0}, 右下角bottomright{maxX, maxY}
%%%----------------------------------------------------------------------

-module(map_config).

-include("common.hrl").
-include("record.hrl").
-include("proto_60_pb.hrl").



%% ====================================================================
%% API functions
%% ====================================================================
-export([load_map_config/0
        ,load_map_config/1
        ,get_map_config/1
    ]).

-export([
        get_seq/3
		,get_seq_by_index/3
		,is_walkable/3
		,is_walkable_by_index/3
		,is_walkable_by_seq/2
		,is_normal_map/1
		,is_safe/3
		]).

%% @doc 加载所有地图配置
load_map_config() ->
    MapIDList = data_map:get_list(),
    SourceIDList = [begin
                        #tpl_map{source_id = SourceID} = data_map:get(E),
                        load_map(SourceID)
                    end || E <- MapIDList],
    SourceIDList1 = lists:usort(SourceIDList),
    [load_map_config(E) || E <- SourceIDList1].

%% @doc 根据id加载地图配置
load_map_config(SourceID) ->
	case file:read_file(lists:concat(["./map/map", SourceID])) of
		{ok, Binary} ->
			<<EncryptMode:8, _IsZip:8, EncryptBin/binary>> = Binary,
			{ok, _Cmd, Data, _TimeStamp} = game_protobuf:decode_package(EncryptMode, "", EncryptBin), 
			parse_data(Data);
		{error, _Reason} ->
			?WARNING("read_map error SourceID:~w, Reason:~w", [SourceID, _Reason])
	end.

%% @doc 根据地图id获取地图配置
get_map_config(MapID) ->
    case ets:lookup(?ETS_MAP_CONFIG, tpl2source(MapID)) of
        [#tpl_map_config{} = MapConfig] ->
            MapConfig;
        _ ->
            false
    end.


%% ====================================================================
%% Internal functions
%% ====================================================================
parse_data(#c2s60002{source_id = SourceID
		            ,width = Width
		            ,height = Height
		            ,block_list = BlockList
		            ,npc_list = NpcList
		            ,monster_list = MonsterList
		            ,collect_list = CollectList
		            ,door_list = DoorList
		            ,born_point = BornPointList
    	            ,name = MapName
    	            ,min_level = MinLevel
                    ,dup_mon_list = DupMonList}) ->
    %% 根据像素计算横线纵向格子数，TODO 与前端商量格子数计算规则
	ColNum = Width div ?CELL_WIDTH + 1,
	RowNum = Height div ?CELL_HEIGHT + 1,
	MapConfig = #tpl_map_config{source_id = SourceID
  		                       ,map_name = MapName
  		                       ,min_level = MinLevel
  		                       ,width = Width
 		                       ,height = Height
		                       ,relive_point = pointlist2obj(BornPointList)
		                       ,mon_list = itemlist2obj(MonsterList)
		                       ,door_list = doorlist2obj(DoorList)
		                       ,npc_list = itemlist2obj(NpcList)
		                       ,collect_list = itemlist2obj(CollectList)
		                       ,dup_mon_list = dupmon2obj(DupMonList)
		                       ,col_num = ColNum
		                       ,row_num = RowNum},
	ets:insert(?ETS_MAP_CONFIG, MapConfig),
    %% 阻挡点，放入到对应ets中，TODO ets的new是否能够提前new，方便统一管理
    map_block:load_map_block(SourceID, BlockList),
	ok.

%% 各种格式转换，TODO 可以和前端商定好地图编辑器生成的数据格式
itemlist2obj(List) ->
	[{Id, X, Y} || {c2s60002_item,X,Y,Id,_Type} <- List].

doorlist2obj(List) ->
	[{Id, X, Y, TargetX, TargetY} || {c2s60002_door,X,Y,Id,TargetX,TargetY} <- List].

dupmon2obj(List) ->
	[itemlist2obj(L1)||{c2s60002_item_list,L1} <- List].

pointlist2obj(List) ->
	[{X, Y} || {c2s60002_point,X,Y} <- List].


tpl2source(MapID) ->
    #tpl_map{source_id = SourceID} = data_map:get(MapID),
    SourceID.

