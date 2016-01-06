#!/bin/bash

## 查看最新的log文件
## author kongqingquan@foxmail.com

FINDDIR=./logs

file=$(find $FINDDIR -name "*.log" | sort -r | head -n 1)

echo "$file"

tail -f -n 40 $file
