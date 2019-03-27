#!/bin/bash
SRC_DIR="/home/wwwroot/www"  #注意末尾不含/
#使用 $I_DIR_LOG 记录发生变动的目录
I_DIR_LOG="/usr/local/inotify_rsync/i_dir.log"
RSYNC_TASK_ID="/usr/local/inotify_rsync/rsync_task.id"
TRANSLATING_LOG="/usr/local/inotify_rsync/translating.log"
ERR_LOG="/usr/local/inotify_rsync/error.log"

#@7ckf 用于监控到的目标文件夹发生变动后的1min以内，启动rsync到远程主机
#从$I_DIR_LOG一次性获取到所有目录
cat ${I_DIR_LOG} | while read DERECTORY
do
	echo $(date "+%Y-%m-%d %H:%M:%S") " Translating ${SRC_DIR}${DERECTORY} to ${DERECTORY}.." >> ${TRANSLATING_LOG} 2>&1
	#注意rsync不要使用-r参数，避免发生递归，影响效率
	#rsync -PdztopgDl --delete ${SRC_DIR}${DERECTORY} ${DERECTORY} 2>> $ERR_LOG #错误重定向
	#2018-10-25 去掉了-opg 选项
	rsync -PdztDl --delete --exclude="Html" --exclude="PDF" --exclude="Runtime" --exclude="*.log" --exclude="*.shtml" --exclude=".ftpquota" --exclude=".svn" --exclude=".well-known" --password-file=/usr/local/inotify_rsync/user.pwd ${SRC_DIR}${DERECTORY} rsync://rsync_user@192.168.1.100/rsync_module${DERECTORY}
done
#清空$I_DIR_LOG  rsyncTask.id
> ${I_DIR_LOG}
> ${RSYNC_TASK_ID}