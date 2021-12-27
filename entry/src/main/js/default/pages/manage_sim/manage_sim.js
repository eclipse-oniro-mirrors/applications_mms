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
import cardService from '../../service/SimCardService.js';
import Prompt from '@system.prompt';
import settingService from '../../service/SettingService.js';
import conversationService from '../../service/ConversationService.js';

const TAG = 'JS->manage.js->';

// 取消全选模式
const CANCEL_ALL_CHECKED = 0;
// 全选模式
const ALL_CHECKED = 1;
// 统计被选模式
const COMPUTED_CHECKED = 2;

export default {
    data: {
        // 内容
        content: '',
        // sim卡号
        index: null,
        // sim卡数量
        simCount: null,
        // 选中信息数量
        selectMsgCount: 0,
        // 被选中的数据
        mmCheckedList: [],
        // 展示内容
        simMessageList: [],
        hasCheckboxStatus: false,
        allShow: false,
        shareList: [],
        searchContent: ''
    },
    onInit() {
        this.index = this.idx;
        this.simCount = this.countOfSim;
    },
    onShow() {
        this.$element('reset').show();
        this.getMsgFromSimCard();
        this.shareList = [
            {
                text: '新建联系人'
            },
            {
                text: '保存至已有联系人'
            }
        ];
    },
    // 获取SIM卡内的内容
    getMsgFromSimCard() {
        mmsLog.info(TAG + 'getMsgInSimCard(): start');
        let actionData = {};
        actionData.simCount = this.simCount;
        actionData.index = this.index;
        let that = this;
        let dateUtil = this.$app.$def.dateUtil;
        cardService.queryMessageInSimCard(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info(TAG + 'getMsgInSimCard(): success');
                let simMessageList = [];
                for (let item of  result.abilityResult) {
                    dateUtil.convertTimeStampToDateWeek(item, true, that);
                    dateUtil.convertDateFormatForItem(item, true, that);
                    simMessageList.push(item);
                }
                that.simMessageList = simMessageList;

                mmsLog.info(TAG + 'getMsgInSimCard(): fail, simMessageList = ' + simMessageList);
                that.$element('reset').close();
            } else {
                mmsLog.info(TAG + 'getMsgInSimCard(): fail, abilityResult = ' + result.abilityResult);
            }
        });
    },
    onBackPress() {
        if (this.hasCheckboxStatus) {
            this.singleMsgCancelBack();
            return true;
        }
        return false;
    },
    mmsListLongPress(index) {
        if (this.hasCheckboxStatus) {
            return;
        }
        this.longPressIndex = index;
        let item = this.simMessageList[this.longPressIndex]
        if (!item.isMsm) {
            this.$element('menu_long_press').show({
                x: this.touchX,
                y: this.touchY
            });
        } else {
            let msgType = item.msgType;
            if (msgType.indexOf(0) == -1) {
                this.$element('menu_long_press_mms').show({
                    x: this.touchX,
                    y: this.touchY
                });
            } else {
                this.$element('menu_long_press_mms_sms').show({
                    x: this.touchX,
                    y: this.touchY
                });
            }

        }
    },
    // 获取屏幕坐标
    touchStart(e) {
        this.touchX = e.touches[0].globalX;
        this.touchY = e.touches[0].globalY;
    },
    // 长按工具栏选择
    longPressSelected(e) {
        if (this.hasCheckboxStatus) {
            return;
        }
        let value = e.value;
        let element = this.simMessageList[this.longPressIndex];
        switch (value) {
            case '0':
            // 复制到手机
                element.isCbChecked = !element.isCbChecked;
                this.copyToPhone();
                break;
            case '1':
            // 删除
                element.isCbChecked = !element.isCbChecked;
                this.selectMsgCount = 1;
                this.$element('delete_dialog').show();
                break;
            case '2':
            // 添加到联系人
                element.isCbChecked = !element.isCbChecked;
                this.addContactsDialog();
                break;
            case '3':
                this.more(this.longPressIndex);
                break;
            default:
                mmsLog.info(TAG + 'longPressSelected, code is exit');
        }
    },
    clickGroupCopy() {
        // 将数据复制到数据库中
        this.copyToPhone();
        this.hasCheckboxStatus = false;
    },
    // 删除
    clickGroupDelete() {
        if (this.selectMsgCount == 0) {
            return;
        }
        this.$element('delete_dialog').show();
    },
    // 批量删除
    deleteDialogConfirm() {
        let actionData = {};
        this.simMessageList.forEach(element => {
            if (element.isCbChecked) {
                actionData.index = this.index;
                actionData.indexOnSim = element.indexOnSim;
                cardService.delSimMessage(actionData);
            }
        });

        for (let i = 0; i < this.selectMsgCount; i++) {
            this.simMessageList.splice(this.simMessageList.findIndex(item => item.isCbChecked), 1);
        }
        this.$element('delete_dialog').close();
        this.singleMsgCancelBack();
    },
    deleteDialogCancel() {
        this.$element('delete_dialog').close()
    },
    // 复制至手机
    copyToPhone() {
        // 选中SIM卡中的短信，复制到数据库中
        let simMessageMap = new Map();
        for (let element of this.simMessageList) {
            if (element.isCbChecked) {
                let sendResult = {
                    telephone: element.address,
                    content: element.content,
                    sendStatus: common.int.SEND_MESSAGE_SUCCESS,
                    time: element.timeMillisecond,
                    isMessageSim: true
                }
                if (simMessageMap.has(element.address)) {
                    let sendResults = simMessageMap.get(element.address);
                    sendResults.push(sendResult);
                } else {
                    let sendResults = [];
                    sendResults.push(sendResult);
                    simMessageMap.set(element.address, sendResults);
                }
            }
        }
        let actionData = {
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            sendResults: [],
            ownNumber: common.string.EMPTY_STR,
            isSender: 1,
            hasDraft: this.isDraft
        }
        // 分组之后入库
        let telephoneKeys = simMessageMap.keys();
        for (let key of telephoneKeys) {
            let sendResults = simMessageMap.get(key);
            actionData.sendResults = sendResults;
            mmsLog.info('insertManageSimData, param:' + actionData);
            conversationService.insertManageSimData(actionData, res => {
                mmsLog.info('insertManageSimData, result:' + JSON.stringify(res));
            });
        }
        Prompt.showToast({
            message: this.$t('strings.message_copied_to_phone'),
            duration: 2000,
            bottom: '150px'
        });
    },
    more(longPressIndex) {
        let item = this.simMessageList[longPressIndex];
        // 设置选中标记
        item.isCbChecked = !item.isCbChecked;
        this.hasCheckboxStatus = true;
        // 获取选中的列表
        this.computedCheckedMsgCount(COMPUTED_CHECKED);
    },
    // 列表选择勾选
    listCheckBoxChange(index, e) {
        this.simMessageList[index].isCbChecked = e.checked;
        this.computedCheckedMsgCount(COMPUTED_CHECKED);
    },
    singleMsgCancelBack() {
        this.hasCheckboxStatus = false;
        this.computedCheckedMsgCount(CANCEL_ALL_CHECKED);
    },
    // 全选
    clickGroupCheckAll() {
        mmsLog.info('computedCheckedMsgCount, code is exit')
        if (this.selectMsgCount === this.simMessageList.length) {
            this.computedCheckedMsgCount(CANCEL_ALL_CHECKED);
            this.simMessageList.forEach((val, index) => {
                val.isCbChecked = false;
            })
        } else {
            this.computedCheckedMsgCount(ALL_CHECKED)
        }
    },
    computedCheckedMsgCount(isSelect) {
        switch (isSelect) {
            case 0:
                this.cancelAllSelect();
                break;
            case 1:
                this.allSelect();
                break;
            case 2:
                this.calculateChecked(false);
                break;
            default:
                mmsLog.info(TAG + 'computedCheckedMsgCount, code is exit');
        }
    },
    moreSelected(e) {
        let value = e.value
        switch (value) {
            case '1':
                this.addContactsDialog();
                break
            default:
                mmsLog.info('moreSelected, code is exit')
        }
    },

    addContactsDialog() {
        this.$element('shareDialog').show();
    },

    shareCancelClick() {
        this.$element('shareDialog').close();
    },

    jumpClick(idx) {
        let number = common.string.EMPTY_STR;
        switch (idx) {
            case 0:
                this.shareCancelClick();
                number = this.simMessageList[this.longPressIndex].address;
                this.createNewContract(number);
                break;
            case 1:
                this.shareCancelClick();
                number = this.simMessageList[this.longPressIndex].address;
                this.existingContact(number);
                break;
            default:
                break;
        }
    },
    // 新建联系人
    createNewContract(number) {
        var actionData = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_CONTACT;
        this.jumpToContract(actionData);
    },

    // 保存联系人
    existingContact(number) {
        var actionData = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_EXIST_CONTACT;
        this.jumpToContract(actionData);
    },

    // 跳转联系人app
    jumpToContract(actionData) {
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info('manage_sim.js --> Data: ' + data);
        }).catch((error) => {
            mmsLog.error('manage_sim.js --> failed: ' + JSON.stringify(error));
        })
    },

    allSelect() {
        for (let mms of this.simMessageList) {
            mms.isCbChecked = true;
        }
        this.calculateChecked(true);
    },
    // 取消全选
    cancelAllSelect() {
        for (let mms of this.simMessageList) {
            mms.isCbChecked = false;
        }
        this.selectMsgCount = 0;
        this.mmCheckedList = [];
    },
    // 计算被选中的值
    calculateChecked(isAllSelect) {
        let result = settingService.calculateChecked(this.simMessageList, isAllSelect);
        if (result) {
            this.selectMsgCount = result.count;
            this.mmCheckedList = result.checkedList;
            if (result.count == 1) {
                this.longPressIndex = this.simMessageList((val, index) => val.isCbChecked);
            }
            this.allShow = false;
            if (this.selectMsgCount == this.simMessageList.length) {
                this.allShow = true;
            }
        }
    },
    resetBack() {
        this.resetBack = false;
    },
    back() {
        router.back();
    },
    singleMsgBack() {
        router.back();
    }
}
