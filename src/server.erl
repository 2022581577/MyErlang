%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 
%%-----------------------------------------------------

-module(server).

-export([start/0
        ,stop/0]).

-export([start_applications/1]).
-export([stop_applications/1]).

-define(APP_SERVER, server).

start() ->
    prep_start(),
    {ok, _} = application:ensure_all_started(?APP_SERVER),
%%    ok = start_applications(?APPS),
    ok.

stop() ->
    prep_stop(),
    application:stop(?APP_SERVER),
%%    ok = stop_applications(lists:reverse(?APPS)),
    timer:sleep(5000),
    erlang:halt(0, [{flush, false}]).


prep_start() ->
    ok.

prep_stop() ->
    ok.


start_applications(Apps) ->
    manage_applications(fun lists:foldl/3
        ,fun application:start/1
        ,fun application:stop/1
        ,already_started
        ,cannot_start_application
        ,Apps
    ).

stop_applications(Apps) ->
    manage_applications(fun lists:foldl/3
        ,fun application:stop/1
        ,fun() -> ok end
        ,not_started
        ,cannot_stop_application
        ,Apps
    ).

manage_applications(Iterate, Do, UnDo, SkipError, ErrorTag, Apps) ->
    F = fun(App, Acc) ->
        case Do(App) of
            ok ->
                [App | Acc];
            {error, {SkipError, _}} ->
                Acc;
            {error, Reason} ->
                lists:foreach(UnDo, Acc),
                throw({error, {ErrorTag, App, Reason}})
        end
        end,
    Iterate(F, [], Apps),
    ok.
