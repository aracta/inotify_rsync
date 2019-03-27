#!/bin/bash
SRC_DIR="/home/wwwroot/s1.elabscience.com/"
#declare -A DIRECTORYS
/usr/bin/inotifywait -mrq --exclude '/Runtime/' --timefmt '%Y%m%d_%H:%M:%S' --format '%T %w %f %Xe' -e create,delete,attrib,close_write,move $SRC_DIR | while read DATE DIRECTORY FILE EVENT
do
	# ${DIRECTORYS[${DIRECTORY}]}=${DIRECTORY}
	# 只记录相对根目录的目录
	DIRECTORY_s="/"${DIRECTORY#*${SRC_DIR}}
	#使用 /var/log/rsyncDrectory.log 记录发生变动的目录
	#判断数组/文件中是否有值
	grep -wq "${DIRECTORY_s}" /var/log/rsyncDrectory.log && > /dev/null 2>&1 || ( echo "${DIRECTORY_s}" >> /var/log/rsyncDrectory.log 2>&1 && 
	#启动at命令，1min后执行rsyncDo.sh（先判断当前atq队列中是否已经存在该命令，如有，则先删除，后再添加）
	#使用 /var/log/rsyncTask.id 记录当前待命中的jobid（经测试taskID变量在本while循环中无法共享）
	taskID=$(cat /var/log/rsyncTask.id)
	#如果taskID不为空
	if [ ${taskID} -gt 0 ]
	then
		#taskDetail=$(at -c ${taskID} 2>&1)

		#echo ${taskDetail} >> /var/log/taskDetail.log 2>&1
		#如果当前存在该任务
		#if [ "${taskDetail}" != "Cannot find jobid ${taskID}" ]
		#then
			# 删除原任务ID
			atrm ${taskID} > /dev/null 2>&1
		#fi
	fi

	#创建新的at任务，并记录jobid到/var/log/rsyncTask.id
	taskID=$(at -f /usr/local/inotify/rsyncDo.sh now+1 min 2>&1)
	taskID=${taskID%at*}
	taskID=${taskID:4}
	echo ${taskID} > /var/log/rsyncTask.id 2>&1
	)
	#echo "${DATE} ${DIRECTORY} ${FILE} ${EVENT}" >> /var/log/rsyncInotifywait.log 2>&1
done

