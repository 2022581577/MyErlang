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

