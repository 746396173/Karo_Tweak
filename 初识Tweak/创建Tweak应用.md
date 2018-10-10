### 创建Tweak应用：



```shell
MacBook-Air:~ laoshiren$ cd ./Desktop
MacBook-Air:Desktop laoshiren$ mkdir myTweak
MacBook-Air:Desktop laoshiren$ cd ./myTweak/
MacBook-Air:myTweak laoshiren$ /opt/theos/bin/nic.pl 创建theos项目
  [1.] iphone/application
  [2.] iphone/library
  [3.] iphone/preference_bundle
  [4.] iphone/tool
  [5.] iphone/tweak
Choose a Template (required): 5  选择tweak模板,相当于外挂
Project Name (required): myTweak 项目名称
Package Name [com.yourcompany.mytweak]: com.yourcompany.mytweak 
包名,反域名的形式(PS:报名要全小写)
Author/Maintainer Name [老实人]: askMe 作者
[iphone/tweak] MobileSubstrate Bundle filter [com.apple.springboard]: 
com.apple.springboard 这个是你要hook住app的bundleID,在项目plist中可以修改和添加
[iphone/tweak] List of applications to terminate upon installation 
(space-separated, '-' for none) [SpringBoard]: SpringBoard 安装后要终结app的进程
Instantiating iphone/tweak in mytweak/...
Done.
```

创建完毕之后打开Makefile文件添加代码自定义功能

- Makefile：

- ```shell
  include theos/makefiles/common.mk 
  TWEAK_NAME = myTweak myTweak_FILES = Tweak.xm 
  include $(THEOS_MAKE_PATH)/tweak.mk 
  after-install:: 
    install.exec "killall -9 SpringBoard"
  ```

  ```shell
  THEOS_DEVICE_IP = 192.168.199.184 
  手机的ip地址,等会ssh协议打包安装(mac和phone同一个局域网) 
  ARCHS = armv7 arm64 
  指定处理器架构(如果不写可能报错:binary does not support this cpu type) 
  TARGET = iphone:latest:7.0 
  指定编译器sdk版本和发布最低版本(latest是你选择xcode的最新sdk,也可以填写8.0) 
  myTweak_FRAMEWORKS = UIKit 
  导入库 多个库空格隔开 
  myTweak_PRIVATE_FRAMEWORKS = AppSupport 
  导入私有库,如果你的xcod7.3需要将私有库导入到/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.3.sdk/System/Library/ 
  myTweak_LDFLAGS = -lz 􏺗􏺘􏺳􏰉􏶇􏶒􏰂􏵔􏵠􏾁
  连接mach-o对象(.dylib文件,.a文件,.o文件等),(-lz会自动搜索libz.dylib或libz.a) 
  include theos/makefiles/common.mk 
  固定写法,无需更改 
  TWEAK_NAME = myTweak 
  项目名称
  myTweak_FILES = Tweak.xm 
  tweak包含的源文件(不包含头文件) 多个空格隔开 
  include $(THEOS_MAKE_PATH)/tweak.mk 
  不同工程,指定不同.mk文件.如:application.mk􏱲,tweak.mk和tool.mk 
  after-install:: 
    install.exec "killall -9 SpringBoard" 
  安装完后终结进程

  ```

  ​