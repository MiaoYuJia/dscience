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
conf_door=/data/production/mprofile
source $conf_door/conf/application-context.cfg
source $conf_door/conf/base.sh

inputDate=${1}

#若输入日期为空，默认日期为当前日期的前一天，格式为：年/月/日
if [ -z "${inputDate}" ];then
inputDate=`date -d "-4 day" +%Y/%m/%d`
fi

#dir
input=/user/root/flume/3th_logs/asiainfo/dxcloud_ub/2016/11/{18,19,21}/with_pyid
echo $input
offline_score=tmp/offline_score/score/$inputDate
all_rule=tmp/offline_score/config/rule
echo $all_rule

hadoop fs -rmr $offline_score

cd $(dirname $0)

#hbase to hdfs
function f_offline_score(){
spark-submit \
        --driver-library-path /usr/hdp/2.4.0.0-169/hadoop/lib/ \
        --master "yarn-cluster" \
        --queue normal \
        --class "com.ipinyou.offscore.OffScoring" \
        --driver-java-options "-Dlog4j.debug -Dlog4j.configuration=/usr/hdp/2.4.0.0-169/spark/conf/log4j.properties" \
	/data/users/data-mprofile/mprofile_yujia/lib/offline_score-0.0.1-SNAPSHOT.jar "1" "$offline_score" "$all_rule" "$input"
}
f_offline_score
CheckIfError "f_offline_score"

function hf2hbase(){
spark-submit \
        --driver-library-path /usr/hdp/2.4.0.0-169/hadoop/lib/ \
        --master "yarn-client" \
        --queue normal \
        --class "com.ipinyou.offscore.hf2hb" \
        --driver-java-options "-Dlog4j.debug -Dlog4j.configuration=/usr/hdp/2.4.0.0-169/spark/conf/log4j.properties" \
        ../../lib/offline_score-0.0.1-SNAPSHOT.jar "1" "$offline_score"
}
#hf2hbase
CheckIfError "hf2hbase"
CheckAndMail "hf2hbase"

