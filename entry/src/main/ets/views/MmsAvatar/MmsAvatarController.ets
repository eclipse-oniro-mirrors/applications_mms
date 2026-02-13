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

import HiLog from '../../utils/HiLog';
import LooseObject from '../../data/LooseObject';
import router from '@system.router';
import commonService from '../../service/CommonService';
import common from '../../data/commonData';
import { BusinessError } from '@ohos.base';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';

const TAG = 'MmsSearchController';

let MmsAvatarCtrl: MmsAvatarController;

export default class MmsAvatarController {
  pageInfos: NavPathStack | null = null;
  static getInstance() {
    if (MmsAvatarCtrl == null) {
      MmsAvatarCtrl = new MmsAvatarController();
    }
    return MmsAvatarCtrl;
  }

  onShow(pageInfos: NavPathStack) {
    this.pageInfos = pageInfos;
  }

  clickAvatar(item: LooseObject) {
    HiLog.i(TAG, 'click avatar');
    let contactsNum: number = item?.contactsNum;
    let telephone: string = item?.telephone;
    if (contactsNum == common.int.MESSAGE_CODE_ONE) {
      let actionData: Record<string, number | string> = {
        'phoneNumber': telephone,
        'pageFlag': common.contactPage.PAGE_FLAG_CONTACT_DETAILS
      };
      this.jumpToContact(actionData);
    } else {
      let threadId: number = item?.threadId;
      this.jumpToGroupContactList(threadId);
    }
  }

  jumpToContact(actionData: Record<string, number | string>) {
    HiLog.i(TAG, 'jump to contact');
    let str = commonService.commonContactParam(actionData);
    (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToContact, startAbility success');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed Cause: ' + JSON.stringify(error.message));
    })
  }

  jumpToGroupContactList(threadId: number) {
    HiLog.i(TAG, 'jump to contact list view');
    this.pageInfos?.pushPathByName('groupContactList',{
      'threadId': threadId
    } as Record<string,number>);
  }
}
