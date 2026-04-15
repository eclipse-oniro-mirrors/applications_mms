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
import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import CommonService, { StrTypeSet } from '../../../../main/ets/service/CommonService';
import MmsUtil from '../../../../main/ets/utils/MmsUtil';

export default function commonServiceTest() {
  describe('CommonServiceTest', () => {

    it('CommonService_setItemMmsContent', 0, () => {
      let res: StrTypeSet = CommonService.commonContactParam({});
      expect(JSON.stringify(res.parameters)).assertEqual('{}');
    })

    it('CommonService_getDisplay_length_0', 0, () => {
      let mmsParts: Record<string, number>[] = [];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(0);
    })

    it('CommonService_getDisplay_length_1', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 0
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(0);
    })

    it('CommonService_getDisplay_length_2_first_0_second_1', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 0
      }, {
        'msgType': 1
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(3);
    })

    it('CommonService_getDisplay_length_2_first_0_second_2', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 0
      }, {
        'msgType': 2
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(3);
    })

    it('CommonService_getDisplay_length_3_first_0_second_3', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 0
      }, {
        'msgType': 3
      }, {
        'msgType': 1
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(2);
    })

    it('CommonService_getDisplay_length_2_first_0_second_3', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 0
      }, {
        'msgType': 3
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(1);
    })

    it('CommonService_getDisplay_length_3_first_1_second_0', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 1
      }, {
        'msgType': 0
      }, {
        'msgType': 0
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(4);
    })

    it('CommonService_getDisplay_length_4_first_1_second_0', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 1
      }, {
        'msgType': 0
      }, {
        'msgType': 0
      }, {
        'msgType': 0
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(3);
    })

    it('CommonService_getDisplay_length_4_first_2_second_0', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 2
      }, {
        'msgType': 0
      }, {
        'msgType': 0
      }, {
        'msgType': 0
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(3);
    })

    it('CommonService_getDisplay_length_4_first_3_second_0', 0, () => {
      let mmsParts: Record<string, number>[] = [{
        'msgType': 3
      }, {
        'msgType': 0
      }, {
        'msgType': 0
      }, {
        'msgType': 0
      }];
      expect(CommonService.getDisplay(mmsParts)).assertEqual(2);
    })

    it('CommonService_setItemMmsContent_mmsParts_length_1', 0, () => {
      let mmsParts: Record<string, string | number>[] = [{
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0
      }];
      let item: Record<string, string | number> = {};
      CommonService.setItemMmsContent(item, mmsParts);
      expect(item.msgType).assertEqual(0);
    })

    it('CommonService_setItemMmsContent_mmsParts_length_2_first_0_second_1', 0, () => {
      let mmsParts: Record<string, string | number>[] = [{
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0,
        "content": ''
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 1,
        "content": ''
      }];
      let item: Record<string, string | number> = {};
      CommonService.setItemMmsContent(item, mmsParts);
      expect(item.content).assertEqual('');
    })

    it('CommonService_setItemMmsContent_mmsParts_length_2_first_0_second_2', 0, () => {
      let mmsParts: Record<string, string | number>[] = [{
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0,
        "content": 'xx'
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 2,
        "content": ''
      }];
      let item: Record<string, string | number> = {};
      CommonService.setItemMmsContent(item, mmsParts);
      expect(item.content).assertEqual('xx' + '\n' + '');
    })

    it('CommonService_setItemMmsContent_mmsParts_length_2_first_0_second_3', 0, () => {
      let mmsParts: Record<string, string | number>[] = [{
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0,
        "content": 'xx'
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 3,
        "content": ''
      }];
      let item: Record<string, string | number> = {};
      CommonService.setItemMmsContent(item, mmsParts);
      expect(item.content).assertEqual('xx' + '\n' + '');
    })

    it('CommonService_setItemMmsContent_mmsParts_length_3_first_3_second_0', 0, () => {
      let mmsParts: Record<string, string | number>[] = [{
        "time": 1,
        "msgUriPath": 1,
        "msgType": 3,
        "content": 'xx'
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0,
        "content": ''
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0,
        "content": ''
      }];
      let item: Record<string, string | number> = {};
      CommonService.setItemMmsContent(item, mmsParts);
      expect(item.content).assertEqual('');
    })

    it('CommonService_setItemMmsContent_mmsParts_length_3_first_3_second_0_content', 0, () => {
      let mmsParts: Record<string, string | number>[] = [{
        "time": 1,
        "msgUriPath": 1,
        "msgType": 3,
        "content": 'xx'
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0,
        "content": 'xx'
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 0,
        "content": ''
      }];
      let item: Record<string, string | number> = {};
      CommonService.setItemMmsContent(item, mmsParts);
      expect(item.content).assertEqual('xx' + '\n' + '');
    })

    it('CommonService_setItemMmsContent_mmsParts_length_2_first_3_second_0_content', 0, () => {
      let mmsParts: Record<string, string | number>[] = [{
        "time": 1,
        "msgUriPath": 1,
        "msgType": 3,
        "content": 'xx'
      }, {
        "time": 1,
        "msgUriPath": 1,
        "msgType": 1,
        "content": 'xx'
      }];
      let item: Record<string, string | number> = {};
      CommonService.setItemMmsContent(item, mmsParts);
      expect(item.content).assertEqual('xx');
    })


    it('CommonService_getMmsSource', 0, () => {
      let mmsParts: LooseObject[] = [];
      let mmsPart1: LooseObject = {
        "locationPath": "sdk/sdk",
        "recordingTime": 0,
        "content": "123",
        "fileSize": 1,
        "messageType": true,
        "type": 0,
      };
      mmsParts.push(mmsPart1);
      expect(CommonService.getMmsSource(mmsParts)[0].fileSize).assertEqual(1);
    })

    it('CommonService_getMmsSource_messageType_false', 0, () => {
      let mmsParts: LooseObject[] = [];
      let mmsPart1: LooseObject = {
        "locationPath": "sdk/sdk",
        "recordingTime": 0,
        "content": "123",
        "fileSize": 1,
        "messageType": false,
        "type": 0,
      };
      mmsParts.push(mmsPart1);
      expect(CommonService.getMmsSource(mmsParts)[0].fileSize).assertEqual(1);
    })

    it('CommonService_getMmsContent_msgType_0', 0, () => {
      let mmsParts: LooseObject = {
        "content": "1234",
        "msgType": 0
      };
      let mmsPartsList: LooseObject[] = [];
      mmsPartsList.push(mmsParts);
      expect(CommonService.getMmsContent(mmsPartsList)).assertEqual('1234');
    })

    it('CommonService_getMmsContent_msgType_1', 0, () => {
      let mmsParts: LooseObject = {
        "content": "1234",
        "msgType": 1
      };
      let mmsPartsList: LooseObject[] = [];
      mmsPartsList.push(mmsParts);
      expect(CommonService.getMmsContent(mmsPartsList)).assertEqual('');
    })

    it('CommonService_checkIsMms_isMsm_false', 0, () => {
      let dataSource: LooseObject[] = [];
      let dataSource1: LooseObject | string = {
        "isMsm": false
      };
      dataSource.push(dataSource1);
      let isMsg = CommonService.checkIsMms(dataSource);
      expect(isMsg).assertTrue();
    })

    it('CommonService_checkIsMms_isMsm_true', 0, () => {
      let dataSource: LooseObject[] = [];
      let dataSource1: LooseObject | string = {
        "isMsm": true
      };
      dataSource.push(dataSource1);
      let isMsg = CommonService.checkIsMms(dataSource);
      expect(isMsg).assertFalse();
    })

    it('CommonService_judgeIsSelectText_msgType_0', 0, () => {
      let mmsSource: Record<string, string | number>[] = [{
        'content': '', 'msgType': 0
      }];
      let isMsg = CommonService.judgeIsSelectText(mmsSource);
      expect(isMsg).assertTrue();
    })

    it('CommonService_judgeIsSelectText_msgType_4', 0, () => {
      let mmsSource: Record<string, string | number>[] = [{
        'content': 'xx', 'msgType': 4
      }];
      let isMsg = CommonService.judgeIsSelectText(mmsSource);
      expect(isMsg).assertTrue();
    })

    it('CommonService_judgeIsSelectText_msgType_1', 0, () => {
      let mmsSource: Record<string, string | number>[] = [{
        'content': 'xx', 'msgType': 1
      }];
      let isMsg = CommonService.judgeIsSelectText(mmsSource);
      expect(isMsg).assertTrue();
    })

    it('CommonService_judgeIsSelectText_msgType_2', 0, () => {
      let mmsSource: Record<string, string | number>[] = [{
        'content': 'xx', 'msgType': 2
      }];
      let isMsg = CommonService.judgeIsSelectText(mmsSource);
      expect(isMsg).assertTrue();
    })

    it('CommonService_judgeIsSelectText_msgType_3', 0, () => {
      let mmsSource: Record<string, string | number>[] = [{
        'content': 'xx', 'msgType': 3
      }];
      let isMsg = CommonService.judgeIsSelectText(mmsSource);
      expect(isMsg).assertTrue();
    })

    it('CommonService_judgeIsSelectText_msgType_3_content_empty', 0, () => {
      let mmsSource: Record<string, string | number>[] = [{
        'content': '', 'msgType': 3
      }];
      let isMsg = CommonService.judgeIsSelectText(mmsSource);
      expect(isMsg).assertFalse();
    })

    it('CommonService_judgeIsSelectText_judgeIsImage_msgType_1', 0, () => {
      let mmsSource: Record<string, number>[] = [{
        'msgType': 1
      }];
      let isMsg = CommonService.judgeIsImage(mmsSource);
      expect(isMsg).assertTrue();
    })

    it('CommonService_judgeIsSelectText_judgeIsImage_msgType_2', 0, () => {
      let mmsSource: Record<string, number>[] = [{
        'msgType': 2
      }];
      let isMsg = CommonService.judgeIsImage(mmsSource);
      expect(isMsg).assertFalse();
    })

    it('CommonService_getTransmitContentHeight_msgShowType_0', 0, () => {
      let list: LooseObject[] = [{
        "msgShowType": 0
      }];
      let height1 = CommonService.getTransmitContentHeight(list);
      expect(height1).assertEqual(170);
    })

    it('CommonService_getTransmitContentHeight_msgShowType_4', 0, () => {
      let list: LooseObject[] = [{
        "msgShowType": 4
      }];
      let height1 = CommonService.getTransmitContentHeight(list);
      expect(height1).assertEqual(320);
    })

    it('CommonService_getTransmitContentHeight_msgShowType_4_length_3', 0, () => {
      let list: LooseObject[] = [{
        "msgShowType": 4
      }, {
        "msgShowType": 4
      }, {
        "msgShowType": 4
      }];
      let height1 = CommonService.getTransmitContentHeight(list);
      expect(height1).assertEqual(650);
    })

    it('CommonService_getTransmitContentHeight_msgShowType_3', 0, () => {
      let list: LooseObject[] = [{
        "msgShowType": 3
      }];
      let height1 = CommonService.getTransmitContentHeight(list);
      expect(height1).assertEqual(240);
    })

    it('CommonService_getTransmitContentHeight_msgShowType_1', 0, () => {
      let list: LooseObject[] = [{
        "msgShowType": 1
      }];
      let height1 = CommonService.getTransmitContentHeight(list);
      expect(height1).assertEqual(220);
    })

    it('CommonService_getTransmitContentHeight_msgShowType_2', 0, () => {
      let list: LooseObject[] = [{
        "msgShowType": 2
      }];
      let height1 = CommonService.getTransmitContentHeight(list);
      expect(height1).assertEqual(220);
    })

    it('CommonService_judgeIsAttachment_length_0', 0, () => {
      let mmsSource: LooseObject[] = [];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertFalse();
    });

    it('CommonService_judgeIsAttachment_length_1_msgType_1', 0, () => {
      let mmsSource: LooseObject[] = [{
        'msgType': 1
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertTrue();
    });

    it('CommonService_judgeIsAttachment_length_1_msgType_2', 0, () => {
      let mmsSource: LooseObject[] = [{
        'msgType': 2
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertTrue();
    });

    it('CommonService_judgeIsAttachment_length_1_msgType_3', 0, () => {
      let mmsSource: LooseObject[] = [{
        'msgType': 3
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertTrue();
    });

    it('CommonService_judgeIsAttachment_length_1_msgType_9', 0, () => {
      let mmsSource: LooseObject[] = [{
        'msgType': 9
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertTrue();
    });

    it('CommonService_judgeIsAttachment_length_1_isVcard', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.isVcard))(4)
        .afterReturn(true);
      let mmsSource: LooseObject[] = [{
        'msgType': 4
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertTrue();
      mocker.clear(MmsUtil);
    });

    it('CommonService_judgeIsAttachment_length_1_isFile', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.isFile))(8)
        .afterReturn(true);
      let mmsSource: LooseObject[] = [{
        'msgType': 8
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertTrue();
      mocker.clear(MmsUtil);
    });

    it('CommonService_judgeIsAttachment_length_1_isRcsMap', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.isRcsMap))(7)
        .afterReturn(true);
      let mmsSource: LooseObject[] = [{
        'msgType': 7
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertTrue();
      mocker.clear(MmsUtil);
    });

    it('CommonService_judgeIsAttachment_length_1_msgType_0', 0, () => {
      let mmsSource: LooseObject[] = [{
        'msgType': 0
      }];
      let result = CommonService.judgeIsAttachment(mmsSource);
      expect(result).assertFalse();
    });
  })
}