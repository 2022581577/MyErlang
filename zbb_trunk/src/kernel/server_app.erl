%%-----------------------------------------------------
%% @Author: zhongbinbin
%% @Email : zhongbinbin@yy.com
%% @Create: 2015-5-20
%% @Desc  : 各种服务的开启
%%-----------------------------------------------------

-module(server_app).

-include("common.hrl").

-export([start/2
        ,stop/1]).

-export([prep_stop/0]).

-compile(export_all).

start(normal, []) ->
    %% 开启主监控树
    {ok, Sup} = server_sup:start_link(),
    %% 加载配置
    game_config:init(),
    ok = lib_server:start(Sup),
    {ok, Sup}.

stop(_) ->
    ok.

%% application:stop(App)时会调用)
prep_stop() ->
    ok.

%% -------------------------
%%      LOCAL Function
%% -------------------------
