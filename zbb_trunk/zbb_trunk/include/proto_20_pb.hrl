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

-ifndef(C2S20001_PB_H).
-define(C2S20001_PB_H, true).
-record(c2s20001, {
    dup_tpl_id = erlang:error({required, dup_tpl_id})
}).
-endif.

-ifndef(S2C20001_PB_H).
-define(S2C20001_PB_H, true).
-record(s2c20001, {
    result = erlang:error({required, result}),
    dup_tpl_id = erlang:error({required, dup_tpl_id})
}).
-endif.

-ifndef(C2S20002_PB_H).
-define(C2S20002_PB_H, true).
-record(c2s20002, {
    
}).
-endif.

-ifndef(S2C20002_PB_H).
-define(S2C20002_PB_H, true).
-record(s2c20002, {
    result = erlang:error({required, result}),
    dup_tpl_id = erlang:error({required, dup_tpl_id})
}).
-endif.

-ifndef(S2C20003_PB_H).
-define(S2C20003_PB_H, true).
-record(s2c20003, {
    mon_wave = erlang:error({required, mon_wave}),
    next_wave_count_down = 0,
    dup_count_down = 0
}).
-endif.

-ifndef(S2C20004_PB_H).
-define(S2C20004_PB_H, true).
-record(s2c20004, {
    result = erlang:error({required, result}),
    star = 0,
    bind_coin = 0,
    coin = 0,
    exp = 0,
    list = [],
    run_time = erlang:error({required, run_time})
}).
-endif.

-ifndef(C2S20006_PB_H).
-define(C2S20006_PB_H, true).
-record(c2s20006, {
    
}).
-endif.

-ifndef(S2C20006_PB_H).
-define(S2C20006_PB_H, true).
-record(s2c20006, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(S2C20007_PB_H).
-define(S2C20007_PB_H, true).
-record(s2c20007, {
    total_coin = erlang:error({required, total_coin}),
    multiple = erlang:error({required, multiple})
}).
-endif.

-ifndef(C2S20008_PB_H).
-define(C2S20008_PB_H, true).
-record(c2s20008, {
    
}).
-endif.

-ifndef(C2S20009_PB_H).
-define(C2S20009_PB_H, true).
-record(c2s20009, {
    rank = erlang:error({required, rank})
}).
-endif.

-ifndef(S2C20010_PB_H).
-define(S2C20010_PB_H, true).
-record(s2c20010, {
    total_exp = erlang:error({required, total_exp}),
    default_list = [],
    drop_list = [],
    tower_list = [],
    list = [],
    list1 = [],
    wave = 0
}).
-endif.

-ifndef(C2S20011_PB_H).
-define(C2S20011_PB_H, true).
-record(c2s20011, {
    drop_skill_id = erlang:error({required, drop_skill_id})
}).
-endif.

-ifndef(C2S20012_PB_H).
-define(C2S20012_PB_H, true).
-record(c2s20012, {
    mon_inst_id = erlang:error({required, mon_inst_id}),
    mon_tpl_id = erlang:error({required, mon_tpl_id}),
    target_mon_tpl_id = erlang:error({required, target_mon_tpl_id})
}).
-endif.

-ifndef(S2C20012_PB_H).
-define(S2C20012_PB_H, true).
-record(s2c20012, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(S2C20014_PB_H).
-define(S2C20014_PB_H, true).
-record(s2c20014, {
    hp = erlang:error({required, hp})
}).
-endif.

-ifndef(DUP_SKILL_TOWER_PB_H).
-define(DUP_SKILL_TOWER_PB_H, true).
-record(dup_skill_tower, {
    mon_inst_id = erlang:error({required, mon_inst_id}),
    seq = erlang:error({required, seq}),
    mon_tpl_id = erlang:error({required, mon_tpl_id})
}).
-endif.

-ifndef(S2C20015_PB_H).
-define(S2C20015_PB_H, true).
-record(s2c20015, {
    total_soul = erlang:error({required, total_soul}),
    total_coin = erlang:error({required, total_coin})
}).
-endif.

-ifndef(C2S20016_PB_H).
-define(C2S20016_PB_H, true).
-record(c2s20016, {
    rank = erlang:error({required, rank})
}).
-endif.

-ifndef(C2S20017_PB_H).
-define(C2S20017_PB_H, true).
-record(c2s20017, {
    
}).
-endif.

-ifndef(C2S20018_PB_H).
-define(C2S20018_PB_H, true).
-record(c2s20018, {
    dup_tpl_id = erlang:error({required, dup_tpl_id})
}).
-endif.

-ifndef(S2C20019_PB_H).
-define(S2C20019_PB_H, true).
-record(s2c20019, {
    list = []
}).
-endif.

-ifndef(MON_TARGET_PB_H).
-define(MON_TARGET_PB_H, true).
-record(mon_target, {
    mon_tpl_id = erlang:error({required, mon_tpl_id}),
    target_count = erlang:error({required, target_count}),
    current_count = erlang:error({required, current_count}),
    wave = erlang:error({required, wave})
}).
-endif.

-ifndef(C2S20020_PB_H).
-define(C2S20020_PB_H, true).
-record(c2s20020, {
    multiple = erlang:error({required, multiple})
}).
-endif.

-ifndef(C2S20021_PB_H).
-define(C2S20021_PB_H, true).
-record(c2s20021, {
    chapter_id = erlang:error({required, chapter_id}),
    rank = erlang:error({required, rank})
}).
-endif.

-ifndef(S2C20023_PB_H).
-define(S2C20023_PB_H, true).
-record(s2c20023, {
    revive_num = 0
}).
-endif.

-ifndef(C2S20024_PB_H).
-define(C2S20024_PB_H, true).
-record(c2s20024, {
    
}).
-endif.

-ifndef(C2S20025_PB_H).
-define(C2S20025_PB_H, true).
-record(c2s20025, {
    
}).
-endif.

-ifndef(S2C20025_PB_H).
-define(S2C20025_PB_H, true).
-record(s2c20025, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S20026_PB_H).
-define(C2S20026_PB_H, true).
-record(c2s20026, {
    dup_id = erlang:error({required, dup_id}),
    limit_battle_value = erlang:error({required, limit_battle_value}),
    full_auto_start = erlang:error({required, full_auto_start}),
    pwd = erlang:error({required, pwd})
}).
-endif.

-ifndef(S2C20026_PB_H).
-define(S2C20026_PB_H, true).
-record(s2c20026, {
    result = erlang:error({required, result}),
    room_id = erlang:error({required, room_id})
}).
-endif.

-ifndef(C2S20027_PB_H).
-define(C2S20027_PB_H, true).
-record(c2s20027, {
    room_id = erlang:error({required, room_id})
}).
-endif.

-ifndef(S2C20027_PB_H).
-define(S2C20027_PB_H, true).
-record(s2c20027, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S20028_PB_H).
-define(C2S20028_PB_H, true).
-record(c2s20028, {
    
}).
-endif.

-ifndef(S2C20028_PB_H).
-define(S2C20028_PB_H, true).
-record(s2c20028, {
    result = erlang:error({required, result}),
    reason = erlang:error({required, reason})
}).
-endif.

-ifndef(C2S20029_PB_H).
-define(C2S20029_PB_H, true).
-record(c2s20029, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C20030_PB_H).
-define(S2C20030_PB_H, true).
-record(s2c20030, {
    list = []
}).
-endif.

-ifndef(S2C20031_PB_H).
-define(S2C20031_PB_H, true).
-record(s2c20031, {
    room = erlang:error({required, room}),
    list = []
}).
-endif.

-ifndef(S2C20032_PB_H).
-define(S2C20032_PB_H, true).
-record(s2c20032, {
    room_id = erlang:error({required, room_id})
}).
-endif.

-ifndef(P_DUP_ROOM_PB_H).
-define(P_DUP_ROOM_PB_H, true).
-record(p_dup_room, {
    room_id = erlang:error({required, room_id}),
    dup_id = erlang:error({required, dup_id}),
    limit_battle_value = erlang:error({required, limit_battle_value}),
    full_auto_start = erlang:error({required, full_auto_start}),
    pwd = [],
    user_num = erlang:error({required, user_num}),
    leader = erlang:error({required, leader})
}).
-endif.

-ifndef(P_DUP_ROOM_USER_PB_H).
-define(P_DUP_ROOM_USER_PB_H, true).
-record(p_dup_room_user, {
    user_id = erlang:error({required, user_id}),
    nick_name = erlang:error({required, nick_name}),
    career_id = erlang:error({required, career_id}),
    level = erlang:error({required, level}),
    battle_value = erlang:error({required, battle_value}),
    is_ready = erlang:error({required, is_ready}),
    vip_level = erlang:error({required, vip_level}),
    server_no = erlang:error({required, server_no})
}).
-endif.

-ifndef(C2S20033_PB_H).
-define(C2S20033_PB_H, true).
-record(c2s20033, {
    dup_tpl_id = erlang:error({required, dup_tpl_id})
}).
-endif.

-ifndef(S2C20034_PB_H).
-define(S2C20034_PB_H, true).
-record(s2c20034, {
    total_exp = erlang:error({required, total_exp}),
    coin_count = erlang:error({required, coin_count}),
    gold_count = erlang:error({required, gold_count}),
    list = [],
    user_count = erlang:error({required, user_count}),
    avg_level = erlang:error({required, avg_level})
}).
-endif.

-ifndef(C2S20035_PB_H).
-define(C2S20035_PB_H, true).
-record(c2s20035, {
    
}).
-endif.

-ifndef(C2S20036_PB_H).
-define(C2S20036_PB_H, true).
-record(c2s20036, {
    target_user_id = erlang:error({required, target_user_id})
}).
-endif.

-ifndef(C2S20037_PB_H).
-define(C2S20037_PB_H, true).
-record(c2s20037, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C20037_PB_H).
-define(S2C20037_PB_H, true).
-record(s2c20037, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S20043_PB_H).
-define(C2S20043_PB_H, true).
-record(c2s20043, {
    
}).
-endif.

-ifndef(C2S20044_PB_H).
-define(C2S20044_PB_H, true).
-record(c2s20044, {
    mon_inst_id = erlang:error({required, mon_inst_id}),
    mon_tpl_id = erlang:error({required, mon_tpl_id})
}).
-endif.

-ifndef(S2C20044_PB_H).
-define(S2C20044_PB_H, true).
-record(s2c20044, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(S2C20046_PB_H).
-define(S2C20046_PB_H, true).
-record(s2c20046, {
    default_list = [],
    drop_list = [],
    cd_list = []
}).
-endif.

-ifndef(S2C20047_PB_H).
-define(S2C20047_PB_H, true).
-record(s2c20047, {
    
}).
-endif.

-ifndef(C2S20048_PB_H).
-define(C2S20048_PB_H, true).
-record(c2s20048, {
    dup_tpl_id = erlang:error({required, dup_tpl_id}),
    auto_num = erlang:error({required, auto_num})
}).
-endif.

-ifndef(C2S20049_PB_H).
-define(C2S20049_PB_H, true).
-record(c2s20049, {
    
}).
-endif.

-ifndef(C2S20050_PB_H).
-define(C2S20050_PB_H, true).
-record(c2s20050, {
    
}).
-endif.

-ifndef(C2S20051_PB_H).
-define(C2S20051_PB_H, true).
-record(c2s20051, {
    
}).
-endif.

-ifndef(C2S20052_PB_H).
-define(C2S20052_PB_H, true).
-record(c2s20052, {
    limit_battle_value = erlang:error({required, limit_battle_value}),
    full_auto_start = erlang:error({required, full_auto_start})
}).
-endif.

-ifndef(C2S20053_PB_H).
-define(C2S20053_PB_H, true).
-record(c2s20053, {
    
}).
-endif.

-ifndef(C2S20054_PB_H).
-define(C2S20054_PB_H, true).
-record(c2s20054, {
    
}).
-endif.

-ifndef(C2S20055_PB_H).
-define(C2S20055_PB_H, true).
-record(c2s20055, {
    dup_tpl_id = erlang:error({required, dup_tpl_id})
}).
-endif.

-ifndef(C2S20056_PB_H).
-define(C2S20056_PB_H, true).
-record(c2s20056, {
    
}).
-endif.

-ifndef(S2C20056_PB_H).
-define(S2C20056_PB_H, true).
-record(s2c20056, {
    list = []
}).
-endif.

-ifndef(C2S20057_PB_H).
-define(C2S20057_PB_H, true).
-record(c2s20057, {
    
}).
-endif.

-ifndef(C2S20058_PB_H).
-define(C2S20058_PB_H, true).
-record(c2s20058, {
    
}).
-endif.

-ifndef(C2S20059_PB_H).
-define(C2S20059_PB_H, true).
-record(c2s20059, {
    
}).
-endif.

-ifndef(C2S20060_PB_H).
-define(C2S20060_PB_H, true).
-record(c2s20060, {
    
}).
-endif.

-ifndef(S2C20060_PB_H).
-define(S2C20060_PB_H, true).
-record(s2c20060, {
    list = []
}).
-endif.

-ifndef(S2C20061_PB_H).
-define(S2C20061_PB_H, true).
-record(s2c20061, {
    
}).
-endif.

-ifndef(S2C20034_MON_COUNT_PB_H).
-define(S2C20034_MON_COUNT_PB_H, true).
-record(s2c20034_mon_count, {
    type = erlang:error({required, type}),
    count = erlang:error({required, count})
}).
-endif.

-ifndef(S2C20046_DUP_SKILL_CD_PB_H).
-define(S2C20046_DUP_SKILL_CD_PB_H, true).
-record(s2c20046_dup_skill_cd, {
    skill_id = erlang:error({required, skill_id}),
    skill_time = erlang:error({required, skill_time})
}).
-endif.

-ifndef(S2C20056_DUP_VESTMENT_LOG_PB_H).
-define(S2C20056_DUP_VESTMENT_LOG_PB_H, true).
-record(s2c20056_dup_vestment_log, {
    dup_tpl_id = erlang:error({required, dup_tpl_id}),
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no}),
    nick_name = erlang:error({required, nick_name}),
    pass_time = erlang:error({required, pass_time}),
    battle_value = erlang:error({required, battle_value})
}).
-endif.

