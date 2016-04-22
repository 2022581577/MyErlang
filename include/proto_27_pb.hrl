-ifndef(S2C27000_PB_H).
-define(S2C27000_PB_H, true).
-record(s2c27000, {
    question_theme = erlang:error({required, question_theme})
}).
-endif.

-ifndef(S2C27001_PB_H).
-define(S2C27001_PB_H, true).
-record(s2c27001, {
    question_state = erlang:error({required, question_state}),
    count_down = erlang:error({required, count_down}),
    question_num = erlang:error({required, question_num}),
    question_id = erlang:error({required, question_id})
}).
-endif.

-ifndef(S2C27002_PB_H).
-define(S2C27002_PB_H, true).
-record(s2c27002, {
    correct_num = erlang:error({required, correct_num}),
    wisdom = erlang:error({required, wisdom})
}).
-endif.

-ifndef(S2C27003_PB_H).
-define(S2C27003_PB_H, true).
-record(s2c27003, {
    exp = erlang:error({required, exp})
}).
-endif.

-ifndef(S2C27004_PB_H).
-define(S2C27004_PB_H, true).
-record(s2c27004, {
    correct_list = [],
    error_list = []
}).
-endif.

-ifndef(S2C27005_PB_H).
-define(S2C27005_PB_H, true).
-record(s2c27005, {
    rank_list = []
}).
-endif.

-ifndef(QUESTION_RANK_PB_H).
-define(QUESTION_RANK_PB_H, true).
-record(question_rank, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    nick_name = erlang:error({required, nick_name}),
    wisdom = erlang:error({required, wisdom})
}).
-endif.

-ifndef(S2C27006_PB_H).
-define(S2C27006_PB_H, true).
-record(s2c27006, {
    count_down = erlang:error({required, count_down})
}).
-endif.

-ifndef(S2C27007_PB_H).
-define(S2C27007_PB_H, true).
-record(s2c27007, {
    rank_list = []
}).
-endif.

-ifndef(CHARM_RANK_PB_H).
-define(CHARM_RANK_PB_H, true).
-record(charm_rank, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    nick_name = erlang:error({required, nick_name}),
    charm = erlang:error({required, charm})
}).
-endif.

-ifndef(C2S27008_PB_H).
-define(C2S27008_PB_H, true).
-record(c2s27008, {
    target_id = erlang:error({required, target_id})
}).
-endif.

-ifndef(S2C27008_PB_H).
-define(S2C27008_PB_H, true).
-record(s2c27008, {
    user_id = erlang:error({required, user_id}),
    target_id = erlang:error({required, target_id})
}).
-endif.

-ifndef(C2S27009_PB_H).
-define(C2S27009_PB_H, true).
-record(c2s27009, {
    
}).
-endif.

-ifndef(C2S27010_PB_H).
-define(C2S27010_PB_H, true).
-record(c2s27010, {
    target_id = erlang:error({required, target_id})
}).
-endif.

-ifndef(S2C27010_PB_H).
-define(S2C27010_PB_H, true).
-record(s2c27010, {
    user_id = erlang:error({required, user_id}),
    target_id = erlang:error({required, target_id})
}).
-endif.

-ifndef(S2C27011_PB_H).
-define(S2C27011_PB_H, true).
-record(s2c27011, {
    num_list = []
}).
-endif.

-ifndef(STRUCK_INTERACTION_PB_H).
-define(STRUCK_INTERACTION_PB_H, true).
-record(struck_interaction, {
    type = erlang:error({required, type}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(S2C27012_PB_H).
-define(S2C27012_PB_H, true).
-record(s2c27012, {
    charm = erlang:error({required, charm})
}).
-endif.

-ifndef(C2S27013_PB_H).
-define(C2S27013_PB_H, true).
-record(c2s27013, {
    id = erlang:error({required, id}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C27013_PB_H).
-define(S2C27013_PB_H, true).
-record(s2c27013, {
    occupation_list = []
}).
-endif.

-ifndef(STRUCK_OCCUPATION_PB_H).
-define(STRUCK_OCCUPATION_PB_H, true).
-record(struck_occupation, {
    id = erlang:error({required, id}),
    mon_id = erlang:error({required, mon_id}),
    pos_x = erlang:error({required, pos_x}),
    pos_y = erlang:error({required, pos_y}),
    user_list = []
}).
-endif.

-ifndef(C2S27014_PB_H).
-define(C2S27014_PB_H, true).
-record(c2s27014, {
    target_id = erlang:error({required, target_id}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C27014_PB_H).
-define(S2C27014_PB_H, true).
-record(s2c27014, {
    type = erlang:error({required, type}),
    bask_list = []
}).
-endif.

-ifndef(STRUCK_BASK_PB_H).
-define(STRUCK_BASK_PB_H, true).
-record(struck_bask, {
    user_id1 = erlang:error({required, user_id1}),
    user_id2 = erlang:error({required, user_id2})
}).
-endif.

-ifndef(S2C27015_PB_H).
-define(S2C27015_PB_H, true).
-record(s2c27015, {
    active_type = erlang:error({required, active_type})
}).
-endif.

-ifndef(C2S27016_PB_H).
-define(C2S27016_PB_H, true).
-record(c2s27016, {
    
}).
-endif.

-ifndef(S2C27016_PB_H).
-define(S2C27016_PB_H, true).
-record(s2c27016, {
    week_wisdom = erlang:error({required, week_wisdom}),
    month_wisdom = erlang:error({required, month_wisdom}),
    week_rank_list = [],
    month_rank_list = []
}).
-endif.

-ifndef(STRUCK_WEEK_RANK_PB_H).
-define(STRUCK_WEEK_RANK_PB_H, true).
-record(struck_week_rank, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    nick_name = erlang:error({required, nick_name}),
    wisdom = erlang:error({required, wisdom})
}).
-endif.

-ifndef(STRUCK_MONTH_RANK_PB_H).
-define(STRUCK_MONTH_RANK_PB_H, true).
-record(struck_month_rank, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    nick_name = erlang:error({required, nick_name}),
    wisdom = erlang:error({required, wisdom}),
    medal = erlang:error({required, medal})
}).
-endif.

-ifndef(S2C27017_PB_H).
-define(S2C27017_PB_H, true).
-record(s2c27017, {
    rank = erlang:error({required, rank})
}).
-endif.

