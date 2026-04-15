#!/bin/bash
# Copyright (c) 2024 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
#limitations under the License
set -ex

echo "old NODE_HOME is ${NODE_HOME}"

# NODE_HOME的环境变量多配置了一个bin目录, 在这里去除掉
[[ "${NODE_HOME}" =~ .*\bin$ ]] && NODE_HOME=${NODE_HOME%\bin*}
echo "new NODE_HOME is ${NODE_HOME}"
echo "HM_SDK_HOME is ${HM_SDK_HOME}"
echo "OHOS_SDK_HOME is ${OHOS_SDK_HOME}"
echo "OHOS_BASE_SDK_HOME is ${OHOS_BASE_SDK_HOME}"
node -v
npm -v

# 签名工具路径
export SIGNTOOL_PATH=$(dirname "$(pwd)")/vendor/xxx/binary/artifacts/publickeyinfrastructure/sign_tool

# 初始化相关路径
PROJECT_PATH="$(pwd -P)"  # 工程目录
TOOLS_INSTALL_DIR="$(pwd -P)"  # commandline-tools安装目录，流水线下载命令行工具的安装路径

# 因CMC上的sdk无XXX-XX-DB1这一层目录，临时方案手动添加目录
# cd ${HM_SDK_HOME}
# DIR="XXX-XX-DB1"
# if [ ! -d "$DIR" ]; then
    # mkdir -p "$DIR"
    # mv base/ XXX/ sdk-pkg.json $DIR
# fi

# Setup npm
npm config set registry
npm config set @ohos:registry
npm config set strict-ssl false
#npm config set sslVerify false

# 使用grep查找包含智能信息版本号的行，并提取版本号，用于后面版本号的恢复
smart_mms_version=$(grep -oP '(?<=@xx-smartmms/smartmms": ")\d+\.\d+\.\d+-\d+' "${PROJECT_PATH}/entry/oh-package.json5")
# 提取原始的client_id
old_client_id=$(sed -n '/client_id/{n;p;}' "${PROJECT_PATH}/entry/src/main/module.json5" | sed 's/^.*: \"\(.*\)\".*/\1/')
# 使用grep查找包含短信hap包版本号的行，并提取版本号，用于后面版本号的恢复
mms_version=$(grep -oP '(?<=versionName": ")\d+\.\d+\.\d+\.\d+' "${PROJECT_PATH}/AppScope/app.json5")
# 提取到的版本号、clientId等信息
echo "extracted smart mms version: $smart_mms_version old_client_id: ${old_client_id} mms_version ${mms_version}"
# 安装ohpm, 若镜像中已存在ohpm，则无需重新安装
function init_ohpm() {
    # 配置仓库地址
    ohpm config set registry
    ohpm config set ///:_read_auth "Basic b2hwbV9kb3dubG9hZDppRk5aI3lEZjdOek15TUNzaUZvR3VkWkExQkNFR1g="
    ohpm config set strict_ssl false
    ohpm config set auto_generate_custom_dependency_file true
}

function ohpm_install() {
    cd  $1
    ohpm install
}

# 环境适配
function build() {
  # 从SDK拷贝签名jar包
    cp $HM_SDK_HOME/default/openharmony/toolchains/lib/hap-sign-tool.jar sign/hap-sign-tool.jar

    # 根据业务情况适配local.properties
    cd ${PROJECT_PATH}
    echo "sdk.dir=${HM_SDK_HOME}"  > ./local.properties
    echo "nodejs.dir=${NODE_HOME}" >> ./local.properties

    # 安装依赖前根据流水线参数修改智能信息的依赖版本号，以便出不同环境的智能信息版本；并且可以通过流水线修改依赖的版本，可以先不依赖合入短信转测
    ./update_mms_ver.sh ${SMART_MMS_FLAVOR:-"product"} $smart_mms_version $SMART_MMS_VERSION
    # 打包前将client_id切换为流水线构建参数值，未传值不会修改
    ./update_client_id.sh ${old_client_id} ${NEW_CLIENT_ID}
    # 打包前将短信版本号切换为流水线构建参数值，未传值不会修改
    ./update_hap_version.sh ${mms_version} ${MMS_VERSION}

	# 根据业务情况安装ohpm三方库依赖,
    ohpm_install "${PROJECT_PATH}"
  	ohpm_install "${PROJECT_PATH}/entry"

   # 如果构建过程报错 ERR_PNPM_OUTDATED_LOCKFILE，需要增加配置：lockfile=false
    cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc

    cd $PROJECT_PATH/sign
    chmod +x build.sh
    ./build.sh

    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${PROJECT_PATH}
    # chmod +x hvigorw
    hvigorw clean --no-daemon
    hvigorw assembleHap --mode module -p product=default -p debuggable=false -p ohos-test-coverage=true --no-daemon
    hvigorw --mode module -p module=entry@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon --stacktrace
    # hvigorw assembleHap --mode module -p product=default -p debuggable=false -p buildMode=release

    echo "-----------------handle DTPipeline.zip--------------------"
    has_package_dt_pipeline=0
    if [ -e "build/DTPipeline.zip" ];then
      file_size=$(stat -c%s "build/DTPipeline.zip")
      if [ $file_size -gt 0 ]; then
        echo "DTPipeline.zip is normal"
      else
        has_package_dt_pipeline=1
        rm -rf build/DTPipeline.zip
        echo "DTPipeline.zip size is 0"
      fi
    else
      has_package_dt_pipeline=1
      echo "build/DTPipeline.zip is not exist"
    fi
    if [ $has_package_dt_pipeline -eq 1 ];then
      pushd build/outputs
      if [ $? -ne 0 ];then
             echo "build/outputs is not exist"
             exit 1
      fi
      zip -r ../DTPipeline.zip ./*
      popd
    fi
    hvigorw assembleHap --mode module -p product=default -p debuggable=false -p ohos-test-coverage=false --no-daemon -p buildMode=release
    cp entry/build/default/outputs/default/entry-default-signed.hap entry/build/default/outputs/default/Mms.hap

    # 打包完将智能信息版本改回正式商用版本
    ./update_mms_ver.sh 'product' ${smart_mms_version}
    # 打包完将client_id还原
    ./update_client_id.sh ${NEW_CLIENT_ID} ${old_client_id}
    # 打包完将hap包版本号还原
    ./update_hap_version.sh ${MMS_VERSION} ${mms_version}
}

function main() {
  local start_time=$(date '+%s')
  init_ohpm
  build

  local end_time=$(date '+%s')
  local elapsed_time=$(expr $end_time - $start_time)
  echo "build success in ${elapsed_time}s..."
}

main