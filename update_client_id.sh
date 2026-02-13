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

# 更新client_id，对接不同的agc环境，方便测试业务功能
# $1 old_client_id
# $2 new_client_id
function change_client_id() {
  echo "[change_client_id] params: $*"
  if [ -z "$2" ]; then
    echo "[change_client_id] params invalid."
    return
  fi
  old_client_id=$1
  new_client_id=$2

  # 需要修改的文件
  fp="${PROJECT_PATH}/entry/src/main/module.json5"

  old_data="\\\"value\\\": \\\"${old_client_id}\\\""
  new_data="\\\"value\\\": \\\"${new_client_id}\\\""
  echo "[change_client_id] changed $old_data => $new_data"
  sed -i "s/${old_data}/${new_data}/" $fp
  # 打印修改后的数据
  new_value=$(sed -n '/client_id/{n;p;}' $fp | sed 's/^.*: \"\(.*\)\".*/\1/')
  echo "[change_client_id] changed finished new value: ${new_value}"
}

change_client_id $*