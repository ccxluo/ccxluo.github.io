---
title: '初识supervisor: 一个强大的进程管理工具'
date: 2017-10-11 
tags: deveops
---

## 背景介绍

在 pipeline 中部署项目并启动后启动命令停滞在控制台不结束导致 pipeline 停不下来。

例如，启动项目的命令为 "java -jar xxx.jar"，这时虽然已经启动项目了，但是由于当前进程无法自行终止，始终处于监听状态，故而 pipeline 永远停不下来。

<!--more-->

## 粗鲁的方法

解决这个问题一个最粗鲁的方法就是将命令抛到后台执行，命令如下：

```
nohup java -jar xxx.jar &
```
**“&”** 是shell的命令，它将命令抛到后台运行，这样就不会一直处于监听状态；

**nohup** 是为了让命令所在的子进程和他所在的 session 分离；

例如若使用 ansible 脚本运行该命令，该命令属于 ansible 这个 session 的子进程，则在 playbook 运行完之前命令是在后台运行着的，一旦 playbook 运行完成 session 结束子进程也就跟着结束了，这显然不是我们希望的，所以需要将子进程分离出来。

**nohup命令不会自动把进程变为”后台任务”，所以必须加上&符号**

***反省：***

这显然不是一个好的做法，因为如果直接把进程抛到后台运行的话，当下一次部署的时候就会与上一次的部署进程冲突（端口被占用），这时就需要写一个启动脚本，一个杀死脚本，在部署前先找到上一次部署的进程将其杀死，然后部署，最后再启动项目。

这样是很麻烦的，而且需要自己控制进程的启停，当有很多项目需要管理的时候就会很复杂。

**这时，优雅的做法出现了 —— 进程管理工具。**

## 使用 supervisor 管理进程

### 介绍

进程管理工具可以帮我们管理这些进程，我们不再需要自己判断端口找到对应进程之类的操作，由于我目前只用过 supervisor，因此主要介绍 supervisor 的使用方法。

**Supervisor是一个Linux下用Python开发的进程管理工具，提供了web管理界面，通过配置需要监控的进程，可以很方便的监控并管理进程，更厉害的是，当监控的进程因为各种原因断开的时候，能自定重启该进程。**

### 安装

```
sudo apt-get install supervisor
```

1.  安装完成后，会在 /usr/bin 下加入三个命令：

    [![image](https://upload-images.jianshu.io/upload_images/3028410-022a4f2116715ce0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2017/10/11/%E5%88%9D%E5%A7%8B-supervisor-%E4%B8%80%E4%B8%AA%E5%BC%BA%E5%A4%A7%E7%9A%84%E8%BF%9B%E7%A8%8B%E7%AE%A1%E7%90%86%E5%B7%A5%E5%85%B7/2.png) 

    *   echo_superisord_conf 生成一个配置文件示例（建议仅做学习了解使用）
    *   supervisord 服务端
    *   supervisorctl 客户端
2.  会在 /etc 目录下创建一个 supervisor 目录用于存放supervisor的配置文件

    *   /etc/supervisor/conf.d （文件夹）

    *   /etc/supervisor/supervisord.conf （文件)

    在 supervisord.conf 最后一行配置是加载所有 conf.d 下的配置文件，因此我们可以将自定义的配置文件放在 conf.d 文件夹下。

### 配置

如下图所示：

[![image](https://upload-images.jianshu.io/upload_images/3028410-4257e1f3e682f652.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://xluochen.github.io/2017/10/11/%E5%88%9D%E5%A7%8B-supervisor-%E4%B8%80%E4%B8%AA%E5%BC%BA%E5%A4%A7%E7%9A%84%E8%BF%9B%E7%A8%8B%E7%AE%A1%E7%90%86%E5%B7%A5%E5%85%B7/1.png) 

*   program 后面跟的是程序的名称，可以任意取，是为了区分同文件中的多个程序的
*   command 后面设置程序的启动命令
*   autorstart=true 表示允许自动重启
*   stdout_logfile 用来设置 log 文件的路径

    好了，现在启动 supervisor 就可以正常工作了。

    启动命令：

    ```
    sudo supervisord
    ```

启动之后，可在进程列表中看到对应进程，当用 kill 命令杀死进程后会发现 supervisor 再次重启了这个进程了。

