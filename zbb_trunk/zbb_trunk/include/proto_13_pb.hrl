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

-ifndef(C2S13001_PB_H).
-define(C2S13001_PB_H, true).
-record(c2s13001, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no})
}).
-endif.

-ifndef(S2C13001_PB_H).
-define(S2C13001_PB_H, true).
-record(s2c13001, {
    user_id = erlang:error({required, user_id}),
    user_style = erlang:error({required, user_style}),
    battle_value = erlang:error({required, battle_value}),
    user_attr = erlang:error({required, user_attr}),
    item_list = [],
    grow_list = [],
    misc_list = [],
    flag_id = 0,
    flag_lv = 0
}).
-endif.

-ifndef(S2C13028_PB_H).
-define(S2C13028_PB_H, true).
-record(s2c13028, {
    server_no = erlang:error({required, server_no}),
    nick_name = erlang:error({required, nick_name}),
    career_id = erlang:error({required, career_id})
}).
-endif.

-ifndef(S2C13002_PB_H).
-define(S2C13002_PB_H, true).
-record(s2c13002, {
    event_type = erlang:error({required, event_type}),
    gold = erlang:error({required, gold}),
    bind_gold = erlang:error({required, bind_gold}),
    coin = erlang:error({required, coin}),
    bind_coin = erlang:error({required, bind_coin})
}).
-endif.

-ifndef(S2C13003_PB_H).
-define(S2C13003_PB_H, true).
-record(s2c13003, {
    event_type = erlang:error({required, event_type}),
    level = erlang:error({required, level}),
    exp = erlang:error({required, exp}),
    max_exp = erlang:error({required, max_exp}),
    reg_time = erlang:error({required, reg_time})
}).
-endif.

-ifndef(S2C13004_PB_H).
-define(S2C13004_PB_H, true).
-record(s2c13004, {
    event_type = erlang:error({required, event_type}),
    user_attr = erlang:error({required, user_attr}),
    battle_value = 0
}).
-endif.

-ifndef(S2C13005_PB_H).
-define(S2C13005_PB_H, true).
-record(s2c13005, {
    state = erlang:error({required, state}),
    online_time = erlang:error({required, online_time})
}).
-endif.

-ifndef(C2S13006_PB_H).
-define(C2S13006_PB_H, true).
-record(c2s13006, {
    card_id = erlang:error({required, card_id}),
    card_name = erlang:error({required, card_name})
}).
-endif.

-ifndef(S2C13006_PB_H).
-define(S2C13006_PB_H, true).
-record(s2c13006, {
    result = erlang:error({required, result}),
    state = erlang:error({required, state})
}).
-endif.

-ifndef(S2C13007_PB_H).
-define(S2C13007_PB_H, true).
-record(s2c13007, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C13008_PB_H).
-define(S2C13008_PB_H, true).
-record(s2c13008, {
    list = []
}).
-endif.

-ifndef(USER_MISC_STRUCT_PB_H).
-define(USER_MISC_STRUCT_PB_H, true).
-record(user_misc_struct, {
    key = 0,
    value = 0,
    value1 = 0,
    text = [],
    mtime = 0
}).
-endif.

-ifndef(S2C13009_PB_H).
-define(S2C13009_PB_H, true).
-record(s2c13009, {
    user_id = erlang:error({required, user_id}),
    user_style = erlang:error({required, user_style}),
    hp = erlang:error({required, hp}),
    max_hp = erlang:error({required, max_hp}),
    speed = erlang:error({required, speed})
}).
-endif.

-ifndef(C2S13010_PB_H).
-define(C2S13010_PB_H, true).
-record(c2s13010, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(C2S13011_PB_H).
-define(C2S13011_PB_H, true).
-record(c2s13011, {
    
}).
-endif.

-ifndef(S2C13011_PB_H).
-define(S2C13011_PB_H, true).
-record(s2c13011, {
    mp = erlang:error({required, mp}),
    physical = erlang:error({required, physical})
}).
-endif.

-ifndef(C2S13012_PB_H).
-define(C2S13012_PB_H, true).
-record(c2s13012, {
    pk_mode = erlang:error({required, pk_mode})
}).
-endif.

-ifndef(C2S13013_PB_H).
-define(C2S13013_PB_H, true).
-record(c2s13013, {
    list = []
}).
-endif.

-ifndef(CLIENT_DATA_PB_H).
-define(CLIENT_DATA_PB_H, true).
-record(client_data, {
    key = erlang:error({required, key}),
    value = erlang:error({required, value})
}).
-endif.

-ifndef(C2S13015_PB_H).
-define(C2S13015_PB_H, true).
-record(c2s13015, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(C2S13016_PB_H).
-define(C2S13016_PB_H, true).
-record(c2s13016, {
    
}).
-endif.

-ifndef(S2C13016_PB_H).
-define(S2C13016_PB_H, true).
-record(s2c13016, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S13017_PB_H).
-define(C2S13017_PB_H, true).
-record(c2s13017, {
    rank = erlang:error({required, rank})
}).
-endif.

-ifndef(S2C13018_PB_H).
-define(S2C13018_PB_H, true).
-record(s2c13018, {
    vip_level = erlang:error({required, vip_level}),
    vip_gold = erlang:error({required, vip_gold})
}).
-endif.

-ifndef(C2S13019_PB_H).
-define(C2S13019_PB_H, true).
-record(c2s13019, {
    user_id = erlang:error({required, user_id}),
    server_no = erlang:error({required, server_no})
}).
-endif.

-ifndef(S2C13019_PB_H).
-define(S2C13019_PB_H, true).
-record(s2c13019, {
    user_id = erlang:error({required, user_id}),
    user_style = erlang:error({required, user_style}),
    item_list = [],
    skill_list = [],
    misc_list = [],
    grow_list = [],
    vestment_list = [],
    flag_lv = 0
}).
-endif.

-ifndef(S2C13020_PB_H).
-define(S2C13020_PB_H, true).
-record(s2c13020, {
    infant_ctrl = erlang:error({required, infant_ctrl})
}).
-endif.

-ifndef(C2S13021_PB_H).
-define(C2S13021_PB_H, true).
-record(c2s13021, {
    type = erlang:error({required, type}),
    answer_list = []
}).
-endif.

-ifndef(C2S13022_PB_H).
-define(C2S13022_PB_H, true).
-record(c2s13022, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C13022_PB_H).
-define(S2C13022_PB_H, true).
-record(s2c13022, {
    type = erlang:error({required, type}),
    tpl_id = erlang:error({required, tpl_id}),
    num = erlang:error({required, num}),
    crit_times = erlang:error({required, crit_times})
}).
-endif.

-ifndef(C2S13023_PB_H).
-define(C2S13023_PB_H, true).
-record(c2s13023, {
    code = erlang:error({required, code})
}).
-endif.

-ifndef(S2C13023_PB_H).
-define(S2C13023_PB_H, true).
-record(s2c13023, {
    result = erlang:error({required, result}),
    list = []
}).
-endif.

-ifndef(C2S13024_PB_H).
-define(C2S13024_PB_H, true).
-record(c2s13024, {
    code = erlang:error({required, code})
}).
-endif.

-ifndef(S2C13024_PB_H).
-define(S2C13024_PB_H, true).
-record(s2c13024, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(S2C13025_PB_H).
-define(S2C13025_PB_H, true).
-record(s2c13025, {
    user_type = erlang:error({required, user_type})
}).
-endif.

-ifndef(S2C13026_PB_H).
-define(S2C13026_PB_H, true).
-record(s2c13026, {
    world_lv = erlang:error({required, world_lv})
}).
-endif.

-ifndef(C2S13027_PB_H).
-define(C2S13027_PB_H, true).
-record(c2s13027, {
    step = erlang:error({required, step})
}).
-endif.

-ifndef(C2S13100_PB_H).
-define(C2S13100_PB_H, true).
-record(c2s13100, {
    
}).
-endif.

-ifndef(S2C13100_PB_H).
-define(S2C13100_PB_H, true).
-record(s2c13100, {
    version_timestamp = 0,
    svn = 0
}).
-endif.

-ifndef(S2C13200_PB_H).
-define(S2C13200_PB_H, true).
-record(s2c13200, {
    change_list = [],
    del_list = []
}).
-endif.

-ifndef(TITLE_STRUCT_PB_H).
-define(TITLE_STRUCT_PB_H, true).
-record(title_struct, {
    title_tpl_id = erlang:error({required, title_tpl_id}),
    is_select = erlang:error({required, is_select}),
    end_time = erlang:error({required, end_time})
}).
-endif.

-ifndef(C2S13201_PB_H).
-define(C2S13201_PB_H, true).
-record(c2s13201, {
    title_tpl_id = erlang:error({required, title_tpl_id}),
    is_select = erlang:error({required, is_select})
}).
-endif.

-ifndef(C2S13202_PB_H).
-define(C2S13202_PB_H, true).
-record(c2s13202, {
    
}).
-endif.

-ifndef(S2C13202_PB_H).
-define(S2C13202_PB_H, true).
-record(s2c13202, {
    honor_level = erlang:error({required, honor_level})
}).
-endif.

-ifndef(C2S13203_PB_H).
-define(C2S13203_PB_H, true).
-record(c2s13203, {
    list = []
}).
-endif.

-ifndef(S2C13204_PB_H).
-define(S2C13204_PB_H, true).
-record(s2c13204, {
    mon_tpl_id = erlang:error({required, mon_tpl_id}),
    chest_value = erlang:error({required, chest_value}),
    list = [],
    is_crit = erlang:error({required, is_crit})
}).
-endif.

-ifndef(C2S13205_PB_H).
-define(C2S13205_PB_H, true).
-record(c2s13205, {
    
}).
-endif.

-ifndef(C2S13206_PB_H).
-define(C2S13206_PB_H, true).
-record(c2s13206, {
    
}).
-endif.

-ifndef(S2C13207_PB_H).
-define(S2C13207_PB_H, true).
-record(s2c13207, {
    title_tpl_id = erlang:error({required, title_tpl_id})
}).
-endif.

-ifndef(C2S13208_PB_H).
-define(C2S13208_PB_H, true).
-record(c2s13208, {
    user_id = erlang:error({required, user_id})
}).
-endif.

-ifndef(S2C13208_PB_H).
-define(S2C13208_PB_H, true).
-record(s2c13208, {
    info = erlang:error({required, info})
}).
-endif.

-ifndef(C2S13209_PB_H).
-define(C2S13209_PB_H, true).
-record(c2s13209, {
    lv = erlang:error({required, lv})
}).
-endif.

-ifndef(C2S13210_PB_H).
-define(C2S13210_PB_H, true).
-record(c2s13210, {
    target_type = erlang:error({required, target_type})
}).
-endif.

-ifndef(C2S13211_PB_H).
-define(C2S13211_PB_H, true).
-record(c2s13211, {
    medal_level = erlang:error({required, medal_level})
}).
-endif.

-ifndef(C2S13212_PB_H).
-define(C2S13212_PB_H, true).
-record(c2s13212, {
    
}).
-endif.

-ifndef(C2S13213_PB_H).
-define(C2S13213_PB_H, true).
-record(c2s13213, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(C2S13214_PB_H).
-define(C2S13214_PB_H, true).
-record(c2s13214, {
    
}).
-endif.

-ifndef(S2C13214_PB_H).
-define(S2C13214_PB_H, true).
-record(s2c13214, {
    
}).
-endif.

-ifndef(C2S13215_PB_H).
-define(C2S13215_PB_H, true).
-record(c2s13215, {
    
}).
-endif.

-ifndef(C2S13216_PB_H).
-define(C2S13216_PB_H, true).
-record(c2s13216, {
    
}).
-endif.

-ifndef(C2S13300_PB_H).
-define(C2S13300_PB_H, true).
-record(c2s13300, {
    
}).
-endif.

-ifndef(S2C13300_PB_H).
-define(S2C13300_PB_H, true).
-record(s2c13300, {
    platform_index = erlang:error({required, platform_index}),
    is_vip = erlang:error({required, is_vip}),
    type = 0,
    gift = []
}).
-endif.

-ifndef(C2S13301_PB_H).
-define(C2S13301_PB_H, true).
-record(c2s13301, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(S2C13302_PB_H).
-define(S2C13302_PB_H, true).
-record(s2c13302, {
    is_yellow = 0,
    is_year_yellow = 0,
    yellow_level = 0,
    is_high_yellow = 0,
    new_gift = 0,
    level_list = [],
    day_list = []
}).
-endif.

-ifndef(C2S13303_PB_H).
-define(C2S13303_PB_H, true).
-record(c2s13303, {
    gift_type = erlang:error({required, gift_type}),
    gift_level = 0
}).
-endif.

-ifndef(C2S13304_PB_H).
-define(C2S13304_PB_H, true).
-record(c2s13304, {
    id = erlang:error({required, id}),
    item_url = erlang:error({required, item_url})
}).
-endif.

-ifndef(S2C13304_PB_H).
-define(S2C13304_PB_H, true).
-record(s2c13304, {
    ret = erlang:error({required, ret}),
    msg = erlang:error({required, msg}),
    url_params = erlang:error({required, url_params})
}).
-endif.

-ifndef(S2C13305_PB_H).
-define(S2C13305_PB_H, true).
-record(s2c13305, {
    mon_name = erlang:error({required, mon_name}),
    list = [],
    time = erlang:error({required, time}),
    type = erlang:error({required, type}),
    sub_type = erlang:error({required, sub_type}),
    mon_tpl_id = erlang:error({required, mon_tpl_id}),
    exp_ratio = erlang:error({required, exp_ratio})
}).
-endif.

-ifndef(C2S13306_PB_H).
-define(C2S13306_PB_H, true).
-record(c2s13306, {
    
}).
-endif.

