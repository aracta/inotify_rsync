# 开发背景
我们一般采用rsync+inotify实现两台服务器之间文件自动同步。然而，当前网上众多的使用该方案的教程其实隐含了许多的坑，比如对于文件修改较为频繁的情况下，使用了rsync的全量或递归参数(-a或-r)会导致同步性能急剧下降。网上也有针对此情况的优化方案，例如这篇文章[《真正的inotify+rsync实时同步 彻底告别同步慢》](http://www.ttlsa.com/web/let-infotify-rsync-fast/)，该方案通过对监控到的变动事件进行区分处理，从而规避了rsync的递归扫描，并结合每2小时一次的全量定时同步，从而实现所谓的“实时同步”。然而该方案仍有一定的不完美之处，即，当某一短时间段内发生较多的文件变动时（例如通过FTP对某一目录大批量上传了图片等），rsync会在短时间内频繁启动，从而造成CPU消耗巨大。为处理该问题，本项目结合实际需求，引入了“防抖操作”概念，即增加了 1 分钟的定时任务方案，从而“优雅”地解决了该问题。本项目的同步方案为 1 分钟的延迟同步，所以不能接受这较大尺度的延迟的开发者需注意此问题。
# 开发步骤
本方案的开发者需掌握rsync、inotify的相关原理及配置知识。
## 一、设置 rsync 相关同步项目、密码
```
vi /usr/local/inotify_rsync/rsyncd.conf
```  
具体项目配置请参考rsync相关教程，在此不赘述。
## 二、以 daemon 方式启动 rsync 服务端：
```
rsync --daemon --config=/usr/local/inotify_rsync/rsyncd.conf
```
## 三、inotifywait后台监控文件变更：
### 1、先确认 inotify-tools 工具是否已安装，使用如下命令：
```rpm -qa inotify-tools```  
也可以通过查询 inotifywait 所在的目录：  
```which inotifywait /usr/bin/inotifywait```
### 2、如果需要安装 inotify-tools 的，使用如下命令：
```yum install inotify-tools -y```
### 3、编写 rsync.sh 监控程序：
> 1）rsync.sh捕获记录发生文件变动的目录，排除重复目录；  
> 2）在发生变动后 1 min 自动启动同步程序 rsyncDo.sh;  
> 3）如果一分钟内再次监控到文件变更，则取消当前同步计划，并预约下一个 1 min的同步计划；  
> 4）启动 rsyncDo.sh 程序，向目标主机同步文件；
### 4、赋予 rsync.sh 执行权限：
```chmod +x /usr/local/inotify_rsync/rsync.sh```
### 5、后台运行 rsync.sh 程序，实现对目标文件夹的后台监控：
```nohup /bin/sh /usr/local/inotify_rsync/rsync.sh &```
### 6、当监控到文件改动后 1 分钟，启动 rsyncDo.sh 程序：
  
## 四、其他：注意相关权限问题；  