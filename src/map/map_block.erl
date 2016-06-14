%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.19
%%% @desc   : 地图阻挡信息，需要跟前端商量地图格子flag的意义
%%%----------------------------------------------------------------------

-module(map_block).

-include("common.hrl").
-include("record.hrl").
-include("tpl_map.hrl").

-export([load_map_block/2
        ,ets_map_block_name_list/0
        ,is_walkable_by_pos/3
        ,is_walkable_by_seq/2
        ,is_walkable_by_index/3
        ,is_safe/3]).

%% @doc 获取地图资源ets_map_block_name的列表
ets_map_block_name_list() ->
    MapIDList = data_map:get_list(),
    SourceIDList = [begin
                        #tpl_map{source_id = SourceID} = data_map:get(E),
                        SourceID
                    end || E <- MapIDList],
    SourceIDList1 = lists:usort(SourceIDList),
    [ets_map_block_name(E) || E <- SourceIDList1].


%% @doc 加载地图阻挡信息
load_map_block(SourceID, BlockList) ->
    EtsName = ets_map_block_name(SourceID),
    gen_map_block(EtsName, BlockList, 0),  %% 编号从0开始
    ok.

%% 阻挡点编号规则，TODO 与前端商量好，跟格子数计算规则相关
gen_map_block(_EtsName, [], _Seq) ->
    ok;
gen_map_block(EtsName, [Flag|BlockList], Seq) ->
    Flag =/= 0 andalso ets:insert(EtsName, {Seq,Flag}),
    gen_map_block(EtsName, BlockList, Seq + 1).


%% @doc 判断坐标是否可行
%% @param {IndexX, IndexY}从{0,0}开始
%% @return true|false
is_walkable_by_pos(#tpl_map_config{} = MapConfig, PosX, PosY) ->
    {Seq,_,_} = get_seq_by_pos(MapConfig, PosX, PosY),
    is_walkable_by_seq(MapConfig, Seq);
is_walkable_by_pos(MapID, PosX, PosY) ->
    is_walkable_by_pos(map_config:get_map_config(MapID), PosX, PosY).

is_walkable_by_index(#tpl_map_config{} = MapConfig, IndexX, IndexY) ->
    Seq = get_seq_by_index(MapConfig, IndexX, IndexY),
    is_walkable_by_seq(MapConfig,Seq);
is_walkable_by_index(MapID, IndexX, IndexY) ->
    is_walkable_by_index(map_config:get_map_config(MapID), IndexX, IndexY).

is_walkable_by_seq(#tpl_map_config{source_id = SourceID}, Seq) ->
    EtsName = ets_map_block_name(SourceID),
    case ets:lookup(EtsName, Seq) of
        [{Seq, Flag}] ->
            <<_A1:1,_A2:1,_A3:1,_A4:1,_A5:1,_A6:1,Alpha:1,Road:1>> = <<Flag:8>>,
            Alpha == 1 orelse Road == 1;
        _ ->
            false
    end;
is_walkable_by_seq(MapID, Seq) ->
    is_walkable_by_seq(map_config:get_map_config(MapID), Seq).

%% @doc 判断坐标是否安全区
%% @return true|false
is_safe(#tpl_map_config{source_id = SourceID} = MapConfig, PosX, PosY) ->
    {Seq,_,_} = get_seq_by_pos(MapConfig, PosX, PosY),
    EtsName = ets_map_block_name(SourceID),
    case ets:lookup(EtsName, Seq) of
        [{Seq, Flag}] ->
            <<_A1:1,_A2:1,_A3:1,Safe:1,_A5:1,_A6:1,_Alpha:1,_Road:1>> = <<Flag:8>>,
            Safe == 1;
        _ ->
            false
    end;
is_safe(MapID, PosX, PosY) ->
    is_safe(map_config:get_map_config(MapID), PosX, PosY).

%% @doc 根据坐标得到索引序号
%% @return {Seq,IndexX,IndexY}
get_seq_by_pos(MapConfig, PosX, PosY) ->
    IndexX = PosX div ?CELL_WIDTH,
    IndexY = PosY div ?CELL_HEIGHT,
    Seq = get_seq_by_index(MapConfig, IndexX, IndexY),
    {Seq, IndexX, IndexY}.

%% @doc 根据格子得到索引序号
get_seq_by_index(#tpl_map_config{col_num = ColNum}, IndexX, IndexY) ->
    IndexY * ColNum + IndexX.

%% ets的名字
ets_map_block_name(SourceID) ->
    util:to_atom(lists:concat(["ets_map_block_", SourceID])).

