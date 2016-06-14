%%-----------------------------------------------------
%% @Module:binary_heap 
%% @Author:xiayong
%% @Email:xiayong@yy.com
%% @Created:2014-8-2
%% @Desc:
%%-----------------------------------------------------

-module(binary_heap).

%% ------------------------------------------------------------------------------------------
%% API functions
%% ------------------------------------------------------------------------------------------
-export([
            new/1
            ,put/2
            ,pop/1
            ,get/3
            ,update/3
            ,get_size/1
            ,desc/2
            ,test/0
        ]).


-record(binary_heap,{
    array
    ,compare_fun
}).
%% ------------------------------------------------------------------------------------------
%% Internal functions
%% ------------------------------------------------------------------------------------------
new(CompareFun) ->
    #binary_heap{
        compare_fun = CompareFun
        ,array = array:new([{fixed, false},{default, undefined}])
    }.

put(BinaryHeap = #binary_heap{compare_fun = Fun, array = Array}, Obj) ->
    Size = array:size(Array),
    case Size =:= 0 of
        true ->
            BinaryHeap#binary_heap{
                array = array:set(0, Obj, Array)
            };
        _ ->
            NewArray = up_check(array:set(Size, Obj, Array), Fun, Size, Obj),
            BinaryHeap#binary_heap{
                array = NewArray
            }
    end.

%% @doc TestIndex位置的TestObj元素上浮测试    待测试元素和父亲(TestIndex div 2)比较
up_check(Array, _CompareFun, 0, _TestObj) ->
    %% 待测试元素已到达顶端
    Array;
up_check(Array, CompareFun, TestIndex, TestObj) ->
    ParentIndex = TestIndex div 2,
    Parent = array:get(ParentIndex, Array),
    case CompareFun(TestObj, Parent) of
        false ->
            %% 待测试元素符合要求
            Array;
        _ ->
            %% 待测试元素和父亲交换
            Array1 = array:set(TestIndex, Parent, Array),
            Array2 = array:set(ParentIndex, TestObj, Array1),
            up_check(Array2, CompareFun, ParentIndex, TestObj)
    end.





%% @return {true,Result,NewBinaryHeap}|false
pop(BinaryHeap = #binary_heap{compare_fun = Fun, array = Array}) ->
    Size = array:size(Array),
    if
        Size == 0 ->
            false;
        Size == 1 ->
            Result = array:get(0, Array),
            Array1 = array:resize(array:reset(0, Array)),
            {true, Result, BinaryHeap#binary_heap{array = Array1}};
        true ->
            Result = array:get(0, Array),
            LastObj = array:get(Size-1, Array),
            Array1 = array:resize(array:reset(Size-1, Array)),
            Array2 = array:set(0, LastObj, Array1),
            NewArray = down_check(Array2, Fun, 0, LastObj,array:size(Array2)),
            {true, Result, BinaryHeap#binary_heap{array = NewArray}}
    end.


%% @doc TestIndex位置的TestObj元素下沉测试
down_check(Array, CompareFun, TestIndex, TestObj, Size) ->
    LeftIndex = 2*TestIndex + 1,
    RightIndex = 2*TestIndex + 2,
    if
        LeftIndex < Size - 1  ->
            %% RightObj存在
            LeftObj = array:get(LeftIndex, Array),
            RightObj = array:get(RightIndex, Array),
            case {CompareFun(TestObj, LeftObj), CompareFun(TestObj, RightObj)} of
                {true, true} ->
                    Array;
                {true, false} ->
                    %% 沿着右节点前进
                    Array1 = array:set(TestIndex, RightObj, Array),
                    Array2 = array:set(RightIndex, TestObj, Array1),
                    down_check(Array2, CompareFun, RightIndex, TestObj, Size);
                _ ->
                    %% 沿着左节点前进
                    Array1 = array:set(TestIndex, LeftObj, Array),
                    Array2 = array:set(LeftIndex, TestObj, Array1),
                    down_check(Array2, CompareFun, LeftIndex, TestObj, Size)
            end;
        LeftIndex == Size - 1 ->
            %% RightObj不存在 判断到头了
            LeftObj = array:get(LeftIndex, Array),
            case CompareFun(TestObj, LeftObj) of
                false ->
                    Array1 = array:set(TestIndex, LeftObj, Array),
                    Array2 = array:set(LeftIndex, TestObj, Array1),
                    down_check(Array2, CompareFun, LeftIndex, TestObj, Size);
                _ ->
                    Array
            end;
        true ->
            %% 越界
            Array
    end.

%% @doc 根据KEY得到obj
%% @return {Index,Value}|false
get(BinaryHeap, Key, GetKeyFun) ->
    array:sparse_foldl(fun(Index, Value, Acc) ->
                            case GetKeyFun(Value) == Key of
                                true ->
                                    {Index, Value};
                                _ ->
                                    Acc
                            end
                       end, false, BinaryHeap#binary_heap.array).

%% @return BinaryHeap
update(BinaryHeap, Index, Obj) ->
    Array = BinaryHeap#binary_heap.array,
    Array1 = array:set(Index, Obj, Array),
    Size = array:sparse_size(Array1),
    CompareFun = BinaryHeap#binary_heap.compare_fun,
    Parent = array:get(Index div 2, Array),
    LeftIndex = 2*Index + 1,
    NewArray =
    case CompareFun(Parent, Obj) of
        true ->
            case LeftIndex =< Size - 1 of
                true ->
                    %% 左子节点存在
                    case CompareFun(Obj, array:get(LeftIndex, Array1)) of
                        true ->
                            Array1;
                        _ ->
                            down_check(Array1, CompareFun, Index, Obj, Size)
                    end;
                _ ->
                    Array1
            end;
        _ ->
            up_check(Array1, CompareFun, Index, Obj)
    end,
    BinaryHeap#binary_heap{array = NewArray}.

get_size(_BinaryHeap = #binary_heap{array = Array}) ->
    array:size(Array).

desc(#binary_heap{array = Array}, DescFun) ->
    lists:flatten([DescFun(X) || X <- array:to_list(Array)]).


test() ->
    F = fun(X, Acc) ->
        case X of
            {put, Obj} ->
                ?MODULE:put(Acc, Obj);
            _ ->
                case ?MODULE:pop(Acc) of
                    {true, _, NewAcc} ->
                        NewAcc;
                    _ ->
                        Acc
                end
        end
    end,
    R = lists:foldl(F, ?MODULE:new(fun(X1,X2) -> X1<X2 end), [{put,4},pop,{put,3},{put,5},pop,{put,2}]),
    io:format("R:~w~n", [R]),

    ok.
