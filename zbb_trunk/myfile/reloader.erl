%%%----------------------------------------------------------------------
%%% @author : kongqingquan <kqqsysu@gmail.com>
%%% @date   : 2013.06.15.
%%% @desc   : 代码加载模块
%%%----------------------------------------------------------------------

-module(reloader).
-author('kongqingquan <kqqsysu@gmail.com>').

-export([reload_modules/1,
         reload_modules/2,
         init/0,
         check_reload/0,
         do_check_reload/0
        ]).
-include("common.hrl").
-include("file.hrl").

-define(BEAM_TIME,beam_time).
-define(RELOAD_TIME,reload_time).


reload_modules(Modules) ->
    reload_modules(Modules,false).

reload_modules(Modules,IsForce) ->
    lists:foldl(fun(Mod,AccIn) ->
                    ?INFO("Reload Module:~s",[Mod]),
                    ModName = util:to_atom(Mod),
                    IsLoad =
                        case IsForce of
                            true ->
                                code:purge(ModName),
                                true;
                            false ->
                                code:soft_purge(ModName)
                        end,
                    case IsLoad of
                        true ->
                            case code:load_file(ModName) of
                                {module,ModName} ->
                                    AccIn;
                                _ ->
                                    [Mod | AccIn]
                            end;
                        false ->
                            [Mod | AccIn]
                    end
                end,[],Modules).

%% @doc 初始化模块信息
init() ->
    BeamList = get_beam_list(),
    Atime = get_file_time(),
    set_reload_time(Atime),
    lists:foreach(fun({Name,Time}) ->
                        set_beam_time(Name,Time)
                  end,BeamList),

    case is_auto_reload() of
        true ->
            pre_load_beams();
        _ ->
            skip
    end,
    ok.

%% 提前加载beam
pre_load_beams() ->
    Path = filename:dirname(code:which(?MODULE)) ++ "/",
    {ok,BeamList} = file:list_dir(Path),
    do_pre_load_beams(BeamList).
do_pre_load_beams([H | T]) ->
    case string:tokens(H,".") of
        [StrName,"beam"] ->
            Name = util:to_atom(StrName),
            code:load_file(Name);
        _ ->
            skip
    end,
    do_pre_load_beams(T);
do_pre_load_beams([]) ->
    ok.

check_reload() ->
    case is_auto_reload() of
        true ->
            check_reload2();
        _ ->
            skip
    end.

check_reload2() ->
    Atime = get_file_time(),
    LastAtime = get_reload_time(),
    case Atime > LastAtime of
        true ->
            ?INFO("+++++++++++++++++++ Reload Module ++++++++++++++++ "),
            case do_check_reload() of
                [] ->
                    set_reload_time(Atime),
                    lib_npc:reload_npc();
                _ ->
                    skip
            end;
        false ->
            skip
    end.

do_check_reload() ->
    BeamList = get_beam_list(),
    lists:foldl(fun({Name,Time},AccIn) ->
                    OldTime = get_beam_time(Name),
                    case OldTime of
                        Time ->
                            AccIn;
                        _ ->
                            case reload_modules([Name]) of
                                [] ->
                                    set_beam_time(Name,Time),
                                    AccIn;
                                _ ->
                                    [Name | AccIn]
                            end
                    end
                 end,[],BeamList).



%% @doc 获取beam信息，返回 [{beam,time}...]
get_beam_list() ->
    Path = filename:dirname(code:which(data_item)) ++ "/",
    CheckDir = [Path],
    get_beam_list(CheckDir,[]).
get_beam_list([H | T],AccIn) ->
    {ok,BeamList} = file:list_dir(H),
    NewAccIn = get_beam_info(BeamList,H,AccIn),
    get_beam_list(T,NewAccIn);
get_beam_list([],AccIn) ->
    AccIn.

get_beam_info([H | T],Path,AccIn) ->
    NewAccIn =
    case string:tokens(H,".") of
        [StrName,"beam"] ->
            Name = util:to_atom(StrName),
            case lists:keyfind(Name,1,AccIn) of
                false ->
                    BeamPath = Path ++ H,
                    {ok,{_,[{compile_info,CompileInfo}]}} = beam_lib:chunks(BeamPath,[compile_info]),
                    {time,Time} = lists:keyfind(time,1,CompileInfo),
                    [{Name,Time} | AccIn];
                _ ->
                    AccIn
             end;
         _ ->
             AccIn
     end,
    get_beam_info(T,Path,NewAccIn);
get_beam_info([],_Path,AccIn) ->
    AccIn.

get_beam_time(Name) ->
    case get({?BEAM_TIME,Name}) of
        undefined ->
            0;
        T ->
            T
    end.
set_beam_time(Name,Time) ->
    put({?BEAM_TIME,Name},Time).

is_auto_reload() ->
    ?CONFIG(auto_reload).

get_reload_time() ->
    case get(?RELOAD_TIME) of
        undefined ->
            0;
        N ->
            N
    end.
set_reload_time(T) ->
    put(?RELOAD_TIME,T).

get_file_time() ->
    File = filename:dirname(code:which(data_item)) ++ "/beam_mask",
    case file:read_file_info(File) of
        {ok,#file_info{mtime = Atime}} ->
            Atime;
        _ ->
            0
    end.

