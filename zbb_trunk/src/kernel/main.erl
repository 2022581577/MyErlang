%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 
%%-----------------------------------------------------

-module(main).

-export([start/0
        ,stop/0]).

start() ->
    ok = start_applications([sasl, server]).

stop() ->
    lib_server:stop(),
    ok = stop_applications([sasl, server]),
    timer:sleep(5000),
    erlang:halt(0, [{flush, false}]).

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

