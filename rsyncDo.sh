#!/bin/bash
SRC_DIR="/home/wwwroot/s1.elabscience.com"  #注意末尾不含/
#TAR_DIR="/home/wwwroot/s1.elabscience.com"  #注意末尾不含/
#@7ckf 用于监控到的目标文件夹发生变动后的1min以内，启动rsync到远程主机
#从/var/log/rsyncDrectory.log一次性获取到所有目录
cat /var/log/rsyncDrectory.log | while read DERECTORY
do
	echo $(date "+%Y-%m-%d %H:%M:%S") " Translating ${SRC_DIR}${DERECTORY} to ${TAR_DIR}${DERECTORY}.." >> /var/log/rsyncTranslating.log 2>&1
	#注意rsync不要使用-r参数，避免发生递归，影响效率
	#rsync -PdztopgDl --delete ${SRC_DIR}${DERECTORY} ${TAR_DIR}${DERECTORY} 2>> /var/log/rsyncError.log #错误重定向
	#2018-10-25 去掉了-opg 选项
	rsync -PdztDl --delete --exclude="Html" --exclude="PDF" --exclude="Runtime" --exclude="*.log" --exclude="*.shtml" --exclude=".ftpquota" --exclude=".svn" --exclude=".well-known" --password-file=/root/rsyncuser/elabcom_pass ${SRC_DIR}${DERECTORY} rsync://elabcomuser@172.20.145.13/elabcom${DERECTORY}
done
#清空/var/log/rsyncDrectory.log  rsyncTask.id
> /var/log/rsyncDrectory.log
> /var/log/rsyncTask.id