#!/bin/bash
# This is flutter build

# 初始化记录项目pwd
projectDir=`pwd`

# 假如没有引用三方的flutter Plugin 设置false 即可 *************************
isPlugin=false

# 版本号 + 1
function updateAArVersion(){
    cd ${projectDir}
    v=`grep VERSION_NAME configs/gradle.properties|cut -d'=' -f2`
    echo 旧版本号$v
    v1=`echo | awk '{split("'$v'",array,"."); print array[1]}'`
    v2=`echo | awk '{split("'$v'",array,"."); print array[2]}'`
    v3=`echo | awk '{split("'$v'",array,"."); print array[3]}'`
    y=`expr $v3 + 1`

    vv=$v1"."$v2"."$y
    echo 新版本号$vv
    # 更新配置文件
    echo `pwd`
    sed -i 's/VERSION_NAME='$v'/VERSION_NAME='$vv'/g' configs/gradle.properties
    if [ $? -eq 0 ]; then
        echo ''
    else
        echo '更新版本号失败...'
        exit
    fi
}
updateAArVersion
# 删除 fat-aar 引用
function delFatAarConfig() {
    if [  ${isPlugin} == false  ]; then
        echo '删除 fat-aar 引用........未配置三方插件'
    else :
        cd ${projectDir} # 回到项目
        echo '删除 fat-aar 引用 ... '
        sed -i '' '$d
            ' .android/settings.gradle
        sed -i '' '$d
            ' .android/Flutter/build.gradle
        sed -i '' '$d
            ' .android/Flutter/build.gradle
        sed -i '' '11 d
            ' .android/build.gradle
    fi
}

# 引入fat-aar
function addFatAArConfig() {
     if [  ${isPlugin} == false  ]; then
        echo '引入fat-aar 配置........未配置三方插件'
     else :
        cd ${projectDir} # 回到项目

        cp configs/setting_gradle_plugin.gradle .android/config/setting_gradle_plugin.gradle

        if [ `grep -c 'setting_gradle_plugin.gradle' .android/settings.gradle` -eq '1' ]; then
            echo ".android/settings.gradle 中 已存在 ！！！"
        else
            echo ".android/settings.gradle 中 不存在，去编辑"
            sed -i '' '$a\
            apply from: "./config/setting_gradle_plugin.gradle"
            ' .android/settings.gradle
        fi

        if [ $? -eq 0 ]; then
            echo '.android/settings.gradle 中 脚本插入 fat-aar 成功 !!!'
        else
            echo '.android/settings.gradle 中 脚本插入 fat-aar 出错 !!!'
            exit 1
        fi

        if [ `grep -c 'com.kezong:fat-aar' .android/build.gradle` -eq '1' ]; then
            echo "com.kezong:fat-aar:1.2.4 已存在 ！！！"
        else
            echo "com.kezong:fat-aar:1.2.4 不存在，去添加"
            sed -i '' '10 a\
            classpath "com.kezong:fat-aar:1.2.4"
            ' .android/build.gradle
        fi

        # flutter/build.gradle 中添加fat-aar 依赖 和 dependencies_gradle_plugin
        if [ `grep -c "com.kezong.fat-aar" .android/Flutter/build.gradle` -eq '1' ]; then
            echo "Flutter/build.gradle 中 com.kezong:fat-aar 已存在 ！！！"
        else
            echo "Flutter/build.gradle 中 com.kezong:fat-aar 不存在，去添加"
            sed -i '' '$a\
            apply plugin: "com.kezong.fat-aar"
            ' .android/Flutter/build.gradle
        fi

        cp configs/dependencies_gradle_plugin.gradle .android/config/dependencies_gradle_plugin.gradle
        if [ `grep -c 'dependencies_gradle_plugin' .android/Flutter/build.gradle` -eq '1' ]; then
            echo "Flutter/build.gradle 中 dependencies_gradle_plugin.gradle 已存在 ！！！"
        else
            echo "Flutter/build.gradle 中 dependencies_gradle_plugin.gradle 不存在，去添加"
            sed -i '' '$a\
            apply from: "../config/dependencies_gradle_plugin.gradle"
            ' .android/Flutter/build.gradle
        fi
      fi
}


# step1 clean
echo 'clean old build'
find . -depth -name "build" | xargs rm -rf
cd ${projectDir} # 回到项目
rm -rf .android/Flutter/build
flutter clean



# step 2 package get
echo 'packages get'
cd ${projectDir} # 回到项目
flutter packages get

# step3 脚本补充：因为.android是自动编译的，所以内部的配置文件和脚本不可控，所以需要将configs内的脚本自动复制到 .android 内部
echo 'copy configs/uploadArchives.gradle to .android/config/... ,    copy configs/gradle.properties to Flutter/gradle.properties'
if [  -d '.android/config/' ]; then
   echo '.android/config 文件夹已存在'
else :
   mkdir .android/config
fi

if [  -f ".android/config/uploadArchives.gradle" ];then
    echo '.android/config/uploadArchives.gradle 已存在'
else :
    cp configs/uploadArchives.gradle .android/config/uploadArchives.gradle
fi

cp configs/gradle.properties .android/Flutter/gradle.properties

# step 4  脚本补充：同时在Flutter 的gradle中插入引用  apply from: "../uploadArchives.gradle"
echo '在Flutter 的gradle中插入引用  apply from: "../uploadArchives.gradle"'
if [ `grep -c 'uploadArchives.gradle' .android/Flutter/build.gradle` -eq '1' ]; then
    echo "Found!"
else
    echo "not found , 去修改"
    sed -i '2i\
    apply from: "../config/uploadArchives.gradle"' .android/Flutter/build.gradle
fi

# setp 5 脚本补充：引入fat-aar 相关脚本
# 在 settings.gradle 中 插入 ， 注意 sed 命令换行 在mac下 是 \'$'\n

addFatAArConfig

# step 6 build aar ，生成 aar ， 然后上传到maven
echo 'build aar'
cd ${projectDir}
flutter build apk
if [ $? -eq 0 ]; then
    echo '打包成aar 成功！！！'
else
    echo '打包成aar 出错 !!!'
    exit 1
fi

cd ${projectDir}/.android
./gradlew flutter:uploadArchives
#gradle clean flutter:assembleRelease uploadArchives --info

if [ $? -eq 0 ]; then
    echo 'uploadArchives 成功！！！'
else
    echo 'uploadArchives 出错 !!!'
    delFatAarConfig
    exit 1
fi

# step 7 remove unused files
echo 'remove assets/lib'
cd ${projectDir}/.android/Flutter/src/main/
rm -rf assets
rm -rf lib
delFatAarConfig

echo '<<<<<<<<<<<<<<<<<<<<<<<<<< 结束 >>>>>>>>>>>>>>>>>>>>>>>>>'
echo '打包成功 : flutter-release-'${vv}'.aar...................！ '
exit