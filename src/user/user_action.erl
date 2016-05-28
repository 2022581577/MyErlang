%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc 玩家各个模块的行为流程
%%%
%%% @end
%%% Created : 28. 五月 2016 15:00
%%%-------------------------------------------------------------------
-module(user_action).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([create/1]).
-export([init/1]).
-export([loop/2]).
-export([save/1]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
%% @doc 创建行为
create(User) ->
    F           = fun(Module, {ok, UserIn}) -> Module:create(UserIn) end,
    {ok, UserN} = lists:foldl(F, {ok, User}, create_modules()),
    {ok, UserN}.

%% @doc 初始化行为
init(User) ->
    F           = fun(Module, {ok, UserIn}) -> Module:init(UserIn) end,
    {ok, UserN} = lists:foldl(F, {ok, User}, init_modules()),
    {ok, UserN}.

%% @doc 循环
loop(User, SumTime) ->
    F           = fun(Module, {ok, UserIn}) -> Module:loop(UserIn, SumTime) end,
    {ok, UserN} = lists:foldl(F, {ok, User}, loop_modules()),
    {ok, UserN}.

%% @doc 保存
save(User) ->
    F           = fun(Module, {ok, UserIn}) -> Module:save(UserIn) end,
    {ok, UserN} = lists:foldl(F, {ok, User}, save_modules()),
    {ok, UserN}.

%% ========================================================================
%% Local functions
%% ========================================================================
%% 注意有些数据的加载需要保证顺序
init_modules() ->
    [user_misc    %% 杂项
    ,user_item    %% 道具
    ,user_mail    %% 邮件
    ,user_task    %% 任务
    ].

create_modules() ->
    [].

loop_modules() ->
    [user_base_loop
    ].

save_modules() ->
    [user_misc    %% 杂项
    ,user_item    %% 道具
    ,user_mail    %% 邮件
    ,user_task    %% 任务
    ,user_log     %% 日志
    ].