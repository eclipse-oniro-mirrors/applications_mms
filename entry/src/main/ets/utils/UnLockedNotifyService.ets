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
import myCommon from '@ohos.app.ability.common';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import common from '../data/commonData';
import HiLog from '../utils/HiLog';
import { JSON, taskpool } from '@kit.ArkTS';
import DataShareHelper from '../model/repository/DataShareHelper';
import { BusinessError, commonEventManager, settings} from '@kit.BasicServicesKit';
import LooseObject from '../data/LooseObject';
import { DataParameters } from '../utils/TypesUtils';
import { notificationManager } from '@kit.NotificationKit';
import commonData from '../data/commonData';

const TAG: string = 'UnLockedNotifyService'

export class UnLockedNotifyService {
    // 跟随后端， 如果数据解锁后存储路径为EL5, 设置为true， 存储路径为EL1时为false
    public dataIsMoveEL5: boolean = true
    private static _instance: UnLockedNotifyService | null = null

    private constructor() {
    }

    public static getInstance(): UnLockedNotifyService {
        if (UnLockedNotifyService._instance == null) {
            UnLockedNotifyService._instance = new UnLockedNotifyService()
        }
        return UnLockedNotifyService._instance
    }

    public processMessageUserLocked(context: Context) {
        //  前台启动，强制取消匿名通知。避免糟糕的用户体验
        this.cancelFirstUnlockedNotify();
        //  是否收到过匿名通知
        let value =
            settings.getValueSync(context, commonData.STR.RECEIVE_MESSAGE_USER_LOCK, commonData.bool.NOT_SET);
        HiLog.i(TAG, `settings.mms.receive_message_user_unlock =  ${value}`)
        if (value === commonData.bool.TRUE) {
            // 发布系统事件usual.event.SMS_RECEIVE_COMPLETED, 并携带固定data标志此场景
            let options: commonEventManager.CommonEventPublishData = {
                data: commonData.STR.RECEIVE_MESSAGE_USER_LOCK, // 公共事件的初始数据
            };
            try {
                commonEventManager.publish(commonData.STR.SUBSCRIBER_EVENT, options, (err: BusinessError) => {
                    if (err) {
                        HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
                        return;
                    }
                    settings.setValueSync(context, commonData.STR.RECEIVE_MESSAGE_USER_LOCK, commonData.bool.FALSE);
                    HiLog.i(TAG, `Succeeded in publishing common event.`);
                });
            } catch (error) {
                let err: BusinessError = error as BusinessError;
                HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
            }
        }
    }

    // 首次开机未解锁前收到信息，发送匿名通知
    async sendFirstLockReceiveNotify(data: DataParameters, context: Context) {
        HiLog.i(TAG, 'send first lock receive notify')
        // 存储原始数据和时间
        data.deliveryTime = Date.now()
        data.isFirstUnlocked = true
        let notificationRequest: notificationManager.NotificationRequest = {
            id: -100,  // 匿名通知只留一条
            content: {
                notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
                normal: {
                    // 不能为空数据，否则没提示横幅。数据解析后会重新发送通知
                    title: context?.resourceManager.getStringSync($r('app.string.user_lock_message_title')),
                    text: context?.resourceManager.getStringSync($r('app.string.user_lock_message_content'))
                }
            },
            notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
            deliveryTime: data.deliveryTime,
            groupName: common.STR.KEY_OF_MMS_SCREEN_LOCKED_NOTIFICATION_GROUP,
        }
        notificationManager.publish(notificationRequest).then(() => {
            HiLog.i(TAG, 'Succeeded unlocked publishing notification.');
        }).catch((error: BusinessError) => {
            HiLog.e(TAG, `Failed to publish unlocked notification. Code is ${error.code}, message is ${error.message}`);
        });
        // 存储pdu
        let unLockedNotifyModel: ValuesBucket = {
            'pdu_content': JSON.stringify(data)
        }
        UnLockedNotifyService.getInstance().insertUnLockedNotify(unLockedNotifyModel, () => {}, context)
    }

    // 取消匿名通知
    async cancelFirstUnlockedNotify() {
        HiLog.i(TAG, 'cancel nick notify')
        notificationManager.cancelGroup(common.STR.KEY_OF_MMS_SCREEN_LOCKED_NOTIFICATION_GROUP).then(() => {
            HiLog.i(TAG, 'Succeeded to cancel nick notification.');
        }).catch((error: BusinessError) => {
            HiLog.e(TAG, `Failed to cancel nick notification. Code is ${error.code}, message is ${error.message}`);
        })
    }

    // 增加未解锁来的通知
    public insertUnLockedNotify(valueBucket: ValuesBucket, callback: Function, context: Context) {
        HiLog.i(TAG, 'insert first unlocked notification start')
        let mmsContext: Context =
            context ? context : GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext
        let task: taskpool.Task = new taskpool.Task(insertUnLockedNotify, valueBucket, mmsContext)
        taskpool.execute(task).then((value: Object) => {
            HiLog.i(TAG, 'insert first no locked result: ' + JSON.stringify(value))
            callback(value)
        }).catch((error: BusinessError) => {
            HiLog.e(TAG, `insert first unlocked error info : ${error.code} message: ${error.message}`)
        })
    }

    // 删除未解锁来的通知
    public deleteUnLockedNotify(callback: Function, context?: Context) {
        HiLog.i(TAG, 'delete first unlocked notification start')
        let mmsContext: Context =
            context ? context : GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext
        let task: taskpool.Task = new taskpool.Task(deleteUnLockedNotify, mmsContext);
        taskpool.execute(task).then((value: Object) => {
            HiLog.i(TAG, 'delete first unlocked result: ' + JSON.stringify(value))
            callback(value)
        }).catch((error: BusinessError) => {
            HiLog.e(TAG, `delete first unlocked error info : ${error.code} message: ${error.message}`)
        })
    }

    // 查询未解锁来的通知
    public queryUnLockedNotify(callback: Function, context?: Context) {
        HiLog.i(TAG, 'query first unlocked notification start')
        let mmsContext: Context =
            context ? context : GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext
        let task: taskpool.Task = new taskpool.Task(queryUnLockedNotify, mmsContext,
            common.STR.URI_MESSAGE_FIRST_UNLOCKED_TABLE)
        taskpool.execute(task).then((value1: LooseObject) => {
            let list1 = value1.data as DataParameters[]
            HiLog.i(TAG, `query first unlocked success, list1 length = ${list1.length}`)
            let task2: taskpool.Task = new taskpool.Task(queryUnLockedNotify, mmsContext,
                common.STR.URI_MESSAGE_FIRST_UNLOCKED_TABLE2)
            taskpool.execute(task2).then((value2: LooseObject) => {
                let list2 = value2.data as DataParameters[];
                HiLog.i(TAG, `query first unlocked success, list2 length = ${list2.length}`)
                const list3 = [...list1, ...list2].filter((item, index, self) =>
                    index === self.findIndex((t) => (
                        JSON.stringify(t) === JSON.stringify(item)
                    ))
                );
                // list1 list2 去重后返回list3
                HiLog.i(TAG, `query first unlocked success, list3 length = ${list3.length}`)
                callback(list3)
            }).catch((error: BusinessError) => {
                HiLog.e(TAG, `query first unlocked2 error info : ${error.code} message: ${error.message}`)
            })
        }).catch((error: BusinessError) => {
            HiLog.e(TAG, `query first unlocked1 error info : ${error.code} message: ${error.message}`)
        })
    }
}

@Concurrent
// 添加从未解锁过来的短信通知列表
async function insertUnLockedNotify(valueBucket: ValuesBucket, context: Context) {
    HiLog.i('UnLockedNotifyService', 'insertFirstUnLockedNotify start');
    let result: LooseObject = {};
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
        HiLog.e('UnLockedNotifyService', 'insertFirstUnLockedNotifyModel createDataShareHelper fail');
        result.code = common.int.FAILURE;
        return result;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_FIRST_UNLOCKED_TABLE;
    dataHelper.insert(managerUri, valueBucket).then(() => {
        HiLog.i('UnLockedNotifyService', 'insertFirstUnLockedNotify, success');
        result.code = common.int.SUCCESS;
        return result;
    }).catch((error: BusinessError) => {
        HiLog.e('UnLockedNotifyService', 'insertFirstUnLockedNotify fail, error: ' + JSON.stringify(error));
        return result;
    });
    return result;
}
@Concurrent
// 删除从未解锁过来的短信通知列表
async function deleteUnLockedNotify(context: Context) : Promise<LooseObject> {
    let result: LooseObject = {};
    try {
        HiLog.i('UnLockedNotifyService', 'deleteFirstUnLockedNotify start');
        let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
        if (!dataHelper) {
            HiLog.e('UnLockedNotifyService', 'deleteFirstUnLockedNotify createDataShareHelper fail');
            result.code = common.int.FAILURE;
            return result;
        }
        dataHelper = dataHelper as dataShare.DataShareHelper;
        let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_FIRST_UNLOCKED_TABLE;
        await dataHelper.delete(managerUri, condition);
        HiLog.i('UnLockedNotifyService', 'deleteFirstUnLockedNotify1, success');

        let condition2: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        let managerUri2: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_FIRST_UNLOCKED_TABLE2;
        await dataHelper.delete(managerUri2, condition2);
        HiLog.i('UnLockedNotifyService', 'deleteFirstUnLockedNotify2, success');
        result.code = common.int.SUCCESS;
        return result;
    } catch (err) {
        HiLog.e('UnLockedNotifyService', `deleteFirstUnLockedNotify, error ${err.code} ${err.message}`);
        result.code = common.int.FAILURE;
        return result;
    }
}

@Concurrent
// 查询从未解锁过来的短信通知列表
async function queryUnLockedNotify(context: Context, table: string) {
    HiLog.i('UnLockedNotifyService', 'queryFirstUnLockedNotify start');
    let result: LooseObject = {};
    // 首次解锁场景，负载重，小概率默认2s拉不起数据库进程。这里设置10s。
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context, 10); // 10s
    if (!dataHelper) {
        HiLog.e('UnLockedNotifyService', 'queryFirstUnLockedNotify createDataShareHelper fail')
        result.code = common.int.FAILURE;
        return result;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull('pdu_content');
    let managerUri: string = common.STR.URI_MESSAGE_LOG + table;
    let resultSet: void | DataShareResultSet;
    try {
        resultSet = await dataHelper.query(managerUri, condition, ['*'])
    } catch (error) {
        HiLog.e('UnLockedNotifyService', 'queryFirstUnLockedNotify, fail, error: ' + JSON.stringify(error));
    }
    if (!resultSet) {
        HiLog.e('UnLockedNotifyService', 'queryFirstUnLockedNotify resultSet is null');
        result.code = common.int.FAILURE;
        return result;
    }
    let unlockedNotifications: DataParameters[] = []
    while (resultSet.goToNextRow()) {
        const unlockedNotificationStr = resultSet.getString(resultSet.getColumnIndex('pdu_content'));
        try {
            const unlockedNotification = JSON.parse(unlockedNotificationStr) as DataParameters
            if (unlockedNotification && unlockedNotification.parameters) {
                unlockedNotifications.push(unlockedNotification)
            }
        } catch (e) {
            HiLog.e('UnLockedNotifyService', 'queryFirstUnLockedNotify JSON.parse error');
        }
    }
    resultSet.close();
    result.code = common.int.SUCCESS;
    result.data = unlockedNotifications;
    HiLog.i('UnLockedNotifyService', 'queryFirstUnLockedNotify success');
    return result;
}