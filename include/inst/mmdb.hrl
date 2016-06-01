-ifndef(MMDB_HRL).
-define(MMDB_HRL,"mmdb.hrl").

-include("common.hrl").
-include("record.hrl").

%% record and define
-record(durable_record,{rec_name                %% Record名称，需要与表名相同
                        ,ets_key     = 1        %% 主键编号，一般用于ets初始化(一般1时ets格式为{Key，RecordList})
                        ,db_key                 %% 取数据库是key名称
                        ,is_preload  = false    %% 是否已经预先加载(针对公共数据，一般都已经预加载了的)
                        ,is_list     = false    %% 是否record list 格式，如果为true，ets_key为1，ets格式为{Key，RecordList}
    }).

%% 内存数据库数据定义
%% ！！！ 注意！！！
%% 这里加了需要在lib_record中加上对应的record名
%% 才能获得record的对应字段名
-define(DURABLE_RECORD_LIST,
    [#durable_record{rec_name = global_data
                    ,ets_key = #global_data.global_key
                    ,db_key = global_key
                    ,is_preload = ?FALSE}
    ,#durable_record{rec_name = user
                    ,ets_key = #user.user_id
                    ,db_key = user_id
                    ,is_preload = ?TRUE}
    ,#durable_record{rec_name = user_item
                    ,db_key = user_id
                    ,is_list = ?TRUE}
%%    ,#durable_record{rec_name = guild
%%                   ,ets_key = #guild.guild_id
%%                   ,db_key = guild_id
%%                   ,is_preload = ?TRUE}
    ]).

-endif.
