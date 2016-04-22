-ifndef(C2S33001_PB_H).
-define(C2S33001_PB_H, true).
-record(c2s33001, {
    box_type = erlang:error({required, box_type}),
    num_type = erlang:error({required, num_type})
}).
-endif.

-ifndef(S2C33001_PB_H).
-define(S2C33001_PB_H, true).
-record(s2c33001, {
    treasure_list = []
}).
-endif.

-ifndef(S2C33002_PB_H).
-define(S2C33002_PB_H, true).
-record(s2c33002, {
    msg_list = []
}).
-endif.

-ifndef(STRUCT_TREASURE_MSG_PB_H).
-define(STRUCT_TREASURE_MSG_PB_H, true).
-record(struct_treasure_msg, {
    user_id = erlang:error({required, user_id}),
    name = erlang:error({required, name}),
    item = erlang:error({required, item})
}).
-endif.

-ifndef(C2S33003_PB_H).
-define(C2S33003_PB_H, true).
-record(c2s33003, {
    id_list = []
}).
-endif.

-ifndef(C2S33004_PB_H).
-define(C2S33004_PB_H, true).
-record(c2s33004, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(C2S33005_PB_H).
-define(C2S33005_PB_H, true).
-record(c2s33005, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C33005_PB_H).
-define(S2C33005_PB_H, true).
-record(s2c33005, {
    roulette_list = []
}).
-endif.

-ifndef(S2C33006_PB_H).
-define(S2C33006_PB_H, true).
-record(s2c33006, {
    jackpots = erlang:error({required, jackpots}),
    msg_list = []
}).
-endif.

-ifndef(STRUCT_ROULETTE_MSG_PB_H).
-define(STRUCT_ROULETTE_MSG_PB_H, true).
-record(struct_roulette_msg, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    name = erlang:error({required, name}),
    item = erlang:error({required, item})
}).
-endif.

-ifndef(STRUCT_TREASURE_PB_H).
-define(STRUCT_TREASURE_PB_H, true).
-record(struct_treasure, {
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

