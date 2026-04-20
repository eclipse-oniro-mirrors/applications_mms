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
export class ComInfoModel {
  public pubLogoUrl: string = ''
  public pubName: string = ''
  public portNum: string = ''
  public isVip: boolean = false
  public isA2p: boolean = false
}

export enum NotificationType {
  NORMALMESSAGE = 0,  //普通消息
  HASYELLOWPAGEMESSAGE = 1, //有黄页的通知消息
  SERVICEACCOUNTMESSAGE = 2, //服务号通知消息
  OTHERNOTICMESSAGE = 3, //其他类通知消息
}

export class ContactInfoModel {
  public detailInfo: string = ''
  public displayName: string = ''
  public id: string = ''
  public rawContactId: string = ''
  public contactId: string = ''
}

export class MarkInfoContactModel {
  public markContent: string = ''
  public markSource: string = ''
  public markType: number = 0
  public isCloud: boolean = false
  public markDetails: string = ''
}