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
import ConversationController from '../pages/conversation/conversationController';
import HiLog from '../utils/HiLog';
import TelephoneUtil from '../utils/TelephoneUtil';
import { ContactAvatar } from '../views/ContactAvatar'
import common from '../data/commonData';
import { VibrationUtils } from '../utils/VibrationUtils';
import dotCommon, { dotNoNeedParmas, stateParam } from '../utils/MmsDot/DotCommon';
import DotUtil from '../utils/MmsDot/DotUtils';
import MmsUtil from '../utils/MmsUtil';
import AccessibilityUtil from '../utils/AccessibilityUtil';
import lazy { SplitScreenManager } from '../utils/SplitScreenManager'
import { curves, LengthMetrics } from '@kit.ArkUI';
import Constant from '../data/Constant';
import ConversationListComtroller, { messageType } from '../pages/conversationlist/conversationListController';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../data/EmitterConstant';
import { fileUri } from '@kit.CoreFileKit';
import { RedirectDetailParams } from '../chatbot/utils/ChatbotEntitys';
import lazy { ComInfoModel } from '../model/ComInfoModel';
import { DateRefreshUtil } from '../utils/DateRefreshUtil';
import { DateUtil } from '../utils/DateUtil';
import { JSON } from '@kit.ArkTS';
import StringUtil from '../utils/StringUtil';
import DeviceUtil from '../utils/DeviceUtil';
import myCommon from '@ohos.app.ability.common';
import InfoMsgController from '../pages/infomsg/InfoMsgController';
import ConversationListController from '../pages/conversationlist/conversationListController';
import { ConfigurationConstant } from '@kit.AbilityKit';
import FileUtils from '../utils/FileUtils';
import { ValuesBucket } from '@kit.ArkData';
import ConversationListService from '../service/ConversationListService';
import { ChatbotUtils } from '../chatbot/utils/ChatbotUtils';
import { BadgeUtil } from '../utils/BadgeUtil';
import { Highlight, HighlightsOptions, HighlightType } from '../utils/Highlight';

const MSG_CONTAINS_EMOJI_NUMBER: number = 0;
const TAG = 'MmsListItem';
const MARIGIN_TOP: number = 9;
const MARIGIN_LEFT: number = 16;
const MARIGIN_TITLE_LEFT: number = 8;
const MARIGIN_2: number = 2;
const MARIGIN_FOUR: number = 4;
const MARIGIN_TWENTY_FOUR: number = 24;
const MARIGIN_FORTY: number = 40;
@Component
@Reusable
export struct MmsListItem {
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    @ObjectLink item: messageType;
    @StorageLink('selectPhoneNumber') selectPhoneNumber: string = '';
    @State mConversationCtrl: ConversationController = ConversationController.getInstance()
    @Link isMultipleSelectState: boolean;
    @Prop isInSetReadThreadIndex: number;
    @Prop isShowHeadIcon: boolean = true;
    @Prop loadFromDB: boolean = false;
    @Prop showCount: boolean = false;
    /* 设备是否为pad */
    @Prop isPad: boolean = false;
    /* 是否展示菜单 */
    @Prop isShowMenu: boolean = false;
    @Prop showCountOfUnread: boolean = false;
    // 是否显示底部线条
    @Prop isShowBottomLine: boolean = false;
    private mConListCtrl: ConversationListComtroller = ConversationListComtroller.getInstance();
    @StorageLink('InfoMsgController') mInfoListCtrl: InfoMsgController = InfoMsgController.getInstance();
    @State isCbChecked: boolean = false;
    private selectCallBack: Callback<emitter.EventData> | undefined = undefined;
    private updateReaderTextCallBack: Callback<emitter.EventData> | undefined = undefined;
    @Consume('pageInfos') pageInfos: NavPathStack;
    @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
    private marginLeft: number = px2vp(getContext(this).resourceManager.getNumber($r('sys.float.margin_left').id));
    private marginRight: number = px2vp(getContext(this).resourceManager.getNumber($r('sys.float.margin_right').id));

    @StorageProp('currentColorMode') currentMode: ConfigurationConstant.ColorMode =
        ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    onClickHead: (clickPosition: number, event?: ClickEvent) => void = () => {
    };
    onClickCheckBox: (index: number, value: boolean) => void = () => {
    };
    menuMultSelect: (index: number) => void = () => {
    };
    menuDelete: (index: number) => void = () => {
    };
    menuPin: (threadId: number, index: number) => void = () => {
    };
    menuUnPin: (threadId: number, index: number) => void = () => {
    };
    menuReadOrUnRead: (item: messageType, countOfUnread: number, telephone: string) => void = () => {
    };
    onClickListItem: (index: number) => void = () => {
    };
    @State comInfo: ComInfoModel | null = null;
    @State fatherView: string = '';
    @Prop curBp: string = common.STR.DEVICE_MOBILE_PHONE;
    /**
     * 是否是点击通知进入
     * 如果是点击通知，会先进入列表，导致服务号埋点曝光被执行
     */
    @StorageProp('isFromNotification') @Watch('fromNotification') isFromNotification: boolean =
        AppStorage.get('isFromNotification') ?? false;
    private isPC: boolean = DeviceUtil.isPC();
    private context = getContext(this) as myCommon.UIAbilityContext;
    @State dateTimeHeight: number = 0;
    @State accessibilityTextStr: string | undefined = undefined;
    @State accessibilitySelectStatusStr: string | undefined = undefined;
    /* 设备是否开启无障碍屏幕朗读 */
    @StorageLink('isScreenReaderOpen') @Watch('accessibilityOpenStatusChange') isReaderOpen: boolean = false;
  @StorageProp('currentLanguage') @Watch('sysLocaleChangedFun') currentLanguage: string = '';
  @Prop inputText: string = '';
  private uiContent: UIContext = this.getUIContext();
    accessibilityOpenStatusChange() {
      if (this.isReaderOpen) {
        this.registerAccessibilityTextChangeEvent();
        this.updateReaderText();
      } else {
        if (this.updateReaderTextCallBack) {
          emitter.off(EmitterConstant.EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE, this.updateReaderTextCallBack)
        }
      }
    }


  dealSendNameWithHighlight(): HighlightsOptions[] {
    // 获取目标文本（名字/电话）和搜索关键词
    const targetText = this.item.contactsNum > 1 ? this.dealGroupSendName() : this.dealSendName();

    let highlights: HighlightsOptions[] = [];
    if (this.inputText) {
      highlights = Highlight.getInstance().buildHighlightsByEmTag(targetText, this.inputText)
    } else {
      // 无搜索关键词时，显示原始文本
      highlights = [{ text: targetText, type: HighlightType.normal }];
    }
    return highlights
  }

    updateReaderText() {
      if (this.isReaderOpen) {
        let showName = this.item.contactsNum > 1 ? this.dealGroupSendName() : this.dealSendName();
        this.accessibilityTextStr = AccessibilityUtil.getItemContext(this.item, this.context, showName);
        this.accessibilitySelectStatusStr = this.item.isCbChecked ? getContext(this).resourceManager
          .getStringSync($r('app.string.double_click_cancle').id) :
        getContext(this).resourceManager.getStringSync($r('app.string.double_click_select').id);
      }
    }

  sysLocaleChangedFun() {
    // 针对一小时之内有消息的会话，因分钟数需要国际化，需在语言切换时初始化
    if (DateUtil.isDateDiffOneHour(this.item)) {
      DateUtil.convertDateFormatForItem(this.item);
    }
  }

    getRawContactId(index?: number): string {
        if (index !== undefined) {
            const rawContactId: string = this.item.rawContactId || '';
            return rawContactId.split(',')[index] || ''
        }
        return ''
    }
    getContactId(index?: number): string {
        if (index !== undefined) {
            const contactId: string = this.item.contactId || '';
            let ret = contactId.split(',');
            if (ret.length > index) {
                if (index === 0) {
                    //忽略群发的场景
                    HiLog.i(TAG, 'contactId:'+ ret[index]);
                }
                return ret[index];
            }
        }
        return ''
    }
    // 获取多收件人情况下是否有黄页图片标识
    getYellowPageIcon(index?: number): string {
        if (index !== undefined) {
            const hasYellowPageIcon: string = this.item.hasYellowPageIcon || '';
            return hasYellowPageIcon.split(',')[index] || ''
        }
        return ''
    }

    fromNotification() {
        HiLog.i(TAG,'isFromNotification status: ' + this.isFromNotification);
    }

  refreshParams() {
    this.item.isCbChecked = this.mConListCtrl.checkedStatus.has(this.item.threadId);
    this.updateReaderText();
  }

  aboutToAppear(): void {
    HiLog.i(TAG, `aboutToAppear:${this.item?.threadId}`);
    this.registerSelectStatueChangeEvent();
    this.registerTimeChangeEvent();
    this.registerAccessibilityTextChangeEvent();
    this.refreshParams();
  }

  aboutToDisappear(): void {
    if (this.selectCallBack) {
      emitter.off(EmitterConstant.EVENT_CONVERSATION_LIST_SELECT_STATUES_CHANGE, this.selectCallBack);
    }
    if (this.updateReaderTextCallBack) {
      emitter.off(EmitterConstant.EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE, this.updateReaderTextCallBack)
    }
    DateRefreshUtil.getInstance().unsubscribeTimeRefresh(`${this.item.threadId}`);
  }

  aboutToReuse(params: Record<string, Object>): void {
    setTimeout(() => {
      this.fatherView = (params.fatherView as string)?.valueOf();
      this.registerSelectStatueChangeEvent();
      this.registerTimeChangeEvent();
      this.registerAccessibilityTextChangeEvent();
      this.refreshParams();
    }, 0);
  }

  aboutToRecycle(): void {
    if (this.selectCallBack) {
      emitter.off(EmitterConstant.EVENT_CONVERSATION_LIST_SELECT_STATUES_CHANGE, this.selectCallBack);
    }
    if (this.updateReaderTextCallBack) {
      emitter.off(EmitterConstant.EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE, this.updateReaderTextCallBack)
    }
    DateRefreshUtil.getInstance().unsubscribeTimeRefresh(`${this.item.threadId}`);
  }

  private registerTimeChangeEvent() {
    DateRefreshUtil.getInstance()
      .subscribeTimeRefreshFilter(`${this.item.threadId}`, Number(this.item.timeMillisecond),
        () => {
          DateUtil.convertDateFormatForItem(this.item);
          this.updateReaderText();
        });
  }

  private registerSelectStatueChangeEvent() {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_CONVERSATION_LIST_SELECT_STATUES_CHANGE,
    };
    this.selectCallBack = (eventData: emitter.EventData) => {
      let threadId: number | null = eventData.data?.id;
      if (!threadId || this.item.threadId === threadId) {
        this.item.isCbChecked = this.mConListCtrl.checkedStatus.has(this.item.threadId);
        if (this.isReaderOpen) {
          this.accessibilitySelectStatusStr = this.item.isCbChecked ? getContext(this).resourceManager
            .getStringSync($r('app.string.double_click_cancle').id) :
          getContext(this).resourceManager.getStringSync($r('app.string.double_click_select').id);
        }
      }
    };
    emitter.on(innerEvent, this.selectCallBack);
  }

  // 置顶取消置顶后列表无障碍文本更新
  private registerAccessibilityTextChangeEvent() {
    if (this.updateReaderTextCallBack) {
      emitter.off(EmitterConstant.EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE, this.updateReaderTextCallBack)
    }
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE,
    };
    this.updateReaderTextCallBack = ()=>{
      this.updateReaderText();
    };
    emitter.on(innerEvent, this.updateReaderTextCallBack)
  }

    avatarAlignRules() {
        const rules: AlignRuleOption = {
            center: { anchor: '__container__', align: VerticalAlign.Center },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
        }
        return rules
    }
    //多头像排列规则
    avatarAlignRulesWithIndex(index: number): AlignRuleOption {
        let rulesArray: AlignRuleOption[] = []
        if (this.item.photoFirstNames.length == 3) {
            rulesArray = [
                {},
                {
                    top: { anchor: 'contact_avatar_first', align: VerticalAlign.Bottom },
                },
                {
                    top: { anchor: 'contact_avatar_first', align: VerticalAlign.Bottom },
                    left: { anchor: 'contact_avatar_1', align: HorizontalAlign.End },
                },
            ]
        } else {
            rulesArray = [
                {},
                {
                    left: { anchor: 'contact_avatar_first', align: HorizontalAlign.End }
                },
                {
                    top: { anchor: 'contact_avatar_first', align: VerticalAlign.Bottom },
                },
                {
                    top: { anchor: 'contact_avatar_first', align: VerticalAlign.Bottom },
                    left: { anchor: 'contact_avatar_2', align: HorizontalAlign.End }
                },
            ]
        }
        return rulesArray[index];
    }

    // 多头像间隔
    avatarMarginsWithIndex(index: number): LocalizedMargin {
        let marginArray: LocalizedMargin[] = [];
        if (this.item.photoFirstNames.length == 3) {
            marginArray =
                [{ start: LengthMetrics.vp(this.item.photoSize.width / 2 + 1) },
                    { top: LengthMetrics.vp(MARIGIN_2) },
                    { start: LengthMetrics.vp(MARIGIN_2), top: LengthMetrics.vp(MARIGIN_2) }]
        } else {
            marginArray = [{},
                { start: LengthMetrics.vp(MARIGIN_2) },
                { top: LengthMetrics.vp(MARIGIN_2) },
                { start: LengthMetrics.vp(MARIGIN_2), top: LengthMetrics.vp(MARIGIN_2) }]
        }
        return marginArray[index]
    }

  replaceNewlineToBlank(str: string | Resource): string {
    let res: string = '';
    try {
      if (typeof str === 'string') {
        res = str.replace(new RegExp('\n', 'g'), ' ');
      }
    } catch (err) {
      HiLog.e(TAG, `replaceNewlineToBlank error: ${err}`);
      return res;
    }
    return res;
  }

  //处理群发名称展示格式
  dealGroupSendName(): string {
    try {
      let dealNameArr: string[] = this.item.name.split(',');
      let phoneArr: string[] = this.item.telephoneFormat.split(',');
      let formatNum = common.STR.EMPTY_STR;
      let strContactNameFormat = common.STR.EMPTY_STR;
      for (let index = 0; index < phoneArr.length; ++index) {
        if (phoneArr[index].replace(/\s*/g, '') == dealNameArr[index].replace(/\s*/g, '')) {
          formatNum = TelephoneUtil.countryCodeFormatPhone(phoneArr[index]);
          strContactNameFormat += formatNum + common.STR.COMMA + common.STR.WHITE_SPACE;
        } else {
          strContactNameFormat += (dealNameArr[index] + common.STR.COMMA + common.STR.WHITE_SPACE);
        }
      }
      strContactNameFormat = strContactNameFormat.substring(0, strContactNameFormat.length - 2);
      return strContactNameFormat;
    } catch (err) {
      HiLog.e(TAG, ` dealGroupSendName failed, code is ${err?.code}, message is ${err?.message}`);
    }
    return this.item.name;
  }

  //处理普通名称展示格式
  dealSendName(): string {
    let dealNameStr: string = this.item.name;
    let phoneStr: string = this.item.telephoneFormat;
    let formatNum = common.STR.EMPTY_STR;
    try {
      if (dealNameStr.replace(/\s*/g, '') === phoneStr.replace(/\s*/g, '')) {
        formatNum = TelephoneUtil.countryCodeFormatPhone(phoneStr);
      } else {
        formatNum = dealNameStr !== '' ? dealNameStr : TelephoneUtil.countryCodeFormatPhone(phoneStr);
      }
      if (phoneStr.startsWith('sip:') && phoneStr.concat('@') && formatNum.startsWith('sip:') &&
      formatNum.concat('@')) {
        const startIndex = formatNum.indexOf('sip:') + 'sip:'.length;
        const endIndex = formatNum.indexOf('@', startIndex);
        formatNum = formatNum.substring(startIndex, endIndex);
      }
      if (!StringUtil.isEmpty(this.item.contactName) && !ChatbotUtils.isChatbotNumber(this.item.telephone) &&
          StringUtil.isEmpty(this.item.contactId) && !StringUtil.isContain(this.item.contactName, this.item.telephone)) {
        formatNum = this.item.contactName;
      }
    } catch (err) {
      HiLog.e(TAG, `dealSendName error, code: ${err?.code}, message: ${err?.message}`);
    }
    return formatNum;
  }



    longPressAction() {
        if (!this.isMultipleSelectState) {
            this.isShowMenu = true
            AppStorage.setOrCreate('listShowMenu', true)
        }
        VibrationUtils.onceVibration(common.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
    }

    @Styles
    listItemNormalStyles() {
      .backgroundColor(this.isShowMenu ? $r('sys.color.comp_background_list_card') : Color.Transparent)
    }

    @Styles
    pressedStyles() {
        .backgroundColor(this.isShowMenu ? $r('sys.color.comp_background_list_card') : $r('sys.color.ohos_id_color_click_effect'))
    }

    build() {
      if (!this.isPC) {
        RelativeContainer() {
            this.msgTextHeadIcon()
            this.msgTextBody()
            // Content Abbreviations for Latest News
            // Whether the latest message has not been sent successfully. If yes,
            if (this.item.sendingFailed as boolean && !(this.item.isDraft as boolean)) {
                // If yes
                this.sentSuccessfully()
            } else {
                // If not
                this.sentNotSuccessfully()
            }
            this.msgPinIcon();
            // CheckBox
            if (this.isMultipleSelectState) {this.multipleSelectStateBox()}
            Divider()
                .strokeWidth(`${Constant.HEIGHT_OF_CONVERSATION_LIST_DIVIDER}px`)
                .color($r('sys.color.comp_divider'))
                .visibility(this.isShowBottomLine ? Visibility.Visible : Visibility.None)
                .margin({ start: LengthMetrics.vp(this.isShowHeadIcon ? MARIGIN_LEFT : 0)})
                .alignRules({
                    left: this.isShowHeadIcon ? { anchor: 'contact_avatar', align: HorizontalAlign.End }
                        : { anchor: '__container__', align: HorizontalAlign.Start },
                    right: { anchor: '__container__', align: HorizontalAlign.End },
                    bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
                })
        }.id(this.fatherView + this.item.index)
        .accessibilityText(this.accessibilityTextStr)
        .accessibilityGroup(true, { accessibilityPreferred: true })
        .accessibilityDescription(this.isMultipleSelectState ? this.accessibilitySelectStatusStr: '')
        .borderRadius({
            topRight: 16, bottomRight: 16,
        }).width('100%').height('auto')
        .onClick(() => {
          this.onClickListItem(this.item.index);
        })
        .stateStyles({
            normal: this.listItemNormalStyles,
            pressed: this.pressedStyles
        })
        .parallelGesture(
            GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false, duration: 500 })
                .tag('sessionListLongPress')
                .onAction(() => {
                    this.longPressAction();
                }),
            ))
        .padding({
            left: DeviceUtil.isPC() ? 24 :
                this.isPad ? this.padMargin : this.marginLeft,
            right: DeviceUtil.isPC() ? 24 :
                this.isPad ? this.padMargin : this.marginRight
        })
        .onGestureJudgeBegin((gestureInfo: GestureInfo, event: BaseGestureEvent) => {
            let finger = this.fatherView === 'Conversation' ? this.mConListCtrl.noUiProp.longPressFingers : this.mInfoListCtrl.longPressFingers;
            if (gestureInfo.tag == 'sessionListLongPress' && finger == 1) {
                this.fatherView === 'Conversation' ? this.mConListCtrl.noUiProp.longPressFingers = 0 :
                    this.mInfoListCtrl.longPressFingers = 0;
                // 返回 CONTINUE 将保持系统判定。
                return GestureJudgeResult.CONTINUE;
            }
            return GestureJudgeResult.REJECT;
        })
        .bindContextMenu(this.isShowMenu, this.longPressMenuBuild(), {
            preview: MenuPreviewMode.IMAGE, placement: Placement.BottomLeft,
            previewAnimationOptions: {
                scale: [0.95, 1.1]
            },
            onAppear: (() => {
                AppStorage.setOrCreate('listShowMenu', true)
                this.item.smsType == 0 ? stateParam.PAGE_STATE = 1 : stateParam.PAGE_STATE = 2;
                DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LONGPRESS_ONE_SMS);
            }),
            aboutToAppear:(()=>{
                this.isShowMenu = true;
            }),
            aboutToDisappear: (() => {
                this.isShowMenu = false
                AppStorage.setOrCreate('listShowMenu', false)
            })
        })
      } else {
          RelativeContainer() {
              this.msgTextHeadIcon()
              this.msgTextBody()
              // Content Abbreviations for Latest News
              // Whether the latest message has not been sent successfully. If yes,
              if (this.item.sendingFailed as boolean && !(this.item.isDraft as boolean)) {
                  // If yes
                  this.sentSuccessfully()
              } else {
                  // If not
                  this.sentNotSuccessfully()
              }
              this.msgPinIcon()
              // CheckBox
              if (this.isMultipleSelectState) {this.multipleSelectStateBox()}
              Divider()
                  .strokeWidth('app.float.settings_divider_strokeWidth')
                  .color($r('sys.color.comp_divider'))
                  .visibility(this.isShowBottomLine ? Visibility.Visible : Visibility.None)
                  .margin({ start: LengthMetrics.vp(this.isShowHeadIcon ? MARIGIN_LEFT : 0)})
                  .alignRules({
                      left: this.isShowHeadIcon ? { anchor: 'contact_avatar', align: HorizontalAlign.End }
                          : { anchor: '__container__', align: HorizontalAlign.Start },
                      right: { anchor: '__container__', align: HorizontalAlign.End },
                      bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
                  })
          }.id(this.fatherView + this.item.index)
          .accessibilityText(this.accessibilityTextStr)
          .accessibilityGroup(true, { accessibilityPreferred: true })
          .accessibilityDescription(this.isMultipleSelectState ? this.accessibilitySelectStatusStr: '')
          .onClick(() => {
            this.onClickListItem(this.item.index);
          })
          .borderRadius({
              topRight: 16, bottomRight: 16,
          }).width('100%').height('auto')
          .stateStyles({
              normal: this.listItemNormalStyles,
              pressed: this.pressedStyles
          })
          .padding({
            left: 24,
            right: 24
          })
          .parallelGesture(
              GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false, duration: 500 })
                  .tag('sessionListLongPress')
                  .onAction(() => {
                      if (SplitScreenManager.getInstance().infoModel.isNoLongPress) {
                          return;
                      }
                      this.longPressAction();
                  }),
              ))
            .bindContextMenu(this.longPressMenuBuild(), ResponseType.RightClick, {
                onAppear: (() => {
                    this.isShowMenu = true;
                    AppStorage.setOrCreate('listShowMenu', true)
                    this.item.smsType == 0 ? stateParam.PAGE_STATE = 1 : stateParam.PAGE_STATE = 2;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LONGPRESS_ONE_SMS);
                }),
                aboutToDisappear: (() => {
                    this.isShowMenu = false
                    AppStorage.setOrCreate('listShowMenu', false)
                })
            })
            .bindContextMenu(this.longPressMenuBuild(), ResponseType.LongPress, {
                onAppear: (() => {
                    this.isShowMenu = true;
                    AppStorage.setOrCreate('listShowMenu', true)
                    this.item.smsType == 0 ? stateParam.PAGE_STATE = 1 : stateParam.PAGE_STATE = 2;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LONGPRESS_ONE_SMS);
                }),
                aboutToDisappear: (() => {
                    this.isShowMenu = false
                    AppStorage.setOrCreate('listShowMenu', false)
                })
            })
        }
    }

    // message unread head icon
  @Builder
  msgHeadIcon() {
    if (this.item.smsType === 0) {
      this.linkPersonImage();
    } else {
      if (!StringUtil.isEmpty(this.item.contactId)) {
        this.linkPersonImage();
      } else if (ChatbotUtils.isChatbotNumber(this.item.telephone)) {
        this.chatbotImage();
      } else if (this.item.hasYellowPageIcon) {
        this.yellowImage();
      } else {
        this.normalUserImage();
      }
    }
  }

    //chatbot头像
    @Builder
    chatbotImage() {
        Badge({
            count: this.showCountOfUnread ? this.item.countOfUnread : 0,
            position: BadgeUtil.getBadgePosition(this.showCountOfUnread ? this.item.countOfUnread : 0,
              this.fontSizeScale, this.uiContent),
            style: BadgeUtil.getBadgeStyle(this.fontSizeScale)
        }) {
            Image(this.item.chatbotPageIcon ? (this.item.chatbotPageIcon.startsWith('https') ?
            this.item.chatbotPageIcon : fileUri.getUriFromPath(this.item.chatbotPageIcon)) :
                (Number(this.currentMode) == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
                $rawfile('icon/ic_bell_default_light.svg') : $rawfile('icon/ic_bell_default_dark.svg')))
                .objectFit(ImageFit.Auto)
                .id('list_item_chatbot_icon')
                .width('40vp')
                .height('40vp')
                .alt(Number(this.currentMode) == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT?
                     $rawfile('icon/ic_bell_default_light.svg'): $rawfile('icon/ic_bell_default_dark.svg'))
                .draggable(false)
                .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
                .clip(new Circle({ width: '40vp', height: '40vp' }))
                .syncLoad(true)
        }
        .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .id('contact_avatar')
        .width('40vp')
        .height('40vp')
        .onClick(() => {
            let params: RedirectDetailParams = {
                id:  this.item.telephone,
                icon: this.item.chatbotPageIcon,
                name: this.item.name,
            }
            this.pageInfos.pushPathByName('RcsDetailsChatbotActivity', params);
            DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.OPEN_CHATBOT_DETAIL);
        })
        .accessibilityLevel('yes')
        .accessibilityText($r('app.string.contact_avatar_button'))
    }

    //普通用户头像（设置了头像和没有设置头像，显示文字）
    @Builder
    linkPersonImage() {
        Badge({
            count: this.showCountOfUnread ? this.item.countOfUnread : 0,
            position: BadgeUtil.getBadgePosition(this.showCountOfUnread ? this.item.countOfUnread : 0,
              this.fontSizeScale, this.uiContent),
            style: BadgeUtil.getBadgeStyle(this.fontSizeScale)
        }) {
            // Image组件实现消息联系人头像
            this.msgAvatarsShow()
        }
        .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .id('contact_avatar')
        .width('40vp')
        .height('40vp')
        .onClick(() => {
            HiLog.i(TAG, 'mms list item click head');
            this.onClickHead(this.item.index)
        })
        .accessibilityLevel('yes')
        .accessibilityText($r('app.string.contact_avatar_button'))
    }
    //黄页用户头像
    @Builder
    yellowImage() {
        Badge({
            count: this.showCountOfUnread ? this.item.countOfUnread : 0,
            position: BadgeUtil.getBadgePosition(this.showCountOfUnread ? this.item.countOfUnread : 0,
              this.fontSizeScale, this.uiContent),
            style: BadgeUtil.getBadgeStyle(this.fontSizeScale)
        }) {
            Image('data:image/png;base64,' + this.item.hasYellowPageIcon)
                .width('40vp')
                .height('40vp')
                .draggable(false)
                .objectFit(ImageFit.Fill)
                .clip(new Circle({ width: '40vp', height: '40vp' }))
                .border({
                    width: '1vp',
                    style: BorderStyle.Solid,
                    radius: '20vp',
                    color: $r('sys.color.ohos_id_color_click_effect')
                })
                .syncLoad(true);
        }
        .width('40vp')
        .height('40vp')
        .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .onClick(() => {
            this.onClickHead(this.item.index)
        })
        .id('contact_avatar')
        .accessibilityLevel('yes')
        .accessibilityText($r('app.string.contact_avatar_button'))
    }
    //默认用户头像
    @Builder
    normalUserImage() {
        Badge({
            count: this.showCountOfUnread ? this.item.countOfUnread : 0,
            position: BadgeUtil.getBadgePosition(this.showCountOfUnread ? this.item.countOfUnread : 0,
              this.fontSizeScale, this.uiContent),
            style: BadgeUtil.getBadgeStyle(this.fontSizeScale)
        }) {
           Image($rawfile(this.item.icon))
                .width('40vp')
                .height('40vp')
                .draggable(false)
                .objectFit(ImageFit.Fill)
                .backgroundColor($r('sys.color.icon_fourth'))
                .fillColor($r('sys.color.ohos_id_color_primary_contrary'))
                .borderRadius(20)
                .padding(8)
        }
        .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .id('contact_avatar')
        .width('40vp')
        .height('40vp')
        .onClick(() => {
            this.onClickHead(this.item.index)
        })
        .accessibilityText($r('app.string.contact_avatar_button'))
        .accessibilityLevel('yes')
    }

    // AvatarsShow
    @Builder
    msgAvatarsShow() {
        RelativeContainer() {
            ForEach(this.item.photoFirstNames, (item: string, index: number) => {
                this.msgAvatarsProcessWithIndex(index)
            }, (item: string) => JSON.stringify(item))
        }.id('contact_avatar')
        .width('auto')
        .height('auto')
        .alignRules({ center: { anchor: '__container__', align: VerticalAlign.Center } })
    }

    // AvatarsProcess
  @Builder
  msgAvatarsProcessWithIndex(index: number) {
    ContactAvatar({
      hasYellowPageIcon: this.getYellowPageIcon(index),
      rawContactId: this.getRawContactId(index),
      contactId: this.getContactId(index),
      phoneNumber: this.item.telephoneFormat,
      yellowPageId: this.item.yellowPageId,
      firstPhotoName: this.item.photoFirstNames[index]?.firstName,
      portraitColor: this.item.photoFirstNames[index]?.portraitColor ?
        this.item.photoFirstNames[index]?.portraitColor
        : this.item.portraitColor,
      imgSize: this.item.photoSize.width,
      loadFromDB: this.loadFromDB,
      fontSize: this.item.photoFirstNames.length > 1 ? 8 : 0,
      marginLength: this.item.photoFirstNames.length,
      index: this.item.index,
      smsType: this.item.smsType,
      avatarIcon: this.item.icon,
      chatbotPageIcon: this.item.chatbotPageIcon,
      blockedType: this.item.blockedType
    })
      .id(index === 0 ? 'contact_avatar_first' : ('contact_avatar_' + index))
      .alignRules(this.avatarAlignRulesWithIndex(index))
      .margin(this.avatarMarginsWithIndex(index))
      .onClick(() => {
        HiLog.i(TAG, 'mms list item click head, contactId:' + this.item.contactId);
        if (this.item.telephone.startsWith('sip:') && this.item.telephone.includes('botplatform')) {
          let params: LooseObject = {
            id: this.item.telephone,
            icon: this.item.chatbotPageIcon,
            name: this.item.name,
          }
          this.pageInfos.pushPathByName('RcsDetailsChatbotActivity', params);
          DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.OPEN_CHATBOT_DETAIL);
        } else {
          this.onClickHead(this.item.index);
        }
      })
      .accessibilityLevel('no-hide-descendants')
  }

    // msg count of unread
    @Builder
    msgCountOfUnread() {
        Row(){
            Text(this.item.countOfUnread < 100 ? this.item.countOfUnread.toString() : '99+')
                .backgroundColor($r('sys.color.ohos_id_color_badge_red'))
                .fontSize($r('sys.float.ohos_id_text_size_caption'))
                .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
                .textAlign(TextAlign.Center)
                .constraintSize({ minWidth: 16 })
                .height(16)
                .padding({
                    left: this.item.countOfUnread > 9 ? 6 : 0,
                    right: this.item.countOfUnread > 9 ? 6 : 0
                })
                .borderRadius(16)
        }
        .alignRules({
            top: { anchor: 'contact_avatar', align: VerticalAlign.Top },
            right: { anchor: 'contact_avatar', align: HorizontalAlign.End },
        })
        .id('countOf_unread')
        .offset({ x: 4, y: -4 })
        .borderRadius(20)
        .padding(2)
        .backgroundColor($r('sys.color.ohos_id_color_background'))
    }

    // message Phone number or first name
    @Builder
    msgPhoneNumber() {
        Row() {
          Text(){
            ForEach(this.dealSendNameWithHighlight(), (item: HighlightsOptions) => {
              Span(item.text)
                .fontColor(item.type === HighlightType.highlight
                  ? $r('app.color.brand')
                  : $r('sys.color.ohos_id_color_text_primary'));
            });
          }
            .direction(Direction.Ltr)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .maxLines(1)
            .fontWeight(FontWeight.Medium)
            .wordBreak(WordBreak.BREAK_ALL)
            .fontFeature('\"ss08\" 1')
            .constraintSize({ minHeight: '22vp' })
          if (!this.isShowHeadIcon && this.showCountOfUnread && this.item.countOfUnread > 0) {
            Text()
              .id('un_read_dot')
              .backgroundColor($r('sys.color.icon_emphasize'))
              .width(8)
              .height(8)
              .borderRadius(4)
              .fontFeature('\"ss08\" 1')
              .margin({ start: LengthMetrics.vp(8) })
          }
          Blank();
        }
        .id('name')
        .constraintSize({ minHeight: '22vp' })
        .margin({
            top: LengthMetrics.vp(MARIGIN_TOP),
            start: DeviceUtil.isPC() ? (this.isShowHeadIcon ? LengthMetrics.vp(8) : LengthMetrics.vp(0)) :
            LengthMetrics.vp(this.isShowHeadIcon ? MARIGIN_LEFT : 0),
            end: LengthMetrics.vp(this.fontSizeScale < Constant.SENIOR_MODE_THREE ? MARIGIN_TITLE_LEFT : 0),
        })
        .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: {
                anchor: this.isShowHeadIcon ? 'contact_avatar' : '__container__',
                align: this.isShowHeadIcon ? HorizontalAlign.End : HorizontalAlign.Start
            },
            right: {
                anchor: this.fontSizeScale < Constant.SENIOR_MODE_THREE ? 'time' : '__container__',
                align: this.fontSizeScale < Constant.SENIOR_MODE_THREE ? HorizontalAlign.Start : HorizontalAlign.End
            }
        })
    }

    // message Date Time
    @Builder
    msgDateTime() {
        Text(this.item.time)
            .alignRules(this.fontSizeScale >= Constant.SENIOR_MODE_THREE ? {
                top: { anchor: 'message_details_content', align: VerticalAlign.Bottom },
                left: { anchor: 'message_details_content', align: HorizontalAlign.Start },
                right: { anchor: 'pinning_time', align: HorizontalAlign.Start }
            } : {
                top: { anchor: '__container__', align: VerticalAlign.Top },
                right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                    : { anchor: '__container__', align: HorizontalAlign.End }
            })
            .id('time')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body3'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .constraintSize({minHeight: '16vp'})
            .margin({
                top: LengthMetrics.vp(this.fontSizeScale < Constant.SENIOR_MODE_THREE ? MARIGIN_TOP : 0),
                end: LengthMetrics.vp(this.isMultipleSelectState && this.fontSizeScale < Constant.SENIOR_MODE_THREE ?
                    MARIGIN_LEFT : 0),
                bottom: LengthMetrics.vp(this.fontSizeScale < Constant.SENIOR_MODE_THREE ? 0 : MARIGIN_TOP)
            })
            .onAreaChange((oldValue: Area, newValue: Area) => {
                this.dateTimeHeight = newValue.height as number;
            })
    }

    // message text body
    @Builder
    msgTextBody() {
        this.msgPhoneNumber()
        this.msgDateTime()
    }

    // message text body
    @Builder
    msgTextHeadIcon() {
        if (this.isShowHeadIcon) {
            // Message Head Icon
            this.msgHeadIcon();
        }
    }

    // sent successfully
    @Builder
    sentSuccessfully() {
        Text($r('app.string.message_send_failed'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontColor($r('sys.color.ohos_id_color_warning'))
            .maxLines(1)
            .align(Alignment.TopStart)
            .lineHeight(19)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .alignRules(this.fontSizeScale >= Constant.SENIOR_MODE_THREE ? {
                top: {anchor: 'name', align: VerticalAlign.Bottom},
                left: { anchor: 'name', align: HorizontalAlign.Start },
                right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                    : { anchor: '__container__', align: HorizontalAlign.End }
            } : {
                top: {anchor: 'name', align: VerticalAlign.Bottom},
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                left: { anchor: 'name', align: HorizontalAlign.Start },
                right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                    : { anchor: '__container__', align: HorizontalAlign.End }
            })
            .margin({
                end: this.getEndSpacing(),
                bottom: LengthMetrics.vp(this.fontSizeScale < Constant.SENIOR_MODE_THREE ? MARIGIN_TOP : 0)
            })
            .id('message_details_content')
    }

    private isUnPin(pinningTime: number): boolean {
        return pinningTime > 0;
    }

    private getEndSpacing(): LengthMetrics {
        let marginVp: LengthMetrics = LengthMetrics.vp(0);
        if (this.isUnPin(this.item.pinningTime)) {
            if (this.isShowHeadIcon) {
                marginVp = LengthMetrics.vp(MARIGIN_FORTY);
            } else {
                marginVp = LengthMetrics.vp(MARIGIN_TWENTY_FOUR);
            }
        } else {
            if (this.isShowHeadIcon) {
                marginVp = LengthMetrics.vp(MARIGIN_LEFT);
            }
        }
        return marginVp;
    }

    @Builder
    msgPinIcon() {
        SymbolGlyph($r('sys.symbol.arrowshape_up_to_line_fill'))
            .fontColor([$r('sys.color.icon_fourth')])
            .alignRules(this.fontSizeScale >= Constant.SENIOR_MODE_THREE ? {
                top: { anchor: 'message_details_content', align: VerticalAlign.Bottom },
                right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                    : { anchor: 'name', align: HorizontalAlign.End }
            } : {
                top: {anchor: 'name', align: VerticalAlign.Bottom},
                right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                    : { anchor: '__container__', align: HorizontalAlign.End }
            })
            .visibility(this.isUnPin(this.item.pinningTime) ? Visibility.Visible : Visibility.None)
            .id('pinning_time')
            .height(this.dateTimeHeight)
            .margin({
                top: LengthMetrics.vp((this.fontSizeScale < Constant.SENIOR_MODE_THREE) ? MARIGIN_2 : 0),
                end: LengthMetrics.vp(this.isMultipleSelectState && this.fontSizeScale < Constant.SENIOR_MODE_THREE ?
                    MARIGIN_LEFT : 0),
                bottom: LengthMetrics.vp((this.fontSizeScale < Constant.SENIOR_MODE_THREE) ? 0 : MARIGIN_TOP)
            })
    }

    // sent not successfully
    @Builder
    sentNotSuccessfully() {
        if (this.item.hasMms) {
            this.sendImageText()
        } else {
            this.sentText()
        }
    }

    @Builder
    sendImageText(){
        Text() {
            if (this.showCount) {
                Span($r('app.plural.mms_count', this.item.countOfUnread, this.item.countOfUnread))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            }
            if (this.item.isDisplayDraftText as boolean) {
                Span($r('app.string.draft'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('sys.color.ohos_id_color_warning'))
                Span(' ').fontSize(2)
            }
            Span(this.item.content)
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .align(Alignment.TopStart)
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .maxLines(this.fontSizeScale >= Constant.SENIOR_MODE_THREE ? 1 : 2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(19)
        .fontFeature('\"ss08\" 1')
        .alignRules(this.fontSizeScale >= Constant.SENIOR_MODE_THREE ? {
            top: {anchor: 'name', align: VerticalAlign.Bottom},
            left: { anchor: 'name', align: HorizontalAlign.Start },
            right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                : { anchor: '__container__', align: HorizontalAlign.End }
        } : {
            top: {anchor: 'name', align: VerticalAlign.Bottom},
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: 'name', align: HorizontalAlign.Start },
            right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                : { anchor: '__container__', align: HorizontalAlign.End }
        })
        .margin({
            end: this.getEndSpacing(),
            bottom: LengthMetrics.vp(this.fontSizeScale < Constant.SENIOR_MODE_THREE ? MARIGIN_TOP : 0)
        })
        .id('message_details_content')
    }

    @Builder
    sentText(){
        Text() {
            if (this.showCount) {
                Span($r('app.plural.mms_count', this.item.countOfUnread,
                    this.item.countOfUnread))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            }
            if (this.item.isDisplayDraftText as boolean) {
                Span($r('app.string.draft'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('sys.color.ohos_id_color_warning'))
                Span(' ').fontSize(2)
            }
            Span(this.replaceNewlineToBlank(this.item.content))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .align(Alignment.TopStart)
        .maxLines(this.fontSizeScale >= Constant.SENIOR_MODE_THREE ? 1 : 2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.BREAK_ALL)
        .lineHeight(19)
        .clip(true)
        .fontFeature('\"ss08\" 1')
        .alignRules(this.fontSizeScale >= Constant.SENIOR_MODE_THREE ? {
            top: { anchor: 'name', align: VerticalAlign.Bottom },
            left: { anchor: 'name', align: HorizontalAlign.Start },
            right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                : { anchor: '__container__', align: HorizontalAlign.End }
        } : {
            top: {anchor: 'name', align: VerticalAlign.Bottom},
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: 'name', align: HorizontalAlign.Start },
            right: this.isMultipleSelectState ? { anchor: 'checkbox', align: HorizontalAlign.Start }
                : { anchor: '__container__', align: HorizontalAlign.End }
        })
        .margin({
            end: this.getEndSpacing(),
            bottom: LengthMetrics.vp(this.fontSizeScale < Constant.SENIOR_MODE_THREE && this.fontSizeScale > 1 ?
                MARIGIN_TOP : 0)
        })
        .id('message_details_content')
    }
    // Checkbox
    @Builder
    multipleSelectStateBox() {
        Checkbox()
            .height(20)
            .width(20)
            .select(this.item.isCbChecked)
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .mark({ strokeColor: $r('sys.color.ohos_id_color_foreground_contrary') })
            .hitTestBehavior(HitTestMode.None)
            .onClick(() => {
                //新来信息导致列表isCbChecked刷新是item对应的isCbChecked对应的值,无法改变this.isCbChecked,需要更换this.item.isCbChecked刷新UI
                this.onClickCheckBox(this.item.index, !this.item.isCbChecked);
            })
            .id('checkbox')
            .accessibilityLevel('yes')
            .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                right: { anchor: '__container__', align: HorizontalAlign.End }
            })
            .margin({ start:LengthMetrics.vp(MARIGIN_LEFT), top:LengthMetrics.vp(MARIGIN_LEFT), bottom:LengthMetrics.vp(MARIGIN_LEFT),end:LengthMetrics.vp(MARIGIN_2)})
    }
    //多选菜单按钮
    @Builder mulButton() {
        MenuItem({ content: $r('app.string.select_more') })
            .height(DeviceUtil.isPC() ? 40 : '')
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
            .contentFontColor($r('sys.color.font_primary'))
            .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.select_more').id))
            .onClick(() => {
              // 在进入多选之前清空checkedStatus历史数据，防止存在脏数据，干扰后续
              this.mConListCtrl.checkedStatus.clear();
              setTimeout(() => {
              animateTo({
                curve: curves.interpolatingSpring(0, 1, 228, 30),
              }, () => {
                  this.menuMultSelect(this.item.index);
              });
              }, 850);
            })
            .align(Alignment.Center)
    }

    //置顶按钮
    @Builder pinButton() {
        MenuItem({ content: $r('app.string.msg_pin') })
            .height(DeviceUtil.isPC() ? MARIGIN_FORTY : '')
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
            .contentFontColor($r('sys.color.font_primary'))
            .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.msg_pin').id))
            .onClick(() => {
                this.menuPin(this.item.threadId, this.item.index);
                // 长按置顶打点
                stateParam.PIN_STATE = 0;
                DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LONGPRESS_PIN);
            })
            .align(Alignment.Center)
    }

    //取消置顶按钮
    @Builder unPinButton() {
        MenuItem({ content: $r('app.string.msg_unpin')})
            .height(DeviceUtil.isPC() ? MARIGIN_FORTY : '')
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
            .contentFontColor($r('sys.color.font_primary'))
            .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.msg_unpin').id))
            .onClick(() => {
                this.menuUnPin(this.item.threadId, this.item.index);
                // 长按取消置顶打点
                stateParam.PIN_STATE = 1;
                DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LONGPRESS_PIN);
            })
            .align(Alignment.Center)
    }

    //删除菜单按钮
    @Builder deleteButton() {
        MenuItem({ content: $r('app.string.delete') })
            .height(DeviceUtil.isPC() ? 40 : '')
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
            .contentFontColor($r('sys.color.font_primary'))
            .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.delete').id))
            .onClick(() => {
                setTimeout(() =>{
                    this.menuDelete(this.item.index);
                }, 300);
            })
            .align(Alignment.Center)
    }

    @Builder
    showDivider(){
        if (DeviceUtil.isPC()) {
            this.pcMultDivider()
        } else{
            this.multDivider()
        }
    }

    //设置未读or设置已读
    @Builder readOrUnReadButton() {
        MenuItem({ content: this.item.countOfUnread > 0 ? $r('app.string.read') :
            $r('app.string.un_read') })
            .height(DeviceUtil.isPC() ? MARIGIN_FORTY : '')
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
            .contentFontColor($r('sys.color.font_primary'))
            .accessibilityText(this.item.countOfUnread > 0 ?
            getContext(this).resourceManager.getStringSync($r('app.string.read').id) :
            getContext(this).resourceManager.getStringSync($r('app.string.un_read').id))
            .visibility((this.item.messageCount > 0 &&
                this.item.contactsNum <= 1) ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.menuReadOrUnRead(this.item, this.item.countOfUnread, this.item.telephone);
            })
            .align(Alignment.Center)
    }

    //线条
    @Builder
    multDivider(){
        Divider()
            .color($r('sys.color.comp_divider'))
            .lineCap(LineCapStyle.Square)
            .width(0)
            .alignSelf(ItemAlign.Stretch)
            .padding({ left: $r('app.float.conversation_item_press_Shadow_padding_left'), right: $r('app.float.conversation_item_press_Shadow_padding_left') })
    }
    @Builder
    pcMultDivider() {
        Row() {}
        .width('100%')
        .height(2)
    }

    //长按菜单按钮
    @Builder longPressMenuBuild() {
        Menu() {
            this.mulButton()
            this.showDivider()
            this.readOrUnReadButton();
            if (this.item.messageCount > 0 && this.item.contactsNum <= 1) {
                this.showDivider();
            }
            if (this.isUnPin(this.item.pinningTime)) {
                this.unPinButton()
            } else {
                this.pinButton()
            }
            this.showDivider()
            this.deleteButton()
        }
        .width(DeviceUtil.isPC() ? 160 : '224vp')
        .align(Alignment.Center)
    }
    //长按预览
    @Builder previewLongPress() {
        Column() {
            this.previewLongPressContent();
        }
        .height(this.fontSizeScale > 1 ? (this.fontSizeScale * 68) + 'vp' : '88vp')
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
        .borderRadius(20)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .accessibilityLevel('no-hide-descendants')
    }

    @Builder
    previewLongPressContent(){
        RelativeContainer() {
            this.msgTextHeadIcon()
            this.msgTextBody()
            // Content Abbreviations for Latest News
            // Whether the latest message has not been sent successfully. If yes,
            if (this.item.sendingFailed as boolean &&
                !(this.item.isDraft as boolean)) {
                this.sentSuccessfully()
            } else {
                this.sentNotSuccessfully()
            }
            this.msgPinIcon()
            if (this.isMultipleSelectState) {
                this.multipleSelectStateBox()
            }
        }
        .id(this.fatherView + this.item.index)
        .borderRadius({
            topRight: 16,
            bottomRight: 16,
        })
        .width('100%')
        .height('100%')
        .accessibilityText(AccessibilityUtil.getItemContext(this.item, this.context))
        .width('100%')
    }
}
