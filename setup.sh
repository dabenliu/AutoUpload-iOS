#!/bin/sh
# 使用方法
# 1.修改下方配置信息
# 2.将AutoUpload文件夹复制到工程的根目录
# 3.拖拽setup.sh文件到终端

# 配置信息
# ————配置开始————————————————————————————————————————————————————
#这里配置完参数则运行脚本时不再需要进行手动输入（用于参数化构建）
parameter_workspace=""
##打包模式
parameter_configuration=""
##打包类型
parameter_type=""
##上传类型
parameter_upload=""
#上传bugly
parameter_bugly=""
##上传appstore
##账号
parameter_username=""
##独立密码
parameter_password=""

#设置teamID（必须配置）
teamID=""
# ————配置结束————————————————————————————————————————————————————

echo "\033[32m****************\n开始自动打包\n****************\033[0m\n"

# ==========自动打包配置信息部分========== #
#进入当前目录
cd "$(dirname $0)"

#当前路径
current_path=$(pwd)
#项目路径
project_path=$(dirname $(pwd))
#项目所在路径
project_parent_path=$(dirname $(dirname $(pwd)))

#返回上一级目录,进入项目工程目录
cd ..
#获取项目名称
project_name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

#获取工程plist配置文件
info_plist_path="${project_name}/Info.plist"

#设置build版本号（可以不进行设置）
date=`date +"%Y%m%d%H%M"`
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $date" "$info_plist_path"

#获取build版本号
bundle_build_version=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${info_plist_path}`

#指定输出ipa路径
export_path_ipa="$project_parent_path/$project_name-IPA"
#指定输出归档文件地址
export_path_archive="$export_path_ipa/$project_name.xcarchive"

echo "\033[32m****************\n自动打包选择配置部分\n****************\033[0m\n"

# ==========自动打包可选择信息部分========== #
# 输入是否为工作空间
archiveRun () {
    #是否是工作空间
    echo "\033[36;1m是否是工作空间(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. 是 \033[0m"
    echo "\033[33;1m2. 否 \033[0m"
    
    if [ ${#parameter_workspace} == 0 ]
    then
        #读取用户输入
        read parameter_workspace
        sleep 0.5
    fi

    if [ "$parameter_workspace" == "1" ]
    then
        echo "\n\033[32m****************\n将采用：xcworkspace\n****************\033[0m\n"
    elif [ "$parameter_workspace" == "2" ]
    then
        echo "\n\033[32m****************\n将采用：xcodeproj\n****************\033[0m\n"
    else
        parameterInvalid
        parameter_workspace
        archiveRun
    fi
}
archiveRun

# 输入打包模式
configurationRun () {
    echo "\033[36;1m请选择打包模式(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. Release \033[0m"
    echo "\033[33;1m2. Debug \033[0m"
    
    if [ ${#parameter_configuration} == 0 ]
    then
        #读取用户输入
        read parameter_configuration
        sleep 0.5
    fi

    if [ "$parameter_configuration" == "1" ];
    then
        parameter_configuration="Release"
    elif [ "$parameter_configuration" == "2" ];
    then
        parameter_configuration="Debug"
    else
        echo "\n\033[31;1m****************\n您输入的参数,无效请重新输入!!! \n****************\033[0m\n"
        parameter_configuration=""
        configurationRun
    fi
    
    echo "\n\033[32m****************\n打包模式：${parameter_configuration} \n****************\033[0m\n"
}
configurationRun


# 输入打包类型
methodRun () {
    # 输入打包类型
    echo "\033[36;1m请选择打包方式(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. AdHoc(预发) \033[0m"
    echo "\033[33;1m2. AppStore(发布) \033[0m"
    echo "\033[33;1m3. Enterprise(企业) \033[0m"
    echo "\033[33;1m4. Development(测试) \033[0m\n"
    
    if [ ${#parameter_type} == 0 ]
    then
        #读取用户输入
        read parameter_type
        sleep 0.5
    fi
      
    if [ "$parameter_type" == "1" ]; then
        parameter_type="AdHoc"
    elif [ "$parameter_type" == "2" ]; then
        parameter_type="AppStore"
    elif [ "$parameter_type" == "3" ]; then
        parameter_type="Enterprise"
    elif [ "$parameter_type" == "4" ]; then
        parameter_type="Development"
    else
        parameter_type=""
        methodRun
    fi
    
    echo "\033[32m****************\n您选择了 ${parameter_type} 打包类型\n****************\033[0m\n"
}
methodRun

#对应ExportOptions.plist的路径
export_options_path="${current_path}/${parameter_type}_ExportOptions.plist"

# 设置对应的ExportOptions.plist的teamID
if [ ${#teamID} != 0 ]
then
    /usr/libexec/PlistBuddy -c "Set :teamID $teamID" "$export_options_path"
else
    echo "\n\033[31;1m****************\n请配置teamID, 否则将无法上传!!! \n****************\033[0m\n"
fi

# 输入上传类型
publishRun () {
    # 输入打包类型
    echo "\033[36;1m请选择上传类型(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. 蒲公英 \033[0m"
    echo "\033[33;1m2. AppStore \033[0m"
    echo "\033[33;1m3. 不上传 \033[0m"
    
    if [ ${#parameter_upload} == 0 ]
    then
        #读取用户输入
        read parameter_upload
        sleep 0.5
    fi

    if [ "$parameter_upload" == "1" ]; then
        echo "\033[32m****************\n您选择了上传 蒲公英\n****************\033[0m\n"
    elif [ "$parameter_upload" == "2" ]; then
        echo "\033[32m****************\n您选择了上传 AppStore\n****************\033[0m\n"
    elif [ "$parameter_upload" == "3" ]; then
        echo "\033[32m****************\n您选择了不上传\n****************\033[0m\n"
    else
        echo "\n\033[31;1m**************** 您输入的参数,无效请重新输入!!! ****************\033[0m\n"
        parameter_upload=""
        publishRun
    fi
}
publishRun

# 输入是否上传bugly
buglyRun () {
    # 输入打包类型
    echo "\033[36;1m请选择是否上传bugly(输入序号, 按回车即可) \033[0m"
    echo "\033[33;1m1. 不上传 \033[0m"
    echo "\033[33;1m2. 上传 \033[0m"
    
    if [ ${#parameter_bugly} == 0 ]
    then
        #读取用户输入
        read parameter_bugly
        sleep 0.5
    fi

    if [ "$parameter_bugly" == "1" ]; then
        echo "\033[32m****************\n您选择了不上传 bugly\n****************\033[0m\n"
    elif [ "$parameter_bugly" == "2" ]; then
        echo "\033[32m****************\n您选择了上传 bugly\n****************\033[0m\n"
    else
        echo "\n\033[31;1m**************** 您输入的参数,无效请重新输入!!! ****************\033[0m\n"
        parameter_bugly=""
        buglyRun
    fi
}
buglyRun

echo "\n\033[32m****************\n打包信息配置完毕，开始进行打包\n****************\033[0m\n"
echo "\n\033[32m****************\n开始清理工程\n****************\033[0m\n"

#强制删除旧的文件夹
rm -rf $export_path_ipa

# 指定输出文件目录不存在则创建
if test -d "$export_path_ipa" ;
then
    echo $export_path_ipa
else
    mkdir -pv $export_path_ipa
fi

# 清理工程
xcodebuild clean -configuration "$parameter_configuration" -alltargets

echo "\n\033[32m****************\n清理工程完毕\n****************\033[0m\n"
echo "\n\033[32m****************\n开始编译项目\n****************\033[0m\n"

# 开始编译
if [ "$parameter_workspace" == "1" ]
then
    #工作空间
    xcodebuild archive \
    -workspace ${project_name}.xcworkspace \
    -scheme ${project_name} \
    -configuration ${parameter_configuration} \
    -archivePath ${export_path_archive} \
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios
else
    #不是工作空间
    xcodebuild archive \
    -project ${project_name}.xcodeproj \
    -scheme ${project_name} \
    -configuration ${parameter_configuration} \
    -archivePath ${export_path_archive}
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "$export_path_archive" ; then
    echo "\n\033[32m****************\n项目编译成功\n****************\033[0m\n"
else
    echo "\n\033[32m****************\n项目编译失败\n****************\033[0m\n"
    exit 1
fi

echo "\n\033[32m****************\n开始导出ipa文件\n****************\033[0m\n"

#1、打包命令
#2、归档文件地址
#3、ipa输出地址
#4、ipa打包plist文件地址
xcodebuild -exportArchive \
-archivePath ${export_path_archive} \
-configuration ${parameter_configuration} \
-exportPath ${export_path_ipa}  \
-exportOptionsPlist "${current_path}/${parameter_type}_ExportOptions.plist"

#app 名字
app_name=`find ${export_path_ipa} -name *.ipa | awk -F "[/.]" '{print $(NF-1)}'`

#app 版本号
bundle_version=`xcodebuild -showBuildSettings | grep MARKETING_VERSION | tr -d 'MARKETING_VERSION ='`

#指定输出ipa名称 : project_name + bundle_build_version
ipa_name="$app_name-V$bundle_version($bundle_build_version)"
#ipa最终路径
path_ipa=$export_path_ipa/$ipa_name.ipa

# 修改ipa文件名称
mv $export_path_ipa/$app_name.ipa $path_ipa

# 检查文件是否存在
if test -f "$path_ipa" ; then
    echo "\n\033[32m****************\n导出 $app_name.ipa 包成功\n****************\033[0m\n"
else
    echo "\n\033[32m****************\n导出 $app_name.ipa 包失败\n****************\033[0m\n"
    exit 1
fi

echo "\n\033[32m****************\n使用Shell脚本打包完毕\n****************\033[0m\n"

#上传 蒲公英
if [ "$parameter_upload" == "1" ]
then
    echo "\033[32m****************\n开始上传蒲公英\n****************\033[0m\n"

    curl -F "file=@$path_ipa" \
    -F "uKey=e5a9331a3fd25bc36646f831e4d42f2d" \
    -F "_api_key=ce1874dcf4523737c9c1d3eafd99164f" \
    https://upload.pgyer.com/apiv1/app/upload

    echo "\033[32m****************\n上传蒲公英完毕\n****************\033[0m\n"
fi


#上传 AppStore
if [ "$parameter_upload" == "2" ]
then
    #验证账号密码
    if [ ${#parameter_username} != 0 -a ${#parameter_password} != 0 ]
    then
        echo "\n\033[32m****************\n开始上传AppStore\n****************\033[0m\n"
        
        #验证APP
        xcrun altool --validate-app \
        -f "$path_ipa" \
        -t iOS \
        -u "$parameter_username" \
        -p "$parameter_password" \
        --output-format xml
        
        #上传APP
        xcrun altool --upload-app \
        -f "$path_ipa" \
        -t iOS \
        -u "$parameter_username" \
        -p "$parameter_password" \
        --output-format xml
        
        echo "\n\033[32m****************\n上传AppStore完毕\n****************\033[0m\n"
    fi
fi

#上传 Bugly
if [ "$parameter_bugly" == "2" ]
then
    echo "\033[32m****************\n开始上传bugly\n****************\033[0m\n"
    bugly_app_id="fc42b13a1b"
    bugly_app_key="b1fca7f9-29cf-4e64-ab1f-444391c25cfc"

    #dsym 路径
    dsymfile_path="${export_path_archive}/dSYMs/${app_name}.app.dSYM"

    zip_path="${export_path_ipa}"

    java -jar buglySymboliOS.jar \
    -i "${dsymfile_path}" \
    -u -id "${bugly_app_id}" \
    -key "${bugly_app_key}" \
    -version "${bundle_version}" \
    -o "${zip_path}"
    echo "\033[32m****************\n上传bugly完成\n****************\033[0m\n"
fi
