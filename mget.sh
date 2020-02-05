#author: 9crk
#contact: admin@9crk.com
#update in ShenZhen.China at 2020.02.05 when 2019-nConv virus occurs. we are all in home.

if [ $# -lt 3 ]; then
	echo ""
        echo "[usage]   sh ./$0 url thread_num save_out_file(use xxxx.mp4. DON'T use absolute path like /home/xx/xxx.mp4)"
        echo "[example] sh ./$0 http://xxxxxx.mp4 20 target.mp4"
	echo ""
	exit 0
fi

path=/tmp/$3
mkdir $path
len=`curl --head $1 -s |grep "ength"|awk '{print $2}'|tr -d '\r'`
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
#echo "curl -o $path/part$i.tmp $1 -r $start-$end &"
catme="$catme $path/part$i.tmp"
done
while true
do
wait=`ps -ef|grep curl|wc -l`
if [ $wait -lt 2 ];then
break
fi
sleep 1
now=`du -sh $path|awk '{print $1}'`
echo "total $len now $now"
done
cat $catme >$3
rm -r $path
