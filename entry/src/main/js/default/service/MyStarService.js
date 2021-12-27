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

import MyStarModel from '../model/myStarImpl/MyStarImplModel.js'
let myStatModel = new MyStarModel();
import { commonPasteboard } from '../../default/utils/Pasteboard.js';
import mmsLog from '../utils/MmsLog.js';
import common from '../pages/common_constants.js';
import contractService from '../service/ContractService.js';
import commonService from '../service/CommonService.js';
import conversationService from '../service/ConversationService.js';

const TAG = 'MyStarService ->';
export default {

    /**
     * 获取收藏列表
     * @param actionData 查询条件
     * @param callBack 回调函数
     * @return
     */
    queryFavoriteMessageList(actionData, callBack) {
        let result = {};
        let listPromise = new Promise((resolve, reject) => {
            myStatModel.queryFavoriteMessageList(actionData, res => {
                if (res.code === common.int.SUCCESS) {
                    resolve(res);
                } else {
                    mmsLog.info(TAG + 'Error: queryFavoriteMessageList() failed !!!');
                    reject(res);
                }
            });
        });
        let countPromise = new Promise((resolve, reject) => {
            myStatModel.countFavoriteList(actionData, res => {
                if (res.code === common.int.SUCCESS) {
                    resolve(res);
                } else {
                    mmsLog.info(TAG + 'Error: countFavoriteList() failed !!!');
                    reject(res);
                }
            });
        });
        let promiseAll = Promise.all([listPromise, countPromise]);
        promiseAll.then(res => {
            let listResult = res[0];
            let countResult = res[1];
            result.total = countResult.abilityResult;
            result.code = listResult.code;
            let telephones = [];
            this.groupFavoriteMessage(listResult.abilityResult, telephones, actionData, favoriteList => {
                this.dealContactsName(telephones, actionData, favoriteList, list => {
                    result.response = list;
                    callBack(result);
                });
            });
        }).catch(err => {
            mmsLog.log(TAG + 'queryFavoriteMessageList error: ' + err);
            result.code = common.int.FAILURE;
            callBack(result);
        })
    },

    /**
     * 收藏数据处理
     * @param favoriteList
     */
    convertMyStarList(favoriteList) {
        let resultList = [];
        for(let item of favoriteList) {
            let result = {};
            result.id = item.msgId;
            result.image = '/common/icon/user_avatar_full_fill.svg';
            result.content = item.msgContent;
            result.timeMillisecond = item.startTime;
            result.isMsm = item.msgType == 0 ? false : true;
            result.isCbChecked = false;
            result.msgType = 0;
            // 判断是接收方还是发送方
            result.date = common.string.EMPTY_STR;
            result.time = common.string.EMPTY_STR;
            result.groupId = item.groupId;
            result.isSender = item.isSender;
            result.isReceive = (item.isSender == 0) ? false : true;
            if (result.isReceive) {
                result.receiverNumber = item.senderNumber;
                result.address = result.receiverNumber;
            } else {
                result.receiverNumber = item.receiverNumber;
                result.address = '';
            }
            if (!result.isMsm) {
                result.msgShowType = common.MESSAGE_SHOW_TYPE.NORMAL;
            }
            result.sessionId = item.sessionId;
            resultList.push(result);
        }
        return resultList;
    },

    /**
     * 收藏数据分组
     * @param starList
     * @param telephones
     */
    groupFavoriteMessage(starList, telephones, actionData, callback) {
        let details = this.convertMyStarList(starList);
        let resultList = [];
        // 需要根据groupId 进行分组
        let detailMap = new Map();
        for(let item of details) {
            if(detailMap.has(item.groupId)) {
                let groups = detailMap.get(item.groupId);
                groups.push(item);
            } else {
                let groups = [];
                groups.push(item);
                detailMap.set(item.groupId, groups);
            }
        }
        // 根据组进行
        let groupIds = detailMap.keys();
        let mmsPartIds = [];
        for(let groupId of groupIds) {
            let groups = detailMap.get(groupId);
            let result = groups[groups.length - 1];
            let numbers = [];
            if(result.isMsm) {
                mmsPartIds.push(result.id);
            }
            for(let item of groups) {
                numbers.push(item.receiverNumber);
                telephones.push(item.receiverNumber);
            }
            result.receiverNumber = numbers.join(common.string.COMMA);
            resultList.push(result);
        }
        this.dealMmsPartData(resultList, mmsPartIds, actionData, res => {
            callback(res);
        });
    },
    dealMmsPartData(resultList, msgIds, actionData, callback) {
        if(msgIds.length == 0) {
            callback(resultList);
            return;
        }
        actionData.msgIds = msgIds;
        conversationService.queryMmsPartByIds(actionData, res => {
            let mmsParts = res.response;
            let favoriteMmsPartMap = new Map();
            for (let part of mmsParts) {
                if (favoriteMmsPartMap.has(part.msgId)) {
                    let strings = favoriteMmsPartMap.get(part.msgId);
                    strings.push(part);
                } else {
                    let strings = [];
                    strings.push(part);
                    favoriteMmsPartMap.set(part.msgId, strings);
                }
            }
            for (let starItem of resultList) {
                if (favoriteMmsPartMap.has(starItem.id)) {
                    let parts = favoriteMmsPartMap.get(starItem.id);
                    // 判断是否需要展示 0 普通样式, 1 主题, 2幻灯片,
                    starItem.mms = commonService.getMmsSource(parts);
                    starItem.msgShowType = commonService.getDisplay(starItem.mms);
                    commonService.setItemMmsContent(starItem, starItem.mms);
                }
            }
            callback(resultList);
        });
    },

    /**
     * 根据号码获取联系人姓名
     * @param telephones
     * @param actionData
     * @param favoritelist
     * @param callback
     */
    dealContactsName(telephones, actionData, favoritelist, callback) {
        actionData.telephones = telephones;
        if (telephones.length == 0) {
            callback(favoritelist);
            return;
        }
        contractService.queryContactDataByTelephone(actionData, contacts => {
            if (contacts.length == 0) {
                callback(favoritelist);
            } else {
                // 将结果转换为Map,key:手机号，value: 名称
                let telephoneMap = this.getAddressMap(contacts);
                // 将结果根据手机号进行匹配
                this.buildAddress(favoritelist, telephoneMap);
                callback(favoritelist);
            }
        });
    },
    getAddressMap(contacts) {
        let addressMap = new Map();
        for (let item of contacts) {
            if (item.displayName == common.string.EMPTY_STR) {
                addressMap.set(item.detailInfo, item.detailInfo);
            } else {
                addressMap.set(item.detailInfo, item.displayName);
            }
        }
        return addressMap;
    },
    buildAddress(favoritelist, telephoneMap) {
        for (let list of favoritelist) {
            // 多人名称的组合,名称是需要组合展示
            if (!list.isReceive) {
                list.address = common.string.EMPTY_STR;
            } else {
                this.getNameAndAddress(list, telephoneMap);
            }
        }
    },
    getNameAndAddress(list, telephoneMap) {
        if (list.receiverNumber.indexOf(common.string.COMMA) > -1) {
            let tels = list.receiverNumber.split(common.string.COMMA);
            let name = common.string.EMPTY_STR;
            for (let telephone of tels) {
                if (telephoneMap.has(telephone)) {
                    name = name + telephoneMap.get(telephone) + common.string.COMMA;
                } else {
                    name = name + telephone + common.string.COMMA;
                }
            }
            list.address = name.substring(0, name.length - 1);
        } else {
            if (telephoneMap.has(list.receiverNumber)) {
                list.address = telephoneMap.get(list.receiverNumber);
            } else {
                list.address = list.receiverNumber;
            }
        }
    },

    /**
     * 计算列表被选中的值
     * @param mmsList 列表数据
     * @param isAllSelect 是否全选
     * @return 统计数据
     */
    calculateChecked(mmsList, isAllSelect){
        let count = 0;
        let textCount = 0;
        let mmsCount = 0;
        let mmCheckedList = [];
        let result = {};
        for(let item of mmsList) {
            if(isAllSelect || item.isCbChecked) {
                mmCheckedList.push(item);
                count++;
                if (item.isMsm) {
                    mmsCount++;
                } else {
                    textCount++;
                }
                if(item.isMsm && this.judgeIsContainText(item.mms)) {
                    textCount++;
                }
            }
        }
        result.count = count;
        result.textCount = textCount;
        result.mmsCount = mmsCount;
        result.mmCheckedList = mmCheckedList;
        return result;
    },

    /**
     * 判断是否存在文本
     * @param mmCheckedList 彩信列表
     * @return
     */
    judgeIsContainText(mmsSource) {
        let flage = false;
        if(mmsSource == null || mmsSource.length == 0) {
            return flage;
        }
        let textCount = 0;
        for(let item of mmsSource) {
            let msgType = item.msgType;
            if(common.MSG_ITEM_TYPE.TEXT == msgType) {
                flage = true;
                textCount ++;
            }
            if((common.MSG_ITEM_TYPE.IMAGE == msgType || common.MSG_ITEM_TYPE.AUDIO == msgType
            || common.MSG_ITEM_TYPE.VIDEO == msgType) && item.content !== common.string.EMPTY_STR) {
                flage = true;
            }
        }
        if(textCount == mmsSource.length) {
            flage = false;
        }
        return flage;
    },

    /**
     * 复制被选中的文本
     * @param mmCheckedList 选中的列表
     * @return
     */
    textCopy(mmCheckedList){
        let strText = common.string.EMPTY_STR;
        let index = 0;
        for(let element of mmCheckedList) {
            if (element.isCbChecked && element.msgType.indexOf(0) != -1) {
                // 判断是否包含文本信息
                let splitStr = common.string.EMPTY_STR;
                if (index < mmCheckedList.length - 1) {
                    splitStr = '\n';
                }
                strText += element.content;
                strText += splitStr;
            }
            index++;
        }
        commonPasteboard.setPasteboard(strText);
    },

    /**
     * 保存图片
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    saveImage(actionData, callback) {
        let result = {
            code: 0,
            filePath: '/common/icon/test.jpg'
        }
        callback(result);
    },

    /**
     * 调用分享功能接口
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    favoriteShare(actionData, callback) {
        let result = {
            code: 0,
        }
        callback(result);
    }
}