%%%----------------------------------------------------------------------
%%% @author :
%%% @date   : 2016.02.16
%%% @desc   : record定义
%%%----------------------------------------------------------------------

-ifndef(RECORD_HRL).
-define(RECORD_HRL,"record.hrl").

-include("rd_user.hrl").
-include("rd_map.hrl").
-include("rd_guild.hrl").

%% 节点数据结构
-record(node, {key             %% 根据不同的需求，设置不同的key（以node_name为key；以{platform,server_id}为key）
              ,node_name       %% 节点
              ,node_type       %% 节点类型(config中的server_type)
              ,platform        %% 平台(config中的platform)
              ,server_id       %% 服务器编号(config中的server_id)
              ,ip              %% ip(config中的server_ip)
              ,port            %% 端口(config中的server_port)
               }).

-endif.
