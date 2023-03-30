/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import common from "../data/commonData";

export default {
    commonContractParam(actionData) {
        let str = {
            "bundleName": common.string.CONTRACT_BUNDLE_NAME,
            "abilityName": common.string.CONTRACT_ABILITY_NAME,
            "parameters": actionData,
            "entities": [
                common.string.COMMON_ENTITIES
            ]
        };
        return str;
    },

    getDisplay(mmsParts) {
        let display = common.MESSAGE_SHOW_TYPE.NORMAL;
        let first = mmsParts[0];
        if (mmsParts.length == 1) {
            display = common.MESSAGE_SHOW_TYPE.NORMAL;
        } else if (mmsParts.length >= 2) {
            let second = mmsParts[1];
            if (first.msgType == common.MSG_ITEM_TYPE.THEME) {
                if (second.msgType == common.MSG_ITEM_TYPE.IMAGE || second.msgType == common.MSG_ITEM_TYPE.VIDEO) {
                    display = common.MESSAGE_SHOW_TYPE.PPT_IMAGE;
                } else if (mmsParts.length > 2) {
                    display = common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE;
                } else {
                    display = common.MESSAGE_SHOW_TYPE.THEME_NO_IMAGE;
                }
            } else if (second.msgType == common.MSG_ITEM_TYPE.THEME && mmsParts.length == 3) {
                display = common.MESSAGE_SHOW_TYPE.THEME_IMAGE;
            } else {
                if (first.msgType == common.MSG_ITEM_TYPE.IMAGE || first.msgType == common.MSG_ITEM_TYPE.VIDEO) {
                    display = common.MESSAGE_SHOW_TYPE.PPT_IMAGE;
                } else {
                    display = common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE;
                }
            }
        }
        return display;
    },

    setItemMmsContent(item, mmsParts) {
        item.msgUriPath = common.string.EMPTY_STR;
        item.content = common.string.EMPTY_STR;
        let first = mmsParts[0];
        item.msgUriPath = first.msgUriPath;
        item.audioTime = first.time;
        if (mmsParts.length == 1) {
            item.msgType = first.msgType;
            item.content = first.content;
        } else if (mmsParts.length >= 2) {
            let content = first.content;
            let second = mmsParts[1];
            let secondContent = second.content;
            if (first.msgType == common.MSG_ITEM_TYPE.THEME) {
                if (second.msgType == common.MSG_ITEM_TYPE.IMAGE || second.msgType == common.MSG_ITEM_TYPE.VIDEO) {
                    item.msgUriPath = second.msgUriPath;
                }
                if (content == common.string.EMPTY_STR) {
                    item.content = secondContent;
                } else {
                    item.content = content + "\n" + secondContent;
                }
            } else if (second.msgType == common.MSG_ITEM_TYPE.THEME && mmsParts.length === 3) {
                item.msgUriPath = first.msgUriPath;
                item.msgType = first.msgType;
                let third = mmsParts[2];
                let thirdContent = third.content;
                if (secondContent == common.string.EMPTY_STR) {
                    item.content = thirdContent;
                } else {
                    item.content = secondContent + "\n" + thirdContent;
                }
            } else {
                item.content = content;
            }
        }
    },

    getMmsSource(mmsParts) {
        let source = [];
        mmsParts.forEach(part => {
            let obj = {
                msgType: parseInt(part.type),
                msgUriPath: part.locationPath,
                time: part.recordingTime,
                content: part.content,
                fileSize: part.fileSize,
                messageType: part.messageType ? parseInt(part.messageType) : 0
            }
            source.push(obj);
        });
        return source;
    },

    getMmsContent(mmsSource) {
        let content = common.string.EMPTY_STR;
        for (let mms of mmsSource) {
            // Indicates that the topic exists.
            if (mms.msgType == common.MSG_ITEM_TYPE.THEME) {
                content = mms.content;
                break;
            }
        }
        return content;
    },

    checkIsMms(dataSource) {
        // Indicates whether the SMS message is a common message.
        let isMsg = false;
        for (let index = 0; index < dataSource.length; index++) {
            let item = dataSource[index];
            if (!item.isMsm) {
                isMsg = true;
                break;
            }
        }
        return isMsg;
    },

    judgeIsSelectText(mmsSource) {
        let flage = false;
        for (let item of mmsSource) {
            let msgType = item.msgType;
            if (common.MSG_ITEM_TYPE.THEME == msgType) {
                flage = true;
            }
            if (common.MSG_ITEM_TYPE.TEXT == msgType && item.content != common.string.EMPTY_STR) {
                flage = true;
            }
            if ((common.MSG_ITEM_TYPE.IMAGE == msgType || common.MSG_ITEM_TYPE.AUDIO == msgType
            || common.MSG_ITEM_TYPE.VIDEO == msgType) && item.content != common.string.EMPTY_STR) {
                flage = true;
            }
        }
        return flage;
    },

    judgeIsImage(mmsSource) {
        let flage = false;
        for (let item of mmsSource) {
            let msgType = item.msgType;
            if (common.MSG_ITEM_TYPE.IMAGE == msgType) {
                flage = true;
            }
        }
        return flage;
    },

    getTransmitContentHeight(list) {
        let height = 0;
        list.forEach((item) => {
            if (item.msgShowType == common.MESSAGE_SHOW_TYPE.NORMAL) {
                height = height + common.TRANSMIT_ITEM_HEIGHT.TEXT_HEIGHT;
            } else if (item.msgShowType == common.MESSAGE_SHOW_TYPE.THEME_IMAGE) {
                height = height + common.TRANSMIT_ITEM_HEIGHT.THEME_IMAGE_HEIGHT;
            } else if (item.msgShowType == common.MESSAGE_SHOW_TYPE.PPT_IMAGE) {
                height = height + common.TRANSMIT_ITEM_HEIGHT.PPT_IMAGE_HEIGHT;
            } else if (item.msgShowType == common.MESSAGE_SHOW_TYPE.THEME_NO_IMAGE ||
            item.msgShowType == common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE) {
                height = height + common.TRANSMIT_ITEM_HEIGHT.THEME_HEIGHT;
            }
            height = height + common.TRANSMIT_ITEM_HEIGHT.DISTANCE;
        });
        if (height > common.TRANSMIT_ITEM_HEIGHT.TOTAL_HEIGHT) {
            height = common.TRANSMIT_ITEM_HEIGHT.TOTAL_HEIGHT;
        }
        return height;
    },

    judgeIsAttachment(mmsSource): boolean {
        let flage = false;
        if (mmsSource == null || mmsSource.length == 0) {
            return flage;
        }
        for (let item of mmsSource) {
            let msgType = item.msgType;
            if (common.MSG_ITEM_TYPE.IMAGE == msgType || common.MSG_ITEM_TYPE.VIDEO == msgType
            || common.MSG_ITEM_TYPE.AUDIO == msgType) {
                flage = true;
            }
        }
        return flage;
    }
}