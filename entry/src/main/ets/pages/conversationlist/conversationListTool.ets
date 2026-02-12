/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import LooseObject from '../../data/LooseObject';
import common, { GlobalContextKey } from '../../data/commonData'
import Constant from '../../data/Constant';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import HiLog from '../../utils/HiLog';
const TAG = 'conversationListTool'
/*
 * 查询首页消息数据库ActionData
 * 是冷启动：使用ui线程和静默模式访问数据库
 * 否则：使用worker和常规数据库访问方式
 */
export function queryFirstPageMessagesDataBaseActionData(actionData: LooseObject, hasAggregate: boolean,
    pinSessionSize: number): LooseObject {
    if (hasAggregate) {
        actionData.smsType = common.sms_type.COMMON;
    }
    HiLog.i(TAG, 'queryFirstPageMessagesDataBaseActionData pinSessionSize: ' + pinSessionSize);
    pinSessionSize = (pinSessionSize < 0) ? 0 : pinSessionSize;
    actionData.page = Constant.PAGE_INIT_NUM;
    actionData.limit = Constant.FIRST_PAGE_SIZE + pinSessionSize;
    actionData.orderByTimeDesc = true;
    let databaseInitSuccess =
        SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_SMS_DATABASE_INIT_SUCCESS, false) as boolean;
    if (databaseInitSuccess &&
    GlobalContext.getContext().hasKey(GlobalContextKey.QUERY_FIRST_PAGE_ON_COLD_START_UP) &&
        GlobalContext.getContext().getObject(GlobalContextKey.QUERY_FIRST_PAGE_ON_COLD_START_UP) as boolean) {
        actionData.useWorker = false;
        actionData.useSilenceDB = true;
        GlobalContext.getContext().setObject(GlobalContextKey.QUERY_FIRST_PAGE_ON_COLD_START_UP, false)
    }
    return actionData
}

/*
 * 查询指定个数的消息数据库ActionData
 * 是冷启动：使用ui线程和静默模式访问数据库
 * 否则：使用worker和常规数据库访问方式
 */
export function queryMessagesDataBaseActionData(actionData: LooseObject, hasAggregate: boolean,
    querySize: number): LooseObject {
    if (hasAggregate) {
        actionData.smsType = common.sms_type.COMMON;
    }
    HiLog.i(TAG, 'queryMessagesDataBaseActionData querySize: ' + querySize);
    actionData.page = Constant.PAGE_INIT_NUM;
    actionData.limit = querySize;
    actionData.orderByTimeDesc = true;
    let databaseInitSuccess =
        SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_SMS_DATABASE_INIT_SUCCESS, false) as boolean;
    if (databaseInitSuccess &&
    GlobalContext.getContext().hasKey(GlobalContextKey.QUERY_FIRST_PAGE_ON_COLD_START_UP) &&
        GlobalContext.getContext().getObject(GlobalContextKey.QUERY_FIRST_PAGE_ON_COLD_START_UP) as boolean) {
        actionData.useWorker = false;
        actionData.useSilenceDB = true;
        GlobalContext.getContext().setObject(GlobalContextKey.QUERY_FIRST_PAGE_ON_COLD_START_UP, false)
    }
    return actionData
}

export class ContactsUpdateRecords {
    private delayNumberMicroseconds: number = 200
    //联系人云同步发送广播事件间隔,平均间隔时间是3.9s--4.8s之间。
    public static readonly contactCloudSyncTimeIntervalMicroseconds: number = 5000
    public static readonly contactManualUpdateMicroseconds: number = 200
    private lastUpdateTimestamp: number = -1

    //根据联系人的更新事件，推导出当前是否处于联系人云同步
    //动态决定联系人的刷新时间
    public contactsUpdateEvent(): number {
        let currentTimestamp = Date.now();
        if (currentTimestamp - this.lastUpdateTimestamp > ContactsUpdateRecords.contactManualUpdateMicroseconds &&
            currentTimestamp - this.lastUpdateTimestamp <
            ContactsUpdateRecords.contactCloudSyncTimeIntervalMicroseconds) {
            // 两次更新事件，间隔200ms-5s，处于云同步状态。
            this.delayNumberMicroseconds = ContactsUpdateRecords.contactCloudSyncTimeIntervalMicroseconds;
        } else {
            //两次更新事件，处于手工更新状态。
            this.delayNumberMicroseconds = ContactsUpdateRecords.contactManualUpdateMicroseconds;
        }
        this.lastUpdateTimestamp = currentTimestamp;
        return this.delayNumberMicroseconds
    }

    private static mInstance: ContactsUpdateRecords | undefined = undefined;

    public static getInstance(): ContactsUpdateRecords {
        if (ContactsUpdateRecords.mInstance == undefined) {
            ContactsUpdateRecords.mInstance = new ContactsUpdateRecords()
        }
        return ContactsUpdateRecords.mInstance
    }
}



/**
 * ConversationListController中不需要触发UI刷新的属性需在此类中定义，避免不必要的UI刷性影响性能
 * 此方式是利用了@State装饰器的规则：嵌套属性的赋值观察不到
 * 用于记录RCS已经注册过的函数就不要再重新注册了。
 */
export class RcsRegisterOnProp {
    public loginStatusChanged: boolean = false;
    public networkStatusChanged: boolean = false;
    public rcsMessageStatusChanged: boolean = false;
}
