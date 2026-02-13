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
 * comment: All class and interface  provide data constraints for CURD ContactInfo in the file
 * */
import { dataSharePredicates, DataShareResultSet } from '@kit.ArkData'
import LooseObject from '../../data/LooseObject';
import mmsTable from '../../data/tableData';
import HiLog from '../../utils/HiLog';
import TelephoneUtil from '../../utils/TelephoneUtil';

const TAG = 'ContactParams';

export interface ISelectContactInfo {
    headImage: string,
    contactName: string,
    telephone: string,
    telephoneFormat: string
    select: boolean
}

/*
 * 短信列表页显示联系人
 * */
export interface ISessionTelephoneInfo {
    telephones: string[],
    hasDelete: string;
    useSilenceDB: boolean;

    buildQueryContactDataCondition(): dataSharePredicates.DataSharePredicates;

    buildContactDataResult(resultSet: DataShareResultSet): LooseObject;

    buildContactDataColumns(): string[];
}

/*
 * */
export class QueryContactInfoInSessionActionData implements ISessionTelephoneInfo {
    buildQueryContactDataCondition(): dataSharePredicates.DataSharePredicates {
        let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        condition.equalTo(mmsTable.contactDataColumns.typeId, '5');
        condition.and().equalTo(mmsTable.contactDataColumns.hasDelete, this.hasDelete);
        this.conditionOrTelephones(this.telephones, condition);
        return condition
    }

    buildContactDataResult(resultSet: DataShareResultSet): LooseObject {
        let result: LooseObject = {};
        result.detailInfo = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo));
        result.displayName = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.displayName));
        result.id = resultSet.getLong(resultSet.getColumnIndex(mmsTable.contactDataColumns.id));
        result.rawContactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.rawContactId));
        result.contactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.contactId));
        if (result.contactId !== '' && result.displayName === '') {
            HiLog.e(TAG, '[buildContactDataResult] Contact Query error.contactId: ' + result.contactId);
        }
        return result;
    }

    private conditionOrTelephones(telephones: string[], condition: dataSharePredicates.DataSharePredicates) {
        condition.beginWrap();
        let arr: string[] = [];
        let regExp = new RegExp('[\\s]', 'g');
        for (let i = 0; i < telephones.length; i++) {
            let telPhone = telephones[i];
            //如果电话号码尾数小于等于7位，直接全等匹配
            if (telPhone.length <= 7) {
                condition.and()
                    .beginWrap()
                    .equalTo(mmsTable.contactDataColumns.formatNumber, telPhone)
                    .or()
                    .equalTo(mmsTable.contactDataColumns.detailInfo, telPhone)
                    .endWrap();
                arr.push(telPhone);
                this.orCondition(telephones, condition, i);
            } else {
                let tel = TelephoneUtil.formatDisplayPhoneNum(telPhone).replace(regExp, '');
                condition.beginWrap()
                    .endsWith(mmsTable.contactDataColumns.formatNumber, tel)
                    .or()
                    .endsWith(mmsTable.contactDataColumns.detailInfo, tel)
                    .endWrap();
                arr.push(tel);
                this.orCondition(telephones, condition, i);
            }
            if (i == telephones.length - 1) {
                condition.endWrap();
            }
        }
    }

    orCondition(telephones: string[], condition: dataSharePredicates.DataSharePredicates, i: number) {
        if (i < telephones.length - 1) {
            //或的关系匹配
            condition.or();
        }
    }

    buildContactDataColumns(): string[] {
        return [
            mmsTable.contactDataColumns.detailInfo,
            mmsTable.contactDataColumns.displayName,
            mmsTable.contactDataColumns.id,
            mmsTable.contactDataColumns.rawContactId,
            mmsTable.contactDataColumns.contactId];
    }

    public telephones: string[]
    public hasDelete: string
    public useSilenceDB: boolean = false;

    constructor(telephones: string[]) {
        this.telephones = telephones
        this.hasDelete = '0'
    }
}