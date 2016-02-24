#!/usr/bin/env escript
%%% @author : kongqingquan <kqqsysu@gmail.com>

-mode(compile).

-include("../include/common.hrl").
-include("../include/generation.hrl").

main(_Args) ->
    Name = "lib_user_dic",
    Str = get_header(Name) ++ get_define() ++ fun_init_dic() ++ fun_get_dic_list(),
    FileName = Name ++ ".erl",
    ?WRITE_FILE(FileName,Str),
    ok.


%% @doc 头信息
get_header(Name) ->
    ?COPYRIGHT
    "-module("++ Name ++").\n"
    "-include(\"common.hrl\").\n"
    "-include(\"record.hrl\").\n\n"
    "-export([init_dic/1,get_dic_lists/0]).\n\n".


%% @doc 预定内容
get_define() ->
    "-define(SAVE_DB_DIC_LIST,[" ++ get_dic_define() ++ "]).\n"
    "-define(NEED_INIT_DIC_LIST,[" ++ get_init_define() ++ "]).\n\n".

get_dic_define() ->
    lists:foldl(fun({Key,_RecordName},AccIn) ->
                    NewAccIn = ?IF(AccIn == "",AccIn,AccIn ++ ","),
                    NewAccIn ++ Key
                end,"",?SAVE_DB_DIC_LIST).
get_init_define() ->
    lists:foldl(fun({Key,Val},AccIn) ->
                    NewAccIn = ?IF(AccIn == "",AccIn,AccIn ++ ","),
                    lists:concat([NewAccIn,"{",Key,",",Val,"}"])
                end,"",?NEED_INIT_DIC_LIST).

%% @doc 生成 fun init_dic
fun_init_dic() ->
    "%% @doc 初始化user的dic\n"
    "init_dic(List) ->\n"
    "\tlists:foreach(fun({Key,Default}) -> put(Key,Default) end,?NEED_INIT_DIC_LIST),\n"
    "\tNewList = [{{dic,K},Val} || {K,Val} <- List],\n"
    "\tdo_init_dic(NewList).\n\n"
    "%% 对内容为doc的数据进行转换 doc -> record\n" ++
    gen_fun_init_dic(?SAVE_DB_DIC_LIST,"") ++ 
    "do_init_dic([{Key,Val} | T]) ->\n"
    "\tcase Val of\n"
    "\t\tundefined ->\n"
    "\t\t\tskip;\n"
    "\t\t_ ->\n"
    "\t\t\tput(Key,Val)\n"
    "\tend,\n"
    "\tdo_init_dic(T);\n"
    "do_init_dic([]) ->\n"
    "\tok.\n\n".

gen_fun_init_dic([{_Key,false} | T],AccIn) ->
    gen_fun_init_dic(T,AccIn);
gen_fun_init_dic([{Key,{list,Record}} | T],AccIn) ->
    NewAccIn = 
    AccIn ++
    "do_init_dic([{" ++ Key ++",undefined} | T]) ->\n"
    "\tdo_init_dic(T);\n"
    "do_init_dic([{" ++ Key ++" = Key,ValList} | T]) ->\n"
    "\tRecordVal = [mongo_tool:gen_record_list(?RECORD_FIELDS(" ++ atom_to_list(Record) ++ "), Val, #" ++ atom_to_list(Record) ++  "{}, 0) || Val <- ValList],\n" ++
    "\tput(Key, RecordVal),\n" 
    "\tdo_init_dic(T);\n",
    gen_fun_init_dic(T,NewAccIn);
gen_fun_init_dic([{Key,Record} | T],AccIn) ->
    NewAccIn = 
    AccIn ++
    "do_init_dic([{" ++ Key ++",undefined} | T]) ->\n"
    "\tdo_init_dic(T);\n"
    "do_init_dic([{" ++ Key ++" = Key,Val} | T]) ->\n"
    "\tRecordVal = mongo_tool:gen_record_list(?RECORD_FIELDS(" ++ atom_to_list(Record) ++ "), Val, #" ++ atom_to_list(Record) ++  "{}, 0),\n" ++
    "\tput(Key, RecordVal),\n" 
    "\tdo_init_dic(T);\n",
    gen_fun_init_dic(T,NewAccIn);
gen_fun_init_dic([],AccIn) ->
    AccIn.


fun_get_dic_list() ->
    "%% @doc 下线获取需保存数据库的进程字典列表\n"
    "get_dic_lists() ->\n"
    "\tdo_get_dic_lists(?SAVE_DB_DIC_LIST,[]).\n\n"
    "%% 对内容为record的数据进行转换 record -> doc\n" ++
    gen_get_dic_list(?SAVE_DB_DIC_LIST,"") ++
    "do_get_dic_lists([H = {dic,Key} | T],AccIn) ->\n"
    "\tVal = get(H),\n"
    "\tdo_get_dic_lists(T,[{Key,Val} | AccIn]);\n"
    "do_get_dic_lists([],AccIn) ->\n"
    "\tAccIn.".

gen_get_dic_list([{_Key,false} | T],AccIn) ->
    gen_get_dic_list(T,AccIn);
gen_get_dic_list([{Key,{list,Record}} | T],AccIn) ->
    NewAccIn =
    AccIn ++
    "do_get_dic_lists([" ++ Key ++ " = {dic,Key} | T],AccIn) ->\n"
    "\tcase get(" ++ Key ++ ") of\n"
    "\t\tundefined ->\n"
    "\t\t\tdo_get_dic_lists(T,AccIn);\n"
    "\t\tValList ->\n"
    "\t\t\tDocVal = [mongo_tool:gen_doc(?RECORD_FIELDS("++ atom_to_list(Record) ++"), Val, 0) || Val <- ValList],\n"
    "\t\t\tdo_get_dic_lists(T,[{Key,DocVal} | AccIn])\n"
    "\tend;\n",
    gen_get_dic_list(T,NewAccIn);
gen_get_dic_list([{Key,Record} | T],AccIn) ->
    NewAccIn =
    AccIn ++
    "do_get_dic_lists([" ++ Key ++ " = {dic,Key} | T],AccIn) ->\n"
    "\tcase get(" ++ Key ++ ") of\n"
    "\t\tundefined ->\n"
    "\t\t\tdo_get_dic_lists(T,AccIn);\n"
    "\t\tVal ->\n"
    "\t\t\tDocVal = mongo_tool:gen_doc(?RECORD_FIELDS("++ atom_to_list(Record) ++"), Val, 0),\n"
    "\t\t\tdo_get_dic_lists(T,[{Key,DocVal} | AccIn])\n"
    "\tend;\n",
    gen_get_dic_list(T,NewAccIn);
gen_get_dic_list([],AccIn) ->
    AccIn.
