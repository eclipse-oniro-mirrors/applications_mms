/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import commonData from '../data/commonData';
import ReceiveController, { SearchContactResult } from '../views/receive/receiveController';
import HiLog from './HiLog';
import SearchUtil, { ContactsSchema, IdLabelValueSchema } from './SearchUtil';
import { taskpool } from '@kit.ArkTS';
import { Highlight } from '../utils/Highlight';
import { BusinessError } from '@kit.BasicServicesKit';
import { fuzzySearchContactsUtils } from './FuzzySearchContactsUtils';

const TAG = 'contactsSearchTaskPoolUtil';

@Concurrent
export async function searchContactsFunction(searchStr: string, context: Context) {
  // let result: ContactsSchema[] = await SearchUtil.searchContact(searchStr)//这个方法查询不到联系人，因此使用注释使用新方法
  let result: ContactsSchema[]=await fuzzySearchContactsUtils.fuzzyQueryContactByName(searchStr,context)
  let resContacts: SearchContactResult[] = [];
  result.forEach((contactSchema: ContactsSchema) => {
    contactSchema.phoneNumbers.forEach((item: IdLabelValueSchema) => {
      // build contact
      let emTagReg: RegExp = new RegExp(`${commonData.STR.EM_TAG_START}|${commonData.STR.EM_TAG_END}`, 'g');
      let contact: SearchContactResult = {
        rawContactId: contactSchema.entityId,
        contactId: contactSchema.entityId,
        displayName: (contactSchema.name ?? '').replace(emTagReg, ''),
        detailInfo: (item.value ?? '').replace(emTagReg, ''),
        nameHighlights: Highlight.getInstance().buildHighlightsByEmTag((contactSchema.name ?? ''), searchStr),
        phoneHighlights: Highlight.getInstance().buildHighlightsByEmTag((item.value ?? ''), searchStr)
      };
      resContacts.push(contact);
    });
  })
  // SearchUtil.releaseService();
  return resContacts;
}

export class ContactsSearchUtil {
  private static sInstance: ContactsSearchUtil;

  static getInstance() {
    if (ContactsSearchUtil.sInstance == null) {
      HiLog.i(TAG, 'getInstance');
      ContactsSearchUtil.sInstance = new ContactsSearchUtil();
    }
    return ContactsSearchUtil.sInstance;
  }

  public searchContactsWithTaskPool(searchStr: string, context: Context,receiveController: ReceiveController, callback: Function) {
    HiLog.i(TAG, 'searchContactsWithTaskPool')
    let task: taskpool.Task = new taskpool.Task(searchContactsFunction, searchStr, context)
    taskpool.execute(task).then((result) => {
      this.dealSearchContactsResult(result as ContactsSchema[], receiveController, callback)
    }).catch((e: BusinessError) => {
      HiLog.e(TAG, 'search contacts failure: code = ' + e.code ?? -1 + ', name = ' + e.name ??
        'UnknownError' + ', message = ' + e.message ?? 'UnknownMessage' + ', stack = ' + e.stack ?? 'UnknownStack');
      callback(commonData.int.FAILURE);
    });
    return task
  }

  private dealSearchContactsResult(resContacts: ContactsSchema[], receiveController: ReceiveController,
    callback: Function) {
    receiveController.contacts = resContacts;
    receiveController.formatContactData();
    receiveController.deleteRepetitionContacts(receiveController.contacts, receiveController.selectContacts);
    receiveController.contactsTemp = receiveController.contacts.slice(0);
    receiveController.dealSearchData();
    HiLog.i(TAG, 'search contacts success. Count: ' + receiveController.contacts.length + ', ' + resContacts.length);
    callback(commonData.int.SUCCESS);
  }
}