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
import commonData from '../../data/commonData';
import ConversationController from '../../pages/conversation/conversationController';
import { Mms, ContactType } from '../../utils/TypesUtils';
import HiLog from '../../utils/HiLog';
import prompt from '@ohos.promptAction';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import myCommon from '@ohos.app.ability.common';
import { SavedFileInfo } from '../../utils/FileUtil';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { MMSaveVcardDialog, MMAskIsImportDialog, MMCheckVcardDialog } from './MMMoreDialog'
import bundleManager from '@ohos.bundle.bundleManager';
import lazy { VCardUtil } from '../../utils/VCardUtil';
import DeviceUtil from '../../utils/DeviceUtil';
import ConversationDataSource from '../../model/ConversationDataSource';
import { Configuration, LengthMetrics } from '@kit.ArkUI';

const TAG = 'MMContentVcard';

// instrument ignore file
@Component
export struct MMContentVcard {
  private item: Mms = { duration: '', type: -1, path: '', name: '', ct: '' , isFraud: 0};
  @Prop showMenu: boolean = false;
  private context = getContext(this) as myCommon.UIAbilityContext;
  private mConversationCtrl: ConversationController = ConversationController.getInstance();
  @State contacts: ContactType[] = []
  private mmsContentBackgroundColor?: Resource | string; // Bubble background color
  private bubbleTextDirection: string = '';
  private savedFileInfo: SavedFileInfo | null = null
  @StorageProp('windowWidth') deviceWidth: number = 0;
  @State isMulContactShow: boolean = false;
  private isFromTransmit: boolean = false
  private itemIndex: number = -1;
  private changeConversationSelectedNumberAndCheckAllBool: () => void = () => {};
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  async aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    if (!this.context) {
      HiLog.w(TAG, 'Initialize getcontext is null!')
      this.context = getContext(this) as myCommon.UIAbilityContext;
      if (!this.context) {
        HiLog.e(TAG, 'retry getcontext failed,context is null!')
      }
    }
    this.contacts = await VCardUtil.getInstance().parseVCard(this.context, this.item?.path, 0);
    // 判断是否是按照多个联系人展示
    this.isMulContactShow = VCardUtil.getInstance().isMulContactShow(this.contacts)
  }

  private mmConfirmVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMAskIsImportDialog({
      confirmed: () => {
        SharedPreferencesUtils.deletePreferences(this.item.path)
        if (!this.savedFileInfo) {
          return
        }
        let vcfFileInfo: SavedFileInfo = this.savedFileInfo;
        const name: string = 'vcard_temp.vcf'
        prompt.showToast({
          message: $r('app.string.msg_vCard_import_success', name),
          duration: 200
        });
        VCardUtil.getInstance().importVCard(this.context, vcfFileInfo.path, (result: boolean) => {
          HiLog.i(TAG, 'import vcard result: ' + result);
          setTimeout(() => {
            prompt.showToast({
              message: $r('app.string.vCard_import_success', name),
              duration: 200
            });
          }, 300)
        })
        this.mmConfirmVcardDialog.close();
      },
    }),
    autoCancel: true,
    cancel: () => {
      this.mmConfirmVcardDialog?.close();
    },
    gridCount: 4
  })

  mmSaveVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMSaveVcardDialog({
      path: this.item.path,
      confirmed: async (savedFileInfo: SavedFileInfo) => {
        this.savedFileInfo = savedFileInfo
        let atManager = abilityAccessCtrl.createAtManager();
        let info = await bundleManager.getApplicationInfo(commonData.STR.BUNDLE_NAME,
          bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_PERMISSION)
        let hasPermission =
          atManager.verifyAccessTokenSync(info.accessTokenId, 'ohos.permission.WRITE_CONTACTS');
        HiLog.i(TAG, 'check permission: ' + hasPermission);
        if (hasPermission === 0) {
          this.mmConfirmVcardDialog.open();
          this.mmSaveVcardDialog.close();
        } else {
          let permissions: Permissions[] = ['ohos.permission.WRITE_CONTACTS'];
          let permissionResult = await atManager.requestPermissionsFromUser(this.context, permissions);
          HiLog.i(TAG, 'check permission: ' + JSON.stringify(permissionResult.authResults));
          if (permissionResult.authResults[0] == 0) {
            this.mmConfirmVcardDialog.open();
            this.mmSaveVcardDialog.close();
          }
        }
      },
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
  });

  private mmCheckVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMCheckVcardDialog({
      path: this.item.path,
      contacts: this.contacts
    }),
    autoCancel: true,
    cancel: () => {
      this.mmCheckVcardDialog?.close();
    },
    alignment: DialogAlignment.Center,
  })

  onMmsVCardMessageClick() {
    if (this.isFromTransmit) {
      return
    }
    if (this.mConversationCtrl?.isSelectStatus) {
      this.mConversationCtrl.multiSelectMmsMsg(this.itemIndex)
      this.mConversationCtrl.listCheckBoxChange(this.itemIndex,
        !ConversationDataSource.getInstance().mmsList[this.itemIndex].isCbChecked)
      this.changeConversationSelectedNumberAndCheckAllBool();
      return
    }
    if(this.bubbleTextDirection === 'right'){
      if (!this.contacts || this.contacts.length === 0 || !this.item?.path) {
        return;
      }
      this.mmCheckVcardDialog.open()
    }else{
      if (!this.item?.path) {
        return;
      }
      this.mmSaveVcardDialog.open()
    }
  }

  getAvatarWidth() {
    return (this.fontSizeScale > 2 ? 2 : this.fontSizeScale) * 32
  }

  getMaxWidth() {
    const curPadding = 36
    return this.deviceWidth * 0.8 - this.getAvatarWidth() - curPadding
  }

  build() {
    Column() {
      if (this.contacts.length && this.isMulContactShow) {
        Row() {
            Image($rawfile('icon/ic_user_default_avatar.svg'))
              .draggable(false)
              .width(this.getAvatarWidth())
              .height(this.getAvatarWidth())
              .clip(new Circle({ width: this.getAvatarWidth(), height: this.getAvatarWidth() }))
              .margin({end: LengthMetrics.vp(12)})
          Text(VCardUtil.getInstance().getContactName(this.contacts)?.join('，'))
            .lineHeight(21)
            .constraintSize({ maxWidth: this.getMaxWidth() })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontColor(this.bubbleTextDirection == 'right'
              ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .wordBreak(WordBreak.BREAK_ALL)
        }
        .id('MMContentVcard_MulContactShow')
        .margin(12)
      } else if (this.contacts.length) {
        Row() {
            Image($rawfile('icon/ic_user_default_avatar.svg'))
              .draggable(false)
              .width(this.getAvatarWidth())
              .height(this.getAvatarWidth())
              .clip(new Circle({ width: this.getAvatarWidth(), height: this.getAvatarWidth() }))
              .margin({end: LengthMetrics.vp(12)})
          Column() {
            Text(this.contacts[0]?.contactName)
              .lineHeight(21)
              .constraintSize({ maxWidth: this.getMaxWidth() })
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontColor(this.bubbleTextDirection == 'right'
                ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
              .textAlign(TextAlign.Start)
              .wordBreak(WordBreak.BREAK_ALL)
            Text(this.contacts[0]?.telephoneFormat)
              .direction(Direction.Ltr)
              .lineHeight(19)
              .constraintSize({ maxWidth: this.getMaxWidth() })
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontColor(this.bubbleTextDirection == 'right'
                ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'))
              .textAlign(Configuration.getLocale().dir === 'rtl' ? TextAlign.End : TextAlign.Start)
              .wordBreak(WordBreak.BREAK_ALL)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .id('MMContentVcard_singleContactShow')
        .margin(12)
      }
    }
    .backgroundColor(this.mmsContentBackgroundColor)
    .borderRadius(this.bubbleTextDirection == 'right' ? {
      topStart: LengthMetrics.vp(16),
      topEnd: LengthMetrics.vp(2),
      bottomStart: LengthMetrics.vp(16),
      bottomEnd: LengthMetrics.vp(16)
    } : {
      topStart: LengthMetrics.vp(2),
      topEnd: LengthMetrics.vp(16),
      bottomStart: LengthMetrics.vp(16),
      bottomEnd: LengthMetrics.vp(16)
    })
    .alignItems(HorizontalAlign.Center)
    .enabled(true)
    .accessibilityLevel('yes')
    .id('MMContent_Vcard')
    .onClick(() => {
      if (!this.showMenu) {
        this.onMmsVCardMessageClick()
      }
    })
  }
}
