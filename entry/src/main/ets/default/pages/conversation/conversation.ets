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
/**
 * 信息/彩信查看界面
 */
import ConversationController from "./conversationController";
import DeviceUtil from "../../utils/DeviceUtil";
import { Receive } from "../../views/receive/receive";
import LooseObject from "../../data/LooseObject";
import { MmsMenu } from "../../views/MmsMenu";
import Common from "./common";

@Entry
@Component
export struct Conversation {
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @State mCommonCtrl: Common = Common.getInstance();
  @State sizeType: SizeType = DeviceUtil.isTablet() ? SizeType.LG : SizeType.SM;
  @State columns: number = DeviceUtil.isTablet() ? 12 : 4;
  @State gutter: string = "24vp";
  @State margin: string = DeviceUtil.isTablet() ? "24vp" : "12vp";

  private menuItems: Array<any> = [
    {
      value: $r("app.string.delete"),
      action: () => {
        this.mConversationCtrl.longPressMore(0);
      },
      enabled: true
    }
  ];

  /** 短信详情弹框 */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DetailsDialog({
      item: this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex],
      receiver: this.mConversationCtrl.strContactsName == ''
        ? this.mConversationCtrl.strContactsNumber :
        this.mConversationCtrl.strContactsName
    }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -30 }
  })

  aboutToAppear() {
    this.mConversationCtrl.onInit()
  }

  onPageShow() {
    this.mConversationCtrl.onShow()
  }

  onPageHide() {
    this.mConversationCtrl.onHide()
  }

  onBackPress() {
    return this.mConversationCtrl.onBackPress();
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
      Flex({ direction: FlexDirection.Column,alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
        // <!--上方titleBar-->
        // 新建界面
        if (this.mConversationCtrl.isNewMsg) {
          Row() {
            Image($rawfile('icon/ic_message_back.svg'))
              .width('24vp')
              .height('24vp')
              .onClick(() => {
                // 点击返回恢复到未选中短信状态
                this.mConversationCtrl.titleBarBack()
              })
            Text($r("app.string.new_message"))
              .margin({ left: '24vp' })
              .fontSize(20)
              .lineHeight(28)
              .fontColor($r('app.color.main_font_color'))
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .height(56)
          .padding({left: '24vp', right: '24vp' })
          .zIndex(2)
          .constraintSize({ minHeight: 56 })
        }
        // 短信详情查看界面
        else {
          Row() {
            // 选择状态
            if (this.mConversationCtrl.isSelectStatus) {
              Row() {
                Image($rawfile('icon/ic_public_cancel.svg'))
                  .width(24)
                  .height(24)
                  .onClick(() => {
                    // 点击返回恢复到未选中短信状态
                    this.mConversationCtrl.titleBarCancel()
                  })
                Text(this.mConversationCtrl.selectDeleteMsgCount == 0 ? $r("app.string.msg_unselected_tip") : $r("app.string.msg_selected_tip", this.mConversationCtrl.selectDeleteMsgCount))
                  .margin({ left: 16 })
                  .fontSize(20)
                  .fontColor($r('app.color.main_font_color'))
                  .fontWeight(FontWeight.Bold)
              }
              .alignItems(VerticalAlign.Center)
              .width('100%')
            }
            // 非选择状态
            else {
              Row() {
                Flex({
                alignItems:ItemAlign.Center,
                }) {
                  Row() {
                    Image($rawfile('icon/ic_message_back.svg'))
                      .width(24)
                      .height(24)
                      .onClick(() => {
                        this.mConversationCtrl.titleBarBack()
                      })
                    Image($rawfile('icon/user_avatar_full_fill.svg'))
                      .width(40)
                      .height(40)
                      .margin({ left: 16 })
                      .onClick(() => {
                        this.mConversationCtrl.titleBarAvatar();
                      })
                  }
                  .flexBasis(80)

                  Column() {
                    Flex({
                      direction: FlexDirection.Column,
                      justifyContent: FlexAlign.Center,
                      alignItems: ItemAlign.Start
                    }) {
                      if (this.mConversationCtrl.contactsNum > 1) {
                        Text(this.mConversationCtrl.strContactsName).fontSize(16).fontColor($r('app.color.main_font_color'))
                        Text($r("app.string.members", this.mConversationCtrl.contactsNum)).fontSize(14).fontColor($r('app.color.main_font_color_40'))
                      } else if (this.mConversationCtrl.strContactsName == '' || this.mConversationCtrl.strContactsName == null) {
                        Text(this.mConversationCtrl.strContactsNumberFormat).fontSize(16).fontColor($r('app.color.main_font_color'))
                      } else {
                        Text(this.mConversationCtrl.strContactsName).fontSize(16).fontColor($r('app.color.main_font_color'))
                        Text(this.mConversationCtrl.strContactsNumberFormat).fontSize(14).fontColor($r('app.color.main_font_color_40'))
                      }
                    }
                  }
                  .flexGrow(1)
                  .alignItems(HorizontalAlign.Start)
                  .padding({ left: 16 })

                  Row() {
                    Image($rawfile('icon/ic_message_phone.svg'))
                      .width(24)
                      .height(24)
                      .onClick(() => {
                        this.mConversationCtrl.clickCall();
                      })
                    Column() {
                      MmsMenu({
                        menuItems: this.menuItems,
                        sizeType: this.sizeType
                      })
                    }
                    .margin({ left: 16 })
                  }
                  .flexBasis(64)

                }.height('100%')
              }
              .width('100%')
            }
          }
          .height(56)
          .constraintSize({ minHeight: 56 })
          .padding({left: 24, right: 24 })
          .zIndex(2)
        }
        // <!--中间内容区域-->
        Row() {
          // 新建消息内容
          if (this.mConversationCtrl.isNewMsg) {
            Row() {
              Receive({ mConversationController: $mConversationCtrl })
            }.margin({ top: 8 })
          }
          // 短信内容
          // <!--信息列表-->
          if (!this.mConversationCtrl.isNewMsg) {
            List({ space: 10, initialIndex: this.mConversationCtrl.mmsList.length - 1 }) {
              ForEach(this.mConversationCtrl.mmsList, (item, index) => {
                ListItem() {
                  Column() {
                    GridContainer({
                      columns: this.columns,
                      sizeType: this.sizeType,
                      gutter: this.gutter,
                      margin: this.margin
                    }) {
                      // <!--发信息Item-->
                      if (!item.isReceive && !item.isDraft) {
                        Flex({
                          direction: FlexDirection.Column,
                          justifyContent: FlexAlign.Center,
                          alignItems: ItemAlign.Center
                        }) {
                          // 短信/彩信
                          if (index == 0) {
                            Text($r("app.string.msg_note_mms")).fontSize(12).lineHeight(16).fontColor($r('app.color.main_font_color_60')).margin({ bottom: 2 })
                          }
                          // 时间
                          if (item.dateShow) {
                            Text(){
                              Span(item.date).fontSize(12).fontColor($r('app.color.main_font_color_60'))
                              Span(item.week).fontSize(12).fontColor($r('app.color.main_font_color_60'))
                            }.lineHeight(16).margin({ bottom: 8 })
                          }
                          Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
                            Column() {
                              Flex({
                                justifyContent: FlexAlign.End,
                                alignItems: ItemAlign.End
                              }) {
                                // <!--文本-->
                                Flex({
                                  justifyContent: FlexAlign.End,
                                  alignItems: ItemAlign.End
                                }) {
                                  // <!--发送失败icon-->
                                  if (!item.isMsm && ((this.mConversationCtrl.contactsNum == 1 && item.sendStatus == 2) || (this.mConversationCtrl.contactsNum > 1 && item.failuresNumber > 0 && item.completeNumber == this.mConversationCtrl.contactsNum))) {
                                    Row() {
                                      Image($rawfile('icon/ic_send_fail.svg'))
                                        .width(24)
                                        .height(24)
                                    }
                                    .flexBasis(35)
                                    .padding({ top: 9 })
                                  }
                                  // 消息气泡
                                  bubbleText({
                                    conversationCtrl: $mConversationCtrl,
                                    borderRadius: [4, 24],
                                    direction: 'right',
                                    content: item.content,
                                    backgroundColor: $r("app.color.sender_bubble"),
                                    isShowMsgLongMenu: item.isShowMsgLongMenu,
                                    itemIndex: index
                                  })
                                }
                              }
                              // <!--发送时间、发送状态那行-->
                              Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
                                if (this.mConversationCtrl.contactsNum == 1 && item.sendStatus != 1) {
                                  Text(item.time).textAlign(TextAlign.Start).fontSize(10).lineHeight(13).fontColor($r('app.color.main_font_color_60')).margin({ top: 8, right: 5 })
                                }
                                // 卡1还是卡2
                                if (this.mConversationCtrl.cardImage) {
                                  Image(item.subId == 0 ? $rawfile('icon/icon_mms_sim_1.svg') : $rawfile('icon/icon_mms_sim_2.svg'))
                                    .width(10)
                                    .height(10)
                                    .margin({ top: 8, right: 5 })
                                }
                                // 是否锁定
                                if (item.isLock) {
                                  Image($rawfile('icon/msg_lock.svg'))
                                    .width(10)
                                    .height(10)
                                    .margin({ top: 8, right: 5 })
                                }
                                Text($r("app.string.messageSendFailed"))
                                  .textAlign(TextAlign.Start)
                                  .fontSize(10)
                                  .lineHeight(13)
                                  .margin({ top: 8 })
                                  .fontColor($r('app.color.message_send_failed'))
                                  .visibility(item.sendStatus == 2 ? Visibility.Visible : Visibility.None)
                                Text($r("app.string.messageSending"))
                                  .textAlign(TextAlign.Start)
                                  .fontSize(10)
                                  .fontColor($r('app.color.main_font_color_60'))
                                  .lineHeight(13)
                                  .margin({ top: 8 })
                                  .visibility(item.sendStatus == 1 ? Visibility.Visible : Visibility.None)
                                Text($r("app.string.messageDeliver"))
                                  .textAlign(TextAlign.Start)
                                  .fontSize(10)
                                  .fontColor($r('app.color.main_font_color_60'))
                                  .lineHeight(13)
                                  .margin({ top: 8 })
                                  .visibility(item.sendStatus == 0 ? Visibility.Visible : Visibility.None)
                              }.width('100%').margin({ right: 12 })
                            }
                            .width('100%')
                            .alignItems(HorizontalAlign.End)
                            // <!--发件人头像, 群消息时才存在-->
                            Flex({ direction: FlexDirection.Column,
                              justifyContent: FlexAlign.Start,
                              alignItems: ItemAlign.Center }) {
                              Image($rawfile('icon/user_avatar_full_fill.svg'))
                                .width(30)
                                .height(30)
                            }
                            .width(50)
                            .height(30)
                            .visibility(this.mConversationCtrl.contactsNum > 1 ? Visibility.Visible : Visibility.None)
                            // <!--信息checkbox-->
                            if (this.mConversationCtrl.isSelectStatus) {
                              Row() {
                                Toggle({ type: ToggleType.Checkbox, isOn: item.isCbChecked })
                                  .width(24)
                                  .height(24)
                                  .selectedColor($r("app.color.control_activated_color"))
                                  .onChange(((isOn: boolean) => {
                                    this.mConversationCtrl.listCheckBoxChange(index, isOn)
                                  }))
                              }
                              .width(48)
                              .height(48)
                              .margin({ left: 4 })
                            }
                          }
                          .useSizeType({
                            xs: { span: 4, offset: 0 }, sm: { span: 4, offset: 0 },
                            md: { span: 8, offset: 2 }, lg: { span: 8, offset: 2 }
                          })
                        }
                        .width('100%')
                        .useSizeType({
                          xs: { span: 4, offset: 0 }, sm: { span: 4, offset: 0 },
                          md: { span: 12, offset: 0 }, lg: { span: 12, offset: 0 }
                        })
                      }
                      // <!--收信息Item-->
                      else if (item.isReceive) {
                        // <!--收信息Item-->
                        Flex({
                          direction: FlexDirection.Column,
                          justifyContent: FlexAlign.Center,
                          alignItems: ItemAlign.Center
                        }) {
                          // 短信/彩信
                          if (index == 0) {
                            Text($r("app.string.msg_note_mms")).fontSize(12).lineHeight(16).fontColor($r('app.color.main_font_color_60')).margin({ bottom: 2 })
                          }
                          // 时间
                          if (item.dateShow) {
                            Text(){
                              Span(item.date).fontSize(12).fontColor($r('app.color.main_font_color_60'))
                              Span(item.week).fontSize(12).fontColor($r('app.color.main_font_color_60'))
                            }.lineHeight(16).margin({ bottom: 8 })
                          }

                          Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
                            Column() {
                              Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                                // 消息气泡
                                bubbleText({
                                  conversationCtrl: $mConversationCtrl,
                                  borderRadius: [4, 24],
                                  direction: 'left',
                                  content: item.content,
                                  backgroundColor: $r("app.color.receiver_bubble"),
                                  isShowMsgLongMenu: item.isShowMsgLongMenu,
                                  itemIndex: index
                                })
                              }
                              .useSizeType({
                                xs: { span: 4, offset: 0 }, sm: { span: 4, offset: 0 },
                                md: { span: 8, offset: 0 }, lg: { span: 8, offset: 0 }
                              })
                              // <!--发送时间、发送状态那行-->
                              Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                                Text(item.time).textAlign(TextAlign.Start).fontSize(10).lineHeight(13).fontColor($r('app.color.main_font_color_60')).margin({ top: 8, right: 5 })
                                // 卡1还是卡2
                                if (this.mConversationCtrl.cardImage) {
                                  Image(item.subId == 0 ? $rawfile('icon/icon_mms_sim_1.svg') : $rawfile('icon/icon_mms_sim_2.svg'))
                                    .width(10)
                                    .height(10)
                                    .margin({ top: 8, left: 5 })
                                }
                                // 是否锁定
                                if (item.isLock) {
                                  Image($rawfile('icon/msg_lock.svg'))
                                    .width(10)
                                    .height(10)
                                    .margin({ top: 8, left: 5 })
                                }
                              }.width('70%').margin({ left: 12 })
                            }
                            .width('100%')
                            .alignItems(HorizontalAlign.Start)

                            if (this.mConversationCtrl.isSelectStatus) {
                              Row() {
                                Toggle({ type: ToggleType.Checkbox, isOn: item.isCbChecked })
                                  .width(24)
                                  .height(24)
                                  .selectedColor($r("app.color.control_activated_color"))
                                  .onChange(((isOn: boolean) => {
                                    this.mConversationCtrl.listCheckBoxChange(index, isOn)
                                  }))
                              }
                              .margin({ left: 4 })
                              .width(48)
                              .height(48)
                            }
                          }
                        }.width('100%')
                        .useSizeType({
                          xs: { span: 4, offset: 0 }, sm: { span: 4, offset: 0 },
                          md: { span: 12, offset: 0 }, lg: { span: 12, offset: 0 }
                        })
                      }
                    }
                  }
                }.onClick(() => {
                  if (this.mConversationCtrl.isSelectStatus) {
                    this.mConversationCtrl.listCheckBoxChange(index,!item.isCbChecked)
                  }
                })
                .padding(index == this.mConversationCtrl.mmsList.length - 1 ? { bottom: 20 } : null)
              }, item => item.id)
            }
            .listDirection(Axis.Vertical) // 排列方向
            .edgeEffect(EdgeEffect.Spring) // 滑动到边缘无效果
            .width('100%')
          }
        }
        .width('100%')
        .flexBasis('auto')
        .flexShrink(1)
      }
      .width('100%')
      // <!--底部输入框-->
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        // <!--底部更多选项 -->
        if (this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete) {
          /** 底部选中了信息按钮 */
          Flex({
            direction: FlexDirection.Row,
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            /** 删除 */
            Flex({
              direction: FlexDirection.Column,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Center
            }) {
              Image($rawfile('icon/ic_public_delete.svg'))
                .width(24)
                .height(24)
              Text($r("app.string.delete")).fontSize(10).margin({ top: 3 }).fontColor($r('app.color.main_font_color'))
            }.width('25%').opacity(this.mConversationCtrl.selectDeleteMsgCount == 0 ? 0.4 : 1)
            .onClick(() => {
              if (this.mConversationCtrl.selectDeleteMsgCount != 0) {
                this.mConversationCtrl.clickGroupDelete()
              }
            })
            /** 转发 */
            Flex({ direction: FlexDirection.Column,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Center }) {
              Image($rawfile('icon/ic_transfer.svg'))
                .width(24)
                .height(24)
              Text($r("app.string.msg_transmit")) {

              }.fontSize(10).margin({ top: 3 }).fontColor($r('app.color.main_font_color'))
            }.width('25%').opacity(this.mConversationCtrl.selectDeleteMsgCount == 0 ? 0.4 : 1)
            .onClick(() => {

            })
            /** 收藏 */
            Flex({ direction: FlexDirection.Column,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Center }) {
              Image($rawfile('icon/ic_msg_favorite_m.svg'))
                .width(24)
                .height(24)
              Text($r("app.string.msg_star")) {

              }.fontSize(10).margin({ top: 3 }).fontColor($r('app.color.main_font_color'))
            }.width('25%').opacity(this.mConversationCtrl.selectDeleteMsgCount == 0 ? 0.4 : 1)
            .onClick(() => {

            })
            /** 全选 */
            Flex({ direction: FlexDirection.Column,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Center }) {
              Image(this.mConversationCtrl.isMessageCheckAll ? $rawfile('icon/ic_select_all_filled.svg') : $rawfile('icon/ic_select_all.svg'))
                .width(24)
                .height(24)
              Text(this.mConversationCtrl.isMessageCheckAll ? $r("app.string.msg_deselect_all") : $r("app.string.msg_select_all")) {
              }
              .fontSize(10)
              .margin({ top: 3 })
              .fontColor(this.mConversationCtrl.isMessageCheckAll ?
              $r("app.color.control_activated_color") : $r("app.color.main_font_color"))
            }.width('25%')
            .onClick(() => {
              this.mConversationCtrl.clickGroupCheckAll()
            })
            /** 更多 */
            Flex({ direction: FlexDirection.Column,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Center }) {
              Image($rawfile('icon/ic_message_more1.svg'))
                .width(24)
                .height(24)
              Text($r("app.string.more")) {
              }.fontSize(10).margin({ top: 3 }).fontColor($r('app.color.main_font_color'))
            }.width('25%')
            // @ts-ignore
            .bindMenu(this.mConversationCtrl.selectDeleteMsgCount == 1 ?
              [
//                {
//                  value: $r("app.string.msg_copy"),
//                  action: () => {
//
//                  }
//                },
//                {
//                  value: $r("app.string.share"),
//                  action: () => {
//
//                  }
//                },
//                {
//                  value: $r("app.string.msg_select_text"),
//                  action: () => {
//
//                  }
//                },
//                {
//                  value: $r("app.string.lock"),
//                  action: () => {
//
//                  }
//                },
                {
                  value: $r("app.string.query_details"),
                  action: () => {
                    this.dialogController.open()
                    this.mConversationCtrl.isSelectStatus = !this.mConversationCtrl.isSelectStatus
                    this.mConversationCtrl.isMessageCheckAll = false
                    this.mConversationCtrl.cancleCheckedAll()
                  }
                },
                this.mConversationCtrl.hasReport ? {
                  value: $r("app.string.query_report"),
                  action: () => {
                    this.mConversationCtrl.moreSelected(6)
                  }
                } : {}
              ] : [{}
//                    {
//                      value: $r("app.string.msg_copy"),
//                      action: () => {
//
//                      }
//                    },
//                    {
//                      value: $r("app.string.lock"),
//                      action: () => {
//                      }
//                    }
                ]
            )
          }
          .width('100%')
          .height(56)
        }
        // <!--底部发送栏-->
        if (!this.mConversationCtrl.isSelectStatus) {
          Flex({ alignItems: ItemAlign.End, justifyContent: FlexAlign.Center }) {
            // <!--左侧更多和全屏显示-->
            Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
              Flex() {
                Image($rawfile('icon/msg_add.svg'))
                  .onClick(() => {

                  })
                  .width(24)
                  .height(24)
                  .margin({ bottom: 16 })
              }
            }
            .flexBasis('40')
            .visibility(Visibility.Hidden)
            // <!--输入框-->
            Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
              Flex({ alignItems: ItemAlign.Center }) {
                Image(this.mConversationCtrl.slotId == 0 ? $rawfile('icon/ic_message_card1.svg') : $rawfile('icon/ic_message_card2.svg'))
                  .width(22)
                  .height(22)
                Image($rawfile('icon/icon_down.svg'))
                  .width(16)
                  .height(22)
              }
              .flexBasis(36)
              .visibility(this.mConversationCtrl.cardImage ? Visibility.Visible : Visibility.None)

              Flex() {
                TextArea({
                  placeholder: $r("app.string.msg_note_mms"),
                  text: this.mConversationCtrl.textValue
                })
                  .placeholderColor($r('app.color.placeholder_color'))
                  .caretColor($r('app.color.control_activated_color'))
                  .backgroundColor($r("app.color.transparent_color"))
                  .borderRadius(20)
                  .onChange(value => {
                    this.mConversationCtrl.changeValue(value);
                  })
              }
              .flexGrow(1)
              .flexShrink(1)
              .constraintSize({ minHeight: 40, maxHeight: 584 })
            }
            .backgroundColor($r("app.color.search_input_background"))
            .padding(this.mConversationCtrl.cardImage ? { left: 8, right: 8 } : 0)
            .borderRadius(20)
            .flexBasis('auto')
            .flexShrink(1)
            Column().width(12)
            Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
              Flex() {
                Image($r("app.media.smileyFace"))
                  .width(24)
                  .height(24)
                  .margin({ bottom: 16 })
              }
            }
            .flexBasis('40')
            .visibility(Visibility.Hidden)
            // <!--发送-->
            Flex({
              direction: FlexDirection.Row,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Start
            }) {
              //                Text((this.mConversationCtrl.textValue.length !=0 || this.mConversationCtrl.isEditMms)
              //                 ? this.mConversationCtrl.msgSendTip : '').fontSize(12)
              Flex() {
                Image(this.mConversationCtrl.canSendMessage ? $rawfile('icon/ic_message_send_filled.svg') : $rawfile('icon/ic_message_send.svg'))
                  .onClick(() => {
                    //  点击发送按钮
                    this.mConversationCtrl.send()
                  })
                  .width(24)
                  .height(24)
                  .margin({ bottom: 16 })
              }
            }
            .flexBasis('40')
          }
          .constraintSize({ minHeight: 72 })
          .width('100%').padding({ bottom: 16, top: 8 })
        }
      }
      .width('100%')
      .padding({ left: 24, right: 12 })
      .backgroundColor($r("app.color.white"))
    }
    .backgroundColor($r("app.color.detail_main_background"))
    .width('100%')
    .height('100%')
  }
}

@CustomDialog
struct DetailsDialog {
  controller: CustomDialogController
  item: LooseObject
  receiver: string

  build() {
    Column() {
      Text($r("app.string.msgDetails"))
        .width('70%')
        .fontSize(20)
        .fontColor($r('app.color.main_font_color'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })
      Text() {
        Span($r("app.string.type")).fontSize(16)
        Span($r("app.string.sms")).fontSize(16)
      }.fontSize(16).fontColor($r('app.color.main_font_color')).margin({ bottom: 10 })

      Text() {
        Span($r("app.string.putAddresser")).fontSize(16)
        Span(this.receiver).fontSize(16)
      }.fontSize(16).fontColor($r('app.color.main_font_color')).margin({ bottom: 10 })

      Text() {
        Span($r("app.string.sendTime")).fontSize(16)
        Span(this.item.date).fontSize(16)
      }.fontSize(16).fontColor($r('app.color.main_font_color')).margin({ bottom: 10 })

      Flex({ justifyContent: FlexAlign.Center }) {
        Button() {
          Text($r("app.string.msg_know")).fontSize(16).fontColor($r('app.color.control_activated_color'))
        }
        .width(200)
        .backgroundColor($r("app.color.white"))
        .onClick(() => {
          this.controller.close()
        })
      }
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
  }
}

// 自定义聊天气泡
@Component
struct bubbleText {
  @Link conversationCtrl: ConversationController;
  private borderRadius: Array<number>; // 圆角大小，共两个参数
  private direction: string; // left:左上角 right: 右上角
  private content: string; // 气泡显示内容
  private backgroundColor: Resource | string; // 气泡背景色
  private isShowMsgLongMenu: boolean;
  private itemIndex: number;
  @State showMenu: boolean = false
  @Builder MenuBuilder() {
    Row() {
      Button($r("app.string.delete"))
        .fontSize(14)
        .fontColor($r('app.color.main_font_color'))
        .backgroundColor($r("app.color.white"))
        .onClick(() => {
          this.conversationCtrl.longPressSelected(2)
          this.showMenu = false
        })
      Button($r("app.string.more"))
        .fontSize(14)
        .fontColor($r('app.color.main_font_color'))
        .backgroundColor($r("app.color.white"))
        .onClick(() => {
          this.conversationCtrl.longPressSelected(4)
          this.showMenu = false
        })
    }
    .height(40)
    .borderRadius(20)
    .backgroundColor($r("app.color.white"))
  }

  build() {
    Row() {
      Text(this.content)
        .fontSize(16)
        .lineHeight(21)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.backgroundColor)
        .borderRadius(this.borderRadius[1])
        .fontColor($r('app.color.main_font_color'))
    }
    .flexBasis('auto')
    .gesture(
    LongPressGesture({ repeat: false, duration: 500 })
      //长按动作存在会连续触发
      .onAction(() => {
        if (!this.conversationCtrl.isSelectStatus) {
          this.conversationCtrl.mmsListLongPress(this.itemIndex)
          this.showMenu = true
        }
      })
    )
    .bindPopup(this.showMenu, {
      builder: this.MenuBuilder,
      placement: this.direction == 'left' ? Placement.TopRight :  Placement.TopLeft,
      maskColor: $r("app.color.mask_color"),
      popupColor: $r("app.color.transparent_color"),
      enableArrow: false,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.showMenu = false
        }
      }
    })
  }
}