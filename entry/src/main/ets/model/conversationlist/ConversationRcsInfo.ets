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

export class ConversationRcsInfo {
  // Session list information
  // rcsId
  rcsId: number
  // SMS card slot id
  slotId: number
  // Mobile number for receiving SMS messages
  receiverNumber: string
  // Mobile number of the SMS message sender
  senderNumber: string
  // Start Sending Time
  startTime: number
  // Finished Sending Time
  endTime: string
  // message type
  rcsType: number
  // SM title
  msgTitle: string
  // Text of the SMS message
  msgContent: string
  // Sending status
  msgState: number
  // 0 - Not read,1 - Read by the peer end
  isRead: number
  // sessionId ID
  sessionId: number
  // groupId ID
  groupId: number
  // 0 is the receiver,1 is the receiver
  isSender: number
  // sdk Layer returned sms_id
  msgId: string
  // Integer
  enrichedCallingType: number
  // error code  Integer
  errorCode: number
  // network status  TEXT
  networkType: string
  // TEXT
  ownerAddr: string
  // privacy mode  Integer
  privacyMode: number
  // Integer
  protocol: number
  // Integer
  replyPathPresent: number
  // Visible or not  Integer
  seen: number
  // TEXT
  serviceCenter: string
  // TEXT
  serviceKind: string
  isCollect: number
  // TEXT
  isAdvancedSecurity: number
  receiveState: number
  failReceiveContext: string
  isReport: number
  //TEXT
  private detectResContent: string

  constructor(rcsId: number,
             slotId: number,
             receiverNumber: string,
             senderNumber: string,
             startTime: number,
             endTime: string,
             rcsType: number,
             msgTitle: string,
             msgContent: string,
             msgState: number,
             isRead: number,
             sessionId: number,
             groupId: number,
             isSender: number,
             msgId: string,
             enrichedCallingType: number,
             errorCode: number,
             networkType: string,
             ownerAddr: string,
             privacyMode: number,
             protocol: number,
             replyPathPresent: number,
             seen: number,
             serviceCenter: string,
             serviceKind: string,
             isCollect: number,
             isAdvancedSecurity: number,
             receiveState: number,
             failReceiveContext: string,
             isReport: number,
             detectResContent: string
  ) {
    this.rcsId=rcsId;
    this.slotId=slotId;
    this.receiverNumber=receiverNumber;
    this.senderNumber=senderNumber;
    this.startTime=startTime;
    this.endTime=endTime;
    this.rcsType=rcsType;
    this.msgTitle=msgTitle;
    this.msgContent=msgContent;
    this.msgState=msgState;
    this.isRead=isRead;
    this.sessionId=sessionId;
    this.groupId=groupId;
    this.isSender=isSender;
    this.msgId=msgId;
    this.enrichedCallingType=enrichedCallingType;
    this.errorCode=errorCode;
    this.networkType=networkType;
    this.ownerAddr=ownerAddr;
    this.privacyMode=privacyMode;
    this.protocol=protocol;
    this.replyPathPresent=replyPathPresent;
    this.seen=seen;
    this.serviceCenter=serviceCenter;
    this.serviceKind=serviceKind;
    this.isCollect=isCollect;
    this.isAdvancedSecurity=isAdvancedSecurity;
    this.receiveState=receiveState;
    this.failReceiveContext=failReceiveContext;
    this.isReport = isReport;
    this.detectResContent = detectResContent;
  }
}