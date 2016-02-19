-ifndef(TPL_MAP_HRL).
-define(TPL_MAP_HRL, "tpl_map.hrl").

%%模板结构
-record(tpl_map, {
				id		%%	id
				,source_id		%%	地图资源(server)
				,map_type		%%	地图类型	//作者://地图类型枚举1 普通野外地图2 副本地图3 排位战4 活动5 私有副本
				,map_sub_type 
				,chest_drop		%%	是否掉丰收号角	//101). %% 世界BOSS102). %% 领地战103). %% 挂机地图401). %% 阵营战402). %% 秘境神树403). %% 帮会副本404). %% 沙滩答题407). %% 长跑
				,min_level		%%	最低进入等级要求
				,name		%%	名称	//作者:名称
				,map_cross_type		%%	跨服类型	//-define(MAP_CROSS_TYPE_NONE,  0).   %% 不跨服-define(MAP_CROSS_TYPE_SMALL,  1).   %% 小跨服-define(MAP_CROSS_TYPE_MIDDLE,  2).   %% 中跨服(同平台)-define(MAP_CROSS_TYPE_BIG,  3).   %% 大跨服(跨平台)
				,elite_list		%%	精英列表	//YY:[{Id1,X1,Y1},{Id2,X2,Y2},{Id3,[{X31,Y31},{X32,Y32}]}]其中1,2为固定坐标，3为随机坐标
				,elite_num		%%	精英
				,elite_refresh		%%	精英刷新时间	//YY:[上限,下限] 单位:秒
				,goblin_num		%%	哥布林数量
				,goblin_refresh		%%	哥布林刷新时间	//YY:[上限,下限]单位:秒
				,goblin_list		%%	哥布林刷新列表	//YY:[上限,下限]单位:秒
				,max_line		%%	最大线
				,disable_skill_list		%%	禁用的技能类型	//格式：技能类型1_技能类型2_技能类型3
				,pk_mode		%%	允许的pk模式	//作者:99 可以切任意模式0、和平模式1、帮派模式 2、队伍模式 3、红名模式4、自由模式
				,ride		%%	能否上坐骑	//Microsoft:0 不能1 能
                ,max_user       %% 地图人数上限 0表示没上限限制

				}).
-endif.
