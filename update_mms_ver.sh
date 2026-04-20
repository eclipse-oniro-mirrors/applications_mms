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

# 更新智能信息har的版本号，根据不同的product，依赖不同的智能信息版本
# $1 渠道信息（product、mirror、beta）
# $2 默认版本号
# $3 流水线配置的动参版本号
function change_smart_mms_version() {
  echo "[change_smart_mms_version] params: $*"
  # 版本号后缀，可以修改为不同渠道的智能信息版本依赖
  ver_suffix=$1
  if [ "$ver_suffix" != "beta" -a "$ver_suffix" != "mirror" ]; then
    # 非beta、mirror的统一改为Product的版本号
    ver_suffix=''
  fi
  if [ -z "$3" ]; then
    version=$2
  else
    version=$3
  fi

  # 需要修改的文件
  fp="${PROJECT_PATH}/entry/oh-package.json5"

  old_data="\\\"@xx-smartmms\\/smartmms\\\": \\\"[^\"]*\\\""
  new_data="\\\"@xx-smartmms\\/smartmms\\\": \\\"${version}${ver_suffix}\\\""
  echo "[change_smart_mms_version] changed $old_data => $new_data"
  sed -i "s/${old_data}/${new_data}/" $fp
  replace_version=$(grep -oP '(?<=@xx-smartmms/smartmms": ")\d+\.\d+\.\d+-\d+[^\"]+' $fp)
  echo "[change_smart_mms_version] changed finished ver $replace_version"
}

change_smart_mms_version $*