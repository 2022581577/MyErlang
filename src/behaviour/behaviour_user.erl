%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2013.06.15.
%%% @desc   : gen_server 自定义模板
%%%----------------------------------------------------------------------

-module(behaviour_user).
-compile(inline).

-include("common.hrl").
-include("record.hrl").

%%%=========================================================================
%%%  API
%%%=========================================================================


-callback create(User :: #user{}) ->
    {ok, NewUser :: #user{}}.
-callback init(User :: #user{}) ->
    {ok, NewUser :: #user{}}.
-callback loop(User :: #user{}, N :: integer()) ->
    {ok, NewUser :: #user{}}.
-callback save(User :: #user{}) ->
    {ok, NewUser :: #user{}}.
