%% some log defines
-define(Debug2(F, D), ""). %(io:format("~n## crontab debug: " ++ F ++ "~n", D))).
-define(Warn2 (F, D), (io:format("~n## crontab warn: "  ++ F ++ "~n", D))).
-define(Error2(F, D), (io:format("~n## crontab error: " ++ F ++ "~n", D))).

-define(CRON_FILE, "../ebin/game_cron.cfg"). %% filename of the config
-define(CHECK_FILE_INTERVAL, 60000). % 1 minute
-define(CHECK_CRON_INTERVAL, 60000). % 1 minute

-define(CRON_ANY,   1). % "*"
-define(CRON_NUM,   2). % 2
-define(CRON_RANGE, 4). % 2-3
-define(CRON_LIST,  8). % "2,3-6"

-record(cron_field, {
     type = ?CRON_ANY
   ,value 
}).

-record(cron_entry, {
     m   % minute
   ,h   % hour
   ,dom % day of month
   ,mon % month
   ,dow % day of week
   ,mfa % the mfa
}).

