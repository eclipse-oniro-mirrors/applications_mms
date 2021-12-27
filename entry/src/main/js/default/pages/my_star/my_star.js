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
import prompt from '@system.prompt';
import myStatService from '../../service/MyStarService.js';
import cardService from '../../service/SimCardService.js';
import conversationService from '../../service/ConversationService.js';
import contactService from '../../service/ContractService.js';
// JS公共常量
import common from '../common_constants.js';
// 取消全选模式
const CANCEL_ALL_CHECKED = 0;
// 全选模式
const ALL_CHECKED = 1;
// 统计被选模式
const COMPUTED_CHECKED = 2;
const PRE_LOG = 'favorite page: ';

export default {
    data: {
        // 数据回传标识
        hasDataEcho: false,
        // 进入选中状态标识
        hasCheckboxStatus: false,
        // 选中信息数量
        selectMsgCount: 0,
        // 选中信息带有文本数量
        selectMsgTextCount: 0,
        // 选中信息为彩信数量
        selectMsgMmsCount: 0,
        // 信息列表
        mmsList: [],
        // 是否是双卡
        hasDoubleCard: false,
        // 被选中的数据
        mmCheckedList: [],
        // 收藏信息被全部选中的状态
        allShow: false,
        // 总数
        total: 0,
        // 列表分页，页数
        page: 0,
        // 列表分页，数量
        limit: 15,
        // 是否展示选择文本
        hasSelectTextShow: false,
        isCheckDeleted: false,
        searchContent: ''
    },
    onShow() {
        // 获取电话卡信息
        this.getTelephoneCardInfo();
    },
    requestItem() {
        let count = this.page * this.limit;
        if (this.page === 0) {
            this.page++;
            this.queryFavoriteMessageList();
        } else if (count < this.total && this.contacts.length > (this.page - 1) * this.limit) {
            // 对Contacts的限制，是防止初始化时多次刷新请求
            this.page++;
            this.queryFavoriteMessageList();
        }
    },
    // 获取收藏信息列表
    queryFavoriteMessageList() {
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            page: this.page,
            limit: this.limit,
            hasCollect: 1
        }
        let that = this;
        let dateUtil = this.$app.$def.dateUtil;
        myStatService.queryFavoriteMessageList(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info('queryFavoriteMessageList,success');
                let res = [];
                for (let item of result.response) {
                    item.timeMillisecond = parseInt(item.timeMillisecond);
                    dateUtil.convertDateFormatForItem(item, true, that);
                    that.dealMessageDetailContent(item);
                    res.push(item);
                }
                that.mmsList = that.mmsList.concat(res);
                that.total = result.total;
            } else {
                mmsLog.info(PRE_LOG + 'Error: queryFavoriteMessageList() failed !!!');
            }
            that.hasDataEcho = true;
        });
    },
    dealMessageDetailContent(star) {
        if (star.msgShowType === common.MESSAGE_SHOW_TYPE.THEME_NO_IMAGE ||
        star.msgShowType == common.MESSAGE_SHOW_TYPE.THEME_IMAGE) {
            if (star.content !== common.string.EMPTY_STR) {
                star.content = this.$t('strings.msg_theme') + ': ' + star.content;
            }
        } else if (star.msgShowType === common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE) {
            star.content = (star.content == common.string.EMPTY_STR) ? this.$t('strings.msg_slide') : star.content;
        } else if (star.msgShowType === common.MESSAGE_SHOW_TYPE.PPT_IMAGE) {
            let mmsSource = star.mms;
            if (mmsSource[0].msgType == common.MSG_ITEM_TYPE.THEME && star.content !== common.string.EMPTY_STR) {
                star.content = this.$t('strings.msg_theme') + ': ' + star.content;
            } else {
                star.content = (star.content == common.string.EMPTY_STR) ? this.$t('strings.msg_slide') : star.content;
            }
        }
    },
    // 获取电话卡信息
    getTelephoneCardInfo() {
        let cardNumber = cardService.initSimCardNum();
        if (cardNumber == common.int.SIM_COUNT) {
            this.hasDoubleCard = true;
        } else {
            this.hasDoubleCard = false;
        }
    },
    onBackPress() {
        if (this.hasCheckboxStatus) {
            this.singleMsgCancelBack();
            return true;
        }
        return false;
    },
    // 获取屏幕坐标
    touchStart(e) {
        this.touchX = e.touches[0].globalX;
        this.touchY = e.touches[0].globalY;
    },
    // 长按信息触发
    mmsListLongPress(index) {
        if (this.hasCheckboxStatus) {
            return;
        }
        this.longPressIndex = index;
        let item = this.mmsList[this.longPressIndex];
        if (item.isMsm) {
            // 判断彩信是否包含文本
            let commonService = this.$app.$def.commonService;
            if (commonService.judgeIsSelectText(item.mms)) {
                this.$element('menu_long_press_mms_sms').show({
                    x: this.touchX,
                    y: this.touchY
                });
            } else {
                this.$element('menu_long_press_mms').show({
                    x: this.touchX,
                    y: this.touchY
                });
            }
        } else {
            this.$element('menu_long_press').show({
                x: this.touchX,
                y: this.touchY
            });
        }
    },
    // 长按工具栏选择
    longPressSelected(e) {
        let value = e.value;
        let item = this.mmsList[this.longPressIndex];
        switch (value) {
            case '0':
            // 复制
                item.isCbChecked = !item.isCbChecked;
                this.computedCheckedMsgCount(COMPUTED_CHECKED);
                this.clickGroupCopy();
                break;
            case '1':
            // 转发
                item.isCbChecked = !item.isCbChecked;
                this.computedCheckedMsgCount(COMPUTED_CHECKED);
                this.clickGroupTransmit();
                item.isCbChecked = !item.isCbChecked;
                this.computedCheckedMsgCount(COMPUTED_CHECKED);
                break;
            case '2':
            // 删除
                this.isCheckDeleted = false;
                item.isCbChecked = !item.isCbChecked;
                this.computedCheckedMsgCount(COMPUTED_CHECKED);
                this.clickGroupDelete();
                break;
            case '3':
            // 选择文本
                item.isCbChecked = !item.isCbChecked;
                this.computedCheckedMsgCount(COMPUTED_CHECKED);
                this.longIntentTextSelect(item);
                item.isCbChecked = !item.isCbChecked;
                this.computedCheckedMsgCount(COMPUTED_CHECKED);
                break;
            case '4':
            // 更多
                this.more(this.longPressIndex);
                break;
            case '5':
            // 保存图片
                item.isCbChecked = !item.isCbChecked;
                this.computedCheckedMsgCount(COMPUTED_CHECKED);
                try {
                    this.saveImage();
                } catch {
                    mmsLog.error(e);
                } finally {
                    item.isCbChecked = !item.isCbChecked;
                    this.computedCheckedMsgCount(COMPUTED_CHECKED);
                }
                break;
            default:
                mmsLog.info('longPressSelected, code is exit');
        }
    },
    moreSelected(e) {
        let value = e.value
        switch (value) {
            case '1':
                this.longTextSelect();
                break;
            case '2':
                this.favoriteShare();
                break;
            default:
                mmsLog.info('moreSelected, code is exit');
        }
    },
    longTextSelect() {
        this.computedCheckedMsgCount(COMPUTED_CHECKED);
        let item = this.mmsList[this.longPressIndex];
        this.intentTextSelect(item);
    },
    intentTextSelect(item) {
        let param = JSON.parse(JSON.stringify(item));
        if(param.isMsm) {
            let content = common.string.EMPTY_STR;
            let count = 0;
            let length = param.mms.length;
            for(let item of param.mms) {
                if(common.MSG_ITEM_TYPE.TEXT == item.msgType) {
                    content = content + item.content;
                } else if(common.MSG_ITEM_TYPE.THEME == item.msgType) {
                    content = content + this.$t('strings.msg_theme')+': ' + item.content;
                } else if((common.MSG_ITEM_TYPE.IMAGE == item.msgType || common.MSG_ITEM_TYPE.AUDIO == item.msgType
                || common.MSG_ITEM_TYPE.VIDEO == item.msgType) && item.content !== common.string.EMPTY_STR) {
                    content = content + item.content;
                }
                count ++;
                if(count < length) {
                    content = content + '\n';
                }
            }
            param.content = content;
        }
        this.jumpToTextSelect(param);
    },
    // 列表选择勾选
    listCheckBoxChange(index, e) {
        let item = this.mmsList[index];
        item.isCbChecked = e.checked;
        this.computedCheckedMsgCount(COMPUTED_CHECKED);
        this.setHasSelectTextShow(item);
        if(!item.isCbChecked && this.mmCheckedList.length == 1) {
            this.setHasSelectTextShow(this.mmCheckedList[0]);
        }
    },
    setHasSelectTextShow(item) {
        if(item.isCbChecked && item.isMsm) {
            let commonService = this.$app.$def.commonService;
            this.hasSelectTextShow = commonService.judgeIsSelectText(item.mms);
        } else if(!item.isMsm && item.isCbChecked) {
            this.hasSelectTextShow = true;
        } else {
            this.hasSelectTextShow = false;
        }
    },
    singleMsgCancelBack() {
        this.hasCheckboxStatus = false;
        this.hasSelectTextShow = false;
        this.computedCheckedMsgCount(CANCEL_ALL_CHECKED);
    },
    computedCheckedMsgCount(status) {
        switch (status) {
            case 0:
                this.cancelSelectAll();
                break;
            case 1:
                this.selectAll();
                break;
            case 2:
                this.calculateChecked(false);
                break;
            default:
                mmsLog.info('computedCheckedMsgCount, code is exit')
        }

    },
    selectAll() {
        for (let mms of this.mmsList) {
            mms.isCbChecked = true;
        }
        this.calculateChecked(true);
    },
    // 取消全选
    cancelSelectAll() {
        for (let mms of this.mmsList) {
            mms.isCbChecked = false;
        }
        this.selectMsgCount = 0;
        this.selectMsgTextCount = 0;
        this.selectMsgMmsCount = 0;
        this.mmCheckedList = [];
    },
    // 计算被选中的值
    calculateChecked(isAllSelect) {
        let result = myStatService.calculateChecked(this.mmsList, isAllSelect);
        if (result) {
            this.selectMsgCount = result.count;
            this.selectMsgTextCount = result.textCount;
            this.selectMsgMmsCount = result.mmsCount;
            this.mmCheckedList = result.mmCheckedList;
            if (result.count == 1) {
                this.longPressIndex = this.mmsList.findIndex((val, index) => val.isCbChecked);
            }
            this.allShow = false;
            if (this.selectMsgCount == this.mmsList.length) {
                this.allShow = true;
            }
        }
    },
    clickBottomDelete() {
        this.isCheckDeleted = true;
        this.clickGroupDelete();
    },
    // 删除
    clickGroupDelete() {
        if (this.selectMsgCount == 0) {
            this.isCheckDeleted = false;
            return;
        }
        this.$element('delete_dialog').show();
    },
    // 批量删除
    deleteDialogConfirm() {
        if (this.selectMsgCount == 0) {
            return;
        }
        this.isCheckDeleted = false;
        let groupIds = [];
        for (let i = 0; i < this.selectMsgCount; i++) {
            let index = this.mmsList.findIndex(item => item.isCbChecked);
            let item = this.mmsList[index];
            this.mmsList.splice(index, 1);
            groupIds.push(item.groupId);
        }
        // 设置收藏标志位
        let actionData = {
            groupIds: groupIds,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            hasCollect: 0
        };
        conversationService.updateCollect(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info('Success: updateCollect()');
            } else {
                mmsLog.info('Error: updateCollect() failed !!!');
            }
        });
        this.$element('delete_dialog').close();
        this.singleMsgCancelBack();
    },
    deleteDialogCancel() {
        this.$element('delete_dialog').close();
        if (!this.isCheckDeleted) {
            let item = this.mmsList[this.longPressIndex];
            item.isCbChecked = !item.isCbChecked;
            this.computedCheckedMsgCount(COMPUTED_CHECKED);
        }
        this.isCheckDeleted = false;
    },
    // 复制
    clickGroupCopy() {
        // 如果选中的值未选中，直接返回
        if (this.selectMsgCount == 0 || this.selectMsgTextCount == 0) {
            return;
        }
        // 复制
        myStatService.textCopy(this.mmCheckedList);
        // 取消全选
        this.singleMsgCancelBack();
    },
    // 全选
    clickGroupCheckAll() {
        if (this.selectMsgCount === this.mmsList.length) {
            this.computedCheckedMsgCount(CANCEL_ALL_CHECKED);
            this.mmsList.forEach((val, index) => {
                val.isCbChecked = false;
            })
        } else {
            this.computedCheckedMsgCount(ALL_CHECKED)
        }
    },
    // 转发
    clickGroupTransmit() {
        if (this.mmCheckedList.length == 1) {
            this.transmitMsgSingle();
        } else if (this.mmCheckedList.length > 1) {
            this.transmitMsgMulti();
        }
    },
    // 保存
    saveImage() {
        let actionData = {}
        actionData.threadId = ''
        actionData.pduId = this.mmsList[this.longPressIndex].pduId
        let that = this;
        myStatService.saveImage(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                let message = that.$t('strings.attachment_saved_to') + result.filePath
                + that.$t('strings.please_keep_it_secure')
                prompt.showToast({ // 图片保存完成
                    message: message,
                    duration: 1000,
                });
            } else {
                mmsLog.info(PRE_LOG + 'saveImage error');
            }
        });
    },
    more(longPressIndex) {
        let item = this.mmsList[longPressIndex];
        // 设置选中标记
        item.isCbChecked = !item.isCbChecked;
        // 获取选中的列表
        this.computedCheckedMsgCount(COMPUTED_CHECKED);
        this.hasCheckboxStatus = true;
        this.setHasSelectTextShow(item);
    },
    singleMsgBack() {
        router.back();
    },
    tip() {
        this.$element('tip_details_dialog').show();
    },
    // 模拟双击事件 item 参数
    doubleClick(index, e) {
        if (this.timeOutFlag != null) {
            clearTimeout(this.timeOutFlag);
        }
        let ref = e.target.ref;
        let that = this;
        if (typeof this.doubleClickMap == 'undefined' || this.doubleClickMap[ref] == null) {
            this.doubleClickMap = {};
            this.doubleClickMap[ref] = 0;
        }
        this.doubleClickMap[ref] = this.doubleClickMap[ref] + 1
        if (this.doubleClickMap[ref] == 2) {
            this.longPressIndex = index;
            let item = this.mmsList[this.longPressIndex];
            item.isCbChecked = !item.isCbChecked;
            this.computedCheckedMsgCount(COMPUTED_CHECKED);
            this.doubleIntentTextSelect(item);
            item.isCbChecked = !item.isCbChecked;
            this.computedCheckedMsgCount(COMPUTED_CHECKED);
        } else if (this.doubleClickMap[ref] > 2) {
            this.doubleClickMap = {};
        }
        this.timeOutFlag = setTimeout(function () {
            that.doubleClickMap = {};
        }, 300)
    },
    doubleIntentTextSelect(item) {
        let param = JSON.parse(JSON.stringify(item));
        if(param.isMsm) {
            if(param.msgShowType != common.MESSAGE_SHOW_TYPE.NORMAL) {
                return;
            }
        }
        this.jumpToTextSelect(param);
    },
    longIntentTextSelect(item) {
        let param = JSON.parse(JSON.stringify(item));
        if(param.isMsm) {
            let isContainText = myStatService.judgeIsContainText(param.mms);
            if(isContainText) {
                this.getIntentText(param);
            } else {
                return;
            }
        }
        this.jumpToTextSelect(param);
    },
    getIntentText(param) {
        for(let item of param.mms) {
            if(common.MSG_ITEM_TYPE.TEXT == item.msgType) {
                param.content = item.content;
                break;
            }
            if((common.MSG_ITEM_TYPE.IMAGE == item.msgType || common.MSG_ITEM_TYPE.AUDIO == item.msgType
            || common.MSG_ITEM_TYPE.VIDEO == item.msgType) && item.content !== common.string.EMPTY_STR) {
                param.content = item.content;
                break;
            }
        }
    },
    jumpToTextSelect(item) {
        router.push({
            uri: 'pages/text_select/text_select',
            params: item
        });
    },
    // 单个数据转发
    jumpToTransmit(transmitContent, transmitContentList, isMms) {
        router.push({
            uri: 'pages/transmit_msg/transmit_msg',
            params: {
                doubleCard: this.cardImage,
                transmitContent: transmitContent,
                transmitContentList: transmitContentList,
                isMulti: true,
                isMms: isMms,
                isMyStartPage: true
            }
        });
    },
    transmitMsgSingle() {
        let starObj = {};
        let item = this.mmCheckedList[0]
        let contactsName = this.$t('strings.transmitContentReceive', {
            name: item.address
        });
        starObj.contactsName = contactsName;
        starObj.isMsm = item.isMsm;
        starObj.msgShowType = item.msgShowType;
        starObj.mms = item.mms;
        starObj.content = item.content;
        starObj.msgUriPath = item.msgUriPath ? item.msgUriPath : common.string.EMPTY_STR;
        starObj.contentInfo = common.string.EMPTY_STR;
        starObj.msgType = item.msgType;
        starObj.audioTime = item.audioTime;
        let transmitContentList = [];
        transmitContentList.push(starObj);
        let transmitContent = item.isReceive ? contactsName : this.$t('strings.transmitContent');
        this.jumpToTransmit(transmitContent, transmitContentList, item.isMsm);
    },
    // 多个数据转发
    transmitMsgMulti() {
        mmsLog.info('transmitMsgMulti,start');
        let transmitContent = this.$t('strings.transmitContentMultiForFavorite');
        let item = this.mmCheckedList[0];
        let contactsName = this.$t('strings.transmitContentReceive', {
            name: item.address
        });
        let today = this.$t('strings.today');
        let yesterday = this.$t('strings.yesterday');
        let transmitContentMe = this.$t('strings.transmitContentMe');
        let transmitMsg = this.getTransmitMulti(this.mmCheckedList, contactsName, today, yesterday, transmitContentMe);
        this.jumpToTransmit(transmitContent, transmitMsg.transmitContentList, true);
    },
    getTransmitMulti(mmCheckedList, contactsName, today, yesterday, transmitContentMe) {
        let result = {};
        let transmitList = [];
        for (let element of mmCheckedList) {
            let transmitContentArray = {}
            if (element.isCbChecked) {
                let date = element.date.substring(0, element.date.length - 3);
                if (date == today || date == yesterday) {
                    let time = element.timeMillisecond;
                    date = this.getTime(time);
                }
                transmitContentArray.date = date;
                transmitContentArray.time = element.time;
                transmitContentArray.msgUriPath = element.msgUriPath ? element.msgUriPath : common.string.EMPTY_STR;
                transmitContentArray.content = element.content;
                if (element.isReceive) {
                    transmitContentArray.contactsName = contactsName;
                } else {
                    transmitContentArray.contactsName = transmitContentMe;
                }
                transmitContentArray.mms = element.mms;
                transmitContentArray.msgShowType = element.msgShowType;
                transmitContentArray.isMsm = element.isMsm;
                transmitContentArray.contentInfo = common.string.EMPTY_STR;
                transmitContentArray.msgType = element.msgType;
                transmitContentArray.audioTime = element.audioTime;
                transmitList.push(transmitContentArray);
            }
        }
        result.transmitContentList = transmitList;
        return result;
    },
    getTime(nS) {
        var date = new Date(parseInt(nS));
        var year = date.getFullYear();
        var mon = date.getMonth() + 1;
        var day = date.getDate();
        return year + this.$t('strings.year') + mon + this.$t('strings.month') + day + this.$t('strings.day');
    },
    favoriteShare() {
        if (this.selectMsgCount == 0 || this.selectMsgTextCount != 1) {
            return;
        }
        var actionData = {};
        let item = this.mmCheckedList[0];
        actionData.content = item.content;
        myStatService.favoriteShare(actionData, function (data) {
            mmsLog.info(PRE_LOG + 'favoriteShare: ' + data.success);
        });
    },
    // 头像点击事件处理器
    avatarClickEventHandler(item) {
        let i = item
        let isReceive = i.isReceive;
        if (isReceive) {
            let telephone = i.receiverNumber;
            if (telephone == null || telephone == common.string.EMPTY_STR) {
                mmsLog.warn(PRE_LOG + 'avatarClickEventHandler: telephone is null')
                return;
            }
            let actionData = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContract(actionData);
        } else {
            // 跳转到联系人名片页面
            let actionData = {
                featureAbility: this.$app.$def.featureAbility,
                ohosDataAbility: this.$app.$def.ohosDataAbility,
            };
            contactService.judgeIsExitProfile(actionData,flag => {
                if(flag){
                    let jumpData = {
                        pageFlag: common.contractPage.PAGE_FLAG_CALLING_CARD
                    }
                    this.jumpToContract(jumpData);
                }else{
                    mmsLog.info('jumpToCard is error');
                }
            })
        }
    },
    // 跳转联系人app
    jumpToContract(actionData) {
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info('my_star.js ---> Data: ' + data);
        }).catch((error) => {
            mmsLog.error('my_star.js ---> Cause: ' + JSON.stringify(error));
        })
    },
    clickStarMms(item) {
        router.push({
            uri: 'pages/slide_detail/slide_detail',
            params: {
                mms: item,
                threadId: item.sessionId
            }
        });
    }
}
