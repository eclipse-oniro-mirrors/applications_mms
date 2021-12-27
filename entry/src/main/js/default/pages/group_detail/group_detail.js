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
import mmsLog from '../../../default/utils/MmsLog.js';
import router from '@system.router';

// JS公共常量
import common from '../common_constants.js';

// 相关接口的查询服务
import groupDetailService from '../../service/GroupDetailService.js';
import settingService from '../../service/SettingService.js';
import conversationService from '../../service/ConversationService.js';

export default {
    data: {
        // 联系人数量
        contactsNum: 0,
        // 会话列表ID
        threadId: 0,
        // 发送短信相关数据
        contactList: [],
        // 是否真正进行跳转,避免重复跳转
        isJumping: false,
        // 发送时间
        time: '',
        // 是否重新发送
        isAllSendFail: false,
        // 是否是详细信息
        isDetail: false,
        // 组ID
        groupId: 0,
        // 重发的下标
        reSendIndex: 0,
        // 重发的内容
        content: '',
        // 卡1
        slotId: 0,
        // 是否显示联系人头像
        isShowContactHeadIcon: true,
        // 全部发送总数记录
        sendAllCount: 0
    },
    onInit() {
        this.getSettingFlagForConvListPage();
    },
    onReady() {
        mmsLog.info('JS_group_detail: ' + 'onReady()......');
    },
    onShow() {
        mmsLog.info('JS_group_detail: ' + 'onShow()......');
        this.isJumping = false;
        this.contactList = [];
        this.queryContactSendDetail();
    },
    // 查询联系人列表或发送的信息详情
    queryContactSendDetail() {
        let actionData = {
            threadId: this.threadId,
            groupId: this.groupId,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            rdbStore: this.$app.$def.rdbStore
        };
        groupDetailService.queryContactSendDetail(this.isDetail, actionData, (result) => {
            let code = result.code;
            if (code == common.int.SUCCESS) {
                mmsLog.info('JS_group_detail: ' + 'queryContactSendDetail Success:' + this.isDetail);
                if (this.isDetail) {
                    this.converTime(result.contactList);
                }
                this.contactList = result.contactList;
                if(this.isDetail) {
                    this.judgeIsAllSendFail();
                }
            } else {
                mmsLog.info('JS_group_detail: ' + 'Error: queryContactSendDetail() failed !!!');
            }
        });
    },
    converTime(contactList) {
        let dateUtil = this.$app.$def.dateUtil;
        for(let item of contactList) {
            item.timeMillisecond = parseInt(item.timeMillisecond);
            dateUtil.convertTimeStampToDateWeek(item, true, this);
            dateUtil.convertDateFormatForItem(item, true, this);
        }
    },
    // 统计发送失败的数量
    judgeIsAllSendFail() {
        groupDetailService.judgeIsAllSendFail(this.contactList, (isAllSendFail) => {
            this.isAllSendFail = isAllSendFail;
        });
    },
    titleBarBack() {
        router.back();
    },
    // 点击头像跳转至联系人详情页面
    clickToContactDetail(index) {
        if (this.isJumping) {
            return;
        }
        this.isJumping = true;
        let actionData = {};
        actionData.phoneNumber = this.contactList[index].telephone;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
        // 跳转联系人详情页面
        this.jumpToContract(actionData);
    },
    // 全部重新发送
    resendAll() {
        let telephones = [];
        let that = this;
        let contractListTemp = [];
        let contractListReal = [];
        this.contactList.forEach(function (item) {
            if (item.sendStatus == common.int.SEND_MESSAGE_FAILED) {
                telephones.push(item.telephone);
                item.sendStatus = common.int.SEND_MESSAGE_SENDING;
                // 将状态更新为正在发送
                that.updataItemStatus(item.id, 2);
                contractListTemp.push(item);
            } else {
                contractListReal.push(item);
            }
        });
        // 将正在发送的数据，放到列表的第一位
        contractListReal.forEach(function (item) {
            contractListTemp.push(item);
        });
        // 获取数据判断图标是否展示
        this.judgeIsAllSendFail();
        // 排序后的数据
        this.contactList = contractListTemp;
        // 进行群组发送
        if (telephones && telephones.length > 0) {
            for (let telephone of telephones) {
                this.resendSms(telephone, that.content, telephones.length);
            }
        }
    },
    // 发送按钮点击取消按钮取消对话框
    cancelResend() {
        this.$element('mms_fail_dialog').close();
        this.reSendIndex = 0;
    },
    // 点击重新发送按钮发送
    resend() {
        this.contactList[this.reSendIndex].time = this.$t('strings.just');
        this.contactList[this.reSendIndex].sendStatus = 1;
        let item = this.contactList[this.reSendIndex];
        let telephone = this.contactList[this.reSendIndex].telephone;
        // 获取数据判断图标是否展示
        this.judgeIsAllSendFail();
        this.$element('mms_fail_dialog').close();
        // 将状态更新为正在发送
        this.updataItemStatus(item.id, 2);
        this.resendSms(telephone, this.content, 1);
    },
    resendSms(destinationHost, content, telephonesLength) {
        mmsLog.info('resendSms,start');
        let params = {
            slotId: this.slotId,
            destinationHost: destinationHost,
            content: content
        };
        let sendMsgService = this.$app.$def.sendMsgService;
        sendMsgService.sendMessage(params, (sendStatus) => {
            // 处理发送的结果
            this.dealSendResult(sendStatus, params.destinationHost);
            this.sendAllCount ++;
            if (this.sendAllCount === telephonesLength) {
                // 获取数据判断图标是否展示
                this.judgeIsAllSendFail();
                this.sendAllCount = 0;
            }
        });
    },
    // 点击失败图片，唤起dialog
    resendOpen(index) {
        this.$element('mms_fail_dialog').show();
        this.reSendIndex = index;
    },
    dealSendResult(result, telephone) {
        mmsLog.info('dealSendResult,result:' + result);
        this.contactList.forEach((item) => {
            if (item.telephone == telephone) {
                item.sendStatus = result;
                let sendStatus = result;
                if(item.sendStatus == common.int.SEND_MESSAGE_FAILED) {
                    sendStatus = 1;
                } else if(item.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
                    sendStatus = 0;
                } else {
                    sendStatus = 2;
                }
                this.updataItemStatus(item.id, sendStatus);
            }
        });
    },
    updataItemStatus(id, sendStatus) {
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            msgId: id,
            sendStatus: sendStatus
        }
        conversationService.updateById(actionData, res => {
            mmsLog.log('updateById,result:' + JSON.stringify(res));
        });
    },
    // 获取整合通知信息和显示联系人头像的开关值
    getSettingFlagForConvListPage() {
        let preferences = this.$app.$def.preferences;
        let result = settingService.getSettingFlagForConvListPage(preferences);
        if (result) {
            this.isShowContactHeadIcon = result.isShowContactHeadIcon;
        }
    },
    // 跳转联系人app
    jumpToContract(actionData) {
        var str = {
            'want': {
                'bundleName': common.string.CONTRACT_BUNDLE_NAME,
                'abilityName': common.string.CONTRACT_ABILITY_NAME,
                'parameters': actionData,
                'entities': [
                    common.string.COMMON_ENTITIES
                ]
            },
        };
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info('JS_group_detail jumpToContract Data' + data);
        }).catch((error) => {
            mmsLog.error('JS_group_detail jumpToContract failed: ' + JSON.stringify(error));
        })
    },
}