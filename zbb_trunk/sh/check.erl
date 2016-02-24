%% ============================================================================
%% ================================ 机器授权检测 ==============================
%% ============================================================================
check() ->
    case catch do_check() of
        true ->
            ok;
        _ ->
            init:stop(),
            receive
                stop ->
                    false
            end
    end.

do_check() ->
    SourceIP = 
    case inet:getif() of
        {ok,IfList} ->
            lists:foldl(fun({{127,0,0,1},_,_},AccIn) ->
                            AccIn;
                        ({IpAddress,_,_},AccIn) ->
                        Ip = 
                        case IpAddress of
                            {A,B,C,D} ->
                                lists:concat([A,".",B,".",C,".",D]);
                            {A,B,C,D,E,F,G,H} ->
                                lists:concat([A,".",B,".",C,".",D,".",E,".",F,".",G,".",H])
                        end,
                        [Ip | AccIn]
                end,[],IfList);
        {error,_Reason} ->
            []
    end,
    
    {ok,EthList} = inet:getifaddrs(),
    F = fun({_,InfoList},AccIn) ->
            case lists:keyfind(hwaddr,1,InfoList) of
                false ->
                    AccIn;
                {_,[0,0,0,0,0,0]} ->
                    AccIn;
                {_, Hwaddr} ->
                    NewStrHwaddr = lists:foldl(fun(N,AccInStr) -> 
                                                Str = 
                                                case erlang:integer_to_list(N,16) of
                                                    [_] = S ->
                                                        "0" ++ S;
                                                    S ->
                                                        S
                                                end,
                                                case AccInStr of
                                                    "" ->
                                                        Str;
                                                    _ ->
                                                        AccInStr ++ ":" ++ Str
                                                end
                                              end,"",Hwaddr),
                    [NewStrHwaddr| AccIn]
            end
        end,         
    SourceAddr = lists:foldl(F,[],EthList),

    OsType =os:type(),
    OsVersion = os:version(),

    Time = util:timestamp() div 1000,
    Str = lists:concat([SourceIP,SourceAddr,Time,?AUTH_KEY]),
    Flag = util:md5(Str),

    ModuleInfo = ?MODULE:module_info(),

    {Compile,Source} = 
    case lists:keyfind(compile,1,ModuleInfo) of
        {compile,CompileList} ->
            CompileTime = 
            case lists:keyfind(time,1,CompileList) of
                {time,{Y,M,D,H,MM,S}} ->
                    lists:concat([Y,"-",M,"-",D," ",H,":",MM,":",S]);
                _ ->
                    ""
            end,
            SourceDir =
            case lists:keyfind(source,1,CompileList) of
                {source,Dir} ->
                    filename:dirname(Dir);
                _ ->
                    ""
            end,
            {CompileTime,SourceDir};
        _ ->
            {"",""}
    end,

    BuileVersion = get_build_version(),
    Auth = #auth{
                source_ip = SourceIP,       %% 请机器IP列表
                source_addr = SourceAddr,   %% 请求机器网卡地址
                version = BuileVersion,          %% 版本号
                compile = Compile,        %% 编译时间
                source = Source,         %% 代码路径
                os_type = OsType,        %% 操作系统类型
                os_version = OsVersion,     %% 操作系统版本
                plat = ?CONFIG_PLATFORM,           %% 平台
                server = lists:concat([?CONFIG_PREFIX,"_",?CONFIG_SERVER_ID]),         %% 服ID
                server_type = ?CONFIG_SERVER_TYPE,    %% 服类型
                time = Time,           %% 时间
                flag = Flag            %% 加密码编码
            },
    Bin = term_to_binary(Auth),
    
    %% 机器key,检查是否为测试服
    {ok,EthList} = inet:getifaddrs(),
    F2 = fun({_,InfoList},AccIn) ->
            case lists:keyfind(hwaddr,1,InfoList) of
                false ->
                    AccIn;
                {_, Hwaddr} ->
                    StrHwaddr = [erlang:integer_to_list(N,16) || N <- Hwaddr],
                    NewStrHwaddr = lists:foldl(fun(HwStr,AccInStr) -> lists:append(AccInStr,HwStr) end,"",StrHwaddr),
                    %io:format("NewStrHwaddr:~p~n",[NewStrHwaddr]),
                    lists:append(NewStrHwaddr,AccIn)
            end
        end,         
    NewEthList = lists:foldl(F2,"",EthList),

    
    OsVersion = os:version(),
    VersionList = tuple_to_list(OsVersion),
    VersionList2 = [N rem 255 || N <-VersionList],
    
    %% io:format("Version:~p,VersionList:~p,EhtList:~p~n",[Version,VersionList,NewEthList]),

    <<N:128>> = erlang:md5(VersionList2 ++ NewEthList ++ [32] ++ VersionList2),
    
    Key = lists:flatten(io_lib:format("~32.16.0b", [N])),

    AuthServer = 
    case lists:member(Key,?AUTH_TEST_SERVER_KEY) of
        true ->
            ?AUTH_TEST_SERVER;
        false ->
            ?AUTH_SERVER
    end,

    do_check2(AuthServer,Time,Auth,Bin).

do_check2([Server | T],Time,#auth{source_ip = SourceIP,source_addr = SourceAddr} = Auth,Bin) ->
    TcpOptions = [{active, false},{packet,2},binary],
    case gen_tcp:connect(Server,8888,TcpOptions,5000) of
        {ok,Socket} ->
            util:sleep(100),
            gen_tcp:send(Socket,Bin),
            case gen_tcp:recv(Socket,0,5000) of
                {ok,Packet} ->
                    catch gen_tcp:close(Socket),
                    check_recv(Time,SourceIP,SourceAddr,Packet);
                _ ->
                    do_check2(T,Time,Auth,Bin)
            end;
        _ ->
            do_check2(T,Time,Auth,Bin)
    end;
do_check2([],_Time,_Auth,_Bin) ->
    false.

check_recv(Time,SourceIP,SourceAddr,Packet) ->
    case binary_to_term(Packet) of
        {ok,Time2,Flag} ->
            case abs(Time -Time2) < 300 of
                true ->
                    Str = lists:concat([SourceIP,SourceAddr,Time2,?AUTH_KEY,1]),
                    Md5 = util:md5(Str),
                    Md5 == Flag;
                false ->
                    false
            end;
        _ ->
    ?INFO("Check Recv"),
            false
    end.

-ifdef(BUILD_VERSION).
get_build_version() ->
    ?BUILD_VERSION.
-else.
get_build_version() ->
    "".
-endif.
