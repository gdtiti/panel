#!/bin/bash
get_node_url(){
	nodes=(https://github.com/gdtiti/panel/raw/master);
	i=1;
	for node in ${nodes[@]};
	do
		start=`date +%s.%N`
		result=`curl -sS --connect-timeout 3 -m 60 $node/check.txt`
		if [ "$result" = 'True' ];then
			end=`date +%s.%N`
			start_s=`echo $start | cut -d '.' -f 1`
			start_ns=`echo $start | cut -d '.' -f 2`
			end_s=`echo $end | cut -d '.' -f 1`
			end_ns=`echo $end | cut -d '.' -f 2`
			time_micro=$(( (10#$end_s-10#$start_s)*1000000 + (10#$end_ns/1000 - 10#$start_ns/1000) ))
			time_ms=$(($time_micro/1000))
			values[$i]=$time_ms;
			urls[$time_ms]=$node
			i=$(($i+1))
		fi
	done
	j=5000
	for n in ${values[@]};
	do
		if [ $j -gt $n ];then
			j=$n
		fi
	done
	if [ $j = 5000 ];then
		NODE_URL='https://github.com/gdtiti/panel/raw/master';
	else
		NODE_URL=${urls[$j]}
	fi
	
}

if [ ! $NODE_URL ];then
	echo '正在选择下载节点...';
	get_node_url
fi
