/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import ReceiveController from './receiveController'
import LooseObject from '../../data/LooseObject'
import ConversationController from '../../pages/conversation/conversationController'

@Component
export struct Receive {
  @StorageLink('ReceiveController') mReceiveController: ReceiveController = ReceiveController.getInstance();
  @StorageLink('ConversationController') mConversationController: ConversationController = ConversationController.getInstance();

  private aboutToAppear(): void {
    this.mReceiveController.changeMyText(this.mConversationController.strContactsNumberFormat);
  }

  private onPageShow(): void  {
        this.mReceiveController.onInit((receiverData) => {
                this.mConversationController.setReceiveContactValue(receiverData)
        })
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
          Text($r('app.string.putAddresser'))
            .flexBasis(70)
            .height(21)
            .maxLines(1)
            .fontSize(16)
            .fontColor($r('app.color.main_font_color_40'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
          Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            // 如果选择了联系人
            //            if (this.mReceiveController.isInputStatus) {
            //              ForEach(this.mReceiveController.selectContacts, (item, index) => {
            //                Row() {
            //                  if (item.contactName == '' || item.contactName == null) {
            //                    Text(item.telephoneFormat)
            //                      .textAlign(TextAlign.Center)
            //                      .textOverflow({ overflow: TextOverflow.Ellipsis })
            //                      .fontSize(12)
            //                  }
            //                  if (item.contactName != '' && item.contactName != null) {
            //                    Text(item.contactName)
            //                      .textAlign(TextAlign.Center)
            //                      .textOverflow({ overflow: TextOverflow.Ellipsis })
            //                      .fontSize(12)
            //                  }
            //                  if (item.select) {
            //                    Image($rawfile('icon/ic_cancel_black.svg'))
            //                      .width(16)
            //                      .height(16)
            //                  }
            //                }
            //                .padding({ left: 8, right: 8 })
            //                .margin(4)
            //                .backgroundColor('#EEE')
            //                .borderRadius(24)
            //                .height(20)
            //                .alignItems(VerticalAlign.Center)
            //                .onClick(() => {
            //                  this.mReceiveController.nameClick(index)
            //                })
            //              }, item => item.id)
            //            }
            //            //
            //            else {
            //              Text(this.mReceiveController.strSelectContact)
            //                .fontColor('#171BFA')
            //                .textAlign(TextAlign.Center)
            //                .textOverflow({ overflow: TextOverflow.Ellipsis })
            //            }
            //            if (this.mReceiveController.isInputStatus) {
            Row() {
              TextArea({ text: this.mReceiveController.myText })
                .flexBasis('auto')
                .caretColor($r('app.color.control_activated_color'))
                .placeholderColor($r('app.color.placeholder_color'))
                .backgroundColor($r('app.color.white'))
                .onChange((value) => {
                  this.mReceiveController.searchChange(value, (receiverData) => {
                    this.mConversationController.setReceiveContactValue(receiverData);
                  });
                })
              //                  .onBlur(() => {
              //                    this.mReceiveController.checkReceive()
              //                  })
              //                  .onFocus(() => {
              //                    this.mReceiveController.myContactFocus();
              //                  })
            }
            .constraintSize({ maxHeight: 120 })
            //            }
          }
          .flexGrow(1)
          //          .onClick(() => {
          //            this.mReceiveController.myContactClick();
          //          })
        }
        .flexBasis('auto')

        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          // 右侧联系人图标
          Image($rawfile('icon/ic_about.svg'))
            .width(24)
            .height(24)
            .margin({ right: 12 })
            .onClick(() => {
              // 跳转到联系人模块选择联系人界面
              this.mReceiveController.clickToContracts((receiverData) => {
                                this.mConversationController.setReceiveContactValue(receiverData);
              })
            })
        }
        .width(36)
        .height(56)
      }
      .constraintSize({ maxHeight: 200 })
      .backgroundColor($r('app.color.white'))
      .borderRadius(24)
      .padding({ top: 8, bottom: 8, left: 12, right: 12 })

      Column() {
        // 是否显示最近联系人列表
        if (this.mReceiveController.isShowSearch) {
          Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            Text('最近联系人')
              .fontSize(16)
              .fontColor($r('app.color.main_font_color_40'))
              .fontWeight(FontWeight.Regular)
          }
          .height(48)
          // <!-- list区域 -->
          List({ space: 0, initialIndex: 0 }) {
            ForEach(this.mReceiveController.contacts, (item, index) => {
              ListItem() {
                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                  Image($rawfile(item.headImage))
                    .width(40)
                    .height(40)

                  Flex({
                    direction: FlexDirection.Column,
                    justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.Start
                  }) {
                    if (item.contactName != '' || item.contactName != null) {
                      Text(item.contactName)
                        .fontSize(16)
                        .fontColor($r('app.color.main_font_color'))
                        .lineHeight(22)
                    }
                    Text(item.telephoneFormat)
                      .fontColor($r('app.color.main_font_color_40'))
                      .fontSize(14)
                      .lineHeight(19)
                  }
                  .margin({ left: 12 })
                }.height(64)
              }
            }, item => item.id)
          }
          .listDirection(Axis.Vertical) // 排列方向
          .edgeEffect(EdgeEffect.Spring) // 滑动到边缘无效果
          .divider({ strokeWidth: 1, color: $r('app.color.divider_color'), startMargin: 52, endMargin: 0 }) // 每行之间的分界线
        }
      }.padding({ left: 12, right: 12 })
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
  }
}