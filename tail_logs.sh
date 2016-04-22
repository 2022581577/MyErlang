#!/bin/bash

## 查看最新的log文件
## author kongqingquan@foxmail.com

FINDDIR=./logs
SERVER=1

if [ $# -ne 0 ]; then
    SERVER=$1
fi

file=$(find $FINDDIR -name "*s${SERVER}*.log" | sort -r | head -n 1)

echo "$file"

tail -f -n 40 $file
