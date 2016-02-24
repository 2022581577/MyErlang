#!/usr/bin/env escript
%%% @author : kongqingquan <kqqsysu@gmail.com>

-mode(compile).

-include("../include/common.hrl").
-include("../include/generation.hrl").

main(_Args) ->
    Name = "lib_dets",
    Str = get_header(Name) ++ get_define() ++ fun_init_dets() ++ fun_db_mask() ++ fun_check_record() ++ fun_sync() ++ fun_delete() ++ fun_save_dets(),
    FileName = Name ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    fun_parese_dets_macro(),
    ok.


%% @doc 头信息
get_header(Name) ->
    ?COPYRIGHT
    "-module(" ++ Name ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([init_dets/0,set_dets_db_mask/1,del_dets_db_mask/1,get_dets_db_mask_num/0,sync/1,delete_dets/1,check_record/0,save_dets/2]).\n\n".


%% @doc 预定内容
get_define() ->
    "%% 需要进行record检测的dets\n"
    "-define(DETS_OF_CHECK_RECORD,[" ++ get_check_define() ++ "]).\n".

get_check_define() ->
    lists:foldl(fun(#durable_record{name = Name},AccIn) ->
                case Name of
                    user_dic ->
                        AccIn;
                    pay_info ->
                        AccIn;
                    _ ->
                        NewAccIn = ?IF(AccIn == "", AccIn, AccIn ++ ","),
                        NewAccIn ++ ?DETS_RECORD_NAME(Name)
                end
               end,"",?DURABLE_RECORD_LIST).

fun_init_dets() ->
    "%% @doc 初始化dets\n"
    "init_dets() ->\n"
    "\t%% 确保文件夹路径的存在\n"
	"\tfilelib:ensure_dir(?DETS_DIR),"
    "\t%% 打开dets\n"
    "\tdets:open_file(?DETS_DB_MASK, [{file, ?DETS_FILE_NAME(?DETS_DB_MASK)}, {repair, force}]),    %% 玩家未存库掩码(存玩家id，全局数据直接存数据库表名)\n" ++
    lists:foldl(fun
            (#durable_record{name = pay_info},AccIn) -> %% pay_info不生成
                AccIn;
            (#durable_record{name = Name,keypos = KeyPos,ets_type = EtsType},AccIn) ->
                        DetsName = ?DETS_RECORD_NAME(Name),
                        StrKeyPos = ?KEYPOS(Name,KeyPos),
                        AccIn ++ "\tdets:open_file("++ DetsName  ++", [{file, ?DETS_FILE_NAME(" ++ DetsName  ++ ")}, {type, " ++ atom_to_list(EtsType) ++ "}," ++ StrKeyPos ++ ", {repair, force}]),\n"
                end,"",?DURABLE_RECORD_LIST) ++
    "\t%% 检测数据（record是否匹配）\n"
    "\tcheck_record(),\n"
    "\tlib_dets_util:check_record2(),\n"
    "\tok.\n\n".
%    "\t%% 根据玩家未存库掩码 检测是否与数据库匹配\n"
%    "\tcheck_db_mask().\n\n".


fun_db_mask() ->
    "%% 设置玩家（系统）未存库掩码\n"
    "set_dets_db_mask(ID) ->\n"
    "\tdets:insert(?DETS_DB_MASK, {ID}),\n"
    "\tok.\n"
    "%% 删除玩家（系统）未存库掩码\n"
    "del_dets_db_mask(ID) ->\n"
    "\tdets:delete(?DETS_DB_MASK, ID),\n"
    "\tok.\n"
    "%% 获取玩家（系统）未存库掩码数量\n"
    "get_dets_db_mask_num() ->\n"
    "\tdets:info(?DETS_DB_MASK, size).\n".    
%    "%% 检查是否已入库\n"
%    "check_db_mask() ->\n"
%    "\tF = fun({ID}, _) ->\n"
%    "\t\tcase is_integer(ID) of\n"
%    "\t\t\ttrue ->\n"
%    "\t\t\t\t?WARNING(\"Sync Save User Info:~w\",[ID]),\n"
%    "\t\t\t\tsave_user_info(ID);\n"
%    "\t\t\tfalse ->\n"
%    "\t\t\t\t?WARNING(\"Check Db Mask Error,ID:~w\",[ID])\n"
%    "\t\tend\n"
%    "\tend,"
%    "\tutil:dets_foldl(F, ok, ?DETS_DB_MASK).\n\n".



fun_check_record() ->
    "%% 检查record是否需要更新\n"
    "check_record() ->\n"
    "\t[do_check_record(E) || E <- ?DETS_OF_CHECK_RECORD].\n\n" ++
    fun_do_check_record().

fun_do_check_record() ->
    fun_do_check_record(?DURABLE_RECORD_LIST,"").
fun_do_check_record([#durable_record{name = user_dic} | T],AccIn) ->
    %% user_dic 不用生成
    fun_do_check_record(T,AccIn);
fun_do_check_record([#durable_record{name = pay_info} | T],AccIn) ->
    %% pay_info 不用生成
    fun_do_check_record(T,AccIn);
fun_do_check_record([#durable_record{name = Name} | T],AccIn) ->
    DetsName = ?DETS_RECORD_NAME(Name),
    RecordName = atom_to_list(Name),
    NewAccIn =
    AccIn ++
    "do_check_record("++ DetsName ++") ->\n"
    "\tNewFields = ?RECORD_FIELDS("++ RecordName ++"),\n"
    "\tcase dets:lookup(" ++ DetsName ++", ?RECORD_FILES_NAME) of\n"
    "\t\t[#record_files{files = NewFields}] ->\n"
    "\t\t\tok;\n"
    "\t\t[#record_files{files = Fields}] ->\n"
    "\t\t\t%% 把数据全部更新\n"
    "\t\t\tdets:delete(" ++ DetsName ++ ", ?RECORD_FILES_NAME),\n"
    "\t\t\tlib_dets_util:reset_record(" ++ DetsName ++ ", Fields, #" ++ RecordName ++"{}, NewFields),\n"
    "\t\t\t%% 重新设置record\n"
    "\t\t\tlib_dets_util:set_base_record("++ DetsName ++ ", #"++ RecordName ++ "{}, NewFields);\n"
    "\t\t[] ->\n"
    "\t\t\tlib_dets_util:set_base_record("++ DetsName ++ ", #"++ RecordName ++ "{}, NewFields);\n"
    "\t\tErr ->\n"
    "\t\t\t?WARNING(\"dets lookup Err:~w\", [Err]),\n"
    "\t\t\tdets:delete(" ++ DetsName ++ ", ?RECORD_FILES_NAME),\n"
    "\t\t\tlib_dets_util:set_base_record("++ DetsName ++ ", #"++ RecordName ++ "{}, NewFields)\n"
    "\tend",

    NewAccIn2 = 
    case T of
        [] ->
            NewAccIn ++ ".\n\n";
        _ ->
            NewAccIn ++ ";\n"
    end,
    fun_do_check_record(T,NewAccIn2);
fun_do_check_record([_ | T],AccIn) ->
    fun_do_check_record(T,AccIn);
fun_do_check_record([],AccIn) ->
    case AccIn of
        "" ->
             "do_check_record(_) ->\n"
             "\tok.\n\n";
         _ ->
             AccIn
     end.

fun_sync() ->
    "%% @doc 玩家数据入库\n"
    "sync(ID) ->\n" ++
    fun_sync2() ++
    "\tok.\n\n".

fun_sync2() ->
    UserStatus  = lists:keyfind(user_status,#durable_record.name, ?DURABLE_RECORD_LIST),
    UserDic  = lists:keyfind(user_dic,#durable_record.name, ?DURABLE_RECORD_LIST),
    DurableList1 = lists:keydelete(user_status,#durable_record.name,?DURABLE_RECORD_LIST),
    DurableList2 = lists:keydelete(user_dic,#durable_record.name,DurableList1),
    DurableList3 = [UserDic | DurableList2] ++ [UserStatus],
    fun_sync2(DurableList3,"").
fun_sync2([#durable_record{name = Name,keypos = KeyPos,is_user = true} | T],AccIn) when is_integer(KeyPos) ->
    Var = ?TO_UPPER(Name),
    NewAccIn = 
    AccIn ++ 
    "\tcase ets:lookup(" ++ ?ETS_RECORD_NAME(Name) ++ ", ID) of\n"
    "\t\t[{ID," ++ Var ++ "}] ->\n"
    "\t\t\tdb_agent_"++ atom_to_list(Name) ++":update_"++ atom_to_list(Name) ++ "(ID," ++ Var ++ ");\n"
    "\t\t_ ->\n"
    "\t\t\tcase dets:lookup(" ++ ?DETS_RECORD_NAME(Name) ++", ID) of\n"
    "\t\t\t\t[{ID," ++ Var ++ "}] ->\n"
    "\t\t\t\t\tdb_agent_"++ atom_to_list(Name) ++":update_"++ atom_to_list(Name) ++ "(ID," ++ Var ++ ");\n" ++
    "\t\t\t\t[] ->\n"
    "\t\t\t\t\tskip;\n"
    "\t\t\t\t_ ->\n"
    "\t\t\t\t\t?WARNING(\"Reset " ++ atom_to_list(Name) ++" Fail,ID:~w\",[ID])\n"
    "\t\t\tend\n"
    "\tend,\n",
    fun_sync2(T,NewAccIn);
fun_sync2([#durable_record{name = Name,is_user = true} | T],AccIn) ->
    %% record
    Var = ?TO_UPPER(Name),
    NewAccIn = 
    AccIn ++ 
    "\tcase ets:lookup(" ++ ?ETS_RECORD_NAME(Name) ++ ", ID) of\n"
    "\t\t[#" ++ atom_to_list(Name) ++ "{} = " ++ Var ++"] ->\n"
    "\t\t\tdb_agent_"++ atom_to_list(Name) ++":update_"++ atom_to_list(Name) ++ "(" ++ Var ++ ");\n"
    "\t\t_ ->\n"
    "\t\t\tcase dets:lookup(" ++ ?DETS_RECORD_NAME(Name) ++" , ID) of\n"
    "\t\t\t\t[#" ++ atom_to_list(Name) ++ "{} = " ++ Var ++"] ->\n"
    "\t\t\t\t\tdb_agent_"++ atom_to_list(Name) ++":update_"++ atom_to_list(Name) ++ "(" ++ Var ++ ");\n" ++
    "\t\t\t\t[] ->\n"
    "\t\t\t\t\tskip;\n"
    "\t\t\t\t_ ->\n"
    "\t\t\t\t\t?WARNING(\"Reset " ++ atom_to_list(Name) ++" Fail,ID:~w\",[ID])\n"
    "\t\t\tend\n"
    "\tend,\n",
    fun_sync2(T,NewAccIn);
fun_sync2([_ | T],AccIn) ->
    fun_sync2(T,AccIn);
fun_sync2([],AccIn) ->
    AccIn.

fun_delete() ->
    "%% @doc 删除某个玩家的所有dets信息\n"
    "delete_dets(UserID) ->\n" ++
    lists:foldl(fun(#durable_record{name = Name,is_user = IsUser},AccIn) ->
                case IsUser of
                    true ->
                        AccIn ++ "\tdets:delete("++ ?DETS_RECORD_NAME(Name) ++", UserID),\n";
                    false ->
                        AccIn
                end
                end,"",?DURABLE_RECORD_LIST) ++
    "\tdel_dets_db_mask(UserID).\n\n".

fun_parese_dets_macro() ->
    List = parse_dets_define("./include/dets.hrl","./include/"),
    AtomList =  lists:concat(["," ++ atom_to_list(A)  || A <- List]),
    Context = "\-define(DETS_LIST" ++ ",[global_data_disk" ++ AtomList ++ "]" ++ ").\n",
    file:write_file("./include/dets_list.hrl", Context),
    ok.

parse_dets_define(FileName, IncludePath) ->
    try
        case epp:open(FileName, IncludePath) of
            {ok, Epp} ->
                epp:parse_file(Epp),
                List = epp:macro_defs(Epp),
                List2 = [Macro || {_,[_]} = Macro <- List],
                NameList = [Name || {_,[{_,{_,[{_,_,Name}]}}]} <- List2],
                %?INFO("======== NameList:~w ======",[NameList]),
                epp:close(Epp),
                NameList;
            {error, Err2} ->
                ?WARNING("open dets header file error, Err:~w",[Err2]),
                []
        end
    catch
		Err3:Reason ->
			?WARNING2("parse dets define file fail, Err:~w, Reason:~w",[Err3, Reason]),
            []
    end.

fun_save_dets() ->
    "%% @doc 保存dets\n"
    "save_dets(UserID, " ++ make_save_info() ++ ") ->\n" ++
    lists:foldl(fun(#durable_record{name = Name, is_user = IsUser, keypos = Keypos},AccIn) ->
                    Var = ?TO_UPPER(Name),
                    case IsUser of
                        true when Keypos == user_id ->
                            AccIn ++
                            "\tcase " ++ Var ++ " of\n"
                            "\t\tundefined ->   skip;\n"
                            "\t\t_ ->\n"
                            "\t\t\tdets:insert(" ++ ?DETS_RECORD_NAME(Name) ++ ", " ++ Var ++ ")\n"
                            "\tend,\n";
                        true ->
                            AccIn ++
                            "\tcase " ++ Var ++ " of\n"
                            "\t\tundefined ->   skip;\n"
                            "\t\t_ ->\n"
                            "\t\t\tdets:insert(" ++ ?DETS_RECORD_NAME(Name) ++ ", {UserID, " ++ Var ++ "})\n"
                            "\tend,\n";
                        _ ->
                            AccIn
                    end
                end,"",?DURABLE_RECORD_LIST) ++
    "\tok.\n\n".

make_save_info() ->
    [$, | Elem] = 
    lists:foldl(fun(#durable_record{name = Name, is_user = IsUser},AccIn) ->
                    Var = ?TO_UPPER(Name),
                    case IsUser of
                        true ->
                            AccIn ++ ",\n\t\t\t\t\t\t\t" ++ atom_to_list(Name) ++ " = " ++ Var;
                        _ ->
                            AccIn
                    end
                end,"",?DURABLE_RECORD_LIST),
    "#save_info{" ++ Elem ++ "}".

