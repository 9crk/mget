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
    curl -o $path/part$i.$start.$end.tmp $1 -r $start-$end -s &
    #echo "curl -o $path/part$i.tmp $1 -r $start-$end &"
    catme="$catme $path/part$i.$start.$end.tmp"
done

while true
do
    echo "agian"
    dontWannaWait=0
    lastSize="0M"
    while true
    do
        wait=`ps -ef|grep curl|wc -l`
        if [ $wait -lt 2 ];then
            break
        fi
        sleep 1
        now=`du -sm $path|awk '{print $1}'`
        echo "total $len now $now MB   reDownload=$dontWannaWait"
        if [ "$lastSize" == "$now" ];then 
            dontWannaWait=$(($dontWannaWait+1))
            if [ $wait -gt 4 ] && [ $dontWannaWait -gt 30 ];then
                echo "too slow. killed all task to restart"
                killall curl
                dontWannaWait=0
            fi
        else
            dontWannaWait=0
        fi
        lastSize=$now
    done

    #check download
    cnt=0
    for((i=0;i<task;i++));  
    do
        start=$(($iLen*$i))
        end=$(($start+$iLen -1))
        #check exist
        if [ ! -f "$path/part$i.$start.$end.tmp" ];then
            echo "found file lose : $start-$end"
            curl -o $path/part$i.$start.$end.tmp $1 -r $start-$end -s &
            cnt=$(($cnt+1))
        else
            #check size
            size=`ls -al $path/part$i.$start.$end.tmp |awk '{print $5}'`
            r_size=$(($end-$start))
            if [ $size -lt $r_size ];then    
                echo "redownload $start-$end"
                curl -o $path/part$i.$start.$end.tmp $1 -r $start-$end -s &
                cnt=$(($cnt+1))     
            fi
        fi
    done
    echo $cnt
    if [ $cnt  == 0 ];then
        echo "download success!!!"
        break
    fi
done

cat $catme >$3
rm -r $path
