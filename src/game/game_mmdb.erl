%% Generate by code robot @ binbinjnu@163.com>
%% All rights reserved
%% @desc 游戏内存数据库

-module(game_mmdb).

-include("common.hrl").
-include("record.hrl").

-export([
		init/0,
		get_user/1,
		get_user_item/1,
		get_guild/1,
		get_account_info/1,
		add_account_mapping/2,
		new_user_init_ets/1
		]).


init() ->
	ets:new(?ETS_USER,[{keypos,#user.user_id},named_table,public,set,{read_concurrency,true}]),
	ets:new(?ETS_USER_ITEM,[{keypos,1},named_table,public,set,{read_concurrency,true}]),
	ets:new(?ETS_GUILD,[{keypos,#guild.guild_id},named_table,public,set,{read_concurrency,true}]),
	ets:new(?ETS_ACCOUNT_INFO,[{keypos,#account_info.acc_name},named_table,public,set,{read_concurrency,true}]),     %% 账号角色ID映射
	ok.


get_account_info(AccName) ->
	AccName1 = util:to_binary(AccName),
	case ets:lookup(?ETS_ACCOUNT_INFO, AccName1) of
		[#account_info{} = AccountInfo] ->
			AccountInfo;
		[] ->
			false
	end.

add_account_mapping(AccName,UserID) ->
	AccountInfo1 = 
		case get_account_info(AccName) of
			#account_info{user_ids = UserIDs} = AccountInfo ->
				AccountInfo#account_info{user_ids = [UserID | lists:delete(UserID,UserIDs)]};
			false ->
				#account_info{acc_name = AccName,user_ids = [UserID]}
		end,
	%% 帐号和对应玩家id列表映射
	ets:insert(?ETS_ACCOUNT_INFO,AccountInfo1).


get_user(Key) ->
	case ets:lookup(?ETS_USER, Key) of
		[#user{} = USER] ->
			USER;
		[] ->
			false
	end.

get_user_item(Key) ->
	case ets:lookup(?ETS_USER_ITEM, Key) of
		[{Key,USER_ITEM}] ->
			USER_ITEM;
		[] ->
			load_user_item(Key)
	end.

load_user_item(Key) ->
	USER_ITEM = edb_util:get_all(user_item, [{user_id, Key}]),
	USER_ITEM1 = [util:to_tuple([user_item | E]) || E <- USER_ITEM],
	ets:insert(?ETS_USER_ITEM,{Key,USER_ITEM1}),
	USER_ITEM1.

get_guild(Key) ->
	case ets:lookup(?ETS_GUILD, Key) of
		[#guild{} = GUILD] ->
			GUILD;
		[] ->
			false
	end.

%% @doc 新号初始化ets
new_user_init_ets(UserID) ->
	ets:insert(?ETS_USER_ITEM, {UserID, []}),
	ok.

