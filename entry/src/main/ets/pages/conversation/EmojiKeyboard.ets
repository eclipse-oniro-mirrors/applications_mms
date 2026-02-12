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
import ConversationController from './conversationController';
import tabTextList from './emoji'
import lazy { Emoji } from './emoji'
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import common from '../../data/commonData';
import { display, LengthMetrics, MeasureText, SubHeader } from '@kit.ArkUI';
import DeviceUtil from '../../utils/DeviceUtil';
import mediaquery from '@ohos.mediaquery';
import CreateNewConversationViewModle from './CreateNewConversationViewModle';
import HiLog from '../../utils/HiLog';
const DEFAULT_EMOJI_SPACE: string = '26vp';
const TAG = 'EmojiKeyboard';

@Component
export default struct SendEmoji {
  // 默认跳到表情页
  @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @State currentIndex: number = 1;
  @Link ctrl: ConversationController;
  @State recentEmoji: number[][] = [];
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @ObjectLink mCreateNewConversationViewModle: CreateNewConversationViewModle;
  //是否是新建信息
  @Prop mIsNew: boolean = false;
  numList: number[] = [1, 2, 3, 4, 5, 6, 7, 8];
  touchResult: number = 0;
  firstTouch: number = 0;
  secondTouch: number = 0;
  @Provide toLeft: boolean = true;
  @Provide isClick: boolean = false;
  private scroller: Scroller = new Scroller
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @Provide emojiLength: number = 0;
  controller: TextAreaController = new TextAreaController();

  aboutToAppear(): void {
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll(this.scroller) {
        Column() {
          recentEmoji({
            ctrl: $ctrl,
            recentEmojiList: this.recentEmoji,
            mIsNew: this.mIsNew,
            mCreateNewConversationViewModle: this.mCreateNewConversationViewModle,
            controller: this.controller,
          }).width('100%')
          EmojiKeyboard({
            ctrl: $ctrl,
            pageNum: 0,
            currentIndex: $currentIndex,
            mIsNew: this.mIsNew,
            mCreateNewConversationViewModle: this.mCreateNewConversationViewModle,
            controller: this.controller,
          }).width('100%')
          Row()
            .height(this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0)
            .width('100%')
            .backgroundColor(Color.Transparent)
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
    .border(DeviceUtil.isPC() ? {
      width: 1,
      color: $r('app.color.light_background_color'),
      radius: 16,
      style: BorderStyle.Solid
    } : {})
    .shadow(DeviceUtil.isPC() ? {
      radius: 16,
      color: '#0C0A59F7',
    } : undefined)
    .zIndex(9999)
  }
}

@Component
struct recentEmoji {
  @StorageLink('curBp') @Watch('setColumnSpace') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('windowWidth') @Watch('setColumnSpace') deviceWidth: number = 0;
  @Link ctrl: ConversationController;
  @ObjectLink mCreateNewConversationViewModle: CreateNewConversationViewModle;
  @Prop recentEmojiList: number[][] = [];
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @State isPad: boolean = false;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  @Consume emojiLength: number;
  @State columnsGap: number = 0;
  @Prop mIsNew: boolean = false;
  private normalPadding: number = 0
  private columnCount = 8
  private listener = mediaquery.matchMediaSync('(orientation: landscape)')
  private portraitFunc: Callback<mediaquery.MediaQueryResult> | undefined
  private iPadScreenPercentage: number = 0.5
  private landscapeRatio: number = 0.6
  private portraitRatio: number = 0.5
  private landscapeEmojiCount = 15
  private portraitEmojiCount = 8
  private errorNumber = 0.1
  controller: TextAreaController = new TextAreaController();

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      if (this.isPad) {
         this.columnCount = this.landscapeEmojiCount
         this.iPadScreenPercentage = this.landscapeRatio
         this.setColumnSpace()
      }
    } else {
      if (this.isPad) {
        this.columnCount = this.portraitEmojiCount
        this.iPadScreenPercentage = this.portraitRatio
        this.setColumnSpace()
      }
    }
  }

  aboutToAppear() {
    this.portraitFunc = this.onPortrait.bind(this);
    this.listener.on(common.notificationLocal.NOTIFICATION_LOCAL_SCREEN_CHANGE,
      this.portraitFunc);
    this.recentEmojiList = this.mConversationCtrl.getRecentEmojiList()
    this.isPad = DeviceUtil.isTablet();
    this.normalPadding = this.isPad ? this.padMargin : 16
    try {
      let orientation = display.getDefaultDisplaySync().orientation
      if (this.isPad && ( orientation === display.Orientation.LANDSCAPE ||
        orientation === display.Orientation.LANDSCAPE_INVERTED)) {
        this.columnCount = this.landscapeEmojiCount
        this.iPadScreenPercentage = this.landscapeRatio
      } else if (this.isPad && ( orientation === display.Orientation.PORTRAIT ||
        orientation === display.Orientation.PORTRAIT_INVERTED)) {
        this.iPadScreenPercentage = this.portraitRatio
      }
    } catch (err) {
      HiLog.e(TAG, `getDefaultDisplaySync error, code: ${err.code}, message: ${err.message},`);
    }
    this.setColumnSpace()
  }

  aboutToDisappear(): void {
    this.listener.off(common.notificationLocal.NOTIFICATION_LOCAL_SCREEN_CHANGE,
      this.portraitFunc);
  }

  private setColumnSpace() {
    if (this.recentEmojiList.length <= 0) {
      return
    }
    let realEmojiDeviceWidth = this.deviceWidth *
      (this.isPad ? this.iPadScreenPercentage :
        this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 1 : this.portraitRatio) -
      this.normalPadding * 2
    let oneEmojiWidthPx = MeasureText.measureText({
      fontSize: DEFAULT_EMOJI_SPACE,
      textContent: String.fromCodePoint(...this.recentEmojiList[0])
    })
    let oneEmojiWidth = px2vp(oneEmojiWidthPx)
    this.columnsGap =
      DeviceUtil.isPC() ? 10 : (realEmojiDeviceWidth - (this.columnCount * oneEmojiWidth)) / (this.columnCount - 1)
  }

  build() {
    if (this.recentEmojiList.length > 0) {
      Column() {
        SubHeader({
          secondaryTitle: $r('app.string.msg_recent_used')
        }).margin({ left: DeviceUtil.isPC() ? -52 : -28, bottom: DeviceUtil.isPC() ? 8 : '' })

        Grid() {
          ForEach(this.recentEmojiList, (item: Array<number>) => {
            this.loadEmojiItem(item)
          })
        }
        .columnsGap(this.columnsGap + common.STR.UNIT_COMMON_VP)
        .rowsGap(10)
        .align(Alignment.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: DeviceUtil.isPC() ? 16 : this.padMargin - this.errorNumber,
        right: DeviceUtil.isPC() ? 16 : this.padMargin - this.errorNumber
      })
    }
  }

  @Builder
  loadEmojiItem(item: number[]) {
    GridItem() {
      Text(String.fromCodePoint(...item))
        .textAlign(TextAlign.Center)
        .fontSize('26vp')
        .fontColor($r('sys.color.ohos_id_color_text_primary'));
    }
    .onClick(() => {
      let splitPoint: number = 0;
      if (this.mIsNew) {
        if (DeviceUtil.isPC()) {
          splitPoint = this.controller.getCaretOffset().index;
        } else {
           splitPoint = this.mCreateNewConversationViewModle.caretPosition + this.emojiLength
        }
        let beforeText: string = this.mCreateNewConversationViewModle.textValue.substring(0, splitPoint);
        let afterText: string = this.mCreateNewConversationViewModle.textValue.substring(splitPoint);
        this.mCreateNewConversationViewModle.textValue = beforeText + String.fromCodePoint(...item) + afterText;
        this.emojiLength += String.fromCodePoint(...item).length
        this.mCreateNewConversationViewModle.newEmojiLength = this.emojiLength;
        if (DeviceUtil.isPC()) {
          this.mCreateNewConversationViewModle.caretPosition = splitPoint + String.fromCodePoint(...item).length;
          this.mCreateNewConversationViewModle.isEmoChange = true;
        }
      } else {
        if (DeviceUtil.isPC()) {
          splitPoint = this.controller.getCaretOffset().index;
        } else {
          splitPoint = this.ctrl.caretPosition + this.emojiLength
        }
        let beforeText: string = this.ctrl.textValue.substring(0, splitPoint);
        let afterText: string = this.ctrl.textValue.substring(splitPoint);
        this.ctrl.textValue = beforeText + String.fromCodePoint(...item) + afterText;
        this.emojiLength += String.fromCodePoint(...item).length
        this.ctrl.newEmojiLength = this.emojiLength;
        if (DeviceUtil.isPC()) {
          this.ctrl.caretPosition = splitPoint + String.fromCodePoint(...item).length;
          this.ctrl.isEmoChange = true;
        }
      }
      let testEmoji = this.mConversationCtrl.recentEmojiList(item);
      SharedPreferencesUtils.saveToPreferences('recentListPreferences', testEmoji);
    })
  }
}

@Component
struct EmojiKeyboard {
  private emojiNum: number = 32;
  @StorageLink('curBp') @Watch('setColumnSpace') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('windowWidth') @Watch('setColumnSpace') deviceWidth: number = 0;
  @Link ctrl: ConversationController;
  @ObjectLink mCreateNewConversationViewModle: CreateNewConversationViewModle;
  pageNum: number = 0;
  @State numArray: number[] = [];
  @State @Watch('handleSwiperNumberChange') num: number = 0;
  @State recentEmojis: object[] = [];
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @State changeIndex: number = 0;
  numArrayLength: number = 0;
  @Consume toLeft: boolean;
  @Link @Watch('currentIndexChange') currentIndex: number;
  @Consume isClick: boolean;
  @State isPad: boolean = false;
  @StorageLink('mmsPadMargin') @Watch('setColumnSpace') padMargin: number = DeviceUtil.padMargin();
  @Consume emojiLength: number;
  @Prop mIsNew: boolean = false;
  @State columnsGap: number = 0
  private normalPadding: number = 0
  private columnCount = 8
  private iPadScreenPercentage = 0.5
  private listener = mediaquery.matchMediaSync('(orientation: landscape)')
  private portraitFunc: Callback<mediaquery.MediaQueryResult> | undefined
  private landscapeRatio: number = 0.6
  private portraitRatio: number = 0.5
  private landscapeEmojiCount = 15
  private portraitEmojiCount = 8
  private errorNumber = 0.1
  controller: TextAreaController = new TextAreaController();

  handleSwiperNumberChange() {
    let numberCeil = Math.ceil(this.num);
    let list: Array<number> = []
    for (let i = 1; i <= numberCeil; i++) {
      list.push(i);
    }
    this.numArray = list
    this.numArrayLength = this.numArray.length
  }

  currentIndexChange() {
    if (this.isClick) {
      this.changeIndex = 0;
    } else {
      if (this.currentIndex == this.pageNum + 1) {
        if (this.toLeft) {
          this.changeIndex = 0;
        } else {
          this.changeIndex = this.numArrayLength - 1;
        }
        this.toLeft = true
      }
    }
  }

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      if (this.isPad) {
        this.columnCount = this.landscapeEmojiCount
        this.iPadScreenPercentage = this.landscapeRatio
        this.setColumnSpace()
      }
    } else {
      if (this.isPad) {
        this.columnCount = this.portraitEmojiCount
        this.iPadScreenPercentage = this.portraitRatio
        this.setColumnSpace()
      }
    }
  }

  aboutToAppear(): void {
    this.portraitFunc = this.onPortrait.bind(this);
    this.listener.on(common.notificationLocal.NOTIFICATION_LOCAL_SCREEN_CHANGE,
      this.portraitFunc);
    if (this.curBp === common.STR.DEVICE_FLAT_PLATE){
      this.emojiNum = 56;
    }
    this.num = tabTextList[this.pageNum].length / this.emojiNum;
    this.isPad = DeviceUtil.isTablet();
    try {
      let orientation = display.getDefaultDisplaySync().orientation
      if (this.isPad && ( orientation === display.Orientation.LANDSCAPE ||
        orientation === display.Orientation.LANDSCAPE_INVERTED)) {
        this.columnCount = this.landscapeEmojiCount
        this.iPadScreenPercentage = this.landscapeRatio
      } else if (this.isPad && ( orientation === display.Orientation.PORTRAIT ||
        orientation === display.Orientation.PORTRAIT_INVERTED)) {
        this.iPadScreenPercentage = this.portraitRatio
      }
    } catch (err) {
      HiLog.e(TAG, `getDefaultDisplaySync error, code: ${err.code}, message: ${err.message},`);
    }
    this.setColumnSpace();
  }

  aboutToDisappear(): void {
    this.listener.off(common.notificationLocal.NOTIFICATION_LOCAL_SCREEN_CHANGE,
      this.portraitFunc);
  }

  private setColumnSpace() {
    if (tabTextList[0].length <= 0 || tabTextList[0][0] === null) {
      return;
    }
    this.normalPadding = this.isPad ? this.padMargin : 16
    let realEmojiDeviceWidth = this.deviceWidth *
      (this.isPad ? this.iPadScreenPercentage : this.curBp ===
      common.STR.DEVICE_MOBILE_PHONE ? 1 : this.portraitRatio) -
      this.normalPadding * 2
    let oneEmojiWidthPx = MeasureText.measureText({
      fontSize: DEFAULT_EMOJI_SPACE,
      textContent: String.fromCodePoint(...tabTextList[0][0].value)
    })
    let oneEmojiWidth = px2vp(oneEmojiWidthPx)
    this.columnsGap =
      DeviceUtil.isPC() ? 10 : (realEmojiDeviceWidth - (this.columnCount * oneEmojiWidth)) / (this.columnCount - 1)
  }

  build() {
    Column() {
      SubHeader({
        secondaryTitle: $r('app.string.msg_all_emoji')
      }).margin({
          start: DeviceUtil.isPC() ? LengthMetrics.vp(-52) : LengthMetrics.vp(-28),
          bottom: DeviceUtil.isPC() ? 8 : ''
        })

      Grid() {
        ForEach(tabTextList[0], (item: Emoji) => {
          this.loadEmojiItem(item)
        })
      }
      .columnsGap(this.columnsGap + common.STR.UNIT_COMMON_VP)
      .rowsGap(10)
      .align(Alignment.Start)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: DeviceUtil.isPC() ? 16 : this.padMargin - this.errorNumber,
      right: DeviceUtil.isPC() ? 16 : this.padMargin - this.errorNumber
    })
    .margin({top: '-2vp'})
  }

  @Builder
  loadEmojiItem(item: Emoji) {
    GridItem() {
      Text(String.fromCodePoint(...item.value))
        .textAlign(TextAlign.Center)
        .fontSize('26vp')
        .fontColor($r('sys.color.ohos_id_color_text_primary'));
    }
    .onClick(() => {
      let splitPoint: number = 0;
      if (this.mIsNew) {
        if (DeviceUtil.isPC()) {
          splitPoint = this.controller.getCaretOffset().index;
        } else {
           splitPoint = this.mCreateNewConversationViewModle.caretPosition + this.emojiLength
        }
        let beforeText: string = this.mCreateNewConversationViewModle.textValue.substring(0, splitPoint);
        let afterText: string = this.mCreateNewConversationViewModle.textValue.substring(splitPoint);
        this.mCreateNewConversationViewModle.textValue = beforeText + String.fromCodePoint(...item.value) + afterText;
        this.emojiLength += String.fromCodePoint(...item.value).length
        this.mCreateNewConversationViewModle.newEmojiLength = this.emojiLength;
        if (DeviceUtil.isPC()) {
          this.mCreateNewConversationViewModle.caretPosition = splitPoint + String.fromCodePoint(...item.value).length;
          this.mCreateNewConversationViewModle.isEmoChange = true;
        }
      } else {
        if (DeviceUtil.isPC()) {
          splitPoint = this.controller.getCaretOffset().index;
        } else {
          splitPoint = this.ctrl.caretPosition + this.emojiLength
        }
        let beforeText: string = this.ctrl.textValue.substring(0, splitPoint);
        let afterText: string = this.ctrl.textValue.substring(splitPoint);
        this.ctrl.textValue = beforeText + String.fromCodePoint(...item.value) + afterText;
        this.emojiLength += String.fromCodePoint(...item.value).length
        this.ctrl.newEmojiLength = this.emojiLength;
        if (DeviceUtil.isPC()) {
          this.ctrl.caretPosition = splitPoint + String.fromCodePoint(...item.value).length;
          this.ctrl.isEmoChange = true;
        }
      }
      let testEmoji = this.mConversationCtrl.recentEmojiList(item.value);
      SharedPreferencesUtils.saveToPreferences('recentListPreferences', testEmoji);
    })
  }
}