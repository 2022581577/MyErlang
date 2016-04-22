-ifndef(C2S30001_PB_H).
-define(C2S30001_PB_H, true).
-record(c2s30001, {
    
}).
-endif.

-ifndef(S2C30001_PB_H).
-define(S2C30001_PB_H, true).
-record(s2c30001, {
    achieve_num = erlang:error({required, achieve_num}),
    list = [],
    finish_list = [],
    unfinish_list = []
}).
-endif.

-ifndef(STRUCT_TYPE_ACHIEVE_NUM_PB_H).
-define(STRUCT_TYPE_ACHIEVE_NUM_PB_H, true).
-record(struct_type_achieve_num, {
    type = erlang:error({required, type}),
    achieve_num = erlang:error({required, achieve_num})
}).
-endif.

-ifndef(C2S30002_PB_H).
-define(C2S30002_PB_H, true).
-record(c2s30002, {
    type = erlang:error({required, type}),
    sub_type = erlang:error({required, sub_type})
}).
-endif.

-ifndef(S2C30002_PB_H).
-define(S2C30002_PB_H, true).
-record(s2c30002, {
    type = erlang:error({required, type}),
    sub_type = erlang:error({required, sub_type}),
    list = []
}).
-endif.

-ifndef(STRUCT_ACHIEVE_DETAIL_PB_H).
-define(STRUCT_ACHIEVE_DETAIL_PB_H, true).
-record(struct_achieve_detail, {
    id = erlang:error({required, id}),
    is_finish = erlang:error({required, is_finish}),
    target_num = erlang:error({required, target_num}),
    now_num = erlang:error({required, now_num})
}).
-endif.

-ifndef(C2S30003_PB_H).
-define(C2S30003_PB_H, true).
-record(c2s30003, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(S2C30003_PB_H).
-define(S2C30003_PB_H, true).
-record(s2c30003, {
    id_list = []
}).
-endif.

-ifndef(S2C30004_PB_H).
-define(S2C30004_PB_H, true).
-record(s2c30004, {
    id = erlang:error({required, id})
}).
-endif.

