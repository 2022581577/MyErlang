-ifndef(C2S11001_PB_H).
-define(C2S11001_PB_H, true).
-record(c2s11001, {
    channel_id = erlang:error({required, channel_id}),
    msg = erlang:error({required, msg})
}).
-endif.

-ifndef(S2C11001_PB_H).
-define(S2C11001_PB_H, true).
-record(s2c11001, {
    channel_id = erlang:error({required, channel_id}),
    user_id = erlang:error({required, user_id}),
    nick_name = erlang:error({required, nick_name}),
    career_id = erlang:error({required, career_id}),
    level = erlang:error({required, level}),
    vip_level = erlang:error({required, vip_level}),
    server_no = erlang:error({required, server_no}),
    msg = erlang:error({required, msg}),
    time = erlang:error({required, time}),
    guild_id = erlang:error({required, guild_id}),
    user_type = 0,
    is_yellow = 0,
    is_year_yellow = 0,
    is_high_yellow = 0,
    yellow_level = 0
}).
-endif.

-ifndef(C2S11002_PB_H).
-define(C2S11002_PB_H, true).
-record(c2s11002, {
    user_id = erlang:error({required, user_id}),
    msg = erlang:error({required, msg})
}).
-endif.

-ifndef(S2C11003_PB_H).
-define(S2C11003_PB_H, true).
-record(s2c11003, {
    type = erlang:error({required, type}),
    msg = erlang:error({required, msg})
}).
-endif.

-ifndef(S2C11004_PB_H).
-define(S2C11004_PB_H, true).
-record(s2c11004, {
    msg = erlang:error({required, msg}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C11005_PB_H).
-define(S2C11005_PB_H, true).
-record(s2c11005, {
    notice_id = erlang:error({required, notice_id}),
    list = []
}).
-endif.

-ifndef(NOTICE_TYPE_PB_H).
-define(NOTICE_TYPE_PB_H, true).
-record(notice_type, {
    list = []
}).
-endif.

-ifndef(NOTICE_ARGS_PB_H).
-define(NOTICE_ARGS_PB_H, true).
-record(notice_args, {
    id = erlang:error({required, id}),
    value = erlang:error({required, value})
}).
-endif.

