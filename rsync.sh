#!/bin/bash
#监控目标目录
SRC_DIR="/home/wwwroot/www/"
#使用 $I_DIR_LOG 记录发生变动的目录
I_DIR_LOG="/usr/local/inotify_rsync/i_dir.log"
#使用 $RSYNC_TASK_ID 记录当前待命中的jobid（经测试taskID变量在本while循环中无法共享）
RSYNC_TASK_ID="/usr/local/inotify_rsync/rsync_task.id"
#declare -A DIRECTORYS
/usr/bin/inotifywait -mrq --excludei '/Runtime*?/' --timefmt '%Y%m%d_%H:%M:%S' --format '%T %w %f %Xe' -e create,delete,attrib,close_write,move ${SRC_DIR} | while read DATE DIRECTORY FILE EVENT
do
	# ${DIRECTORYS[${DIRECTORY}]}=${DIRECTORY}
	# 只记录相对根目录的目录
	DIRECTORY_s="/"${DIRECTORY#*${SRC_DIR}}
	#判断数组/文件中是否有值
	grep -wq "${DIRECTORY_s}" ${I_DIR_LOG} && > /dev/null 2>&1 || ( echo "${DIRECTORY_s}" >> ${I_DIR_LOG} 2>&1 && 
	#启动at命令，1min后执行rsyncDo.sh（先判断当前atq队列中是否已经存在该命令，如有，则先删除，后再添加）
	taskID=$(cat $RSYNC_TASK_ID)
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

	#创建新的at任务，并记录jobid到$RSYNC_TASK_ID
	taskID=$(at -f /usr/local/inotify/rsyncDo.sh now+1 min 2>&1)
	taskID=${taskID%at*}
	taskID=${taskID:4}
	echo ${taskID} > ${RSYNC_TASK_ID} 2>&1
	)
	#echo "${DATE} ${DIRECTORY} ${FILE} ${EVENT}" >> /var/log/rsyncInotifywait.log 2>&1
done

