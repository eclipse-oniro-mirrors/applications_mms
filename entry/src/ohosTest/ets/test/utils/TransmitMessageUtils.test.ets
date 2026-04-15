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
import { describe, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium'
import commonData from '../../../../main/ets/data/commonData';
import LooseObject from '../../../../main/ets/data/LooseObject';
import TransmitMsgController from '../../../../main/ets/pages/transmitmsg/transmitMsgController'
import TransmitMessageUtils from '../../../../main/ets/utils/TransmitMessageUtils';

export default function TransmitMessageUtilsTest() {
  describe('TransmitMessageUtilsTest', () => {

    it('TransmitMessageUtilsTest_getMainTitle_if', 0, () => {
      let mocker: MockKit = new MockKit();
      let controller: TransmitMsgController = TransmitMsgController.getInstance();
      controller.dialogMsg.contactsParam.contactsNum = 2;
      controller.dialogMsg.contactsParam.contactName = 'John Doe';
      controller.dialogMsg.contactsParam.telephoneFormat = '1234567890';
      controller.dialogMsg.contactsParam.contactNameSplit = 'John Doe and Karen Smith';
      controller.dialogMsg.contactsParam.telephoneFormatSplit = '1234567890 and 0987654321';
      when(mocker.mockFunc(TransmitMessageUtils, TransmitMessageUtils.getPluralPeople))(ArgumentMatchers.any)
        .afterReturn('id');
      let titleStrs: ResourceStr = TransmitMessageUtils.getMainTitle(controller);
      expect(titleStrs).not().assertUndefined();
      controller.dialogMsg.contactsParam.contactName = '';
      let titleStr: ResourceStr = TransmitMessageUtils.getMainTitle(controller);
      expect(titleStrs).not().assertUndefined();
      mocker.clear(TransmitMessageUtils);
    })

    it('TransmitMessageUtilsTest_getMainTitle_else', 0, () => {
      let controller: TransmitMsgController = TransmitMsgController.getInstance();
      controller.dialogMsg.contactsParam.contactsNum = 1;
      controller.dialogMsg.contactsParam.contactName = 'John Doe';
      controller.dialogMsg.contactsParam.telephoneFormat = '1234567890';
      TransmitMessageUtils.getMainTitle(controller);
      controller.dialogMsg.contactsParam.contactName = '';
      let titleStr: ResourceStr = TransmitMessageUtils.getMainTitle(controller);
      expect(titleStr).not().assertUndefined();
    })

    it('TransmitMessageUtilsTest_getShareTitle', 0, () => {
      let controller: TransmitMsgController = TransmitMsgController.getInstance();
      controller.dialogMsg.contactsParam.contactName = '';
      controller.dialogMsg.contactsParam.telephoneFormat = '1234567890';
      TransmitMessageUtils.getShareTitle(controller);
      controller.dialogMsg.contactsParam.contactName = '911';
      let titleStr: ResourceStr = TransmitMessageUtils.getShareTitle(controller);
      expect(titleStr).not().assertUndefined();
    })

    it('TransmitMessageUtilsTest_transmitContentCanEdit_true', 0, () => {
      let msg: LooseObject = {
        transmitContentList: [
          { isMsm: true },
          { isMsm: false },
          { isMsm: true }
        ]
      };
      const result = TransmitMessageUtils.transmitContentCanEdit(msg);
      expect(result).assertEqual(true);
    })

    it('should_return_false_when_msg_is_null', 0, () => {
      let msg: LooseObject | null = null;
      const result = TransmitMessageUtils.transmitContentCanEdit(msg);
      expect(result).assertEqual(false);
    });

    it('TransmitMessageUtilsTest_transmitContentCanEdit_false', 0, () => {
      let msg: LooseObject = {
        transmitContentList: []
      };
      const result = TransmitMessageUtils.transmitContentCanEdit(msg);
      expect(result).assertEqual(false);
    })

    it('TransmitMessageUtilsTest_transmitCanAddSource_msg_is_null', 0, () => {
      const result = TransmitMessageUtils.transmitCanAddSource(null);
      expect(result).assertEqual(false);
    })

    it('TransmitMessageUtilsTest_transmitCanAddSource_transmitContentList_is_null', 0, () => {
      let msg: LooseObject = {
        transmitContentList: null
      };
      const result = TransmitMessageUtils.transmitCanAddSource(msg);
      expect(result).assertEqual(false);
    })

    it('TransmitMessageUtilsTest_transmitCanAddSource_mms_is_null', 0, () => {
      let msg: LooseObject = {
        transmitContentList: [
          {
            mms: null
          }
        ]
      };
      const result = TransmitMessageUtils.transmitCanAddSource(msg);
      expect(result).assertEqual(false);
    })

    it('TransmitMessageUtilsTest_transmitCanAddSource_length_two', 0, () => {
      let msg: LooseObject = {
        transmitContentList: [
          {
            mms: [
              {
                type: commonData.MM_ATTACHMENT_TYPE.TEXT
              },
              {
                type: commonData.MM_ATTACHMENT_TYPE.TEXT
              }
            ]
          }
        ]
      };
      const result = TransmitMessageUtils.transmitCanAddSource(msg);
      expect(result).assertEqual(false);
    })

    it('TransmitMessageUtilsTest_transmitCanAddSource_type_error', 0, () => {
      let msg: LooseObject = {
        transmitContentList: [
          {
            mms: [
              {
                type: commonData.MM_ATTACHMENT_TYPE.IMAGE
              }
            ]
          }
        ]
      };
      const result = TransmitMessageUtils.transmitCanAddSource(msg);
      expect(result).assertEqual(false);
    })

    it('TransmitMessageUtilsTest_transmitCanAddSource_type_success', 0, () => {
      let msg: LooseObject = {
        transmitContentList: [
          {
            mms: [
              {
                type: commonData.MM_ATTACHMENT_TYPE.TEXT
              }
            ]
          }
        ]
      };
      const result = TransmitMessageUtils.transmitCanAddSource(msg);
      expect(result).assertEqual(true);
    })
  })
}