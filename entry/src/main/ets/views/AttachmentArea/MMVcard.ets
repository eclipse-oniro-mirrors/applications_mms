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
import { Mms, ContactType } from '../../utils/TypesUtils';
import { MMCheckVcardDialog, ContactTypeForUI } from './MMMoreDialog'
import { VCardUtil } from '../.././../ets/utils/VCardUtil'
import myCommon from '@ohos.app.ability.common';
import HiLog from '../../utils/HiLog';
import { LengthMetrics } from '@kit.ArkUI';

// instrument ignore file
const TAG = 'MMVcard';
/**
 * The UI for contactVcard Message show in the attachment area.
 */
@Component
export struct MMVcard {
  private item?: Mms;
  @State contacts: void | ContactType[] = [];
  @State isMulContactShow: boolean = false;
  @StorageProp('windowWidth') deviceWidth: number = 0;
  private context = getContext(this) as myCommon.UIAbilityContext;
  private isMulContacts: Function = () => {};
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  aboutToAppear(): void {
    this.init()
  }

  async init() {
    if (this.item) {
      const contacts = await VCardUtil.getInstance().parseVCard(this.context, this.item?.path, 0);
      this.contacts = contacts
      // 附件区 联系人ux 显示一行的场景：多个联系人、单个联系人只有号码、单个联系人只有名字。
      this.isMulContactShow = VCardUtil.getInstance().isMulContactShow(this.contacts)
      this.isMulContacts(VCardUtil.getInstance().isMulContactShow(this.contacts))
    }
  }

  private mmCheckVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMCheckVcardDialog({
      path: this.item?.path,
      contacts: this.contacts as ContactTypeForUI[]
    }),
    autoCancel: true,
    cancel: () => {
      this.mmCheckVcardDialog?.close();
    },
    alignment: DialogAlignment.Center,
  })

  getAvatarWidth() {
    return (this.fontSizeScale > 2 ? 2 : this.fontSizeScale) * 24
  }

  getMaxWidth() {
    const avatarWidth = this.getAvatarWidth()
    const curPadding = 20
    const xmarkWidth = (this.fontSizeScale > 2 ? 2 : this.fontSizeScale) * 14
    return this.deviceWidth * 0.8 - avatarWidth - xmarkWidth - curPadding
  }

  build() {
    Stack({alignContent:Alignment.Top}) {
      if (this.contacts && this.isMulContactShow) {
        Row() {
          Image($rawfile('icon/ic_user_default_avatar.svg'))
              .draggable(false)
              .width(this.getAvatarWidth())
              .height(this.getAvatarWidth())
              .clip(new Circle({ width: this.getAvatarWidth(), height: this.getAvatarWidth() }))
              .margin({ end: LengthMetrics.vp(8) })
          Column() {
            Text(VCardUtil.getInstance().getContactName(this.contacts)?.join('，'))
              .lineHeight(21)
              .constraintSize({ maxWidth: this.getMaxWidth() })
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.icon_primary'))
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .wordBreak(WordBreak.BREAK_ALL)
          }
        }
        .alignItems(VerticalAlign.Center)
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
      } else if (this.contacts) {
        Row() {
            Image($rawfile('icon/ic_user_default_avatar.svg'))
              .draggable(false)
              .width(this.getAvatarWidth())
              .height(this.getAvatarWidth())
              .clip(new Circle({ width: this.getAvatarWidth(), height: this.getAvatarWidth() }))
              .margin({ end: LengthMetrics.vp(8) })
          Column() {
            Text(this.contacts[0]?.contactName)
              .lineHeight(20)
              .constraintSize({ maxWidth: this.getMaxWidth() })
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.icon_primary'))
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .wordBreak(WordBreak.BREAK_ALL)
            Text(this.contacts[0]?.telephoneFormat)
              .lineHeight(18)
              .constraintSize({ maxWidth: this.getMaxWidth() })
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.icon_primary'))
              .fontFamily('HarmonyHeiTi')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .margin({top: 4})
              .wordBreak(WordBreak.BREAK_ALL)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Center)
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
      }
    }
    .padding({
      start: LengthMetrics.vp(8),
      end: LengthMetrics.vp(16 + 14 * this.fontSizeScale),
      top: LengthMetrics.vp(8),
      bottom: LengthMetrics.vp(8)
    })
    .borderRadius(8)
    .backgroundColor($r( 'app.color.mms_recorder_area_display_bg'))
    .enabled(true)
    .onClick(()=>{
      this.mmCheckVcardDialog.open()
    })
  }
}