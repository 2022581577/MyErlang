-ifndef(LOGGER_HRL).
-define(LOGGER_HRL,"logger.hrl").

%%in standard output
-define(PRINT(Format, Args), io:format(Format, Args)).
-define(PRINT(Format), io:format(Format)).

-ifdef(LIVE).
    -define(_U(S),unicode:characters_to_list(iolist_to_binary(S))).
-else.
    -define(_U(S),S).
-endif.

-ifdef(LAGER).

%% define logger
-define(D(Format, Args),            log_lager:lager(fun_info, ?MODULE, ?LINE, Format, Args)).
-define(INFO(Format, Args),         log_lager:lager(fun_info, ?MODULE, ?LINE, Format, Args)).
-define(WARNING(Format, Args),      log_lager:lager(fun_warning, ?MODULE, ?LINE, Format, Args)).
-define(WARNING2(Format, Args),     log_lager:lager(fun_warning, ?MODULE, ?LINE, Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).
-define(ERROR(Format, Args),        log_lager:lager(fun_error, ?MODULE, ?LINE, Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).    
-define(CRITICAL_MSG(Format, Args), log_lager:lager(fun_crash, ?MODULE, ?LINE, Format, Args)).

%% no param logger
-define(D(Format),                  ?D(Format, [])).     
-define(INFO(Format),               ?INFO(Format, [])).   
-define(WARNING(Format),            ?WARNING(Format, [])). 
-define(WARNING2(Format),           ?WARNING2(Format ++ ",~w", [erlang:get_stacktrace()])).
-define(ERROR(Format),              ?ERROR(Format ++ ",~w", [erlang:get_stacktrace()])).
-define(CRITICAL_MSG(Format),       ?CRITICAL_MSG(Format, [])).

-else.

%% define logger
-define(D(Format, Args),            logger:debug_msg(?MODULE,?LINE,Format, Args)).
-define(INFO(Format, Args),         logger:info_msg(?MODULE,?LINE,Format, Args)).
-define(WARNING(Format, Args),      logger:warning_msg(?MODULE,?LINE,Format, Args)).
-define(WARNING2(Format, Args),     logger:warning_msg(?MODULE,?LINE,Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).
-define(ERROR(Format, Args),        logger:error_msg(?MODULE,?LINE,Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).    
-define(CRITICAL_MSG(Format, Args), logger:critical_msg(?MODULE,?LINE,Format, Args)).

%% no param logger
-define(D(Format),                  ?D(Format, [])).     
-define(INFO(Format),               ?INFO(Format, [])).   
-define(WARNING(Format),            ?WARNING(Format, [])). 
-define(WARNING2(Format),           ?WARNING2(Format ++ ",~w", [erlang:get_stacktrace()])).
-define(ERROR(Format),              ?ERROR(Format ++ ",~w", [erlang:get_stacktrace()])).
-define(CRITICAL_MSG(Format),       ?CRITICAL_MSG(Format, [])).

-endif.


-endif.
