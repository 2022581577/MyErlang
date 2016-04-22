-module(cron_test).
-compile(export_all).
-include("cron.hrl").

parse() ->
    parse(?CRON_FILE).

parse(File) ->
    case cron_lib:parse(File) of
        {ok, _} -> io:format("success!~n");
        _ -> ok
    end.
