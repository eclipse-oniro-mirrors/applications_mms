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
import router from '@system.router';
import common from '../common_constants.js';
import conversationService from '../../service/ConversationService.js';
import mmsLog from '../../../default/utils/MmsLog.js';

const TAG = 'slide_detail.js ---> ';

export default {
    data: {
        mmsItem: null,
        mmsSource: [],
        isShowLine: true,
        isNeedSave: false,
        isLock: false,
        lockIcon: '/common/icon/msg_lock_two.svg',
        lockText: '',
        deleteText: '',
        threadId: 0,
        audioName: '',
        doubleClickStatus: false,
        isShowBottom: true
    },
    onInit() {
        this.audioName = common.string.AUDIO_NAME;
        this.mmsItem = this.mms;
        this.mmsSource = this.mmsItem.mms;
        if (this.mmsSource.length > 0) {
            this.setLineStatus();
            this.setSlideSubscript();
            this.setSaveButtonStatus();
        }
        if (this.isShowBottom) {
            this.initLockStatus();
        }
    },
    onShow() {
    },
    onBackPress() {
    },
    initLockStatus() {
        this.isLock = this.mmsItem.isLock;
        if(this.isLock) {
            this.lockIcon = '/common/icon/msg_unlock.svg';
            this.lockText = this.$t('strings.unlock');
            this.deleteText = this.$t('strings.msg_delete_dialog_lock');
        } else {
            this.lockIcon = '/common/icon/msg_lock_two.svg';
            this.lockText = this.$t('strings.lock');
            this.deleteText = this.$t('strings.msg_delete_dialog_tip1');
        }
    },
    setLineStatus() {
        if (this.mmsSource.length === 1) {
            this.isShowLine = false;
        } else if (this.mmsSource.length === 2) {
            let first = this.mmsSource[0];
            let second = this.mmsSource[1];
            if (first.msgType == common.MSG_ITEM_TYPE.THEME && second.msgType == common.MSG_ITEM_TYPE.TEXT) {
                this.isShowLine = false;
            }
        }
    },
    setSlideSubscript() {
        if (!this.isShowLine) {
            return;
        }
        let first = this.mmsSource[0];
        this.mmsSource.forEach((item, index) => {
            if (first.msgType == common.MSG_ITEM_TYPE.THEME) {
                if (index === 0) {
                    item.subscript = common.string.EMPTY_STR;
                } else {
                    item.subscript = index + '/' + (this.mmsSource.length - 1);
                }
            } else {
                item.subscript = (index + 1) + '/' + this.mmsSource.length;
            }
        });
    },
    setSaveButtonStatus() {
        for (let i = 0; i < this.mmsSource.length; i++) {
            let item = this.mmsSource[i];
            if (item.msgType == common.MSG_ITEM_TYPE.VIDEO ||
            item.msgType == common.MSG_ITEM_TYPE.IMAGE ||
            item.msgType == common.MSG_ITEM_TYPE.AUDIO) {
                this.isNeedSave = true;
                break;
            }
        }
    },
    back() {
        router.back();
    },
    // 转发
    transferMms() {
        router.push({
            uri: 'pages/transmit_msg/transmit_msg',
            params: {
                isSlideDetail: true,
                mmsSource: this.mmsSource
            }
        });
    },
    // 锁定
    lockMms() {
        if(this.isLock) {
            this.isLock = false;
            this.lockIcon = '/common/icon/msg_lock_two.svg';
            this.lockText = this.$t('strings.lock');
            this.deleteText = this.$t('strings.msg_delete_dialog_tip1');
        } else {
            this.isLock = true;
            this.lockIcon = '/common/icon/msg_unlock.svg';
            this.lockText = this.$t('strings.unlock');
            this.deleteText = this.$t('strings.msg_delete_dialog_lock');
        }
        this.updateLock(this.isLock);
        this.mmsItem.isLock = this.isLock;
    },
    updateLock(isLock) {
        // 选择内容锁定
        let groupIds = [this.mmsItem.groupId];
        let hasLock = isLock ? 1 : 0;
        let actionData = {
            groupIds: groupIds,
            featureAbility: this.$app.$def.featureAbility,
            hasLock: hasLock,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        conversationService.updateLock(actionData, result => {
            mmsLog.info(TAG + 'updateLock success' + result);
        });
        // 更新锁定状态
        this.updateSessionLock(isLock);
    },
    updateSessionLock(isLock) {
        let threadIds = [this.threadId];
        let hasLock = isLock ? 1 : 0;
        let valueBucket = {
            'has_lock': hasLock,
        }
        let actionData = {
            threadId: this.threadId,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        conversationService.queryMessageLockBySessionId(actionData, lockStatus => {
            if (lockStatus.length > 0 && !isLock) {
                let count = this.calculateLockCount(lockStatus);
                if (count != lockStatus.length) {
                    mmsLog.log(TAG + 'updateSessionLock, it is not all select unlock');
                    return;
                }
            }
            let conversationListService = this.$app.$def.conversationListService;
            let rdbStore = this.$app.$def.rdbStore;
            conversationListService.updateById(rdbStore, threadIds, valueBucket);
        });
    },
    calculateLockCount(lockStatus) {
        let count = 0;
        for (let element of lockStatus) {
            if (!element.isLock) {
                count ++;
            }
        }
        return count;
    },
    // 删除
    deleteMms() {
        this.$element('delete_dialog').show();
    },
    deleteCancel() {
        // 取消弹出
        this.$element('delete_dialog').close();
    },
    deleteConfirm() {
        let groupIds = [this.mmsItem.groupId];
        let actionData = {
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            groupIds: groupIds,
            featureAbility: this.$app.$def.featureAbility,
        };
        // 这里调用数据库的删除方法
        conversationService.deleteMessageByGroupIds(actionData);
        router.back();
    },
    // 保存所有
    saveAllMms() {

    },
    doubleClick(content, hasTheme) {
        if(hasTheme) {
            content = this.$t('strings.msg_theme') + ': '+content;
        }
        if (!this.doubleClickStatus) {
            this.doubleClickStatus = true;
            setTimeout(() => {
                this.doubleClickStatus = false;
            }, 500);
        } else {
            this.jumpToTextSelect(content);
        }
    },
    jumpToTextSelect(content) {
        router.push({
            uri: 'pages/text_select/text_select',
            params: {
                content: content
            }
        });
    },
}