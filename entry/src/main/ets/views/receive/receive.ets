/**
 * Copyright (c) 2022-2024 Huawei Device Co., Ltd.
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
import ReceiveController from './receiveController';
import ConversationController, { BaseItemType } from '../../pages/conversation/conversationController';
import LooseObject from '../../data/LooseObject';
import i18n from '@ohos.i18n';
import { BusinessError } from '@ohos.base';
import HiLog from '../../utils/HiLog';
import inputMethod from '@ohos.inputMethod';
import {Highlight, HighlightsOptions, HighlightType } from '../../utils/Highlight';
import { Chip, ChipSize } from '@ohos.arkui.advanced.Chip';
import { ContactAvatar } from '../ContactAvatar';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { newPageListParams } from '../../utils/MmsDot/DotCommon';
import emitter from '@ohos.events.emitter';
import EmitterConstant from '../../data/EmitterConstant';
import TelephoneUtil from '../../utils/TelephoneUtil';
import DeviceUtil from '../../utils/DeviceUtil';
import common from '../../data/commonData';
import Configuration from '@system.configuration';
import { contact } from '@kit.ContactsKit';
import { Want } from '@kit.AbilityKit';
import lazy {SplitScreenManager,SplitInfoModel } from '../../utils/SplitScreenManager'
// import { AlignmentMode } from '@kit.SpeechKit';
import CreateNewConversationViewModle from '../../pages/conversation/CreateNewConversationViewModle';
import { DraftUtils } from '../../utils/DraftUtils';
import myCommon from '@ohos.app.ability.common'
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'Receive';
const MAX_SELECT_NUM = 100; //可选取的联系人最大数量

@Component
export struct Receive {
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    @Link mReceiveController: ReceiveController;
    @ObjectLink mCreateNewConversationViewModle: CreateNewConversationViewModle;
    @Link showMMContentPicker: boolean;
    @Link textareaFocusable: boolean;
    @StorageProp('messageAreaFocusFlag') @Watch('messageAreaFocusFlagChange') messageAreaFocusFlag:boolean = false;
    @State isInputStatus: boolean = true;
    scroller: Scroller = new Scroller();
    contactTextController:TextAreaController = new TextAreaController();
    private context = getContext(this) as myCommon.UIAbilityContext;
    @StorageLink('mReceiveControllerContacts') @Watch('receiveCtrlContactsChange') mReceiveControllerContacts: Array<LooseObject> = [];
    @StorageProp('isShowContactHeadIcon') isShowHead: boolean = true;
    @State contactsLength: number = 0;
    @State strSelectContact: string | Resource = '';
    private highLightUtil: Highlight = Highlight.getInstance();
    private searchValue: string = ''
    /* 设备是否为pad */
    @State isPad: boolean = false;
    @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
    @StorageLink('comeFromContact') mComeFromContact: boolean = false;
    @StorageLink('comeFromServiceaccess') mComeFromServiceaccess: boolean = false;
    @StorageLink('needToSaveDraft') @Watch('needToSaveDraftChange') needToSaveDraft: boolean = false;
    private needToSaveDraftForDisAppear: boolean = true;
    private textDirection: string = Configuration.getLocale().dir;
    @State isShowSheet: boolean = false;
    @State splitInfoModel: SplitInfoModel = SplitScreenManager.getInstance().infoModel;
    want: Want = {};
    private threadId: number = 0
    private contacts: number = 4;
    @State isShowSmsTips: boolean = false;
    @Prop isBeidouSatelliteMsg: boolean = false;
    @State contactsCount: number = 0;
    @State isVdeStatus?: boolean = false;

    aboutToAppear() {
        HiLog.i(TAG, 'aboutToAppear...');
        if (!this.context) {
            HiLog.w(TAG, 'Initialize getcontext is null!')
            this.context = getContext(this) as myCommon.UIAbilityContext;
            if (!this.context) {
                HiLog.e(TAG, 'retry getcontext failed,context is null!')
            }
        }
        let innerEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_IS_INPUT_STATUS,
        };
        emitter.on(innerEvent, (data) => {
            let isInputStatus: boolean = data.data!['isInputStatus'];
            let contactsLength: number = data.data!['contactsLength'];
            let strSelectContact: string | Resource = data.data!['strSelectContact'];
            this.isInputStatus = isInputStatus;
            this.contactsLength = contactsLength;
            this.strSelectContact = strSelectContact;
        })
        this.mReceiveController.onInit(this.context, (receiverData: BaseItemType) => {
            this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData, this.threadId);
        });
        this.mReceiveController.emitOnchangeInputStatus();
        this.mReceiveController.InputTextClear();
        this.isPad = DeviceUtil.isTablet();
    }

    aboutToDisappear() {
        HiLog.i(TAG, 'aboutToDisappear... ' + this.needToSaveDraftForDisAppear);
        let curBp: string = AppStorage.get('curBp') as string;
        if (!this.deleteSessionIsNeedHandleDraft()) {
            HiLog.i(TAG, 'delete session do not need save draft')
            return
        }
        if (!this.mCreateNewConversationViewModle.isSend && curBp !== common.STR.DEVICE_MOBILE_PHONE
            && this.needToSaveDraftForDisAppear && !this.isBeidouSatelliteMsg) {
            this.mCreateNewConversationViewModle.setDraftModel(() => {
                DraftUtils.getInstance().saveDraft(getContext(this))
            })
        }
    }

    needToSaveDraftChange() {
        HiLog.i(TAG, 'needToSaveDraftChange... ' + this.needToSaveDraftForDisAppear);
        this.needToSaveDraftForDisAppear = false;
        if (!this.deleteSessionIsNeedHandleDraft()) {
            HiLog.i(TAG, 'delete session do not need save draft')
            return
        }
        let curBp: string = AppStorage.get('curBp') as string;
        if (!this.mCreateNewConversationViewModle.isSend && curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            this.mCreateNewConversationViewModle.setDraftModel(() => {
                DraftUtils.getInstance().saveDraft(getContext(this));
            })
        }
    }

    // 适配删除session时，不走保存草稿路径
    deleteSessionIsNeedHandleDraft(): boolean {
        let deleteSessionThreadId: number = AppStorage.get('deleteSessionThreadId') ?? -1
        if (deleteSessionThreadId === this.threadId) {
            HiLog.i(TAG, 'deleteSessionThreadId is ' + deleteSessionThreadId + ' ,threadId is ' + this.threadId)
            AppStorage.setOrCreate('deleteSessionThreadId', -1)
            return false
        } else {
            return true
        }
    }

    receiveCtrlContactsChange() {
        this.mReceiveController.setContacts(this.mReceiveControllerContacts)
    }

    messageAreaFocusFlagChange() {
        this.mReceiveController.setIsShowSearch(false);
    }

    dynamicFormatPhoneForSearch(item: LooseObject): HighlightsOptions[] {
        let isPhoneNumber = TelephoneUtil.isPhoneNumber(item.telephoneFormat)
        if (!isPhoneNumber) {
            return item.phoneHighlights
        }
        let formatPhoneNumber = TelephoneUtil.formatDisplayPhoneNum(item.telephoneFormat)
        //去掉国家码后,在去掉空格的手机号
        let formatPhoneNoSpace = formatPhoneNumber.replace(new RegExp('[\\s]', 'g'), '')
        //没有去掉国家码,去掉空格后的手机号
        let telephoneFormatTem = (item.telephoneFormat as string).replace(new RegExp('[\\s]', 'g'), '')
        //由前面2个获取到国家码
        let countryRegion = telephoneFormatTem.replace(formatPhoneNoSpace, ' ')
        //根据获取到的国家码,加上空格,再放入格式化后的手机号formatPhoneNumber里面,此时国家码和手机号之间有正确的空格
        formatPhoneNumber = (countryRegion !== ' ' ? countryRegion : '') + formatPhoneNumber
        let spaceIndexes: number[] = []
        for (let i = 0; i < formatPhoneNumber.length; i++) {
            if (formatPhoneNumber.charAt(i) === ' ') {
                spaceIndexes.push(i)
            }
        }
        if (spaceIndexes.length <= 0) {
            return item.phoneHighlights
        }
        let currentIndex: number = 0;
        let spaceIndex: number = 0;
        let highlights: HighlightsOptions[] = []
        for (let i = 0; i < item.phoneHighlights.length; i++) {
            let text: string = item.phoneHighlights[i].text
            for (let j = 0; j < text.length; j++) {
                if ( (currentIndex + j) == spaceIndexes[spaceIndex]) {
                    text = text.slice(0, j) + ' ' + text.slice(j);
                    spaceIndex < spaceIndexes.length - 1 ?
                      spaceIndex += 1 : spaceIndex += 0
                }
            }
            currentIndex += text.length;
            highlights.push({
                text: text,
                type: item.phoneHighlights[i].type
            })
        }
        return highlights;
    }

    getChipTextContactName(item:LooseObject) : string {
        if (item) {
            if (item.contactName) {
                if (TelephoneUtil.isPhoneNumber(item.contactName) && item.telephoneFormat) {
                    return TelephoneUtil.dynamicFormatPhone(item.telephoneFormat);
                }
                return item.contactName;
            } else if (item.telephoneFormat) {
                return TelephoneUtil.dynamicFormatPhone(item.telephoneFormat);
            }
        }
        HiLog.e(TAG, 'receive info is Invalid,contactName and telephoneFormat is null')
        return common.STR.WHITE_SPACE;
    }

    build() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            Row() {
                Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
                    //新建信息-收件人
                    Text($r('app.string.putAddresser'))
                        .maxLines(1)
                        .fontSize(this.getMaxFontSizeScale() * 16 + 'vp')
                        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                        .fontWeight(FontWeight.Regular)
                        .fontFamily('HarmonyHeiTi')
                        .flexShrink(0)
                    Scroll(this.scroller) {
                        Flex({
                            wrap: FlexWrap.Wrap,
                            alignItems: ItemAlign.Center,
                            justifyContent: FlexAlign.Start,
                            alignContent: FlexAlign.Start
                        }) {
                            // If a contact is selected
                            if (this.isInputStatus) {
                                if (this.mReceiveController.selectContacts != null &&
                                    this.mReceiveController.selectContacts.length > 0) {
                                    ForEach(this.mReceiveController.selectContacts, (item:LooseObject, index:number) => {
                                        Row(){
                                            Chip({
                                                size: ChipSize.SMALL,
                                                label: {
                                                    text: (this.getChipTextContactName(item)) as string,
                                                    fontSize: `${this.getMaxFontSizeScale() * 12}vp`,
                                                    fontFamily:'HarmonyHeiTi'
                                                },
                                                allowClose: item?.select,
                                                onClose: () => {
                                                    this.mReceiveController.nameClick(index, (receiverData: BaseItemType) => {
                                                        this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                                                    }, (this.getChipTextContactName(item)) as string)
                                                },
                                                direction: Direction.Ltr
                                            })
                                        }
                                        .id(item.telephone)
                                        .onClick(() => {
                                            this.mReceiveController.nameClick(index, (receiverData: BaseItemType) => {
                                                HiLog.i(TAG, 'The chip is close or open' + JSON.stringify(item?.select));
                                                this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                                            }, (this.getChipTextContactName(item)) as string)
                                        })
                                        .margin({ right: 8, top: 4, bottom: 4 })
                                    }, (item:LooseObject) => JSON.stringify(item))
                                }
                            }
                            else if (!this.isInputStatus && this.contactsLength > 0) {
                                Text((typeof this.strSelectContact == 'string') && TelephoneUtil.isPhoneNumber(this.strSelectContact)
                                    ? TelephoneUtil.countryCodeFormatPhone(this.strSelectContact)
                                    : this.strSelectContact)
                                    .direction(Direction.Ltr)
                                    .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                                    .textAlign(TextAlign.Center)
                                    .fontSize(this.getMaxFontSizeScale() * 16 + 'vp')
                                    .fontWeight(FontWeight.Medium)
                                    .maxLines(1)
                                    .textAlign(this.textDirection === 'rtl' ? TextAlign.End : TextAlign.Start)
                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    .width('100%')
                                    .padding(this.textDirection === 'rtl' ?
                                        { right: 8} : { left: 8})
                                    .onClick(() => {
                                        this.mReceiveController.myContactClick(this.scroller);
                                        setTimeout(() =>{
                                            sendEventByKey('receivedContactTextArea', 10, '');
                                        }, 100);
                                    })
                            }
                            if ((!this.isInputStatus && this.contactsLength == 0) || this.isInputStatus) {
                                this.contactTextArea()
                            }
                        }
                        .flexShrink(1)
                        .id('ContactFlex')
                        .padding({ bottom: 4, top: 4 })
                    }
                    .scrollable(ScrollDirection.Vertical)
                    .flexShrink(1)
                    .scrollBar(this.splitInfoModel.isMediumAndSmall ? BarState.Off : BarState.Auto )
                    .padding({ bottom: 1, top: 1 })

                // Contact icon on the right
                    Button(){
                        SymbolGlyph($r('sys.symbol.person_2'))
                            .width(24)
                            .height(24)
                            .fontSize('24vp')
                            .draggable(false)
                            .id('moreContactButton')
                            .fontColor([$r('sys.color.ohos_id_color_primary')])
                    }
                    .type(ButtonType.Normal)
                    .align(Alignment.Center)
                    .width(40)
                    .height(40)
                    .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.select_contacts_button').id))
                    .flexShrink(0)
                    .stateStyles({
                        normal:{
                            .backgroundColor(Color.Transparent)
                        },
                        pressed:{
                            .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
                            .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
                        }
                    })
                    .onClick(() => {
                        AppStorage.setOrCreate('isSelectContactsFromPickUp', true);
                        // When user selects a contact after open the keyboard, the keyboard stops responding.
                        // So we close keyboard before.
                        if (canIUse('SystemCapability.MiscServices.InputMethodFramework')) {
                            inputMethod.getController().hideTextInput();
                        }
                        AppStorage.setOrCreate('isSelectContactsFromPickDone', false);
                        contact.selectContacts({
                            isMultiSelect: true,
                            maxSelectable: MAX_SELECT_NUM,
                            filter: {
                                filterClause: {
                                    dataItem: {
                                        field: contact.DataField?.PHONE || 1,
                                        options: [{
                                            filterCondition: contact.FilterCondition?.IS_NOT_NULL || 0
                                        }],
                                    }
                                },
                                filterType: contact.FilterType?.SHOW_FILTER || 0
                            }
                        }, (err: BusinessError, data) => {
                            if (err) {
                                HiLog.e(TAG, `selectContact callback: err->${JSON.stringify(err)}`);
                                return;
                            }
                            HiLog.i(TAG, 'selectContact callback: success');
                            this.mReceiveController.batchSelectContactForResult(data, (receiverData: BaseItemType) => {
                                this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                                AppStorage.setOrCreate('isSelectContactsFromPickDone', true);
                            }, this.isBeidouSatelliteMsg)
                            AppStorage.setOrCreate('isSelectContactsFromPickUp', false);
                        });
                        // 新建收件人——进入联系人列表打点
                        newPageListParams.STATE = 2;
                        DotUtil.getInstance().reportEvent(newPageListParams, dotCommon.eventName.NEWPAGE_INPUT);
                    })
                }
                .constraintSize({ minHeight: 56, maxHeight: this.splitInfoModel.isMediumAndSmall ? 56 :
                    this.isVdeStatus ? 88 : 124 })
                .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
                .padding({
                    start: LengthMetrics.vp(12),
                    bottom: 4,
                    top: 4,
                    end: LengthMetrics.vp(4)
                })
            }
            .padding({left: this.handlePaddingInDiffDevice('left'), right: this.handlePaddingInDiffDevice('right')})

            Stack() {
                Column() {
                    Row(){
                        Text($r('app.string.beidou_sms_tips'))
                            .fontFamily('HarmonyHeiTi')
                            .fontSize(16)
                            .fontColor($r('sys.color.ohos_id_color_primary'))
                            .lineHeight(21)
                            .textAlign(TextAlign.Start)
                            .fontWeight(FontWeight.Medium)
                            .padding({left: 12})
                            .maxFontScale(1.45)
                        SymbolGlyph($r('sys.symbol.xmark'))
                            .width(20)
                            .height(20)
                            .draggable(false)
                            .fontColor([$r('sys.color.ohos_id_color_primary')])
                            .fontWeight(FontWeight.Medium)
                            .position({ end: LengthMetrics.vp(12), top: LengthMetrics.vp(0) })
                            .fontSize($r('app.float.action_bar_text_size'))
                            .onClick(() => {
                                this.isShowSmsTips = true;
                            })
                    }
                    .padding({top: 16})
                    .width('100%')
                    Row() {
                        Image('')
                            .width(4)
                            .height(4)
                            .borderRadius(2)
                            .backgroundColor($r('sys.color.icon_secondary'))
                        Text($r('app.plural.every_satellite_worried', this.contacts, this.contacts))
                            .fontFamily('HarmonyHeiTi')
                            .fontSize(12)
                            .fontColor($r('sys.color.ohos_id_color_primary'))
                            .fontWeight(FontWeight.Regular)
                            .lineHeight(16)
                            .textAlign(TextAlign.Start)
                            .padding({left: 10, right: 4})
                            .maxLines(1)
                            .maxFontScale(1.45)
                    }
                    .width('100%')
                    .padding({left: 14, top: 12})
                    Row() {
                        Image('')
                            .width(4)
                            .height(4)
                            .borderRadius(2)
                            .backgroundColor($r('sys.color.icon_secondary'))
                            .position({ start: LengthMetrics.vp(0), top: LengthMetrics.vp(6) })
                        Text($r('app.string.send_character_prompt'))
                            .fontFamily('HarmonyHeiTi')
                            .fontSize(12)
                            .fontColor($r('sys.color.ohos_id_color_primary'))
                            .fontWeight(FontWeight.Regular)
                            .lineHeight(16)
                            .textAlign(TextAlign.Start)
                            .padding({left: 14, right: 16})
                            .maxLines(2)
                            .maxFontScale(1.45)
                    }
                    .width('100%')
                    .padding({left: 14, top: 8, bottom: 12})
                }
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .borderRadius(24)
            }
            .padding({ left: DeviceUtil.isPC() ? 24 : 16, right: DeviceUtil.isPC() ? 24 : 16, top: 12 })
            .width('100%')
            .visibility(this.isBeidouSatelliteMsg && !this.isShowSmsTips ? Visibility.Visible : Visibility.None)

            Column() {
                if (this.mReceiveController.isShowSearch && this.mReceiveController.contacts.length > 0 &&
                    this.mReceiveController.myText.length > 0) {
                    List({ space: 0, initialIndex: 0 }) {
                        ForEach(this.mReceiveController.contacts, (item: LooseObject, index: number) => {
                            this.receiveItem(item, index)
                        }, (item: LooseObject) => JSON.stringify(item))

                    }
                    .margin({ top: 8 })
                    .padding({
                        left: this.isPad || DeviceUtil.isPC() ? 8 : 0,
                        right: this.isPad || DeviceUtil.isPC() ? 8 : 0,
                    })
                    .listDirection(Axis.Vertical) // Arrange Direction
                    .height('100%')
                    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true }) // Sliding to the edge has no effect
                    .divider({
                        strokeWidth: $r('app.float.settings_divider_strokeWidth'),
                        startMargin: this.isShowHead ? 72 : 16,
                        endMargin: $r('sys.float.margin_right'),
                        color: $r('sys.color.ohos_id_color_list_separator')
                    }) // Demarcation line between each row
                    .onTouch((event: TouchEvent) => {
                        this.contactTextController.stopEditing();
                        if (event.type === TouchType.Down) {
                            newPageListParams.STATE = 1;
                            DotUtil.getInstance().reportEvent(newPageListParams, dotCommon.eventName.NEWPAGE_INPUT);
                        }
                    })
                    .onScrollStart(() => {
                        this.contactTextController.stopEditing();
                    })
                } else {
                    List()
                        .onTouch(() => {
                            if (AppStorage.get('keyboardHeight') as number > 0) {
                                this.contactTextController.stopEditing();
                                this.textareaFocusable = false;
                            }
                        })
                        .height('100%')
                }
            }
            .layoutWeight(1)
        }
        .width('100%')
    }

    private handlePaddingInDiffDevice = (direction: string) => {
        if (direction === 'right') {
            return this.isPad ? this.padMargin : DeviceUtil.isPC() ? '24' : $r('sys.float.margin_right')
        }
        if (direction === 'left') {
            return this.isPad ? this.padMargin : DeviceUtil.isPC() ? '24' : $r('sys.float.margin_left')
        }
        return $r('sys.float.margin_left')
    }

    @Builder
    receivePhoneNumber(item: LooseObject) {
        Text() {
            ForEach(this.dynamicFormatPhoneForSearch(item),
                (i: HighlightsOptions) => {
                    Span(i.text)
                        .fontColor(i.type == HighlightType.highlight
                            ? $r('sys.color.ohos_id_color_text_primary_activated')
                            : $r('sys.color.ohos_id_color_text_secondary'))
                })
        }
        .direction(Direction.Ltr)
        .lineHeight(19)
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .maxLines(1)
        .width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(this.textDirection === 'rtl' ? TextAlign.End : TextAlign.Start)
    }

    @Builder
    receiveContent(item: LooseObject, index: number) {
        Flex({
            direction: FlexDirection.Column,
            justifyContent: FlexAlign.Center,
            alignItems: ItemAlign.Start
        }) {
            if (item.contactName != '' || item.contactName != null) {
                this.receiveContactName(item)
            }
            Row().height(2).width('100%')
            if (item.phoneHighlights?.length > 0) {
                this.receivePhoneNumber(item)
            } else {
                Text(item.primary ?
                $r('app.string.default_recent', TelephoneUtil.nationalFormatNumber(item.telephoneFormat)) :
                TelephoneUtil.nationalFormatNumber(item.telephoneFormat))
                    .lineHeight(19)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontWeight(FontWeight.Regular)
                    .maxLines(1)
                    .width('100%')
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
        }
        .layoutWeight(1)
        .margin(this.textDirection === 'rtl' ?
            { right: DeviceUtil.isPC() ? 8 : this.isShowHead ? 16 : 0 } :
            { left: DeviceUtil.isPC() ? 8 : this.isShowHead ? 16 : 0 })
        .onClick(() => {
            this.mReceiveController.addContact(index, (receiverData: BaseItemType) => {
                this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                this.scroller.scrollEdge(Edge.Bottom);
                setTimeout(() => {
                    sendEventByKey('receivedContactTextArea', 10, '');
                }, 100);
            }, this.isBeidouSatelliteMsg)
        })
    }

    @Builder
    receiveContactName(item: LooseObject) {
        if (item.nameHighlights && item.nameHighlights.length > 0) {
            Text() {
                ForEach(item.nameHighlights, (i: HighlightsOptions) => {
                    Span(i.text)
                        .fontColor(i.type == HighlightType.highlight
                            ? $r('sys.color.ohos_id_color_text_primary_activated')
                            : $r('sys.color.ohos_id_color_text_primary'))
                })
            }
            .fontFamily('HarmonyHeiTi')
            .lineHeight(22)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .maxLines(1)
            .margin({ bottom: 2 })
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        } else {
            Text(TelephoneUtil.nationalFormatNumber(item.contactName))
                .lineHeight(22)
                .fontFamily('HarmonyHeiTi')
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .maxLines(1)
                .margin({ bottom: 2 })
                .fontWeight(FontWeight.Medium)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
        }
    }

    @Builder
    receiveHeader(item: LooseObject, index: number) {
        if (this.isShowHead) {
            ContactAvatar({
                rawContactId: item.rawContactId,
                contactId: item.contactId,
                firstPhotoName: item.photoFirstName,
                portraitColor: item.portraitColor
            }).onClick(() => {
                this.mReceiveController.titleBarAvatar(index)
            })
        }
    }

    @Builder
    receiveItem(item: LooseObject, index: number) {
        ListItem() {
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                this.receiveHeader(item, index)
                this.receiveContent(item, index)
            }
            .width('100%')
            .height((this.fontSizeScale * 64) + 'vp')
            .padding({ left: 8, right: 8 })
        }
        .padding({ left: 8, right: 8 })
        .stateStyles({
            pressed: this.pressedStyles,
            normal: this.normalStyles
        })
    }

    @Builder
    contactText(contactString: string | Resource) {
        Text(contactString)
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('sys.float.ohos_id_text_size_button3'))
            .flexShrink(1)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
    }

    @Builder
    contactTextArea() {
        TextArea({ text: this.mReceiveController.myText, controller: this.contactTextController } as TextAreaOptions)
            .padding({left:8})
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .backgroundColor(Color.Transparent)
            .defaultFocus(this.isFocus())
            .enableKeyboardOnFocus(true)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .constraintSize({maxHeight:110, maxWidth:'100%', minWidth:'50vp'})
            .id('receivedContactTextArea')
            .focusable(true)
            .flexGrow(1)
            .direction(Direction.Ltr)
            .onChange((value) => {
                HiLog.i(TAG, 'onChange_onChange')
                this.searchValue = value;
                if (!this.scroller.isAtEnd()) {
                    this.scroller.scrollEdge(Edge.Bottom);
                }
                if (value.endsWith(',') && !this.mReceiveController.isAllCommas(value) &&
                    !value.slice(0, -1).includes(',')) {
                    HiLog.i(TAG, 'contact is end with , trans into contact')
                    this.mReceiveController.checkReceive((receiverData: BaseItemType) => {
                        this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                        this.scroller.scrollEdge(Edge.Bottom);
                        setTimeout(() => {
                            sendEventByKey('receivedContactTextArea', 10, '');
                        }, 100);
                    }, this.isBeidouSatelliteMsg, true);
                } else if (value.slice(0, -1).includes(',') && !this.mReceiveController.isAllCommas(value)) {
                    HiLog.i(TAG, 'contact is includes , trans it')
                    let remaining = value;
                    let index = 0;
                    while (remaining.length > 0) {
                        let current = remaining.split(',')[0].trim();
                        remaining = remaining.split(',').slice(1).join(',');
                        this.mReceiveController.myText = current
                        this.mReceiveController.checkReceive((receiverData: BaseItemType) => {
                            receiverData.contactValue = remaining
                            this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                            this.scroller.scrollEdge(Edge.Bottom);
                            setTimeout(() => {
                                sendEventByKey('receivedContactTextArea', 10, '');
                            }, 100);
                        }, this.isBeidouSatelliteMsg, true);
                    }
                } else {
                    HiLog.i(TAG, 'contact not is end with , keep format')
                    if (this.mReceiveController.isAllCommas(value)) {
                        value = ''
                    }
                    this.mReceiveController.searchChange(value,this.context, (receiverData: BaseItemType) => {
                        this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                        newPageListParams.NUMBER_STATUS = receiverData.selectContacts.length + 1 >= 2 ? 2 : 1;
                    }, this.contactTextController);
                }
            })
            .onFocus(() => {
                this.mReceiveController.isHideTextArea = true;
                this.contactTextAreaOnFocus();
            })
            .onBlur(() => {
                this.mReceiveController.isHideTextArea = false;
            })
            .enterKeyType(EnterKeyType.Done)
            .onSubmit(async (enterKey: EnterKeyType, event: SubmitEvent) => {
                HiLog.i(TAG, 'onSubmit');
                event.keepEditableState()
                await this.mReceiveController.checkReceive((receiverData: BaseItemType) => {
                    this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                    this.scroller.scrollEdge(Edge.Bottom);
                    setTimeout(() => {
                        sendEventByKey('receivedContactTextArea', 10, '');
                    }, 100);
                }, this.isBeidouSatelliteMsg, true);
            })
            .onDidDelete(() => {
                HiLog.i(TAG, 'onDidDelete')
                let timeoutId = setTimeout(() =>{
                    clearTimeout(timeoutId);
                    if (this.mReceiveController.myText === common.STR.EMPTY_STR) {
                        this.mReceiveController.deleteContactItem((receiverData: BaseItemType) => {
                            this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
                        })
                    }
                }, 50);
            })
    }

    contactTextAreaOnFocus() {
        HiLog.i(TAG, 'When the focus is obtained, the candidate box must be displayed.')
        this.mReceiveController.isShowSearch = true;
        this.mReceiveController.setInputStatus(true);
    }

    private isFocus() {
        if (this.mReceiveController.myText === '' && this.mReceiveController.selectContacts.length === 0) {
            return true
        } else {
            return false
        }
    }

    private getMaxFontSizeScale(): number {
        return this.fontSizeScale <= 2 ? this.fontSizeScale : 2;
    }
    @Styles
    pressedStyles() {
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        .borderRadius(0)
        .opacity(1)
    }
    @Styles
    normalStyles() {
        .backgroundColor('#00000000')
        .borderRadius(0)
        .opacity(1)
    }
}
