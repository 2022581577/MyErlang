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
              ,map_port        %% 地图连接端口(config中的map_port)
    }).

%% srv_reader的state
-record(reader_state,{type                  %% 类型：game，map
                     ,acc_name              %% 账号
                     ,user_id       = 0     %% 最终使用的玩家id，默认0
                     ,user_pid              %% 玩家pid
                     ,socket                %% 控制权转交后需测试socket为 undefined
                     ,packet_len    = 0     %% 初始packet长度为0，从消息头接收到数据后重置packet长度
    }).

%% 公共数据
-record(global_data, {global_key
                    ,value
                    ,is_dirty = 0
    }).

-endif.
