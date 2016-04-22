-define(COPYRIGHT,"%% Generate by code robot @ binbinjnu@163.com>\n%% All rights reserved\n").
-define(DESC(Desc), "%% @desc " ++ Desc ++ "\n\n").
-define(CODE_DIR,"src/game/").
-define(WRITE_FILE(FileName,Str),(fun() ->
                           Dir = ?CODE_DIR,
                           filelib:ensure_dir(Dir),
                           FilePath = filename:join(Dir,FileName),
                           %?PRINT("Gen File:~s,Path:~s~n,Str:~p~n",[FileName,FilePath,Str]),
                           case file:open(FilePath,[write,raw]) of 
                               {ok,Fd} ->
                                   ok = file:write(Fd, unicode:characters_to_binary(Str)),
                                   file:sync(Fd),file:close(Fd),
                                   io:format("Gen File:~s Success~n",[FileName]);
                               {error,Reason} ->
                                   io:format("Open file fail:~p~n",[Reason])
                           end
                   end)()).

-define(ETS_RECORD_NAME(EtsName),(fun()-> string:to_upper(lists:concat(["?ETS_",EtsName])) end)()).
-define(KEYPOS(KeyPosName,KeyPos),(fun()->
                case is_integer(KeyPos) of
                    true ->
                        lists:concat(["{keypos,",KeyPos,"}"]);
                    false ->
                        lists:concat(["{keypos,#",KeyPosName,".",KeyPos,"}"])
                end
                end)()).
-define(TO_UPPER(Name),(fun()->
                        NewName =
                        case is_list(Name) of
                            true ->
                                Name;
                            false ->
                                atom_to_list(Name)
                        end,
                        string:to_upper(NewName)
                        end)()).
