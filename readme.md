## 设置 rsync 相关同步项目、密码
```vi /etc/rsyncd.conf```
## 以 daemon 方式启动 rsync 服务端：
```
rsync --daemon --config=/etc/rsyncd.conf
```
## inotifywait后台监控文件变更； 
### 1、先确认 inotify-tools 工具是否已安装，使用如下命令：
```rpm -qa inotify-tools```  
也可以通过查询 inotifywait 所在的目录：  
```which inotifywait /usr/bin/inotifywait```
### 2、如果需要安装 inotify-tools 的，使用如下命令：
```yum install inotify-tools -y```
### 3、编写 rsync.sh 监控程序，并赋予执行权限：
```chmod +x /usr/local/inotify/rsync.sh```
#### 关于 rsync.sh 程序里面的内容，大致介绍如下：
> 1、rsync.sh捕获记录发生文件变动的目录，排除重复目录；  
> 2、在发生变动后 1 min 自动启动同步程序 rsyncDo.sh;
> 3、如果一分钟内再次监控到文件变更，则取消当前同步计划，并预约下一个 1 min的同步计划；  
> 4、启动 rsyncDo.sh 程度，向目标主机同步文件；

### 4、后台运行 rsync.sh 程序，保持对目标文件夹的监控：
```nohup /bin/sh /usr/local/inotify/rsync.sh &```

  
## 5、解决相关权限问题；  