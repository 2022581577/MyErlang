%%%------------------------------------------------------------------------
%%% @author : 
%%% @date   :
%%% @desc   :
%%%------------------------------------------------------------------------

-module(log_test).

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([]).
-compile(export_all).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
test(Format) ->
    test(Format, []).

test(Format, Args) ->
    %?TRACE(Format, Args),
    ?D(Format, Args),  
    ?INFO(Format, Args),
    ?WARNING(Format, Args),
    ?WARNING2(Format, Args),
    ?ERROR(Format, Args),
    ?CRITICAL_MSG(Format, Args).

%% ========================================================================
%% Local functions
%% ========================================================================

