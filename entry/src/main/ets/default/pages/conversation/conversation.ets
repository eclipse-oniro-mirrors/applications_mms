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
import ConversationController from './conversationController'
import {Receive} from '../../views/receive/receive'
import LooseObject from '../../data/LooseObject'
import mediaquery from '@ohos.mediaquery'
import observer from '@ohos.telephony.observer';
let portraitFunc = null
@Entry
@Component
export struct Conversation {
  @StorageLink('ConversationController') conversationController: ConversationController = ConversationController.getInstance();
  /** 短信详情弹框 */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DetailsDialog({
      item: this.conversationController.mmsList[this.conversationController.mmsIndex],
      receiver: this.conversationController.strContactsName == ''
        ? this.conversationController.strContactsNumber :
        this.conversationController.strContactsName
    }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -30 }
  })
  // 监听横竖屏
  listener = mediaquery.matchMediaSync('(orientation: landscape)')
  onPortrait(mediaQueryResult) {
    if (mediaQueryResult.matches) {
      console.log("mediaQuery landScape")
      this.sizeType = SizeType.LG
    } else {
      console.log("mediaQuery vert")
      this.sizeType = SizeType.XS
      this.columns = 4
      this.margin = '12vp'
    }
  }

  private aboutToAppear(): void  {
    this.onPortrait(this.listener)
    portraitFunc = this.onPortrait.bind(this)
    this.listener.on('change', portraitFunc)
    // 实时监听SIM卡状态
    observer.on('simStateChange', data => {
      let simState = data.state
      if (simState == 0 || simState == 1) {
        this.conversationController.haveSimCard = false
      } else {
        this.conversationController.haveSimCard = true
      }
      this.conversationController.initSendTip()
    });
    this.conversationController.onInit()
    // 初始化函数
  }

  private onPageShow(): void  {
    this.conversationController.onShow()
  }

  private onBackPress(): void {
    this.conversationController.onBackPress()
  }

  @State columns: number = 12;
  @State sizeType: SizeType = SizeType.LG;
  @State gutter: string = '24vp';
  @State margin: string = '24vp';

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
      Flex({ direction: FlexDirection.Column,alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
        // <!--上方titleBar-->
        // 新建界面
        if (this.conversationController.isNewMsg) {
          Row() {
            Image($rawfile('icon/ic_message_back.svg'))
              .width('24vp')
              .height('24vp')
              .onClick(() => {
                // 点击返回恢复到未选中短信状态
                this.conversationController.titleBarBack()
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
            if (this.conversationController.isSelectStatus) {
              Row() {
                Image($rawfile('icon/ic_cancel_black.svg'))
                  .width(24)
                  .height(24)
                  .onClick(() => {
                    // 点击返回恢复到未选中短信状态
                    this.conversationController.titleBarCancel()
                  })
                Text(this.conversationController.selectDeleteMsgCount == 0 ? $r("app.string.msg_unselected_tip") : $r("app.string.msg_selected_tip", this.conversationController.selectDeleteMsgCount))
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
                        this.conversationController.titleBarBack()
                      })
                    Image($rawfile('icon/user_avatar_full_fill.svg'))
                      .width(40)
                      .height(40)
                      .margin({ left: 16 })
                      .onClick(() => {
                        this.conversationController.titleBarAvatar();
                      })
                  }
                  .flexBasis(80)

                  Column() {
                    Flex({
                      direction: FlexDirection.Column,
                      justifyContent: FlexAlign.Center,
                      alignItems: ItemAlign.Start
                    }) {
                      if (this.conversationController.contactsNum > 1) {
                        Text(this.conversationController.strContactsName).fontSize(16).fontColor($r('app.color.main_font_color'))
                        Text($r("app.string.members", this.conversationController.contactsNum)).fontSize(14).fontColor($r('app.color.main_font_color_40'))
                      } else if (this.conversationController.strContactsName == '' || this.conversationController.strContactsName == null) {
                        Text(this.conversationController.strContactsNumberFormat).fontSize(16).fontColor($r('app.color.main_font_color'))
                      } else {
                        Text(this.conversationController.strContactsName).fontSize(16).fontColor($r('app.color.main_font_color'))
                        Text(this.conversationController.strContactsNumberFormat).fontSize(14).fontColor($r('app.color.main_font_color_40'))
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
                        this.conversationController.clickCall();
                      })
                    Image($rawfile('icon/ic_message_more1.svg'))
                      .width(24)
                      .height(24)
                      .margin({ left: 16 })
                      .bindMenu([
                        {
                          // @ts-ignore
                          value: $r("app.string.delete"),
                          action: () => {
                            this.conversationController.longPressMore(0);
                          }
                        },
                        //                    {
                        //                      // @ts-ignore
                        //                      value: $r("app.string.msg_new_contact"),
                        //                      action: () => {
                        //                        this.conversationController.longPressMore(1);
                        //                      }
                        //                    },
                        //                    {
                        //                      // @ts-ignore
                        //                      value: $r("app.string.msg_save_to_an_existing_contact"),
                        //                      action: () => {
                        //                        this.conversationController.longPressMore(2);
                        //                      }
                        //                    },
                        //                    {
                        //                      // @ts-ignore
                        //                      value: $r("app.string.msg_pre_call_editor"),
                        //                      action: () => {
                        //                        this.conversationController.longPressMore(3);
                        //                      }
                        //                    },
                        //                    {
                        //                      // @ts-ignore
                        //                      value: $r("app.string.msg_blacklist"),
                        //                      action: () => {
                        //
                        //                      }
                        //                    }
                      ])
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
          if (this.conversationController.isNewMsg) {
            Row() {
              Receive()
            }.margin({ top: 8 })
          }
          // 短信内容
          // <!--信息列表-->
          if (!this.conversationController.isNewMsg) {
            List({ space: 10, initialIndex: this.conversationController.mmsList.length - 1 }) {
              ForEach(this.conversationController.mmsList, (item, index) => {
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
                          if (!this.conversationController.mmsDateSet.has(item.date.id) &&
                          this.conversationController.mmsDateSet.add(item.date.id)) {
                            Text(item.date).fontSize(12).lineHeight(16).fontColor($r('app.color.main_font_color_60')).margin({ bottom: 8 })
                          }
                          Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                            Column() {
//                              if (this.conversationController.isSelectStatus == false && item.isShowMsgLongMenu) {
//                                menu({
////                                  controller: this.conversationController,
//                                  index: index,
//                                  isSender: true
//                                })
//                              }
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
                                  if (!item.isMsm && ((this.conversationController.contactsNum == 1 && item.sendStatus == 2) || (this.conversationController.contactsNum > 1 && item.failuresNumber > 0 && item.completeNumber == this.conversationController.contactsNum))) {
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
                                if (this.conversationController.contactsNum == 1 && item.sendStatus != 1) {
                                  Text(item.time).textAlign(TextAlign.Start).fontSize(10).lineHeight(13).fontColor($r('app.color.main_font_color_60')).margin({ top: 8, right: 5 })
                                }
                                // 卡1还是卡2
                                if (this.conversationController.cardImage) {
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
                            .visibility(this.conversationController.contactsNum > 1 ? Visibility.Visible : Visibility.None)
                            // <!--信息checkbox-->
                            Toggle({ type: ToggleType.Checkbox, isOn: item.isCbChecked })
                              .width(20)
                              .height(20)
                              .visibility(this.conversationController.isSelectStatus ? Visibility.Visible : Visibility.None)
                              .onChange(((isOn: boolean) => {
                                this.conversationController.listCheckBoxChange(index, isOn)
                              }))
                          }
                          .useSizeType({
                            xs: { span: 4, offset: 0 }, sm: { span: 8, offset: 2 },
                            md: { span: 8, offset: 2 }, lg: { span: 8, offset: 2 }
                          })
                        }
                        .width('100%')
                        .useSizeType({
                          xs: { span: 4, offset: 0 }, sm: { span: 12, offset: 0 },
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
                          if (!this.conversationController.mmsDateSet.has(item.date.id) &&
                          this.conversationController.mmsDateSet.add(item.date.id)) {
                            Text(item.date).fontSize(12).lineHeight(16).fontColor($r('app.color.main_font_color_60')).margin({ bottom: 8 })
                          }

                          Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                            Column() {
//                              if (this.conversationController.isSelectStatus == false && item.isShowMsgLongMenu) {
//                                menu({
////                                  controller: this.conversationController,
//                                  index: index,
//                                  isSender: false
//                                })
//                              }
                              Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                                // 消息气泡
                                bubbleText({
                                  borderRadius: [4, 24],
                                  direction: 'left',
                                  content: item.content,
                                  backgroundColor: $r("app.color.receiver_bubble"),
                                  isShowMsgLongMenu: item.isShowMsgLongMenu,
                                  itemIndex: index
                                })
                              }
                              .useSizeType({
                                xs: { span: 4, offset: 0 }, sm: { span: 8, offset: 0 },
                                md: { span: 8, offset: 0 }, lg: { span: 8, offset: 0 }
                              })
                              // <!--发送时间、发送状态那行-->
                              Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                                Text(item.time).textAlign(TextAlign.Start).fontSize(10).lineHeight(13).fontColor($r('app.color.main_font_color_60')).margin({ top: 8, right: 5 })
                                // 卡1还是卡2
                                if (this.conversationController.cardImage) {
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

                            Toggle({ type: ToggleType.Checkbox, isOn: item.isCbChecked })
                              .width(20)
                              .height(20)
                              .visibility(this.conversationController.isSelectStatus ? Visibility.Visible : Visibility.None)
                              .onChange(((isOn: boolean) => {
                                this.conversationController.listCheckBoxChange(index, isOn)
                              }))
                          }
                        }.width('100%')
                        .useSizeType({
                          xs: { span: 4, offset: 0 }, sm: { span: 12, offset: 0 },
                          md: { span: 12, offset: 0 }, lg: { span: 12, offset: 0 }
                        })
                      }
                    }
                  }
                }.onClick(() => {
                  if (this.conversationController.isSelectStatus) {
                    this.conversationController.listCheckBoxChange(index,!item.isCbChecked)
                  }
                })
//                .padding({ left: 24, right: 24 })

              }, item => item.id)
            }
            .listDirection(Axis.Vertical) // 排列方向
            .edgeEffect(EdgeEffect.Spring) // 滑动到边缘无效果
            .width('100%')
          }
        }
        .width('100%')
        .flexBasis('auto')

      }
      .width('100%')
      // <!--底部输入框-->
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        // <!--底部更多选项 -->
        if (this.conversationController.isSelectStatus && !this.conversationController.hasDetailDelete) {
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
              Image($rawfile('icon/ic_delete_m.svg'))
                .width(24)
                .height(24)
              Text($r("app.string.delete")).fontSize(10).margin({ top: 3 }).fontColor($r('app.color.main_font_color'))
            }.width('25%').opacity(this.conversationController.selectDeleteMsgCount == 0 ? 0.4 : 1)
            .onClick(() => {
              if (this.conversationController.selectDeleteMsgCount != 0) {
                this.conversationController.clickGroupDelete()
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
            }.width('25%').opacity(this.conversationController.selectDeleteMsgCount == 0 ? 0.4 : 1)
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
            }.width('25%').opacity(this.conversationController.selectDeleteMsgCount == 0 ? 0.4 : 1)
            .onClick(() => {

            })
            /** 全选 */
            Flex({ direction: FlexDirection.Column,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Center }) {
              Image(this.conversationController.isMessageCheckAll ? $rawfile('icon/ic_select_all_filled.svg') : $rawfile('icon/ic_select_all.svg'))
                .width(24)
                .height(24)
              Text(this.conversationController.isMessageCheckAll ? $r("app.string.msg_deselect_all") : $r("app.string.msg_select_all")) {
              }.fontSize(10).margin({ top: 3 }).fontColor($r('app.color.main_font_color'))
            }.width('25%')
            .onClick(() => {
              this.conversationController.clickGroupCheckAll()
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
            .bindMenu(this.conversationController.selectDeleteMsgCount == 1 ?
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
                    this.conversationController.isSelectStatus = !this.conversationController.isSelectStatus
                    this.conversationController.isMessageCheckAll = false
                    this.conversationController.cancleCheckedAll()
                  }
                },
                this.conversationController.hasReport ? {
                  value: $r("app.string.query_report"),
                  action: () => {
                    this.conversationController.moreSelected(6)
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
        if (!this.conversationController.isSelectStatus) {
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
            .visibility(Visibility.None)
            // <!--输入框-->
            Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
              Flex({ alignItems: ItemAlign.Center }) {
                Image(this.conversationController.slotId == 0 ? $rawfile('icon/ic_message_card1.svg') : $rawfile('icon/ic_message_card2.svg'))
                  .width(22)
                  .height(22)
                Image($rawfile('icon/icon_down.svg'))
                  .width(16)
                  .height(22)
              }
              .flexBasis(36)
              .visibility(this.conversationController.cardImage ? Visibility.Visible : Visibility.None)

              Flex() {
                TextArea({
                  placeholder: $r("app.string.msg_note_mms"),
                  text: this.conversationController.textValue
                })
                  .placeholderColor($r('app.color.placeholder_color'))
                  .caretColor($r('app.color.control_activated_color'))
                  .backgroundColor($r('app.color.default_main_background'))
                  .borderRadius(20)
                  .onChange(value => {
                    this.conversationController.changeValue(value);
                  })
              }.flexGrow(1).constraintSize({ minHeight: 40, maxHeight: 584 })
            }
            .backgroundColor($r('app.color.default_main_background'))
            .padding({ left: 8, right: 8 })
            .borderRadius(20)
            .flexBasis('auto')
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
            .visibility(Visibility.None)
            // <!--发送-->
            Flex({
              direction: FlexDirection.Row,
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.Start
            }) {
              //                Text((this.conversationController.textValue.length !=0 || this.conversationController.isEditMms)
              //                 ? this.conversationController.msgSendTip : '').fontSize(12)
              Flex() {
                Image(this.conversationController.canSendMessage ? $rawfile('icon/ic_message_send_filled.svg') : $rawfile('icon/ic_message_send.svg'))
                  .onClick(() => {
                    //  点击发送按钮
                    this.conversationController.send()
                  })
                  .width(24)
                  .height(24)
                  .opacity(this.conversationController.canSendMessage ? 1 : 0.4)
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
      .padding({ left: 24, right: 24 })
      .backgroundColor($r("app.color.white"))
    }
    .backgroundColor($r("app.color.default_main_background"))
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
  @StorageLink('ConversationController') controller: ConversationController = ConversationController.getInstance();
  private borderRadius: Array<number>; // 圆角大小，共两个参数
  private direction: string; // left:左上角 right: 右上角
  private content: string; // 气泡显示内容
  private backgroundColor: Resource | string; // 气泡背景色
  private isShowMsgLongMenu: boolean;
  private itemIndex: number;
  @State showMenu: boolean = false
  @Builder MenuBuilder() {
    Row() {
      //      Button($r("app.string.msg_copy"))
      //        .fontSize(14)
      //        .fontColor(Color.Black)
      //        .backgroundColor($r("app.color.white"))
      //      Button($r("app.string.msg_transmit"))
      //        .fontSize(14)
      //        .fontColor(Color.Black)
      //        .backgroundColor($r("app.color.white"))
      Button($r("app.string.delete"))
        .fontSize(14)
        .fontColor(Color.Black)
        .backgroundColor($r("app.color.white"))
        .onClick(() => {
          this.controller.longPressSelected(2)
          this.showMenu = false
        })
      //      Button($r("app.string.msg_select_text"))
      //        .fontSize(12)
      //        .fontColor(Color.Black)
      //        .backgroundColor($r("app.color.white"))
      Button($r("app.string.more"))
        .fontSize(14)
        .fontColor(Color.Black)
        .backgroundColor($r("app.color.white"))
        .onClick(() => {
          this.controller.longPressSelected(4)
          this.showMenu = false
        })
    }
    .height(40)
//    .padding(10)
    .borderRadius(20)
    .backgroundColor($r("app.color.white"))
  }

  build() {
    Row() {
      Stack({ alignContent: this.direction == 'left' ? Alignment.TopStart : Alignment.TopEnd }) {
        Text()
          .backgroundColor(this.backgroundColor)
          .borderRadius(this.borderRadius[0])
          .width(24)
          .height(24)
          .visibility(this.content ? Visibility.Visible : Visibility.None)
        Text(this.content)
          .fontSize(16)
          .lineHeight(21)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.backgroundColor)
          .borderRadius(this.borderRadius[1])
          .fontColor($r('app.color.main_font_color'))

      }
    }
    .flexBasis('auto')
    .gesture(
    LongPressGesture({ repeat: false, duration: 500 })
      //长按动作存在会连续触发
      .onAction(() => {
        if (!this.controller.isSelectStatus) {
          this.controller.mmsListLongPress(this.itemIndex)
          this.showMenu = true
        }
      })
    )
    .bindPopup(this.showMenu, {
      builder: this.MenuBuilder,
      placement: this.direction == 'left' ? Placement.TopRight :  Placement.TopLeft,
      maskColor: 0x33000000,
      popupColor: Color.White,
      enableArrow: false,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.showMenu = false
        }
      }
    })
  }
}