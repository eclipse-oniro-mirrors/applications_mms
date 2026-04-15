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
set -e
PROJECT_PATH="$(pwd -P)"  # 工程目录

# 将版本名转换为版本号
# $1 version_name 版本名
# return version_code 版本号
function change_version_name_to_code() {
  # 使用IFS（内部字段分隔符）设置为点号，然后读取所有部分到数组中
  IFS='.' read -r -a array <<< "$1"
  version_code=$(printf "%d%02d%02d%04d" $(expr ${array[0]}) $(expr ${array[1]}) $(expr ${array[2]}) $(expr ${array[3]}))
  echo $version_code
}

# 更新client_id，对接不同的agc环境，方便测试业务功能
# $1 old_version_name
# $2 new_version_name
function change_hap_version() {
  echo "[change_hap_version] params: $*"
  if [ -z "$2" ]; then
    echo "[change_hap_version] params invalid."
    return
  fi
  old_version_name=$1
  new_version_name=$2

  # 需要修改的文件
  fp="${PROJECT_PATH}/AppScope/app.json5"

  old_data="\\\"versionName\\\": \\\"${old_version_name}\\\""
  new_data="\\\"versionName\\\": \\\"${new_version_name}\\\""
  echo "[change_hap_version] changed versionName $old_data => $new_data"
  sed -i "s/${old_data}/${new_data}/" $fp
  new_ver_name=$(grep -oP '(?<=versionName": ")\d+\.\d+\.\d+\.\d+' $fp)

  old_version_code=$(change_version_name_to_code $old_version_name)
  new_version_code=$(change_version_name_to_code $new_version_name)
  old_data="\\\"versionCode\\\": ${old_version_code}"
  new_data="\\\"versionCode\\\": ${new_version_code}"
  echo "[change_hap_version] changed versionCode $old_data => $new_data"
  sed -i "s/${old_data}/${new_data}/" $fp
  new_ver_code=$(grep -oP '(?<=versionCode": )\d+' $fp)

  # 打印修改后的数据
  echo "[change_hap_version] changed finished new_ver_name: ${new_ver_name} new_ver_code: ${new_ver_code}"
}

change_hap_version $*