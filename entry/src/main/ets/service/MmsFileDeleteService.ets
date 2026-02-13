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

import common from '../data/commonData';
import HiLog from '../utils//HiLog';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import FileUtils from '../utils/FileUtils';
import MmsPartModel from '../model/MmsPartModel';

const TAG: string = 'MmsFileDeleteService';
const DELETE_FILE_CHUNK_NUM: number = 50;
const SAVE_DELETE_FILE_CHUNK_NUM: number = 200;

export default class MmsFileDeleteService {

  private static instance: MmsFileDeleteService;
  private mmsPartModel: MmsPartModel = new MmsPartModel();

  public static getInstance(): MmsFileDeleteService {
    if (MmsFileDeleteService.instance == null) {
      MmsFileDeleteService.instance = new MmsFileDeleteService();
    }
    return MmsFileDeleteService.instance;
  }

  /**
   * 执行清除沙箱文件子任务
   *
   * @param task 子任务名称
   * @param context 上下文
   * @returns void
   */
  public async deleteBySubTask(task: string, context: Context): Promise<void> {
    HiLog.i(TAG, `deleteBySubTask start, taskName:${task}`);
    let pathArr = SharedPreferencesUtils.getFromPreferences(task, []) as [];
    if (!pathArr || pathArr.length < 1) {
      HiLog.w(TAG, 'deleteBySubTask pathStr is empty.');
      return;
    }
    HiLog.w(TAG, `deleteBySubTask pathArr.length is:${pathArr.length}`);
    let pathChunk: string[][] = [];
    for (let i = 0; i < pathArr.length; i += DELETE_FILE_CHUNK_NUM) {
      pathChunk.push(pathArr.slice(i, i + DELETE_FILE_CHUNK_NUM));
    }
    for (let paths of pathChunk) {
      HiLog.w(TAG, 'deleteBySubTask paths.length is:' + JSON.stringify(paths.length));
      FileUtils.deleteListFileAfterDataBaseDelete(context, paths);
      this.updateSubTaskPaths(task, paths);
    }
  }

  /**
   * 删除会话、详情、30天自动删除等后执行清除沙箱文件
   *
   * @param task 子任务名称
   * @param context 上下文
   * @returns void
   */
  public async clearByAfterDataBaseDelete(filePathList: string[], context: Context): Promise<void> {
    HiLog.i(TAG, `clearByAfterDataBaseDelete param filePathList.length is: ${filePathList?.length}` );
    if (!context || filePathList?.length === 0) {
      HiLog.e(TAG, 'clearByAfterDataBaseDelete param is invalid.');
      return;
    }
    SharedPreferencesUtils.init(context);
    // 设置自动清理任务的sp值为false.可以在下次打开短信触发清理参与未清理完成的资源文件
    SharedPreferencesUtils.saveToPreferences(common.STR.IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED, false);
    const taskSpName = common.STR.DELETE_SANDBOX_FILES_SUB_TASK_PREFIX + Date.now() + '_';
    let pathChunk: string[][] = [];
    for (let i = 0; i < filePathList.length; i += SAVE_DELETE_FILE_CHUNK_NUM) {
      pathChunk.push(filePathList.slice(i, i + SAVE_DELETE_FILE_CHUNK_NUM));
    }
    // mms_part表中删除消息后依然存在的路径
    let pathStillExists: string[] = [];
    // 最终需要删除的资源文件路径
    let deleteItems: string[] = [];
    // 分批加入删除任务、删除子任务
    for (let i = 0; i < pathChunk.length; i++) {
      deleteItems = pathChunk[i];
      // 删除资源文件前需要过滤下mms_part表中是否此文件路径是否依然被其他消息使用的资源文件
      // RCS转发、分享等逻辑可能存在两条消息公用一处资源
      pathStillExists = await this.mmsPartModel.queryMmsPartPathByPaths(pathChunk[i],context);
      if (pathStillExists.length > 0) {
        deleteItems = deleteItems.filter((deletePath) => {
          return !pathStillExists.includes(deletePath);
        });
      }
      SharedPreferencesUtils.saveToPreferences(taskSpName + i, deleteItems);
      MmsFileDeleteService.getInstance().updateTaskList(taskSpName + i, true);
    }
    // 分批执行删除子任务
    for (let i = 0; i < pathChunk.length; i++) {
      MmsFileDeleteService.getInstance().deleteBySubTask(taskSpName + i, context);
    }
  }

  /**
   * 清除沙箱文件子任务删除一批文件后更新首选项
   *
   * @param task 清除沙箱文件子任务名
   * @param deletePaths 已清除的文件路径数组
   */
  public updateSubTaskPaths(task: string, deletePaths: string[]) {
    let pathArr = SharedPreferencesUtils.getFromPreferences(task, []) as [];
    if (!pathArr || pathArr.length < 1) {
      HiLog.w(TAG, 'updateSubTaskPaths pathStr is empty.');
      return;
    }
    let newItemArr: string[] = [];
    for (let pathArrElement of pathArr) {
      if (!deletePaths.includes(pathArrElement)) {
        newItemArr.push(pathArrElement);
      }
    }
    HiLog.w(TAG, `updateSubTaskPaths newPathArr.length is: ${newItemArr.length}`);
    if (newItemArr.length === 0) {
      SharedPreferencesUtils.deletePreferences(task);
    } else {
      SharedPreferencesUtils.saveToPreferences(task, newItemArr);
    }
  }

  /**
   * 更新清除沙箱文件任务首选项
   *
   * @param task 更新沙箱文件子任务名
   * @param isAdd 是否增加子任务 true-增加，false-删除
   */
  public updateTaskList(taskName: string, isAdd: boolean) {
    HiLog.w(TAG, `updateTaskList taskName is:${taskName}, isAdd: ${isAdd}`);
    let taskArr: string[] =
      SharedPreferencesUtils.getFromPreferences(common.STR.DELETE_SANDBOX_FILES_TASK_LIST, []) as [];
    if (!taskArr) {
      HiLog.w(TAG, 'updateTaskList taskStr is empty.');
      return;
    }
    // 删除子任务时首选项中为空
    if (!isAdd && taskArr.length < 1) {
      HiLog.w(TAG, 'updateTaskList taskArr is empty.');
      return;
    }
    HiLog.w(TAG, `updateTaskList taskArr.length is: ${taskArr?.length}`);
    let newTaskArr: string[] = [];
    if (isAdd) {
      taskArr.push(taskName);
      newTaskArr = taskArr;
    } else {
      newTaskArr = taskArr.filter(item => item !== taskName);
    }
    SharedPreferencesUtils.saveToPreferences(common.STR.DELETE_SANDBOX_FILES_TASK_LIST, newTaskArr);
    HiLog.w(TAG, `updateTaskList newTaskArr.length is: ${newTaskArr?.length}`);
  }
}