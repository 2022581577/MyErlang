-ifndef(C2S31001_PB_H).
-define(C2S31001_PB_H, true).
-record(c2s31001, {
    
}).
-endif.

-ifndef(S2C31001_PB_H).
-define(S2C31001_PB_H, true).
-record(s2c31001, {
    date_list = [],
    reward_list = [],
    resign_num = erlang:error({required, resign_num})
}).
-endif.

-ifndef(C2S31002_PB_H).
-define(C2S31002_PB_H, true).
-record(c2s31002, {
    
}).
-endif.

-ifndef(C2S31003_PB_H).
-define(C2S31003_PB_H, true).
-record(c2s31003, {
    date = erlang:error({required, date})
}).
-endif.

-ifndef(C2S31004_PB_H).
-define(C2S31004_PB_H, true).
-record(c2s31004, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(C2S31005_PB_H).
-define(C2S31005_PB_H, true).
-record(c2s31005, {
    
}).
-endif.

-ifndef(S2C31005_PB_H).
-define(S2C31005_PB_H, true).
-record(s2c31005, {
    type = erlang:error({required, type}),
    reward_list = []
}).
-endif.

-ifndef(STRUCT_REWARD_PB_H).
-define(STRUCT_REWARD_PB_H, true).
-record(struct_reward, {
    id = erlang:error({required, id}),
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S31006_PB_H).
-define(C2S31006_PB_H, true).
-record(c2s31006, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C31007_PB_H).
-define(S2C31007_PB_H, true).
-record(s2c31007, {
    back1 = [],
    back2 = [],
    back3 = []
}).
-endif.

-ifndef(STRUCT_REWARD_BACK_PB_H).
-define(STRUCT_REWARD_BACK_PB_H, true).
-record(struct_reward_back, {
    type = erlang:error({required, type}),
    num = erlang:error({required, num}),
    state = erlang:error({required, state})
}).
-endif.

-ifndef(C2S31008_PB_H).
-define(C2S31008_PB_H, true).
-record(c2s31008, {
    cost = erlang:error({required, cost}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(C2S31009_PB_H).
-define(C2S31009_PB_H, true).
-record(c2s31009, {
    lv = erlang:error({required, lv})
}).
-endif.

-ifndef(C2S31010_PB_H).
-define(C2S31010_PB_H, true).
-record(c2s31010, {
    day = erlang:error({required, day})
}).
-endif.

