-ifndef(USER_STYLE_PB_H).
-define(USER_STYLE_PB_H, true).
-record(user_style, {
    nick_name = [],
    server_no = 0,
    career_id = 0,
    direction = 0,
    clothes_id = 0,
    is_transform = 0,
    vestment_id = 0,
    pk_mode = 0,
    pk_value = 0,
    guild_id = 0,
    guild_name = [],
    team_id = 0,
    dead_protect = 0,
    level = 0,
    guild_pos = 0,
    vip_level = 0,
    camp = 0,
    honor_level = 0,
    title_list = [],
    weapon_id = 0,
    fashion_weapon_id = 0,
    fashion_clothes_id = 0,
    meditation = 0,
    legend_pos = 0,
    grow_shape = [],
    is_yellow = 0,
    is_year_yellow = 0,
    is_high_yellow = 0,
    yellow_level = 0
}).
-endif.

-ifndef(USER_ATTR_PB_H).
-define(USER_ATTR_PB_H, true).
-record(user_attr, {
    max_hp = 0,
    max_mp = 0,
    max_physical = 0,
    speed = 0,
    attack_min = 0,
    attack_max = 0,
    physical_defense = 0,
    magic_defense = 0,
    hit = 0,
    dodge = 0,
    crit = 0,
    resist_crit = 0,
    sunder_armor = 0,
    holy_strike = 0,
    resist_holy = 0,
    crit_multiplier = 0,
    crit_damage_bonus = 0,
    crit_damage_reduction = 0,
    damage_bonus = 0,
    damage_reduction = 0,
    mon_damage_bonus = 0,
    user_damage_bonus = 0,
    mon_damage_reduction = 0,
    user_damage_reduction = 0,
    fix_damage = 0,
    fix_damage_reduction = 0,
    max_hp_bonus = 0,
    attack_bonus = 0,
    physical_defense_bonus = 0,
    magic_defense_bonus = 0,
    hit_bonus = 0,
    dodge_bonus = 0,
    crit_bonus = 0,
    resist_crit_bonus = 0,
    dizzy = 0,
    dizzy_resist = 0,
    slowdown = 0,
    slowdown_resist = 0,
    silence = 0,
    silence_resist = 0,
    attack_steal = 0,
    attack_rebound = 0
}).
-endif.

-ifndef(MAP_BUFF_PB_H).
-define(MAP_BUFF_PB_H, true).
-record(map_buff, {
    buff_id = erlang:error({required, buff_id}),
    end_time = erlang:error({required, end_time}),
    buff_value = 0,
    total_time = erlang:error({required, total_time}),
    level = 1,
    list = []
}).
-endif.

-ifndef(BUFF_ADD_ATTR_PB_H).
-define(BUFF_ADD_ATTR_PB_H, true).
-record(buff_add_attr, {
    attr_id = erlang:error({required, attr_id}),
    add_type = erlang:error({required, add_type}),
    attr_value = erlang:error({required, attr_value})
}).
-endif.

-ifndef(KEY_VALUE_PB_H).
-define(KEY_VALUE_PB_H, true).
-record(key_value, {
    key = erlang:error({required, key}),
    value = 0
}).
-endif.

-ifndef(ITEM_FORM_PB_H).
-define(ITEM_FORM_PB_H, true).
-record(item_form, {
    tpl_id = erlang:error({required, tpl_id}),
    num = erlang:error({required, num}),
    bind = erlang:error({required, bind}),
    extra_info = []
}).
-endif.

-ifndef(ITEM_EXTRA_INFO_PB_H).
-define(ITEM_EXTRA_INFO_PB_H, true).
-record(item_extra_info, {
    key = erlang:error({required, key}),
    value1 = 0,
    value2 = []
}).
-endif.

-ifndef(ITEM_STRUCT_PB_H).
-define(ITEM_STRUCT_PB_H, true).
-record(item_struct, {
    item_id = erlang:error({required, item_id}),
    tpl_id = erlang:error({required, tpl_id}),
    user_id = erlang:error({required, user_id}),
    bind = erlang:error({required, bind}),
    loc = erlang:error({required, loc}),
    cell = erlang:error({required, cell}),
    num = erlang:error({required, num}),
    extra_info = [],
    dirty = erlang:error({required, dirty})
}).
-endif.

-ifndef(VESTMENT_STRUCT_PB_H).
-define(VESTMENT_STRUCT_PB_H, true).
-record(vestment_struct, {
    select = erlang:error({required, select}),
    rank = erlang:error({required, rank}),
    star = erlang:error({required, star}),
    unlock_list = [],
    active_list = [],
    blood_list = [],
    soul_list = [],
    star_pool = erlang:error({required, star_pool})
}).
-endif.

-ifndef(UNLOCK_LIST_STRUCT_PB_H).
-define(UNLOCK_LIST_STRUCT_PB_H, true).
-record(unlock_list_struct, {
    vestment_id = erlang:error({required, vestment_id}),
    element_list = []
}).
-endif.

-ifndef(BLOOD_LIST_STRUCT_PB_H).
-define(BLOOD_LIST_STRUCT_PB_H, true).
-record(blood_list_struct, {
    vestment_id = erlang:error({required, vestment_id}),
    value_list = []
}).
-endif.

-ifndef(SOUL_LIST_STRUCT_PB_H).
-define(SOUL_LIST_STRUCT_PB_H, true).
-record(soul_list_struct, {
    vestment_id = erlang:error({required, vestment_id}),
    value_list = []
}).
-endif.

-ifndef(GROW_STRUCT_PB_H).
-define(GROW_STRUCT_PB_H, true).
-record(grow_struct, {
    grow_type = erlang:error({required, grow_type}),
    rank = erlang:error({required, rank}),
    countdown = erlang:error({required, countdown}),
    bless_value = erlang:error({required, bless_value}),
    grow_num = erlang:error({required, grow_num}),
    qual_num = erlang:error({required, qual_num}),
    select_image = erlang:error({required, select_image}),
    is_show = erlang:error({required, is_show}),
    skill_list = [],
    active_list = [],
    star = erlang:error({required, star}),
    base_battle = 0,
    grow_battle = 0,
    qual_battle = 0,
    skill_battle = 0
}).
-endif.

-ifndef(USER_SKILL_PB_H).
-define(USER_SKILL_PB_H, true).
-record(user_skill, {
    skill_id = erlang:error({required, skill_id}),
    skill_subtype = erlang:error({required, skill_subtype}),
    level = erlang:error({required, level}),
    dirty = 0
}).
-endif.

-ifndef(PATH_POINT_PB_H).
-define(PATH_POINT_PB_H, true).
-record(path_point, {
    pos_x = erlang:error({required, pos_x}),
    pos_y = erlang:error({required, pos_y})
}).
-endif.

-ifndef(P_USER_PB_H).
-define(P_USER_PB_H, true).
-record(p_user, {
    user_id = erlang:error({required, user_id}),
    nick_name = erlang:error({required, nick_name}),
    career_id = erlang:error({required, career_id}),
    level = erlang:error({required, level}),
    vip_level = erlang:error({required, vip_level}),
    battle_value = erlang:error({required, battle_value}),
    is_online = erlang:error({required, is_online}),
    last_online_time = erlang:error({required, last_online_time}),
    server_no = erlang:error({required, server_no}),
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    vestment_id = erlang:error({required, vestment_id}),
    flag_id = erlang:error({required, flag_id}),
    fashion_weapon_id = erlang:error({required, fashion_weapon_id}),
    clothes_id = erlang:error({required, clothes_id}),
    fashion_clothes_id = erlang:error({required, fashion_clothes_id}),
    weapon_id = erlang:error({required, weapon_id}),
    sex = erlang:error({required, sex}),
    yellow_level = erlang:error({required, yellow_level}),
    is_yellow = erlang:error({required, is_yellow}),
    is_year_yellow = erlang:error({required, is_year_yellow}),
    is_high_yellow = erlang:error({required, is_high_yellow}),
    wing_id = erlang:error({required, wing_id}),
    fashion_wing_id = erlang:error({required, fashion_wing_id})
}).
-endif.

-ifndef(P_USER_LITTLE_PB_H).
-define(P_USER_LITTLE_PB_H, true).
-record(p_user_little, {
    user_id = erlang:error({required, user_id}),
    nick_name = erlang:error({required, nick_name}),
    vip_level = erlang:error({required, vip_level}),
    server_no = erlang:error({required, server_no}),
    career_id = erlang:error({required, career_id}),
    yellow_level = erlang:error({required, yellow_level}),
    is_yellow = erlang:error({required, is_yellow}),
    is_year_yellow = erlang:error({required, is_year_yellow}),
    is_high_yellow = erlang:error({required, is_high_yellow})
}).
-endif.

-ifndef(GROW_SHAPE_STRUCT_PB_H).
-define(GROW_SHAPE_STRUCT_PB_H, true).
-record(grow_shape_struct, {
    grow_type = erlang:error({required, grow_type}),
    grow_id = 0,
    fashion_grow_id = 0
}).
-endif.

-ifndef(C2S22000_PB_H).
-define(C2S22000_PB_H, true).
-record(c2s22000, {
    page = erlang:error({required, page}),
    size = erlang:error({required, size})
}).
-endif.

-ifndef(S2C22000_PB_H).
-define(S2C22000_PB_H, true).
-record(s2c22000, {
    list = []
}).
-endif.

-ifndef(P_GUILD_PB_H).
-define(P_GUILD_PB_H, true).
-record(p_guild, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    lv = erlang:error({required, lv}),
    member_num = erlang:error({required, member_num}),
    server_no = erlang:error({required, server_no}),
    is_apply = erlang:error({required, is_apply}),
    flag_id = erlang:error({required, flag_id}),
    bv_total = erlang:error({required, bv_total}),
    buy_size_num = erlang:error({required, buy_size_num}),
    leader = erlang:error({required, leader})
}).
-endif.

-ifndef(C2S22001_PB_H).
-define(C2S22001_PB_H, true).
-record(c2s22001, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(S2C22001_PB_H).
-define(S2C22001_PB_H, true).
-record(s2c22001, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    lv = erlang:error({required, lv}),
    member_num = erlang:error({required, member_num}),
    server_no = erlang:error({required, server_no}),
    exp = erlang:error({required, exp}),
    notice = erlang:error({required, notice}),
    yy = erlang:error({required, yy}),
    qq = erlang:error({required, qq}),
    auto_allow_list = [],
    flag_lv = erlang:error({required, flag_lv}),
    tree_lv = erlang:error({required, tree_lv}),
    tree_start_time = erlang:error({required, tree_start_time}),
    dup_start_time = erlang:error({required, dup_start_time}),
    dup_lv = erlang:error({required, dup_lv}),
    flag_id = erlang:error({required, flag_id}),
    buy_size_num = erlang:error({required, buy_size_num}),
    leader = erlang:error({required, leader})
}).
-endif.

-ifndef(P_GUILD_APPLY_PB_H).
-define(P_GUILD_APPLY_PB_H, true).
-record(p_guild_apply, {
    user = erlang:error({required, user}),
    time = erlang:error({required, time})
}).
-endif.

-ifndef(P_GUILD_INVITE_PB_H).
-define(P_GUILD_INVITE_PB_H, true).
-record(p_guild_invite, {
    inviter = erlang:error({required, inviter}),
    tar = erlang:error({required, tar}),
    time = erlang:error({required, time})
}).
-endif.

-ifndef(AUTO_ALLOW_PB_H).
-define(AUTO_ALLOW_PB_H, true).
-record(auto_allow, {
    key = erlang:error({required, key}),
    value = erlang:error({required, value})
}).
-endif.

-ifndef(C2S22002_PB_H).
-define(C2S22002_PB_H, true).
-record(c2s22002, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(S2C22002_PB_H).
-define(S2C22002_PB_H, true).
-record(s2c22002, {
    id = erlang:error({required, id}),
    list = []
}).
-endif.

-ifndef(P_GUILD_MEMBER_PB_H).
-define(P_GUILD_MEMBER_PB_H, true).
-record(p_guild_member, {
    user = erlang:error({required, user}),
    offline_time = erlang:error({required, offline_time}),
    contribute = erlang:error({required, contribute}),
    contribute_total = erlang:error({required, contribute_total}),
    pos = erlang:error({required, pos})
}).
-endif.

-ifndef(C2S22003_PB_H).
-define(C2S22003_PB_H, true).
-record(c2s22003, {
    name = erlang:error({required, name}),
    flag_id = erlang:error({required, flag_id})
}).
-endif.

-ifndef(C2S22004_PB_H).
-define(C2S22004_PB_H, true).
-record(c2s22004, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(C2S22005_PB_H).
-define(C2S22005_PB_H, true).
-record(c2s22005, {
    tar_id = erlang:error({required, tar_id}),
    is_allow = erlang:error({required, is_allow})
}).
-endif.

-ifndef(C2S22006_PB_H).
-define(C2S22006_PB_H, true).
-record(c2s22006, {
    
}).
-endif.

-ifndef(C2S22007_PB_H).
-define(C2S22007_PB_H, true).
-record(c2s22007, {
    tar_id = erlang:error({required, tar_id}),
    pos = erlang:error({required, pos})
}).
-endif.

-ifndef(C2S22008_PB_H).
-define(C2S22008_PB_H, true).
-record(c2s22008, {
    tar_id = erlang:error({required, tar_id})
}).
-endif.

-ifndef(S2C22009_PB_H).
-define(S2C22009_PB_H, true).
-record(s2c22009, {
    code = erlang:error({required, code})
}).
-endif.

-ifndef(S2C22010_PB_H).
-define(S2C22010_PB_H, true).
-record(s2c22010, {
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    guild_pos = erlang:error({required, guild_pos}),
    contribute = erlang:error({required, contribute}),
    contribute_total = erlang:error({required, contribute_total}),
    flag_lv = erlang:error({required, flag_lv}),
    daily_award = erlang:error({required, daily_award}),
    lv_award = erlang:error({required, lv_award}),
    disband_time = erlang:error({required, disband_time}),
    task_refresh_num = erlang:error({required, task_refresh_num}),
    domain_award_flag = erlang:error({required, domain_award_flag}),
    join_time = erlang:error({required, join_time}),
    now_time = erlang:error({required, now_time}),
    is_first_join = erlang:error({required, is_first_join}),
    bless_info = []
}).
-endif.

-ifndef(P_BLESS_PB_H).
-define(P_BLESS_PB_H, true).
-record(p_bless, {
    type = erlang:error({required, type}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(S2C22011_PB_H).
-define(S2C22011_PB_H, true).
-record(s2c22011, {
    type = erlang:error({required, type}),
    user = erlang:error({required, user})
}).
-endif.

-ifndef(S2C22012_PB_H).
-define(S2C22012_PB_H, true).
-record(s2c22012, {
    pos = erlang:error({required, pos}),
    user = erlang:error({required, user})
}).
-endif.

-ifndef(C2S22013_PB_H).
-define(C2S22013_PB_H, true).
-record(c2s22013, {
    tar_id = erlang:error({required, tar_id})
}).
-endif.

-ifndef(S2C22013_PB_H).
-define(S2C22013_PB_H, true).
-record(s2c22013, {
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    guild_level = erlang:error({required, guild_level}),
    leader = erlang:error({required, leader})
}).
-endif.

-ifndef(C2S22014_PB_H).
-define(C2S22014_PB_H, true).
-record(c2s22014, {
    guild_id = erlang:error({required, guild_id}),
    reply = erlang:error({required, reply})
}).
-endif.

-ifndef(C2S22015_PB_H).
-define(C2S22015_PB_H, true).
-record(c2s22015, {
    
}).
-endif.

-ifndef(C2S22016_PB_H).
-define(C2S22016_PB_H, true).
-record(c2s22016, {
    msg = erlang:error({required, msg}),
    yy = erlang:error({required, yy}),
    qq = erlang:error({required, qq})
}).
-endif.

-ifndef(C2S22017_PB_H).
-define(C2S22017_PB_H, true).
-record(c2s22017, {
    auto_allow_list = []
}).
-endif.

-ifndef(C2S22018_PB_H).
-define(C2S22018_PB_H, true).
-record(c2s22018, {
    
}).
-endif.

-ifndef(S2C22018_PB_H).
-define(S2C22018_PB_H, true).
-record(s2c22018, {
    apply_list = [],
    invite_list = []
}).
-endif.

-ifndef(S2C22019_PB_H).
-define(S2C22019_PB_H, true).
-record(s2c22019, {
    apply_list = [],
    invite_list = [],
    apply_deletes = [],
    invite_deletes = []
}).
-endif.

-ifndef(C2S22020_PB_H).
-define(C2S22020_PB_H, true).
-record(c2s22020, {
    tar_id = erlang:error({required, tar_id})
}).
-endif.

-ifndef(C2S22021_PB_H).
-define(C2S22021_PB_H, true).
-record(c2s22021, {
    list = []
}).
-endif.

-ifndef(ITEM_INFO_PB_H).
-define(ITEM_INFO_PB_H, true).
-record(item_info, {
    item_tpl_id = erlang:error({required, item_tpl_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S22022_PB_H).
-define(C2S22022_PB_H, true).
-record(c2s22022, {
    
}).
-endif.

-ifndef(S2C22022_PB_H).
-define(S2C22022_PB_H, true).
-record(s2c22022, {
    list = []
}).
-endif.

-ifndef(GUILD_CONTRIBUTE_PB_H).
-define(GUILD_CONTRIBUTE_PB_H, true).
-record(guild_contribute, {
    user = erlang:error({required, user}),
    contribute_today = erlang:error({required, contribute_today}),
    contribute_total = erlang:error({required, contribute_total})
}).
-endif.

-ifndef(C2S22023_PB_H).
-define(C2S22023_PB_H, true).
-record(c2s22023, {
    
}).
-endif.

-ifndef(S2C22023_PB_H).
-define(S2C22023_PB_H, true).
-record(s2c22023, {
    list = []
}).
-endif.

-ifndef(P_GUILD_ITEM_PB_H).
-define(P_GUILD_ITEM_PB_H, true).
-record(p_guild_item, {
    id = erlang:error({required, id}),
    item = erlang:error({required, item})
}).
-endif.

-ifndef(C2S22024_PB_H).
-define(C2S22024_PB_H, true).
-record(c2s22024, {
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S22025_PB_H).
-define(C2S22025_PB_H, true).
-record(c2s22025, {
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S22026_PB_H).
-define(C2S22026_PB_H, true).
-record(c2s22026, {
    
}).
-endif.

-ifndef(S2C22026_PB_H).
-define(S2C22026_PB_H, true).
-record(s2c22026, {
    list = []
}).
-endif.

-ifndef(ITEM_APPLY_PB_H).
-define(ITEM_APPLY_PB_H, true).
-record(item_apply, {
    user = erlang:error({required, user}),
    id = erlang:error({required, id}),
    time = erlang:error({required, time}),
    item_id = erlang:error({required, item_id}),
    item = erlang:error({required, item})
}).
-endif.

-ifndef(C2S22027_PB_H).
-define(C2S22027_PB_H, true).
-record(c2s22027, {
    id = erlang:error({required, id}),
    is_allow = erlang:error({required, is_allow})
}).
-endif.

-ifndef(C2S22028_PB_H).
-define(C2S22028_PB_H, true).
-record(c2s22028, {
    list = [],
    tar_id = erlang:error({required, tar_id})
}).
-endif.

-ifndef(ITEM_ALLOT_PB_H).
-define(ITEM_ALLOT_PB_H, true).
-record(item_allot, {
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S22029_PB_H).
-define(C2S22029_PB_H, true).
-record(c2s22029, {
    
}).
-endif.

-ifndef(S2C22029_PB_H).
-define(S2C22029_PB_H, true).
-record(s2c22029, {
    list = []
}).
-endif.

-ifndef(ITEM_LOG_PB_H).
-define(ITEM_LOG_PB_H, true).
-record(item_log, {
    operator = erlang:error({required, operator}),
    op = erlang:error({required, op}),
    time = erlang:error({required, time}),
    item = erlang:error({required, item}),
    tar = erlang:error({required, tar})
}).
-endif.

-ifndef(C2S22031_PB_H).
-define(C2S22031_PB_H, true).
-record(c2s22031, {
    
}).
-endif.

-ifndef(C2S22032_PB_H).
-define(C2S22032_PB_H, true).
-record(c2s22032, {
    
}).
-endif.

-ifndef(C2S22033_PB_H).
-define(C2S22033_PB_H, true).
-record(c2s22033, {
    
}).
-endif.

-ifndef(S2C22033_PB_H).
-define(S2C22033_PB_H, true).
-record(s2c22033, {
    task_id = erlang:error({required, task_id}),
    state = erlang:error({required, state}),
    color = erlang:error({required, color}),
    list = [],
    help_num = erlang:error({required, help_num}),
    invite_num = erlang:error({required, invite_num}),
    awards = [],
    luck = erlang:error({required, luck})
}).
-endif.

-ifndef(P_TASK_LOG_PB_H).
-define(P_TASK_LOG_PB_H, true).
-record(p_task_log, {
    user = erlang:error({required, user}),
    tar = erlang:error({required, tar}),
    color = erlang:error({required, color})
}).
-endif.

-ifndef(C2S22034_PB_H).
-define(C2S22034_PB_H, true).
-record(c2s22034, {
    
}).
-endif.

-ifndef(S2C22034_PB_H).
-define(S2C22034_PB_H, true).
-record(s2c22034, {
    list = [],
    deletes = []
}).
-endif.

-ifndef(P_GUILD_TASK_PB_H).
-define(P_GUILD_TASK_PB_H, true).
-record(p_guild_task, {
    user = erlang:error({required, user}),
    luck = erlang:error({required, luck}),
    task_id = erlang:error({required, task_id}),
    state = erlang:error({required, state}),
    color = erlang:error({required, color}),
    help_num = erlang:error({required, help_num}),
    invite_num = erlang:error({required, invite_num}),
    is_helped = erlang:error({required, is_helped})
}).
-endif.

-ifndef(C2S22035_PB_H).
-define(C2S22035_PB_H, true).
-record(c2s22035, {
    tar_id = erlang:error({required, tar_id})
}).
-endif.

-ifndef(S2C22035_PB_H).
-define(S2C22035_PB_H, true).
-record(s2c22035, {
    user = erlang:error({required, user})
}).
-endif.

-ifndef(C2S22036_PB_H).
-define(C2S22036_PB_H, true).
-record(c2s22036, {
    tar_id = erlang:error({required, tar_id})
}).
-endif.

-ifndef(C2S22037_PB_H).
-define(C2S22037_PB_H, true).
-record(c2s22037, {
    
}).
-endif.

-ifndef(C2S22038_PB_H).
-define(C2S22038_PB_H, true).
-record(c2s22038, {
    
}).
-endif.

-ifndef(C2S22039_PB_H).
-define(C2S22039_PB_H, true).
-record(c2s22039, {
    
}).
-endif.

-ifndef(S2C22039_PB_H).
-define(S2C22039_PB_H, true).
-record(s2c22039, {
    list = []
}).
-endif.

-ifndef(DUP_LOG_PB_H).
-define(DUP_LOG_PB_H, true).
-record(dup_log, {
    dup_tpl_id = erlang:error({required, dup_tpl_id}),
    user = erlang:error({required, user})
}).
-endif.

-ifndef(S2C22041_PB_H).
-define(S2C22041_PB_H, true).
-record(s2c22041, {
    guild_id = erlang:error({required, guild_id}),
    state = erlang:error({required, state}),
    hp = erlang:error({required, hp}),
    ret_time = erlang:error({required, ret_time})
}).
-endif.

-ifndef(S2C22042_PB_H).
-define(S2C22042_PB_H, true).
-record(s2c22042, {
    guild_id = erlang:error({required, guild_id}),
    num = erlang:error({required, num}),
    exp = erlang:error({required, exp})
}).
-endif.

-ifndef(C2S22045_PB_H).
-define(C2S22045_PB_H, true).
-record(c2s22045, {
    guild_id = erlang:error({required, guild_id})
}).
-endif.

-ifndef(C2S22047_PB_H).
-define(C2S22047_PB_H, true).
-record(c2s22047, {
    
}).
-endif.

-ifndef(S2C22048_PB_H).
-define(S2C22048_PB_H, true).
-record(s2c22048, {
    mon_lv = erlang:error({required, mon_lv}),
    score = erlang:error({required, score}),
    time = erlang:error({required, time}),
    min_score = erlang:error({required, min_score}),
    list = []
}).
-endif.

-ifndef(DUP_SCORE_PB_H).
-define(DUP_SCORE_PB_H, true).
-record(dup_score, {
    user = erlang:error({required, user}),
    value = erlang:error({required, value}),
    value1 = erlang:error({required, value1})
}).
-endif.

-ifndef(S2C22049_PB_H).
-define(S2C22049_PB_H, true).
-record(s2c22049, {
    exp = erlang:error({required, exp})
}).
-endif.

-ifndef(S2C22050_PB_H).
-define(S2C22050_PB_H, true).
-record(s2c22050, {
    list_personal = [],
    list_guild = [],
    guild_exp = erlang:error({required, guild_exp}),
    n = erlang:error({required, n}),
    mon_lv = erlang:error({required, mon_lv})
}).
-endif.

-ifndef(C2S22051_PB_H).
-define(C2S22051_PB_H, true).
-record(c2s22051, {
    
}).
-endif.

-ifndef(S2C22051_PB_H).
-define(S2C22051_PB_H, true).
-record(s2c22051, {
    list = []
}).
-endif.

-ifndef(P_GUILD_DUP_PB_H).
-define(P_GUILD_DUP_PB_H, true).
-record(p_guild_dup, {
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    mon_lv = erlang:error({required, mon_lv}),
    score = erlang:error({required, score}),
    leader = erlang:error({required, leader})
}).
-endif.

-ifndef(C2S22052_PB_H).
-define(C2S22052_PB_H, true).
-record(c2s22052, {
    
}).
-endif.

-ifndef(C2S22053_PB_H).
-define(C2S22053_PB_H, true).
-record(c2s22053, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(S2C22053_PB_H).
-define(S2C22053_PB_H, true).
-record(s2c22053, {
    bgold = erlang:error({required, bgold})
}).
-endif.

-ifndef(S2C22054_PB_H).
-define(S2C22054_PB_H, true).
-record(s2c22054, {
    guild_id = erlang:error({required, guild_id}),
    list = []
}).
-endif.

-ifndef(C2S22055_PB_H).
-define(C2S22055_PB_H, true).
-record(c2s22055, {
    
}).
-endif.

-ifndef(C2S22056_PB_H).
-define(C2S22056_PB_H, true).
-record(c2s22056, {
    
}).
-endif.

-ifndef(S2C22057_PB_H).
-define(S2C22057_PB_H, true).
-record(s2c22057, {
    id = erlang:error({required, id}),
    user = erlang:error({required, user}),
    value_max = erlang:error({required, value_max}),
    value = erlang:error({required, value}),
    num = erlang:error({required, num}),
    list = []
}).
-endif.

-ifndef(RED_GET_INFO_PB_H).
-define(RED_GET_INFO_PB_H, true).
-record(red_get_info, {
    user = erlang:error({required, user}),
    value = erlang:error({required, value})
}).
-endif.

-ifndef(C2S22058_PB_H).
-define(C2S22058_PB_H, true).
-record(c2s22058, {
    
}).
-endif.

-ifndef(S2C22058_PB_H).
-define(S2C22058_PB_H, true).
-record(s2c22058, {
    list = []
}).
-endif.

-ifndef(P_GUILD_REDBAG_PB_H).
-define(P_GUILD_REDBAG_PB_H, true).
-record(p_guild_redbag, {
    user = erlang:error({required, user}),
    type = erlang:error({required, type}),
    list = []
}).
-endif.

-ifndef(S2C22059_PB_H).
-define(S2C22059_PB_H, true).
-record(s2c22059, {
    list = [],
    list2 = [],
    num = erlang:error({required, num})
}).
-endif.

-ifndef(P_REDBAG_NUM_PB_H).
-define(P_REDBAG_NUM_PB_H, true).
-record(p_redbag_num, {
    type = erlang:error({required, type}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S22060_PB_H).
-define(C2S22060_PB_H, true).
-record(c2s22060, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(C2S22061_PB_H).
-define(C2S22061_PB_H, true).
-record(c2s22061, {
    user_id = erlang:error({required, user_id}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C22061_PB_H).
-define(S2C22061_PB_H, true).
-record(s2c22061, {
    code = erlang:error({required, code})
}).
-endif.

-ifndef(C2S22062_PB_H).
-define(C2S22062_PB_H, true).
-record(c2s22062, {
    
}).
-endif.

-ifndef(C2S22063_PB_H).
-define(C2S22063_PB_H, true).
-record(c2s22063, {
    item_id_list = []
}).
-endif.

-ifndef(C2S22064_PB_H).
-define(C2S22064_PB_H, true).
-record(c2s22064, {
    tar_id = erlang:error({required, tar_id}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C22064_PB_H).
-define(S2C22064_PB_H, true).
-record(s2c22064, {
    type = erlang:error({required, type}),
    user = erlang:error({required, user})
}).
-endif.

-ifndef(C2S22065_PB_H).
-define(C2S22065_PB_H, true).
-record(c2s22065, {
    
}).
-endif.

-ifndef(S2C22065_PB_H).
-define(S2C22065_PB_H, true).
-record(s2c22065, {
    list = [],
    room_list = [],
    round = erlang:error({required, round}),
    win_guild_id = erlang:error({required, win_guild_id})
}).
-endif.

-ifndef(S2C22066_PB_H).
-define(S2C22066_PB_H, true).
-record(s2c22066, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(S2C22065_ROOM_PB_H).
-define(S2C22065_ROOM_PB_H, true).
-record(s2c22065_room, {
    room_index = erlang:error({required, room_index}),
    guild_id_1 = erlang:error({required, guild_id_1}),
    guild_id_2 = erlang:error({required, guild_id_2}),
    win_guild_id = erlang:error({required, win_guild_id}),
    round = erlang:error({required, round})
}).
-endif.

