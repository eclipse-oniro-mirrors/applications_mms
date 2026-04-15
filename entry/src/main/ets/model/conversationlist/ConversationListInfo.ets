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
import common, { MarkRead } from '../../data/commonData';
import AvatarColor from '../common/AvatarColor';

export class ConversationListInfo {
  // 会话列表信息
  // 数据id
  id: number
  // 最后一条短信时间
  time: number
  // 手机号
  telephone: string
  // 短信内容,用户会话列表短信文本展示
  content: string
  //收件人个数
  contactsNum: number
  // 短信类型 0:常规短信 1：通知消息
  smsType: number
  // 未读数
  unreadCount: number
  // 发送状态 0：Success ，1 ：Fail ， 2 ： Sending
  sendStatus: number
  // 是否有草稿  0： no， 1：have
  hasDraft: number
  // 当前会话短信个数
  messageCount: number
  // 是否有彩信 0： no， 1：have
  hasMms: number
  // Contacts id. e.g. 0,,1,2,3
  contactId: string
  // Contacts name e.g. Jack,Bob,10010
  contactName: string
  // 是否有附件 0： no， 1：have
  hasAttachment: number
  // 格式化后的电话号码
  telephoneFormat: string
  // 黄页Id
  public yellowPageId: string
  // 标识拦截类型
  public blockedType: number
  // 标识置顶时间戳
  public pinningTime: number

  constructor(id: number = 0,
    time: number = 0,
    telephone: string = '',
    content: string = '',
    contactsNum: number = 0,
    smsType: number = 0,
    unreadCount: number = 0,
    sendStatus: number = 0,
    hasDraft: number = 0,
    messageCount: number = 0,
    hasMms: number = 0,
    contactId: string = '',
    contactName: string = '',
    hasAttachment: number = 0,
    telephoneFormat: string = '',
    yellowPageId: string = '',
    blockedType: number = 0,
    pinningTime: number = 0) {
    this.id = id;
    this.time = time;
    this.telephone = telephone;
    this.content = content;
    this.contactsNum = contactsNum;
    this.smsType = smsType;
    this.unreadCount = unreadCount;
    this.sendStatus = sendStatus;
    this.hasDraft = hasDraft;
    this.messageCount = messageCount;
    this.hasMms = hasMms;
    this.contactId = contactId;
    this.contactName = contactName;
    this.hasAttachment = hasAttachment;
    this.telephoneFormat = telephoneFormat;
    this.yellowPageId = yellowPageId;
    this.blockedType = blockedType;
    this.pinningTime = pinningTime;
  }
}


export class ConversationListViewInfo {
  // 手机号
  public telephone: string
  // 短信内容,用户会话列表短信文本展示
  public content: string | Resource
  // 短信内容,用户会话列表短信文本展示
  public originContent: string
  //收件人个数
  public contactsNum: number
  // 当前会话短信个数
  public messageCount: number
  // 是否有彩信 0： no， 1：have
  public hasMms: boolean
  // Contacts id. e.g. 0,1,2,3
  public contactId: string
  // Contacts name e.g. Jack,Bob,10010
  public contactName: string
  //数据库中的原始DB数据
  public originNameFromDB: string
  public name: string
  // 格式化后的电话号码
  public telephoneFormat: string
  // 黄页Id
  public yellowPageId: string
  // 拦截类型
  public blockedType: number
  // 未读短信数
  public countOfUnread: number
  // 头像
  public icon: string
  // 信息类型
  public smsType: number
  // 默认不选择
  public isCbChecked: boolean
  // 是否发送失败
  public sendingFailed: boolean
  // 会话id
  public threadId: number
  // 会话最新更新时间，unix时间
  public timeMillisecond: number
  // 是否有草稿
  public isDraft: boolean
  // 是否展示[草稿]
  public isDisplayDraftText: boolean
  // 时间
  public time: string
  // 是否有附件
  public hasAttachment: boolean
  // 黄页头像
  public hasYellowPageIcon: string
  // 时间属性
  public detailTime: Resource | string | null
  // 条目时间
  public itemTime: Resource | string | null
  //背景色
  public portraitColor: Resource
  // 置顶时间戳
  public pinningTime: number

  constructor(session: ConversationListInfo) {
    this.name = common.STR.EMPTY_STR;
    this.originNameFromDB = session.contactName
    this.contactsNum = session.contactsNum;
    this.content = session.content;
    this.originContent = session.content
    this.countOfUnread = session.unreadCount;
    this.icon = session.smsType == common.sms_type.COMMON ? 'icon/user_avatar_full_fill.svg' :
      'icon/ic_bell_fill.svg';
    this.smsType = session.smsType;
    this.isCbChecked = false;
    this.sendingFailed = session.sendStatus == common.int.SEND_MESSAGE_FAILED ? true : false;
    this.telephone = session.telephone;
    this.telephoneFormat = session.telephoneFormat;
    this.threadId = session.id;
    this.timeMillisecond = session.time;
    this.isDraft = session.hasDraft > 0 ? true : false;
    this.isDisplayDraftText = session.hasDraft == 1 ? true : false;
    this.time = common.STR.EMPTY_STR;
    this.messageCount = session.messageCount;
    this.hasMms = session.hasMms == 1 ? true : false;
    this.contactId = session.contactId;
    this.contactName = session.contactName;
    this.hasAttachment = session.hasAttachment == 1 ? true : false;
    this.hasYellowPageIcon = common.STR.EMPTY_STR;
    this.yellowPageId = session.yellowPageId;
    this.blockedType = session.blockedType;
    this.detailTime = common.STR.EMPTY_STR
    this.itemTime = common.STR.EMPTY_STR
    this.portraitColor = AvatarColor.background.Color[session.id % 6];
    this.pinningTime = session.pinningTime;
  }
}