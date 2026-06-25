/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

/*
 * 1 Group messaging scenario
 * 2 click blue little word 'Detail'
 * */
import groupDetailCtrl from './groupDetailController';
import HiLog from '../../utils/HiLog';
import common from '../../data/commonData';
import LooseObject from '../../data/LooseObject';
import { ContactAvatar } from '../../views/ContactAvatar';
import AvatarColor from '../../model/common/AvatarColor';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { EditableLeftIconType, EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import TelephoneUtil from '../../utils/TelephoneUtil';
import { ToolBar, ToolBarOptions } from '@ohos.arkui.advanced.ToolBar'
//import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit'
import TitleBarUtil from '../../utils/TitleBarUtil';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import lazy { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import DeviceUtil from '../../utils/DeviceUtil';

const TAG = 'GroupDetail';

@Builder
export function GroupDetailLoader(param: LooseObject): void {
  GroupDetail();
}

@Component
export default struct GroupDetail {
  @Consume('pageInfos') pageInfos: NavPathStack
  @State mGroupDetailCtrl: groupDetailCtrl = groupDetailCtrl.getInstance();
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @StorageProp('isShowContactHeadIcon') isShowHead: boolean = true;
  @State toolbarList: ToolBarOptions = new ToolBarOptions()
  private context = getContext(this) as myCommon.UIAbilityContext;
  private dialogGridCount: number = 4;
  private bottomSpace: number = (AppStorage.get<number>('windowHeight') as number) * 0.08 -
    ((this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0) as number) / 2;
  @State isPC: boolean = DeviceUtil.isPC();
  @StorageProp('fontSizeScale') @Watch('fontSizeScaleChange') fontSizeScale: number = 1;
  //是否适老化,按规范走 1.75倍及以上 才更换上下布局
  @State isAF: boolean = this.fontSizeScale < 1.75 ? false : true;
  @State isPad: boolean = false;
  @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();

  @Styles
  listItemNormalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  }

  resendDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.msg_resend_prompt'),
      primaryButton: {
        value: $r('app.string.cancel'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {}
      },
      secondaryButton: {
        value: $r('app.string.msg_resend'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          this.mGroupDetailCtrl.resendMsg(this.context);
          GlobalContext.getContext().setObject('conversationNeedToUpdate', true);
        }
      }
    }),
    autoCancel: false,
  })

  aboutToAppear(): void {
    this.isPad = DeviceUtil.isTablet();
    this.toolbarList.push({
      content: $r('app.string.msg_detail_resend_all'),
      icon: $rawfile('icon/ic_msg_resend.svg'),
      action: () => {
        this.mGroupDetailCtrl.resendAll(this.context);
        GlobalContext.getContext().setObject('conversationNeedToUpdate', true);
      },
    })
  }

  destinationAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.mGroupDetailCtrl.onInit(this.pageInfos);
    this.mGroupDetailCtrl.onShow(this.context);
  }

  destinationDisappear() {
    HiLog.i(TAG, 'aboutToDisappear');
  }

  destinationShow() {
    HiLog.i(TAG, 'onPageShow');
  }

  destinationBackPress() {
    HiLog.i(TAG, 'onBackPress');
    this.mGroupDetailCtrl.onBackPress(this.context);
    return true;
  }

  @Builder makeAvatarAndPhoneNum(item: LooseObject, index: number) {
    Row() {
      Column() {
        Text(item.name === '' ? item.telephoneFormat : item.name)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .lineHeight(21)
          .margin({ left: this.isShowHead && !this.isAF ? 16 : 0 })
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (item.name !== '') {
          Text(TelephoneUtil.dynamicFormatPhone(item.telephoneFormat))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Regular)
            .lineHeight(19)
            .margin({ left: this.isShowHead && !this.isAF ? 16 : 0, top: 2 })
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
    }.width(this.isAF ?'80%': '50%')
  }
  @Builder makeMessageSendStatus(item: LooseObject, index: number) {
    Column() {
      if (item.sendStatus === common.int.SEND_MESSAGE_SENDING) {
        Text($r('app.string.messageSending'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(19)
          .textAlign(this.isAF ? TextAlign.Start:TextAlign.End)
          .fontWeight(FontWeight.Regular)
      } else if (item.sendStatus === common.int.SEND_MESSAGE_SUCCESS) {
        Text(item.time)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .lineHeight(19)
          .width('100%')
          .textAlign(this.isAF ? TextAlign.Start:TextAlign.End)
          .fontWeight(FontWeight.Regular)
        Text($r('app.string.messageDeliver'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(19)
          .textAlign(this.isAF ? TextAlign.Start:TextAlign.End)
          .fontWeight(FontWeight.Regular)
      } else {
        Text(item.time)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .lineHeight(19)
          .width('100%')
          .textAlign(this.isAF ? TextAlign.Start:TextAlign.End)
          .fontWeight(FontWeight.Regular)
        if (item.sendStatus === common.int.SEND_MESSAGE_FAILED) {
          Flex({
            direction: FlexDirection.Row,
            alignItems: ItemAlign.Center
          }) {
            Text($r('app.string.messageSendFailed'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .width('100%')
              .fontColor($r('sys.color.ohos_id_color_warning'))
              .lineHeight(19)
              .textAlign(this.isAF ? TextAlign.Start : TextAlign.End)
              .fontWeight(FontWeight.Regular)
            if (this.isAF) {
              this.sendingFailedImageBuilder(index)
            }
          }
        }
      }
    }.width('100%')
  }
  @Builder makeMessageSendErrorStatus(item: LooseObject, index: number){
    Flex({ direction: FlexDirection.Row, justifyContent: this.isAF ? FlexAlign.Start:FlexAlign.End, alignItems: ItemAlign.Center }) {
      this.makeMessageSendStatus(item, index)
      if (item.sendStatus === common.int.SEND_MESSAGE_FAILED && !this.isAF) {
        this.sendingFailedImageBuilder(index)
      }
    }.width(this.isAF ? '80%':'40%')
  }

  @Builder
  sendingFailedImageBuilder(index: number) {
    Image($rawfile('icon/ic_public_error.svg'))
      .syncLoad(true)
      .width(16)
      .height(16)
      .id('sendFail')
      .draggable(false)
      .fillColor($r('sys.color.warning'))
      .objectFit(ImageFit.Fill)
      .draggable(false)
      .flexShrink(0)
      .margin({ left: 8 })
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.sending_failed_button').id))
      .onClick(() => {
        this.mGroupDetailCtrl.setResendIndex(index!);
        this.resendDialogController.open();
      })
  }

  @Builder makeMessageSendGroupDetailList(){
    List() {
      ForEach(this.mGroupDetailCtrl.groupList, (item: LooseObject, index: number) => {
        ListItem() {
          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.SpaceBetween,
            alignItems: ItemAlign.Center
          }) {
            if (this.isShowHead) {
              Row() {
                ContactAvatar({
                  hasYellowPageIcon: item.hasYellowPageIcon,
                  rawContactId: item.rawContactId,
                  contactId: item.contactId,
                  firstPhotoName: item.rawContactId ? this.mGroupDetailCtrl.getPhotoName(index!) :
                  common.STR.WHITE_SPACE,
                  portraitColor: item.rawContactId ? this.mGroupDetailCtrl.getPortraitColor(index!)
                    : AvatarColor.background.Color[0]
                })
              }.width('6.5%')
            }
            Flex({
              direction: this.isAF ? FlexDirection.Column : FlexDirection.Row,
              justifyContent: FlexAlign.SpaceBetween,
              alignItems: ItemAlign.Center
            }) {
              this.makeAvatarAndPhoneNum(item, index)
              this.makeMessageSendErrorStatus(item, index)
            }.width(this.isShowHead ? '85%' : '100%')
          }.width('100%')
        }
        .stateStyles({
          normal: this.listItemNormalStyles,
          pressed: this.pressedStyles
        })
        .width('100%')
        .constraintSize({ minHeight: 64 })
        .padding({ left: this.isPC ? 24 : 16, top: 10, bottom: 11, right: this.isPC ? 24 : 16 })
        .onClick(() => {
          this.mGroupDetailCtrl.clickToContactDetail(index!);
        })
      })
    }
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
    .divider({
      strokeWidth: $r('app.float.settings_divider_strokeWidth'),
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: this.isShowHead ? 72 : 16,
      endMargin: 16 })
    .backgroundColor($r('sys.color.background_secondary'))
    .layoutWeight(1)
  }
  @Builder showResendAllBtn(){
    if (this.mGroupDetailCtrl.isAllResendBtnShow) {
      Column() {
        ToolBar({
          toolBarList: this.toolbarList,
        }).height(52)
        Row().height((this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0) as number)
      }
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
  }

  @Builder
  navTitle() {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph(
          $r('sys.symbol.chevron_backward'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .fontSize('24vp')
          .id('back_image')
          .draggable(false)
          .width(24)
          .height(24)
      }
      .margin({ right: $r('sys.float.ohos_id_elements_margin_horizontal_m') })
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .draggable(false)
      .borderRadius($r('sys.float.corner_radius_level10'))
      .id('back_button')
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.guide_action_text_previous').id) )
      .onClick(() => {
        this.destinationBackPress()
      })
      Text($r('app.string.msg_detail_mms'))
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .focusable(true)

    }
    .width('100%')
    .padding(
      {
        right: DeviceUtil.isPC() ? '' : this.curBp === common.STR.DEVICE_MOBILE_PHONE ?
          64 : this.isPad ? this.padMargin : $r('sys.float.margin_left'),
        left: DeviceUtil.isPC() ? '' : this.curBp === common.STR.DEVICE_MOBILE_PHONE ?
          12 : this.isPad ? this.padMargin : $r('sys.float.margin_left')
      })
  }

  build() {
    // HdsNavDestination() {
    NavDestination() {
      Column() {
        this.makeMessageSendGroupDetailList()
        Blank()
        this.showResendAllBtn()
      }
      .padding({
        top: 0,
        left: this.fullScreenPadding ? (this.fullScreenPadding.left as number) : 0,
        right: this.fullScreenPadding ? (this.fullScreenPadding.right as number) : 0,
        bottom: 0
      })
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .title(this.navTitle)
    // .titleBar(TitleBarUtil.getTitleBar({ stackBuilder: this.navTitle.bind(this),
    //   enableComponentSafeArea: true,
    //   callback: () => { this.destinationBackPress() }}))
    .onShown(() => {
      this.destinationShow();
    })
    .onAppear(() => {
      this.destinationAppear();
    })
    .onDisAppear(() => {
      this.destinationDisappear();
    })
    // .onBackPressed(() => {
    //   return this.destinationBackPress();
    // })
    .backgroundColor($r('sys.color.ohos_id_color_toolbar_sub_bg'))
    .hideTitleBar(false)
    .hideBackButton(true)
  }

  private fontSizeScaleChange() {
    //是否适老化,按规范走 1.75倍及以上 才更换上下布局
    if (this.fontSizeScale < 1.75) {
      this.isAF = false;
      return;
    }
    this.isAF = true;
  }
}