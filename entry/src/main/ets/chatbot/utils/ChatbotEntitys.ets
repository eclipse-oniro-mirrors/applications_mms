/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { Expose } from 'class-transformer';
import LooseObject from '../../data/LooseObject';


export class BotDetails {

  @Expose() public botinfo?: DetailsMessage;

  @Expose() public botVerification?: VerificationInfo;

  @Expose({name:'persistent-menu'})
  @Expose() public persistentMenu?: PersistentMenu;

}

class VerificationInfo {
  // @SerializedName('verificationInfo')
  public verificationInfo?: VerifiedInfo
}

class VerifiedInfo {
  // @SerializedName('verified')
  public verified?: boolean;
  // @SerializedName('verifiedBy')
  public verifiedBy?: string;
  // @SerializedName('expires')
  public expires?: string;
}

class DetailsMessage {
  // @SerializedName('pcc')
  public pcc?: OrgDetails;
  // @SerializedName('version')
  public version?: string;
  // @SerializedName('provider')
  public provider?: string;
  // @SerializedName('TCPage')
  public TCPage?: string
  // @SerializedName('email')
  public email?: string;
  // @SerializedName('website')
  public website?: string;
  // @SerializedName('address')
  public address?: Address;
}

export class DetailsObject {

  public title?: Resource | string;

  public value?: Resource | string;
}

class Address {
  // @SerializedName('addressEntry')
  public addressEntry?: AddressInfo[];
}

export class AddressInfo {
  // @SerializedName('addrString')
  public addrString?: string;
  // @SerializedName('label')
  public label?: string;
}

class OrgDetails {
  // @SerializedName('pccType')
  public pccType?: string;
  // @SerializedName('orgDetails')
  public orgDetails?: DetailsInfo;
}

class DetailsInfo {
  // @SerializedName('orgName')
  public orgName?: NameInfo[];
  // @SerializedName('commAddr')
  public commAddr?: UriInfo;
  // @SerializedName('mediaList')
  public mediaList?: MediaEntry;
  // @SerializedName('categoryList')
  public categoryList?: CategoryInfo;
  // @SerializedName('orgDescription')
  public orgDescription?: string;
}

class CategoryInfo {
  // @SerializedName('categoryEntry')
  public categoryEntry?: string[];
}

class MediaEntry {
  // @SerializedName('mediaEntry')
  public mediaEntry?: Icon[];
}

export class Icon {
  // @SerializedName('mediaContent')
  public mediaContent?: string;
  // @SerializedName('media')
  public media?: IconInfo;
  // @SerializedName('label')
  public label?: string;
}

class IconInfo {
  // @SerializedName('mediaUrl')
  public mediaUrl?: string;
}

export class NameInfo {
  // @SerializedName('displayName')
  public displayName?: string;
  // @SerializedName('orgNameType')
  public orgNameType?: string;
}

class UriInfo {
  // @SerializedName('uriEntry')
  public uriEntry?: AddrUri[];
  // @SerializedName('tel')
  public tel?: CallbackInfo;
}

export class AddrUri {
  // @SerializedName('addrUriType')
  public addrUriType?: string;
  // @SerializedName('addrUri')
  public addrUri?: string;
  // @SerializedName('label')
  public label?: string;
}

class CallbackInfo {
  // @SerializedName('telType')
  public telType?: string;
  // @SerializedName('telNb')
  public telNb?: Phone;
  // @SerializedName('label')
  public label?: string;
}
class Phone {
  // @SerializedName('telStr')
  public telStr?: string;
}

export enum CardOrientation {
  /**
   * vertical
   */
  VERTICAL = 'VERTICAL',
  /**
   * horizontal
   */
  HORIZONTAL = 'HORIZONTAL'
}

export enum ImageAlignment {
  /**
   * left
   */
  LEFT = 'LEFT',
  /**
   * right
   */
  RIGHT = 'RIGHT'
}

/**
 * Definition of data to be posted back from UE to chatbot.
 *
 */
export class Postback {
  public data?: string;
}

abstract class BaseSuggestion {
  public displayText?: string;
  public postback?: Postback;
}


export class Reply extends BaseSuggestion {
}

/**
 * OpenUrl Entity
 *
 */
class OpenUrl {
  public url?: string;
  public application?: string;
}

/**
 * Suggested actions to interact a website or deep app link.
 *
 */
class UrlAction {
  public openUrl?: OpenUrl;
}

/**
 * creates a new event on the user's calendar
 *
 */
class CreateCalendarEvent {
  public startTime?: string;
  public endTime?: string;
  public title?: string;
  public description?: string;
  public fallbackUrl?: string;
}

class CalendarAction {
  public createCalendarEvent?: CreateCalendarEvent;
}

/**
 * Compose a draft text message.
 *
 */
class ComposeTextMessage {
  public phoneNumber?: string;
  public text?: string;
}

/**
 * Compose a draft message with a media recording.
 *
 */
class ComposeRecordingMessage {
  public phoneNumber?: string;
  public type?: string;
}

/**
 * Suggested actions for composing draft messages.
 *
 */
class ComposeAction {
  public composeTextMessage?: ComposeTextMessage;
  public composeRecordingMessage?: ComposeRecordingMessage;
}

/**
 * DialPhoneNumber Entity
 *
 */
class DialPhoneNumber {
  public phoneNumber?: string;
  public fallbackUrl?: string;
  public subject?: string;
}

/**
 * Suggested actions for interacting with a phone number.
 *
 */
class DialerAction {
  /**
   * calls a phone number via the user's dialler app
   */
  public dialPhoneNumber?: DialPhoneNumber;
  /**
   * start an Enriched Call via the user’s dialler app
   */
  public dialEnrichedCall?: DialPhoneNumber;
  /**
   * start a video call via the user’s dialler app
   */
  public dialVideoCall?: DialPhoneNumber;
}

/**
 * Location Entity
 *
 */
class Location {
  public latitude?: number;
  public longitude?: number;
  public label?: string;
  /**
   * Search for location(s) by query.
   *
   * Search is based on user's current location
   *
   * 'examples': [
   *     'restaurants',
   *     'GSMA Head Office, 25 Walbrook, London, UK'
   * ],
   */
  public query?: string;
}

/**
 * show location(s) on a map for given coordinates or search query
 *
 */
class ShowLocation {
  public location?: Location;
  public fallbackUrl?: string;
}

class RequestLocationPush {
  public title?: string
  public type?: string

  public toString() {
    return 'RequestLocationPush{}';
  }
}

/**
 * Suggested actions for interacting with a location on a map.
 *
 */
class MapAction {
  public showLocation?: ShowLocation;
  public requestLocationPush?: RequestLocationPush;
}

class RequestDeviceSpecifics {
  public title?: string
  public type?: string

  public toString() {
    return 'RequestDeviceSpecifics{}';
  }
}

/**
 * Request specifics about the user's device.
 *
 */
class DeviceAction {
  public requestDeviceSpecifics?: RequestDeviceSpecifics;
}

/**
 * Ask the user to disable the anonymization setting.
 *
 */
class DisableAnonymization {
  public toString() {
    return 'DisableAnonymization{}';
  }
}

/**
 * Ask the user to enable sending displayed notifications.
 *
 */
class EnableDisplayedNotifications {
  public toString() {
    return 'EnableDisplayedNotifications{}';
  }
}

/**
 * Suggested actions for interacting with app settings
 *
 */
class SettingsAction {
  public disableAnonymization?: DisableAnonymization;
  public enableDisplayedNotifications?: EnableDisplayedNotifications;
}

export class Action extends BaseSuggestion {
  public calendarAction?: CalendarAction;
  public composeAction?: ComposeAction;
  public dialerAction?: DialerAction;
  public urlAction?: UrlAction;
  public mapAction?: MapAction;
  public deviceAction?: DeviceAction;
  public settingsAction?: SettingsAction;
}

export class Suggestion {
  public reply?: Reply;
  public action?: Action;
  public trafficType?: string;
  public contributionId?: string;
}

/**
 * CardMedia entity
 *
 */
export class CardMedia {
  public mediaUrl?: string;
  public mediaContentType?: string;
  /**
   * Media file size in bytes
   */
  public mediaFileSize?: number;
  /**
   * Storage path of rich media files in the local sandbox
   */
  public mediaFileLocalPath?: string
  public mediaFileLocalName?: string
  public height?: string;
  public thumbnailUrl?: string;
  public thumbnailContentType?: string;
  /**
   * Thumbnail file size in bytes
   */
  public thumbnailFileSize?: number;
  /** Path for storing thumbnails in the local sandbox  */
  public thumbnailLocalPath?: string
  public thumbnailLocalName?: string
  /**
   * Optional textual description of media content.
   * Accessibility text for use with screen readers. Will not be shown on screen.
   */
  public contentDescription?: string;
}

export class ChatbotCardContent {
  public media?: CardMedia;
  public title?: string;
  public description?: string;
  public suggestions?: Suggestion[];
}

export enum RcsChatbotServiceKind {
  CHATBOT_CARD = 11,
  CHATBOT_SUGGESTIONS = 12
}

export class ChatbotDetail {
  public serviceId?: string;
  public serviceName?: string = '';
  public lastSuggestedList?: string;
  /** Chatbot收到消息时是否通知用户，0 通知 1 不提醒 */
  public disturb?: number = 0;
  public callbackPhoneNumber?: string;
  public persistentMenu?: string;
  public expires?: number = 0;
  public sms?: string;
  public serviceIcon?: string;
  public serviceDescription?: string;
  public categoryList?: string;
  public brief?: number = 0;
  public favorite?: number = 0;
  public email ?: string;
  public website ?: string;
  public address ?: string;
  public pinyin ?: string;
  public pinyinShort ?: string;
  public colour ?: string;
  public backgroundImage ?: string;
  public verified ?: number = 0;
  public verifiedBy ?: string;
  public verifiedExpires ?: string;
  public cacheControl ?: string;
  public eTag ?: string;
  public tcPage ?: string;
  public recentUseTime ?: string;
  public shareInfo ?: number = 0;
  public serviceProvider ?: string;
}

export enum ChatbotDetailDisturb {
  NOTIFY_USER = 0,
  NOT_NOTIFY_USER = 1
}

export interface TypeLocalCustomData {
  msgId?: string,
  isDeeplink?: boolean
}

/**
 * A chatbot message, sent from chatbot platform to client.
 *
 */
export class BotMessage {
  /**
   * Rich card message, either a 'Single Rich Card' or a 'Carousel of Rich Cards'
   */
  @Expose() public message?: RichCardMessage;
  /**
   * Suggested replies and/or suggested actions for a chatbot message, send from chatbot platform
   * to client.
   */
  @Expose() public suggestions?: Suggestion[];
  @Expose() public TrafficType?: string;
  @Expose() public contributionId?: string;
  // localCustomData is stash custom data
  @Expose() public localCustomData?: TypeLocalCustomData;
  // reply is suggestion reply carried field
  @Expose() public replyId?: string;
}

/**
 * A general-purpose, standalone Rich Card message.
 *
 */
class GeneralPurposeCard {
  public layout?: Layout;
  public content?: ChatbotCardContent;
}

/**
 * A rich card message, sent from chatbot platform to client.
 *
 */
export class RichCardMessage {
  @Expose() public generalPurposeCard?: GeneralPurposeCard;
  @Expose() public generalPurposeCardCarousel?: GeneralPurposeCardCarousel;
}

/**
 * Layout entity
 *
 */
class Layout {
  public cardOrientation?: string;
  public imageAlignment?: string;
  public cardWidth?: string;
}

/**
 * A carousel of general-purpose Rich Cards.
 *
 */
class GeneralPurposeCardCarousel {
  public layout?: Layout;
  public content?: ChatbotCardContent[];
}

/**
 * Response to a suggested reply or suggested action, sent from client to chatbot platform.
 *
 */
export class Response {
  public reply?: Reply;
  public action?: Action;
}

/**
 * A chatbot message, sent from client to chatbot platform.
 *
 */
export class ClientMessage {
  /**
   * Response to a suggested reply or suggested action, sent from client to chatbot platform.
   */
  public response?: Response;
  /**
   * Data shared by the client with the chatbot platform (e.g. device specifics).
   */
  public sharedData?: SharedData;
}

/**
 * Data shared by the client with the chatbot platform (e.g. device specifics).
 *
 */
export class SharedData {
  public deviceSpecifics?: DeviceSpecifics;
}

/**
 * Device specifics shared by the client with the chatbot platform.
 *
 */
class DeviceSpecifics {
  /**
   * short description of the device model (e. g. 'SmartPhone8').
   */
  public deviceModel?: string;
  /**
   * Version information about the device platform.
   */
  public platformVersion?: string;
  /**
   * short code for client vendor, same as used during RCS autoconfiguration (e. g. 'VNDR').
   */
  public clientVendor?: string;
  /**
   * Version information about the client, same as used during RCS autoconfiguration
   */
  public clientVersion?: string;
  /**
   * Remaining battery use of device in minutes (e.g. '517')
   */
  public batteryRemainingMinutes?: number;
}

export enum ChatbotCardMessageType {
  SINGLE_CARD = 'singleCard',
  MULTI_CARD = 'multiCard'
}

/**
 * persist menu entry
 *
 */
export class Entry {
  public reply?: Reply;
  public action?: Action;
  public menu?: Menu;
}

/**
 * persistent-menu
 *
 */
class Menu {
  public displayText?: string;
  public entries?: Entry[];
}

/**
 * persistent menu
 *
 */
export class PersistentMenu {
  @Expose() public menu?: Menu;
}

export interface ChatbotCardMediaFile {
  type: 'thumbnail' | 'originalFile'
  path: string
  pathData: PathAndMsgType
  url: string
  size: number
  msgType: number
  name: string
}

export interface PathAndMsgType {
  fileDir: string
  filePath: string
  msgType: number
  fileName: string
}

export class ChatbotParameters {
  public isChatbotMessage?: boolean;
  public mmsSource?: LooseObject[] = [];
  public isNotifyUserMessage?: boolean;
  public serviceId?: string
  public serviceName?: string
  public cardType?: ChatbotCardMessageType
  public cardContent?: BotMessage
  public originFiles?: ChatbotCardMediaFile[] | null
  public telephoneFromServiceId?: string
  public msgType?: number
}

export interface RedirectDetailParams {
  id?: string;
  icon?: string;
  name?: string;
}

export interface QueryChatbotsResult {
  chatbotName?: string;
  number?: string;
  chatbotIcon?: string;
}

export class ChatbotConfig {
  @Expose() public defaultDnsIpList: string[] = [];
}

export class ChatbotProfile {
  /*
   * Chatbot service ID
   * Note: An id value can occur only once in the query results. If there are more than one
   * entry available with the same Chatbot service ID, it is up to the Service Provider Chatbot
   * Directory Function to select which one to return to the client.
   */
  public id?: string
  public name?: string
  /**
   * Link to the Chatbot icon image. If not provided, the client shall assume that the icon is
   * not available.
   */
  public icon?: string
  /**
   * Chatbot description.
   */
  public description?: string
  public version?: string
  /**
   * Indicates whether the Chatbot is to be presented to the user as a Chatbot whose identity
   * has been verified. If absent, the Chatbot shall not be presented as verified.
   */
  public verified?: boolean | string

  constructor(id: string,
    name: string,
    icon: string,
    description: string,
  ) {
    this.id = id;
    this.name = name;
    this.icon = icon;
    this.description = description;
  }
}

export class ChatbotDirectory {
  @Expose() public recommendBots?: ChatbotProfile[];
  @Expose() public bots?: ChatbotProfile[];
  /**
   * The number of query objects returned
   */
  @Expose() public itemsReturned?: number;
  /**
   * The index of the first query result in the current set of query results
   */
  @Expose() public startIndex?: number;
  /**
   * The number of query objects available
   */
  @Expose() public totalItems?: number;
}

/**
 * 用于请求应用号数据
 */
export interface ReturnDataQuicklyParam {
  /** 是否需要快速返回数据 */
  isNeedReturnDataQuickly: boolean;

  /** 使用现有的数据库中的应用号数据刷新界面 */
  callbackOfRefreshUI: (chatbotDetail?: ChatbotDetail | null) => void;

  /** 没有名称的chatbot的会话,在向服务器请求详情数据成功后 是否使用最新的名称来更新session表，并刷新会话列表 */
  isUpdateSession?: boolean;
}
/** 应用号服务器ID的固定前缀 */
export const PREFIX_OF_CHATBOT_SERVICE = 'sip:';
/** 应用号服务器ID的后缀中固定的部分 */
export const PART_SUFFIX_OF_CHATBOT_SERVICE = '@botplatform';