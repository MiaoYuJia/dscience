hadoop fs -rmr hdfs://hadoopcluster/user/yujia.miao/tmp/result

inputDate=2016/11/25

num=3 
preday_date=`date -d "0 day" +%Y/%m/%d`
preday_date=$inputDate
str_date=$preday_date

while [ $num -gt 1 ]
do
num=`expr $num - 1`
v_date=`date "-d -$num day $preday_date" +%Y/%m/%d`
str_date=$str_date","$v_date
done

echo $str_date

#旅游行业
seed=/user/yujia.miao/ctr_reach/seed/pyid
imp=/user/root/flume/express/{$str_date}/*/imp*
click=/user/root/flume/express/{$str_date}/*/click*
out=/user/yujia.miao/ctr_reach/result
pig -f test.pig \
	-param seed=$seed \
	-param imp=$imp \
	-param click=$click \
	-param out=$out 
