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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach, } from '@ohos/hypium';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { DTGlobalContext } from '../../../testability/TestAbility';
import ConversationController, {
  ActionDataType,
  mmsListType,
} from '../../../../../main/ets/pages/conversation/conversationController';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import { ContactType, Mms, mmsInfo, packingItem } from '../../../../../main/ets/utils/TypesUtils';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { window } from '@kit.ArkUI';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import ImageUtil from '../../../../../main/ets/utils/ImageUtil';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';
import ObjectUtil from '../../../../../main/ets/utils/ObjectUtil';
import FileUtil from '../../../../../main/ets/utils/FileUtil';
import SmilFile from '../../../../../main/ets/utils/SmilFile';
import { mmsReceive } from '../../../../../main/ets/views/MmsReceive/mmsReceiveMain';
import { image } from '@kit.ImageKit';
import { VCardUtil } from '../../../../../main/ets/utils/VCardUtil';
import { ContactTypeForUI } from '../../../../../main/ets/views/AttachmentArea/MMMoreDialog';

export default function conversationControllerPart6Test() {
  describe('conversationControllerTest6', () => {

    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      ConversationController.release();
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('conversationController_dealMmsMessageResult_tmplBol_true', 0, () => {
      let actionData: ActionDataType = {
        contactName: 'name',
        destinationHost: 'host',
      } as ActionDataType;
      mConversationCtrl.sendReportable = true;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);

      mConversationCtrl.dealMmsMessageResult(context, actionData, 0);

      mocker.verify('showToast', ['xx']).once();

      mocker.clear(GlobalContext.getContext());

      mConversationCtrl.sendReportable = false;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      mConversationCtrl.dealMmsMessageResult(context, actionData, 0);
      mocker.verify('showToast', ['xx']).once();
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_initMmsItem', 0, () => {
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
        .afterReturn('xx');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getMmsDataSource))()
        .afterReturn(new Promise<Mms[]>(resolve => resolve([])));
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any)
        .afterReturn(1);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      let item: mmsListType = new mmsListType();
      mConversationCtrl.initSendItem(context, item, '');

      expect(mConversationCtrl.isSendPicture).assertFalse();

      mocker.clear(DateUtil);
      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('conversationController_initMmsItem', 0, () => {
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
        .afterReturn('xx');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getMmsDataSource))()
        .afterReturn(new Promise<Mms[]>(resolve => resolve([])));
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any)
        .afterReturn(1);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      let item: mmsListType = new mmsListType();
      mConversationCtrl.initSendItem(context, item, '');

      expect(mConversationCtrl.isSendPicture).assertFalse();

      mocker.clear(DateUtil);
      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('conversationController_resetAttachAreaPicture', 0, () => {
      mocker.mockFunc(mConversationCtrl.pictureCtrl, mConversationCtrl.pictureCtrl.resetPictureStatus);
      mConversationCtrl.resetAttachAreaPicture();
      mocker.clear(mConversationCtrl.pictureCtrl);
    })

    it('conversationController_initSouce_isEnd_true_type_2', 0, async () => {
      let mms: Mms = {
        type: 2,
        copyPath: '',
        name: 'name',
        galleryPath: '',
        path: '',
        size: '1'
      } as Mms;
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [mms];

      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn(mms);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any)
        .afterReturn('1');

      await mConversationCtrl.initSouce(context, false, 0);

      expect(mConversationCtrl).not().assertUndefined();

      mocker.clear(ObjectUtil);
      mocker.clear(FileUtil);
      mocker.clear(JSON);
    })

    it('conversationController_initSouce_isEnd_true_type_2_galleryPath_undefined', 0, async () => {
      let mms: Mms = {
        type: 2,
        copyPath: '',
        name: 'name',
        galleryPath: undefined,
        path: '',
        size: '1'
      } as Mms;
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [mms];

      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn(mms);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any)
        .afterReturn('1');

      await mConversationCtrl.initSouce(context, false, 0);

      expect(mConversationCtrl).not().assertUndefined();

      mocker.clear(ObjectUtil);
      mocker.clear(FileUtil);
      mocker.clear(JSON);
    })

    it('conversationController_initSouce_type_1_byteLength_0', 0, async () => {
      let mms: Mms = {
        type: 1,
        copyPath: '',
        name: 'name',
        galleryPath: '',
        path: '',
        size: '1'
      } as Mms;
      let mms1: Mms = {
        type: 1,
        copyPath: '',
        name: 'name',
        galleryPath: undefined,
        path: '/',
        size: '1'
      } as Mms;
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [mms, mms1];

      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn(mms);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(0)
        } as packingItem)));
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))()
        .afterReturn('');
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any)
        .afterReturn('1');

      await mConversationCtrl.initSouce(context, false, 0);

      expect(mConversationCtrl).not().assertUndefined();

      mocker.clear(ObjectUtil);
      mocker.clear(FileUtil);
      mocker.clear(JSON);
    })

    it('conversationController_getMmsDataSource_mmDisplaySource_length_0', 0, async () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [];
      let res: Array<Mms> = await mConversationCtrl.getMmsDataSource(context, '', [], ()=>{}, ()=>{});
      expect(res.length).assertEqual(0);
    })

    it('conversationController_getMmsDataSource_mmDisplaySource_length_1', 0, async () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      mConversationCtrl.mAttachAreaCtrl.copySource = [{} as Mms];
      mConversationCtrl.textValue = 'xx';
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTextSource))()
        .afterReturn({} as Mms);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any)
        .afterReturn({} as Mms);

      let res: Array<Mms> = await mConversationCtrl.getMmsDataSource(context, 'xx', [{} as Mms], ()=>{}, ()=>{});

      expect(res.length).assertEqual(3);
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_getMmsDataSource_mmDisplaySource_length_1_textValue_empty', 0, async () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      mConversationCtrl.mAttachAreaCtrl.copySource = [{} as Mms];
      mConversationCtrl.textValue = '';
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any)
        .afterReturn({} as Mms);

      let res: Array<Mms> = await mConversationCtrl.getMmsDataSource(context, '', [{} as Mms], ()=>{}, ()=>{});

      expect(res.length).assertEqual(2);
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_getSmilSource', 0, () => {
      when(mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox))(ArgumentMatchers.any)
        .afterReturn({
          'path': '',
          'name': 'name'
        } as Record<string, string>);
      when(mocker.mockFunc(SmilFile, SmilFile.getSmil))(ArgumentMatchers.any)
        .afterReturn('');

      let res: Mms = mConversationCtrl.getSmilSource(context, 'xx', []);

      expect(res == null).assertFalse();

      mocker.clear(FileUtil);
      mocker.clear(SmilFile);
    })

    it('conversationController_getTextSource', 0, () => {
      when(mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox))(ArgumentMatchers.any)
        .afterReturn({
          'path': '',
          'name': 'name'
        } as Record<string, string>);

      let res: Mms = mConversationCtrl.getTextSource(context, '');

      expect(res.name).assertEqual('name');

      mocker.clear(FileUtil);
    })

    it('conversationController_recentEmojiList', 0, () => {
      let emojiArr: number[] = [1, 2];
      let currentValue = JSON.stringify(emojiArr);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn([currentValue, '']);
      let res: string[] = mConversationCtrl.recentEmojiList(emojiArr);

      expect(res.length).assertEqual(2);

      mocker.clear(SharedPreferencesUtils);
    })

    it('conversationController_recentEmojiList_length_28', 0, () => {
      let emojiArr: number[] = [1, 2];
      let testEmoji: string[] = new Array<string>(28);
      for (let i = 0; i < 28; i++) {
        testEmoji.push('');
      }
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(testEmoji);
      let res: string[] = mConversationCtrl.recentEmojiList(emojiArr);

      expect(res.length).assertEqual(56);

      mocker.clear(SharedPreferencesUtils);
    })

    it('conversationController_getRecentEmojiList', 0, () => {
      when(mocker.mockFunc(JSON,JSON.parse))(ArgumentMatchers.any)
        .afterReturn(1);

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(JSON.stringify(['1']));

      let res: number[][] = mConversationCtrl.getRecentEmojiList();

      expect(JSON.stringify(res)).assertEqual('[1,1,1,1,1]');

      mocker.clear(SharedPreferencesUtils);
      mocker.clear(JSON);
    })

    it('conversationController_getTabSrc_index_1', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(1);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_person.svg')));
    })

    it('conversationController_getTabSrc_index_2', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(2);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_animal.svg')));
    })

    it('conversationController_getTabSrc_index_3', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(3);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_food.svg')));
    })

    it('conversationController_getTabSrc_index_4', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(4);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_activity.svg')));
    })

    it('conversationController_getTabSrc_index_5', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(5);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_travel.svg')));
    })

    it('conversationController_getTabSrc_index_6', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(6);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_body.svg')));
    })

    it('conversationController_getTabSrc_index_7', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(7);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_symbol.svg')));
    })

    it('conversationController_getTabSrc_index_8', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(8);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_flag.svg')));
    })

    it('conversationController_getTabSrc_index_9', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(9);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_flag.svg')));
    })

    it('conversationController_getTabSrc_index_10', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrc(10);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($rawfile('icon/emo_recent.svg')));
    })

    it('conversationController_getTabSrcSelected_index_1', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(1);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_person_selected')));
    })

    it('conversationController_getTabSrcSelected_index_2', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(2);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_animal_selected')));
    })

    it('conversationController_getTabSrcSelected_index_3', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(3);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_food_selected')));
    })

    it('conversationController_getTabSrcSelected_index_4', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(4);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_activity_selected')));
    })

    it('conversationController_getTabSrcSelected_index_5', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(5);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_travel_selected')));
    })

    it('conversationController_getTabSrcSelected_index_6', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(6);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_body_selected')));
    })

    it('conversationController_getTabSrcSelected_index_7', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(7);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_symbol_selected')));
    })

    it('conversationController_getTabSrcSelected_index_8', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(8);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_flag_selected')));
    })

    it('conversationController_getTabSrcSelected_index_9', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(9);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_flag_selected')));
    })

    it('conversationController_getTabSrcSelected_index_10', 0, () => {
      let res: Resource = mConversationCtrl.getTabSrcSelected(10);
      expect(JSON.stringify(res)).assertEqual(JSON.stringify($r('app.media.emo_recent_selected')));
    })

    it('conversationController_downloadMms_result_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = {
        id: 1
      } as mmsInfo;
      when(mocker.mockFunc(mmsReceive, mmsReceive.changeStateToDowning))(data)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mocker.mockFunc(mmsReceive, mmsReceive.startDownloadMMs);

      await mConversationCtrl.downloadMms(data, context);

      mocker.verify('startDownloadMMs', [data]).never();
      mocker.clear(mmsReceive);
    })

    it('conversationController_downloadMms_result_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: mmsInfo = {
        id: 1
      } as mmsInfo;
      when(mocker.mockFunc(mmsReceive, mmsReceive.changeStateToDowning))(data)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      mocker.mockFunc(mmsReceive, mmsReceive.startDownloadMMs);

      await mConversationCtrl.downloadMms(data, context);

      mocker.verify('startDownloadMMs', [data]).never();
      mocker.clear(mmsReceive);
    })

    it('conversationController_canResendMms', 0, () => {
      mConversationCtrl.isAirPlaneMode = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);

      let res: boolean = mConversationCtrl.canResendMms(true);

      expect(res).assertFalse();

      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_canResendMms_isAirPlaneMode_true', 0, () => {
      mConversationCtrl.isAirPlaneMode = true;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      let res: boolean = mConversationCtrl.canResendMms(true);
      expect(res).assertFalse();
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_canResendMms_isMms_false', 0, () => {
      mConversationCtrl.isAirPlaneMode = true;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      let res: boolean = mConversationCtrl.canResendMms(false);
      expect(res).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_adjustLowListHeight_currentSendBarGlobalY', 0, () => {
      let res: boolean = mConversationCtrl.adjustLowListHeight(-1, 1, 1);
      expect(res).assertFalse();
    })

    it('conversationController_adjustLowListHeight_msgListGlobalY', 0, () => {
      let res: boolean = mConversationCtrl.adjustLowListHeight(1, -1, 1);
      expect(res).assertFalse();
    })

    it('conversationController_adjustLowListHeight_true', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateListHeightInsensitive);
      let res: boolean = mConversationCtrl.adjustLowListHeight(1, 1, 1);
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_updateListHeightInsensitive_listLightTimerId_1', 0, () => {
      let res: boolean = mConversationCtrl.updateListHeightInsensitive(1, 1);
      expect(res).assertTrue();
    })

    it('conversationController_updateListHeightInsensitive_listLightTimerId_minus1', 0, () => {
      let res: boolean = mConversationCtrl.updateListHeightInsensitive(1, -1);
      expect(res).assertFalse();
    })

    it('conversationController_deleteCharForEmojiStr_index_minus1', 0, () => {
      let res: string = mConversationCtrl.deleteCharForEmojiStr('', -1);
      expect(res).assertEqual('');
    })

    it('conversationController_deleteCharForEmojiStr_index_2', 0, () => {
      let res: string = mConversationCtrl.deleteCharForEmojiStr('', 2);
      expect(res).assertEqual('');
    })

    it('conversationController_deleteCharForEmojiStr_relatedEmojisLength_0', 0, () => {
      let res: string = mConversationCtrl.deleteCharForEmojiStr('xxx', 1);
      expect(res).assertEqual('xx');
    })

    it('conversationController_deleteCharForEmojiStr_subStr_equal_emojiStr', 0, () => {
      let res: string = mConversationCtrl.deleteCharForEmojiStr('😊', 1);
      expect(res).assertEqual('');
    })

    it('conversationController_deleteCharForEmojiStr_', 0, () => {
      let res: string = mConversationCtrl.deleteCharForEmojiStr('😊😃', 0);
      expect(res).assertEqual('😃');
    })

    it('conversationController_showBubbleOrEmoji', 0, () => {
      let res: boolean = mConversationCtrl.showBubbleOrEmoji('😊', 2);
      expect(res).assertFalse();
    })

    it('conversationController_showBubbleOrEmoji_len_greaterThan_emojiCount', 0, () => {
      let res: boolean = mConversationCtrl.showBubbleOrEmoji('😊😃', 0);
      expect(res).assertTrue();
    })

    it('conversationController_showBubbleOrEmoji_emoji_notExist', 0, () => {
      let res: boolean = mConversationCtrl.showBubbleOrEmoji('xx', 1);
      expect(res).assertTrue();
    })

    it('conversationController_isHasEmoji_string', 0, () => {
      let res: boolean = mConversationCtrl.isHasEmoji('string');
      expect(res).assertFalse();
    })

    it('conversationController_isHasEmoji_notHave', 0, () => {
      let res: boolean = mConversationCtrl.isHasEmoji('xx');
      expect(res).assertFalse();
    })

    it('conversationController_isHasEmoji_has', 0, () => {
      let res: boolean = mConversationCtrl.isHasEmoji('😊');
      expect(res).assertTrue();
    })

    it('conversationController_getMmsCount', 0, () => {
      let mmslist: mmsListType = new mmsListType();
      mmslist.isCbChecked = false;
      mmslist.mmsPdu = 'pdu';
      let mmslist1: mmsListType = new mmsListType();
      mmslist1.isCbChecked = true;
      mmslist1.mmsPdu = 'pdu';
      mConversationCtrl.mmsList = [mmslist, mmslist1];

      let res: boolean = mConversationCtrl.getMmsCount();
      expect(res).assertTrue();
    })

    it('conversationController_setMmsDataSource_size_0', 0, async () => {
      let mmsSource: Array<Mms> = [{
        path: ''
      } as Mms];
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          size: 0,
          data: new ArrayBuffer(0)
        } as packingItem)));

      await mConversationCtrl.setMmsDataSource(context, mmsSource);

      mocker.clear(FileUtil);

      expect(mConversationCtrl).not().assertUndefined();
    })

    it('conversationController_setMmsDataSource_size_1_type_9', 0, async () => {
      let mmsSource: Array<Mms> = [{
        path: ''
      } as Mms];
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          size: 1,
          data: new ArrayBuffer(0)
        } as packingItem)));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('fileTotalSize')
        .afterReturn(1);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMmsDataSourcePushListItem))(ArgumentMatchers.any)
        .afterReturn(new Promise<Mms>(resolve => resolve({
          type: 9
        } as Mms)));

      await mConversationCtrl.setMmsDataSource(context, mmsSource);

      mocker.clear(FileUtil);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());

      expect(mConversationCtrl).not().assertUndefined();
    })

    it('conversationController_setMmsDataSource_size_1_type_0', 0, async () => {
      let mmsSource: Array<Mms> = [{
        path: ''
      } as Mms];
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          size: 1,
          data: new ArrayBuffer(0)
        } as packingItem)));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('fileTotalSize')
        .afterReturn(1);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMmsDataSourcePushListItem))(ArgumentMatchers.any)
        .afterReturn(new Promise<Mms>(resolve => resolve({
          type: 0
        } as Mms)));

      await mConversationCtrl.setMmsDataSource(context, mmsSource);

      mocker.clear(FileUtil);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());

      expect(mConversationCtrl).not().assertUndefined();
    })

    it('conversationController_queryNoReceiverDraft', 0, () => {
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          size: 1,
          data: new ArrayBuffer(0)
        } as packingItem)));
      let getObject:Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('fileTotalSize').afterReturn(1);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMmsDataSourcePushListItem))(ArgumentMatchers.any)
        .afterReturn(new Promise<Mms>(resolve => resolve({
          type: 0
        } as Mms)));
      when(getObject)('DataWorker').afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                receiverNumber: '570977632',
                senderNumber: '570977633'
              } as LooseObject]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      mocker.verify('packingSize', ['']).never();

      mocker.clear(FileUtil);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationController_releaseConversationPixelMap', 0, async () => {
      let mms: Mms = {
        path: '/',
        type: 1
      } as Mms;
      when(mocker.mockFunc(ImageUtil, ImageUtil.convertImageToPixmap))(mms.path)
        .afterReturn({
          release: (callback: AsyncCallback<void, void>): void => {

          }
        } as image.PixelMap);
      await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      mConversationCtrl.releaseConversationPixelMap();

      mocker.verify('convertImageToPixmap', ['/']).once();

      mocker.clear(ImageUtil);
    })

    it('conversationController_setMmsDataSourcePushListItem_type_1', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 1,
        isOnAudio:false
      } as Mms;
      //先执行一次setMmsDataSourcePushListItem，先设置conversationPixelMap，使hasStorage=true
      await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      //进而测试if (hasStorage)分支
      let res: Mms = await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('conversationController_setMmsDataSourcePushListItem_type_2', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 2,
        isOnAudio:false
      } as Mms;
      let res: Mms = await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('conversationController_setMmsDataSourcePushListItem_type_3', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 3,
        isOnAudio:false
      } as Mms;
      let res: Mms = await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('conversationController_setMmsDataSourcePushListItem_type_7', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 7,
        index: 1,
        isOnAudio:false
      } as Mms;
      let res: Mms = await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('conversationController_setMmsDataSourcePushListItem_type_9', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 9,
        index: 1,
        isOnAudio:false
      } as Mms;
      let res: Mms = await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('conversationController_getConvertDegreeString', 0, () => {
      let res: string = mConversationCtrl.getConvertDegreeString(20.9);
      expect(res).assertEqual(`20°53'59"`);
    })

    it('conversationController_cancelReceiveFileOnclick', 0, () => {
      mConversationCtrl.cancelReceiveFileOnclick('', '');
      expect(mConversationCtrl.simSlotId).assertEqual(0);
    })

    it('conversationController_rcsVCardMessageContentAppear_isSingleContactOrMultipleTel_true', 0, async () => {
      let item: Mms = {
        path: '',
        contacts: [{
          contactName: 'name'
        } as ContactType]
      } as Mms;
      let res = await mConversationCtrl.rcsVCardMessageContentAppear(context, item, false, []);
      expect(res.length).assertEqual(0);
    })

    it('conversationController_rcsVCardMessageContentAppear', 0, async () => {
      let list: ContactType[] = [{
        contactName: 'name',
        id: 0
      } as ContactType, {
        contactName: 'name',
        id: 2
      } as ContactType, {
        contactName: 'name2',
        id: 1
      } as ContactType];

      let item: Mms = {
        path: '/',
        contacts: list
      } as Mms;

      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().parseVCard))(ArgumentMatchers.any).afterReturn(list);
      let res = await mConversationCtrl.rcsVCardMessageContentAppear(context, item, false, []);
      expect(res.length).assertEqual(3);
      mocker.clear(VCardUtil.getInstance());
    })

    it('conversationController_mmCheckVcardDialogAppear', 0, () => {
      let contacts: ContactTypeForUI[] = [{
        contactName: '',
        telephone: '',
        telephoneFormat: '',
        headImage: '',
        select: false,
        rawContactId: '',
        id: 0
      }, {
        contactName: '',
        telephone: '',
        telephoneFormat: '',
        headImage: '',
        select: false,
        rawContactId: '',
        id: 0
      }];
      let res: ContactTypeForUI[] = mConversationCtrl.mmCheckVcardDialogAppear(contacts, []);
      expect(res.length).assertEqual(1);
    })
	
    it('conversationController_setMmsDataSourcePushListItem_type_10', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 10,
        content: '{"body":"name;address","longitude":"1","latitude":"1","accuracy":"0"}'
      } as Mms;
      let res: Mms = await mConversationCtrl.setMmsDataSourcePushListItem(mms, 0);
      expect(res.index).assertEqual(0);
    })
  })
}