-module(try_catch).

-export([test/0]).

test() ->
    try 
        test1()
    catch 
        Err:Reason ->
            io:format("err:~w, reason:~w", [Err, Reason]),
            ok
    after 
        1000 ->
            io:format("Time out!")
    end,
    ok.

test1() ->
    A = 1 + 1,
    A = 2 + 1.
