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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { DTGlobalContext } from '../../testability/TestAbility';
import common from '@ohos.app.ability.common';
import { VCardUtil, VcfItem } from '../../../../main/ets/utils/VCardUtil';
import FileUtil, { SavedFileInfo } from '../../../../main/ets/utils/FileUtil';
import { ContactType } from '../../../../main/ets/utils/TypesUtils';
import LooseObject from '../../../../main/ets/data/LooseObject';

export default function VCardUtilTest() {
  describe('VCardUtilTest', () => {

    let vCardUtil: VCardUtil = VCardUtil.getInstance();

    it('VCardUtilTest_generateVcf', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext;
      let vcfItem: VcfItem = {
        name: 'aaaa',
        phones: '15825643258',
        id: 1,
        avatarBase64Encoded: '46542313546565465dfasfafafafadfevdfdf',
        photoPath: ''
      };
      let vcfItem1: VcfItem = {
        name: 'aaaa',
        phones: '15825643258',
        id: 1,
        avatarBase64Encoded: '',
        photoPath: 'photoPath'
      };
      let vcfItems: VcfItem[] = [vcfItem, vcfItem1];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.saveTextToSandBox))(ArgumentMatchers.any).afterReturn({});
      let vcfFileInfo: SavedFileInfo = vCardUtil.generateVcf(context, vcfItems);
      mocker.clear(FileUtil);
      expect(vcfFileInfo.name).assertUndefined();
    })

    it('VCardUtilTest_parseVCard', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext;
      let contacts: ContactType[] = await vCardUtil.parseVCard(context, context.cacheDir, 15864258632);
      expect(contacts).not().assertUndefined();
    })

    it('VCardUtilTest_removeSameNumbers', 0, () => {
      let newTelArr: string[] = ['458324455', '83528864', '458324455'];
      let telephoneArr: string[] = vCardUtil.removeSameNumbers(newTelArr);
      expect(telephoneArr.length).assertEqual(2);
    })

    it('VCardUtilTest_dealSelectedContactsToVcfItems', 0, () => {
      let contactType: ContactType = new ContactType();
      contactType.contactName = 'name1';
      contactType.telephone = '582648254';
      contactType.telephoneFormat = '185 2586 4563';
      contactType.headImage = '';
      contactType.select = true;
      let contactArr: ContactType[] = [contactType];
      let vcfItems: VcfItem[] = vCardUtil.dealSelectedContactsToVcfItems(contactArr, true);
      expect(vcfItems.length).assertEqual(1);
    })

    it('VCardUtilTest_dealSelectedContactsToVcfItems_else1', 0, () => {
      let contactType1: ContactType = new ContactType();
      contactType1.contactName = 'name3';
      contactType1.telephone = '582648259';
      contactType1.telephoneFormat = '185 2586 4569';
      contactType1.headImage = '';
      contactType1.select = true;
      let contactType2: ContactType = new ContactType();
      contactType2.contactName = 'name4';
      contactType2.telephone = '582648253';
      contactType2.telephoneFormat = '185 2586 4560';
      contactType2.headImage = '';
      contactType2.select = true;
      let contactArr: ContactType[] = [contactType1, contactType2];
      let vcfItems: VcfItem[] = vCardUtil.dealSelectedContactsToVcfItems(contactArr, false);
      expect(vcfItems.length).assertEqual(2);
    })

    it('VCardUtilTest_dealSelectedContactsToVcfItems_else1_isSave', 0, () => {
      let contactType1: ContactType = new ContactType();
      contactType1.contactName = '';
      contactType1.telephone = '582648259';
      contactType1.telephoneFormat = '185 2586 4569';
      contactType1.headImage = '';
      contactType1.select = true;
      let contactType2: ContactType = new ContactType();
      contactType2.contactName = 'name4';
      contactType2.telephone = '582648253';
      contactType2.telephoneFormat = '185 2586 4560';
      contactType2.headImage = '';
      contactType2.select = true;
      let contactArr: ContactType[] = [contactType1, contactType2];
      let vcfItems: VcfItem[] = vCardUtil.dealSelectedContactsToVcfItems(contactArr, true);
      expect(vcfItems.length).assertEqual(1);
    })

    it('VCardUtilTest_dealSelectedContactsToVcfItems_else1_isSave_false', 0, () => {
      let contactType1: ContactType = new ContactType();
      contactType1.contactName = '';
      contactType1.telephone = '582648259';
      contactType1.telephoneFormat = '185 2586 4569';
      contactType1.headImage = '';
      contactType1.select = true;
      let contactType2: ContactType = new ContactType();
      contactType2.contactName = 'name4';
      contactType2.telephone = '582648253';
      contactType2.telephoneFormat = '185 2586 4560';
      contactType2.headImage = '';
      contactType2.select = true;
      let contactArr: ContactType[] = [contactType1, contactType2];
      let vcfItems: VcfItem[] = vCardUtil.dealSelectedContactsToVcfItems(contactArr, false);
      expect(vcfItems.length).assertEqual(1);
    })

    it('VCardUtilTest_dealSelectedContactsToVcfItems_else2', 0, () => {
      let contactType1: ContactType = new ContactType();
      contactType1.contactName = '1';
      contactType1.telephone = '5826148251';
      contactType1.telephoneFormat = '185 2586 45631';
      contactType1.headImage = '';
      contactType1.select = true;
      contactType1.id = 1;
      let contactType2: ContactType = new ContactType();
      contactType2.contactName = '1';
      contactType2.telephone = '5826248252';
      contactType2.telephoneFormat = '185 2586 45632';
      contactType2.headImage = '';
      contactType2.select = true;
      contactType2.id = 1;
      let contactType3: ContactType = new ContactType();
      contactType3.contactName = '1';
      contactType3.telephone = '5826248253';
      contactType3.telephoneFormat = '185 2586 45633';
      contactType3.headImage = '';
      contactType3.select = true;
      contactType3.id = 3;
      let contactArr: ContactType[] = [contactType1, contactType2, contactType3];
      let vcfItems: VcfItem[] = vCardUtil.dealSelectedContactsToVcfItems(contactArr, false);
      expect(vcfItems.length).assertEqual(2);
    })

    it('VCardUtilTest_multContactsToVcfItems', 0, () => {
      let contactType1: ContactType = new ContactType();
      contactType1.contactName = 'contactName';
      contactType1.telephone = '5826148251';
      contactType1.telephoneFormat = '185 2586 45631';
      contactType1.headImage = '';
      contactType1.select = true;
      contactType1.id = 1;
      let contactType2: ContactType = new ContactType();
      contactType2.contactName = 'se';
      contactType2.telephone = '5826248252';
      contactType2.telephoneFormat = '185 2586 45632';
      contactType2.headImage = '';
      contactType2.select = true;
      contactType2.id = 2;
      let contactType3: ContactType = new ContactType();
      contactType3.contactName = 'se';
      contactType3.telephone = '5826248253';
      contactType3.telephoneFormat = '185 2586 45633';
      contactType3.headImage = '';
      contactType3.select = true;
      contactType3.id = 2;
      let contactArr: ContactType[] = [contactType1, contactType2];
      let contactData: ContactType[] = [contactType1, contactType3];
      let vcfItem: VcfItem = {
        name: 'contactName',
        phones: '',
        id: 1,
        avatarBase64Encoded: '',
        photoPath: ''
      }
      let vcfItems: VcfItem[] = [vcfItem];
      (vCardUtil as object)['multContactsToVcfItems'](contactData, contactArr, vcfItems);
      expect(vcfItems.length).assertEqual(2);
    })

    it('VCardUtilTest_isVcard_false1', 0, () => {
      let data: LooseObject = {
        isMsm: false
      }
      let res: boolean = VCardUtil.isVcard(data);
      expect(res).assertEqual(false);
    })

    it('VCardUtilTest_isVcard_false2', 0, () => {
      let data: LooseObject = {
        mmsSource: []
      }
      let res: boolean = VCardUtil.isVcard(data);
      expect(res).assertEqual(false);
    })

    it('VCardUtilTest_isVcard_true', 0, () => {
      let data: LooseObject = {
        isMsm: true,
        mmsSource: [{
          type: 4,
          path: ""
        }]
      }
      let res: boolean = VCardUtil.isVcard(data);
      expect(res).assertEqual(true);
    })
  })
}