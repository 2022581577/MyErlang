#! /bin/bash

## 编译少量文件
## author binbinjnu@163.com
ROOT=`cd $(dirname $0); pwd`
var=1
while [ $var -le $# ]
do
    FileName="${!var}.erl"
    FILE=`find src -name $FileName`
    if [ -s "$FILE" ] ; then
        erl -pa "./ebin" -noinput -eval "case make:files([\"${FILE}\"], [{outdir, \"ebin\"},{d,'DEBUG'}]) of error -> halt(1); _ -> halt(0) end"
        ./gamectl reload -r ${!var}
    fi      
    let var++
done 
