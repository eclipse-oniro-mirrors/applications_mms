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

import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import TelephoneUtil from '../utils/TelephoneUtil';
import LooseObject from '../data/LooseObject';
import ContactsModel from '../model/ContactsModel';
import StringUtil from '../utils/StringUtil';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import myCommon from '@ohos.app.ability.common';
import { GlobalThisType } from './ConversationListService';
import AvatarColor from '../model/common/AvatarColor';
import { AbilityResult } from '../utils/TypesUtils';

const TAG = 'ContactsService';

export default class ContactsService {
  private static instance: ContactsService;
  private contactsModel = new ContactsModel();

  private constructor() {
  }

  public static getInstance(): ContactsService {
    if (ContactsService.instance == null) {
      ContactsService.instance = new ContactsService();
    }
    return ContactsService.instance;
  }

  public static getTestInstance(): ContactsService {
    return new ContactsService();
  }

  public async queryContactDataByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryContactDataByCondition,
        {
          actionData: actionData,
          context: context
        } as GlobalThisType, (res: LooseObject) => {
          callback(res);
        });
    } else {
      this.contactsModel.queryContactDataByCondition(actionData, callback, context);
    }
  }

  public async queryContactDataReceive(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    HiLog.i(TAG, 'queryContactDataReceive start');
    this.contactsModel.queryContactDataByCondition(actionData, callback, context);
  }

  public async queryCallLogByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryCallLogByCondition, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        callback(res);
      });
    } else {
      this.contactsModel.queryCallLogByCondition(actionData, callback, context);
    }
  }

  public async queryContactDataSizeByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryContactDataSizeByCondition,
        {
          actionData: actionData,
          context: context
        } as GlobalThisType, (res: Object) => {
          callback(res);
        });
    } else {
      this.contactsModel.queryContactDataSizeByCondition(actionData, callback, context);
    }
  }

  public async queryContactByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryContactByCondition, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: LooseObject) => {
        callback(res);
      });
    } else {
      this.contactsModel.queryContactByCondition(actionData, callback, context);
    }
  }

  public async queryRecentContactByRow(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryRecentContactByRow, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: LooseObject) => {
        callback(res);
      });
    } else {
      this.contactsModel.queryRecentContactByRow(actionData, callback, context);
    }
  }

  public async queryContactSizeByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryContactSizeByCondition,
        {
          actionData: actionData,
          context: context
        } as GlobalThisType, (res: LooseObject) => {
          callback(res);
        });
    } else {
      this.contactsModel.queryContactSizeByCondition(actionData, callback, context);
    }
  }

  public async queryRawContactSizeByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryRawContactSizeByCondition,
        {
          actionData: actionData,
          context: context
        } as GlobalThisType, (res: LooseObject) => {
          callback(res);
        });
    } else {
      this.contactsModel.queryRawContactSizeByCondition(actionData, callback, context);
    }
  }

  public async queryContactViewByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryContactViewByCondition,
        {
          actionData: actionData,
          context: context
        } as GlobalThisType, (res: LooseObject) => {
          callback(res);
        });
    } else {
      this.contactsModel.queryContactViewByCondition(actionData, callback, context);
    }
  }

  public queryContact(actionData: LooseObject, callback: Function, context: Context): void {
    this.queryContactByCondition(actionData, (res: LooseObject) => {
      if (res.code == common.int.FAILURE) {
        callback(res);
        return;
      }
      actionData.contactIds = res.abilityResult[0];
      this.queryContactDataByCondition(actionData, (res: LooseObject) => {
        if (res.code == common.int.FAILURE) {
          callback(res);
          return;
        }
        let contactList: Array<LooseObject> = this.buildContactList(res.abilityResult);
        let result: LooseObject = {};
        result.code = common.int.SUCCESS;
        result.response = contactList;
        callback(result);
      }, context);
    }, context);
  }

  public queryRecentContact(callback: Function, context: Context): void {
    let actionData: Record<string, string> = {
      'type': common.recent_contacts.type,
    };
    this.queryRecentContactByRow(actionData, (res: LooseObject) => {
      if (res.code == common.int.FAILURE) {
        callback(res);
        return;
      }
      let contactList: Array<LooseObject> = this.buildContactList(res.abilityResult);
      let result: LooseObject = {};
      result.code = common.int.SUCCESS;
      result.response = contactList;
      callback(result);
    }, context);
  }

  // deal contactParams from third application
  public dealContactParams(contactObjects: string): LooseObject {
    HiLog.i(TAG, 'dealContactParams start');
    let contactParams: LooseObject = {};
    if (StringUtil.isEmpty(contactObjects)) {
      return contactParams;
    }
    let params: Array<LooseObject> = [];
    try {
      params = JSON.parse(contactObjects);
      let contactsNumber: string = common.STR.EMPTY_STR;
      let contactsName: string = common.STR.EMPTY_STR;
      let contactsNumberFormat: string = common.STR.EMPTY_STR;
      let rawContactIds: Array<string> = [];
      let length: number = params.length;
      for (let i = 0; i < params.length; i++) {
        let item: LooseObject = params[i];
        contactsNumber = contactsNumber + item.telephone + common.STR.COMMA;
        contactsNumberFormat = contactsNumberFormat + item.telephone + common.STR.COMMA;
        if (item.contactName) {
          contactsName += (item.contactName + common.STR.COMMA);
        } else if (length > 1) {
          contactsName += (item.telephone + common.STR.COMMA);
        }
        rawContactIds.push(item.contactId || '');
      }
      let telephone: string = contactsNumber.substring(0, contactsNumber.length - 1);
      contactsNumber = TelephoneUtil.dealTelephoneSort(telephone);
      contactParams.strContactsNumber = contactsNumber;
      contactParams.strContactsNumberFormat = contactsNumberFormat.substring(0, contactsNumberFormat.length - 1);
      contactParams.strContactsName = contactsName.substring(0, contactsName.length - 1);
      contactParams.contactsNum = length;
      contactParams.rawContactId = rawContactIds.join(common.STR.COMMA);
    } catch (error) {
      HiLog.e(TAG, 'dealContactParams failed, return!');
      return contactParams;
    }
    return contactParams;
  }

  public judgeContactExist(actionData: LooseObject, callback: Function, context: Context): void {
    this.queryContactDataSizeByCondition(actionData, (res: LooseObject) => {
      let isContactExist: boolean = false;
      if (res.code == common.int.FAILURE) {
        HiLog.e(TAG, 'judgeProfileExit fail!');
        callback(isContactExist);
      } else {
        if (res.abilityResult > 0) {
          isContactExist = true;
        }
        callback(isContactExist);
      }
    }, context);
  }

  private buildContactList(contacts: LooseObject[]): Array<LooseObject> {
    let contactList: Array<LooseObject> = [];
    for (let contact of contacts) {
      let item: LooseObject = {};
      item.contactName = contact.displayName;
      item.headImage = 'icon/user_avatar_full_fill.svg';
      item.telephone = contact.detailInfo;
      item.telephoneFormat = contact.detailInfo;
      item.select = false;
      item.primary = contact.primary ? contact.primary : 0;
      item.rawContactId = contact.rawContactId ? contact.rawContactId : -1;
      item.contactId = contact.contactId ? contact.contactId : -1;
      item.portraitColor = AvatarColor.background.Color[Math.abs(Number.parseInt(item.rawContactId, 10)) % 6];
      item.photoFirstName = StringUtil.getFirstName(contact.displayName)
      contactList.push(item);
    }
    return contactList;
  }

  public async getStrContactsName(context: Context, actionData: LooseObject, contactParams: LooseObject) {
    return new Promise<void>((resolve) => {
      this.contactsModel.queryContactDataByCondition(actionData, async (res: AbilityResult) => {
        if (res.code === 0 && res?.abilityResult?.length !== 0) {
          contactParams.strContactsName = res.abilityResult[0].displayName;
        }
        resolve();
      }, context);
    });
  }
}
