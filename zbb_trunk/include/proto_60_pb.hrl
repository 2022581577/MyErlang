-ifndef(C2S60001_PB_H).
-define(C2S60001_PB_H, true).
-record(c2s60001, {
    lag = erlang:error({required, lag}),
    frame = 0,
    memory = 0,
    state = 0
}).
-endif.

-ifndef(S2C60001_PB_H).
-define(S2C60001_PB_H, true).
-record(s2c60001, {
    time_stamp = erlang:error({required, time_stamp})
}).
-endif.

-ifndef(C2S60002_PB_H).
-define(C2S60002_PB_H, true).
-record(c2s60002, {
    map_id = erlang:error({required, map_id}),
    map_type = erlang:error({required, map_type}),
    width = erlang:error({required, width}),
    height = erlang:error({required, height}),
    block_list = [],
    npc_list = [],
    monster_list = [],
    collect_list = [],
    door_list = [],
    born_point = [],
    edge = erlang:error({required, edge}),
    polygon_list = [],
    name = erlang:error({required, name}),
    min_level = erlang:error({required, min_level}),
    dup_mon_list = []
}).
-endif.

-ifndef(C2S60003_PB_H).
-define(C2S60003_PB_H, true).
-record(c2s60003, {
    
}).
-endif.

-ifndef(S2C60003_PB_H).
-define(S2C60003_PB_H, true).
-record(s2c60003, {
    help = erlang:error({required, help})
}).
-endif.

-ifndef(C2S60004_PB_H).
-define(C2S60004_PB_H, true).
-record(c2s60004, {
    gm = erlang:error({required, gm})
}).
-endif.

-ifndef(S2C60004_PB_H).
-define(S2C60004_PB_H, true).
-record(s2c60004, {
    reply = erlang:error({required, reply})
}).
-endif.

-ifndef(C2S60002_ITEM_LIST_PB_H).
-define(C2S60002_ITEM_LIST_PB_H, true).
-record(c2s60002_item_list, {
    list = []
}).
-endif.

-ifndef(C2S60002_DOOR_PB_H).
-define(C2S60002_DOOR_PB_H, true).
-record(c2s60002_door, {
    x = erlang:error({required, x}),
    y = erlang:error({required, y}),
    id = erlang:error({required, id}),
    target_x = erlang:error({required, target_x}),
    target_y = erlang:error({required, target_y})
}).
-endif.

-ifndef(C2S60002_POLYGON_PB_H).
-define(C2S60002_POLYGON_PB_H, true).
-record(c2s60002_polygon, {
    point_list = []
}).
-endif.

-ifndef(C2S60002_ITEM_PB_H).
-define(C2S60002_ITEM_PB_H, true).
-record(c2s60002_item, {
    x = erlang:error({required, x}),
    y = erlang:error({required, y}),
    id = erlang:error({required, id}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(C2S60002_POINT_PB_H).
-define(C2S60002_POINT_PB_H, true).
-record(c2s60002_point, {
    x = erlang:error({required, x}),
    y = erlang:error({required, y})
}).
-endif.

