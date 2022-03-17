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
import HiLog from './HiLog';

const TAG = 'AppStorageUtil';
export default class AppStorageUtil {
  constructor() {
    this.initData()
  }
  /**
   *  是否展示通知信息
   *
   * @param hasInfoMsg 是否展示通知信息
   */
  static setHasInfoMsg(hasInfoMsg) {
    AppStorage.SetOrCreate('hasInfoMsg', hasInfoMsg);
  }

  /**
   * 是否展示通知信息
   *
   * @return dragItemInfo 是否展示通知信息
   */
  static getHasInfoMsg() {
    let globalData: boolean = AppStorage.Get('hasInfoMsg');
    return globalData;
  }


  /**
   *  full_screen_show_picture页面中图片或视频的index
   *
   * @param indexInShowPicPage
   */
  static setIndexInShowPicPage(indexInShowPicPage) {
    AppStorage.SetOrCreate('indexInShowPicPage', indexInShowPicPage);
  }

  /**
   * full_screen_show_picture页面中图片或视频的index
   *
   * @return indexInShowPicPage
   */
  static getIndexInShowPicPage() {
    let indexInShowPicPage: any = AppStorage.Get('indexInShowPicPage');
    return indexInShowPicPage;
  }


  /**
   *  full_screen_show_picture页面中图片或视频的checkbox的值
   *
   * @param checkedValueInShowPicPage
   */
  static setCheckedValueInShowPicPage(checkedValueInShowPicPage) {
    AppStorage.SetOrCreate('checkedValueInShowPicPage', checkedValueInShowPicPage);
  }

  /**
   * full_screen_show_picture页面中图片或视频的checkbox的值
   *
   * @return checkedValueInShowPicPage
   */
  static getCheckedValueInShowPicPage() {
    let checkedValueInShowPicPage: any = AppStorage.Get('checkedValueInShowPicPage');
    return checkedValueInShowPicPage;
  }

  /**
   *  contact_item_pick页面中的电话号码列表
   *
   * @param oneContactInContactItemPickPage
   */
  static setOneContactInContactItemPickPage(oneContactInContactItemPickPage) {
    AppStorage.SetOrCreate('oneContactInContactItemPickPage', oneContactInContactItemPickPage);
  }

  /**
   * contact_item_pick页面中的电话号码列表
   *
   * @return oneContactInContactItemPickPage
   */
  static getOneContactInContactItemPickPage() {
    let oneContactInContactItemPickPage: any = AppStorage.Get('oneContactInContactItemPickPage');
    return oneContactInContactItemPickPage;
  }

  /**
   *  全屏发送值
   *
   * @param textValueOther
   */
  static setTextValueOther(textValueOther) {
    AppStorage.SetOrCreate('textValueOther', textValueOther);
  }

  /**
   * 全屏发送值
   *
   * @return textValueOther
   */
  static getTextValueOther() {
    let textValueOther: string = AppStorage.Get('textValueOther');
    return textValueOther;
  }

  /**
   *  全屏发送标记
   *
   * @param sendFlag
   */
  static setSendFlag(sendFlag) {
    AppStorage.SetOrCreate('sendFlag', sendFlag);
  }

  /**
   * 全屏发送标记
   *
   * @return sendFlag
   */
  static getSendFlag() {
    let sendFlag: boolean = AppStorage.Get('sendFlag');
    return sendFlag;
  }


  /**
   *  转发发送的标记
   *
   * @param transmitFlag
   */
  static setTransmitFlag(transmitFlag) {
    AppStorage.SetOrCreate('transmitFlag', transmitFlag);
  }

  /**
   * 转发发送的标记
   *
   * @return transmitFlag
   */
  static getTransmitFlag() {
    let transmitFlag: boolean = AppStorage.Get('transmitFlag');
    return transmitFlag;
  }

  /**
   *  转发内容
   *
   * @param transmitContent
   */
  static setTransmitContent(transmitContent) {
    AppStorage.SetOrCreate('transmitContent', transmitContent);
  }

  /**
   * 转发内容
   *
   * @return transmitContent
   */
  static getTransmitContent() {
    let transmitContent: string = AppStorage.Get('transmitContent');
    return transmitContent;
  }


  /**
   *  转发的内容包含彩信
   *
   * @param transmitContents
   */
  static setTransmitContents(transmitContents) {
    AppStorage.SetOrCreate('transmitContents', transmitContents);
  }

  /**
   * 转发的内容包含彩信
   *
   * @return transmitContents
   */
  static getTransmitContents() {
    let transmitContents: any = AppStorage.Get('transmitContents');
    return transmitContents;
  }

  /**
   *
   *
   * @param isSlideDetail
   */
  static setIsSlideDetail(isSlideDetail) {
    AppStorage.SetOrCreate('isSlideDetail', isSlideDetail);
  }

  /**
   *
   *
   * @return isSlideDetail
   */
  static getIsSlideDetail() {
    let isSlideDetail: boolean = AppStorage.Get('isSlideDetail');
    return isSlideDetail;
  }

  /**
   *
   *
   * @param mmsSource
   */
  static setMmsSource(mmsSource) {
    AppStorage.SetOrCreate('mmsSource', mmsSource);
  }

  /**
   *
   *
   * @return mmsSource
   */
  static getMmsSource() {
    let mmsSource: any = AppStorage.Get('mmsSource');
    return mmsSource;
  }

  /**
   *
   *
   * @param transmitSource
   */
  static setTransmitSource(transmitSource) {
    AppStorage.SetOrCreate('transmitSource', transmitSource);
  }

  /**
   *
   *
   * @return transmitSource
   */
  static getTransmitSource() {
    let sendFlag: any = AppStorage.Get('transmitSource');
    return sendFlag;
  }

  /**
   *
   *
   * @param isContainerOriginSource
   */
  static setIsContainerOriginSource(isContainerOriginSource) {
    AppStorage.SetOrCreate('isContainerOriginSource', isContainerOriginSource);
  }

  /**
   *
   *
   * @return isContainerOriginSource
   */
  static getIsContainerOriginSource() {
    let isContainerOriginSource: boolean = AppStorage.Get('isContainerOriginSource');
    return isContainerOriginSource;
  }
  /**
   *  卡的槽位
   *
   * @param slotId
   */
  static setSlotId(slotId) {
    AppStorage.SetOrCreate('slotId', slotId);
  }

  /**
   * 卡的槽位
   *
   * @return slotId
   */
  static getSlotId() {
    let slotId: number = AppStorage.Get('slotId');
    return slotId;
  }
  /**
   *  列表Id
   *
   * @param threadId
   */
  static setThreadId(threadId) {
    AppStorage.SetOrCreate('threadId', threadId);
  }

  /**
   * 列表Id
   *
   * @return threadId
   */
  static getThreadId() {
    let threadId: string = AppStorage.Get('threadId');
    return threadId;
  }
  /**
   *  联系人数量
   *
   * @param contactsNum
   */
  static setContactsNum(contactsNum) {
    AppStorage.SetOrCreate('contactsNum', contactsNum);
  }

  /**
   * 联系人数量
   *
   * @return contactsNum
   */
  static getContactsNum() {
    let contactsNum: number = AppStorage.Get('contactsNum');
    return contactsNum;
  }
  /**
   *  联系人名称
   *
   * @param strContactsName
   */
  static setStrContactsName(strContactsName) {
    AppStorage.SetOrCreate('strContactsName', strContactsName);
  }

  /**
   * 联系人名称
   *
   * @return strContactsName
   */
  static getStrContactsName() {
    let strContactsName: string = AppStorage.Get('strContactsName');
    return strContactsName;
  }
  /**
   *  联系人号码
   *
   * @param strContactsNumber
   */
  static setStrContactsNumber(strContactsNumber) {
    AppStorage.SetOrCreate('strContactsNumber', strContactsNumber);
  }

  /**
   * 联系人号码
   *
   * @return strContactsNumber
   */
  static getStrContactsNumber() {
    let strContactsNumber: string = AppStorage.Get('strContactsNumber');
    return strContactsNumber;
  }
  /**
   *  格式化联系人号码
   *
   * @param strContactsNumberFormat
   */
  static setStrContactsNumberFormat(strContactsNumberFormat) {
    AppStorage.SetOrCreate('strContactsNumberFormat', strContactsNumberFormat);
  }

  /**
   * 格式化联系人号码
   *
   * @return strContactsNumberFormat
   */
  static getStrContactsNumberFormat() {
    let strContactsNumberFormat: string = AppStorage.Get('strContactsNumberFormat');
    return strContactsNumberFormat;
  }

  /**
   *  是否从全屏界面回来
   *
   * @param isFromFullScreen
   */
  static setIsFromFullScreen(isFromFullScreen) {
    AppStorage.SetOrCreate('isFromFullScreen', isFromFullScreen);
  }

  /**
   * 是否从全屏界面回来
   *
   * @return isFromFullScreen
   */
  static getIsFromFullScreen() {
    let isFromFullScreen: boolean = AppStorage.Get('isFromFullScreen');
    return isFromFullScreen;
  }

  /**
   *  是否从全屏界面回来
   *
   * @param isFromFullScreen
   */
  static setPreferences(preferences) {
    AppStorage.SetOrCreate('preferences', preferences);
  }

  /**
   *  保存状态到AppStorage，和组件建立双向数据绑定
   *
   * @param propName 键
   * @param defaultValue 值
   */
  static setAndLink(propName, defaultValue) {
    AppStorage.SetAndLink(propName, defaultValue);
  }

  /**
   *  保存状态到AppStorage，和组件建立双向数据绑定
   *
   * @param propName 键
   * @param defaultValue 值
   */
  static Link(propName) {
    return AppStorage.Link(propName);
  }

  /**
   * 是否从全屏界面回来
   *
   * @return isFromFullScreen
   */
  static getPreferences() {
    let preferences = AppStorage.Get('preferences');
    return preferences;
  }

  initData(){
    AppStorageUtil.setHasInfoMsg(true)
    AppStorageUtil.setIndexInShowPicPage(undefined)
    AppStorageUtil.setCheckedValueInShowPicPage(undefined)
    AppStorageUtil.setOneContactInContactItemPickPage(undefined)
    AppStorageUtil.setTextValueOther('')
    AppStorageUtil.setSendFlag(false)
    AppStorageUtil.setTransmitFlag(false)
    AppStorageUtil.setTransmitContent('')
    AppStorageUtil.setTransmitContents([])
    AppStorageUtil.setIsSlideDetail(false)
    AppStorageUtil.setMmsSource([])
    AppStorageUtil.setTransmitSource([])
    AppStorageUtil.setIsContainerOriginSource(false)
    AppStorageUtil.setSlotId(0)
    AppStorageUtil.setThreadId('')
    AppStorageUtil.setContactsNum(0)
    AppStorageUtil.setStrContactsName('')
    AppStorageUtil.setStrContactsNumber('')
    AppStorageUtil.setStrContactsNumberFormat('')
    AppStorageUtil.setIsFromFullScreen(false)
  }
}