%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 六月 2016 10:14
%%%-------------------------------------------------------------------
-module(db_test).
-author("Administrator").

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
create_item(UserID, [{_TplID, _Location} | _] = L) ->
    L1 =
        [#user_item{item_id = game_counter:get_item_id(),
                    tpl_id = TplID,
                    user_id = UserID,
                    location = Location} || {TplID, Location} <- L],
    game_db:save_value(UserID, L1),
    ok.


%% ========================================================================
%% Local functions
%% ========================================================================

