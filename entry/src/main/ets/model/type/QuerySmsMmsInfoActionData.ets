/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { dataSharePredicates } from '@kit.ArkData'
import LooseObject, { getAllKeyOfLooseObject } from '../../data/LooseObject';
import HiLog from '../../utils/HiLog';
import StringUtil from '../../utils/StringUtil';
import mmsTable from '../../data/tableData';
import Constant from '../../data/Constant';

const TAG = 'QuerySmsMmsInfoActionData'

export interface IQueryActionData {
    actionDataName: string;
    fields: string[];
    actionData: LooseObject;

    buildQueryCondition(): dataSharePredicates.DataSharePredicates;

    loadData(actionData: LooseObject): boolean;

    checkLegality(): boolean;
}

/*
 * 1.该方法用来解决LooseObject不知道有多少key的情况；
 * 2.通过定义一个专有类完成LooseObject究竟有哪些key，方便未来代码的扩展和检查。
 * */
export class QuerySmsMmsInfoByConditionAllActionData implements IQueryActionData {
    public actionDataName: string = Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL;

    constructor() {
        this.fields = ['threadId', 'page', 'actionDataName', 'contactsNum', 'limit', 'offset', 'isCustomSearch'];
        this.actionData = {};
    }

    public actionData: LooseObject;
    public fields: string[];

    public checkLegality(): boolean {
        let keyNameSet: Set<string> = getAllKeyOfLooseObject(this.actionData);
        //先判断每一个key的长度是否一样
        if (this.fields.length != keyNameSet.size) {
            HiLog.e(TAG, 'actionData key number is not same with fields ');
            return false;
        }
        let passFlag = true;
        //然后判断每一个keyname是否一样
        this.fields.forEach((fieldName) => {
            if (!keyNameSet.has(fieldName)) {
                passFlag = false;
                HiLog.e(TAG, 'actionData has no field: ' + fieldName);
            }
            ;
        })
        //然后判断actionDataName是否一样。
        if (!this.actionDataName === this.actionData.actionDataName) {
            passFlag = false;
            HiLog.e(TAG, 'input actionDataName is: ' + this.actionData.actionDataName,
                ' ' + 'but this class actionDataName is: ' + this.actionDataName);
        }
        return passFlag
    }

    public loadData(actionData: LooseObject): boolean {
        this.actionData = actionData;
        let passFlag: boolean = this.checkLegality();
        if (!passFlag) {
            this.actionData = {};
        }
        return passFlag
    }

    public buildQueryCondition(): dataSharePredicates.DataSharePredicates {
        let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        condition.equalTo(mmsTable.messageInfo.sessionId, this.actionData.threadId);
        condition.and().equalTo(mmsTable.messageInfo.isBlocked, Constant.NO_BLOCK);
        let limit: number = StringUtil.getLimitForSmsMmsInfo(this.actionData.page, this.actionData.contactsNum);
        let offset: number = StringUtil.getOffsetForSmsMmsInfo(this.actionData.page, this.actionData.contactsNum);
        if (this.actionData.isCustomSearch) {
            limit = this.actionData.limit;
            offset = this.actionData.offset;
        }
        condition.limit(limit, offset);
        return condition
    }
}


export class QuerySmsMmsInfoActionDataFactory {
    static create(actionData: LooseObject): IQueryActionData | undefined {
        //为信息详情页查询使用的查询action
        if (actionData.actionDataName === Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL) {
            HiLog.i(TAG, 'use ' + Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL)
            return new QuerySmsMmsInfoByConditionAllActionData();
        }
        HiLog.i(TAG, ' no actionData in  QuerySmsMmsInfoActionDataFactory')
        return undefined
    }
}