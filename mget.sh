path=/tmp/$3
mkdir $path
len=`curl --head $1 -s |grep "Length"|awk '{print $2}'|tr -d '\r'`
len=`echo $len | sed 's/\\r//g'`
task=`echo $2 | sed 's/\\r//g'`
echo "total len = $len"
iLen=$(($len/$task))
echo "divide = $iLen"

catme=""
for((i=0;i<task;i++));  
do

start=$(($iLen*$i))
end=$(($start+$iLen -1))
if [ $i == $(($task-1)) ];then
end=$len
fi
curl -o $path/part$i.tmp $1 -r $start-$end -s &
echo "curl -o $path/part$i.tmp $1 -r $start-$end &"
catme="$catme $path/part$i.tmp"
done
while true
do
wait=`ps -ef|grep curl|wc -l`
if [ $wait -lt 2 ];then
break
fi
sleep 1
now=`du -sh $path`
echo "total $len now $now"
done
cat $catme >$3
rm -r $path
