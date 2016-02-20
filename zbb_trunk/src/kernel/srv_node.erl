%%%----------------------------------------------------------------------
%%% @author : zhongbinbin <binbinjnu@163.com>
%%% @date   : 2016.02.20
%%% @desc   : 节点管理进程，用于管理本节点和各个跨服节点
%%%           节点通过注册来相互连通，连通后连接的节点信息保存起来
%%%           不通过nodes获取连通的节点，而是通过保存起来的信息确认
%%%           TODO 如果用游戏服来作为跨服节点，需要特殊处理
%%%----------------------------------------------------------------------
-module(srv_node).
-behaviour(game_gen_server).

-include("common.hrl").
-include("map.hrl").
-include("user.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

-define(MODULE_LOOP_TICK, 5000).		%% 进程循环时间10秒

%% ====================================================================
%% API functions
%% ====================================================================
-export([
            start_link/0
			,game_node_list/0
			,get_server_node/1
			,get_sys_server_node/1
			,sync_merge_list/1
			,delete_game_node/1
			,save_game_node/1
			,online_count/0
			,connect_cross/1
			,reconnect_cross/1
			,next_day_refresh/0
        ]).
-export([
 			small_cross_node_list/0
			,target_local_node/1
			,target_local_node/2     
        ]).

-export([do_init/1, do_call/3, do_cast/2, do_info/2, do_terminate/2]).

start_link() ->
    game_gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-record(state, {loop_count = 0      %% 循环次数
               ,connect_list = []   %% 链接列表 [{CrossType,CrossName,CrossNode,ConnectFlag} | _] 
               ,node_info           %% 本节点的节点信息
           }).

-define(CONNECT_FLAG_FALSE, 0).
-define(CONNECT_FLAG_TRUE, 1).

-record(node_info, {node            %% 节点
                   ,node_type       %% 节点类型(config中的server_type)
                   ,platform        %% 平台(config中的platform)
                   ,server_id       %% 服务器编号(config中的server_id)
                   ,port            %% 端口(config中的server_port)
                   ,ip              %% ip(config中的server_ip)
               }).

%% @doc 获取需要连接的节点信息
%% @return [{} | _]
init_connect_list() ->
    case ?CONFIG(server_type) of
        ?SERVER_TYPE_GAME ->    %% 游戏服，需要获取跨服节点信息
            case ?CONFIG(center_server_flag) of
                1 ->    %% 通过中央服获取跨服节点信息
                    [];
                _ ->    %% 没连接中央服，给默认的跨服节点信息
                    []
            end;
        _ ->                    %% 非游戏服，没有跨服节点信息
            []
    end.

%% @doc 根据节点名获取#node_info{}
%% @return #node_info{}
node2node_info(Node) ->
	case string:tokens(util:to_list(Node), "_@") of
		[NodeTypeStr, PlatformStr, PrefixServerIDStr, PortStr, IpStr] ->
            #node_info{node = Node
                      ,node_type = util:to_atom(NodeTypeStr)
                      ,platform = PlatformStr
                      ,server_id = util:prefix_server_id_str2server_id(PrefixServerIDStr)
                      ,port = util:to_integer(PortStr)
                      ,ip = IpStr}
		R ->
            ?WARNING("node2node_info false, Res:~w", [R]),
			{false, <<"illegal node name">>}
	end.

%% @doc 连接跨服A/B/C区服务器
%% @return {true,State}
connect(#state{connect_list = ConnectList} = State) ->
    [begin 
        net_kernel:connect_node(CrossNode), %% 连接节点
        game_gen_server:cast({?MODULE, CrossServer}, {register, node()}),   %% 注册节点信息
     end || {CrossType, CrossName, CrossNode, ?CONNECT_FLAG_FALSE} <- ConnectList],
    ok.


do_init([]) ->
    %% 监控节点
	net_kernel:monitor_nodes(true, [{node_type, all}]),
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    %% 初始化本节点信息
    NodeInfo = node2node_info(node()),
    %% 获取连接列表信息
    ConnectList = init_connect_list(),
    {ok, #state{connect_list = ConnectList, node_info = NodeInfo}}.


%% SourceNode连当前节点(当前是小跨服节点)
do_cast({connect_node, SourceNode, CrossType, MergeList}, State) ->
%% 	?DEBUG("connect_node, SourceNode:~w, CrossType:~w", [SourceNode, CrossType]),
	save_game_node(get_sys_server_node(SourceNode)),
	sync_merge_list(MergeList),
	game_gen_server:cast({?MODULE, SourceNode}, {connect_confirm, CrossType}),
    {noreply, State};

do_cast({connect_confirm, CrossType}, State = #state{server_list = ServerList}) ->
%% 	?DEBUG("connect_confirm....CurrentNode:~w", [node()]),
	case lists:keyfind(CrossType, 1, ServerList) of
		false ->
			{noreply, State};
		{CrossType,CrossName,CrossServer,_} ->
			NewL = lists:keystore(CrossType, 1, ServerList, {CrossType,CrossName,CrossServer,1}),
			ConnectFlag = ?IF(length(lists:filter(fun({_,_,_,Flag}) -> Flag == 0 end, NewL)) > 0,0,1),
			{noreply, State#state{server_list = NewL, connect_flag = ConnectFlag}}
	end;

%do_cast(next_day_refresh, State = #state{connect_flag = OldConnectFlag}) ->
%	N = util:server_open_days(),
%	ConnectFlag =
%		if
%			(N == ?CROSS_B_ACTIVITY_OPEN_DAY + 1) orelse (N == ?CROSS_A_ACTIVITY_OPEN_DAY + 1) ->
%				0;
%			true ->
%				OldConnectFlag
%		end,
%	?DEBUG("ConnectFlag:~w",[ConnectFlag]),
%	{noreply, State#state{connect_flag = ConnectFlag}};

do_cast(_Info, State) ->
    {noreply, State}.


do_call(get_state, _From, State) ->
	{reply, State, State};

do_call(_Info, _From, State) ->
    {reply, ok, State}.


%% 处理新节点加入事件
do_info({nodeup, Node, _InfoList}, State) ->
	case get_sys_server_node(Node) of
		SysServerNode when is_record(SysServerNode, sys_server_node) ->
			save_game_node(SysServerNode),
		    {noreply, State};
		_ ->
			{noreply, State}
	end;

%% 处理节点关闭事件
do_info({nodedown, Node, _InfoList}, State = #state{server_list = L}) ->
	case get_sys_server_node(Node) of
		SysServerNode when is_record(SysServerNode, sys_server_node) ->
			delete_game_node(SysServerNode),
			{noreply, State#state{server_list = lists:keydelete(Node, 3, L), connect_flag = 0}};
		_ ->
			{noreply, State}
	end;

do_info(loop, State) ->
    erlang:send_after(?MODULE_LOOP_TICK, self(), loop),
    %% 检测节点连通情况并进行连通(如果是游戏节点，需要连接到对应的跨服节点)
    case ?CONFIG(server_type) of
        ?SERVER_TYPE_GAME ->
            State1 = connect(State),
            {noreply, State1};
        _ ->
            {noreply, State}
    end;

do_info(_Info, State) ->
    {noreply, State}.

do_terminate(_Reason, State) ->
    {ok, State}.


%% @doc 获取本服节点列表(任何游戏节点调用有效)
game_node_list() ->
	case srv_param:get_value(?ETS_GLOBAL_PARAM, game_node_list) of
		{false,_} ->
			[];
		Dict ->
			dict:fetch_keys(Dict)
	end.

%% @doc 小跨服节点列表(小跨服节点调用有效)
small_cross_node_list() ->
	NodeType = srv_param:get_value(?ETS_GLOBAL_PARAM, node_type),
	if
		NodeType == ?CROSS_TYPE_B orelse NodeType == ?CROSS_TYPE_C ->
			case srv_param:get_value(?ETS_GLOBAL_PARAM, cross_node_list) of
				{false,_} ->
					[];
				Dict ->
					[SysServerNode#sys_server_node.node||{{_Site, _ServerNo, NodeIndex}, SysServerNode}<- dict:to_list(Dict), NodeIndex == 1]
			end;
		true ->
			CrossActivityFlag = game_misc:is_start_cross_activity(?CROSS_TYPE_A),
			if
				CrossActivityFlag == true ->
					case srv_param:get_value(?ETS_GLOBAL_PARAM, cross_node_list) of
						{false,_} ->
							[];
						Dict ->
							[SysServerNode#sys_server_node.node||{{_Site, _ServerNo, NodeIndex}, SysServerNode}<- dict:to_list(Dict), NodeIndex == 1]
					end;
				true ->
					[srv_param:get_value(?ETS_GLOBAL_PARAM, local_node)]
			end
	end.

%% @doc 根据玩家的server_no获取对应服的中心节点(A、B、C区跨服节点调用)
%% @return TargetLocalNode|{false, Msg}
target_local_node(ServerNo) ->
	target_local_node(srv_param:get_value(?ETS_GLOBAL_PARAM, site), ServerNo).
target_local_node(Site, ServerNo) ->
	case srv_param:get_value(?ETS_GLOBAL_PARAM, cross_node_list) of
		{false,_} = R ->
			R;
		Dict ->
			case dict:find({Site, game_misc:get_main_server_no(Site, ServerNo), 1}, Dict) of			
				{ok, #sys_server_node{node = Node}} ->
					Node;
				Error ->
					{false, Error}
			end
	end.

%% @doc 获得节点信息
%% @return #sys_server_node{}
get_server_node(Node) ->
	case srv_param:get_value(?ETS_GLOBAL_PARAM, game_node_list) of
		{false,_} ->
			false;
		Dict ->
			case dict:find(Node, Dict) of
				{ok,V} ->
					V;
				_ ->
					false
			end
	end.

%% @doc 同步合服信息到跨服节点
sync_merge_list(List) ->
	case srv_param:get_value(?ETS_GLOBAL_PARAM, merge_list) of
		{false, _} ->
			srv_param:save(?ETS_GLOBAL_PARAM, merge_list, List);
		OldList ->
			NewList = lists:foldl(fun({K,V}, Acc) -> lists:keystore(K, 1, Acc, {K,V}) end, OldList, List),
			srv_param:save(?ETS_GLOBAL_PARAM, merge_list, NewList)
	end.

%% @doc 隔天刷新 开服第3天->第4天时 触发B/C区节点的连接
next_day_refresh() ->
	[ game_gen_server:cast({srv_kernel, Node}, next_day_refresh) || Node <- srv_kernel:game_node_list()].
 
%% @doc 服务器在线人数
online_count() ->
	L = ets:tab2list(?ETS_NODE_USER_COUNT),
	lists:foldl(fun({_Node,{UserCount,_IpCount}}, Acc) -> Acc+UserCount end, 0, L).



%% ====================================================================
%% Internal functions
%% ====================================================================
%% @doc save SysServerNode
%% 1、每个服的节点
%% 2、A区跨服节点
%% 3、B区跨服节点
%% 4、C区跨服节点
save_game_node(SysServerNode = #sys_server_node{node_type = ?CROSS_TYPE_NONE, ip = Ip, server_no = ServerNo, node_index = NodeIndex, node = Node, site = Site})  ->
	LocalSysServerNode = get_sys_server_node(node()),
	if
		LocalSysServerNode#sys_server_node.ip == Ip andalso
		LocalSysServerNode#sys_server_node.server_no == ServerNo andalso 
		LocalSysServerNode#sys_server_node.site == Site ->
			%% 目标节点和当前节点同服 save game_node_list
			[ begin rpc:cast(TempNode, net_kernel, connect_node, [Node]) end || TempNode <- srv_kernel:game_node_list()],
			srv_param:save2dict(?ETS_GLOBAL_PARAM, game_node_list, Node, SysServerNode),
			LocalSysServerNode#sys_server_node.node_index == 1 andalso NodeIndex == 1 andalso srv_param:save2dict(?ETS_GLOBAL_PARAM, cross_node_list, {Site, ServerNo, NodeIndex}, SysServerNode);
		true ->
			%% 目标节点和当前节点不同服 当前是跨服的1号节点,目标节点是1号节点 save cross_node_list
			is_cross(LocalSysServerNode#sys_server_node.node) andalso LocalSysServerNode#sys_server_node.node_index == 1 andalso NodeIndex == 1 andalso srv_param:save2dict(?ETS_GLOBAL_PARAM, cross_node_list, {Site, ServerNo, NodeIndex}, SysServerNode)
	end;
save_game_node(SysServerNode) ->
	#sys_server_node{node_type = NodeType} = get_sys_server_node(node()),
	(NodeType == ?CROSS_TYPE_B orelse NodeType == ?CROSS_TYPE_C) andalso srv_param:save2dict(?ETS_GLOBAL_PARAM, game_node_list, SysServerNode#sys_server_node.node, SysServerNode),
	ok.

delete_game_node(#sys_server_node{node_type = ?CROSS_TYPE_NONE, ip = Ip, server_no = ServerNo, node_index = NodeIndex, node = Node, site = Site}) ->
	LocalSysServerNode = get_sys_server_node(node()),
	if
		LocalSysServerNode#sys_server_node.ip == Ip andalso LocalSysServerNode#sys_server_node.server_no == ServerNo ->	
			srv_param:del_from_dict(?ETS_GLOBAL_PARAM, game_node_list, Node),
			is_cross(LocalSysServerNode#sys_server_node.node) andalso srv_param:del_from_dict(?ETS_GLOBAL_PARAM, cross_node_list, {Site, ServerNo, NodeIndex});
		true ->
			is_cross(LocalSysServerNode#sys_server_node.node) andalso srv_param:del_from_dict(?ETS_GLOBAL_PARAM, cross_node_list, {Site, ServerNo, NodeIndex})
	end;
delete_game_node(SysServerNode) ->
	#sys_server_node{node_type = NodeType} = get_sys_server_node(node()),
	(NodeType == ?CROSS_TYPE_B orelse NodeType == ?CROSS_TYPE_C) andalso srv_param:del_from_dict(?ETS_GLOBAL_PARAM, game_node_list, SysServerNode#sys_server_node.node),
	ok.
	

%% @doc 根据节点名node()获取#sys_server_node{}
%% @return #sys_server_node{}
get_sys_server_node(Node) ->
	case string:tokens(util:to_list(Node), "_@") of
		[Game,Site,NodeTypeString,ServerNoString,NodeIndexString,PortString,Ip] ->
			#sys_server_node{
				node_index = util:to_integer(NodeIndexString)
				,node_type = util:to_integer(NodeTypeString)
				,node = Node
			  	,server_no = game_misc:get_server_no(ServerNoString)
			  	,ip = Ip
			  	,port = util:to_integer(PortString)
				,game = Game
				,site = Site 
			};
		_ ->
			{false, <<"illegal node name">>}
	end.

%% @doc 重连跨服A/B/C区服务器
reconnect_cross([State]) ->
	case game_misc:is_cross_platform() of
		false ->
			case intf_server_config:config_from_php() of
				{true, ServerConfig} ->
					srv_param:save(?ETS_GLOBAL_PARAM, server_config, ServerConfig),
					connect_cross([State#state{connect_flag = 0}]);
				{false, Code, Msg} ->
					?WARN("reconnect_cross server_config_error....Code:~w Msg:~s", [Code, Msg]),
					{true, State}
			end;
		_ ->
			{true, State}
	end.

%% @doc 连接跨服A/B/C区服务器
%% @return {true,State}
connect_cross([State = #state{server_list = CurrentServerList, connect_flag = 0}]) ->
	case srv_param:get_value(?ETS_GLOBAL_PARAM, server_config) of
		#server_config{cross_server_list = ConfigServerList, merge_list = MergeList} ->
%% 			?DEBUG("CurrentServerList:~w", [CurrentServerList]),
			CurrentServerList1 =
				lists:foldl(fun({CrossType,CrossName,CrossServer,Flag}, Acc) ->
					CrossActivityFlag = game_misc:is_start_cross_activity(CrossType),
%% 					?DEBUG("1....CrossType:~w CrossActivityFlag:~w", [CrossType, CrossActivityFlag]),
					if
						CrossActivityFlag == true ->
							case lists:keyfind(CrossType, 1, ConfigServerList) of
								false ->
									%% 新的配置已不存在此条数据 disconnect
%% 									?DEBUG("0....~w disconnect ~w", [node(), CrossServer]),
									net_kernel:disconnect(CrossServer),
									lists:keydelete(CrossType, 1, Acc);
								{CrossType,CrossName,CrossServer} ->
									%% 新的配置和老的配置相同
%% 									?DEBUG("1....~w connect ~w", [node(), CrossServer]),
									net_kernel:connect_node(CrossServer),
									game_gen_server:cast({?MODULE, CrossServer}, 
														 {
														  connect_node
														  ,node()
														  ,CrossType
														  ,MergeList}),
									lists:keystore(CrossType, 1, Acc, {CrossType,CrossName,CrossServer,Flag});
								{CrossType,NewCrossName,NewCrossServer} ->
									%% 新的配置和老的配置不同
									?WARN("2....~w disconnect ~w", [node(), CrossServer]),
									net_kernel:disconnect(CrossServer),
									?WARN("2....~w connect ~w", [node(), NewCrossServer]),
									net_kernel:connect_node(NewCrossServer),
									game_gen_server:cast({?MODULE, NewCrossServer}, 
														 {
														  connect_node
														  ,node()
														  ,CrossType
														  ,MergeList}),
									lists:keystore(CrossType, 1, Acc, {CrossType,NewCrossName,NewCrossServer,0})
							end;
						true ->
							Acc
					end
				end, [], CurrentServerList),
%% 			?DEBUG("CurrentServerList1:~w", [CurrentServerList1]),
			CurrentServerList2 = 
				lists:foldl(fun({CrossType,CrossName,CrossServer},Acc) ->
					CrossActivityFlag = game_misc:is_start_cross_activity(CrossType),
%% 					?DEBUG("2....CrossType:~w CrossActivityFlag:~w", [CrossType, CrossActivityFlag]),
					if
						CrossActivityFlag == true ->
							case lists:keyfind(CrossType, 1, Acc) of
								false ->
									net_kernel:connect_node(CrossServer),
									game_gen_server:cast({?MODULE, CrossServer}, 
														 {
														  connect_node
														  ,node()
														  ,CrossType
														  ,MergeList}),							
									lists:keystore(CrossType, 1, Acc, {CrossType,CrossName,CrossServer,0});
								_ ->
									Acc
							end;
						true ->
							Acc
					end
				end, CurrentServerList1, ConfigServerList),			
			ConnectFlag = 
				?IF(length(lists:filter(fun({_,_,_,Flag}) -> Flag == 0 end, CurrentServerList2)) > 0,0,1),
%% 			?DEBUG("NewCurrentServerList:~w ConnectFlag:~w", [CurrentServerList2, ConnectFlag]),
			{true, State#state{server_list = CurrentServerList2, connect_flag = ConnectFlag}};
		_ ->
			{true, State}
	end;
connect_cross([State]) ->
	{true, State}.

%% @doc 当前节点是否是A/B/C区跨服节点
is_cross(CurrentNode) ->
	ServerConfig = srv_param:get_value(?ETS_GLOBAL_PARAM, server_config),
	case game_misc:is_cross_platform() of
		false ->
			case lists:keyfind(CurrentNode, 3, ServerConfig#server_config.cross_server_list) of
				{_CrossType,_CrossName,CurrentNode} ->
					%% 目标节点和当前节点不同服 当前是跨服的1号节点,目标节点是1号节点 save cross_node_list
					true;
				_ ->
					false
			end;
		_ ->
			true
	end.

%% @doc save SysServerNode
%% 1、每个服的节点
%% 2、A区跨服节点
%% 3、B区跨服节点
%% 4、C区跨服节点
save_node_info(SysServerNode = #sys_server_node{node_type = ?CROSS_TYPE_NONE, ip = Ip, server_no = ServerNo, node_index = NodeIndex, node = Node, site = Site})  ->
	LocalSysServerNode = get_sys_server_node(node()),
	if
		LocalSysServerNode#sys_server_node.ip == Ip andalso
		LocalSysServerNode#sys_server_node.server_no == ServerNo andalso 
		LocalSysServerNode#sys_server_node.site == Site ->
			%% 目标节点和当前节点同服 save game_node_list
			[ begin rpc:cast(TempNode, net_kernel, connect_node, [Node]) end || TempNode <- srv_kernel:game_node_list()],
			srv_param:save2dict(?ETS_GLOBAL_PARAM, game_node_list, Node, SysServerNode),
			LocalSysServerNode#sys_server_node.node_index == 1 andalso NodeIndex == 1 andalso srv_param:save2dict(?ETS_GLOBAL_PARAM, cross_node_list, {Site, ServerNo, NodeIndex}, SysServerNode);
		true ->
			%% 目标节点和当前节点不同服 当前是跨服的1号节点,目标节点是1号节点 save cross_node_list
			is_cross(LocalSysServerNode#sys_server_node.node) andalso LocalSysServerNode#sys_server_node.node_index == 1 andalso NodeIndex == 1 andalso srv_param:save2dict(?ETS_GLOBAL_PARAM, cross_node_list, {Site, ServerNo, NodeIndex}, SysServerNode)
	end;
save_game_node(SysServerNode) ->
	#sys_server_node{node_type = NodeType} = get_sys_server_node(node()),
	(NodeType == ?CROSS_TYPE_B orelse NodeType == ?CROSS_TYPE_C) andalso srv_param:save2dict(?ETS_GLOBAL_PARAM, game_node_list, SysServerNode#sys_server_node.node, SysServerNode),
	ok.
