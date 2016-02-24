#!/usr/bin/env escript
%%% @author : kongqingquan <kqqsysu@gmail.com>


-mode(compile).

-include("../include/common.hrl").
-include("../include/generation.hrl").

main(_Args) ->
    gen_normal(),
    gen_preload(),
    ok.

gen_normal() ->
    gen_normal(?DURABLE_RECORD_LIST).
gen_normal([#durable_record{name = Name, record_list = true,is_user = IsUser,write_mode = WriteMode} | T]) ->
    RecordName = atom_to_list(Name),
    Mod = "db_agent_" ++ RecordName,
    
    Str =
    ?COPYRIGHT
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([find_" ++ RecordName ++ "/0,find_" ++ RecordName ++ "/1,update_" ++ RecordName ++ "/2]).\n\n"
    "%% @doc 加载所有\n"
    "find_" ++ RecordName ++ "() ->\n"
    "\tAllList = mongo_tool:find("++ RecordName ++", {}),\n\n"
    "\tAllList2 = [{ID,DocList} || {'_id', ID, list, DocList} <- AllList],\n"
    "\tF = fun({ID,DocList}, AccIn) ->\n"
    "\t\t\tNewL =\n"
    "\t\t\tcase DocList of\n"
    "\t\t\t\t[] ->\n"
    "\t\t\t\t\t[];\n"
    "\t\t\t\t[#record_files{} | T] ->\n"
    "\t\t\t\t\t[mongo_tool:gen_record(?RECORD_FIELDS("++RecordName++"),Doc,#"++RecordName++"{}) || Doc <- T];\n"
    "\t\t\t\t_ ->\n"
    "\t\t\t\t\t[mongo_tool:gen_record(?RECORD_FIELDS("++RecordName++"),Doc,#"++RecordName++"{}) || Doc <- DocList]\n"
    "\t\t\tend,\n"
    "\t\t\t[{ID,NewL} | AccIn]\n"
    "\tend,\n"
    "\tlists:foldl(F, [], AllList2).\n"

    "%% 加载一条\n"
    "find_" ++ RecordName ++ "(ID) ->\n"
    "\tcase  mongo_tool:find_one("++ RecordName ++ ", ID) of\n"
    "\t\t{} ->\n"
    "\t\t\t[];\n"
    "\t\t{{'_id', ID,list, DocList}} ->\n"
    "\t\t\tcase DocList of\n"
    "\t\t\t\t[] ->\n"
    "\t\t\t\t\t[];\n"
    "\t\t\t\t[#record_files{} | T] ->\n"
    "\t\t\t\t\t[mongo_tool:gen_record(?RECORD_FIELDS("++RecordName++"),Doc,#"++RecordName++"{}) || Doc <- T];\n"
    "\t\t\t\t_ ->\n"
    "\t\t\t\t\t[mongo_tool:gen_record(?RECORD_FIELDS("++RecordName++"),Doc,#"++RecordName++"{}) || Doc <- DocList]\n"
    "\t\t\tend\n"
    %"\t\t\t[mongo_tool:gen_record_list(?RECORD_FIELDS("++ RecordName ++"),Doc,#"++ RecordName ++"{},0) || Doc <- List]\n"
    "\tend.\n\n"
    "%% @doc 保存信息\n"
    "update_" ++ RecordName ++ "(ID, List) ->\n" ++

    "\tNewList = [mongo_tool:gen_doc2(?RECORD_FIELDS("++RecordName++"),Item) || Item <- List],\n"
    "\tDoc = {'_id', ID, list, {db_list,NewList}},\n" ++
    gen_update(RecordName,IsUser,WriteMode) ++ ".\n\n",
    
    FileName = Mod ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    gen_normal(T);

gen_normal([#durable_record{name = Name,keypos = KeyPos,is_preload = false,is_user = IsUser,write_mode = WriteMode} | T]) when is_integer(KeyPos) ->

    RecordName = atom_to_list(Name),
    Mod = "db_agent_" ++ RecordName,

    Str =
    ?COPYRIGHT
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([find_" ++ RecordName ++ "/0,find_" ++ RecordName ++ "/1,update_" ++ RecordName ++ "/2]).\n\n"
    "%% @doc 加载所有\n"
    "find_" ++ RecordName ++ "() ->\n"
    "\tAllList = mongo_tool:find("++ RecordName ++", {}),\n\n"
    "\tAllList2 = [{ID,DocList} || {'_id', ID, list, DocList} <- AllList],\n"
    "\t[{ID,mongo_tool:db_to_term(Doc)} || {ID,Doc} <- AllList2].\n\n"
    "%% 加载一条\n"
    "find_" ++ RecordName ++ "(ID) ->\n"
    "\tcase  mongo_tool:find_one("++ RecordName ++ ", ID) of\n"
    "\t\t{} ->\n"
    "\t\t\t[];\n"
    "\t\t{{'_id', ID,list, DocList}} ->\n" ++
    case Name of
        user_dic ->
            "\t\t\tmongo_tool:db_to_term(DocList)\n";
        _ ->
            "\t\t\tList = mongo_tool:db_to_term(DocList),\n"
            "\t\t\t[mongo_tool:gen_record_list(?RECORD_FIELDS("++ RecordName ++"),Doc,#"++ RecordName ++"{},0) || Doc <- List]\n"
    end ++
    "\tend.\n\n"
    "%% @doc 保存信息\n"
    "update_" ++ RecordName ++ "(ID, List) ->\n" ++
    case Name of
        user_dic ->
            "\tDoc = {'_id',ID,list,List},\n";
        _ ->
            "\tDocList = [mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ "), Item, 0) || Item <- List],\n"
            "\tDoc = {'_id', ID, list, DocList},\n"
    end ++
    gen_update(RecordName,IsUser,WriteMode) ++ ".\r\n\n",
    
    FileName = Mod ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    gen_normal(T);
gen_normal([#durable_record{name = Name,keypos = KeyPos,is_preload = false,is_user = IsUser,write_mode = WriteMode} | T]) ->

    RecordName = atom_to_list(Name),
    Mod = "db_agent_" ++ RecordName,

    Str =
    ?COPYRIGHT
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([find_" ++ RecordName ++ "/0,find_" ++ RecordName ++ "/1,update_" ++ RecordName ++ "/1,insert_" ++ RecordName ++ "/1]).\n\n"
    "%% @doc 加载所有\n"
    "find_" ++ RecordName ++ "() ->\n"
    "\tmongo_tool:find("++ RecordName ++", {}).\n\n"
    "%% @doc 获取一条信息\n"
    "find_" ++ RecordName ++ "(ID) ->\n"
    "\tcase  mongo_tool:find_one(" ++ RecordName ++ ",ID) of\n"
    "\t\t{} ->\n" ++
    case Name of
        user_status ->
            "\t\t\tfalse;\n";
        _ ->
            "\t\t\t#" ++ RecordName ++ "{" ++ atom_to_list(KeyPos) ++ " = ID};\n"
    end ++
    "\t\t{Doc} ->\n"
    "\t\t\tmongo_tool:gen_record(?RECORD_FIELDS(" ++ RecordName ++ "),Doc,#" ++ RecordName ++ "{})\n"
    "\tend.\n\n"
    "%% @doc 更新状态\n"
    "update_" ++ RecordName ++ "(#" ++ RecordName ++ "{" ++ atom_to_list(KeyPos) ++" = ID} = " ++ ?TO_UPPER(Name) ++ " ) ->\n" ++
    case Name of
        user_status ->
            "\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ ")," ++ ?TO_UPPER(Name) ++ "#user_status{socket = undefined,map_pid = undefined}),\n";
        _ ->
            "\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ ")," ++ ?TO_UPPER(Name) ++ "),\n"
    end ++
    gen_update(RecordName,IsUser,WriteMode) ++ ".\n\n"
    "%% @doc 插入操作\n"
    "insert_" ++ RecordName ++ "(#" ++ RecordName ++ "{} = " ++ ?TO_UPPER(Name) ++ ") ->\n\t" ++
    case IsUser of
        true ->
            "Context=mongo_tool:get_user_context(safe),";
        _ ->
            "Context=mongo_tool:get_global_context(safe),"
    end ++
    "\n\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ ")," ++ ?TO_UPPER(Name) ++ "),\n"
    "\tmongo_tool:insert(Context," ++ RecordName ++ ",Doc).\n",
    
    FileName = Mod ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    gen_normal(T);
gen_normal([#durable_record{is_preload = true} | T]) ->
    gen_normal(T);
gen_normal([]) ->
    ok.

gen_preload() ->
    gen_preload(?DURABLE_RECORD_LIST).
gen_preload([#durable_record{name = Name, keypos=KeyPos,record_fields = {FieldsName1,FieldsRecord1},is_user = IsUser,write_mode = WriteMode} | T]) ->
    RecordName = atom_to_list(Name),
    FieldsName = atom_to_list(FieldsName1),
    FieldsRecord = atom_to_list(FieldsRecord1),
    Var = string:to_upper(RecordName),
    Mod = "db_agent_" ++ RecordName,
    Str =
    ?COPYRIGHT
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([find_" ++ RecordName ++ "/0,update_" ++ RecordName ++ "/1,del_" ++ RecordName ++ "/1]).\n\n"
    "%% @doc 加载所有\n"
    "find_" ++ RecordName ++ "() ->\n"
    "\tList = mongo_tool:find("++ RecordName ++", {}),\n"
    "\t[begin \n"
    "\t\t#"++ RecordName++"{" ++ FieldsName ++ "=DataList} = Info2 = mongo_tool:gen_record(?RECORD_FIELDS("++RecordName++"), Info, #"++RecordName++"{}),\n"
    "\t\tNewData = [mongo_tool:gen_record(?RECORD_FIELDS(" ++ FieldsRecord ++"), Data,#" ++ FieldsRecord ++ "{}) || Data <- DataList],\n"
    "\t\tInfo2#"++RecordName++"{" ++ FieldsName ++ "=NewData}\n"
    "\tend || Info <- List].\n"
    "%% @doc 添加or更新\n" ++
    "update_" ++ RecordName ++ "(#" ++ RecordName ++ "{" ++ atom_to_list(KeyPos) ++ "=ID, " ++ FieldsName ++ "=DataList} = " ++ Var ++") ->\n"
    "\tNewData = [mongo_tool:gen_doc2(?RECORD_FIELDS(" ++ FieldsRecord ++ "), Data) || Data <- DataList],\n"
    "\tNewVar = "++ Var ++"#"++ RecordName ++"{" ++ FieldsName ++ "={db_list,NewData}},\n"
    "\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS("++RecordName++"), NewVar),\n" ++
    gen_update(RecordName,IsUser,WriteMode) ++ ".\n\n"
    "%% @doc 删除\n"
    "del_" ++ RecordName ++ "(ID) ->\n"
    "\tmongo_tool:delete("++ RecordName ++ ", {'_id', ID}).\n\n",
    
    FileName = Mod ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    gen_preload(T);

gen_preload([#durable_record{name = Name,is_preload = true,keypos = KeyPos, db_keypos = DbKeyPos,is_user = IsUser,write_mode = WriteMode} | T]) ->
    RecordName = atom_to_list(Name),
    Var = string:to_upper(RecordName),
    Mod = "db_agent_" ++ RecordName,
    NewKeyPos = ?IF(Name == pay_info, DbKeyPos, KeyPos),
    
    {UpdateArgs,FunName} =
    case is_integer(NewKeyPos) of
        true ->
            {"2","update_" ++ RecordName ++ "(ID," ++ Var ++") ->\n"};
        false ->
            {"1","update_" ++ RecordName ++ "(#" ++ RecordName ++ "{" ++ atom_to_list(NewKeyPos) ++ "=ID} = " ++ Var ++ ")->\n"}
    end,
    %% 对充值增加多一个log表
    {LogExprot, PayLog} = 
        case Name of
            pay_info ->
                {"update_log_" ++ RecordName ++ "/1,",
                    "%% @doc 添加or更新log\n" ++
                    "update_log_" ++ RecordName ++ "(#" ++ RecordName ++ "{" ++ atom_to_list(NewKeyPos) ++ "=ID} = " ++ Var ++ ")->\n"
                    "\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ "), " ++ Var ++"),\n" ++
                    gen_update("log_" ++ RecordName,true,safe) ++ ".\n\n"};
            _ ->
                {"", ""}
        end,

    Str =
    ?COPYRIGHT
    "-module(" ++ Mod ++ ").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([find_" ++ RecordName ++ "/0,update_" ++ RecordName ++ "/" ++ UpdateArgs ++ "," ++ LogExprot ++ "del_" ++ RecordName ++ "/1]).\n\n"
    "%% @doc 加载所有\n"
    "find_" ++ RecordName ++ "() ->\n"
    "\tmongo_tool:find("++ RecordName ++", {}).\n\n"
    "%% @doc 添加or更新\n" ++
    FunName ++
    "\tDoc = mongo_tool:gen_doc(?RECORD_FIELDS(" ++ RecordName ++ "), " ++ Var ++"),\n" ++
    case Name of
        pay_info ->
            gen_update(RecordName,true,safe);
        _ ->
            gen_update(RecordName,IsUser,WriteMode)
    end ++ ".\n\n" ++
    "%% @doc 删除\n"
    "del_" ++ RecordName ++ "(ID) ->\n"
    "\tmongo_tool:delete("++ RecordName ++ ", {'_id', ID}).\n\n" 
    ++ PayLog,
    
    FileName = Mod ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    gen_preload(T);
gen_preload([#durable_record{is_preload = false} | T]) ->
    gen_preload(T);
gen_preload([]) ->
    ok.

gen_update(RecordName,true,WriteMode) ->
    "\tContext = mongo_tool:get_user_context(" ++ atom_to_list(WriteMode) ++ "),\n"
    "\tmongo_tool:update(" ++ RecordName ++ ", ID, Doc,true,false,Context)";
gen_update(RecordName,_IsUser,WriteMode) ->
    "\tContext = mongo_tool:get_global_context(" ++ atom_to_list(WriteMode) ++ "),\n"
    "\tmongo_tool:update(" ++ RecordName ++ ", ID, Doc,true,false,Context)".


