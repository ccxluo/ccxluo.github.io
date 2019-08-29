---
title: 圣杯布局 VS 双飞翼布局
date: 2018-11-16
tags: 前端
categories: [前端]
---

最近在学习 CSS 布局，看到了这两个经典布局（其实是同一个只是实现方式不同），才发现自己原来对很多 CSS 属性理解的都不够，于是仔细看了这两个布局的实现方式自己动手做了一遍，希望能有更深的理解。

圣杯布局和双飞翼布局都是实现三栏布局的方法，页面整体分为三部分，header、container、footer，其中 container 部分左右定宽，中间自适应，是很常见的布局，效果如下图。

![](https://upload-images.jianshu.io/upload_images/3028410-9e4b1105eef88810.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

下面分别介绍两种布局的实现原理。

<!--more-->

### 圣杯布局


html 代码如下：

```html
<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="utf-8">
    <title>Layout Demo</title>
    <link rel="stylesheet" href="./style.css">
  </head>
  <body>
    <div class="header">header</div>
    <div class="container">
      <div class="main">main</div>
      <div class="left">left</div>
      <div class="right">right</div>
    </div>
    <div class="footer">footer</div>
  </body>
</html>

```

note： 先写 main 部分是因为要先渲染中间部分。

- 给每一部分加上背景颜色，左右边栏固定宽度100px，中间栏宽度自适应，此时页面长这样：

 ![](https://upload-images.jianshu.io/upload_images/3028410-f550f8499e795b99.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 将 main、left、right 部分都设置左浮动,此时由于中间部分脱离了文档流，footer 就会挤上去，因此需要给 container 加上 `overflow: hidden;`，保证中间部分的空间留出来。

 ![](https://upload-images.jianshu.io/upload_images/3028410-aec0407beb5772ec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 此时 left 和 right 依旧在下一行，为了使 left 和 right 移上去，则需要缩小 main 部分的宽度，通过 container 的 padding 来设置。设置 container 的左右 padding 为 100px，给 left 加上 `margin-left： -100%`使其上移一行。

 ![](https://upload-images.jianshu.io/upload_images/3028410-506f466f6fb87f4f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 使用相对定位使left 靠左 
  
  ```
    position: relative;
    left: -100px;
  ```
  
 ![](https://upload-images.jianshu.io/upload_images/3028410-424d7c2e406c985a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 同理，将 right 部分上移
  
<pre>
   margin-left: -100px;
   position: relative;
   right: -100px;
</pre>

  
 ![](https://upload-images.jianshu.io/upload_images/3028410-0b9eab854c999817.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 
### 双飞翼布局

双飞翼布局和圣杯布局在实现思路上大致相同，区别是双飞翼布局在 main 部分外面多了一层 div，利用父层 div 的 margin 值取代了圣杯布局中 container 的 padding，

- 先回到基础布局的样子

 ![](https://upload-images.jianshu.io/upload_images/3028410-f550f8499e795b99.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 给 main 部分加一个内层 div，三部分（main、left、right）都设置`float: left;`,  main 部分`width: 100%;`,  left 和 right 定宽
	
 html 结构如下：
	
 ```html
	<!DOCTYPE html>
	<html lang="en" dir="ltr">
	  <head>
	    <meta charset="utf-8">
	    <title>Layout Demo</title>
	    <link rel="stylesheet" href="./style.css">
	  </head>
	  <body>
	    <div class="header">header</div>
	    <div class="container">
	      <div class="main">
	        <div class="inner-main">main</div>
	      </div>
	      <div class="left">left</div>
	      <div class="right">right</div>
	    </div>
	    <div class="footer">footer</div>
	  </body>
	</html>
 ```

 ![](https://upload-images.jianshu.io/upload_images/3028410-6716b54ca76b68a1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 为了使 left 和 right 上移需要缩小 main 的宽度，和圣杯布局不同的是，这里通过设置 inner-main 的 margin 来留出位置，同样使用负 margin 来使得 left 和 right 上移（这里不需要使用相对定位）

 ![](https://upload-images.jianshu.io/upload_images/3028410-3d5370e523f3ed4e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 
### 总结

通过上面两种实现方式可以看出，圣杯布局和双飞翼布局在思路上的区别是：

- 圣杯布局通过设置主元素的 padding 来为左右栏留出位置，而双飞翼布局是在中间栏增加子元素，通过内层子元素的 margin 来为左右栏留出位置（注意： 双飞翼布局中 width 和 float 属性都是设置在外层 div 上的）

- 圣杯布局中为了使得左右栏分布在最左和最右需要同时使用负 margin 和相对定位实现，而双飞翼布局中不需要使用相对定位

[代码示例](https://github.com/XLuoChen/Layout-demo/tree/master)

 

