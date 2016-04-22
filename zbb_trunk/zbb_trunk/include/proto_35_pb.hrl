-ifndef(S2C35000_PB_H).
-define(S2C35000_PB_H, true).
-record(s2c35000, {
    info = erlang:error({required, info})
}).
-endif.

-ifndef(STRUCT_USER_BATTLE_3V3_PB_H).
-define(STRUCT_USER_BATTLE_3V3_PB_H, true).
-record(struct_user_battle_3v3, {
    user_id = erlang:error({required, user_id}),
    win = erlang:error({required, win}),
    fail = erlang:error({required, fail}),
    draw = erlang:error({required, draw}),
    escape = erlang:error({required, escape}),
    exp = erlang:error({required, exp}),
    lv = erlang:error({required, lv}),
    dan_grading = erlang:error({required, dan_grading}),
    king_finish_time = erlang:error({required, king_finish_time}),
    rise_win = erlang:error({required, rise_win}),
    rise_fail = erlang:error({required, rise_fail})
}).
-endif.

