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

-ifndef(S2C25000_PB_H).
-define(S2C25000_PB_H, true).
-record(s2c25000, {
    activity_list = [],
    open_time = erlang:error({required, open_time})
}).
-endif.

-ifndef(S2C25001_PB_H).
-define(S2C25001_PB_H, true).
-record(s2c25001, {
    boss_list = []
}).
-endif.

-ifndef(S2C25002_PB_H).
-define(S2C25002_PB_H, true).
-record(s2c25002, {
    id = erlang:error({required, id}),
    belong_guild_id = erlang:error({required, belong_guild_id}),
    belong_guild_name = erlang:error({required, belong_guild_name}),
    belong_user_id = erlang:error({required, belong_user_id}),
    own_rank = erlang:error({required, own_rank}),
    boss_left_hp = erlang:error({required, boss_left_hp}),
    boss_total_hp = erlang:error({required, boss_total_hp}),
    rank_list = []
}).
-endif.

-ifndef(C2S25010_PB_H).
-define(C2S25010_PB_H, true).
-record(c2s25010, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C25010_PB_H).
-define(S2C25010_PB_H, true).
-record(s2c25010, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(S2C25011_PB_H).
-define(S2C25011_PB_H, true).
-record(s2c25011, {
    banner = erlang:error({required, banner}),
    banner_user_id = erlang:error({required, banner_user_id}),
    banner_x = erlang:error({required, banner_x}),
    banner_y = erlang:error({required, banner_y}),
    left_refresh_box_time = erlang:error({required, left_refresh_box_time}),
    left_time = erlang:error({required, left_time}),
    camp_list = [],
    user_list = [],
    post_list = []
}).
-endif.

-ifndef(CAMP_POINT_PB_H).
-define(CAMP_POINT_PB_H, true).
-record(camp_point, {
    camp_id = erlang:error({required, camp_id}),
    post_num = erlang:error({required, post_num}),
    occupy_point = erlang:error({required, occupy_point}),
    point = erlang:error({required, point}),
    banner_num = erlang:error({required, banner_num}),
    user_num = erlang:error({required, user_num})
}).
-endif.

-ifndef(USER_POINT_PB_H).
-define(USER_POINT_PB_H, true).
-record(user_point, {
    user_id = erlang:error({required, user_id}),
    user_name = erlang:error({required, user_name}),
    camp_id = erlang:error({required, camp_id}),
    point = erlang:error({required, point}),
    soul = erlang:error({required, soul}),
    kill_num = erlang:error({required, kill_num}),
    banner_num = erlang:error({required, banner_num}),
    level = erlang:error({required, level}),
    help_kill = erlang:error({required, help_kill}),
    dead_num = erlang:error({required, dead_num}),
    last_hit_num = erlang:error({required, last_hit_num}),
    server_no = erlang:error({required, server_no}),
    con_kill_num = erlang:error({required, con_kill_num})
}).
-endif.

-ifndef(POST_INFO_PB_H).
-define(POST_INFO_PB_H, true).
-record(post_info, {
    pos_x = erlang:error({required, pos_x}),
    pos_y = erlang:error({required, pos_y}),
    camp = erlang:error({required, camp})
}).
-endif.

-ifndef(S2C25020_PB_H).
-define(S2C25020_PB_H, true).
-record(s2c25020, {
    type = erlang:error({required, type}),
    domain_list = []
}).
-endif.

-ifndef(S2C25021_PB_H).
-define(S2C25021_PB_H, true).
-record(s2c25021, {
    id = erlang:error({required, id}),
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    occupy_time = erlang:error({required, occupy_time}),
    left_occupy_time = erlang:error({required, left_occupy_time}),
    left_time = erlang:error({required, left_time})
}).
-endif.

-ifndef(C2S25022_PB_H).
-define(C2S25022_PB_H, true).
-record(c2s25022, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C25023_PB_H).
-define(S2C25023_PB_H, true).
-record(s2c25023, {
    rank_list = []
}).
-endif.

-ifndef(S2C25024_PB_H).
-define(S2C25024_PB_H, true).
-record(s2c25024, {
    rank_list = []
}).
-endif.

-ifndef(S2C25025_PB_H).
-define(S2C25025_PB_H, true).
-record(s2c25025, {
    rank_list = []
}).
-endif.

-ifndef(S2C25026_PB_H).
-define(S2C25026_PB_H, true).
-record(s2c25026, {
    add_exp = erlang:error({required, add_exp}),
    point = erlang:error({required, point})
}).
-endif.

-ifndef(DOMAIN_INFO_PB_H).
-define(DOMAIN_INFO_PB_H, true).
-record(domain_info, {
    id = erlang:error({required, id}),
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    occupy_time = erlang:error({required, occupy_time}),
    guild_flag_id = erlang:error({required, guild_flag_id}),
    last_occupy_time = 0
}).
-endif.

-ifndef(DOMAIN_GUILD_PB_H).
-define(DOMAIN_GUILD_PB_H, true).
-record(domain_guild, {
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    user_num = erlang:error({required, user_num}),
    domain_num = erlang:error({required, domain_num})
}).
-endif.

-ifndef(DOMAIN_USER_PB_H).
-define(DOMAIN_USER_PB_H, true).
-record(domain_user, {
    user_id = erlang:error({required, user_id}),
    user_name = erlang:error({required, user_name}),
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    kill_num = erlang:error({required, kill_num}),
    point = erlang:error({required, point}),
    level = erlang:error({required, level}),
    battle_value = erlang:error({required, battle_value}),
    server_no = erlang:error({required, server_no})
}).
-endif.

-ifndef(DOMAIN_MSG_PB_H).
-define(DOMAIN_MSG_PB_H, true).
-record(domain_msg, {
    msg_id = erlang:error({required, msg_id}),
    msg_time = erlang:error({required, msg_time}),
    list = []
}).
-endif.

-ifndef(C2S25027_PB_H).
-define(C2S25027_PB_H, true).
-record(c2s25027, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(S2C25030_PB_H).
-define(S2C25030_PB_H, true).
-record(s2c25030, {
    state = erlang:error({required, state}),
    state_end_time = erlang:error({required, state_end_time}),
    sub_state = erlang:error({required, sub_state}),
    round = erlang:error({required, round}),
    round_no = erlang:error({required, round_no})
}).
-endif.

-ifndef(S2C25031_PB_H).
-define(S2C25031_PB_H, true).
-record(s2c25031, {
    point = erlang:error({required, point}),
    exp = erlang:error({required, exp}),
    exploit = erlang:error({required, exploit}),
    identity = erlang:error({required, identity})
}).
-endif.

-ifndef(S2C25032_PB_H).
-define(S2C25032_PB_H, true).
-record(s2c25032, {
    type = erlang:error({required, type}),
    list = [],
    left_time = erlang:error({required, left_time})
}).
-endif.

-ifndef(PVN_USER_INFO_PB_H).
-define(PVN_USER_INFO_PB_H, true).
-record(pvn_user_info, {
    user_id = erlang:error({required, user_id}),
    user_name = erlang:error({required, user_name}),
    server_no = erlang:error({required, server_no}),
    level = erlang:error({required, level}),
    battle_value = erlang:error({required, battle_value})
}).
-endif.

-ifndef(S2C25033_PB_H).
-define(S2C25033_PB_H, true).
-record(s2c25033, {
    user_id = erlang:error({required, user_id}),
    type = erlang:error({required, type}),
    result = erlang:error({required, result}),
    point = [],
    exp = erlang:error({required, exp}),
    exploit = erlang:error({required, exploit})
}).
-endif.

-ifndef(S2C25034_PB_H).
-define(S2C25034_PB_H, true).
-record(s2c25034, {
    round = erlang:error({required, round}),
    round_no = erlang:error({required, round_no}),
    list = [],
    state = erlang:error({required, state}),
    state_end_time = erlang:error({required, state_end_time})
}).
-endif.

-ifndef(C2S25035_PB_H).
-define(C2S25035_PB_H, true).
-record(c2s25035, {
    user_id = erlang:error({required, user_id}),
    result = erlang:error({required, result})
}).
-endif.

-ifndef(S2C25035_PB_H).
-define(S2C25035_PB_H, true).
-record(s2c25035, {
    
}).
-endif.

-ifndef(C2S25036_PB_H).
-define(C2S25036_PB_H, true).
-record(c2s25036, {
    coin = erlang:error({required, coin}),
    exp = erlang:error({required, exp}),
    exploit = erlang:error({required, exploit}),
    gift_id = erlang:error({required, gift_id})
}).
-endif.

-ifndef(C2S25037_PB_H).
-define(C2S25037_PB_H, true).
-record(c2s25037, {
    user_id = erlang:error({required, user_id})
}).
-endif.

-ifndef(S2C25038_PB_H).
-define(S2C25038_PB_H, true).
-record(s2c25038, {
    list = []
}).
-endif.

-ifndef(S2C25039_PB_H).
-define(S2C25039_PB_H, true).
-record(s2c25039, {
    list = []
}).
-endif.

-ifndef(S2C25100_PB_H).
-define(S2C25100_PB_H, true).
-record(s2c25100, {
    id = erlang:error({required, id}),
    type = erlang:error({required, type}),
    progress = erlang:error({required, progress})
}).
-endif.

-ifndef(C2S25101_PB_H).
-define(C2S25101_PB_H, true).
-record(c2s25101, {
    
}).
-endif.

-ifndef(C2S25201_PB_H).
-define(C2S25201_PB_H, true).
-record(c2s25201, {
    
}).
-endif.

-ifndef(S2C25202_PB_H).
-define(S2C25202_PB_H, true).
-record(s2c25202, {
    state = erlang:error({required, state}),
    boss_dead = erlang:error({required, boss_dead}),
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    user_name = erlang:error({required, user_name}),
    state_end_time = erlang:error({required, state_end_time})
}).
-endif.

-ifndef(C2S25301_PB_H).
-define(C2S25301_PB_H, true).
-record(c2s25301, {
    
}).
-endif.

-ifndef(S2C25301_PB_H).
-define(S2C25301_PB_H, true).
-record(s2c25301, {
    total_num = erlang:error({required, total_num}),
    left_num = erlang:error({required, left_num}),
    end_time = erlang:error({required, end_time}),
    state = erlang:error({required, state}),
    user_list = [],
    destroy_list = [],
    destroy_time = erlang:error({required, destroy_time}),
    destroyed_list = []
}).
-endif.

-ifndef(S2C25302_PB_H).
-define(S2C25302_PB_H, true).
-record(s2c25302, {
    left_revive_num = erlang:error({required, left_revive_num}),
    award_num = erlang:error({required, award_num}),
    award_list = []
}).
-endif.

-ifndef(S2C25401_PB_H).
-define(S2C25401_PB_H, true).
-record(s2c25401, {
    end_time = erlang:error({required, end_time}),
    state = erlang:error({required, state}),
    user_list = [],
    own_user_id = 0,
    pos_x = 0,
    pos_y = 0,
    next_refresh_time = 0
}).
-endif.

-ifndef(S2C25501_PB_H).
-define(S2C25501_PB_H, true).
-record(s2c25501, {
    end_time = erlang:error({required, end_time}),
    state = erlang:error({required, state}),
    wave = erlang:error({required, wave}),
    user_list = []
}).
-endif.

-ifndef(C2S25502_PB_H).
-define(C2S25502_PB_H, true).
-record(c2s25502, {
    
}).
-endif.

-ifndef(S2C25502_PB_H).
-define(S2C25502_PB_H, true).
-record(s2c25502, {
    item_tpl_id = erlang:error({required, item_tpl_id}),
    item_num = erlang:error({required, item_num})
}).
-endif.

-ifndef(S2C25102_PB_H).
-define(S2C25102_PB_H, true).
-record(s2c25102, {
    list = [],
    state = erlang:error({required, state}),
    end_time = erlang:error({required, end_time})
}).
-endif.

-ifndef(P_GOD_BOSS_PB_H).
-define(P_GOD_BOSS_PB_H, true).
-record(p_god_boss, {
    mon_tpl_id = erlang:error({required, mon_tpl_id}),
    mon_hp = erlang:error({required, mon_hp}),
    mon_max_hp = erlang:error({required, mon_max_hp}),
    list = [],
    killer_id = erlang:error({required, killer_id})
}).
-endif.

-ifndef(P_GOD_BOSS_HARM_PB_H).
-define(P_GOD_BOSS_HARM_PB_H, true).
-record(p_god_boss_harm, {
    user_id = erlang:error({required, user_id}),
    user_name = erlang:error({required, user_name}),
    harm = erlang:error({required, harm}),
    server_no = erlang:error({required, server_no})
}).
-endif.

-ifndef(S2C25601_PB_H).
-define(S2C25601_PB_H, true).
-record(s2c25601, {
    guild_1 = erlang:error({required, guild_1}),
    guild_2 = erlang:error({required, guild_2}),
    state = erlang:error({required, state}),
    state_end_time = erlang:error({required, state_end_time}),
    user_list = [],
    post_list = [],
    win_guild_id = erlang:error({required, win_guild_id})
}).
-endif.

-ifndef(GUILD_POST_INFO_PB_H).
-define(GUILD_POST_INFO_PB_H, true).
-record(guild_post_info, {
    pos_x = erlang:error({required, pos_x}),
    pos_y = erlang:error({required, pos_y}),
    guild_id = erlang:error({required, guild_id}),
    time = erlang:error({required, time})
}).
-endif.

-ifndef(S2C25602_PB_H).
-define(S2C25602_PB_H, true).
-record(s2c25602, {
    
}).
-endif.

-ifndef(S2C25000_ACTIVITY_INFO_PB_H).
-define(S2C25000_ACTIVITY_INFO_PB_H, true).
-record(s2c25000_activity_info, {
    type = erlang:error({required, type}),
    state = erlang:error({required, state}),
    start_time = erlang:error({required, start_time}),
    end_time = erlang:error({required, end_time}),
    param_list = []
}).
-endif.

-ifndef(S2C25001_BOSS_INFO_PB_H).
-define(S2C25001_BOSS_INFO_PB_H, true).
-record(s2c25001_boss_info, {
    id = erlang:error({required, id}),
    state = erlang:error({required, state}),
    hour = erlang:error({required, hour}),
    min = erlang:error({required, min}),
    last_kill_id = erlang:error({required, last_kill_id}),
    last_kill_name = erlang:error({required, last_kill_name}),
    next_refresh_time = erlang:error({required, next_refresh_time}),
    last_kill_server_no = erlang:error({required, last_kill_server_no})
}).
-endif.

-ifndef(S2C25002_RANK_INFO_PB_H).
-define(S2C25002_RANK_INFO_PB_H, true).
-record(s2c25002_rank_info, {
    rank = erlang:error({required, rank}),
    user_id = erlang:error({required, user_id}),
    user_name = erlang:error({required, user_name}),
    hurt = erlang:error({required, hurt}),
    server_no = erlang:error({required, server_no})
}).
-endif.

-ifndef(DOMAIN_MSG_ARGS_PB_H).
-define(DOMAIN_MSG_ARGS_PB_H, true).
-record(domain_msg_args, {
    arg_type = erlang:error({required, arg_type}),
    arg_int = erlang:error({required, arg_int}),
    arg_string = erlang:error({required, arg_string})
}).
-endif.

-ifndef(S2C25034_BET_INFO_PB_H).
-define(S2C25034_BET_INFO_PB_H, true).
-record(s2c25034_bet_info, {
    user_id = erlang:error({required, user_id}),
    list = [],
    result = erlang:error({required, result})
}).
-endif.

-ifndef(S2C25038_PVP_USER_RANK_PB_H).
-define(S2C25038_PVP_USER_RANK_PB_H, true).
-record(s2c25038_pvp_user_rank, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    user_name = erlang:error({required, user_name}),
    level = erlang:error({required, level}),
    battle_value = erlang:error({required, battle_value}),
    point = erlang:error({required, point}),
    identity = erlang:error({required, identity})
}).
-endif.

-ifndef(S2C25039_PVN_USER_RANK_PB_H).
-define(S2C25039_PVN_USER_RANK_PB_H, true).
-record(s2c25039_pvn_user_rank, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    user_name = erlang:error({required, user_name}),
    level = erlang:error({required, level}),
    battle_value = erlang:error({required, battle_value}),
    round = erlang:error({required, round}),
    result = erlang:error({required, result}),
    time = erlang:error({required, time}),
    gift_id = erlang:error({required, gift_id})
}).
-endif.

-ifndef(S2C25301_USER_BLOOD_PB_H).
-define(S2C25301_USER_BLOOD_PB_H, true).
-record(s2c25301_user_blood, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    user_name = erlang:error({required, user_name}),
    kill_num = erlang:error({required, kill_num}),
    help_num = erlang:error({required, help_num}),
    point = erlang:error({required, point}),
    left_revive_num = erlang:error({required, left_revive_num})
}).
-endif.

-ifndef(S2C25302_AWARD_PB_H).
-define(S2C25302_AWARD_PB_H, true).
-record(s2c25302_award, {
    award_id = erlang:error({required, award_id}),
    award_num = erlang:error({required, award_num})
}).
-endif.

-ifndef(S2C25401_USER_RAID_PB_H).
-define(S2C25401_USER_RAID_PB_H, true).
-record(s2c25401_user_raid, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    user_name = erlang:error({required, user_name}),
    extrem_num = erlang:error({required, extrem_num}),
    gold_num = erlang:error({required, gold_num}),
    point = erlang:error({required, point})
}).
-endif.

-ifndef(S2C25501_USER_SIEGE_PB_H).
-define(S2C25501_USER_SIEGE_PB_H, true).
-record(s2c25501_user_siege, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    user_name = erlang:error({required, user_name}),
    point = erlang:error({required, point})
}).
-endif.

-ifndef(S2C25601_USER_INFO_PB_H).
-define(S2C25601_USER_INFO_PB_H, true).
-record(s2c25601_user_info, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    user_name = erlang:error({required, user_name}),
    kill_num = erlang:error({required, kill_num}),
    add_honor = erlang:error({required, add_honor}),
    help_num = erlang:error({required, help_num}),
    dead_num = erlang:error({required, dead_num}),
    guild_id = erlang:error({required, guild_id}),
    point = erlang:error({required, point})
}).
-endif.

-ifndef(S2C25601_GUILD_INFO_PB_H).
-define(S2C25601_GUILD_INFO_PB_H, true).
-record(s2c25601_guild_info, {
    guild_id = erlang:error({required, guild_id}),
    guild_name = erlang:error({required, guild_name}),
    resource_point = erlang:error({required, resource_point}),
    battle_value = erlang:error({required, battle_value})
}).
-endif.

