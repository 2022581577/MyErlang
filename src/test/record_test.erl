%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 五月 2016 15:49
%%%-------------------------------------------------------------------
-module(record_test).
-author("Administrator").

%% include
-include("common.hrl").
-include("record.hrl").

%% export
-export([get_rd_user/3]).
-export([record_files_user/0]).

%% record and define


%% ========================================================================
%% API functions
%% ========================================================================
get_rd_user(UserID, AccName, Name) ->
    #user{user_id = UserID,
        acc_name = AccName,
        name = Name,
        ip = util:to_binary("127.0.0.1"),
        other_data = <<"">>}.

record_files_user() ->
    record_info(fields, user).

%% ========================================================================
%% Local functions
%% ========================================================================

