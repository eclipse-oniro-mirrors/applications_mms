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
import LooseObject from '../data/LooseObject';
import TransmitMsgController from '../pages/transmitmsg/transmitMsgController';
import TransmitSearchController from '../pages/transmitmsg/transmitSearchMsgController';
import HiLog from './HiLog';
import commonData from '../data/commonData';

const TAG = 'TransmitMessageUtils';
export default class TransmitMessageUtils {
    //获取TransmitDialog标题
    public static getMainTitle(controller: TransmitMsgController | TransmitSearchController): ResourceStr {
        let titleStr: ResourceStr;
        if (controller.dialogMsg.contactsParam.contactsNum! > 1) {
            titleStr = $r('app.string.contentSentTo',
                controller.dialogMsg?.contactsParam.contactName == '' ?
                controller.dialogMsg?.contactsParam.telephoneFormatSplit :
                controller.dialogMsg?.contactsParam.contactNameSplit, TransmitMessageUtils.getPluralPeople(controller));
        } else {
            titleStr = $r('app.string.smart_sms_forward_dialog_single',
                controller.dialogMsg?.contactsParam.contactName == '' ?
                controller.dialogMsg?.contactsParam.telephoneFormat :
                controller.dialogMsg?.contactsParam.contactName);
        }
        return titleStr;
    }

    public static getShareTitle(controller: TransmitMsgController | TransmitSearchController): ResourceStr {
        let titleStr: ResourceStr;
        titleStr = $r('app.string.contentSentContentToSingle',
            controller.dialogMsg?.contactsParam.contactName == '' ?
            controller.dialogMsg?.contactsParam.telephoneFormat :
            controller.dialogMsg?.contactsParam.contactName);
        return titleStr;
    }

    static getPluralPeople(controller: TransmitMsgController | TransmitSearchController) {
        let pluralPeopleString = getContext(TransmitMessageUtils)
            .getApplicationContext()
            .resourceManager
            .getPluralStringValueSync($r('app.plural.plural_people').id,
                controller.dialogMsg?.contactsParam.contactsNum!);
        return pluralPeopleString;
    }

    public static transmitContentCanEdit(msg: LooseObject | null): boolean {
        for (let index: number = 0; index < msg?.transmitContentList.length; index++) {
            if (!msg?.transmitContentList[index].isMsm) {
                HiLog.i(TAG, 'transmit message contain sms, show tab to edit content');
                return true;
            }
        }
        return false;
    }

    public static transmitCanAddSource(msg: LooseObject | null): boolean {
        if (msg && msg.transmitContentList && msg.transmitContentList.length > 0) {
            HiLog.i(TAG, 'msg.transmitContentList.length > 0');
          for (let index: number = 0; index < msg.transmitContentList.length; index++) {
            if (msg.transmitContentList[index].mms && msg.transmitContentList[index].mms.length == 1 &&
              msg.transmitContentList[index].mms[0].type &&
              msg.transmitContentList[index].mms[0].type === commonData.MM_ATTACHMENT_TYPE.TEXT) {
                HiLog.i(TAG, 'transmit message contain pure text, show can add source content');
              return true;
            }
          }
        }
        return false;
    }
}