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
import LooseObject from '../../data/LooseObject';
import { Mms, ContactType, TransmitPageJumpParam } from '../../utils/TypesUtils';
import FavoriteController from './favoriteController'
import FileUtil, { SavedFileInfo } from '../../utils/FileUtil';
import HiLog from '../../utils/HiLog';
import commonData from '../../data/commonData';
import { VibrationUtils } from '../../utils/VibrationUtils';
import myCommon from '@ohos.app.ability.common';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { VCardUtil } from '../.././../ets/utils/VCardUtil'
import { MMSaveVcardDialog, MMAskIsImportDialog, MMCheckVcardDialog, ContactTypeForUI } from '../../views/AttachmentArea/MMMoreDialog'
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import bundleManager from '@ohos.bundle.bundleManager';
import prompt from '@ohos.promptAction';
import DeviceUtil from '../../utils/DeviceUtil';
import { LengthMetrics } from '@kit.ArkUI';
import TransmitMsgController from '../transmitmsg/transmitMsgController';

const TAG = 'MmsContentVcard';

@Component
export struct MmsContentVcard {
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  public listScroller?: ListScroller
  private context = getContext(this) as myCommon.UIAbilityContext;
  @Consume mFavoriteCtrl: FavoriteController;
  @Consume multiSelectFlag: Visibility;
  @Consume show: boolean;
  private item: LooseObject = {}
  private itemIndex: number = 0;
  private isSender: boolean = false;
  @State showMenu: boolean = false;
  @State contacts: void | ContactType[] = [];
  private savedFileInfo: SavedFileInfo | null = null
  private path: string = '';
  private menuMultSelect: (index: number) => void = () => {};
  @StorageProp('windowWidth') deviceWidth: number = 0;
  @State isMulContactShow: boolean = false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @StorageProp('isShowContactHeadIcon') isShowHead: boolean = true;
  favoriteNameMargin: number = 0;
  transmitPageJumpParam: null | TransmitPageJumpParam = null;
  pageInfos?: NavPathStack;

  aboutToAppear(): void {
    this.init()
  }

  async init() {
    this.path = this.mFavoriteCtrl.mmsScreening(this.item.msgId, 4).locationPath ?? ''
    if (this.path) {
      this.contacts = await VCardUtil.getInstance().parseVCard(this.context, this.path, 0);
      this.isMulContactShow = VCardUtil.getInstance().isMulContactShow(this.contacts)
    }
  }

  // instrument ignore next
  mmConfirmVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMAskIsImportDialog({
      confirmed: () => {
        SharedPreferencesUtils.deletePreferences(this.path)
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

  // instrument ignore next
  mmSaveVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMSaveVcardDialog({
      path: this.path,
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

  mmCheckVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMCheckVcardDialog({
      path: this.path,
      contacts: this.contacts as ContactTypeForUI[]
    }),
    autoCancel: true,
    cancel: () => {
      this.mmCheckVcardDialog?.close();
    },
    alignment: DialogAlignment.Center,
  })

  // instrument ignore next
  onMmsVCardMessageClick() {
    if (this.mFavoriteCtrl?.isSelectStatus) {
      this.mFavoriteCtrl?.multiSelectMmsMsg(this.itemIndex);
      this.mFavoriteCtrl?.listCheckBoxChange(this.itemIndex,
        !this.mFavoriteCtrl.mmsListFromFavo[this.itemIndex]?.isCbChecked);
      return
    }
    if (this.isSender) {
      if (!this.path) {
        return;
      }
      this.mmSaveVcardDialog.open()
    } else {
      if (!this.contacts || this.contacts.length === 0) {
        return;
      }
      this.mmCheckVcardDialog.open()
    }
  }

  @Builder
  longPressMenuBuild() {
    Menu() {
      // 多选
      this.multSelectMenuButton()
      this.multDivider()
      // 保存
      this.saveMenuButton()
      this.multDivider()
      // 转发
      this.transmitMenuButton()
      this.multDivider()
      // 删除
      this.deleteMenuButton()
    }
    .width('224vp')
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  multSelectMenuButton() {
    MenuItem({ content: $r('app.string.select_more') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.show = false;
        this.showMenu = false;
        this.mFavoriteCtrl.isSelectStatus = true;
        this.mFavoriteCtrl.mmsIndex = this.itemIndex;
        this.item.isCbChecked = true;
        this.multiSelectFlag = Visibility.Visible;
        this.menuMultSelect(this.itemIndex);
      })
  }

  // instrument ignore next
  @Builder
  saveMenuButton() {
    MenuItem({ content: $r('app.string.save') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(async () => {
        let mmsSource: Mms[] = this.item.mmsSource;
        let saveObject: Mms
        if (mmsSource.length > 1) {
          saveObject = mmsSource[1]
        } else {
          saveObject = mmsSource[0]
        }
        FileUtil.saveFileToFileManager(this.context, saveObject.path, saveObject.name)
        this.showMenu = false;
      })
  }

  @Builder
  transmitMenuButton() {
    MenuItem({ content: $r('app.string.msg_transmit') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        this.mFavoriteCtrl.longPressSelected(1, (type, pageName, params, pageInfos) => {
          this.transmitPageJumpParam = {
            type: type,
            pageName: pageName,
            params: params
          }
          this.pageInfos = pageInfos;
        })
        this.showMenu = false
      })
  }

  @Builder
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.cancelFavorite(this.context, this.item);
        this.showMenu = false;
      })
  }

  getAvatarWidth() {
    return (this.fontSizeScale > 2 ? 2 : this.fontSizeScale) * 32
  }

  getMaxWidth() {
    const contactAvatarWidth: number = this.isShowHead ? 32 : 0
    const favoriteNameMargin: number = this.favoriteNameMargin
    const avatarWidth = (this.fontSizeScale > 2 ? 2 : this.fontSizeScale) * 32
    const curPadding = 36
    return this.deviceWidth * 0.8 - avatarWidth - curPadding - contactAvatarWidth - favoriteNameMargin
  }

  // instrument ignore next
  build() {
    Column() {
      if (this.contacts && this.contacts.length && this.isMulContactShow) {
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
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontColor(!this.isSender
              ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .wordBreak(WordBreak.BREAK_ALL)
        }
        .margin(12)
        .borderRadius({
          topLeft: 16,
          topRight: 2,
          bottomLeft: 16,
          bottomRight: 16
        })
      } else if (this.contacts  && this.contacts.length) {
        Row(){
            Image($rawfile('icon/ic_user_default_avatar.svg'))
              .draggable(false)
              .width(this.getAvatarWidth())
              .height(this.getAvatarWidth())
              .clip(new Circle({ width: this.getAvatarWidth(), height: this.getAvatarWidth() }))
              .margin({end: LengthMetrics.vp(12)})
          Column(){
            Text(this.contacts[0]?.contactName)
              .lineHeight(21)
              .constraintSize({ maxWidth: this.getMaxWidth() })
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontColor(!this.isSender
                ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
              .textAlign(TextAlign.Start)
              .wordBreak(WordBreak.BREAK_ALL)
            Text(this.contacts[0]?.telephoneFormat)
              .lineHeight(19)
              .constraintSize({ maxWidth: this.getMaxWidth() })
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontColor(!this.isSender
                ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'))
              .textAlign(TextAlign.Start)
              .wordBreak(WordBreak.BREAK_ALL)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({ top: 8, left:12, right:12, bottom:8 })
      }
    }
    .backgroundColor(this.isSender ? $r('sys.color.ohos_id_color_card_bg') : $r('app.color.brand'))
    .borderRadius({
      topLeft: 2,
      topRight: 16,
      bottomLeft: 16,
      bottomRight: 16
    })
    .alignItems(HorizontalAlign.Center)
    .enabled(true)
    .parallelGesture(
      GestureGroup(GestureMode.Exclusive,
        // 长按让showMenu为true，覆盖text自带的复制，让bindContextMenu生效
        LongPressGesture({ repeat: false, duration: 500 })
          .onAction(() => {
            if (this.multiSelectFlag == Visibility.None) {
              this.showMenu = true
            }
          })
        ,
        TapGesture({ count: 1 })
          .onAction(() => {
            if (!this.showMenu) {
              this.onMmsVCardMessageClick()
            }
          })
      )
    )
    .bindContextMenu(this.showMenu, this.longPressMenuBuild, {
      placement: Placement.BottomLeft,
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: {
        scale: [0.95, 1.1]
      },
      aboutToAppear: () => {
        this.transmitPageJumpParam = null;
      },
      onAppear: () => {
        HiLog.w(TAG, `select msg id is: ${this.item.id}`)
        VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
      },
      onDisappear: () => {
        if (this.itemIndex === this.scrollStartIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
        } else if (this.itemIndex === this.scrollEndIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
        }
        this.showMenu = false;
        if (this.transmitPageJumpParam) {
          TransmitMsgController.handleTransmitPageJump(this.transmitPageJumpParam, this.pageInfos);
          this.transmitPageJumpParam = null;
        }
      }
    })
  }
}
