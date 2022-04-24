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
import DeviceUtil from "../../utils/DeviceUtil";
import InfoMsgController from "./InfoMsgController";
import { DeleteDialog } from "../../views/MmsDialogs";
import { MmsListItem } from "../../views/MmsListItem";
import { MmsMenu } from "../../views/MmsMenu";

@Entry
@Component
export default struct InfoMsg {
  @StorageLink('InfoMsgController') mInfoMsgCtrl: InfoMsgController = InfoMsgController.getInstance();
  @State gridColumns: number = DeviceUtil.isTablet() ? 12 : 4;
  @State gridSizeType: SizeType = DeviceUtil.isTablet() ? SizeType.LG : SizeType.SM;
  @State gridGutter: string = "24vp";
  @State gridMargin: string = "24vp";
  private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
  private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };
  delDialogController: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({
      cancel: () => {
        this.mInfoMsgCtrl.deleteDialogCancel()
      },
      confirm: () => {
        this.mInfoMsgCtrl.deleteDialogConfirm()
      },
      msg: this.mInfoMsgCtrl.strMsgDeleteDialogTip,
      hasLockMsg: this.mInfoMsgCtrl.hasLockMsg,
      setSelectLock: () => {
        this.mInfoMsgCtrl.setSelectLock()
      },
      isSelectLockMsg: this.mInfoMsgCtrl.isSelectLockMsg,
      setSelectLockChange: (isOn: boolean) => {
        this.mInfoMsgCtrl.setSelectLockChange(isOn)
      }
    }),
    autoCancel: false,
    alignment: this.dialogAlignment,
    offset: this.dialogOffset
  })

  private menuItems: Array<any> = [
    {
      value: $r("app.string.delete"),
      action: () => {
        this.mInfoMsgCtrl.selectInMoreMenu(1);
      },
      enabled: true
    },
    {
      value: $r("app.string.blocked"),
      action: () => {
        this.mInfoMsgCtrl.selectInMoreMenu(2);
      },
      enabled: true
    }
  ];

  /**
   * 函数在创建自定义组件的新实例后，在执行其build函数之前执行。
   * 允许在aboutToAppear函数中改变状态变量，这些更改将在后续执行build函数中生效。
   */
  aboutToAppear() {
    this.mInfoMsgCtrl.onInit()
  }
  /**
   * 函数在自定义组件析构消耗之前执行。
   * 不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。
   */
  aboutToDisappear() {
  }
  /**
   * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageShow() {
    this.mInfoMsgCtrl.onShow()
  }
  /**
   * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageHide() {
    this.mInfoMsgCtrl.onHide()
  }
  /**
   * 当用户点击返回按钮时触发，，仅@Entry修饰的自定义组件生效。
   * 返回true表示页面自己处理返回逻辑, 不进行页面路由。
   * 返回false表示使用默认的返回逻辑。
   * 不返回值会作为false处理。
   */
  onBackPress() {
    // 系统返回键,true代表拦截
    if (this.mInfoMsgCtrl.isMultipleSelectState) {
      for (let element of this.mInfoMsgCtrl.messageList) {
        element.isCbChecked = false;
      }
      this.mInfoMsgCtrl.isMultipleSelectState = false;
      this.mInfoMsgCtrl.showToolBar = true;
      return true;
    }
    return false;
  }

  build() {

    GridContainer({ columns: this.gridColumns, sizeType: this.gridSizeType, gutter: this.gridGutter, margin: this.gridMargin }) {
      //通知信息
      Column() {
        if (this.mInfoMsgCtrl.isMultipleSelectState) {
          //多选状态标题
          Flex({ direction: FlexDirection.Column }) {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
              Image($rawfile("icon/ic_public_cancel.svg"))
                .width('24vp')
                .height('24vp')
                .onClick(() => {
                  this.onBackPress()
                })
              Text(this.mInfoMsgCtrl.conversationSelectedNumber == 0 ? $r('app.string.msg_unselected_tip') :
              $r('app.string.msg_selected_tip', this.mInfoMsgCtrl.conversationSelectedNumber))
                .padding({ left: '16vp' })
                .fontSize('20fp')
                .fontWeight(FontWeight.Bold)
            }
            .height('56vp')
          }
          .width('100%')
          .height('56vp')
        } else if (!this.mInfoMsgCtrl.searchStatus) {
          //标题行
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
              Image($rawfile("icon/ic_message_back.svg"))
                .width('24vp')
                .height('24vp')
                .onClick(() => {
                  this.mInfoMsgCtrl.back()
                })
              Text($r("app.string.infoMessages"))
                .padding({ left: '16vp' })
                .fontSize('20fp')
                .fontWeight(FontWeight.Bold)
            }
            .height('56vp')
          }
          .width('100%')
          .height('56vp')
        }

        Row() {
          //返回按钮
          if (this.mInfoMsgCtrl.isShowSearchBack) {
            Image($rawfile("icon/ic_message_back.svg"))
              .width(24)
              .height(24)
              .onClick((event: ClickEvent) => {
                this.mInfoMsgCtrl.clickSearchBack();
              })
          }
          //搜索框
          // @ts-ignore
          Search({ value: this.mInfoMsgCtrl.inputValueOfSearch, placeholder: "搜索通知信息" })
            .layoutWeight(1)
            .height('40vp')
            .border({ radius: '20vp' })
              //            .focusable(this.mInfoMsgCtrl.isSearchFocusable)
            .enabled(!this.mInfoMsgCtrl.isMultipleSelectState)
            .backgroundColor($r("app.color.search_input_background"))
            .onChange((value: string) => {
              this.mInfoMsgCtrl.clickToSearch(value);
            })
            .onSubmit((value: string) => {
              this.mInfoMsgCtrl.clickToSearch(value);
            })
          //          .onTouch((event: TouchEvent) => {
          //            if (event.type === TouchType.Down) {
          //              this.mInfoMsgCtrl.searchTouchStart(true, event)
          //            }
          //          })
        }
        .visibility(Visibility.None)
        .width('100%')
        .height('56vp')
        .padding({ left: 24, right: 24 })
        .alignItems(VerticalAlign.Center)

        //短信展示列表
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            List({ initialIndex: 0 }) {
              LazyForEach(this.mInfoMsgCtrl.conversationListDataSource, (item, index) => {
                //真正的信息列表
                if (this.mInfoMsgCtrl.isSearchStatus) {
                  ListItem() {
                    MmsListItem({
                      item: item,
                      index: index,
                      isShowHead: this.mInfoMsgCtrl.isShowContactHeadIcon,
                      isMultipleSelectState: this.mInfoMsgCtrl.isMultipleSelectState,
                      onClickHead: (event: ClickEvent) => {
                        this.mInfoMsgCtrl.clickToGroupDetail(item.index);
                      },
                      onClickBody: (event: ClickEvent) => {
                        this.mInfoMsgCtrl.clickInfoToConversation(item.index);
                      },
                      onItemLongPress: (event: GestureEvent) => {
                        this.mInfoMsgCtrl.conversationLongPress(item.index)
                      },
                      onTouchStart: (event: GestureEvent) => {
                        this.mInfoMsgCtrl.touchStart(event, item.index);
                      },
                      onTouchUpdate: (event: GestureEvent) => {
                        this.mInfoMsgCtrl.touchMove(event, item.index);
                      },
                      onTouchEnd: (event: GestureEvent) => {
                        this.mInfoMsgCtrl.touchEnd(event, item.index);
                      },
                      onClickFirstSlipBtn: (event: ClickEvent) => {
                        this.mInfoMsgCtrl.markAllAsReadByIndex(item.index);
                      },
                      onClickSecondSlipBtn: (event: ClickEvent) => {
                        this.mInfoMsgCtrl.deleteAction(item.index);
                        this.delDialogController.open();
                      }
                    })
                  }
                  .width('100%')
                  .height('64vp')
                  .alignSelf(ItemAlign.Start)
                }
              }, item => item.threadId)
            }
            .align(Alignment.Top)
            .cachedCount(this.mInfoMsgCtrl.limit)
          }.width('100%')
          //搜索上方
          //短信搜索会话item
          //左侧头像
          //右侧信息等
          //上方的name和日期
          //下方的信息详情
          //中间间隔线
          //搜索信息列表 信息条码数量
          //搜索信息列表
          //左侧头像
          //右侧信息等
          //上方的name和日期
          //下方的信息详情
          //如果没有会话信息，也就是{{total}}为0，则显示空白图片
          //显示搜索状态
          if (this.mInfoMsgCtrl.isSearchCoverage) {
            //图层用于搜索的展示
            Flex()
              .width('100%')
              .height('100%')
              .opacity(0.2)
              .backgroundColor(Color.Gray)
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.mInfoMsgCtrl.searchCoverageClick()
                }
              })
          }
        }
        .flexGrow(1)
        //单个会话长按选项
        if (this.mInfoMsgCtrl.isMultipleSelectState) {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
            //删除
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              Image($rawfile(this.mInfoMsgCtrl.svgDelete))
                .width('24vp')
                .height('24vp')
                .margin({ top: '3vp' })
              Text($r("app.string.delete")).fontSize('10fp')
            }
            .width('50%')
            .opacity(this.mInfoMsgCtrl.checkSelectedNumberIsEmpty() ? 0.4 : 1)
            .onClick(() => {
              if (!this.mInfoMsgCtrl.checkSelectedNumberIsEmpty()) {
                this.mInfoMsgCtrl.clickConversationDelete()
                this.delDialogController.open()
              }
            })
            //全选
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              Image($rawfile(this.mInfoMsgCtrl.isConversationCheckAll ? 'icon/ic_select_all_filled.svg' : 'icon/ic_select_all.svg'))
                .width('24vp')
                .height('24vp')
                .margin({ top: '3vp' })
              Text(this.mInfoMsgCtrl.strCheckBoxSelectTip)
                .fontSize('10fp')
                .fontColor(this.mInfoMsgCtrl.isConversationCheckAll ? '#007DFF' : '#2C2C2C')
            }
            .width('50%')
            .onClick(() => {
              this.mInfoMsgCtrl.clickConversationCheckAll()
            })
          }
          .width('100%')
          .height('56vp')
          .padding({ left: '86vp', right: '86vp' })
        }
        //全部已读和更多
        if (!this.mInfoMsgCtrl.isMultipleSelectState && this.mInfoMsgCtrl.showToolBar) {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
            //全部已读
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              Image($rawfile('icon/ic_allread.svg'))
                .width('24vp')
                .height('24vp')
                .margin({ top: '3vp' })
              Text($r("app.string.markAllAsRead")).fontSize('10fp')
            }
            .width('50%')
            .opacity(this.mInfoMsgCtrl.unreadTotalOfInfo == 0 ? 0.4 : 1)
            .onClick(() => {
              this.mInfoMsgCtrl.clickToMarkAllAsReadForInfo()
            })
            //更多
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              MmsMenu({
                menuItems: this.menuItems,
                sizeType: this.gridSizeType,
                menuText: $r("app.string.more")
              })
            }
            .width('50%')
          }
          .width('100%')
          .height('56vp')
          .padding({ left: '86vp', right: '86vp' })
        }
        //设置导航栏显示背景
        //删除弹出对话框
      }
      .width('100%')
      .height('100%')
      .useSizeType({
        xs: { span: 4, offset: 0 }, sm: { span: 4, offset: 0 },
        md: { span: 12, offset: 0 }, lg: { span: 12, offset: 0 }
      })
    }
  }
}