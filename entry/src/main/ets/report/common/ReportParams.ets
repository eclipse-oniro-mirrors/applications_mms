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

/**
 * Parameters required for SMS reported
 */
export interface SmsReportParams {
  senderNum: string,
  startTime: number,
  msgStr: string
}

/**
 * Parameters required for SMS report
 */
export interface ReportSmsContentFailParam {
  senderNumber: string,
  reportContent: string,
  reportDuration: number,
  reportFailReason: number
}

/**
 * SmsContent report connect cloud request message body
 */
export interface SmsContentReportRequestInfo {
  appId: string,
  eventTimestamp: number,
  textMsg: string,
  senderNumber: string,
  receiverId: string,
  ip: string,
  deviceType: string
}

export interface RequestHeader {
  params: RequestHeaderParam[];
}

export interface RequestHeaderParam {
  name: string;
  value: string;
}

export interface ConnectCloudRequestParam {
  method: string;
  path: string;
  headers: RequestHeader;
  body?: string;
  connectTimeout?: number;
  readTimeout?: number;
}

export interface ConnectCloudResponseParam {
  httpStatus: number,
  headers: string,
  body: string
}

export interface UcsRequestParam {
  method: number;
  data: string;
  iv?: string;
  transId?: string;
  signature?: string;
}

/**
 * ucs encryption or signature response result
 */
export interface UcsResponseParam {
  data: string,
  iv: string,
  ak: string
}