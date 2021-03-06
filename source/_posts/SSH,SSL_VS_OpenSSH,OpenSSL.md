---
title: SSH、SSL 以及 OpenSSH、OpenSSL 的区别
date: 2017-10-16
tags: [Linux]
categories: [Linux]
---

## 什么是 SSH

**SSH是一种网络协议，用于计算机之间的加密登录。**

最早的时候，互联网通信都是明文通信，一旦被截获，内容就暴露无疑。1995年，芬兰学者Tatu Ylonen设计了SSH协议，将登录信息全部加密，成为互联网安全的一个基本解决方案，迅速在全世界获得推广，目前已经成为Linux系统的标准配置。

SSH 只是加密的shell，最初是用来替代telnet的。通过port forward，也可以让其他协议通过ssh的隧道而起到加密的效果。

<!--more-->

***（Telnet是远程连接服务，它工作于在tcp/ip协议的应用层，telnet命令通常用来远程登录。但是，telnet因为采用明文传送报文，安全性不好，很多Linux服务器都不开放telnet服务，而改用更安全的ssh方式了。）***

SSH 的英文全称是Secure SHell。通过使用SSH，你可以把所有传输的数据进行加密，这样“中间人”这种攻击方式就不可能实现了，而且也能够防止DNS和IP欺骗。还有一个额外的好处就是传输的数据是经过压缩的，所以可以加快传输的速度。

SSH有很多功能，它既可以代替telnet，又可以为ftp、pop、甚至ppp提供一 个安全的“通道”。SSH是由客户端和服务端的软件组成的，有两个不兼容的版本分别是：1.x和2.x。

**从客户端来看，SSH提供两种级别的安全验证。**

第一种级别（基于口令的安全验证）只要你知道自己帐号和口令，就可以登录到远程主机。所有传输的数据都会被加密，但是不能保证你正在连接的服务器就是你想连接的服务器。可能会有别的服务器在冒充真正的服务器，也就是受到“中间人”这种方式的攻击。

第二种级别（基于密匙的安全验证）。也就是你必须为自己创建一对密匙，并把公匙放在需要访问的服务器上。如果你要连接到远程服务器，客户端软件就会向服务器发出请求，服务器收到请求之后，先在你的根目录下寻找你的公匙，然后把它和你存在远程服务器上的公匙进行比较，如果两个密钥一致，服务器就用该公钥加密「质询」（challenge）并把它发送给客户端软件，客户端再用自己的私钥进行解密。从而避免被「中间人」攻击。

[ssh 工作原理详解](http://freeloda.blog.51cto.com/2033581/1216374)

## 什么是 SSL／TLS

**SSL (Secure Sockets Layer 安全套接层)，是一种国际标准的加密及身份认证通信协议。**

SSL（Secure Sockets Layer）最初是由美国Netscape公司研究出来的，后来成为了Internet网上安全通讯与交易的标准。SSL协议使用通讯双方的客户证书以及CA根证书，允许客户/服务器应用以一种不能被偷听的方式通讯，在通讯双方间建立起了一条安全的、可信任的通讯通道。

它具备以下基本特征：信息保密性、信息完整性、相互鉴定。 主要用于提高应用程序之间数据的安全系数。

**SSL协议的整个概念可以被总结为：一个保证任何安装了安全套接字的客户和服务器间事务安全的协议，它涉及所有TC/IP应用程序。**

SSL协议的优势在于它是与应用层协议独立无关的。高层的应用层协议（例如：HTTP、FTP、Telnet等等）能透明的建立于SSL协议之上。

> TLS 是SSL 的高级版本。 IETF将其进行了标准化，并改名为TLS。

**简单理解区别: SSL 只是数据加密，而 SSH 则包括三部分， 连接， 认证和加密。**

## OpenSSH 和 OpenSSL

**OpenSSL —— 一个C语言函数库，是对SSL协议的实现。**

**OpenSSH —– 是SSH的开源实现，因此用户可以免费使用到这种安全服务。**

**OpenSSH** 是个SSH的软件，**OpenSSL** 是一个安全套接字层密码库，囊括主要的密码算法、常用的密钥和证书封装管理功能及SSL协议，并提供丰富的应用程序。比如很多程序安装依赖 **openssl** 头文件。

**简单说，openssl 是一种加密方式，openssh 程序利用了这种方式。**

