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
import ConversationController, { mmsListType } from '../conversation/conversationController';
import LooseObject from '../../data/LooseObject';
import SlideListDataSource from '../../model/SlidePreviewListDataSource';
import ConListController from '../conversationlist/conversationListController';
import { messageType } from '../conversationlist/conversationListController';
import common from '../../data/commonData';
import HiLog from '../../utils/HiLog';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import { SlideMmsItem } from '../../utils/TypesUtils';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import prompt from '@ohos.promptAction';
import { AsyncCallback, BusinessError } from '@ohos.base';
import ConversationListService from '../../service/ConversationListService';
import DataShareHelper from '../../model/repository/DataShareHelper';
import StringUtil from '../../utils/StringUtil';
import commonData from '../../data/commonData';
import MmsUtil, { getMapInputBoxText } from '../../utils/MmsUtil';
import FavoriteController from '../../pages/favoritepage/favoriteController'

const TAG = 'SlidePreviewController';
const PART_CT = '10000';

export default class SlidePreviewController {
  private static sInstance: SlidePreviewController;
  public slideDataSource: SlideListDataSource = new SlideListDataSource();
  public mConversationController: ConversationController = ConversationController.getInstance();
  public mFavoriteCtrl: FavoriteController = FavoriteController.getInstance();
  public conListCtrl: ConListController = this.mConversationController.conListCtrl;
  public slideList: Array<SlideMmsItem> = [];
  public mmsItem: mmsListType | Object = {};
  public favoriteItem: LooseObject = {};
  // Select Status
  public isSelectStatus: boolean = false;
  public pageInfos: NavPathStack = new NavPathStack();
  // Selected Save Count
  public selectSaveCount: number = 0;
  // Index of the selected information
  public mmsIndex: number = 0;
  // Text entered in the text box, which is also the content of the SMS message to be sent.
  public attachTotalCount: number = 0;
  public totalCount: number = 0;
  // Indicates whether the attach list is selected.
  public isAttachCheckAll: boolean = false;
  // ID of the session list.
  public threadId: number = 0;
  public isCheckAll: boolean = false;
  public isShowSaveAllBtn: boolean = false;
  public msgTitle: string = '';
  public attachIsNotEmpty: boolean = true;

  static getTestInstance() {
    return new SlidePreviewController();
  }

  async getSlidePreviewData() {
    this.slideDataSource.refresh(this.slideList);
    this.totalCount = this.slideDataSource.totalCount();
  }

  /**
   * 处理彩信位置附件的初始化逻辑
   */
  private initMmsMapAttachment = () => {
    if (!this.slideList || this.slideList.length === 0) {
      return;
    }
    try {
      for (let i = 0; i < this.slideList.length; i++) {
        if (this.slideList[i] && this.slideList[i].type === commonData.MM_ATTACHMENT_TYPE.MAP) {
          this.slideList[i].inputBoxTextOfMmsMap = getMapInputBoxText(this.slideList[i].content);
        }
      }
    } catch (e) {
      HiLog.e(TAG, `initMmsMapAttachment error: ${e?.code} ${e?.message}`);
    }
  }

  onInit(pageInfos: NavPathStack) {
    this.pageInfos = pageInfos;
    this.initRouterData();
    this.initMmsMapAttachment();
    this.resetPageData();
  }

  initRouterData() {
    HiLog.i(TAG, 'initRouterData')
    let routerParams: LooseObject = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject;
    this.slideList =
      StringUtil.isEmpty(routerParams.slideDataList) ? [] : routerParams.slideDataList as Array<SlideMmsItem>;
    this.mmsItem = StringUtil.isEmpty(routerParams.mmsItem) ? '' : routerParams.mmsItem;
    this.favoriteItem = StringUtil.isEmpty(routerParams.favoriteItem) ? '' : routerParams.favoriteItem;
    this.threadId = StringUtil.isEmpty(routerParams.threadId) ? 0 : routerParams.threadId;
    this.mmsIndex = StringUtil.isEmpty(routerParams.mmsIndex) ? 0 : routerParams.mmsIndex;
    if (this.slideList?.length) {
      this.attachTotalCount = this.slideList.filter(item => MmsUtil.isSlideAttach(item.type)).length;
      this.attachIsNotEmpty = !this.slideList.find(item => item.ct === PART_CT);
      HiLog.i(TAG, `attachIsNotEmpty is ${this.attachIsNotEmpty}`);
    }
  }

  resetPageData() {
    this.resetSelectStatus();
    this.cancelCheckedAll();
    this.slideDataSource.refresh(this.slideList);
    this.isShowSaveAllBtn = this.slideList.some(item => MmsUtil.isSlideAttach(item.type));
    const mmsItem: mmsListType = this.mmsItem as mmsListType;
    this.msgTitle = mmsItem.msgTitle || '';
  }

  getFirstItem(): SlideMmsItem {
    return this.slideList?.length ? this.slideList[0] : {
      duration: '',
      type: 0,
      path: '',
      name: ''
    };
  }

  clickCheckAllBtn() {
    // Select All/Deselect All
    if (this.isAttachCheckAll) {
      this.isAttachCheckAll = false;
      for (let element of this.slideList) {
        element.isCbChecked = false;
      }
      this.setAttachCheckAll(common.int.CHECKBOX_SELECT_NONE);
    } else {
      this.isAttachCheckAll = true;
      for (let element of this.slideList) {
        if (MmsUtil.isSlideAttach(element.type)) {
          element.isCbChecked = true;
        }
      }
      this.setAttachCheckAll(common.int.CHECKBOX_SELECT_ALL);
    }
    this.slideDataSource.notifyDataReload();
  }

  onBackPress() {
    if (this.isSelectStatus) {
      // Multi-choice status
      this.resetPageData();
      return true;
    }
    if (!this.pageInfos) {
      HiLog.i(TAG, 'this.pageInfos is null');
      return false;
    }
    return false;
  }

  /**
   * Query session by SessionId
   *
   * @param sessionId
   * @returns
   */
  private async querySessionBySessionId(sessionId: number) {
    HiLog.i(TAG, 'query session by sessionId.');
    return new Promise<messageType>((resolve) => {
      // Query session table by ID
      ConversationListService.getInstance().getSessionListResultNew({
        threadId: sessionId
      }, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).then((data) => {
        // Verify callback data -- resType?
        if (data) {
          let session: messageType | undefined = (data.response as messageType[]).find((item) => {
            return item.threadId === sessionId;
          })
          if (session) {
            HiLog.i(TAG, 'query session by sessionId success.');
            // Callback data available
            resolve(session);
          } else {
            HiLog.w(TAG, 'invalid session id: ' + sessionId);
          }
        }
      });
    });
  }

  async deleteDialogConfirm(context: Context) {
    HiLog.i(TAG, 'deleteDialogConfirm start.');
    if (this.favoriteItem) {
      this.mFavoriteCtrl.cancelFavorite(context, this.favoriteItem);
      this.conListCtrl.jumpToFavoritesPage();
    } else {
      this.mConversationController.mmsListLongPress(this.mmsIndex);
      this.mConversationController.deleteDialogConfirm(context);
      if (this.mConversationController.mmsList.length > 0) {
        let session: messageType = await this.querySessionBySessionId(this.threadId);
        this.conListCtrl.jumpToConversationPage(session);
      }
    }
  }

  listCheckBoxChange(index: number, isChecked: boolean) {
    let item: SlideMmsItem = this.slideList[index];
    item.isCbChecked = isChecked;
    this.setSelectStatus(true);
    this.setAttachCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    this.slideDataSource.refresh(this.slideList);
  }

  resetSelectStatus() {
    this.setSelectStatus(false);
    this.selectSaveCount = 0;
  }

  setSelectStatus(isSelect: boolean) {
    this.isSelectStatus = isSelect;
  }

  cancelCheckedAll() {
    this.isAttachCheckAll = false;
    for (let element of this.slideList) {
      element.isCbChecked = false;
    }
    this.slideDataSource.refresh(this.slideList)
  }

  setAttachCheckAll(type: number) {
    if (!this.isSelectStatus) {
      return;
    }
    if (type == common.int.CHECKBOX_SELECT_ALL) {
      this.selectSaveCount = this.attachTotalCount;
      this.isAttachCheckAll = true;

    } else if (type == common.int.CHECKBOX_SELECT_NONE) {
      this.selectSaveCount = common.int.MESSAGE_CODE_ZERO;
      this.isAttachCheckAll = false;
    } else {
      this.checkBoxSelectSingle();
    }
  }

  checkBoxSelectSingle() {
    HiLog.i(TAG, 'checkBoxSelectSingle, start');
    this.selectSaveCount = this.slideList.filter(item =>!!item.isCbChecked)?.length;
    this.isAttachCheckAll = this.selectSaveCount === this.attachTotalCount;
  }

  transmitMsg(context: Context) {
    if (this.favoriteItem) {
      this.mFavoriteCtrl.transmitMsg(this.mmsIndex);
    } else {
      this.mConversationController.transmitMsg(context, this.mmsIndex);
    }
  }

  async saveImageToPhotoAlbums(sandBoxPath: string, isMultiSave?: boolean): Promise<string> {
    return new Promise(async (resolve, reject) => {
      HiLog.i(TAG, 'saveImagePhotoAlbums');
      let context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
      let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
      let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
      try {
        //get fileSandbox.fd
        let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
        let size = fs.statSync(fileSandbox.fd).size;
        let fileSandboxBuffer = new ArrayBuffer(size);
        fs.readSync(fileSandbox.fd, fileSandboxBuffer);
        //write to albums
        let uri = await phAccessHelper.createAsset(photoAccessHelper.default.PhotoType.IMAGE, 'jpg');
        let file = await fs.open(uri, fs.OpenMode.READ_WRITE);
        await fs.write(file.fd, fileSandboxBuffer);
        await fs.close(fileSandbox.fd);
        await fs.close(file.fd);
        resolve(sandBoxPath);
        if (!isMultiSave) {
          prompt.showToast({
            message: $r('app.string.Saved_to_album'), duration: 200
          });
        }
        HiLog.i(TAG, 'saveImagePhotoAlbums end---');
      } catch (err) {
        let error = err as BusinessError;
        HiLog.i(TAG, `saveImageToPhotoAlbums: ${error}`);
        reject(err);
      }
    })

  }

  async saveVideoToAlbums(sandBoxPath: string, isMultiSave?: boolean): Promise<string> {
    return new Promise(async (resolve, reject) => {
      HiLog.i(TAG, 'saveVideoAlbums');
      let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
      let context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
      let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
      try {
        //get fileSandbox.fd
        let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
        let size = fs.statSync(fileSandbox.fd).size;
        let fileSandboxBuffer = new ArrayBuffer(size);
        fs.readSync(fileSandbox.fd, fileSandboxBuffer);
        //write to albums
        let uri = await phAccessHelper.createAsset(photoAccessHelper.default.PhotoType.VIDEO, 'mp4');
        let fileAlbums = await fs.open(uri, fs.OpenMode.READ_WRITE);
        try {
          await fs.write(fileAlbums.fd, fileSandboxBuffer);
        } catch (err) {
          HiLog.e(TAG, `fs.write:${err}`);
        }
        await fs.close(fileSandbox);
        await fs.close(fileAlbums);
        resolve(sandBoxPath);
        if (!isMultiSave) {
          prompt.showToast({
            message: $r('app.string.Saved_to_album'), duration: 200
          });
        }
        HiLog.i(TAG, `uri:${uri}`)

      } catch (err) {
        let error = err as BusinessError
        HiLog.e(TAG, `saveVideoToAlbums: ${error}`);
        reject(error)
      }
    })

  }

  async saveAudioToFileManager(sandBoxPath: string, fileName: string, isMultiSave?: boolean): Promise<string> {
    return new Promise(async (resolve, reject) => {
      let uri: string = '';
      // 创建文件管理器选项实例
      const audioSaveOptions = new picker.AudioSaveOptions();
      // 保存文件名（可选）
      audioSaveOptions.newFileNames = [fileName];
      // 请确保 getContext(this) 返回结果为 UIAbilityContext
      let context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
      const audioViewPicker = new picker.AudioViewPicker(context);
      try {
        //get fileSandbox.fd
        let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
        let size = fs.statSync(fileSandbox.fd).size;
        let fileSandboxBuffer = new ArrayBuffer(size);
        fs.readSync(fileSandbox.fd, fileSandboxBuffer);
        //write to fileManager
        let audioSelectResult: string[] = await audioViewPicker.save(audioSaveOptions);
        if (audioSelectResult?.length) {
          uri = audioSelectResult[0];
        }
        let fileManager = fs.openSync(uri, fs.OpenMode.READ_WRITE);
        try {
          await fs.writeSync(fileManager.fd, fileSandboxBuffer);
        } catch (err) {
          HiLog.e(TAG, `saveAudioToFileManager fs.write:${err}`);
        }
        await fs.close(fileSandbox);
        await fs.close(fileManager);
        resolve(sandBoxPath);
        if (!isMultiSave) {
          let showUri = uri.substring(0, uri.lastIndexOf('/'));
          prompt.showToast({
            message: $r('app.string.Saved_to_folders', showUri), duration: 200
          });
        }
        HiLog.i(TAG, `saveAudioToFileManager uri:${uri}`)
      } catch (err) {
        let error = err as BusinessError
        HiLog.e(TAG, `saveAudioToFileManager: ${error}`);
        reject(error)
      }
    })
  }

  async clickSaveAllBtn() {
    if (!this.isSelectStatus) {
      this.setSelectStatus(true);
    } else {
      // real to save
      const selectAttachPromises: Promise<string>[] =
        this.slideList.filter(item =>!!item.isCbChecked).map(element => {
          if (element.type === commonData.MM_ATTACHMENT_TYPE.IMAGE ||
            element.type === commonData.MM_ATTACHMENT_TYPE.MAP) {
            return this.saveImageToPhotoAlbums(element.path, true);
          } else if (element.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
            return this.saveVideoToAlbums(element.path, true);
          } else if (element.type === commonData.MM_ATTACHMENT_TYPE.AUDIO) {
            return this.saveAudioToFileManager(element.path, element.name, true);
          }
          return this.saveAudioToFileManager(element.path, element.name, true);
        });
      Promise.all(selectAttachPromises)
        .then((result) => {
          if (result) {
            prompt.showToast({
              message: $r('app.string.Saved_to_album'), duration: 200
            });
            if (this.isSelectStatus) {
              this.resetPageData();
            }
          }
        })
        .catch((error: BusinessError) => {
          console.error(error.message);
        });
    }
  }
}