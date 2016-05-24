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


-ifdef(LOGGER).

%% define logger
-define(D(Format, Args),            logger:debug_msg(?MODULE,?LINE,Format, Args)).
-define(INFO(Format, Args),         logger:info_msg(?MODULE,?LINE,Format, Args)).
-define(WARNING(Format, Args),      logger:warning_msg(?MODULE,?LINE,Format, Args)).
-define(WARNING2(Format, Args),     logger:warning_msg(?MODULE,?LINE,Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).
-define(ERROR(Format, Args),        logger:error_msg(?MODULE,?LINE,Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).    
-define(CRITICAL_MSG(Format, Args), logger:critical_msg(?MODULE,?LINE,Format, Args)).

%% no param logger
-define(D(Format),                  logger:debug_msg(?MODULE,?LINE,Format, [])).
-define(INFO(Format),               logger:info_msg(?MODULE,?LINE,Format, [])).
-define(WARNING(Format),            logger:warning_msg(?MODULE,?LINE,Format, [])).
-define(WARNING2(Format),           logger:warning_msg(?MODULE,?LINE,Format ++ ",~w", [] ++ [erlang:get_stacktrace()])).
-define(ERROR(Format),              logger:error_msg(?MODULE,?LINE,Format ++ ",~w", [] ++ [erlang:get_stacktrace()])).    
-define(CRITICAL_MSG(Format),       logger:critical_msg(?MODULE,?LINE,Format, [])).

-else.

%% define logger
-define(D(Format, Args),            log_lager:lager(fun_info, ?MODULE, ?LINE, Format, Args)).
-define(INFO(Format, Args),         log_lager:lager(fun_info, ?MODULE, ?LINE, Format, Args)).
-define(WARNING(Format, Args),      log_lager:lager(fun_warning, ?MODULE, ?LINE, Format, Args)).
-define(WARNING2(Format, Args),     log_lager:lager(fun_warning, ?MODULE, ?LINE, Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).
-define(ERROR(Format, Args),        log_lager:lager(fun_error, ?MODULE, ?LINE, Format ++ ",~w", Args ++ [erlang:get_stacktrace()])).    
-define(CRITICAL_MSG(Format, Args), log_lager:lager(fun_crash, ?MODULE, ?LINE, Format, Args)).

%% no param logger
-define(D(Format),                  log_lager:lager(fun_info, ?MODULE, ?LINE, Format, [])).
-define(INFO(Format),               log_lager:lager(fun_info, ?MODULE, ?LINE, Format, [])).
-define(WARNING(Format),            log_lager:lager(fun_warning, ?MODULE, ?LINE, Format, [])).
-define(WARNING2(Format),           log_lager:lager(fun_warning, ?MODULE, ?LINE, Format ++ ",~w", [] ++ [erlang:get_stacktrace()])).
-define(ERROR(Format),              log_lager:lager(fun_error, ?MODULE, ?LINE, Format ++ ",~w", [] ++ [erlang:get_stacktrace()])).    
-define(CRITICAL_MSG(Format),       log_lager:lager(fun_crash, ?MODULE, ?LINE, Format, [])).

-endif.

-endif.
