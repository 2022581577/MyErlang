#! /bin/bash

## 关键词查找脚本
## author kongqingquan@foxmail.com

SEARCHPATH="./"

if [ $# -lt 1 ]
then
	echo "请输入要查找的关键词,如: ./efind.sh get_online_player"
	exit 1
fi


if [ $# -gt 1 ] 
then
    SEARCHPATH=$2
fi

grep ${1}* $SEARCHPATH  -rn --include=*.erl --include=*.hrl --color=always
