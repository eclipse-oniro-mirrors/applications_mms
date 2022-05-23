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
import LooseObject from '../data/LooseObject';

@Component
export struct MmsListItem {
  @State item: LooseObject = {};
  @State index: number = 0;
  @State isShowHead: boolean = true;
  @State isMultipleSelectState: boolean = false;
  onClickHead: (event?: ClickEvent) => void;
  onClickBody: (event?: ClickEvent) => void;
  onItemLongPress: (event?: GestureEvent) => void;
  onTouchStart: (event?: GestureEvent) => void;
  onTouchUpdate: (event?: GestureEvent) => void;
  onTouchEnd: (event?: GestureEvent) => void;
  onClickFirstSlipBtn: (event?: ClickEvent) => void;
  onClickSecondSlipBtn: (event?: ClickEvent) => void;

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.End }) {
      Row() {
        Row() {
          //头像
          if (this.isShowHead) {
            //是否需要加未读标志红点
            Stack() {
              Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                if(this.item.conversation.countOfUnread > 0) {
                  Text(this.item.conversation.countOfUnread < 100 ? this.item.conversation.countOfUnread.toString() : '99+')
                    .fontSize(10)
                    .align(Alignment.Center)
                    .padding({ left: 5, right: 5 })
                    .height(20)
                    .backgroundColor(Color.Red)
                    .fontColor($r("app.color.white"))
                    .zIndex(2)
                    .position({ x: '60%', y: '-10%' })
                    .border({ width: 2, color: $r("app.color.white"), radius: 50 })
                }
                Image($rawfile(this.item.conversation.icon))
                  .width('40vp')
                  .height('40vp')
              }
              .width('40vp')
              .height('40vp')
              .onClick(this.onClickHead)
            }
          }
          //body
          Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
            Divider().vertical(false)
              .width('100%').height('1vp')
              .color($r("app.color.divider_color"))
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center }) {
              Flex({ direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                //电话号码或名字
                Text(this.item.conversation.name != '' ? this.item.conversation.name : this.item.conversation.telephoneFormat)
                  .fontSize('16fp')
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontColor($r("app.color.main_font_color"))
                  .maxLines(1)
                Text().width(16)
                //日期时间
                Text(this.item.conversation.time)
                  .fontColor($r('app.color.main_font_color_40'))
                  .fontSize('12fp')
                  .maxLines(1)
                  .flexShrink(0)
              }.width('100%')

              //最新消息的内容缩略语
              Row() {
                //最新的消息是否未发送成功，如果是
                if (this.item.conversation.sendingFailed) {
                  Text($r("app.string.messageSendFailed"))
                    .fontSize('12fp')
                    .fontColor(Color.Red)
                } else {
                  //如果不是
                  Text() {
                    //最新的消息是否是草稿，如果是
                    if (this.item.conversation.isDraft) {
                      Span($r("app.string.draft"))
                        .fontSize('14fp')
                        .fontColor(Color.Red)
                    }
                    //如果不是，且未读的消息个数>1条
                    if (!this.item.conversation.isDraft && this.item.conversation.countOfUnread > 1) {
                      Span($r("app.string.multiUnread", this.item.conversation.countOfUnread))
                        .fontSize('14fp')
                        .fontColor('#666666')
                    }
                    //最新消息的内容缩略语
                    Span(this.item.conversation.content)
                      .fontSize('14fp')
                      .fontColor($r('app.color.main_font_color_40'))
                  }
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .alignSelf(ItemAlign.Start)
              .alignItems(VerticalAlign.Top)
              .width('100%')
              .margin({ top: '2vp' })
            }.width('100%')
            .height('100%')
          }
          .layoutWeight(1)
          .height('100%')
          .padding({ left: '12vp' })

          //CheckBox选择框
          if (this.isMultipleSelectState) {
            Toggle({ type: ToggleType.Checkbox, isOn: this.item.conversation.isCbChecked })
              .width('20vp')
              .height('20vp')
              .enabled(false)
          }
        }
        .width('100%')
        .height('100%')
        .translate({
          x: this.item.conversation.itemLeft
        })
        //左滑的删除图标
        if (!this.isMultipleSelectState) {
          Flex({
            direction: FlexDirection.Row,
            justifyContent: FlexAlign.Center,
            alignItems: ItemAlign.Center
          }) {
            if (this.item.conversation.countOfUnread > 0) {
              Image($rawfile("icon/msg_done.svg"))
                .width(40)
                .height(40)
                .margin({ right: 8 })
                .onClick(this.onClickFirstSlipBtn)
            }
            Image($rawfile("icon/msg_delete.svg"))
              .width(40)
              .height(40)
              .onClick(this.onClickSecondSlipBtn)
          }
          .width(this.item.countOfUnread > 0 ? 128 : 80)
          .height('100%')
          .backgroundColor($r("app.color.title_bar_background"))
          .padding({ right: '16vp' })
          .translate({
            x: this.item.conversation.itemLeft
          })
        }
      }
      .width('100%')
      .height('100%')
      .gesture(PanGesture({ direction: this.item.conversation.isDelShow ? PanDirection.Right : PanDirection.Left })
        .onActionStart(this.onTouchStart)
        .onActionUpdate(this.onTouchUpdate)
        .onActionEnd(this.onTouchEnd)
      )
    }
    .onClick(this.onClickBody)
    .gesture(LongPressGesture().onAction(this.onItemLongPress))
  }
}