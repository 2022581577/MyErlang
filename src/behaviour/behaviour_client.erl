%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2013.06.15.
%%% @desc   : client 自定义模板
%%%----------------------------------------------------------------------

-module(behaviour_client).
-compile(inline).

-include("common.hrl").
-include("record.hrl").

%%%=========================================================================
%%%  API
%%%=========================================================================


-callback init() ->
    term().
-callback set_socket(State :: term(), Socket :: port()) ->
    term().
-callback handle(State :: term(), Bin :: binary()) ->
    {ok, term()} | {false, term()}.
