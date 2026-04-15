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
import LooseObject from '../../data/LooseObject';
import AvatarColor from '../../model/common/AvatarColor';
/*
1 send group message
2 press more button
3 click recipients item
*/
import HiLog from '../../utils/HiLog';
import TelephoneUtil from '../../utils/TelephoneUtil';
import { ContactAvatar } from '../../views/ContactAvatar';
import groupContactListCtrl from '../groupcontactlist/groupContactListController';
import dotCommon, { clickAvatarParams } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import { EditableLeftIconType, EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import DeviceUtil from '../../utils/DeviceUtil';
import common from '../../data/commonData';
import { Configuration, LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import myCommon from '@ohos.app.ability.common';
const TAG = 'GroupContactList';

@Builder
export function GroupContactListLoader(param: LooseObject): void {
  GroupContactList();
}

@Component
export default struct GroupContactList {
  @Consume('pageInfos') pageInfos: NavPathStack;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @State mGroupContactListCtrl: groupContactListCtrl = groupContactListCtrl.getInstance();
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @StorageProp('isShowContactHeadIcon') isShowHead: boolean = true;
  @State isPad: boolean = false;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  @State isPC: boolean = DeviceUtil.isPC()
  @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  private listScroller: ListScroller = new ListScroller();
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  @Styles
  listItemNormalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  }
  // 视觉规则，上下间距（大4间距16,大5间距20,大6间距24）
  getMargin(): number {
    if (this.fontSizeScale >= 3.2) {
      return 24;
    }
    if (this.fontSizeScale >= 2.0) {
      return 20;
    }
    if (this.fontSizeScale >= 1.75) {
      return 16;
    }
    return 12;
  }

  destinationAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.mGroupContactListCtrl.onInit(this.context, this.pageInfos);
  }

  destinationBackPress() {
    HiLog.i(TAG, 'onBackPress');
    this.mGroupContactListCtrl.onBackPress();
    return true;
  }
  aboutToAppear(): void {
    this.isPad = DeviceUtil.isTablet();
  }

  @Builder
  recipientListItem(item: LooseObject, index: number) {
    RelativeContainer() {
      Row({ space: 16 }) {
        if (this.isShowHead) {
          ContactAvatar({
            contactId: item.rawContactId,
            hasYellowPageIcon: item.hasYellowPageIcon,
            rawContactId: item.rawContactId,
            firstPhotoName: item.rawContactId ? this.mGroupContactListCtrl.getContactPhotoName(index) :
            common.STR.WHITE_SPACE,
            portraitColor: item.rawContactId ? this.mGroupContactListCtrl.getContactPortraitColor(index) :
            AvatarColor.background.Color[0]
          }).id('contact_avatar')
        }
        Column() {
          Text(item.name === '' ? TelephoneUtil.formatDisplayPhoneNum(item.telephoneFormat) : item.name)
            .fontSize($r('sys.float.Body_L'))
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ left: this.isShowHead ? 16 : 0})
          if (item.name !== '') {
            Text(TelephoneUtil.formatDisplayPhoneNum(item.telephoneFormat))
              .fontSize($r('sys.float.Body_M'))
              .width('100%')
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ left: this.isShowHead ? 16 : 0})
          }
        }.margin({ top: this.getMargin(), bottom: this.getMargin() })
      }.width('80%')
      .alignRules({
        center: { anchor: 'groupContactList', align: VerticalAlign.Center },
        left: { anchor: 'groupContactList', align: HorizontalAlign.Start }
      })
    }.width('100%').height('auto')
    .id('groupContactList')
  }

  @Builder
  navTitle() {
    Text($r('app.string.recipients'))
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .fontWeight(FontWeight.Bold)
      .focusable(true)
      .height('100%')
      .padding(Configuration.getLocale().dir === 'rtl' ?
        {
          right: this.isPC ? $r('sys.float.padding_level12') : this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 :
              this.isPad ? this.padMargin : $r('sys.float.margin_left')
        } :
        {
          left: this.isPC ? $r('sys.float.padding_level12') : this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 :
              this.isPad ? this.padMargin : $r('sys.float.margin_left')
        })
  }

  build() {
    NavDestination() {
          List({ scroller: this.listScroller }) {
            ForEach(this.mGroupContactListCtrl.contactList, (item: LooseObject, index: number) => {
              ListItem() {
                this.recipientListItem(item, index)
              }
              .stateStyles({
                normal: this.listItemNormalStyles,
                pressed: this.pressedStyles
              })
              .width('100%')
              .constraintSize({ minHeight: $r('app.float.id_item_height_large') })
              .padding({ left: this.isPC ? 24 : 16, right: this.isPC ? 24 : 16 })
              .onClick(() => {
                this.mGroupContactListCtrl.clickToContactDetail(index!);
                // 点击群组列表头像打点
                clickAvatarParams.CLICK_PAGE = 'groupContactList';
                DotUtil.getInstance().reportEvent(clickAvatarParams, dotCommon.eventName.CLICK_AVATAR_EVENT);
              })
            })
            ListItem() {
              Row().width('100%').height('100%').backgroundColor(Color.Transparent)
            }.width('100%').height(this.fullScreenPadding?.bottom)
          }
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring, {
            alwaysEnabled: true
          })
          .backgroundColor($r('sys.color.background_secondary'))
          .margin({top: 56 })
          .divider({
            strokeWidth: $r('app.float.settings_divider_strokeWidth'),
            color: $r('sys.color.ohos_id_color_list_separator'),
            startMargin: this.isShowHead ? 72 : 16,
            endMargin: 16 })
    }
    .onAppear(() => {
      this.destinationAppear();
    })
    .onBackPressed(() => {
      return this.destinationBackPress();
    })
    .backgroundColor($r('sys.color.ohos_id_color_toolbar_sub_bg'))
    .title(this.navTitle(), { barStyle: BarStyle.STACK, backgroundColor: $r('sys.color.ohos_id_color_toolbar_sub_bg') })
    .backButtonIcon(new SymbolGlyphModifier($r('sys.symbol.chevron_backward')))
    .padding({
      top: DeviceUtil.isPC() ? common.MESSAGEHOME_DELETE.ACTION_AREA_DISTANCE : this.fullScreenPadding?.top as number
    })
  }
}