/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import HiLog from './HiLog';
import common from '../data/commonData';
import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import SharedPreferencesUtils from './SharedPreferencesUtils';
import MmsFileDeleteService from '../service/MmsFileDeleteService';
import FileUtil from './FileUtil';

const TAG = 'MMsFileDeleteUtil';

@Concurrent
export async function clearFilesForDataBaseDeleted(context: Context): Promise<void> {
  const TAG = 'MMsFileDeleteUtil';
  SharedPreferencesUtils.init(context);
  HiLog.i(TAG, 'clearFilesForDataBaseDeleted start.');
  // 1.从首选项中查询出是否有删除信息后资源文件还未清理完成的任务列表
  // 2.任务列表中每个任务作为key在首选项中查询出未清理完成的文件路径列表
  // 3.根据文件路径列表清除完成后，删除任务的key,在首选项中更新任务列表
  SharedPreferencesUtils.saveToPreferences(common.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, true);
  let taskArr = SharedPreferencesUtils.getFromPreferences(common.STR.DELETE_SANDBOX_FILES_TASK_LIST, []) as [];
  if (!taskArr || taskArr.length < 1) {
    HiLog.w(TAG, 'clearFilesForDataBaseDeleted taskStr is empty.');
    return;
  }
  for (let task of taskArr) {
    HiLog.w(TAG, `clearFilesForDataBaseDeleted taskName is:${task}`);
    await MmsFileDeleteService.getInstance().deleteBySubTask(task, context);
    // 删除完成后清除task,value值
    MmsFileDeleteService.getInstance().updateTaskList(task, false);
  }
  HiLog.i(TAG, 'clearFilesForDataBaseDeleted end.');
  SharedPreferencesUtils.saveToPreferences(common.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, false);
}


export default class MMsFileDeleteUtil {

  private static sInstance: MMsFileDeleteUtil;

  static getInstance() {
    if (MMsFileDeleteUtil.sInstance == null) {
      HiLog.i(TAG, 'getInstance');
      MMsFileDeleteUtil.sInstance = new MMsFileDeleteUtil();
    }
    return MMsFileDeleteUtil.sInstance;
  }

  public async delete(context: Context) {
    if (!context) {
      HiLog.e(TAG, 'delete context is invalid');
      return;
    }
    SharedPreferencesUtils.init(context);
    // 判断是否有已经在执行的任务
    let isDeleteTaskBeingExecuted: boolean =
    SharedPreferencesUtils.getFromPreferences(common.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, false) as boolean;
    if (isDeleteTaskBeingExecuted) {
      HiLog.w(TAG, 'delete isBeingExecuted');
      return;
    }
    SharedPreferencesUtils.saveToPreferences(common.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, true);
    let task: taskpool.LongTask = new taskpool.LongTask(clearFilesForDataBaseDeleted, context);
    taskpool.execute(task).then(() => {
      HiLog.w(TAG, 'delete end');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `delete fail, errCode:${error?.code}, errMsg:${error?.message}`);
    }).finally(() => {
      SharedPreferencesUtils.saveToPreferences(common.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, false);
    })
  }
}
