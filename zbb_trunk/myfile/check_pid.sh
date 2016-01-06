#! /bin/bash

## 检查 erlang 虚拟机运行进程
## author kongqingquan@foxmail.com

echo -e "进程PID\t 节点名称\t  时间"
ps auwx | grep beam | grep -v grep | awk '
                                          {
                                              len = length($0)
                                              for(k=1;k<len;k++){
                                                  if(index($k,".sasl") > 0){
                                                      i=split($k,a,"_")
                                                      str=substr(a[i],index(a[i],"."))
                                                      gsub(str,"",a[i])
                                                      break
                                                  }
                                              }
                                          }
                                          {print $2,"\t",$35,"\t",a[i],"\t"}' | sort -k 2
