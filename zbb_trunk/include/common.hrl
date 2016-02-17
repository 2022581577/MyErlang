-ifndef(COMMON_HRL).
-define(COMMON_HRL,"common.hrl").


-define(CONFIG(Key), game_config:get_config(Key)).

-include("logger.hrl").
-include("ets.hrl").
-include("user.hrl").
-include("map.hrl").

-define(TRUE, true).
-define(FALSE, false).

-define(TCP_OPT,[
                binary
                ,{packet, 0}
                ,{active, false}
                ,{reuseaddr, true}
                ,{nodelay, true}
                ,{delay_send, true}
                ,{send_timeout, 5000}
                ,{keepalive, true}
                ,{exit_on_close, true}
                ,{high_watermark, 128 * 1024}
                ,{low_watermark, 64 * 1024}
            ]).

-define(HEADER_LENGTH, 4).          % 消息头长度
-define(HEART_TIMEOUT, (90 * 1000)).  % 接收数据超时时间

-define(GLOBAL_DATA_DISK, global_data_disk).
-define(GLOBAL_DATA_RAM, global_data_ram).

-define(MYSQL_POOL,mysql_pool).
-define(MYSQL_CONNECT_STATE,mysql_connect_state).

-define(VERSION_SQL_TIMEOUT,(300 * 1000)).
-define(SQL_VERSION, 1).

%% Game Status
-define(GAME_STATUS,game_status).
-define(GAME_STATUS_SUCCESS,0).
-define(GAME_STATUS_NORUN,1).
-define(GAME_STATUS_USAGE,2).
-define(GAME_STATUS_BADRPC,3).
-define(GAME_STATUS_ERROR,4).
-define(GAME_STATUS_STARTING,5).
-define(GAME_STATUS_RUNNING,6).
-define(GAME_STATUS_STOPING,7).

%% Game Timer
-define(DIFF_SECONDS_1970_1900, 2208988800).
-define(DIFF_SECONDS_0000_1900, 62167219200).
-define(TIMER_TEN_SEC,          10).    %% 10秒    
-define(TIMER_ONE_MIN_SEC,      60).    %% 一分钟
-define(TIMER_FIFTEEN_MIN_SEC,  900).   %% 15分钟
-define(TIMER_THIRTY_MIN_SEC,   1800).  %% 30分钟
-define(TIMER_ONE_HOUR_SEC,     3600).
-define(TIMER_ONE_DAY_SEC,      86400).

%% Game Function
-define(RECORD_FIELDS(Record),record_info(fields,Record)).

-endif.
