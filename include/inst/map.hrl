-ifndef(MAP_HRL).
-define(MAP_HRL, "map.hrl").

%% ---------- 地图掩码等配置相关 -----------
-define(RIGHT(X,Y),     {X+1,   Y}).
-define(RIGHTDOWN(X,Y), {X+1,   Y+1}).
-define(DOWN(X,Y),      {X,     Y+1}).
-define(LEFTDOWN(X,Y),  {X-1,   Y+1}).
-define(LEFT(X,Y),      {X-1,   Y}).
-define(LEFTUP(X,Y),    {X-1,   Y-1}).
-define(UP(X,Y),        {X,     Y-1}).
-define(RIGHTUP(X,Y),   {X+1,   Y-1}).
        
-define(MAP_WIDTH,  25000).
-define(MAP_HEIGHT, 25000).

%% 格子宽、高
-define(CELL_WIDTH,     40).    
-define(CELL_HEIGHT,    40).
%% 大格子宽、高
-define(GRID_WIDTH,     720).
-define(GRID_HEIGHT,    480).

-define(AOI_OBJ_TYPE_USER,  0).
-define(AOI_OBJ_TYPE_MON,   1).

%% ---------- 地图掩码等配置相关 -----------

-define(MAP_LOOP_TICK, 50).               %% 地图循环时间 50ms

%% 地图类型
-define(MAP_TYPE_NORMAL,    1).     %% 普通地图 
-define(MAP_TYPE_DUP,       2).     %% 副本
-define(MAP_TYPE_ACTIVITY,  3).     %% 活动地图

-endif.
