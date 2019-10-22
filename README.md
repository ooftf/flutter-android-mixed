# flutter-android-mixed

这是一个Flutter和Android混合开发的示例项目，本项目采用将flutter项目打包成arr，然后Android项目引用的方式进行混合开发  
详细细节可查看文章[flutter打包aar上传maven集成到原生android工程](https://www.jianshu.com/p/2258760e9540)  
本文主要对上述文章内容进行补充  
# 根据文章进行项目部署主要遇到以下几个问题
1. 项目结构
    创建flutter项目要选择flutter module
2. flutter.sh文件怎么运行？  
    安装git，然后在flutter.sh所在目录右键点击git bash here  
    s输入命令 sh flutter.sh  
3. 如果你使用和文章中相同的 flutter.sh文件可能还会遇到['更新版本号失败...']的问题  
    发生问题的原因是sh文件命令有几处语法错误。现已经修改完成。使用本项目的flutter.sh即可  
4. 打包成的arr文件后续加载过程和问题解决都没有。    
    
# Android项目加载arr文件，展示界面
### Android加载flutter界面
```kotlin
     val flutterView = Flutter.createView(
                this,
                lifecycle,
                "route1"
        )
        val layout = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        addContentView(flutterView, layout)
```
### 可能会遇到Either bundlePath or bundlePaths must be specified
##### 问题出现原因：
    Flutter.createView(
                this,
                lifecycle,
                "route1"
        )
    第三个参数"route1"指定了要加载界面的key但是在打包成arr的模块中却没有地方接收导致
#### 解决方式：
    void main() => runApp(_widgetFroRouter(window.defaultRouteName));
    
    Widget _widgetFroRouter(String route){
      switch (route) {
        case 'route1':
          return MyApp();
        case 'route2':
          return MyApp();
        default:
          return Center(
            child: Text('Unknown route: $route', textDirection: TextDirection.ltr),
          );
      }
    }     
    其中  window.defaultRouteName就是 Flutter.createView第三个参数，根据不同的参数返回不同的界面
### 遇到can't find libflutter.so  问题
    重新build一下应该就可以了
# 未验证
## 如果没有maven私服，可以使用阿里https://maven.aliyun.com/mvn/view

# 如果有什么问题欢迎进行交流QQ:994749769
