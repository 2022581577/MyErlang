-ifndef(C2S31001_PB_H).
-define(C2S31001_PB_H, true).
-record(c2s31001, {
    auto_sgin_up = erlang:error({required, auto_sgin_up}),
    gender_limit = erlang:error({required, gender_limit}),
    password = erlang:error({required, password})
}).
-endif.

-ifndef(STRUCT_GROUP_PB_H).
-define(STRUCT_GROUP_PB_H, true).
-record(struct_group, {
    id = erlang:error({required, id}),
    leader = erlang:error({required, leader}),
    member = erlang:error({required, member}),
    gender_limit = erlang:error({required, gender_limit}),
    password = erlang:error({required, password})
}).
-endif.

-ifndef(STRUCT_SELF_GROUP_PB_H).
-define(STRUCT_SELF_GROUP_PB_H, true).
-record(struct_self_group, {
    id = erlang:error({required, id}),
    state = erlang:error({required, state}),
    leader = erlang:error({required, leader}),
    member = erlang:error({required, member}),
    auto_sgin_up = erlang:error({required, auto_sgin_up}),
    gender_limit = erlang:error({required, gender_limit}),
    password = erlang:error({required, password})
}).
-endif.

