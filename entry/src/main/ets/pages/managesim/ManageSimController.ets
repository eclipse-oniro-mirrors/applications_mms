/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import lazy { DateUtil } from '../../utils/DateUtil';
import CardMmsListDataSource from '../../model/CardMmsListDataSource';
import sms from '@ohos.telephony.sms';
import { BusinessError } from '@ohos.base';
import { cardMmsListType } from '../../pages/conversation/conversationController';
import HiLog from '../../utils/HiLog';
import { Params } from '../../data/simCardData';

const TAG = 'ManageSimController'

export default class ManageSimController {
  private static sInstance: ManageSimController | undefined = undefined;
  slotId: number = -1;
  cardMmsList : Array<cardMmsListType> = [];
  pageInfos: NavPathStack = new NavPathStack();
  transmitDialogController: CustomDialogController | null = null;
  cardMmsListDataSource: CardMmsListDataSource = new CardMmsListDataSource();
  showContent: boolean = false;
  dialogController: CustomDialogController | null = null;

  static getInstance() {
    if (!ManageSimController.sInstance) {
      ManageSimController.sInstance = new ManageSimController();
    }
    return ManageSimController.sInstance;
  }

  public static release() {
    ManageSimController.sInstance = undefined;
  }

  onInit(pageInfos: NavPathStack, dialogController: CustomDialogController) {
    this.resetList()
    this.pageInfos = pageInfos;
    let params: Array<Params> = this.pageInfos.getParamByName('ManageSim') as Array<Params>;
    this.slotId = params[0]?.slotId;
    this.dialogController = dialogController
    if (this.dialogController !== null) {
      this.dialogController.open();
    }
    this.cardMmsQuery()
  }

  resetList() {
    this.showContent = false
    this.cardMmsList = []
  }

  goBack() {
    this.pageInfos.pop();
  }

  convertTime(timeStamp:number) {
    let timeShow = DateUtil.convertTimeStampTime(timeStamp * 1000)
    return timeShow
  }

  pushToCopyController(index: number) {
    let param: Record<string, string | number | Resource | boolean> = {
      'info': this.cardMmsList[index].content,
      'isFromConversation': true
    }
    this.pageInfos.pushPathByName('CopyView', param);
  }

  cardMmsQuery() {
    sms.getAllSimMessages(this.slotId, (err: BusinessError, data: sms.SimShortMessage[]) => {
      HiLog.w(TAG,  `getAllSimMessages callback: err->${JSON.stringify(err)}`);
      if (data !== null && data) {
        data.forEach(item => {
          let timeRange = this.convertTime(item.shortMessage.scTimestamp)
          let data: cardMmsListType = {
            content: item.shortMessage.visibleMessageBody,
            name: item.shortMessage.visibleRawAddress,
            timeRange : timeRange
          }
          this.cardMmsList.push(data)
        })
        this.showContent = true
        if (this.dialogController) {
          this.dialogController.close();
        }
      }
    });
    this.cardMmsListDataSource.refresh(this.cardMmsList);
  }
}
