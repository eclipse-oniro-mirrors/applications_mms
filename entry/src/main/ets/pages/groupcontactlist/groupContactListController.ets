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

import HiLog from '../../utils/HiLog';
import common from '../../data/commonData';
import LooseObject from '../../data/LooseObject';
import AvatarColor from '../../model/common/AvatarColor';
import GroupDetailService from '../../service/GroupDetailService';
import commonService from '../../service/CommonService';
import { BusinessError } from '@ohos.base';
import { ActionData } from '../conversationlist/conversationListController';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import StringUtil from '../../utils/StringUtil';
import YellowPageService from '../../service/yellowPageService';

const TAG = 'GroupContactListController';

export default class GroupContactListController {
  private static sInstance: GroupContactListController;
  public contactList: Array<LooseObject> = [];
  public threadId: string = '';
  public groupId: string = '';
  public groupDetailService: GroupDetailService = GroupDetailService.getInstance();
  public numberReg: RegExp = new RegExp('^[0-9]+$');
  public pageInfos: NavPathStack = new NavPathStack();

  static getInstance() {
    if (GroupContactListController.sInstance == null) {
      GroupContactListController.sInstance = new GroupContactListController();
    }
    return GroupContactListController.sInstance;
  }

  onBackPress() {
    this.pageInfos.pop();
    return true;
  }

  onInit(context: Context, pageInfos: NavPathStack) {
    this.pageInfos = pageInfos;
    let routerParams: Array<LooseObject> = this.pageInfos.getParamByName('groupContactList') as Array<LooseObject>;
    this.threadId = routerParams[0].threadId;
    this.queryContactListDetail(context);
  }

  queryContactListDetail(context: Context) {
    let actionData: LooseObject = {};
    actionData.threadId = this.threadId;
    this.groupDetailService.queryContactList(context, actionData, async (result: LooseObject) => {
      let code: number = result.code;
      await this.dealContactListResult(code, result);
    })
  }

  private async dealContactListResult(code: number, result: LooseObject) {
    if (code == common.int.SUCCESS) {
      HiLog.i(TAG, 'queryContactList Success');
      for (let i = 0; i < result.contactList.length; i++) {
        if (StringUtil.isEmpty(result.contactList[i].name)) {
          let res = await YellowPageService.getInstance()
            .judgeYellowPageExist(result.contactList[i], GlobalContext.getContext()
            .getObject('mmsContext') as myCommon.UIAbilityContext);
          result.contactList[i].name = res.name;
          result.contactList[i].hasYellowPageIcon = res.photo;
        }
      }
      this.contactList = result.contactList;
    } else {
      HiLog.i(TAG, 'queryContactList failed');
      this.contactList = [];
    }
  }

  getContactPhotoName(index?: number): string {
    let photoFirstName: string = common.STR.EMPTY_STR;
    if (this.contactList.length > index!) {
      let item: LooseObject = this.contactList[index!];
      let photoNames: Array<LooseObject> = item.photoFirstNames;
      if (photoNames.length > 0) {
        let photoName: LooseObject = photoNames[0];
        photoFirstName = photoName.firstName;
      }
    }
    return photoFirstName;
  }

  getContactPortraitColor(index?: number): Resource {
    let color: Resource = AvatarColor.background.Color[0];
    let length: number = AvatarColor.background.Color.length;
    color = AvatarColor.background.Color[Math.abs(Number.parseInt(this.threadId, 10)) % length];
    if (this.contactList.length > index!) {
      let item: LooseObject = this.contactList[index!];
      let photoNames: Array<LooseObject> = item.photoFirstNames;
      if (photoNames.length > 0) {
        let photoName: LooseObject = photoNames[0];
        if (photoName.portraitColor && photoName.portraitColor !== common.STR.EMPTY_STR) {
          color = photoName.portraitColor;
        } else if (item.telephone !== common.STR.EMPTY_STR &&
        this.numberReg.test(item.telephone.substring(item.telephone.length - 1))) {
          let lastNumber: string = item.telephone.substring(item.telephone.length - 1);
          color = AvatarColor.background.Color[Number(lastNumber) % 6];
        }
      }
    }
    return color;
  }

  clickToContactDetail(index: number) {
    let contact = this.contactList[index];
    let actionData: ActionData= {};
    actionData.phoneNumber = contact.telephone;
    actionData.pageFlag = common.contactPage.PAGE_FLAG_CONTACT_DETAILS;
    this.jumpToContactDetailForResult(actionData);
  }

  async jumpToContactDetailForResult(actionData: ActionData) {
    let str = commonService.commonContactParam(actionData);
    (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToContact, startAbility Success');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed. Cause: ' + JSON.stringify(error.message));
    });
  }
}