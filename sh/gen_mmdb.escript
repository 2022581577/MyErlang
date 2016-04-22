#!/usr/bin/env escript
%%% @author : kongqingquan <kqqsysu@gmail.com>

-mode(compile).

%-include("../include/common.hrl").
-include("../include/generation.hrl").

main(_Args) ->
    Name = "game_mmdb",
    Str = get_header(Name) ++ fun_init() ++ fun_get() ++ fun_new_user_init(),
    FileName = Name ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    ok.

%% @doc 头信息
get_header(Mod) ->
    ?COPYRIGHT 
    ?DESC("游戏内存数据库")
    "-module(" ++ Mod ++ ").\n\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([\n"
    "\t\tinit/0,\n" ++
    lists:foldl(fun(#durable_record{name = Name}, AccIn) ->
                    AccIn ++ "\t\tget_" ++ atom_to_list(Name) ++ "/1,\n"
                end,"",?DURABLE_RECORD_LIST) ++
    "\t\tget_account_info/1,\n"
    "\t\tadd_account_mapping/2,\n"
    "\t\tnew_user_init_ets/1\n"
    "\t\t]).\n\n\n".

fun_init() ->
    "init() ->\n" ++
    lists:foldl(fun(#durable_record{name = Name,keypos = KeyPos, ets_type = EtsType},AccIn) ->
                    AccIn ++ "\tets:new(" ++ ?ETS_RECORD_NAME(Name) ++
                    ",[" ++ ?KEYPOS(Name,KeyPos) ++ ",named_table,public," ++ atom_to_list(EtsType) ++ ",{read_concurrency,true}]),\n"
                end,"",?DURABLE_RECORD_LIST) ++ 
    %% 映射信息先不处理
    "\tets:new(?ETS_ACCOUNT_INFO,[{keypos,#account_info.acc_name},named_table,public,set,{read_concurrency,true}]),     %% 账号角色ID映射\n"
    %"\tets:new(?ETS_USER_NAME,[{keypos,#name_info.name},named_table,public,set,{read_concurrency,true}]),                  %% 角色名称映射\n" TODO 看后续是否需要加server_id
    "\tok.\n\n\n"
    "get_account_info(AccName) ->\n"
    "\tAccName1 = util:to_binary(AccName),\n"
    "\tcase ets:lookup(?ETS_ACCOUNT_INFO, AccName1) of\n"
    "\t\t[#account_info{} = AccountInfo] ->\n"
    "\t\t\tAccountInfo;\n"
    "\t\t[] ->\n"
    "\t\t\tfalse\n"
    "\tend.\n\n"
    "add_account_mapping(AccName,UserID) ->\n"
    "\tAccountInfo1 = \n"
    "\t\tcase get_account_info(AccName) of\n"
    "\t\t\t#account_info{user_ids = UserIDs} = AccountInfo ->\n"
    "\t\t\t\tAccountInfo#account_info{user_ids = [UserID | lists:delete(UserID,UserIDs)]};\n"
    "\t\t\tfalse ->\n"
    "\t\t\t\t#account_info{acc_name = AccName,user_ids = [UserID]}\n"
    "\t\tend,\n"
    "\t%% 帐号和对应玩家id列表映射\n"
    "\tets:insert(?ETS_ACCOUNT_INFO,AccountInfo1).\n"
    %"get_user_id_by_name(Name) ->\n"
    %"\tcase ets:lookup(?ETS_USER_NAME,Name) of\n"
    %"\t\t[#name_info{user_id = UserID}] ->\n"
    %"\t\t\tUserID;\n"
    %"\t\t[] ->\n"
    %"\t\t\t0\n"
    %"\tend.\n\n"
    %"get_user_name_by_id(UserID) ->\n"
    %"\tcase ets:lookup(?ETS_USER_ID, UserID) of\n"
    %"\t\t[#uid_info{name = Name}] ->\n"
    %"\t\t\tName;\n"
    %"\t\t[] ->\n"
    %"\t\t\tfalse\n"
    %"\tend.\n"
    "\n\n".

fun_get() ->
    fun_get(?DURABLE_RECORD_LIST,"").
fun_get([#durable_record{name = Name,keypos = KeyPos,is_preload = IsPreload} = DurableRecord | T], AccIn) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),

    MatchCase = 
        case is_integer(KeyPos) of
            true ->
                "\t\t[{Key," ++ Var ++"}] ->\n";
            false ->
                "\t\t[#" ++ RecordName ++ "{} = "++ Var ++"] ->\n" 
        end, 

    NewAccIn = 
        AccIn ++ 
        "get_" ++ RecordName  ++ "(Key) ->\n"
        "\tcase ets:lookup("++ EtsName ++ ", Key) of\n" ++
        MatchCase ++
        "\t\t\t" ++ Var ++ ";\n"
        "\t\t[] ->\n" ++
        case IsPreload of
            true ->
                "\t\t\tfalse\n"
                "\tend.\n\n";
            false ->
                "\t\t\tload_" ++ RecordName ++ "(Key)\n"
                "\tend.\n\n" ++
                fun_get2(DurableRecord)
        end,
    fun_get(T,NewAccIn);
fun_get([],AccIn) ->
    AccIn.

fun_get2(#durable_record{name = Name, is_user = IsUser, keypos = KeyPos}) ->
    RecordName = atom_to_list(Name),
    EtsName = ?ETS_RECORD_NAME(Name),
    Var = string:to_upper(atom_to_list(Name)),
    Var1 = Var ++ "1",

    "load_" ++ RecordName ++"(Key) ->\n" ++
    case IsUser of
        true when is_integer(KeyPos) ->
            "\t" ++ Var ++ " = edb_util:get_all(" ++ RecordName ++ ", [{user_id, Key}]),\n"
            "\t" ++ Var1 ++ " = [util:to_tuple([" ++ RecordName ++ " | E]) || E <- "  ++ Var ++ "],\n"
            "\tets:insert(" ++ EtsName ++ ",{Key," ++ Var1 ++ "}),\n"
            "\t" ++ Var1 ++ ".\n\n";
        true ->
            "\t case edb_util:get_row(" ++ RecordName ++ ", [{user_id, Key}]) of\n"
            "\t\t[] ->\n"
            "\t\t\t?WARNING(\"Data:~w Not Exit\", [Key]),\n"
            "\t\t\tfalse;\n"
            "\t\t" ++ Var ++ " ->\n"
            "\t\t\t" ++ Var1 ++ " = util:to_tuple([" ++ RecordName ++ " | " ++ Var ++ "]),\n"
            "\t\t\tets:insert(" ++ EtsName ++ ", " ++ Var1 ++ "),\n"
            "\t\t\t" ++ Var1 ++ "\n"
            "\tend.\n\n";
        _ ->
            "\tcase db_agent_"++ RecordName ++":find_" ++ RecordName ++ "(Key) of\n"
            "\t\t#" ++ RecordName ++ "{} = " ++ Var ++ " ->\n"
            "\t\t\tets:insert(" ++ EtsName ++ ", " ++ Var ++ "),\n"
            "\t\t\t" ++ Var ++ ";\n"
            "\t\t_ ->\n"
            "\t\t\t?WARNING(\"Data:~w Not Exit\",[Key]),\n"
            "\t\t\tfalse\n"
            "\tend.\n\n"
    end.


fun_new_user_init() ->
    "%% @doc 新号初始化ets\n"
    "new_user_init_ets(UserID) ->\n" ++
    lists:foldl(fun(#durable_record{name = Name, is_user = IsUser, record_list = RecordList},AccIn) ->
                    case IsUser of
                        true when Name == user ->
                            AccIn;
                        true when RecordList == true ->
                            AccIn ++ "\tets:insert("++ ?ETS_RECORD_NAME(Name) ++", {UserID, []}),\n";
                        true ->
                            AccIn ++ "\tets:insert("++ ?ETS_RECORD_NAME(Name) ++", #" ++ atom_to_list(Name) ++ "{user_id = UserID}),\n";
                        _ ->
                            AccIn
                    end
                end,"",?DURABLE_RECORD_LIST) ++
    "\tok.\n\n".
