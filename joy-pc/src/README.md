[TOC]

## 一、开发准备

1.准备 qt5.9.9 环境 http://download.qt.io/archive/qt/5.9/5.9.9/

2.VS2015 环境

3.vsaddin http://download.qt.io/archive/vsaddin/2.4.2/，下载 vs2015 版本。下载后，在 vs2015 安装后，直接安装即可

## 二、编译脚本

查看 build.bat 脚本，请按照脚本内的参数进行配置

## 三、目录结构

1、Build 属于脚本目录，主要是 SDK 脚本

2、sln 是 vs 解决方案目录

3、src 代码目录

​	3.1、baseui  通用控件类

​	3.2、common 通用类

​	3.3、main 主界面，包括 ui 和 logic

​	3.4、living 直播/播放界面，包括 ui 和 logic

​	3.5、ui 包括 qt 的 .ui 文件