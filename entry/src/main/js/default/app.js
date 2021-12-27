/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import mmsLog from '../default/utils/MmsLog.js';
import featureAbility from '@ohos.ability.featureAbility';
import ohosDataAbility from '@ohos.data.dataability';
import sendMsgService from '../default/service/SendMsgService.js';
import conversationListService from '../default/service/ConversationListService.js';
import notificationService from '../default/service/NotificationService.js';
import commonService from '../default/service/CommonService.js';
import rdbStore from '../default/utils/RdbStoreUtil.js';
import dateUtil from '../../js/default/pages/DateUtil.js';
import preferences from '../default/utils/PreferencesUtil.js';

const TAG = 'app.js->';

export default {
    globalData: {
        // 是否展示通知信息
        hasInfoMsg: true,
    },
    onCreate() {
        mmsLog.info(TAG + 'onCreate(): start, AceApplication onCreate');
        mmsLog.info(TAG + 'onCreate(): end, AceApplication onCreate');
    },
    onDestroy() {
        mmsLog.info(TAG + 'onDestroy(): AceApplication onDestroy');
    },
    // full_screen_show_picture页面中图片或视频的index
    indexInShowPicPage: null,
    // full_screen_show_picture页面中图片或视频的checkbox的值
    checkedValueInShowPicPage: null,
    // contact_item_pick页面中的电话号码列表
    oneContactInContactItemPickPage: null,
    // 全屏发送值
    textValueOther: '',
    // 全屏发送标记
    sendFlag: false,
    // 转发发送的标记
    transmitFlag: false,
    // 转发内容
    transmitContent: '',
    // 转发的内容包含彩信
    transmitContents: [],
    isSlideDetail: false,
    mmsSource: [],
    transmitSource: [],
    isContainerOriginSource: false,
    // 卡的槽位
    slotId: 0,
    // 列表Id
    threadId: '',
    // 联系人数量
    contactsNum: 0,
    // 联系人名称
    strContactsName: '',
    // 联系人号码
    strContactsNumber: '',
    // 格式化联系人号码
    strContactsNumberFormat: '',
    // 跳转三方应用使用
    featureAbility: featureAbility,
    // 查询数据库使用
    ohosDataAbility: ohosDataAbility,
    // 发送短信的服务
    sendMsgService: sendMsgService,
    // 消息通知
    notificationService: notificationService,
    // 列表数据查询
    conversationListService: conversationListService,
    // 公共的服务处理
    commonService: commonService,
    // 数据库操作
    rdbStore: rdbStore,
    // 时间类转化
    dateUtil: dateUtil,
    // 是否从全屏界面回来
    isFromFullScreen: false,
    // 偏量数据库
    preferences: preferences
};
