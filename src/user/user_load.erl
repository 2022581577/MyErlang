%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.04.22
%%% @desc   : 玩家数据上线加载、定时保存和下线保存信息
%%%----------------------------------------------------------------------

-module(user_load).
-include("common.hrl").
-include("record.hrl").

-export([load_init/1]).
-export([save_loop/1]).
-export([save_logout/1]).

%% @doc 加载
load_init(UserID) ->
    case game_mmdb:get_user(UserID) of
        #user{} = User ->   
            F           = fun(Module, {ok, UserIn}) -> Module:load_init(UserIn) end,
            {ok, UserN} = lists:foldl(F, {ok, User}, load_init_modules()),
            {ok, UserN};
        _ ->
            ?FALSE
    end.

%% 注意有些数据的加载需要保证顺序
load_init_modules() ->
    [user_misc    %% 杂项
    ,user_item    %% 道具
    ,user_mail    %% 邮件
    ,user_task    %% 任务
    ].


%% @doc 定时保存
save_loop(User) ->
    {ok, UserN} = save(User),
    {ok, UserN}.


%% @doc 下线保存
save_logout(User) ->
    {ok, UserN} = save(User),
    {ok, UserN}.


save(User) ->
    F           = fun(Module, {ok, UserIn}) -> Module:save(UserIn) end,
    {ok, UserN} = lists:foldl(F, {ok, User}, save_modules()),
    {ok, UserN}.

save_modules() ->
    [user_misc    %% 杂项
    ,user_item    %% 道具
    ,user_mail    %% 邮件
    ,user_task    %% 任务
    ].
