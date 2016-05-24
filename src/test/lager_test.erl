-module(lager_test).

-compile(export_all).


degug(Format) ->
    lager:debug(Format).

info(Format) ->
    lager:info(Format).

warning(Format) ->
    lager:warning(Format).

error(Format) ->
    lager:error(Format).
