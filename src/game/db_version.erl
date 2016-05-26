%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   :
%%%------------------------------------------------------------------------

-module(db_version).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([update_version/0]).
-export([execute/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
update_version() ->
    DbVersion = global_data_disk:get(sql_version, 0),
    case DbVersion >= ?SQL_VERSION of
        ?TRUE ->
            ?INFO("check_version, same version!");
        _ ->
            VersionList = lists:seq(DbVersion + 1, ?SQL_VERSION),
            ?INFO("check_version, VersionList:~w", [VersionList]),
            [version_sql(E) || E <- VersionList],
            global_data_disk:set(sql_version, ?SQL_VERSION),
            global_data_disk:sync()
    end,
    ok.

version_sql(N) ->
    ?INFO("log_version sql has no log_version:~w", [N]),
    ok.

%% 确保顺序执行，用?BASE_MYSQL_POOL
execute(Sql) ->
    edb_util:execute(?BASE_MYSQL_POOL, Sql, ?VERSION_SQL_TIMEOUT).

%% ========================================================================
%% Local functions
%% ========================================================================

