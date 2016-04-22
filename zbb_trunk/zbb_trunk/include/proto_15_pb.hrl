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

-ifndef(S2C15000_PB_H).
-define(S2C15000_PB_H, true).
-record(s2c15000, {
    list = []
}).
-endif.

-ifndef(S2C15001_PB_H).
-define(S2C15001_PB_H, true).
-record(s2c15001, {
    list = []
}).
-endif.

-ifndef(C2S15002_PB_H).
-define(C2S15002_PB_H, true).
-record(c2s15002, {
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S15003_PB_H).
-define(C2S15003_PB_H, true).
-record(c2s15003, {
    item_id = erlang:error({required, item_id}),
    dest_loc = erlang:error({required, dest_loc}),
    dest_cell = erlang:error({required, dest_cell}),
    dest_item_id = 0
}).
-endif.

-ifndef(C2S15004_PB_H).
-define(C2S15004_PB_H, true).
-record(c2s15004, {
    
}).
-endif.

-ifndef(C2S15005_PB_H).
-define(C2S15005_PB_H, true).
-record(c2s15005, {
    item_id_list = []
}).
-endif.

-ifndef(C2S15006_PB_H).
-define(C2S15006_PB_H, true).
-record(c2s15006, {
    loc = erlang:error({required, loc}),
    cell = erlang:error({required, cell}),
    flag = 0
}).
-endif.

-ifndef(C2S15007_PB_H).
-define(C2S15007_PB_H, true).
-record(c2s15007, {
    shop_type = erlang:error({required, shop_type}),
    item_tpl_id = erlang:error({required, item_tpl_id}),
    buy_num = erlang:error({required, buy_num}),
    shop_subtype = 0
}).
-endif.

-ifndef(S2C15007_PB_H).
-define(S2C15007_PB_H, true).
-record(s2c15007, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15008_PB_H).
-define(C2S15008_PB_H, true).
-record(c2s15008, {
    item_id = erlang:error({required, item_id}),
    bind = erlang:error({required, bind}),
    flag = erlang:error({required, flag}),
    cost_id_list = [],
    compose_tpl_id = 0,
    auto_buy = 0
}).
-endif.

-ifndef(S2C15008_PB_H).
-define(S2C15008_PB_H, true).
-record(s2c15008, {
    item_id = erlang:error({required, item_id}),
    result = erlang:error({required, result}),
    flag = erlang:error({required, flag})
}).
-endif.

-ifndef(C2S15009_PB_H).
-define(C2S15009_PB_H, true).
-record(c2s15009, {
    item_id = erlang:error({required, item_id}),
    bind = erlang:error({required, bind}),
    is_protect = 0,
    stren_tpl_id = 0,
    auto_buy = 0
}).
-endif.

-ifndef(S2C15009_PB_H).
-define(S2C15009_PB_H, true).
-record(s2c15009, {
    item_id = erlang:error({required, item_id}),
    result = erlang:error({required, result}),
    stren_lv = erlang:error({required, stren_lv}),
    feed_type = 0,
    feed_succ_rate = 0,
    item_list = []
}).
-endif.

-ifndef(ITEM_LIST_STRUCT_PB_H).
-define(ITEM_LIST_STRUCT_PB_H, true).
-record(item_list_struct, {
    item_tpl_id = erlang:error({required, item_tpl_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S15010_PB_H).
-define(C2S15010_PB_H, true).
-record(c2s15010, {
    item_id = erlang:error({required, item_id}),
    dest_item_id = erlang:error({required, dest_item_id}),
    auto_buy = 0
}).
-endif.

-ifndef(S2C15010_PB_H).
-define(S2C15010_PB_H, true).
-record(s2c15010, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15011_PB_H).
-define(C2S15011_PB_H, true).
-record(c2s15011, {
    item_id = erlang:error({required, item_id}),
    bind = erlang:error({required, bind})
}).
-endif.

-ifndef(S2C15011_PB_H).
-define(S2C15011_PB_H, true).
-record(s2c15011, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15012_PB_H).
-define(C2S15012_PB_H, true).
-record(c2s15012, {
    item_id = erlang:error({required, item_id}),
    bind = erlang:error({required, bind}),
    auto_buy = 0
}).
-endif.

-ifndef(S2C15012_PB_H).
-define(S2C15012_PB_H, true).
-record(s2c15012, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15013_PB_H).
-define(C2S15013_PB_H, true).
-record(c2s15013, {
    item_id = erlang:error({required, item_id}),
    bind = erlang:error({required, bind}),
    auto_buy = 0
}).
-endif.

-ifndef(S2C15013_PB_H).
-define(S2C15013_PB_H, true).
-record(s2c15013, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15014_PB_H).
-define(C2S15014_PB_H, true).
-record(c2s15014, {
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(S2C15014_PB_H).
-define(S2C15014_PB_H, true).
-record(s2c15014, {
    result = erlang:error({required, result}),
    item_id = erlang:error({required, item_id})
}).
-endif.

-ifndef(C2S15015_PB_H).
-define(C2S15015_PB_H, true).
-record(c2s15015, {
    compose_tpl_id = erlang:error({required, compose_tpl_id}),
    compose_num = erlang:error({required, compose_num}),
    auto_buy = erlang:error({required, auto_buy}),
    bind = erlang:error({required, bind})
}).
-endif.

-ifndef(S2C15015_PB_H).
-define(S2C15015_PB_H, true).
-record(s2c15015, {
    compose_tpl_id = erlang:error({required, compose_tpl_id}),
    compose_num = erlang:error({required, compose_num})
}).
-endif.

-ifndef(C2S15016_PB_H).
-define(C2S15016_PB_H, true).
-record(c2s15016, {
    inlay_item_id = erlang:error({required, inlay_item_id}),
    inlay_index = erlang:error({required, inlay_index}),
    item_id = 0,
    tpl_id = erlang:error({required, tpl_id}),
    loc = erlang:error({required, loc})
}).
-endif.

-ifndef(C2S15017_PB_H).
-define(C2S15017_PB_H, true).
-record(c2s15017, {
    item_id = erlang:error({required, item_id}),
    inlay_index = erlang:error({required, inlay_index})
}).
-endif.

-ifndef(C2S15018_PB_H).
-define(C2S15018_PB_H, true).
-record(c2s15018, {
    item_id = erlang:error({required, item_id}),
    inlay_index = erlang:error({required, inlay_index})
}).
-endif.

-ifndef(S2C15018_PB_H).
-define(S2C15018_PB_H, true).
-record(s2c15018, {
    cost_tpl = []
}).
-endif.

-ifndef(COST_TPL_STRUCT_PB_H).
-define(COST_TPL_STRUCT_PB_H, true).
-record(cost_tpl_struct, {
    tpl_id = erlang:error({required, tpl_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(C2S15019_PB_H).
-define(C2S15019_PB_H, true).
-record(c2s15019, {
    id_list = []
}).
-endif.

-ifndef(S2C15019_PB_H).
-define(S2C15019_PB_H, true).
-record(s2c15019, {
    value = erlang:error({required, value})
}).
-endif.

-ifndef(C2S15020_PB_H).
-define(C2S15020_PB_H, true).
-record(c2s15020, {
    fashion_id = erlang:error({required, fashion_id}),
    is_select = erlang:error({required, is_select})
}).
-endif.

-ifndef(S2C15021_PB_H).
-define(S2C15021_PB_H, true).
-record(s2c15021, {
    event_type = erlang:error({required, event_type}),
    list = [],
    type = erlang:error({required, type})
}).
-endif.

-ifndef(C2S15022_PB_H).
-define(C2S15022_PB_H, true).
-record(c2s15022, {
    fashion_id = erlang:error({required, fashion_id})
}).
-endif.

-ifndef(C2S15024_PB_H).
-define(C2S15024_PB_H, true).
-record(c2s15024, {
    fashion_id = erlang:error({required, fashion_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(S2C15025_PB_H).
-define(S2C15025_PB_H, true).
-record(s2c15025, {
    tpl_id = erlang:error({required, tpl_id}),
    num = erlang:error({required, num}),
    list = []
}).
-endif.

-ifndef(C2S15026_PB_H).
-define(C2S15026_PB_H, true).
-record(c2s15026, {
    type = erlang:error({required, type}),
    subtype = erlang:error({required, subtype}),
    activity_id = erlang:error({required, activity_id}),
    item_tpl_id = erlang:error({required, item_tpl_id}),
    buy_num = erlang:error({required, buy_num})
}).
-endif.

-ifndef(S2C15026_PB_H).
-define(S2C15026_PB_H, true).
-record(s2c15026, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15027_PB_H).
-define(C2S15027_PB_H, true).
-record(c2s15027, {
    list = []
}).
-endif.

-ifndef(ID_NUM_STRUCT_PB_H).
-define(ID_NUM_STRUCT_PB_H, true).
-record(id_num_struct, {
    item_id = erlang:error({required, item_id}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(S2C15027_PB_H).
-define(S2C15027_PB_H, true).
-record(s2c15027, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15028_PB_H).
-define(C2S15028_PB_H, true).
-record(c2s15028, {
    item_id = erlang:error({required, item_id}),
    name = erlang:error({required, name})
}).
-endif.

-ifndef(S2C15028_PB_H).
-define(S2C15028_PB_H, true).
-record(s2c15028, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15100_PB_H).
-define(C2S15100_PB_H, true).
-record(c2s15100, {
    item_id_list = []
}).
-endif.

-ifndef(S2C15100_PB_H).
-define(S2C15100_PB_H, true).
-record(s2c15100, {
    list = []
}).
-endif.

-ifndef(SHOW_STRUCT_PB_H).
-define(SHOW_STRUCT_PB_H, true).
-record(show_struct, {
    show_id = erlang:error({required, show_id}),
    item_id = erlang:error({required, item_id})
}).
-endif.

-ifndef(C2S15101_PB_H).
-define(C2S15101_PB_H, true).
-record(c2s15101, {
    show_id = erlang:error({required, show_id})
}).
-endif.

-ifndef(S2C15101_PB_H).
-define(S2C15101_PB_H, true).
-record(s2c15101, {
    result = erlang:error({required, result}),
    list = []
}).
-endif.

-ifndef(MARKET_STRUCT_PB_H).
-define(MARKET_STRUCT_PB_H, true).
-record(market_struct, {
    market_id = erlang:error({required, market_id}),
    user_id = erlang:error({required, user_id}),
    user_name = erlang:error({required, user_name}),
    type = erlang:error({required, type}),
    subtype = erlang:error({required, subtype}),
    price = erlang:error({required, price}),
    item = erlang:error({required, item}),
    mtime = erlang:error({required, mtime})
}).
-endif.

-ifndef(C2S15110_PB_H).
-define(C2S15110_PB_H, true).
-record(c2s15110, {
    
}).
-endif.

-ifndef(S2C15110_PB_H).
-define(S2C15110_PB_H, true).
-record(s2c15110, {
    list = []
}).
-endif.

-ifndef(C2S15111_PB_H).
-define(C2S15111_PB_H, true).
-record(c2s15111, {
    item_id = erlang:error({required, item_id}),
    item_num = erlang:error({required, item_num}),
    price = erlang:error({required, price})
}).
-endif.

-ifndef(S2C15111_PB_H).
-define(S2C15111_PB_H, true).
-record(s2c15111, {
    result = erlang:error({required, result}),
    list = []
}).
-endif.

-ifndef(C2S15112_PB_H).
-define(C2S15112_PB_H, true).
-record(c2s15112, {
    market_id = erlang:error({required, market_id})
}).
-endif.

-ifndef(S2C15112_PB_H).
-define(S2C15112_PB_H, true).
-record(s2c15112, {
    market_id = erlang:error({required, market_id}),
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15113_PB_H).
-define(C2S15113_PB_H, true).
-record(c2s15113, {
    market_id = erlang:error({required, market_id})
}).
-endif.

-ifndef(S2C15113_PB_H).
-define(S2C15113_PB_H, true).
-record(s2c15113, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(C2S15114_PB_H).
-define(C2S15114_PB_H, true).
-record(c2s15114, {
    page = erlang:error({required, page}),
    list = [],
    type = 0,
    subtype = 0,
    order_type = 0,
    order = 0
}).
-endif.

-ifndef(S2C15114_PB_H).
-define(S2C15114_PB_H, true).
-record(s2c15114, {
    page = erlang:error({required, page}),
    page_total = erlang:error({required, page_total}),
    type = erlang:error({required, type}),
    subtype = erlang:error({required, subtype}),
    list = []
}).
-endif.

-ifndef(C2S15115_PB_H).
-define(C2S15115_PB_H, true).
-record(c2s15115, {
    market_id = erlang:error({required, market_id})
}).
-endif.

-ifndef(S2C15115_PB_H).
-define(S2C15115_PB_H, true).
-record(s2c15115, {
    market_id = erlang:error({required, market_id}),
    result = erlang:error({required, result})
}).
-endif.

-ifndef(S2C15116_PB_H).
-define(S2C15116_PB_H, true).
-record(s2c15116, {
    market_id = erlang:error({required, market_id})
}).
-endif.

-ifndef(C2S15117_PB_H).
-define(C2S15117_PB_H, true).
-record(c2s15117, {
    market_id = erlang:error({required, market_id})
}).
-endif.

-ifndef(S2C15117_PB_H).
-define(S2C15117_PB_H, true).
-record(s2c15117, {
    info = erlang:error({required, info})
}).
-endif.

-ifndef(S2C15200_PB_H).
-define(S2C15200_PB_H, true).
-record(s2c15200, {
    servant_list = [],
    total_online_time = erlang:error({required, total_online_time}),
    skill_servant_id = 0
}).
-endif.

-ifndef(C2S15201_PB_H).
-define(C2S15201_PB_H, true).
-record(c2s15201, {
    servant_id = erlang:error({required, servant_id})
}).
-endif.

-ifndef(S2C15201_PB_H).
-define(S2C15201_PB_H, true).
-record(s2c15201, {
    servant_id = erlang:error({required, servant_id}),
    servant_lv = erlang:error({required, servant_lv})
}).
-endif.

-ifndef(C2S15202_PB_H).
-define(C2S15202_PB_H, true).
-record(c2s15202, {
    servant_id = erlang:error({required, servant_id})
}).
-endif.

-ifndef(S2C15202_PB_H).
-define(S2C15202_PB_H, true).
-record(s2c15202, {
    servant_id = erlang:error({required, servant_id})
}).
-endif.

