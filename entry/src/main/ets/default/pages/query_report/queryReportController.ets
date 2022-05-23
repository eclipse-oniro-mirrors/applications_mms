/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import common from '../../data/commonData';
import dateUtil from '../../utils/DateUtil';
import router from '@system.router';
import HiLog from '../../utils/HiLog'
import appStorage from '../../utils/AppStorageUtil';
const TAG = 'QueryReportController';

let queryReportCtrl;
export default class QueryReportController {
  // 是否是彩信
  isMsm: boolean = true;
  // 发送状态描述
  sendStatusDesc: Resource;
  // 发送状态
  sendStatus: number = 0;
  // 时间
  mmsTime: Resource;
  // 具体上下午时间
  specificTime: Resource;
  // 时间戳
  timeMillisecond: string = '0';
  // 手机号
  telephone: string = '';

  static getInstance() {
    if (queryReportCtrl == null) {
      queryReportCtrl = new QueryReportController();
      appStorage.setAndLink('QueryReportController', queryReportCtrl);
    }
    return queryReportCtrl;
  };

  onInit() {
    HiLog.i(TAG, 'onInit')
    this.isMsm = router.getParams().isMsm == undefined ? true : router.getParams().isMsm;
    this.sendStatus = router.getParams().sendStatus == undefined ? 0 : router.getParams().sendStatus;
    this.timeMillisecond = router.getParams().timeMillisecond == undefined ? '0' : router.getParams().timeMillisecond;
    this.telephone = router.getParams().telephone == undefined ? '' : router.getParams().telephone
  };
  onShow() {
    HiLog.i(TAG, 'onShow')
    // 状态转换成中文描述
    this.dealSendStatus();
    // 时间转换
    this.dealTime();
  };
  dealSendStatus() {
    HiLog.i(TAG, 'dealSendStatus sendStatus=' + this.sendStatus)
    if (this.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
      this.sendStatusDesc = $r("app.string.received");
    } else if (this.sendStatus == common.int.SEND_MESSAGE_FAILED) {
      this.sendStatusDesc = this.isMsm ? $r("app.string.refused") : $r("app.string.failed");
    } else {
      this.sendStatusDesc = $r("app.string.rending");
    }
  };
  dealTime() {
    this.mmsTime = dateUtil.convertTimeStampDate(this.timeMillisecond);
    this.specificTime = dateUtil.convertTimeStampTime(this.timeMillisecond, false)
  }
}