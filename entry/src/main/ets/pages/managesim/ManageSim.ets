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

import WantUtil from '../../utils/WantUtil';
import ManageSimController from './ManageSimController';
import LooseObject from '../../data/LooseObject';
import ManageSimBubbleText from './ManageSimBubbleText';
import MmsPreferences from '../../utils/MmsPreferences';
import myCommon from '@ohos.app.ability.common';
import { LoadingDialog } from '@ohos.arkui.advanced.Dialog';

@Builder
export function ManageSimLoader(param: LooseObject): void {
  ManageSim();
}

@Component
export struct ManageSim {
  @Consume('pageInfos') pageInfos: NavPathStack
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @State mManageSimCtrl: ManageSimController = ManageSimController.getInstance();
  @State mTextInputValue: string = ''
  @State multiSimCard: boolean = MmsPreferences.getInstance().haveMultiSimCardReady();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: $r('app.string.refreshing')
    }),
    autoCancel: true,
  })

  aboutToAppear() {
    this.mManageSimCtrl.onInit(this.pageInfos, this.dialogController)
  }

  /**
   * Triggers once when this page is displayed. In scenarios such as routing and application access to the foreground
   * and background, only customized components modified by @Entry take effect.
   */
  destinationShow() {
    WantUtil.getWant(this.context, this.pageInfos);
  }
  /**
   * Function executes before custom component destructor consumption.
   * Changing state variables in the aboutToDisappear function is not allowed, especially changes to the @Link
   * variable may cause unstable application behavior.
   */
  destinationDisappear() {
    this.mManageSimCtrl.resetList()
  }

  /**
   * Triggered when a user clicks the back button. Only the customized component modified by @Entry takes effect.
   * If true is returned, the page processes the return logic and does not route the page.
   * If false is returned, the default return logic is used.
   * If no value is returned, the value is treated as false.
   */
  onBackPress() {
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          if (this.mManageSimCtrl.showContent && this.mManageSimCtrl.cardMmsList.length == 0) {
            Column() {
              Flex({ alignItems: ItemAlign.End, justifyContent: FlexAlign.Center }) {
                Column() {
                  Image($rawfile('icon/ic_massage_m.svg'))
                    .width('120vp')
                    .height('120vp')
                    .draggable(false)
                  Text($r('app.string.no_messages'))
                    .fontSize(14)
                    .opacity(0.4)
                    .height(19)
                    .margin({ top: 8 })
                    .fontColor($r('sys.color.font_primary'))
                }.translate({ y: 87 })
              }
              .width('100%')
              .height('40%')
            }
            .width('100%')
            .height('100%')
          }
          // Top Device Title
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .width($r('app.float.icon_side_length_medium'))
              .height($r('app.float.icon_side_length_medium'))
              .fontColor([$r('sys.color.ohos_id_color_primary')])
              .fontSize('24vp')
              .margin({
                left: $r('app.float.action_bar_margin_left')
              })
              .onClick(() => {
                this.mManageSimCtrl.goBack()
              })
              .draggable(false)
            Row().width($r('app.float.space_16'))
            Text(!this.multiSimCard ? $r('app.string.manage_sim_card_messages') :
              (this.mManageSimCtrl.slotId == 0 ? $r('app.string.manage_sim_card_number_messages', 1) : $r('app.string.manage_sim_card_number_messages', 2)))
              .fontSize($r('app.float.action_bar_text_size'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Row().width('100%').flexShrink(1)
          }
          .width('100%')
          .height($r('app.float.action_bar_height'))
        }
        .height('100%')

        // Content
        Column() {
          if (this.mManageSimCtrl.showContent) {
            if (this.mManageSimCtrl.cardMmsList.length !== 0) {
              Column() {
                List() {
                  LazyForEach(this.mManageSimCtrl.cardMmsListDataSource, (item: LooseObject, index: number) => {
                    ListItem() {
                      Column() {
                        Text(item.name)
                          .textAlign(TextAlign.Start)
                          .fontSize(10)
                          .lineHeight(13)
                          .fontColor($r('sys.color.font_secondary'))
                          .margin({ top: 8, right: 5 })
                        // Message Bubble
                        ManageSimBubbleText({
                          bubbleTextBorderRadius: [4, 24],
                          bubbleTextDirection: 'left',
                          content: item.content,
                          bubbleTextBackgroundColor: $r('sys.color.ohos_id_color_card_bg')
                        })
                          .constraintSize({ maxWidth: 284 })
                          .gesture(
                            TapGesture({ count: 2 })
                              .onAction(() => {
                                this.mManageSimCtrl.pushToCopyController(index);
                              })
                          )
                        Text(item.timeRange)
                          .textAlign(TextAlign.Start)
                          .fontSize(10)
                          .lineHeight(13)
                          .fontColor($r('sys.color.font_secondary'))
                          .margin({ top: 8, right: 5 })
                      }
                      .width('100%')
                      .alignItems(HorizontalAlign.Start)
                      .margin({ bottom: 20 })
                    }.width('100%')
                  }, (item: LooseObject) => JSON.stringify(item))
                }.width('100%')
                .scrollBar(BarState.Off)
                .height('100%')
              }
              .width('100%')
              .height('100%')
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({
        top: this.fullScreenPadding ? (this.fullScreenPadding.top as number) : 0,
        left: $r('app.float.page_padding_left'),
        right: $r('app.float.page_padding_right')
      })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .onShown(() => {
      this.destinationShow();
    })
    .onDisAppear(() => {
      this.destinationDisappear();
    })
    .hideTitleBar(true)
  }
}
