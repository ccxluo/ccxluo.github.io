---
title: 如何实现 mysql 服务器的高可用
date: 2017-10-10
tags: [Devops]
categories: [运维相关]
---

### 什么是高可用

**高可用集群是指以减少服务中断时间为目的的服务器集群技术。它通过保护用户的业务程序对外不间断提供的服务，把因软件/硬件/人为造成的故障对业务的影响降低到最小程度。**

通俗来讲，就是有多台服务器提供相同的服务，当有一台服务器因为某种原因挂掉的时候还有其他机器可以提供服务而不致于使整个服务瘫痪。

### 业务场景

后端服务器和 mysql 服务器分离，要求实现 mysql 服务器的高可用。

<!--more-->

### 分类

假设有两台 mysql 服务器，实现 mysql 高可用的机制有两种，**主 – 从**式和**主 – 主**式。

1.  **主 – 从**

    所谓主 – 从式，顾名思义，一个主机（master）和一个从机（slave），在这种架构中其实就一个主在工作，而从就相当于一个备份机器，从通过日志监测的方式来备份主库上的数据而保证主库的数据安全。在这种架构中如果从上的数据做了改变，主数据是不会用任何变化的。因为 mysql 主从架构主要是 mysql 从监控 mysql 主的日志变化来实现同步，相反的在这个架构中主并没有监控从的日志变化。所以，mysql 从数据反生变化，主也就没有什么变化了。

    因此这种架构就要实现主从的“读写分离”，即只允许对主机进行写，对从机来说只负责读数据。在主从机上做一些配置，当主机故障启动从机的时候，如果需要写入数据，数据不会写在从机上，而是写在主机上，这样就能保证当主机恢复服务的时候数据是同步的。

2.  **主 – 主**

    为什么会有主 – 主方式呢，因为有时候 mysql 的主从不能满足现实中的一些实际需求。比如，一些流量大的网站数据库访问有了瓶颈，需要负载均衡的时候就用两个或者多个的 mysql 服务器，而这些 mysql 服务器的数据库数据必须要保持一致，那么就会用到主主复制。另外，个人觉得如果是主 – 从式的话每次只有一个服务器工作，而另一个一直闲置有点浪费资源。

    本文中主要介绍主 – 主方式。

### 方案设计

[![image](https://upload-images.jianshu.io/upload_images/3028410-117900f0e70f8663.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2017/10/10/%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0-mysql-%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8/2.png) 

**此次方案采用主 – 主架构**

如上图所示，此次的方案是：首先在服务器的 /etc/hosts 中添加一个 ip 地址映射，设置一个默认的 mysql 连接地址，在项目中使用地址映射的名称连接数据库，然后使用脚本实时监控正在使用的 mysql 服务器的状态，一旦发现异常则修改 /etc/hosts 文件，将 mysql 的 ip 地址更改为另外一台 mysql 服务器的 ip 地址。同时设置两台 mysql 服务器使得其上的数据总是同步的。

**因此，对于这种方案需要解决的问题如下：**

1.  如何实现 mysql 主主服务器间的数据同步；
2.  如何实时监控 mysql 服务器的状态；
3.  如何动态变化 hosts 地址映射；

### 实现过程

#### 1.如何实现 mysql 主主服务器间的数据同步

从主 – 从架构和主 – 主架构的区别可以看出如果想实现主主复制，无非就是在 mysql 主从架构上让 mysql 主实现监测从的日志变化，从而实现两台机器相互同步。

在这之前，我们还需要设置 mysql 数据库能够被其他机器访问到，步骤如下：

**创建一个 mysql 的账号用于连接**

[![image](https://upload-images.jianshu.io/upload_images/3028410-443df61bb72dafa2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2017/10/10/%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0-mysql-%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8/3.png) 

类似上图中的用户，例如创建一个 remote 用户，密码为‘remote’，设置成所有 ip 都可访问的，并授予其所有权限，命令如下：

<pre>

mysql> CREATE User 'remote'@'%' IDENTIFIED BY 'remote';

mysql> GRANT ALL PRIVILEGES ON *.* TO 'remote'@'%';

mysql> FLUSH PRIVILEGES;

</pre>

（友情提示：一般情况下不要使用 root 用户去做连接）

接下来就可以继续了。。。

具体操作步骤[👇 戳这里 👇](http://duyunlong.blog.51cto.com/1054716/1306841)

（感谢博主的教程）

另外补充一个遇到的问题，在按照上述教程配置完两个 mysql 服务器后，正常情况下当查看 slave 状态时下图两项应该显示“yes”

[![image](https://upload-images.jianshu.io/upload_images/3028410-d69cbcdf8967638b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2017/10/10/%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0-mysql-%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E9%AB%98%E5%8F%AF%E7%94%A8/B0C5BE6C-7DCC-46C6-B4ED-38D9A0B3EA7D.png) 

但是我的其中一台 mysql 服务器的 Slave_ SQL _Running 总是显示 “no”，即使重新设置主服务器的时候显示“yes”，但是过一会就会“自动”变成“no”，以至于两台服务器的数据无法同步。

**最终解决方案：**

<pre>

mysql -p

STOP SLAVE;

SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;

START SLAVE;

</pre>

***注意：*** 主从方式的设置见[👇 这里 👇](http://369369.blog.51cto.com/319630/790921)

#### 2\. 如何实时监控 mysql 服务器的状态

在第一步中我们已经设置了 mysql 能被其他机器访问到并且创建了账户，因此这一步可以使用刚才创建的用户访问 mysql 并查看其状态判断有没有宕机。

对于 mysql 运行状态的检测有以下几种方法：

[👇 戳这里 👇](https://zhuanlan.zhihu.com/p/20285970)

**有了判断 mysql 状态的方法，那么重头戏来了，如何做到实时监控呢？**

**答案是：使用 crontab**

**crontab** 是 Linux 下的一个命令，我们可以使用它实现定时任务。

先去 Ubuntu 的 /etc 目录下看看，我们都知道 /etc 目录主要用来存放系统中的配置文件，基本上所有的配置文件都可以在这里找到。运行以下命令看看：

<pre>

ls /etc/cron*

</pre>

这个命令会列出/etc目录下所有以cron开头的文件和文件夹。可以看到主要有以下文件夹：

<pre>

/etc/cron.hourly 这里存放了每小时需要运行的脚本

/etc/cron.daily 这里存放了每天需要运行的脚本

/etc/cron.weekly 这里存放了每个星期需要运行的脚本

/etc/cron.monthly 这里存放了每月需要运行的脚本

/etc/cron.d 如果既不是按小时，也不按天，周和月来运行，就放在这个文件夹

</pre>

当我们把脚本放到对应目录下之后，系统就会按照目录所对应的规则定时执行脚本。

由于cron 是Linux的内置服务，但它不自动起来，可以用以下的方法启动、关闭这个服务：

<pre>

service cron start //启动服务

service cron stop //关闭服务

service cron restart //重启服务

service cron reload //重新载入配置

</pre>

如果我们想要一些自定义的服务呢，例如我想让脚本每 5 分钟执行一次，这时 crontab 提供的定时机制就不能满足需求了。

在命令行输入 **crontab -e**， 就会出现一个文件，让你填写对应的定时规则（在这之前有可能会让你选编辑器，选一个就好了）

那么这个规则是什么？

类似 jenkins 执行的定时规则，

<pre>

{minute} {hour} {day-of-month} {month} {day-of-week} {full-path-to-shell-script}

</pre>


minute：区间为0–59；

hour：区间为0–23；

day-of-month：区间为0–31；

month：区间为1–12；1是1月，12是12月；

Day-of-week：区间为0–6；周日是0。

**除了数字还有以下几个特殊的符号需要特殊说明：**

*：代表所有的取值范围内的数字；

/：代表每的意思，”*/5″表示每5个单位；

-：代表从某个数字到某个数字；

,：分开几个离散的数字。

(类似 jenkins 中的定时规则)

**因此，对于上面提到的每五分钟运行一次的需求，步骤如下：**

<pre>

1\. crontab -e    ---- 编辑设置规则的文件

2\. */5 * * * *  path/to/script >> /path/to/log

</pre>

编辑完成，保存完成以后，就会显示以下提示信息：

<pre>

crontab: installing new crontab

</pre>

如果没有这条提示信息，请重新运行 crontab -e 命令

**（记得重启 crontab 服务）service cron restart**

ok，搞定了，现在系统就会每 5 分钟运行一次脚本了。

#### 3. 如何动态变化 hosts 地址映射

最后一步了，如何在发现 mysql 运行异常的时候自动切换到另一台机器上呢。

脚本内容如下： 

<pre>

#!/bin/bash

USER=root

PASS=root

remote_server_ip=`cat /etc/hosts |grep 'mysql_machine'|awk '{print $1}'`

default_ip=192.168.30.25

mysqladmin -h$remote_server_ip -u$USER ping -p$PASS &>/dev/null  ###user should  have mysql permission on remote server. Ideally you should use different user than root.

if [ $? -eq 0 ]
  then
    echo "connecting successfully"
  else
    if [ "$remote_server_ip" == "$default_ip" ]
      then
        sudo sed -i 's/192.168.30.25/192.168.30.15/g' /etc/hosts
      else
        sudo sed -i 's/192.168.30.15/192.168.30.25/g' /etc/hosts
    fi
</pre>

**说明：**

首先获得 /etc/hosts 中 ‘mysql_chine’ 这一项的对应 ip 地址存到变量里，每次发现 mysql 异常的时候就改变这一项的 ip 地址；

**$?** 表示上一条运行的命令的返回状态，如果是 0 则运行成功，否则运行出错（正是通过尝试连接 mysql的状态判断 mysql 是否正常运作）

