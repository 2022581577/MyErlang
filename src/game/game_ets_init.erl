%%%----------------------------------------------------------------------
%%% @author : 
%%% @date   : 2016.02.27
%%% @desc   : ets初始化模块
%%%----------------------------------------------------------------------

-module(game_ets_init).
-include("common.hrl").
-include("record.hrl").

-export([init/0]).

init() ->
    ets:new(?ETS_USER_ONLINE,[{keypos,#user_online.user_id},named_table,public,set,{read_concurrency,true}]),   %% 玩家在线

    ets:new(?ETS_MAP_ID_LIST,[{keypos,1},named_table,public,set,{read_concurrency,true}]),                      %% 地图MapID,IndexIDList映射
    ets:new(?ETS_MAP_INFO,[{keypos,#map_info.map_inst_id},named_table,public,set,{read_concurrency,true}]),    %% 地图MapInstID:{map_id, index_id}信息映射
    ets:new(?ETS_MAP_CONFIG, [{keypos, #tpl_map_config.source_id}, named_table, public, set, {read_concurrency,true}]), %% 地图配置

    %ets:new(?ETS_WALK_POINT,[{keypos,#map_walk_point.map_id},named_table,public,set,{read_concurrency,true}]),                       %% 阻挡点信息
    %ets:new(?ETS_NPC, [{keypos, #npc.id}, named_table, public, set, {read_concurrency,true}]),                           %% NPC信息 
    %ets:new(?ETS_USER_DROP, [{keypos, #user_drop.user_id}, named_table, public, set, {read_concurrency,true}]),          %% 玩家掉落
    %ets:new(?ETS_TEAM, [{keypos, #team.id}, named_table, public, set, {read_concurrency, true}]),                        %% 队伍
    %ets:new(?ETS_GUILD_USER, [{keypos, #guild_user.user_id}, named_table, public, set, {read_concurrency, true}]),       %% 帮派成员信息
    %ets:new(?ETS_GUILD_REQUEST, [{keypos, #guild_request.id}, named_table, public, set, {read_concurrency, true}]),       %% 帮派成员信息
    %ets:new(?ETS_DELETE, [{keypos, #ets_delete.key}, named_table, public, set, {read_concurrency, true}]),      %% 删除数据信息
    %ets:new(?ETS_OPEN_PACKAGE_MASK,[{keypos,1},named_table,public,set,{read_concurrency,true}]),                         %% 开包裹掩码
    %ets:new(?ETS_CHAT_ITEM,[{keypos, 3},named_table,public,set,{read_concurrency,true}]),                     %% 聊天帖的物品信息
    %ets:new(?ETS_LOGIN_FLAG,[{keypos,#login_flag.key},named_table,public,set,{read_concurrency,true}]),                     %% 登陆秘钥
    %ets:new(?ETS_RANK_ITEM, [{keypos, #user_item.id}, named_table, public, set, {read_concurrency, true}]),                 %% 排行榜物品信息
    %ets:new(?ETS_RANK_ITEM_TEMP, [{keypos, #rank_item_info.id}, named_table, public, set, {read_concurrency, true}]),       %% 排行榜物品信息缓存
    %ets:new(?ETS_USER_TO_RANK, [{keypos, #user_to_rank.user_id}, named_table, public, set, {read_concurrency, true}]),      %% 玩家ID-排名映射表
    %ets:new(?ETS_USER_TO_DUP, [{keypos, #user_to_dup.user_id}, named_table, public, set, {read_concurrency, true}]),      %% 占领玩家ID-副本ID映射表
    %ets:new(?ETS_RELA_LV_ONLINE,[{keypos, #rela_lv_online.lv}, named_table, public, set, {read_concurrency, true}]),  %% 好友在线等级列表记录 
    %ets:new(?ETS_IP_ONLINE,[{keypos, #ip_online.ip}, named_table, public, set, {read_concurrency, true}]),  %% 好友在线等级列表记录 
    %ets:new(?ETS_EVENT_TEMP, [{keypos, #event_temp.user_id}, named_table, public, set, {read_concurrency, true}]),       %% 离线事件缓存

    %ets:new(?ETS_ACROSS_CLIENT_INFO,[{keypos,#across_client_info.key},named_table,public,set,{read_concurrency,true}]),     %% client的链接信息
    %ets:new(?ETS_ACROSS_SERVER_INFO,[{keypos,#across_server_info.key},named_table,public,set,{read_concurrency,true}]),     %% 链接的server的信息
    %ets:new(?ETS_ACROSS_USER_INFO,[{keypos,#across_user_info.user_id},named_table,public,set,{read_concurrency,true}]),     %% 参加跨服的玩家信息

    %ets:insert(?ETS_MAP_COUNTER,{?MAP_COUNTER,?INIT_MAP_ONLY_ID}),    
    %%% 数据包统计
    %ets:new(?ETS_PACKET_STAT,[{keypos,1},named_table,public,set,{read_concurrency,true}]),

    %% 阻挡点信息，每个地图资源一个ets表
    [ets:new(E, [{keypos,1},named_table,public,set,{read_concurrency,true}]) || E <- map_block:ets_map_block_name_list()],
    %% 内存数据库ets表初始化
    game_mmdb:init(),
    ok.


%% ============================================================================
%% ================================ 机器授权检测 ==============================
%% ============================================================================
%check() ->
%    case catch do_check() of
%        true ->
%            ok;
%        _ ->
%            init:stop(),
%            receive
%                stop ->
%                    false
%            end
%    end.
%
%do_check() ->
%    SourceIP = 
%    case inet:getif() of
%        {ok,IfList} ->
%            lists:foldl(fun({{127,0,0,1},_,_},AccIn) ->
%                            AccIn;
%                        ({IpAddress,_,_},AccIn) ->
%                        Ip = 
%                        case IpAddress of
%                            {A,B,C,D} ->
%                                lists:concat([A,".",B,".",C,".",D]);
%                            {A,B,C,D,E,F,G,H} ->
%                                lists:concat([A,".",B,".",C,".",D,".",E,".",F,".",G,".",H])
%                        end,
%                        [Ip | AccIn]
%                end,[],IfList);
%        {error,_Reason} ->
%            []
%    end,
%    
%    {ok,EthList} = inet:getifaddrs(),
%    F = fun({_,InfoList},AccIn) ->
%            case lists:keyfind(hwaddr,1,InfoList) of
%                false ->
%                    AccIn;
%                {_,[0,0,0,0,0,0]} ->
%                    AccIn;
%                {_, Hwaddr} ->
%                    NewStrHwaddr = lists:foldl(fun(N,AccInStr) -> 
%                                                Str = 
%                                                case erlang:integer_to_list(N,16) of
%                                                    [_] = S ->
%                                                        "0" ++ S;
%                                                    S ->
%                                                        S
%                                                end,
%                                                case AccInStr of
%                                                    "" ->
%                                                        Str;
%                                                    _ ->
%                                                        AccInStr ++ ":" ++ Str
%                                                end
%                                              end,"",Hwaddr),
%                    [NewStrHwaddr| AccIn]
%            end
%        end,         
%    SourceAddr = lists:foldl(F,[],EthList),
%
%    OsType =os:type(),
%    OsVersion = os:version(),
%
%    Time = util:timestamp() div 1000,
%    Str = lists:concat([SourceIP,SourceAddr,Time,?AUTH_KEY]),
%    Flag = util:md5(Str),
%
%    ModuleInfo = ?MODULE:module_info(),
%
%    {Compile,Source} = 
%    case lists:keyfind(compile,1,ModuleInfo) of
%        {compile,CompileList} ->
%            CompileTime = 
%            case lists:keyfind(time,1,CompileList) of
%                {time,{Y,M,D,H,MM,S}} ->
%                    lists:concat([Y,"-",M,"-",D," ",H,":",MM,":",S]);
%                _ ->
%                    ""
%            end,
%            SourceDir =
%            case lists:keyfind(source,1,CompileList) of
%                {source,Dir} ->
%                    filename:dirname(Dir);
%                _ ->
%                    ""
%            end,
%            {CompileTime,SourceDir};
%        _ ->
%            {"",""}
%    end,
%
%    BuileVersion = get_build_version(),
%    Auth = #auth{
%                source_ip = SourceIP,       %% 请机器IP列表
%                source_addr = SourceAddr,   %% 请求机器网卡地址
%                version = BuileVersion,          %% 版本号
%                compile = Compile,        %% 编译时间
%                source = Source,         %% 代码路径
%                os_type = OsType,        %% 操作系统类型
%                os_version = OsVersion,     %% 操作系统版本
%                plat = ?CONFIG_PLATFORM,           %% 平台
%                server = lists:concat([?CONFIG_PREFIX,"_",?CONFIG_SERVER_ID]),         %% 服ID
%                server_type = ?CONFIG_SERVER_TYPE,    %% 服类型
%                time = Time,           %% 时间
%                flag = Flag            %% 加密码编码
%            },
%    Bin = term_to_binary(Auth),
%    
%    %% 机器key,检查是否为测试服
%    {ok,EthList} = inet:getifaddrs(),
%    F2 = fun({_,InfoList},AccIn) ->
%            case lists:keyfind(hwaddr,1,InfoList) of
%                false ->
%                    AccIn;
%                {_, Hwaddr} ->
%                    StrHwaddr = [erlang:integer_to_list(N,16) || N <- Hwaddr],
%                    NewStrHwaddr = lists:foldl(fun(HwStr,AccInStr) -> lists:append(AccInStr,HwStr) end,"",StrHwaddr),
%                    %io:format("NewStrHwaddr:~p~n",[NewStrHwaddr]),
%                    lists:append(NewStrHwaddr,AccIn)
%            end
%        end,         
%    NewEthList = lists:foldl(F2,"",EthList),
%
%    
%    OsVersion = os:version(),
%    VersionList = tuple_to_list(OsVersion),
%    VersionList2 = [N rem 255 || N <-VersionList],
%    
%    %% io:format("Version:~p,VersionList:~p,EhtList:~p~n",[Version,VersionList,NewEthList]),
%
%    <<N:128>> = erlang:md5(VersionList2 ++ NewEthList ++ [32] ++ VersionList2),
%    
%    Key = lists:flatten(io_lib:format("~32.16.0b", [N])),
%
%    AuthServer = 
%    case lists:member(Key,?AUTH_TEST_SERVER_KEY) of
%        true ->
%            ?AUTH_TEST_SERVER;
%        false ->
%            ?AUTH_SERVER
%    end,
%
%    do_check2(AuthServer,Time,Auth,Bin).
%
%do_check2([Server | T],Time,#auth{source_ip = SourceIP,source_addr = SourceAddr} = Auth,Bin) ->
%    TcpOptions = [{active, false},{packet,2},binary],
%    case gen_tcp:connect(Server,8888,TcpOptions,5000) of
%        {ok,Socket} ->
%            util:sleep(100),
%            gen_tcp:send(Socket,Bin),
%            case gen_tcp:recv(Socket,0,5000) of
%                {ok,Packet} ->
%                    catch gen_tcp:close(Socket),
%                    check_recv(Time,SourceIP,SourceAddr,Packet);
%                _ ->
%                    do_check2(T,Time,Auth,Bin)
%            end;
%        _ ->
%            do_check2(T,Time,Auth,Bin)
%    end;
%do_check2([],_Time,_Auth,_Bin) ->
%    false.
%
%check_recv(Time,SourceIP,SourceAddr,Packet) ->
%    case binary_to_term(Packet) of
%        {ok,Time2,Flag} ->
%            case abs(Time -Time2) < 300 of
%                true ->
%                    Str = lists:concat([SourceIP,SourceAddr,Time2,?AUTH_KEY,1]),
%                    Md5 = util:md5(Str),
%                    Md5 == Flag;
%                false ->
%                    false
%            end;
%        _ ->
%    ?INFO("Check Recv"),
%            false
%    end.
%
%-ifdef(BUILD_VERSION).
%get_build_version() ->
%    ?BUILD_VERSION.
%-else.
%get_build_version() ->
%    "".
%-endif.
