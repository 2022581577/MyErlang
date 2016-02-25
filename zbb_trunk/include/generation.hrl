-include("generation_util.hrl").

-record(durable_record,{name,               %% Record名称
                        keypos = 1,         %% 主键名称，如果为列表，则填写整数 1,2,3
                        db_keypos = 1,      %% 某些表可能需要不同的db_keypos
                        ets_type = set,     %% ets类型
                        is_preload = false, %% 是否已经预先加载(针对公共数据，一般都已经预加载了的)
                        is_user = false,    %% 是否玩家相关数据
                        record_list = false,%% 是否record list 格式,存库优化
                        record_fields = false
                    }).

%% 内存数据库数据定义
-define(DURABLE_RECORD_LIST,[#durable_record{name = user, keypos = user_id, is_user = true, is_preload = true}
                            ,#durable_record{name = user_item, is_user = true, record_list = true}
                            ,#durable_record{name = guild, keypos = guild_id, is_preload = true}
                            ]).

