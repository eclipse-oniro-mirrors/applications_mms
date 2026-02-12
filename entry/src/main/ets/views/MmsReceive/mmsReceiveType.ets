/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

export interface a {
  value1: string
  value2: string
}

export interface b {
  key1: number
  key2: number
}

export interface DataParameters {
  bundleName: string;
  code: number;
  data: string;
  event: string;
  parameters: BaseDataParameters;
}

export interface BaseDataParameters {
  action: string;
  isCdma: boolean;
  isNotificationFlag: boolean;
  isShow: boolean;
  moduleName: string;
  pdus: string[];
  slotId: number;
  id: number;
  telephone: string;
}


export interface mmsRecDataType {
  event: string
  bundleName: string
  code: number,
  data: string
  parameters: mmsRecParameters
}

export interface mmsRecParameters {
  applicationId: string
  contentType: string
  headerData: string
  moduleName: string
  pushType: number,
  rawData: string
  slotId: number,
  transactionId: number,
}

export interface fileData {
  fileType: string
  path: string
  fd?: number
  name?: string
  content?: string
}

export interface decodeMMs {
  phone: string
  fileList: Array<fileData>
  msgContent: string,

}
export interface mmsToSqlDataType extends decodeMMs{
  slotId:number
}

// export interface mmsDecodeDataType {
//   messageType: number,
//   mmsType: mms.MmsNotificationInd
// }

// export interface mmsDecodeDataTypeType {
//   "transactionId": string
//   "messageClass": number,
//   "messageSize": number,
//   "expiry": number,
//   "version": number,
//   "from": mmsDecodeDataTypeFromType
//   "subject": string
//   "deliveryReport": number,
//   "contentLocation": string
//   "contentClass": number,
// }
// export interface mmsDecodeDataTypeFromType{
//   "address": string
//   "charset": number,
// }

export interface c extends a, b {}

let d: c = {
  value1: '1',
  value2: '2',
  key1: 3,
  key2: 4
}