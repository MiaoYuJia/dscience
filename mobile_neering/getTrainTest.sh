#! /bin/sh
#
# Script Name : hb2hdfs.sh
# Description : hbase2hdfs
# Usage       : sh dmp_conversion.sh $inputdate
# Example     : sh dmp_conversion 2015/11/04
# Author      : yujia.miao
# Created     : 2015-12-02
# Modified    : 2016-01-26
# description :

##test20151211
export LANG="en_US.UTF-8"  #本地crontab 在执行shell时没有引入用户环境变量,所以加上该代码
##公共配置文件的import
###测试路径

inputDate=${1}

#若输入日期为空，默认日期为当前日期的前一天，格式为：年/月/日
if [ -z "${inputDate}" ];then
inputDate=`date -d "-4 day" +%Y/%m/%d`
fi

#dir
input="sample_feature/pday=20161103/pvertical=game"
echo $input

out_train="/user/data-mprofile/fe/game/train"
out_test="/user/data-mprofile/fe/game/test"
featureIndex=/user/data-mprofile/fe/game/featureIndex

function rmhdfs(){
hadoop fs -rmr $out_train
hadoop fs -rmr $out_test
hadoop fs -rmr $featureIndex
}
rmhdfs

cd $(dirname $0)

function hf2hbase(){
spark-submit \
        --driver-library-path /usr/hdp/2.4.0.0-169/hadoop/lib/ \
        --master "yarn-client" \
        --queue normal \
        --class "com.ipinyou.spark.commen.Test" \
        --driver-java-options "-Dlog4j.debug -Dlog4j.configuration=/usr/hdp/2.4.0.0-169/spark/conf/log4j.properties" \
        ./lib/commen-0.0.1-SNAPSHOT.jar "1" "$input" $out_train $out_test $featureIndex
}
hf2hbase

hadoop fs -cat $out_train/* |awk 'BEGIN {FS=OFS="\t"}  {print  $2,$3}' > dtrain
hadoop fs -cat $out_test/* | awk 'BEGIN {FS=OFS="\t"}  {print  $2,$3}'> dtest
hadoop fs -cat $featureIndex/* > featureIndex


cat featureIndex | awk 'BEGIN {FS=OFS="\t"; ORS="\t";print "0"; ORS=" "}  { print  $2$1":1"}' >> dtrain
cat featureIndex | awk 'BEGIN {FS=OFS="\t"; ORS="\t";print "0"; ORS=" "}  { print  $2$1":1"}' >> dtest
