%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2013.06.15.
%%% @desc   : gen_server 自定义模板
%%%----------------------------------------------------------------------

-module(behaviour_map).
-compile(inline).

-include("common.hrl").
-include("record.hrl").

%%%=========================================================================
%%%  API
%%%=========================================================================

-callback init(Map :: #map{}) ->
    {ok, NewMap :: #map{}}.
-callback loop(Map :: #map{}) ->
    {ok, NewMap :: #map{}}.
-callback enter(Map :: #map{}) ->
    {ok, NewMap :: #map{}}.
-callback leave(Map :: #map{}) ->
    {ok, NewMap :: #map{}}.



