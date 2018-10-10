# KaroPlus	

## V1.0.0版本更新内容

- 指定页面导航栏背景色修改。
- 指定页面导航栏背景图修改。
- 指定页面状态栏样式修改。
- 拦截撤回。

前提： 需要一个砸壳的微信ipa

使用方式：

cd 到工程目录的Make执行得到dylib动态链接库

```shell
$ make 
编译出现
$ make: *** No rule to make target `/tweak.mk'.  Stop.  
则在命令行 设置变量：
$ export THEOS=/opt/theos  
若make成功想重新make一遍需删除隐藏目录下的.theos文件夹
```

```shell
$ cp .theos/obj/debug/xxxx.dylib ~/Desktop
```

将生成的 dylib 文件拷贝到桌面，跟砸过壳的微信应用放到一个目录层级。

### 使用macOS自带的otool进行dylib的依赖项检查

```shell
$ otool -L xxxx.dylib
xxxx.dylib (architecture armv7):
	/Library/MobileSubstrate/DynamicLibraries/xxxx.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1349.1.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1348.0.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3600.5.2)
	/usr/lib/libsubstrate.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 307.4.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1238.0.0)
xxxx.dylib (architecture arm64):
	/Library/MobileSubstrate/DynamicLibraries/xxxx.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1349.1.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1348.0.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3600.5.2)
	/usr/lib/libsubstrate.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 307.4.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1238.0.0)
```

若上面的/usr/lib/libsubstrate.dylib 而是 /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate的话，就说明你需要一份libsubstrate.dylib，怎么获得可以百度。然后将它与xxxx.dylib放在同一个目录下进入路径变更

```shell
scp root@<your.device.ip>:/usr/lib/libsubstrate.dylib ~/Desktop
$ install_name_tool -change /usr/lib/libsubstrate.dylib @loader_path/libsubstrate.dylib xxxx.dylib
$ otool -L xxxx.dylib
xxxx.dylib (architecture armv7):
	/Library/MobileSubstrate/DynamicLibraries/xxxx.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1349.1.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1348.0.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3600.5.2)
	@loader_path/libsubstrate.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 307.4.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1238.0.0)
xxxx.dylib (architecture arm64):
	/Library/MobileSubstrate/DynamicLibraries/xxxx.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1349.1.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1348.0.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3600.5.2)
	@loader_path/libsubstrate.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 307.4.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1238.0.0)
```

若之前目录为/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate的，需要把上面-change后面的路径改成/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate

### 将dylib注入二进制文件中

这里我们使用[TK](https://github.com/TKkk-iOSer/WeChatPlugin-iOS)写好的、在Make/Others下的autoInsertDylib.sh进行注入。

sh使用方式：

```shell
打开终端
$ autoInsertDylib.sh文件的目录 ipa文件路径  dylib文件路径 即可获得注入dylib的app文件
```

### 重签名、打包 —app转成ipa的过程

##### 一. 可以使用集成[MonkeyDev](https://github.com/AloneMonkey/MonkeyDev)，放入对应的TargetApp的目录下然后进行真机编译。使用方法：请阅读对应Wiki文档: [Wiki](https://github.com/AloneMonkey/MonkeyDev/wiki)

##### 二. 使用[ios-app-signer](http://dantheman827.github.io/ios-app-signer/)进行重签名打包

#### 最后将生成好的ipa进行安装。可以使用pp助手或者xcode。

