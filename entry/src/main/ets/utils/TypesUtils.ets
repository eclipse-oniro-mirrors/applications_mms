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
import { ChatbotParameters } from '../chatbot/utils/ChatbotEntitys';
import LooseObject from '../data/LooseObject';
import dateUtil from './DateUtil';
import { ContactInfo } from './Contact'
import { Expose } from 'class-transformer';

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
  mobilePhoneNumber: string;
  msgId:string
  type:string
  code?: number;
  status: string
  clurSize: number
  totalSize: number
  fileName: string
  filePath: string
  fileType: string
  duration: string
  isFlashMessage: boolean,
  /** 11 chatbot卡片; 12 chatbot消息的建议选项列表 */
  serviceKind: number
  address?: string
  isAfterNoReadButton?: boolean
  deliveryTime?: string
  msgContent?: string
  failReason?: string
}

export interface DataParameters {
  bundleName: string;
  code: number;
  data: string;
  event: string;
  // 是否为第一次未解锁
  isFirstUnlocked: boolean;
  // 是否为锁屏后重新更新后的未读
  isAfterNoReadButton: boolean;
  // 是否为锁屏后重发送的通知 和 isAfterNoReadButton基本同步，设置时机要错过notificationSlotType，不然可能锁屏没横幅
  isAfterReSendNotification: boolean;
  // 锁屏后来的通知事件，更新或者重新发送时使用锁屏时通知的时间
  deliveryTime: number;
  parameters: BaseDataParameters;
}

export interface BaseSessionResult {
  id: number;
  telephone: string;
  start_time?: string;
  msgId?: number;
}

export interface sessionResult {
  rowId: number;
  initDatas: BaseSessionResult[];
  groupId: number;
  smsType: number;
  rcsId?: number;
  code?: number;
}

export interface BaseResponse {
  totalListCount: number;
  unreadCount: number;
  unreadTotalOfInfo: number;
}

export interface Response {
  code: number;
  response: BaseResponse;
}

export interface BaseAbilityResult {
  detailInfo: string;
  displayName: string;
  id: number;
}

export interface AbilityResult {
  code: number;
  abilityResult: BaseAbilityResult[];
}

export interface TelephoneTypeFlag {
  telephoneFlag: number;
  telephoneType: number;
}

/**
 * 消息结构化信息
 */
export interface StructText {
  /**
   * 提取词key
   */
  key?: string;
  /**
   * 提取词key展示名
   */
  name: string;
  /**
   * 提取词
   */
  value: string;
}

export class MessageDetail {
  slotId: number = -1;
  telephone: string = '';
  content: string = '';
  public ipNoticeContent: string = '';
  isMms: boolean = false;
  public isFlashMms: boolean = false;
  mmsSource: LooseObject[] = [];
  msgId: string = '';
  public rcsMsgId: string = '';
  endtime: string = '';
  type: string = '';
  starttime: string = '';
  isAdvancedSecurity: number = 0;
  receiveState?: number = 0;
  failReceiveContext?: string = '';
  public isMute: number = 0; //是否静默 0：不静默，1：静默
  public isBlocked: number = 0;
  public blockedReason: number = 0;
  public blockedSources: string = '';
  public blockedType: number = 0;
  public blockedTypeText: string = '';
  public blockedPrefNumber: string = '';
  public isFraud: boolean = false;
  /* 验证码 - 为空则为非验证码消息 */
  public verCode?: string;
  public isVerCode: boolean = false;
  public rcsType: number = 0;
  public msgType: number = 0;
  public clurSize: number = 0;
  public totalSize: number = 0;
  public rcsMsgContent: string = '';
  public isParseVerCodeDone: boolean = false;
  public chatbotParameters?: ChatbotParameters
  public rcsId?: number
  public isFirstUnlocked: boolean = false;
  public deliveryTime: number = -1;
  public contactName?: string = ''
  public ownerAddr?: string = ''
  public protocol?: number = 0
  public serviceCenter?: string = ''
  /* 以下信息仅应用于打点 */
  public telephoneDot?: string = '';
  public telephoneLength?: number = 0;
  public telephoneType?: number = 0;
  public smsReceiveIdForDot?: number = 0;
  public dotMsgType?: number = -1;
  public mccmnc?: string = '';
  public receiveNull?: string = '';
}

export interface Contact {
  detailInfo: string;
  displayName: string;
  id: number;
  rawContactId?: string;
  contactId?: string;
}

export interface Mms {
  duration: string,
  type: number,
  path: string,
  ct?: string,
  name: string,
  text?: string,
  isOnAudio?: boolean,
  pixelMap?: PixelMap,
  imagePath?: string,
  size?: string,
  copyPath?: string
  index?: number
  galleryPath?: string
  isRcs?: boolean
  pageNum?: number,
  pageCount?: number,
  content?: string,
  contacts?:ContactType[]
  isOriginalImage?: boolean,
  address?: AddressInfo,
  smilParIndex?: number
  mediaFileParam?: MediaFileParam
  videoThumbnailUri?: string,
  isFraud?: number,
  partIndex?: number,
}

interface MediaFileParam {
  imagePixmap?: PixelMap | null
  imagePath?: string
}
/**
 * Type for mms contact info.
 */
export class ContactType {
  public contactName: string = ''
  public telephone: string = ''
  public telephoneFormat: string = ''
  public headImage: string = ''
  public select: boolean = false
  public rawContactId?: string
  public id?: number
  public index?: number
  public avatarBase64Encoded?: string
  public vcfFilePath?: string
  public photoPath?: string
  public telephoneType?: string
  public email?: ContactInfo.Email[] = []
  public address?: ContactInfo.Address[] = []
  public website?: string[] = []
  public org?: string = ''
  public title?: string = ''
  public bday?: string = ''
  public nickName?: string = ''
  public note?: string = ''
}

export interface Region {
  id: string,
  fit?: string,
  top: string,
  left: string,
  height: string,
  width: string
}

export interface PictureListData {
  image: string,
  selected: boolean,
  photoType: number,
  mediaUri?: string,
  pixelMap?: PixelMap,
  index?: number
}

export interface SessionOfFilterMms {
  sessionId: string;
  num: number;
  unreadCount: number;
}

export class mmsInfo {
  id: number = 0;
  content: string = '';
  isStared: boolean = false;
  msgType: number = -1;
  isFullScreenImg: boolean = false;
  read: string = '';
  sendStatus: number = 7;
  subId: number = 0;
  timeMillisecond: number = -1;
  isMsm: boolean = false;
  isCbChecked: boolean = false;
  isDraft: boolean = false;
  groupId: number = -1;
  isReceive: boolean = false;
  date: mmsInfoData = new mmsInfoData();
  time: mmsInfoData = new mmsInfoData();
  completeNumber: number = -1;
  failuresNumber: number = -1;
  hasReport: boolean = false;
  isShowMsgLongMenu: boolean = false;
  mmsSource: String[] | number[] | Object[] = [];
  contentType: number = -1;
  operatorServiceNumber: string = '';
  endTime: mmsInfoData = new mmsInfoData();
  msgState: number = -1;
  fullDate: mmsInfoData = new mmsInfoData();
  timeOfSms: mmsInfoData = new mmsInfoData();
  week: mmsInfoData = new mmsInfoData();
  dateShow: boolean = false;
  detailTime: mmsInfoData = new mmsInfoData();
  slotId: number = -1;
  expiresTime: string = '0';
  isAdvancedSecurity: boolean = false;
  public position: string = '';
  public telephone: string = '';
  public latitudeAndLongitude: string = '';
  public mmsPdu: string = '';
  public clurSize: number = 0;
  public totalSize: number = 0;
}

export class mmsInfoData {
  id: number = -1;
  type: number = -1;
  params: String[] | number[] | Object[] = [];
  bundleName: string = '';
  moduleName: string = '';
}

export interface mmsInfoBaseParam {
  applicationId: string,
  contentType: string,
  headerData: string,
  moduleName: string,
  pushType: number,
  rawData: string,
  slotId: number,
  transactionId: number
}

export interface mmsDataParameters {
  bundleName: string;
  code: number;
  data: string;
  event: string;
  parameters: mmsInfoBaseParam;
}

export class TransmitContent {
  info: string = '';
  content: string = '';
  contactsName: ResourceStr = '';
  isMsm: boolean = false;
  msgShowType: number = -1;
  msgUriPath: string = '';
  contentInfo: string = '';
  contentType: number = -1;
  mms?: Array<Mms>;
  public isRcs?: number;
  public msgTitleTransmit?: string = '';
  public slideFirstItemTransmit?: SlideMmsItem;
  public smilStr?: string;
}

export class packingItem {
  size: number = 0;
  data: ArrayBufferLike = new ArrayBuffer(0);
}

export interface LocationType {
  latitude: number
  longitude: number
}

/**
 * Encapsulate the address info of the location message.
 */
export class AddressInfo {
  // LatLong
  @Expose() public latitude: number = 0;
  @Expose() public longitude: number = 0;
  // Location Name
  @Expose() public name: string = '';
  // Address
  @Expose() public address: string = '';
  @Expose() public countryCode?: string;
  private static sImgSuffix: string = '.jpg';
  private static TAG: string = 'AddressInfo';

  constructor(latitude: number, longitude: number, name: string, address: string) {
    this.latitude = latitude;
    this.longitude = longitude;
    this.name = name;
    this.address = address;
  }

  /**
   * Generate a location image name based on the current AddressInfo.
   *
   * @returns map image name
   */
  buildMapImgName(): string {
    return `PART_${dateUtil.getTimeWithCount()}${AddressInfo.sImgSuffix}`;
  }
}

export class TimeType {
  public id: number = 0
  public type: number = 0
  public params: Array<string> = []
  public bundleName: string = ''
  public moduleName: string = ''
}

export class PhotoSizeType {
  public width: number = 0;
  public height: number = 0;
}

export class PageFlag {
  public pageFlag: string = ''
}

export class ThreadId {
  public threadId: number = -1
}

export class SearchResultListType {
  public sessionList: Array<number> = []
  public contentList: Array<string> = []
  public size: number = 0;
  public data: ArrayBufferLike = new ArrayBuffer(0);
}

export class SessionContentTypeOfRcs {
  public isSendMessage?: number
  public contactNum?: number
  public contactName?: string
}

export class RcsSendLoc {
  public body: string = '';
  public latitude: string = '';
  public longitude: string = '';
  public accuracy: string = '';
}

export interface SlideMmsItem extends Mms {
  isCbChecked?: boolean;
  /** 彩信位置附件的输入框文本 */
  inputBoxTextOfMmsMap?: string
}

/**
 * 页面跳转类型
 */
export enum PageJumpType {
    PUSH_PATH_BY_NAME = 'pushPathByName'
}

/**
 * 转发跳转页面参数
 */
export interface TransmitPageJumpParam {
  /** 页面跳转类型 */
  type: PageJumpType,
  /** 要跳转的页面 */
  pageName: string,
  /** 携带的路由参数 */
  params: Record<string, number | boolean | string | LooseObject[]>
}

/**
 * 新建会话发送参数
 */
export interface NewConversationSendData {
  /** 是否发送彩信消息 */
  isEditMms: boolean;

  /** 发送的彩信附件列表 */
  attachmentDataList: Mms[];
}

/** 在分享功能中分享数据的extra的属性名，用于分享彩信位置消息到信息应用的场景 */
export class ShareExtraData{
  public static MESSAGE_TYPE = 'Mms_extraParams_message_type';
  public static MESSAGE_IS_RCS = 'Mms_extraParams_message_isRcs';
  public static MESSAGE_CONTENT = 'Mms_extraParams_message_content';
  public static MESSAGE_LONGITUDE = 'Mms_extraParams_message_longitude';
  public static MESSAGE_LATITUDE = 'Mms_extraParams_message_latitude';
}

export interface BlockData {
  types?: number;
  phoneNumber?: string;
  timeStamp?: number;
  interceptionMsgCount?: number;
}

export class RcsInfoData {
  public rcsId?: number;
  public rcsType: number = 0;
  public msgContent: string = '';
  public msgState: number = 0;

  /** 自定义属性-消息内容概要 */
  public customAttributeMsgSummary: string | Resource = '';
}