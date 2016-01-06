#!/bin/bash

## 查看最新的log文件
## author kongqingquan@foxmail.com

key="game*"
serverdir="/data/game*"
if [ $# == 1 ]
then
    key=game*$1*
fi

ROOT=`cd $(dirname $0); pwd`
FINDDIR=$ROOT/$serverdir/logs

file=$(find $FINDDIR -maxdepth 1 -name "$key.log" | sort -r | head -n 1)

echo "$file"

tail -f -n 40 $file
