/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import lazy UDC from '@ohos.data.unifiedDataChannel';
import { HashMap } from '@kit.ArkTS';
import { MeasureText, promptAction } from '@kit.ArkUI';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import MMPictureController from '../../views/AttachmentArea/MMPictureController';
import ConversationController, { mmsListType } from './conversationController';
import common from '../../data/commonData';
import { Highlight, HighlightsOptions, HighlightType } from '../../utils/Highlight';
import HiLog from '../../utils/HiLog';
import dotCommon, { dotNoNeedParmas, seleteParam } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import LocationUtil from '../../utils/LocationUtil';
import LooseObject from '../../data/LooseObject';
import { AgreeNetworkDialog } from '../../views/dialogs/AgreeNetworkDialog';
import { AddressInfo, Mms } from '../../utils/TypesUtils';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import { DetectResult } from './ConversationData';
import { VibrationUtils } from '../../utils/VibrationUtils';
import MmsUtil from '../../utils/MmsUtil';
import commonData from '../../data/commonData';
import { commonPasteboard } from '../../data/Pasteboard';
import i18n from '@ohos.i18n';
import myCommon from '@ohos.app.ability.common';
import lazy { SplitScreenManager } from '../../utils/SplitScreenManager'
import Configuration from '@system.configuration';
import { SystemMode } from '../../utils/SystemMode';
import DeviceUtil from '../../utils/DeviceUtil';
import DistributedUtil from '../../utils/DistributedUtil';
import ConversationDataSource from '../../model/ConversationDataSource'
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import { TextAccessibilityModifier } from '../../utils/AccessibilityModifier';

// instrument ignore file
const TAG = 'BubbleText';
const NANOSECONDS_PER_SECOND: number = 1000 * 1000;
const DEFAULT_SELECT: number = -1;
const EMPTY_TEXT: string = '';

// Custom Chat Bubble
@Component
export default struct BubbleText {
  // 文本是否被选中
  @State isTextSelected: boolean = false;
  // 是否鼠标左键触发
  @State isMouseLeft: boolean = false;
  // 被选中的文本起始坐标，用于复制、拖拽时获取选中的文本
  @State textStart: number = -1;
  @State textEnd: number = -1;
  // 设置文本选中状态
  @State selectionStart: number = -1;
  @State selectionEnd: number = -1;
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  private listScroller: Scroller = this.mConversationCtrl.scroller;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @State mAttachAreaCtrl: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  @State mPictureCtrl: MMPictureController = MMPictureController.getInstance();
  @Link conversationCtrl: ConversationController;
  @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  private delConversionController?: CustomDialogController;
  private bubbleTextBorderRadius: Array<number | Resource> = []; // Fillet size, two parameters in total
  private bubbleTextDirection: string = ''; // left: upper left corner right: upper right corner
  private content: string = ''; // Bubble Display Content
  public smsType: number = 0;
  private detectResContent: string = '';
  private isRcs: number = 0;
  private context = getContext(this) as myCommon.UIAbilityContext;
  private bubbleTextBackgroundColor?: Resource | string; // Bubble background color
  @Prop itemIndex: number = 0;
  @State showMenu: boolean = false;
  @State pressed: boolean = false;
  private highlights: Array<HighlightsOptions> = [];
  @Link showMMContentPicker: boolean;
  @ObjectLink mmsItem: mmsListType;
  private isReceive: boolean = false;
  private isAdvancedSecurity: boolean = false;
  @Consume storagePixelMap: HashMap<string, PixelMap>;
  // Default
  private defaultEmojiSize: number = 16;
  private defaultTextHeight: number = 19;
  // Mark whether bubbles need to be displayed
  private shouldShowBubble: boolean = true;
  // Defined on the UI: emojiSize
  private withoutBubbleEmojiSize: number = 24;
  // Defined on the UI: emojiSize + padding * 2 = 28 + 4 * 2 = 36
  private withoutBubbleTextHeight: number = 36;
  private currentScreenWidth: string = '';
  private isMsm: boolean = false;
  private controller: TextAreaController = new TextAreaController();
  // Indicates whether the permission has been denied.
  @Link isPermissionDenied: boolean;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @StorageLink('windowWidth') deviceWidth: number = 0;
  // 高度更新的话, 进行回传
  @BuilderParam updateHeight: (height: number) => void;
  @State copyButtonWidth: Length = '95.1%';
  private isReport: number = 0;
  // 长按下拉菜单是否显示举报
  @State isShowReport: boolean = false;
  @Prop isScrolling: boolean;
  @State textVisibleFlag: boolean = true;
  @Prop isTouch?: boolean = false;
  @State isHidden: boolean = false; //长按弹框弹起的时候隐藏底层视图
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  @StorageLink('mmsScreenPercentage') mmsScreenPercentage: string = '50%';
  @StorageLink('mmsNavMode') curNavMode: number = 0;
  private changeConversationSelectedNumberAndCheckAllBool: () => void = () => {};
  private changeFocusAble: () => void = () => {};
  @Prop isLastItem?: boolean = false;
  @Prop isGeometryAnimate?: boolean = false;
  /* 是否启用NLU能力 */
  private isEnableNlu: boolean = SystemMode.getInstance().isEnableNlu;
  @State isDragging: boolean = false;
  @State isPC: boolean = DeviceUtil.isPC();
  /* 仅用于PC分布式短信场景，用于获取用户管控权限 */
  public isOsAccountConstraintEnabled: boolean = false;
  /**
   * 点击气泡时间戳，缓存用户手指按下时间点
   */
  private touchTime: number = 0;
  /**
   * 设置的剪贴板复制范围选项 CopyOptions.None:不可复制；CopyOptions.InApp 应用内复制；CopyOptions.LocalDevice 设备中复制
   * 剪贴功能和应用拖拽功能冲突，当CopyOptions.None时禁用剪贴功能，可以拖拽，否则不能直接拖拽
   */
  @State copyOption: CopyOptions = CopyOptions.None;
  @State accessibilityStr: string = '';
  @StorageLink('isScreenReaderOpen') @Watch('accessibilityStatusChange') isReaderOpen: boolean = false;

  aboutToAppear() {
    this.msgTitleContent()
    if (!this.context) {
      HiLog.w(TAG, 'Initialize getcontext is null!')
      this.context = getContext(this) as myCommon.UIAbilityContext;
      if (!this.context) {
        HiLog.e(TAG, 'retry getcontext failed,context is null!')
      }
    }
    if (this.conversationCtrl.searchContent !== '') {
      this.highlights = Highlight.getInstance().getHighlightTexts(this.content, this.conversationCtrl.searchContent);
    }
    this.shouldShowBubble = this.conversationCtrl.showBubbleOrEmoji(this.content, 3);
    this.isShowReport = !this.isMsm && this.isReceive && this.isReport == 0;
    this.getPermissionControl();
    this.updateAccessibilityString();
  }

  private accessibilityStatusChange() {
    this.updateAccessibilityString();
  }

  private updateAccessibilityString() {
    if (this.isReaderOpen) {
      this.accessibilityStr = AccessibilityUtil.getBubbleTextAccessibilityStrBy(this.detectResContent, this.context);
    } else {
      this.accessibilityStr = '';
    }
  }

  private async getPermissionControl() {
    this.isOsAccountConstraintEnabled = await DistributedUtil.isOsAccountConstraintEnabled();
  }

  private msgTitleContent() {
    if (!this.mmsItem.msgTitle || !this.mmsItem.ct) {
      return
    }
    let msgTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.subject').id,
      this.mmsItem.msgTitle)
    this.content = this.content ? msgTitle + '\n' + this.content : msgTitle
  }

  private calCurPageRatio(): number {
    if (this.curNavMode === common.int.NAVIGATION_MODE_STACK) {
      return 1;
    }
    try {
      return 1 - Number(this.mmsScreenPercentage.replace("%", "")) / 100;
    } catch {
      HiLog.e(TAG, 'Failed to convert the string percentage to a number.');
    }
    return 0.5;
  }

  private messageBubbleWidthChange(content: string): string {
    HiLog.i(TAG, 'messageBubbleWidthChange by content');
    if (this.curBp === common.STR.DEVICE_MOBILE_PHONE) {
      return this.setWidth(1, content);
    } else if (this.curBp === common.STR.DEVICE_Folding_SCREEN) {
      return this.setWidth(this.calCurPageRatio(), content);
    } else {
      if (this.padMargin === DeviceUtil.padPortraitMargin) {
        return this.setWidth(0.5, content);
      }
      return this.setWidth(0.6, content);
    }
  }

  private setWidth(screenPercent: number, content: string): string {
    let currentScreenWidthForNumber = 0
    if (this.conversationCtrl.isSelectStatus && this.conversationCtrl.contactsNum > 1) {
      currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 24 - 8 - 32 - 8;
    } else if (this.conversationCtrl.isSelectStatus && this.conversationCtrl.contactsNum <= 1) {
      currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 24 - 8;
    } else {
      if (this.conversationCtrl.contactsNum > 1) {
        currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 32 - 8;
      } else {
        currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8;
      }
    }
    if (!this.conversationCtrl.isSelectStatus && this.isCodeMessageType()) {
      return currentScreenWidthForNumber + common.STR.UNIT_COMMON_VP;
    }
    const fullTextWidthPx: number = MeasureText.measureText({
      textContent: content,
    });
    const fullTextWidthVp: number = px2vp(fullTextWidthPx);
    if (fullTextWidthVp <= currentScreenWidthForNumber - 24) {
      return 'auto'
    } else {
      return currentScreenWidthForNumber + 'vp'
    }
  }

  private isCodeMessageType(): boolean {
    let isReceive: boolean = false;
    if (this.bubbleTextDirection == common.STR.BUBBLE_TEXT_DIRECTION &&
      (this.smsType == common.sms_type.NOTICE)) {
      isReceive = true;
    }
    let isCustomButton: boolean = false;
    if (this.mmsItem.msgCodeStr.length > 0) {
      isCustomButton = true;
    }
    if (isReceive && isCustomButton) {
      return true;
    }
    return false;
  }

  @Builder
  // instrument ignore next
  MenuBuilder() {
    Flex({
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center
    }) {
      this.copyButton();
      this.forwardButton()
      this.deleteButton();
      this.chooseTextButton()
      MenuItem({ content: $r('app.string.more') })
        .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
        .contentFontColor($r('sys.color.font_primary'))
        .onClick(() => {
          this.conversationCtrl.longPressSelected(this.context, 4)
          this.showMenu = false;
          this.showMMContentPicker = false;
          // 长按功能弹窗打点
          seleteParam.SELECT_STATE = 5;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
        })
    }
    .width(this.curBp === common.STR.DEVICE_MOBILE_PHONE ? '85%' : '45%')
    .height(40)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
  }

  @Builder
  // instrument ignore next
  chooseTextButton() {
    MenuItem({ content: $r('app.string.msg_select_text') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.controller.stopEditing();
        this.conversationCtrl.longPressSelected(this.context, 3);
        this.showMenu = false;
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 4;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
  }

  @Builder
  // instrument ignore next
  forwardButton() {
    MenuItem({ content: $r('app.string.msg_transmit') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.conversationCtrl.longPressSelected(this.context, 1);
        this.showMenu = false
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 2;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
  }

  @Builder
  // instrument ignore next
  copyButton() {
    MenuItem({ content: $r('app.string.msg_copy') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.conversationCtrl.longPressSelected(this.context, 0);
        this.showMenu = false;
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 1;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
  }

  @Builder
  // instrument ignore next
  deleteButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.conversationCtrl.longPressSelected(this.context, 2);
        this.showMenu = false
        this.delConversionController?.open();
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 3;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
  }

  @Styles
  normalStyles(){
    .backgroundColor(!this.shouldShowBubble ?
    Color.Transparent : this.bubbleTextBackgroundColor)
  }

  @Styles
  pressedStyles(){
    .backgroundColor(!this.shouldShowBubble ?
    Color.Transparent : this.bubbleTextBackgroundColor)
  }

  @Builder
  agreeNetworkDialogControllerBuildContent(): void {
    AgreeNetworkDialog({
      msg: $r('app.string.mms_need_network'),
      msgDescription: $r('app.string.mms_need_network_description')
    })
  }

  private jumpMap(locations: string[]) {
    LocationUtil.searchName((res: LooseObject) => {
      if (res != null) {
        LocationUtil.queryLocation(new AddressInfo(Number(locations[1]), Number(locations[0]),
          res.name, res.formatAddress));
      } else {
        LocationUtil.queryLocation(new AddressInfo(Number(locations[1]), Number(locations[0]),
          ' ', ' '));
      }
    }, Number(locations[0]), Number(locations[1]));
  }

  private async tryOpenMap() {
    HiLog.i(TAG, 'try open mapkit.')
    let locations: string[] = this.mmsItem.latitudeAndLongitude.split(',');
    this.jumpMap(locations);
    DotUtil.getInstance().reportEvent(dotNoNeedParmas,
      dotCommon.eventName.SATELLITE_MMS_JUMP_MAP);
  }

  // 文本选中发生变化时设置选中状态和选中坐标
  private selectionChange(start: number, end: number): void {
    if (this.isMouseLeft) {
      this.textStart = start;
      this.textEnd = end;
    }
    if (start === DEFAULT_SELECT && end === DEFAULT_SELECT) {
      HiLog.w(TAG, `selectionChange default111 start:${start}.end:${end}.`);
      this.TextDefaultSelect();
      this.isMouseLeft = false;
    } else {
      HiLog.w(TAG, `selectionChange default start:${start}.end:${end}.`);
      this.isTextSelected = true;
    }
  }

  private closeMenuSelections() {
    this.showMenu = false;
    this.isTextSelected = false;
    this.TextDefaultSelect();
    this.isMouseLeft = false;
  }

  // 设置文本为初始不选中状态
  private TextDefaultSelect(): void {
    // isTextSelected，不能取消选中效果
    if (!this.isTextSelected) {
      this.selectionStart = DEFAULT_SELECT;
      this.selectionEnd = DEFAULT_SELECT;
      this.textStart = DEFAULT_SELECT;
      this.textEnd = DEFAULT_SELECT;
    }
  }

  /**
   * 获取选择文本对应的原始文字
   *
   * @param source 全部文字
   * @param selectionStart 选择起始点
   * @param selectionEnd 选择终点
   * @returns 选择文字
   */
  private getSelectTextAndEmoji(source: string, selectionStart: number,
    selectionEnd: number): string {
    if (!source || selectionStart > selectionEnd) {
      HiLog.e(TAG, `[getSelectTextAndEmoji] The input params is invalid.`);
      return EMPTY_TEXT;
    }

    if (source.length === 0 || selectionStart === selectionEnd) {
      HiLog.w(TAG, `The text source or select source is empty.`);
      return EMPTY_TEXT;
    }

    let selectText = source.substring(selectionStart, selectionEnd);
    HiLog.w(TAG, `[getSelectTextAndEmoji] The selectText length is ${selectText.length}`);
    return selectText;
  }

  // instrument ignore next
  build() {
    if (!this.isPC){
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.SpaceBetween, alignItems: this.shouldShowBubble ? ItemAlign.Start : ItemAlign.End
      }) {
        Column() {
          Text(this.detectResContent == '' ? this.content :
            (this.isAdvancedSecurity ? this.content : this.detectResContent)) {
            Span(this.content)
          }
          .key('msg_content_text')
          .clip(true)
          .attributeModifier(new TextAccessibilityModifier(this.accessibilityStr))
          .fontSize(this.shouldShowBubble ? this.defaultEmojiSize : this.withoutBubbleEmojiSize)
          .lineHeight(this.shouldShowBubble ? this.defaultTextHeight : this.withoutBubbleTextHeight)
          .maxFontScale(this.shouldShowBubble ? 5 : 2)
          .wordBreak(WordBreak.BREAK_ALL)
          .renderFit(RenderFit.RESIZE_CONTAIN) //动效属性，动效过程中文字不超过动效时候的范围
          .fontColor(this.bubbleTextDirection == 'right'
            ? $r('sys.color.font_on_primary') : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .onVisibleAreaChange([0.2], (isVisible: boolean, currentRatio: number) => {
            if (currentRatio <= 0.2) {
              // text completely invisible
              this.textVisibleFlag = this.detectResContent == '' ? false : true;
            } else {
              // text fully visible
              this.textVisibleFlag = true;
            }
          })
          .enableDataDetector(this.getDataDetectorFlag())
          .copyOption(this.copyOption)
          .onCopy(() => {
            this.copyOption = CopyOptions.None; //使用剪贴复制功能后的回调重新初始化值禁用剪贴功能
          })
          .onTouchIntercept((event: TouchEvent) => {
            if (this.conversationCtrl.isSelectStatus) {
              return HitTestMode.None
            } else {
              return HitTestMode.Default
            }
          })
          .draggable(false)
          .fontFeature('\"ss08\" 1')
          .dataDetectorConfig({
            types: [],
            color: this.bubbleTextDirection == 'right' ? $r('sys.color.font_on_primary') : '',
            onDetectResultUpdate: (detectResultStr: string) => {
              HiLog.w(TAG, 'message content detected');
              let detectResJson: DetectResult = undefined;
              try {
                detectResJson = JSON.parse(detectResultStr);
              } catch {
                HiLog.e(TAG, 'parse json returned by ai detect error, highlight is abnormal');
                detectResJson = undefined;
              }
              if (detectResJson?.entity == '') {
                HiLog.w(TAG, 'there is no detected entity');
              }
              if (detectResJson?.code == 0 && this.detectResContent == '') {
                detectResJson.content = this.content;
                detectResJson.bundleName = 'com.ohos.mms';
                this.detectResContent = JSON.stringify(detectResJson);
                if (this.mmsItem.isRcs == 0 && !Number.isNaN(this.mmsItem.id)) {
                  //普通短彩信
                  //将解析json保存到数据库
                  this.conversationCtrl.saveMmsDetect(this.context, this.mmsItem.id as number,
                    this.detectResContent, this.mmsItem.isRcs);
                  //保存当前短信的文本识别信息到内存中
                  this.mmsItem.detectResContent = this.detectResContent;
                } else if (this.mmsItem.isRcs == 1 && !Number.isNaN(this.mmsItem.rcsId)) {
                  //rcs信息
                  this.conversationCtrl.saveMmsDetect(this.context, this.mmsItem.rcsId,
                    this.detectResContent, this.mmsItem.isRcs);
                  this.mmsItem.detectResContent = this.detectResContent;
                } else {
                  HiLog.e(TAG, 'id is NaN, msgId: ' + this.mmsItem.id +
                    ', rcsId: ' + this.mmsItem.rcsId +
                    ', isRcs: ' + this.isRcs);
                }
              }
            }
          })
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.copyButtonWidth = newValue.width;
          })
          .visibility(Visibility.Visible)

          if (this.mmsItem.msgCodeStr.length > 0) {
            this.customVerCodeText()
          }
        }
        .alignItems(HorizontalAlign.Start)
        if (this.bubbleTextDirection == 'right' && this.mmsItem.position != undefined &&
          this.mmsItem.position != '') {
          Text(this.mmsItem.position)
            .clip(true)
            .fontSize(10)
            .lineHeight(13)
            .fontColor($r('sys.color.ohos_id_color_text_primary_dark'))
            .fontWeight(FontWeight.Normal)
            .fontFamily('HarmonyHeiTi')
            .fontFeature('\"ss08\" 1')
            .margin({ top: 8 })
            .border({
              width: {
                bottom: $r('app.float.settings_divider_strokeWidth')
              },
              color: { bottom: $r('sys.color.ohos_id_color_text_primary_dark') }
            })
            .gesture(
              GestureGroup(GestureMode.Exclusive,
                LongPressGesture()
                  .onAction(() => {
                    HiLog.i(TAG, 'this.mmsItem.position LongPressGesture')
                  }),
                TapGesture({ count: 1 }).onAction((event?: GestureEvent) => {
                  HiLog.i(TAG, 'this.mmsItem.position onClick')
                  this.tryOpenMap()
                })
              )
            )
        }
      }
      .accessibilityGroup(false)
      .padding(this.getCardPadding())
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
      .width(this.messageBubbleWidthChange(this.content))
      .margin({
        top: this.isMsm ? 8 : 0
      })
      .borderRadius(this.getBorderRadius())
      .flexBasis('auto')
      .geometryTransition(this.isGeometryAnimate && this.isLastItem ? `geometry_transition_id` : '', { follow: false })
      .transition(this.isDragging ? TransitionEffect.IDENTITY : TransitionEffect.OPACITY)
      .onPreDrag((preDragStatus: PreDragStatus) => {
        if (preDragStatus === 1) {
          this.isDragging = true
        }
      })
      .parallelGesture(
        GestureGroup(GestureMode.Parallel,
          LongPressGesture({ repeat: false, duration: 800 })//Touch and hold the action will be triggered continuously.
            .tag('bubbleTextLongPress')
            .onAction(() => {
              if (!this.conversationCtrl.isSelectStatus) {
                this.isHidden = true
                this.conversationCtrl.mmsListLongPress(this.itemIndex)
                this.showMenu = true
                VibrationUtils.onceVibration(common.VIBRATIONEFFECT.LONG_PRESS_LIGHT)
              }
            }),
          TapGesture({count: 1})
            .onAction(() => {
              if (this.mConversationCtrl.isSelectStatus &&
              ConversationDataSource.getInstance().mmsList[this.itemIndex]) {
                this.mConversationCtrl.multiSelectMmsMsg(this.itemIndex);
                this.mConversationCtrl.listCheckBoxChange(this.itemIndex,
                  !ConversationDataSource.getInstance().mmsList[this.itemIndex].isCbChecked);
                this.changeConversationSelectedNumberAndCheckAllBool();
              }
            }),
          TapGesture({ count: 2 })
            .onAction(() => {
              if (this.conversationCtrl.isSelectStatus) {
                return;
              }
              //Double-click to enter the text selection page. Touch and hold the session content to collapse the menu bar
              if (this.showMenu) {
                HiLog.i(TAG, 'Double-click to select text close Popup')
                this.showMenu = false;
              }
              HiLog.i(TAG, `TapGesture:itemIndex ${this.itemIndex},mmsItemId:${this.itemIndex}`);
              AppStorage.setOrCreate('isFromMenu', true);
              this.conversationCtrl.pushToCopyController(this.itemIndex, this.mmsItem);
            })
        )
      )
      .gesture(
        SwipeGesture({
          direction: SwipeDirection.All,
          speed: 1
        })
          .onAction((event: GestureEvent) => {
            this.controller.stopEditing();
            this.showMMContentPicker = false;
          })
      )
      .bindContextMenu(this.showMenu, this.longPressMenuBuild(), {
        preview: MenuPreviewMode.IMAGE,
        previewAnimationOptions: {
          scale: [0.95, 1.1]
        },
        placement: this.bubbleTextDirection == 'right' ? Placement.BottomRight : Placement.BottomLeft,
        onAppear: (() => {
          HiLog.w(TAG, `select msg id is: ${this.mmsItem.id}`)
          if (!this.conversationCtrl.isSelectStatus) {
            this.conversationCtrl.mmsListLongPress(this.itemIndex, this.mmsItem)
          }
          //长按内容打点
          DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CONTENT_LONGPRESS);
        }),
        aboutToDisappear: (() => {
          if (this.itemIndex === this.scrollStartIndex) {
            this.listScroller.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
          } else if (this.itemIndex === this.scrollEndIndex) {
            this.listScroller.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
          }
          setTimeout(() => {
            this.showMenu = false
            this.isHidden = false;
          }, 850);
        })
      })
      .draggable(true)
      .visibility(this.isHidden ? Visibility.Hidden : Visibility.Visible)
      .onDragStart((event) => {
        HiLog.i(TAG, 'bubbleText onDragStart start.');
        this.isDragging = true
        let data: UDC.PlainText = new UDC.PlainText();
        data.abstract = this.content;
        data.textContent = this.content;
        (event as DragEvent).setData(new UDC.UnifiedData(data));
        this.showMenu = false;
        VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.DRAG)
      })
      .onDragEnd((event?: DragEvent, extraParams?: string) => {
        HiLog.i(TAG, 'bubbleText onDragEnd End.');
        this.isDragging = false;
      })
      .onTouch((event?: TouchEvent) => {
        if(this.conversationCtrl.isSelectStatus) { //多选界面不做修改保持原规格
          return;
        }
        if (event && event.type === TouchType.Down) {
          this.copyOption = CopyOptions.LocalDevice; //用户手指按下时触发该事件响应，此时Text组件支持剪切功能
          this.touchTime = event.timestamp;
        }
        if (event && event.type === TouchType.Move && //用户手指按下时触发该事件响应
          ((event.timestamp - this.touchTime) / NANOSECONDS_PER_SECOND) >= 500) {
          this.copyOption = CopyOptions.None; //用户手指长时间不离开屏幕，大于 500ms 表示长按手势此时禁用剪贴板功能，可以进行拖拽操作。
        }
      })
    } else {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.SpaceBetween, alignItems: this.shouldShowBubble ? ItemAlign.Start : ItemAlign.End
      }) {
        Column() {
          Text(this.detectResContent == '' ? this.content :
            (this.isAdvancedSecurity ? this.content : this.detectResContent)) {
            Span(this.content)
          }
          .clip(true)
          .fontSize(this.shouldShowBubble ? this.defaultEmojiSize : this.withoutBubbleEmojiSize)
          .lineHeight(this.shouldShowBubble ? this.defaultTextHeight : this.withoutBubbleTextHeight)
          .maxFontScale(this.shouldShowBubble ? 5 : 2)
          .renderFit(RenderFit.RESIZE_CONTAIN) //动效属性，动效过程中文字不超过动效时候的范围
          .fontColor(this.bubbleTextDirection == 'right'
            ? $r('sys.color.font_on_primary') : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .onVisibleAreaChange([0.2], (isVisible: boolean, currentRatio: number) => {
            if (currentRatio <= 0.2) {
              // text completely invisible
              this.textVisibleFlag = this.detectResContent == '' ? false : true;
            } else {
              // text fully visible
              this.textVisibleFlag = true;
            }
          })
          .enableDataDetector(this.getEnableDataDetectorFlag())
          .copyOption(this.conversationCtrl.isSelectStatus || this.showMenu
            ? CopyOptions.None : CopyOptions.LocalDevice)
          .onTouchIntercept((event: TouchEvent) => {
            if (this.conversationCtrl.isSelectStatus) {
              return HitTestMode.None
            } else {
              return HitTestMode.Default
            }
          })
          .draggable(false)
          .fontFeature('\"ss08\" 1')
          .onTextSelectionChange((start: number, end: number) => {
            this.selectionChange(start, end);
          })
          .selection(this.textStart, this.textEnd)
          .onMouse((event?: MouseEvent): void => {
            if (event && event.action === MouseAction.Press) {
              switch (event.button) {
                case MouseButton.Left:
                  this.isMouseLeft = true;
                  break;
                default:
                  break;
              }
            }
          })
          .dataDetectorConfig({
            types: [],
            color: this.bubbleTextDirection == 'right' ? $r('sys.color.font_on_primary') : '',
            onDetectResultUpdate: (detectResultStr: string) => {
              HiLog.i(TAG, 'message content detected');
              let detectResJson: DetectResult = undefined;
              try {
                detectResJson = JSON.parse(detectResultStr);
              } catch {
                HiLog.e(TAG, 'parse json returned by ai detect error, highlight is abnormal');
                detectResJson = undefined;
              }
              if (detectResJson?.entity == '') {
                HiLog.i(TAG, 'there is no detected entity');
              }
              if (detectResJson?.code == 0 && this.detectResContent == '') {
                detectResJson.content = this.content;
                detectResJson.bundleName = 'com.ohos.mms';
                this.detectResContent = JSON.stringify(detectResJson);
                if (this.mmsItem.isRcs == 0 && !Number.isNaN(this.mmsItem.id)) {
                  //普通短彩信
                  //将解析json保存到数据库
                  this.conversationCtrl.saveMmsDetect(this.context, this.mmsItem.id as number,
                    this.detectResContent, this.mmsItem.isRcs);
                  //保存当前短信的文本识别信息到内存中
                  this.mmsItem.detectResContent = this.detectResContent;
                } else if (this.mmsItem.isRcs == 1 && !Number.isNaN(this.mmsItem.rcsId)) {
                  //rcs信息
                  this.conversationCtrl.saveMmsDetect(this.context, this.mmsItem.rcsId,
                    this.detectResContent, this.mmsItem.isRcs);
                  this.mmsItem.detectResContent = this.detectResContent;
                } else {
                  HiLog.e(TAG, 'id is NaN, msgId: ' + this.mmsItem.id +
                    ', rcsId: ' + this.mmsItem.rcsId +
                    ', isRcs: ' + this.isRcs);
                }
              }
            }
          })
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.copyButtonWidth = newValue.width;
          })
          .visibility(Visibility.Visible)

          if (this.mmsItem.msgCodeStr.length > 0) {
            this.customVerCodeText()
          }
        }
        .alignItems(HorizontalAlign.Start)
        if (this.bubbleTextDirection == 'right' && this.mmsItem.position != undefined &&
          this.mmsItem.position != '') {
          Text(this.mmsItem.position)
            .clip(true)
            .fontSize(10)
            .lineHeight(13)
            .fontColor($r('sys.color.ohos_id_color_text_primary_dark'))
            .fontWeight(FontWeight.Normal)
            .fontFamily('HarmonyHeiTi')
            .fontFeature('\"ss08\" 1')
            .margin({ top: 8 })
            .border({
              width: {
                bottom: $r('app.float.settings_divider_strokeWidth')
              },
              color: { bottom: $r('sys.color.ohos_id_color_text_primary_dark') }
            })
            .gesture(
              GestureGroup(GestureMode.Exclusive,
                LongPressGesture()
                  .onAction(() => {
                    HiLog.i(TAG, 'this.mmsItem.position LongPressGesture')
                  }),
                TapGesture({ count: 1 }).onAction((event?: GestureEvent) => {
                  HiLog.i(TAG, 'this.mmsItem.position onClick')
                  this.tryOpenMap()
                })
              )
            )
        }
      }
      .accessibilityLevel('yes')
      .accessibilityGroup(false)
      .padding(this.getCardPadding())
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
      .width(this.messageBubbleWidthChange(this.content))
      .margin({
        top: this.isMsm ? 8 : 0
      })
      .borderRadius(this.getBorderRadius())
      .flexBasis('auto')
      .geometryTransition(this.isGeometryAnimate && this.isLastItem ? `geometry_transition_id` : '', { follow: false })
      .transition(this.isDragging ? TransitionEffect.IDENTITY : TransitionEffect.OPACITY)
      .onPreDrag((preDragStatus: PreDragStatus) => {
        if (preDragStatus === 1) {
          this.isDragging = true
        }
      })
      .parallelGesture(
        GestureGroup(GestureMode.Exclusive,
          LongPressGesture({ repeat: false, duration: 500 })//Touch and hold the action will be triggered continuously.
            .tag('bubbleTextLongPress')
            .onAction(() => {
              if (SplitScreenManager.getInstance().infoModel.isNoLongPress) {
                HiLog.i(TAG, 'This is split screen on PC is no long press');
                return;
              }
              if (!this.conversationCtrl.isSelectStatus) {
                this.isHidden = true
                this.conversationCtrl.mmsListLongPress(this.itemIndex)
                this.showMenu = true
                VibrationUtils.onceVibration(common.VIBRATIONEFFECT.LONG_PRESS_LIGHT)
              }
            }),
          TapGesture({ count: 2 })
            .onAction(() => {
              //Double-click to enter the text selection page. Touch and hold the session content to collapse the menu bar
              if (this.showMenu) {
                HiLog.i(TAG, 'Double-click to select text close Popup')
                this.showMenu = false;
              }
              HiLog.i(TAG, `TapGesture:itemIndex ${this.itemIndex},mmsItemId:${this.itemIndex}`);
              AppStorage.setOrCreate('isFromMenu', true);
              this.conversationCtrl.pushToCopyController(this.itemIndex, this.mmsItem);
            })
        )
      )
      .gesture(
        SwipeGesture({
          direction: SwipeDirection.All,
          speed: 1
        })
          .onAction((event: GestureEvent) => {
            this.controller.stopEditing();
            this.showMMContentPicker = false;
          })
      )
      .bindContextMenu(this.longPressMenuBuild(), ResponseType.RightClick, {
        onAppear: (() => {
          HiLog.w(TAG, `select msg id is: ${this.mmsItem.id}`)
          if (!this.conversationCtrl.isSelectStatus) {
            this.conversationCtrl.mmsListLongPress(this.itemIndex, this.mmsItem)
          }
          //长按内容打点
          DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CONTENT_LONGPRESS);
        }),
        aboutToDisappear: (() => {
          this.showMenu = false
          this.isHidden = false;
        })
      })
      .bindContextMenu(this.longPressMenuBuild(), ResponseType.LongPress, {
        onAppear: (() => {
          HiLog.w(TAG, `select msg id is: ${this.mmsItem.id}`)
          if (!this.conversationCtrl.isSelectStatus) {
            this.conversationCtrl.mmsListLongPress(this.itemIndex, this.mmsItem)
          }
          //长按内容打点
          DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CONTENT_LONGPRESS);
        }),
        aboutToDisappear: (() => {
          this.showMenu = false
          this.isHidden = false;
        })
      })
      .draggable(DeviceUtil.isPC() ? false : true)
      .visibility(this.isHidden && !DeviceUtil.isPC() ? Visibility.Hidden : Visibility.Visible)
      .onDragStart((event) => {
        HiLog.i(TAG, 'bubbleText onDragStart start.');
        this.isDragging = true
        let data: UDC.PlainText = new UDC.PlainText();
        data.abstract = this.content;
        data.textContent = this.content;
        (event as DragEvent).setData(new UDC.UnifiedData(data));
        this.showMenu = false;
        VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.DRAG)
      })
      .onDragEnd((event?: DragEvent, extraParams?: string) => {
        HiLog.i(TAG, 'bubbleText onDragEnd End.');
        this.isDragging = false;
      })
    }
  }

  @Builder
  // instrument ignore next
  longPressMenuBuild() {
    Menu() {
      if (!DeviceUtil.isPC()) {
        // 多选
        this.multSelectMenuButton()
        this.multDivider()
        // 非ip消息或者简单的ip消息才展示复制、转发、选择文本功能
        if (!this.mmsItem.isIpMsg || this.mmsItem.isSimpleIpMsg) {
          // 复制
          this.copyMenuButton()
          this.multDivider()
          // 转发
          this.transmitMenuButton()
          this.multDivider()
          // 选择文本
          this.selectTextMenuButton()
          this.multDivider()
        }
        // 删除
        this.deleteMenuButton()
      } else {
        // 多选
        this.multSelectMenuButton()
        this.pcMultDivider()
        // 非ip消息或者简单的ip消息才展示复制、转发功能
        if (!this.mmsItem.isIpMsg || this.mmsItem.isSimpleIpMsg) {
          // 复制
          this.copyMenuButton()
          this.pcMultDivider()
          // 转发
          if (!this.isOsAccountConstraintEnabled) {
            this.transmitMenuButton()
            this.pcMultDivider()
          }
        }
        // 删除
        this.deleteMenuButton()
      }
    }
    .width(DeviceUtil.isPC() ? 160 : '224vp')
    .align(Alignment.Center)

  }

  private getDataDetectorFlag(): boolean {
    let flag = ((this.isAdvancedSecurity || !this.isEnableNlu) ? false :
      (this.detectResContent == '' ? (!this.isScrolling && this.textVisibleFlag) : true))
    HiLog.iw(TAG, 'getDataDetectorFlag:' + flag);
    return flag;
  }

  private isDataDetectorEnabled(): boolean {
    let flag = ((this.isAdvancedSecurity || !this.isEnableNlu) ? false : this.textVisibleFlag)
    HiLog.iw(TAG, 'isDataDetectorEnabled:' + flag);
    return flag;
  }

  private getEnableDataDetectorFlag(): boolean {
    let flag = (this.isAdvancedSecurity ? false :
      (this.detectResContent == '' ? (!this.isScrolling && this.textVisibleFlag) : true))
    HiLog.iw(TAG, 'getEnableDataDetectorFlag:' + flag);
    return flag;
  }

  private getEnableDataDetector(): boolean {
    let flag = (this.isAdvancedSecurity ? false : this.textVisibleFlag)
    HiLog.iw(TAG, 'getEnableDataDetector:' + flag);
    return flag;
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  pcMultDivider() {
    Row()
      .width('100%')
      .height(2)
  }

  @Builder
  // instrument ignore next
  multSelectMenuButton() {
    MenuItem({ content: $r('app.string.select_more') })
      .constraintSize({ minHeight: DeviceUtil.isPC() ? '' : $r('app.float.id_item_height_mid') })
      .height(DeviceUtil.isPC() ? 40 : '')
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.select_more').id))
      .onClick(() => {
        this.conversationCtrl.longPressSelected(this.context, 4);
        this.changeConversationSelectedNumberAndCheckAllBool();
        this.closeMenuSelections();
        this.showMMContentPicker = false;
        this.conversationCtrl.isMoreMenuDelete = false;
        AppStorage.setOrCreate('isSelectDelete', false);
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 0;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
      .align(Alignment.Center)
  }

  @Builder
  // instrument ignore next
  copyMenuButton() {
    MenuItem({ content: $r('app.string.msg_copy') })
      .constraintSize({ minHeight: DeviceUtil.isPC() ? '' : $r('app.float.id_item_height_mid') })
      .height(DeviceUtil.isPC() ? 40 : '')
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.msg_copy').id))
      .onClick(() => {
        let selectText = '';
        if (DeviceUtil.isPC() && this.textStart >= 0 && this.textEnd >= 0) {
          selectText = this.getSelectTextAndEmoji(this.content, this.textStart, this.textEnd);
          HiLog.w(TAG, `copyMenuButton selectText.length is:${selectText?.length}`);
        }
        this.conversationCtrl.longPressSelected(this.context, 0, undefined, selectText);
        this.closeMenuSelections();
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 1;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
      .align(Alignment.Center)
  }

  @Builder
  // instrument ignore next
  transmitMenuButton() {
    MenuItem({ content: $r('app.string.msg_transmit') })
      .constraintSize({ minHeight: DeviceUtil.isPC() ? '' : $r('app.float.id_item_height_mid') })
      .height(DeviceUtil.isPC() ? 40 : '')
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.msg_transmit').id))
      .onClick(() => {
        AppStorage.setOrCreate('isFromMenu', true);
        setTimeout(() => {
          this.conversationCtrl.longPressSelected(this.context, 1);
        }, 300);
        this.closeMenuSelections();
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 2;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
      .align(Alignment.Center)
  }

  @Builder
  // instrument ignore next
  selectTextMenuButton() {
    MenuItem({ content: $r('app.string.msg_select_text') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.msg_select_text').id))
      .onClick(() => {
        AppStorage.setOrCreate('isFromMenu', true);
        setTimeout(() =>{
          this.conversationCtrl.longPressSelected(this.context, 3);
        }, 300);
        this.closeMenuSelections();
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 3;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
  }

  @Builder
  // instrument ignore next
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: DeviceUtil.isPC() ? '' : $r('app.float.id_item_height_mid') })
      .height(DeviceUtil.isPC() ? 40 : '')
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.delete').id))
      .onClick(() => {
        this.changeFocusAble();
        this.conversationCtrl.longPressSelected(this.context, 2);
        this.closeMenuSelections();

        setTimeout(() => {
          this.delConversionController?.open();
        }, 300);
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 5;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
      .align(Alignment.Center)
  }

  @Builder
  // instrument ignore next
  customVerCodeText() {
    if (this.bubbleTextDirection == 'left') {
      Row() {
        Text($r('app.string.copy_verification_code'))
          .padding({
            top: $r('sys.float.padding_level4'),
            bottom: $r('sys.float.padding_level1')
          })
          .fontSize($r('sys.float.ohos_id_text_size_button2'))
          .fontColor($r('sys.color.brand'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Transparent)
          .textAlign(TextAlign.Start)
          .onClick(() => {
            let ss = this.mmsItem.msgCodeStr;
            commonPasteboard.setPasteboard(ss);
            promptAction.showToast({
              message: $r('app.string.copied_to_clipboard'),
              duration: 2000
            });
            DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CONTENT_COPY_VERIFY_CODE);
          })
          .accessibilityLevel('yes')
          .hitTestBehavior(HitTestMode.Block)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .backgroundColor(Color.Transparent)

    }
  }

  /**
   * 获取卡片的padding值
   */
  private getCardPadding(): Padding | Length | LocalizedPadding {
    // pc上短信padding值
    if (this.isPC) {
      return {
        left: this.shouldShowBubble ? 12 : 0,
        right: this.shouldShowBubble ? 12 : 0,
        top: 10,
        bottom: 9
      }
    }
    // 手机上短信padding值
    return {
      left: this.shouldShowBubble ? 12 : 0,
      right: this.shouldShowBubble ? 12 : 0,
      top: 8,
      bottom: 8
    }
  }

  /**
   * 获取卡片的圆角
   */
  private getBorderRadius(): Length | BorderRadiuses | LocalizedBorderRadiuses {
    // 原生逻辑，短信原文的圆角设置
    return Configuration.getLocale().dir === 'rtl' ? (this.bubbleTextDirection == 'right' ?
      {
        topLeft: this.showMenu ? this.bubbleTextBorderRadius[1]
          : this.bubbleTextBorderRadius[0],
        topRight: this.bubbleTextBorderRadius[1],
        bottomLeft: this.bubbleTextBorderRadius[1],
        bottomRight: this.bubbleTextBorderRadius[1]
      } :
      {
        topLeft: this.bubbleTextBorderRadius[1],
        topRight: this.showMenu ? this.bubbleTextBorderRadius[1] : this.bubbleTextBorderRadius[0],
        bottomLeft: this.bubbleTextBorderRadius[1],
        bottomRight: this.bubbleTextBorderRadius[1]
      }) :
      (this.bubbleTextDirection == 'right' ?
        {
          topLeft: this.bubbleTextBorderRadius[1],
          topRight: DeviceUtil.isPC() ? this.bubbleTextBorderRadius[0] :
            this.showMenu ? this.bubbleTextBorderRadius[1] : this.bubbleTextBorderRadius[0],
          bottomLeft: this.bubbleTextBorderRadius[1],
          bottomRight: this.bubbleTextBorderRadius[1]
        } :
        {
          topLeft: DeviceUtil.isPC() ? this.bubbleTextBorderRadius[0] :
            this.showMenu ? this.bubbleTextBorderRadius[1] : this.bubbleTextBorderRadius[0],
          topRight: this.bubbleTextBorderRadius[1],
          bottomLeft: this.bubbleTextBorderRadius[1],
          bottomRight: this.bubbleTextBorderRadius[1]
        });
  }
}