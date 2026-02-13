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

import { ContactsSchema } from "./SearchUtil";
import { dataShare, dataSharePredicates } from "@kit.ArkData";
import DataShareHelper from "../model/repository/DataShareHelper";
import mmsTable from '../data/tableData';
import HiLog from "./HiLog";
import common from '../data/commonData';
import { QueryContactInfoInSessionActionData } from "../model/type/ContactParams";

const TAG = 'FuzzySearchContactsUtils';

class FuzzySearchContactsUtils {
  private queryContactInfoInSessionActionData: QueryContactInfoInSessionActionData =
    new QueryContactInfoInSessionActionData([])

  public async fuzzyQueryContactByName(queryText: string, context: Context): Promise<ContactsSchema[]> {
    //初始化
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[fuzzyQueryContactByName] createDataShareHelper fail`);
      return [];
    }
    // 构建模糊查询条件，支持按姓名模糊匹配
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.contactDataColumns.typeId, '5'); // 5代表电话类型
    // 使用like操作符实现模糊查询
    if (queryText && queryText.trim() !== '') {
      condition.and()
        .beginWrap()
        .like(mmsTable.contactDataColumns.detailInfo, `%${queryText}%`) // 电话号码模糊匹配
        .or()
        .like(mmsTable.contactDataColumns.displayName, `%${queryText.trim()}%`) // 匹配联系人名称
        .endWrap();
    }
    let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
    try {
      // 查询
      let resultSet = await dataHelper.query(contactDataUri, condition,
        this.queryContactInfoInSessionActionData.buildContactDataColumns());
      const contactsResults: ContactsSchema[] = [];
      if (resultSet.rowCount > 0) {
        // 遍历结果集
        while (resultSet.goToNextRow()) {
          const contact: ContactsSchema = {
            entityId: resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.rawContactId)) || '',
            entityName: resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.contactId)) || '',
            name: resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.displayName)) || '',
            nameExt: '',
            namePinyin: '',
            organization: '',
            title: '',
            icon: '',
            phoneNumbers: [],
            emails: [],
            note: '',
            detailUri: '',
            familyAddress: '',
            imInfo: [],
            imUri: '',
            groupInfo: '',
            nickname: '',
            meeTimeUri: '',
            callUri: '',
            smsUri: '',
            position: ''
          };

          // 添加电话号码
          const phoneValue = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo)) || '';
          if (phoneValue) {
            contact.phoneNumbers.push({
              id: '',
              label: 'PHONE',
              value: phoneValue
            });
          }

          contactsResults.push(contact);
        }
      }

      resultSet.close();
      HiLog.i(TAG, `Successfully querying contacts by name fuzzily, contactsResults: ${JSON.stringify(contactsResults)}`);
      return contactsResults;
    } catch (error) {
      HiLog.e(TAG,'Failed to fuzzy search contacts by name, error: ' + JSON.stringify(error));
      return [];
    }
  }
}

export const fuzzySearchContactsUtils = new FuzzySearchContactsUtils()