-module(smdl).

-export([test/1]).

test(N) ->
    random:seed(erlang:timestamp()),
    put(rc, 0),
    put(ru, 0),
    test1(N),
    {get(rc), get(ru)}.



test1(N) when N > 0 ->
    [_A, _, _] = L = shuffle_list([1,0,0]),
    R = lists:nth(rand(1, 3), L),
    Rc = get(rc),
    Ru = get(ru),
    case R of
        1 -> put(rc, Rc+1);
        _ -> put(ru, Ru+1)
    end,
    %%case lists:delete(0, lists:delete(R, L)) of
    %%    [1] ->  put(rc, Rc+1);
    %%    _ ->    skip
    %%end,

    %%case R of
    %%    1 ->    put(ru, Ru+1);
    %%    _ ->    skip
    %%end,

    test1(N - 1);
test1(_) -> 
    skip.


%% 随机排列列表
shuffle_list(L) ->
    F = fun(_, _) ->
            case rand(1, 2) of
                1 ->    true;
                _ ->    false
            end
        end,
    lists:sort(F, L).

rand(Same, Same) -> Same;
rand(Min, Max) ->
    %% 如果没有种子，将从核心服务器中去获取一个种子，以保证不同进程都可取得不同的种子
    M = Min - 1,
    random:uniform(Max - M) + M.
