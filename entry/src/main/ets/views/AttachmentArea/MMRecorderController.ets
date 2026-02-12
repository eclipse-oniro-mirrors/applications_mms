/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';
import commonData from '../../data/commonData';
import HiLog from '../../utils/HiLog';
import promptAction from '@ohos.promptAction';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import { AudioRecorderService } from '../../service/AudioRecorderService';
import StringUtil from '../../utils/StringUtil';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import FileUtil from '../../utils/FileUtil';
import MmsUtil from '../../utils/MmsUtil';
import call from '@ohos.telephony.call';
import { BusinessError } from '@ohos.base';
import OperatorConfigUtil from '../../../cust/utils/OperatorConfigUtil';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import bundleManager from '@ohos.bundle.bundleManager';
import dotCommon, { mmsTypeParams, sendRcsRecordParams, timeStatusParams } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import lazy { SplitScreenManager, SplitScreenType } from '../../utils/SplitScreenManager'
import { audio } from '@kit.AudioKit';

const TAG = 'MMRecorderController ';
const TIME_ZERO = '00:00';

export class PermissionContainDialogShown {
  public authResults : number = -1
  public dialogShownResults : boolean = false
}

export default class MMRecorderController {
  private static sInstance: MMRecorderController;
  mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  private audioRecorderService: AudioRecorderService = new AudioRecorderService();
  scaleAnimator?: AnimatorResult;
  interval: number = -1;
  seconds: number = 0;
  minute: number = 0;
  isAllowed: boolean = false;
  recorderTime: string = TIME_ZERO;
  currentSize: number = 0;
  totalSize: number = 0;
  isExceedSize: boolean = false;
  audioReady: boolean = false;
  public isNeedTextareaFocus: boolean = false;
  private recorderFilePath: string = '';
  private recorderFileName: string = '';
  private stopRecordCallBack: Function = () => {}

  private optionsAnimator: AnimatorOptions = {
    duration: 1500,
    easing: 'linear',
    delay: 0,
    fill: 'backwards',
    direction: 'normal',
    iterations: -1,
    begin: 1,
    end: 3.25
  }
  private optionsAnimatorSplit: AnimatorOptions = {
    duration: 1000,
    easing: 'linear',
    delay: 0,
    fill: 'backwards',
    direction: 'normal',
    iterations: -1,
    begin: 1,
    end: 1.95
  }


  static getInstance() {
    if (MMRecorderController.sInstance == null) {
      MMRecorderController.sInstance = new MMRecorderController();
    }
    return MMRecorderController.sInstance;
  }

  onInit() {
    HiLog.i(TAG, 'onInit');
    this.createAnimator();
  }

  checkAccessToken(permissionName: Permissions): boolean {
    let atManager = abilityAccessCtrl.createAtManager();
    let info = bundleManager.getApplicationInfoSync(commonData.STR.BUNDLE_NAME,
      bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_PERMISSION)
    let hasPermission = atManager.verifyAccessTokenSync(info.accessTokenId, permissionName);
    return hasPermission === 0;
  }

  async initPermission(permissionName: Permissions): Promise<number> {
    let atManager = abilityAccessCtrl.createAtManager();
    let permissions: Array<Permissions> = []
    permissions.push(permissionName);
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let permissionResult = await atManager.requestPermissionsFromUser(context, permissions)
    HiLog.i(TAG, `permissionResult:${permissionResult.authResults[0]}`);
    return permissionResult.authResults[0];
  }

  async initPermissionContainDialogShown(permissionName: Permissions): Promise<PermissionContainDialogShown> {
    let atManager = abilityAccessCtrl.createAtManager();
    let permissions: Array<Permissions> = []
    permissions.push(permissionName);
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let permissionResult = await atManager.requestPermissionsFromUser(context, permissions)
    HiLog.i(TAG, `permissionResult:${permissionResult.authResults[0]}`);
    let permissionContainDialogShown : PermissionContainDialogShown = {
      authResults : permissionResult.authResults[0],
      dialogShownResults: permissionResult.dialogShownResults != null ? permissionResult.dialogShownResults[0] : false
    };
    return permissionContainDialogShown;
  }

  createAnimator() {
    HiLog.i(TAG, 'createAnimator');
    if (SplitScreenManager.getInstance().isSplitScreenSmall()) {
      this.scaleAnimator = animator.create(this.optionsAnimatorSplit);
    } else {
      this.scaleAnimator = animator.create(this.optionsAnimator);
    }
  }

  resetAnimator() {
    if (!this.scaleAnimator) {
      return
    }
    if (SplitScreenManager.getInstance().isSplitScreenSmall()) {
      this.scaleAnimator.reset(this.optionsAnimatorSplit);
    } else {
      this.scaleAnimator.reset(this.optionsAnimator);
    }
  }

  getFileTotalSize(): number {
    let fileSize = GlobalContext.getContext().getObject('fileTotalSize') as number;
    if (!fileSize) {
      fileSize = 0;
    }
    return fileSize;
  }

  checkSizeIsExceeded() {
    HiLog.i(TAG, 'checkSizeIsExceeded');
    this.recorderTime = TIME_ZERO;
    let fileSize = this.getFileTotalSize();
    if (fileSize >= this.getCustRecordSize(commonData.int.MMS_AUDIO_FILE_MAX_SIZE)) {
      HiLog.i(TAG, 'startRecord size exceed max');
      MmsUtil.showToast({
        message: $r('app.string.mms_audio_size_maximum'),
        duration: 2000
      });
      return true;
    } else {
      return false;
    }
  }

  startRecord(context: Context, callback?:Function) {
    HiLog.i(TAG, 'startRecord');
    this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.RECORD
    this.clearInterval();
    this.recorderTime = TIME_ZERO;
    let fileSize = this.getFileTotalSize();
    this.totalSize = fileSize;
    this.scaleAnimator?.play();
    this.audioReady = true;
    this.audioRecorderService.startRecording(context, (ready: boolean) => {
      this.audioReady = ready;
      if (callback) {
        callback(ready);
      }
      if (ready) {
        this.startInterval();
      }
    });
  }

  startInterval() {
    HiLog.i(TAG, 'startInterval');
    this.interval = setInterval(() => {
      let recordSize = this.audioRecorderService.getRecorderSize();
      if (this.totalSize + recordSize >= this.getCustRecordSize(commonData.int.MMS_AUDIO_FILE_MAX_SIZE)) {
        HiLog.i(TAG, 'exceed max size');
        // Intercept recordings
        this.isExceedSize = true;
        MmsUtil.showToast({
          message: $r('app.string.mms_audio_size_maximum'),
          duration: 2000
        });
        AppStorage.setOrCreate('isExceedSize', true);
        AppStorage.setOrCreate('recorderIsShow', false)
      } else {
        this.currentSize = recordSize;
        this.seconds ++;
        if (this.seconds >= 60) {
          this.seconds = 0;
          this.minute ++;
        }
        let timeStr: string = ((this.minute >= 10) ? this.minute : ('0' + this.minute)) + ':' +
          ((this.seconds >= 10) ? this.seconds : ('0' + this.seconds));
        this.recorderTime = timeStr;
        HiLog.i(TAG, 'recorderTime: ' + ` ${timeStr}`);
      }
    }, 1000);
  }

  stopRecord(context: Context, callBack?: Function, replaceVcardCallBack?: Function) {
    HiLog.i(TAG, 'stopRecord');
    this.scaleAnimator?.cancel();
    this.audioRecorderService.stopRecording(context, (path: string, name: string) => {
      this.recorderFilePath = path
      this.recorderFileName = name
      if(callBack) this.stopRecordCallBack = callBack
      HiLog.i(TAG, 'stopRecording callback');
      if (this.mmAreaController.hasNeedReplaceVcard() && replaceVcardCallBack && !StringUtil.isEmpty(path)) {
        replaceVcardCallBack()
      } else {
        this.handleStopRecording(context)
      }
    });
  }

  handleStopRecording(context: Context, fromReplace?: boolean) {
    if (!StringUtil.isEmpty(this.recorderFilePath)) {
      let recordSize = FileUtil.getFileSizeByPath(this.recorderFilePath);
      this.totalSize = this.totalSize + recordSize;
      if (this.totalSize < 0) {
        this.totalSize = 0;
      }
      GlobalContext.getContext().setObject('fileTotalSize', this.totalSize);
      this.setAudioInfo(context, this.recorderFilePath, this.recorderFileName, this.recorderTime, fromReplace);
    }
    this.clearInterval(this.stopRecordCallBack);
    this.audioRecorderService.closeFile();
  }

  clearInterval(callBack?: Function) {
    HiLog.i(TAG, 'clearInterval');
    if (this.interval !== -1) {
      let fileSize = this.getFileTotalSize();
      if (fileSize < this.getCustRecordSize(commonData.int.MMS_AUDIO_FILE_MAX_SIZE)) {
        if (this.minute === 0 && this.seconds < 1 && this.audioReady) {
          MmsUtil.showToast({
            message: $r('app.string.msg_record_short'),
            duration: 2000
          });
          this.isNeedTextareaFocus = false;
          timeStatusParams.TIME_STATUS = 1;
        } else {
          this.isNeedTextareaFocus = true;
          timeStatusParams.TIME_STATUS = 2;
          mmsTypeParams.TYPE_STATUS = 3;
          DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.ADD_ATTACHMENT);
        }
        if (callBack) {
          callBack();
        }
      }
      clearInterval(this.interval);
      this.interval = -1;
      this.minute = 0;
      this.seconds = 0;
      this.recorderTime = TIME_ZERO;
    }
  }

  setAudioInfo(context: Context, fdPath: string, name: string, recordTime: string, fromReplace?: boolean) {
    HiLog.i(TAG, 'setAudioInfo');
    if (this.seconds >= 1 || this.minute > 0) {
      if (this.isExceedSize) {
        setTimeout(() => {
          this.mmAreaController.setAudio(context, recordTime, fdPath, name, fromReplace);
          this.isExceedSize = false;
        }, 200);
      } else {
        this.mmAreaController.setAudio(context, recordTime, fdPath, name, fromReplace);
      }
    } else {
      // 时长不满足要求时刪除文件
      FileUtil.deleteFile(context, FileUtil.getFileName(fdPath));
    }
  }

  checkMicState() {
    let audioVolumeGroupManager: audio.AudioVolumeGroupManager;
    try {
      audioVolumeGroupManager = audio.getAudioManager()
        .getVolumeManager()
        .getVolumeGroupManagerSync(audio.DEFAULT_VOLUME_GROUP_ID)
    } catch (err) {
      HiLog.e(TAG, `getVolumeGroupManagerSync error, code: ${err.code}, message: ${err.message}`);
      return false;
    }
    let micState: boolean = audioVolumeGroupManager.isMicrophoneMuteSync()
    HiLog.i(TAG, 'micState: ' + micState)
    if (micState) {
      HiLog.i(TAG, 'the microphone is muted.');
      return true;
    }
    return false;
  }

  checkCallState(callBack?:Function) {
    call.getCallState().then((data: call.CallState) => {
      // 1: Incoming call is ringing or waiting;
      // 2:At least one call is dialed, in progress, or on hold, and no new calls are ringing or waiting
      if(![1,2].includes(data)){
        callBack && callBack();
      } else {
        promptAction.showToast({
          message: $r('app.string.rejectRecord'),
          duration: 2000
        });
        HiLog.i(TAG, 'current is calling');
      }
    }).catch((err: BusinessError) => {
      HiLog.e(TAG,`getCallState fail, promise: err->${JSON.stringify(err)}`);
    });
  }

  getCustRecordSize(defaultSize: number): number {
    let custRecordSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(defaultSize);
    if (custRecordSize === defaultSize) {
      return defaultSize;
    }
    return custRecordSize - (commonData.int.MMS_FILE_MAX_SIZE - defaultSize);
  }

  permissionOnSetting(context: Context) {
    HiLog.i(TAG, 'permissionOnSetting');
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionOnSetting(context, ['ohos.permission.MICROPHONE'])
      .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
        HiLog.i(TAG, 'requestPermissionOnSetting data : ' + data);
      }).catch((err: BusinessError) => {
        HiLog.i(TAG, 'requestPermissionOnSetting data : ' + JSON.stringify(err));
      });
  }

  async permissionOnSettingAsync(context: Context): Promise<abilityAccessCtrl.GrantStatus> {
    HiLog.i(TAG, 'permissionOnSettingAsync');
    let atManager = abilityAccessCtrl.createAtManager();
    let res: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    await atManager.requestPermissionOnSetting(context, ['ohos.permission.MICROPHONE'])
      .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
        HiLog.i(TAG, 'permissionOnSettingAsync data   : ' + JSON.stringify(data));
        res =  data[0];
      }).catch((err: BusinessError) => {
      HiLog.i(TAG, 'permissionOnSettingAsync data : ' + JSON.stringify(err));
    });
    return res;
  }
}