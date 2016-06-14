%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 六月 2016 11:34
%%%-------------------------------------------------------------------
-module(util_tests).
-author("Administrator").

%% include
-include_lib("eunit/include/eunit.hrl").

%% export

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
ceil_test() ->
    ?assert(1 =:= util:ceil(1)),
    ?assert(1 =:= util:ceil(0.1)),
    ?assert(0 =:= util:ceil(0)),
    ?assert(0 =:= util:ceil(-0.1)),
    ok.


term_to_bitstring_test() ->
    ?assertEqual(<<"">>, util:term_to_bitstring("")),
    ?assertEqual(<<"[]">>, util:term_to_bitstring([])),
    ?assertEqual(<<"[a,b]">>, util:term_to_bitstring([a,b])),
    ?assertEqual(<<"<<233,146,159,230,150,140,230,150,140>>">>,
        util:term_to_bitstring(<<233,146,159,230,150,140,230,150,140>>)),
    ok.



%% ========================================================================
%% Local functions
%% ========================================================================

