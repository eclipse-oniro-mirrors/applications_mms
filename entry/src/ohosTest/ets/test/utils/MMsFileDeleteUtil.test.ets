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
import { describe, it, expect } from '@ohos/hypium';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import HiLog from '../../../../main/ets/utils/HiLog';
import MMsFileDeleteUtil, { clearFilesForDataBaseDeleted } from '../../../../main/ets/utils/MMsFileDeleteUtil';
import { DTGlobalContext } from '../../testability/TestAbility';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import commonData from '../../../../main/ets/data/commonData';
import FileUtil from '../../../../main/ets/utils/FileUtil';
import MmsFileDeleteService from '../../../../main/ets/service/MmsFileDeleteService';

export default function MMsFileDeleteUtilTest() {
  const TAG = 'MMsFileDeleteUtilTest';
  describe('MMsFileDeleteUtilTest', () => {

    it('MMsFileDeleteUtilTest_delete', 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      GlobalContext.getContext().setObject("mmsContext", context);
      SharedPreferencesUtils.init(context);
      let taskArrs:string[] = [];
      for (let i = 1; i < 6; i++) {
        taskArrs.push('task' + i);
      }
      SharedPreferencesUtils.saveToPreferences(commonData.STR.DELETE_SANDBOX_FILES_TASK_LIST, taskArrs);
      let pathArr:string[] = [];
      for (let i = 1; i < 59; i++) {
        pathArr.push(FileUtil.getSandboxPath(context) + 'task' + i);
      }
      SharedPreferencesUtils.saveToPreferences('task1', pathArr);
      SharedPreferencesUtils.saveToPreferences('task2', pathArr);
      SharedPreferencesUtils.saveToPreferences('task3', pathArr);
      SharedPreferencesUtils.saveToPreferences('task4', pathArr);
      SharedPreferencesUtils.saveToPreferences('task5', pathArr);
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start110.' +
      (SharedPreferencesUtils.getFromPreferences(commonData.STR.DELETE_SANDBOX_FILES_TASK_LIST, []) as []).toString())
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start111.' +
      (SharedPreferencesUtils.getFromPreferences('task1', []) as []).toString())
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start112.' +
      (SharedPreferencesUtils.getFromPreferences('task2', []) as []).toString())
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start113.' +
      (SharedPreferencesUtils.getFromPreferences('task3', []) as []).toString())
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start114.' +
      (SharedPreferencesUtils.getFromPreferences('task4', []) as []).toString())
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start115.' +
      (SharedPreferencesUtils.getFromPreferences('task5', []) as []).toString())
      let result: number = 0;
      try {
        MMsFileDeleteUtil.getInstance().delete(context);
      } catch (err) {
        result = 1;
        HiLog.i(TAG, 'MMsFileDeleteUtilTest_delete error.')
      }
      expect(result).assertEqual(0);
    })

    it('MMsFileDeleteUtilTest_deleteTaskPool', 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      GlobalContext.getContext().setObject("mmsContext", context);
      SharedPreferencesUtils.init(context);
      let taskArrs:string[] = [];
      for (let i = 1; i < 6; i++) {
        taskArrs.push('task' + i);
      }
      SharedPreferencesUtils.saveToPreferences(commonData.STR.DELETE_SANDBOX_FILES_TASK_LIST, taskArrs);
      let pathArr:string[] = [];
      for (let i = 1; i < 59; i++) {
        pathArr.push(FileUtil.getSandboxPath(context) + 'task' + i);
      }
      SharedPreferencesUtils.saveToPreferences('task1', pathArr);
      SharedPreferencesUtils.saveToPreferences('task2', pathArr);
      SharedPreferencesUtils.saveToPreferences('task3', pathArr);
      SharedPreferencesUtils.saveToPreferences('task4', pathArr);
      SharedPreferencesUtils.saveToPreferences('task5', pathArr);
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start110.' +
      (SharedPreferencesUtils.getFromPreferences(commonData.STR.DELETE_SANDBOX_FILES_TASK_LIST, []) as []).toString());
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start111.' +
      (SharedPreferencesUtils.getFromPreferences('task1', []) as []).toString());
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start112.' +
      (SharedPreferencesUtils.getFromPreferences('task2', []) as []).toString());
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start113.' +
      (SharedPreferencesUtils.getFromPreferences('task3', []) as []).toString());
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start114.' +
      (SharedPreferencesUtils.getFromPreferences('task4', []) as []).toString());
      HiLog.i(TAG, 'clearFilesForDataBaseDeleted start115.' +
      (SharedPreferencesUtils.getFromPreferences('task5', []) as []).toString());
      let result: number = 0;
      try {
        SharedPreferencesUtils.saveToPreferences(commonData.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, true);
        let taskArr =
          SharedPreferencesUtils.getFromPreferences(commonData.STR.DELETE_SANDBOX_FILES_TASK_LIST, []) as [];
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
        SharedPreferencesUtils.saveToPreferences(commonData.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, false);
      } catch (err) {
        result = 1;
        HiLog.i(TAG, 'MMsFileDeleteUtilTest_delete error.')
      }
      expect(result).assertEqual(0);
    })

    it('MMsFileDeleteUtilTest_clearByAfterDataBaseDelete', 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      GlobalContext.getContext().setObject("mmsContext", context);
      SharedPreferencesUtils.init(context);
      let pathArr:string[] = [];
      for (let i = 1; i < 208; i++) {
        pathArr.push(FileUtil.getSandboxPath(context) + '/task' + i);
      }
      pathArr.push(FileUtil.getSandboxPath(context) + '/192787654_0/task1');
      pathArr.push(FileUtil.getSandboxPath(context) + '/192787654_0/task2');
      pathArr.push(FileUtil.getSandboxPath(context) + '/192787654_0/task3');
      pathArr.push(FileUtil.getSandboxPath(context) + '/11.mp4');
      pathArr.push(FileUtil.getSandboxPath(context) + '/11.3gp');
      pathArr.push(FileUtil.getSandboxPath(context) + '/IMG_11.jpeg');
      pathArr.push(FileUtil.getSandboxPath(context) + '/IMG_11.jpeg');
      let result: number = 0;
      try {
        MmsFileDeleteService.getInstance().clearByAfterDataBaseDelete(pathArr, context);
      } catch (err) {
        result = 1;
        HiLog.i(TAG, 'MMsFileDeleteUtilTest_delete error.')
      }
      expect(result).assertEqual(0);
    })
  })
}
