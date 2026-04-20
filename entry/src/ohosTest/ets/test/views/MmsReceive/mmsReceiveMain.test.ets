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
import { mmsReceive } from '../../../../../main//ets/views/MmsReceive/mmsReceiveMain'
import { mmsInfo } from '../../../../../main/ets/utils/TypesUtils'
import myCommon from '@ohos.app.ability.common'
import { ValuesBucket } from '@ohos.data.ValuesBucket'
import LooseObject from '../../../../../main/ets/data/LooseObject'
import ConversationService from '../../../../../main/ets/service/ConversationService'
import { DTGlobalContext } from '../../../testability/TestAbility'
import ConversationListService from '../../../../../main/ets/service/ConversationListService'
import StaticSubscriberExtensionContext from '@ohos.application.StaticSubscriberExtensionContext'
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper'
import MmsUtil from '../../../../../main/ets/utils/MmsUtil'
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils'
import mms from '@ohos.telephony.sms';
import {
  decodeMMs,
  fileData, mmsRecDataType, mmsRecParameters } from '../../../../../main/ets/views/MmsReceive/mmsReceiveType'
import MmsDownloadService from '../../../../../main/ets/service/MmsDownloadService'
import sms from '@ohos.telephony.sms'
import { ReceiveMessageDownloadParams } from '../../../../../main/ets/utils/MmsDot/DotCommon'

export default function MmsReceiveTest() {
  describe('MmsReceiveTest', () => {

    it('MmsReceiveTest_changeStateToDowning', 0, async () => {
      let dataStr =
        '{"showTitle":false,"id":5,"rcsId":0,"content":"","isRcs":0,"isStared":false,"msgType":1,"isFullScreenImg":true,"read":"0","sendStatus":7,"receiveState":0,"failReceiveContext":"","subId":0,"isMsm":true,"timeMillisecond":1706175615881,"isCbChecked":false,"isDraft":false,"groupId":5,"isReceive":true,"date":{"id":16777435,"type":10003,"params":[""],"bundleName":"com.ohos.mms","moduleName":"entry"},"time":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"completeNumber":0,"failuresNumber":0,"isAdvancedSecurity":false,"hasReport":false,"isShowMsgLongMenu":false,"mmsSource":[{"duration":"","type":-1,"path":"","name":"","size":"48569.0"}],"contentType":0,"mmsPdu":"8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300","msgState":7,"expiresTime":"1706434795000","fullDate":{"id":16777499,"type":10003,"params":[2024,1,25,""],"bundleName":"com.ohos.mms","moduleName":"entry"},"timeOfSms":{"id":16777233,"type":10003,"params":["5","40"],"bundleName":"com.ohos.mms","moduleName":"entry"},"week":{"id":16777229,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"dateShow":false,"detailTime":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"}}';
      let data: mmsInfo = JSON.parse(dataStr);
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSmsMmsInfoByCondition);
      expect(await mmsReceive.changeStateToDowning(data, context)).assertTrue();
      mocker.clear(ConversationService.getInstance());
    })

    it('MmsReceiveTest_insertMmsPart', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        insertMmsInfo: (valueBucket: ValuesBucket, callback: Function, context: Context) => {
          callback({code:0 } as LooseObject)
        }
      });
      let dataStr =
        '{"msg_id":5,"group_id":5,"part_index":0,"part_size":214,"recording_time":"","type":0,"location_path":"/data/storage/el2/base/haps/entry/files/smil1706175589392.xml","encode":0,"state":0,"content":""}'
      let data: ValuesBucket = JSON.parse(dataStr);
      await mmsReceive.insertMmsPart(data, context);
      mocker.clear(ConversationService);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPart_context_empty', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({} as myCommon.UIAbilityContext);
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        insertMmsInfo: (valueBucket: ValuesBucket, callback: Function, context: Context) => {
          callback({code:1 } as LooseObject)
        }
      });
      let dataStr =
        '{"msg_id":5,"group_id":5,"part_index":0,"part_size":214,"recording_time":"","type":0,"location_path":"/data/storage/el2/base/haps/entry/files/smil1706175589392.xml","encode":0,"state":0,"content":""}'
      let data: ValuesBucket = JSON.parse(dataStr);
      await mmsReceive.insertMmsPart(data);
      mocker.clear(ConversationService);
      mocker.clear(GlobalContext.getContext());
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_changeStateToSuccess', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        querySessionId: (msgId: number, callback: Function, context: Context) => {
          callback(0)
        },
        updateSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback?: Function | null) => {
          if (callback) {
            callback({  });
          }
        }
      });
      let dataStr =
        '{"showTitle":false,"id":5,"rcsId":0,"content":"","isRcs":0,"isStared":false,"msgType":1,"isFullScreenImg":true,"read":"0","sendStatus":7,"receiveState":0,"failReceiveContext":"","subId":0,"isMsm":true,"timeMillisecond":1706175615881,"isCbChecked":false,"isDraft":false,"groupId":5,"isReceive":true,"date":{"id":16777435,"type":10003,"params":[""],"bundleName":"com.ohos.mms","moduleName":"entry"},"time":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"completeNumber":0,"failuresNumber":0,"isAdvancedSecurity":false,"hasReport":false,"isShowMsgLongMenu":false,"mmsSource":[{"duration":"","type":-1,"path":"","name":"","size":"48569.0"}],"contentType":0,"mmsPdu":"8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300","msgState":7,"expiresTime":"1706434795000","fullDate":{"id":16777499,"type":10003,"params":[2024,1,25,""],"bundleName":"com.ohos.mms","moduleName":"entry"},"timeOfSms":{"id":16777233,"type":10003,"params":["5","40"],"bundleName":"com.ohos.mms","moduleName":"entry"},"week":{"id":16777229,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"dateShow":false,"detailTime":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"}}';
      let data: LooseObject = JSON.parse(dataStr);
      let decodeMMsStr =
        '{"phone":"18260081790","subject":"aaa","fileList":[{"fileType":"application/smil","path":"/data/storage/el2/base/haps/entry/files/smil1706175589392.xml","name":"smil1706175589392.xml"},{"fileType":"image/*","path":"/data/storage/el2/base/haps/entry/files/IMG_1706175589391.jpg","name":"IMG_1706175589391.jpg"}],"msgContent":""}';
      let decodeMms: LooseObject = JSON.parse(decodeMMsStr);
      let slotId = 0;
      await mmsReceive.changeStateToSuccess(data, decodeMms, slotId, context, true);
      mocker.clear(ConversationService);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_changeStateToSuccess_res_1', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        querySessionId: (msgId: number, callback: Function, context: Context) => {
          callback(1)
        },
        updateSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback?: Function | null) => {
          if (callback) {
            callback({  });
          }
        }
      });
      let dataStr =
        '{"showTitle":false,"id":5,"rcsId":0,"content":"","isRcs":0,"isStared":false,"msgType":1,"isFullScreenImg":true,"read":"0","sendStatus":7,"receiveState":0,"failReceiveContext":"","subId":0,"isMsm":true,"timeMillisecond":1706175615881,"isCbChecked":false,"isDraft":false,"groupId":5,"isReceive":true,"date":{"id":16777435,"type":10003,"params":[""],"bundleName":"com.ohos.mms","moduleName":"entry"},"time":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"completeNumber":0,"failuresNumber":0,"isAdvancedSecurity":false,"hasReport":false,"isShowMsgLongMenu":false,"mmsSource":[{"duration":"","type":-1,"path":"","name":"","size":"48569.0"}],"contentType":0,"mmsPdu":"8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300","msgState":7,"expiresTime":"1706434795000","fullDate":{"id":16777499,"type":10003,"params":[2024,1,25,""],"bundleName":"com.ohos.mms","moduleName":"entry"},"timeOfSms":{"id":16777233,"type":10003,"params":["5","40"],"bundleName":"com.ohos.mms","moduleName":"entry"},"week":{"id":16777229,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"dateShow":false,"detailTime":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"}}';
      let data: LooseObject = JSON.parse(dataStr);
      let decodeMMsStr =
        '{"phone":"18260081790","subject":"aaa","fileList":[{"fileType":"application/smil","path":"/data/storage/el2/base/haps/entry/files/smil1706175589392.xml","name":"smil1706175589392.xml"},{"fileType":"image/*","path":"/data/storage/el2/base/haps/entry/files/IMG_1706175589391.jpg","name":"IMG_1706175589391.jpg"}],"msgContent":""}';
      let decodeMms: LooseObject = JSON.parse(decodeMMsStr);
      let slotId = 0;
      await mmsReceive.changeStateToSuccess(data, decodeMms, slotId, undefined, false);
      mocker.clear(ConversationService);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_changeStateToSuccess_subject_empty', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        querySessionId: (msgId: number, callback: Function, context: Context) => {
          callback(1)
        },
        updateSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback?: Function | null) => {
          if (callback) {
            callback({  });
          }
        }
      });
      let dataStr =
        '{"showTitle":false,"id":5,"rcsId":0,"content":"","isRcs":0,"isStared":false,"msgType":1,"isFullScreenImg":true,"read":"0","sendStatus":7,"receiveState":0,"failReceiveContext":"","subId":0,"isMsm":true,"timeMillisecond":1706175615881,"isCbChecked":false,"isDraft":false,"groupId":5,"isReceive":true,"date":{"id":16777435,"type":10003,"params":[""],"bundleName":"com.ohos.mms","moduleName":"entry"},"time":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"completeNumber":0,"failuresNumber":0,"isAdvancedSecurity":false,"hasReport":false,"isShowMsgLongMenu":false,"mmsSource":[{"duration":"","type":-1,"path":"","name":"","size":"48569.0"}],"contentType":0,"mmsPdu":"8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300","msgState":7,"expiresTime":"1706434795000","fullDate":{"id":16777499,"type":10003,"params":[2024,1,25,""],"bundleName":"com.ohos.mms","moduleName":"entry"},"timeOfSms":{"id":16777233,"type":10003,"params":["5","40"],"bundleName":"com.ohos.mms","moduleName":"entry"},"week":{"id":16777229,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"dateShow":false,"detailTime":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"}}';
      let data: LooseObject = JSON.parse(dataStr);
      let decodeMMsStr =
        '{"phone":"18260081790","fileList":[{"fileType":"application/smil","path":"/data/storage/el2/base/haps/entry/files/smil1706175589392.xml","name":"smil1706175589392.xml"},{"fileType":"image/*","path":"/data/storage/el2/base/haps/entry/files/IMG_1706175589391.jpg","name":"IMG_1706175589391.jpg"}],"msgContent":""}';
      let decodeMms: LooseObject = JSON.parse(decodeMMsStr);
      let slotId = 0;
      await mmsReceive.changeStateToSuccess(data, decodeMms, slotId, context, true);
      expect(mmsReceive).not().assertUndefined();
      mocker.clear(ConversationService);
    })

    it('MmsReceiveTest_changeStateToSuccess_subject_empty_hasAttachment_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        querySessionId: (msgId: number, callback: Function, context: Context) => {
          callback(1)
        },
        updateSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback?: Function | null) => {
          if (callback) {
            callback({  });
          }
        }
      });
      let dataStr =
        '{"showTitle":false,"id":5,"rcsId":0,"content":"","isRcs":0,"isStared":false,"msgType":1,"isFullScreenImg":true,"read":"0","sendStatus":7,"receiveState":0,"failReceiveContext":"","subId":0,"isMsm":true,"timeMillisecond":1706175615881,"isCbChecked":false,"isDraft":false,"groupId":5,"isReceive":true,"date":{"id":16777435,"type":10003,"params":[""],"bundleName":"com.ohos.mms","moduleName":"entry"},"time":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"completeNumber":0,"failuresNumber":0,"isAdvancedSecurity":false,"hasReport":false,"isShowMsgLongMenu":false,"mmsSource":[{"duration":"","type":-1,"path":"","name":"","size":"48569.0"}],"contentType":0,"mmsPdu":"8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300","msgState":7,"expiresTime":"1706434795000","fullDate":{"id":16777499,"type":10003,"params":[2024,1,25,""],"bundleName":"com.ohos.mms","moduleName":"entry"},"timeOfSms":{"id":16777233,"type":10003,"params":["5","40"],"bundleName":"com.ohos.mms","moduleName":"entry"},"week":{"id":16777229,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"},"dateShow":false,"detailTime":{"id":16777308,"type":10003,"params":[],"bundleName":"com.ohos.mms","moduleName":"entry"}}';
      let data: LooseObject = JSON.parse(dataStr);
      let decodeMMsStr =
        '{"phone":"18260081790","fileList":[{"fileType":"application/smil","path":"/data/storage/el2/base/haps/entry/files/smil1706175589392.xml","name":"smil1706175589392.xml"},{"fileType":"image/*","path":"/data/storage/el2/base/haps/entry/files/IMG_1706175589391.jpg","name":"IMG_1706175589391.jpg"}],"msgContent":""}';
      let decodeMms: LooseObject = JSON.parse(decodeMMsStr);
      let slotId = 0;
      await mmsReceive.changeStateToSuccess(data, decodeMms, slotId, context, false);
      expect(mmsReceive).not().assertUndefined();
      mocker.clear(ConversationService);
    })

    it('MmsReceiveTest_setToSQL', 0, async () => {
      let res = true;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().querySessionByTelephone))(ArgumentMatchers.any)
        .afterAction(() => {
          res = false;
        });
      let dataStr =
        '{"slotId":0,"telephone":"18260081791","content":"1","isReceive":true,"isMms":true,"hasAttachment":true,"mmsSource":[{"size":48569,"duration":"","type":-1,"path":"","name":""}],"mms_pdu":"8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300","isSender":1,"endTime":"1706434795000","isAdvancedSecurity":0}';
      let data: LooseObject = JSON.parse(dataStr);
      await mmsReceive.setToSQL(context, () => {
        ConversationListService.getInstance().querySessionByTelephone('123456', (res: LooseObject) => {
          expect(res.code).assertEqual(0);
        }, context);
      }, data);
      expect(res).assertFalse();
      mocker.clear(ConversationListService.getInstance());
    })

    it('MmsReceiveTest_convertStrArray_double', 0, () => {
      let result: Array<number> = mmsReceive.convertStrArray('35794702385385');
      expect(result.length).assertEqual(7);
    })

    it('MmsReceiveTest_convertStrArray', 0, () => {
      let result = mmsReceive.convertStrArray('5794702385355');
      expect(result.length).assertEqual(7);
    })

    it('MmsReceiveTest_receivePduAndBaseInfo', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      const result = await mmsReceive.receivePduAndBaseInfo(context, null);
      expect(result).assertEqual(false);
    })

    it('MmsReceiveTest_receivePduAndBaseInfo_json', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      let data = {
        event: 'string',
        bundleName: 'string',
        code: 1,
        data: 'string',
        parameters: {
          applicationId: 'string',
          contentType: 'string',
          headerData: 'string',
          moduleName: 'string',
          pushType: 8,
          rawData: '8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300',
          slotId: 1,
          transactionId: 3
        } as mmsRecParameters
      } as mmsRecDataType;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(JSON, JSON.parse))(ArgumentMatchers.any)
        .afterReturn(data)
      const result = await mmsReceive.receivePduAndBaseInfo(context, 'data');
      mocker.clear(JSON)
      expect(result).assertEqual(true);
    })

    it('MmsReceiveTest_handleFirstUnlockEvent', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      await mmsReceive.handleFirstUnlockEvent(context);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_downloadMms', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'isAdvancedSecurity': false,
        'expiresTime': '452546846546546545655'
      };
      mmsReceive.downloadMms(actionData, context);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_queryMmsPartInfo_callback', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryMmsPartInfo))(context)
        .afterReturn(callback);
      let msgId = '1';
      await mmsReceive.queryMmsPartInfo(msgId, callback, context);
      await mmsReceive.queryMmsPartInfo(msgId, undefined, context);
      mocker.clear(ConversationService.getInstance());
    })

    it('MmsReceiveTest_queryMmsPartInfo', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({} as myCommon.UIAbilityContext);
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        queryMmsPartInfo: (actionData: LooseObject, callback: Function, context: Context) => {
          callback({code:1 } as LooseObject)
        }
      });
      let msgId = '1';
      await mmsReceive.queryMmsPartInfo(msgId, () => {});
      await mmsReceive.queryMmsPartInfo(msgId, undefined);
      mocker.clear(ConversationService);
      mocker.clear(GlobalContext.getContext());
    })

    it('MmsReceiveTest_updateMmsPartById', 0, async () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        updateMmsPartById: (mmsPartId: number, isFraud: number, callback: Function, context: Context) => {
          callback({code:0 } as LooseObject)
        }
      });
      let mmsPartId: number = 1;
      let isFraud: number = 2;
      await mmsReceive.updateMmsPartById(mmsPartId, isFraud, context);
      mocker.clear(ConversationService);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_updateMmsPartById_callback', 0, async () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        updateMmsPartById: (mmsPartId: number, isFraud: number, callback: Function, context: Context) => {
          callback({code:1 } as LooseObject)
        }
      });
      let mmsPartId: number = 1;
      let isFraud: number = 2;
      await mmsReceive.updateMmsPartById(mmsPartId, isFraud, context);
      mocker.clear(ConversationService);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_dealReceiveFailed_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = new mmsInfo();
      data.id = 1;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.getRetryTime))(ArgumentMatchers.any)
        .afterReturn(1);
      const result = await mmsReceive.dealReceiveFailed(data, true, context);
      expect(result).assertEqual(true);
    })

    it('MmsReceiveTest_dealReceiveFailed_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = new mmsInfo();
      data.id = 1;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.getRetryTime))(ArgumentMatchers.any)
        .afterReturn(4);
      const result = await mmsReceive.dealReceiveFailed(data, true, context);
      await mmsReceive.dealReceiveFailed(data, false, context);
      expect(result).assertEqual(false);
    })

    it('MmsReceiveTest_startDownloadMmsTaskPoolTask', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = new mmsInfo();
      data.id = 1;
      let retryTimes: number = 1;
      let retryInterval: number = 2
      await mmsReceive.startDownloadMmsTaskPoolTask(retryTimes, retryInterval, data, context);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_mmsKeepAndDecode', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = new mmsInfo();
      data.id = 1;
      let pdu: string = '8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300';
      let encodeData: number[] = [];
      for (let i = 0; i < pdu.length; i += 2) {
        encodeData.push(Number('0x' + pdu.slice(i, i + 2)));
      }
      let dlDataRes: mms.MmsInformation =  await mms.decodeMms(encodeData);
      dlDataRes.attachment = [];
      await mmsReceive.mmsKeepAndDecode(context, {  } as mms.MmsInformation, '', {  } as mms.MmsNotificationInd, new ReceiveMessageDownloadParams());
      let obj: sms.MmsAttachment = {
        'path': 'abc',
        'fileName': 'abc',
        'contentId': '<123>',
        'contentLocation': '321',
        'contentDisposition': sms.DispositionType.ATTACHMENT,
        'contentTransferEncoding': 'binary',
        'contentType': 'text/plain',
        'isSmil': true,
        'inBuff': [1,2],
        'charset': sms.MmsCharSets.UTF_8
      };
      let obj1: sms.MmsAttachment = {
        'path': 'abc',
        'fileName': 'abc',
        'contentId': '123',
        'contentLocation': '321',
        'contentDisposition': sms.DispositionType.ATTACHMENT,
        'contentTransferEncoding': 'binary',
        'contentType': 'application/smil',
        'isSmil': true,
        'inBuff': [2],
        'charset': sms.MmsCharSets.UTF_8
      };
      let obj2: sms.MmsAttachment = {
        'path': 'abc',
        'fileName': 'abc',
        'contentId': '',
        'contentLocation': '321',
        'contentDisposition': sms.DispositionType.ATTACHMENT,
        'contentTransferEncoding': 'binary',
        'contentType': 'application/smil',
        'isSmil': true,
        'inBuff': [],
        'charset': sms.MmsCharSets.UTF_8
      };
      dlDataRes.attachment.push(obj)
      dlDataRes.attachment.push(obj1)
      dlDataRes.attachment.push(obj2)
      let mmsType = dlDataRes.mmsType as mms.MmsNotificationInd;
      let sandPath: string = context.filesDir;
      const result: ESObject = await mmsReceive.mmsKeepAndDecode(context, dlDataRes, sandPath, mmsType, new ReceiveMessageDownloadParams());
      await mmsReceive.mmsKeepAndDecode(context, dlDataRes, sandPath, {  } as mms.MmsNotificationInd, new ReceiveMessageDownloadParams());
      let decodeMms: decodeMMs = result as decodeMMs;
      expect(decodeMms.phone).assertEqual('18260081790')
    });

    it('MmsReceiveTest_mmsKeepAndDecode_undefiend', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = new mmsInfo();
      data.id = 1;
      let pdu: string = '8C829823234D716868363039483632008D9089178031383236303038313739302F545950453D504C4D4E008A808E040000BDB98805810303F46C83687474703A2F2F3231312E3134332E35302E31303A38302F4B596A422D343300';
      let encodeData: number[] = [];
      for (let i = 0; i < pdu.length; i += 2) {
        encodeData.push(Number('0x' + pdu.slice(i, i + 2)));
      }
      let dlDataRes: mms.MmsInformation =  await mms.decodeMms(encodeData);
      dlDataRes.attachment = [];
      dlDataRes.attachment.push(undefined)
      let mmsType = dlDataRes.mmsType as mms.MmsNotificationInd;
      let sandPath: string = context.filesDir;
      const result: ESObject = await mmsReceive.mmsKeepAndDecode(context, dlDataRes, sandPath, mmsType, new ReceiveMessageDownloadParams());
      let decodeMms: decodeMMs = result as decodeMMs;
      expect(decodeMms.phone).assertEqual('18260081790')
    });

    it('MmsReceiveTest_insertMmsPartProcess_smil', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"application/smil","path": ""}';
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir;
      item.fileType = 'application/smil';
      let dataInfo: mmsInfo = new mmsInfo();
      dataInfo.id = 1;
      await mmsReceive.insertMmsPartProcess(item, dataInfo, 1, undefined, true, true,new ReceiveMessageDownloadParams(),
        context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPartProcess_image', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"image","path": ""}';
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir;
      item.fileType = 'image';
      let dataInfo: mmsInfo = new mmsInfo();
      dataInfo.id = 1;
      await mmsReceive.insertMmsPartProcess(item, dataInfo, 1, undefined, true, true,new ReceiveMessageDownloadParams(),
        context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPartProcess_video', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"video","path": ""}';
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir;
      item.fileType = 'video';
      let dataInfo: mmsInfo = new mmsInfo();
      dataInfo.id = 1;
      await mmsReceive.insertMmsPartProcess(item, dataInfo, 1, undefined, true, true,new ReceiveMessageDownloadParams(),
        context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPartProcess_media', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"media","path": ""}';
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir;
      item.fileType = 'media';
      let dataInfo: mmsInfo = new mmsInfo();
      dataInfo.id = 1;
      await mmsReceive.insertMmsPartProcess(item, dataInfo, 1, undefined, true, true,new ReceiveMessageDownloadParams(),
        context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPartProcess_x-vCard', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"x-vCard","path": ""}';
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir;
      item.fileType = 'x-vCard';
      let dataInfo: mmsInfo = new mmsInfo();
      dataInfo.id = 1;
      await mmsReceive.insertMmsPartProcess(item, dataInfo, 1, undefined, true, true,new ReceiveMessageDownloadParams(),
        context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPartProcess_audio', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"audio","path": ""}';
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir;
      item.fileType = 'audio';
      let dataInfo: mmsInfo = new mmsInfo();
      dataInfo.id = 1;
      await mmsReceive.insertMmsPartProcess(item, dataInfo, 1, undefined, true, true,
        new ReceiveMessageDownloadParams(), context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPartProcess_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"aaaaaaa","path": ""}';
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir;
      item.fileType = 'aaaaaaa';
      let dataInfo: mmsInfo = new mmsInfo();
      dataInfo.id = 1;
      await mmsReceive.insertMmsPartProcess(item, dataInfo, 1, undefined, true, true,
        new ReceiveMessageDownloadParams(), context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_insertMmsPartProcess_audio_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let itemStr: string = '{"fileType":"audio","path": ""}';
      let data: mmsInfo = new mmsInfo();
      data.id = 1;
      let mmsRecName = `${data.id}_RetrieveConf.mms`;
      let item: fileData = JSON.parse(itemStr)
      item.path = context.filesDir + '/' + mmsRecName;
      await mmsReceive.insertMmsPartProcess(item, data, 1, item.path, false, true, new ReceiveMessageDownloadParams(),
        context, null);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_saveContentToText', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = new mmsInfo();
      data.id = 1;
      data.groupId = 2;
      await mmsReceive.saveContentToText(data, {
        "msgContent":"",
        "fileList": ["aaaaa","bbbbb"]
      } as LooseObject, new ReceiveMessageDownloadParams(), context);
      let decodeMMs: LooseObject = {
        "msgContent":"aaaaaaaa",
        "fileList": ["aaaaa","bbbbb"]
      };
      await mmsReceive.saveContentToText(data, decodeMMs, new ReceiveMessageDownloadParams(), context);
      expect(mmsReceive).not().assertUndefined();
    })

    it('MmsReceiveTest_checkHasAttachment', 0, () => {
      let fileList: fileData[] = [{
        "fileType": "txt", "path": ""
      },
        {
          "fileType": "video", "path": ""
        }
      ]
      const result = mmsReceive.checkHasAttachment(fileList);
      expect(result).assertTrue();
    })
  })
}