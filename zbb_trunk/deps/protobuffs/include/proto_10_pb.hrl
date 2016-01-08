-ifndef(C2S10000_PB_H).
-define(C2S10000_PB_H, true).
-record(c2s10000, {
    acct_name = erlang:error({required, acct_name}),
    infant = erlang:error({required, infant}),
    time_stamp = erlang:error({required, time_stamp}),
    sign = erlang:error({required, sign}),
    server_no = erlang:error({required, server_no}),
    micro_flag = 0,
    open_key = [],
    pf = [],
    pf_key = [],
    zone_id = [],
    is_hook = 0,
    via = []
}).
-endif.

-ifndef(S2C10000_PB_H).
-define(S2C10000_PB_H, true).
-record(s2c10000, {
    result = erlang:error({required, result}),
    msg = erlang:error({required, msg}),
    session_key = erlang:error({required, session_key}),
    users = []
}).
-endif.

-ifndef(C2S10003_PB_H).
-define(C2S10003_PB_H, true).
-record(c2s10003, {
    user_name = erlang:error({required, user_name}),
    career_id = erlang:error({required, career_id})
}).
-endif.

-ifndef(S2C10003_PB_H).
-define(S2C10003_PB_H, true).
-record(s2c10003, {
    result = erlang:error({required, result}),
    msg = erlang:error({required, msg}),
    create_user_id = erlang:error({required, create_user_id}),
    users = []
}).
-endif.

-ifndef(C2S10004_PB_H).
-define(C2S10004_PB_H, true).
-record(c2s10004, {
    acct_name = erlang:error({required, acct_name}),
    user_id = erlang:error({required, user_id})
}).
-endif.

-ifndef(S2C10004_PB_H).
-define(S2C10004_PB_H, true).
-record(s2c10004, {
    result = erlang:error({required, result}),
    session_key = erlang:error({required, session_key}),
    freshman_flag = erlang:error({required, freshman_flag})
}).
-endif.

-ifndef(S2C10005_PB_H).
-define(S2C10005_PB_H, true).
-record(s2c10005, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S10006_PB_H).
-define(C2S10006_PB_H, true).
-record(c2s10006, {
    acct_name = erlang:error({required, acct_name}),
    server_no = erlang:error({required, server_no}),
    infant = erlang:error({required, infant}),
    user_id = erlang:error({required, user_id}),
    session_key = erlang:error({required, session_key})
}).
-endif.

-ifndef(S2C10006_PB_H).
-define(S2C10006_PB_H, true).
-record(s2c10006, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S10007_PB_H).
-define(C2S10007_PB_H, true).
-record(c2s10007, {
    user_id = erlang:error({required, user_id}),
    session_key = erlang:error({required, session_key})
}).
-endif.

-ifndef(S2C10007_PB_H).
-define(S2C10007_PB_H, true).
-record(s2c10007, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S10008_PB_H).
-define(C2S10008_PB_H, true).
-record(c2s10008, {
    acct_name = erlang:error({required, acct_name}),
    server_no = erlang:error({required, server_no})
}).
-endif.

-ifndef(S2C10008_PB_H).
-define(S2C10008_PB_H, true).
-record(s2c10008, {
    ip = erlang:error({required, ip}),
    port = erlang:error({required, port})
}).
-endif.

-ifndef(C2S10009_PB_H).
-define(C2S10009_PB_H, true).
-record(c2s10009, {
    step = erlang:error({required, step})
}).
-endif.

-ifndef(SIMPLE_USER_PB_H).
-define(SIMPLE_USER_PB_H, true).
-record(simple_user, {
    user_id = erlang:error({required, user_id}),
    user_name = erlang:error({required, user_name}),
    career_id = erlang:error({required, career_id}),
    level = erlang:error({required, level})
}).
-endif.

