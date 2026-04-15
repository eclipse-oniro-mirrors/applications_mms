/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
// @ts-ignore
import lazy search from '@ohos.fusionsearchclient';
import Log from '@ohos.hilog';
import { hilog, hiTraceChain, hiTraceMeter } from '@kit.PerformanceAnalysisKit';

/**
 * The search index info for SMS.
 */
const SMS_SEARCH_CLIENT_INDEX: search.Index = {
  indexId: 'test',
  ownerId: 'test',
  indexName: 'sysMessages',
  schemaType: 6,
  version: '0.0.1',
};

/**
 * The search index info for CONTACTS.
 */
const CONTACTS_SEARCH_CLIENT_INDEX: search.Index = {
  indexId: 'test',
  ownerId: 'test',
  indexName: 'sysContacts',
  schemaType: 7,
  version: '0.0.1',
};

/**
 * Filter not delete msg
 */
const NON_DELETED_FILTER: search.SimpleFilterClause = {
  field: 'isDeleted',
  operator: 'eq',
  value: 0
};

/**
 * Filter notification msg
 */
const NOTIFICATION_FILTER: search.SimpleFilterClause = {
  field: 'messageType',
  operator: 'eq',
  value: 1
};

/**
 * The size of session search.
 */
const SESSION_SEARCH_SIZE: number = 1000;

// The content in the tag indicates the matching result.
const EM_TAG_START: string = '<em>';
const EM_TAG_END: string = '</em>';

// TAG
const TAG: string = 'SearchUtil';
const DOMAIN = 0x0800;

class SearchUtil {

  public searchEnable: boolean = true;
  public isInit: boolean = false;
  private _searchSession: search.SearchSession | undefined;

  setSearchSession(searchSession: search.SearchSession): void {
    this._searchSession = searchSession;
  }
  /**
   * Fuzzy query message by text.
   *
   * @param queryText Search Keyword
   * @returns Message Array
   */
  public async searchMessage(queryText: string, pageNum: number, searchType: SearchType = SearchType.FULL): Promise<MessagesSchema[]> {
    Log.info(DOMAIN, TAG, 'searchMessage start.');
    // Create search session
    let size:number = 100;
    hiTraceMeter.startTrace('search_030201_search_message_create', 31030201);
    const searchSession: search.SearchSession = await this.getSearchSession();
    hiTraceMeter.finishTrace('search_030201_search_message_create', 31030201);
    // Build query clause
    const queryClause: search.SimpleQueryClause = {
      query: queryText,
      searchFields: ['content'],
      queryType: 'match'
    };
    // Setting the Sort mode
    const querySort: search.Sort = {
      type: 'FIELD',
      field: 'createDate',
      sortType: 'DESC'
    };
    // Build filter.
    let filterArr: search.SimpleFilterClause[] = [];
    switch (searchType) {
      case SearchType.NOTIFICATION:
        filterArr.push(NOTIFICATION_FILTER);
        break;
    }
    const filterClause: search.LogicalFilterClause = { logicalOperator: 'and', clauses: filterArr };
    // Construct a query statement
    const query: Record<string, Object> = {
      'index': SMS_SEARCH_CLIENT_INDEX,
      'query': queryClause,
      'filter': filterClause,
      'outFields': ['content', 'entityId', 'contactName',
        'contactId', 'createDate', 'sessionId', 'isCollect', 'phoneNumber', 'messageType'],
      'offset': pageNum,
      'size': size,
      'sorts': [querySort]
    };
    // Begin query.
    hiTraceMeter.startTrace('search_030202_search_message_activate', 31030202);
    const messageSearchResult: search.SearchResult<MessagesSchema> = await searchSession
      .search(query as Object as search.Query);
    hiTraceMeter.finishTrace('search_030202_search_message_activate', 31030202);
    if (messageSearchResult.records) {
      let messageRecord: MessagesSchema[] = messageSearchResult.records as MessagesSchema[];
      messageRecord = this.dealCollectRecords(messageRecord);
      Log.info(DOMAIN, TAG, 'searchMessage end. size: ' + messageRecord.length);
      this.sortMessages(messageRecord);
      messageRecord = this.decodeMessages(messageRecord);
      return messageRecord;
    }
    Log.info(DOMAIN, TAG, 'searchMessage end. size: 0');
    return [];
  }

  public async searchMoreMessage(queryText: string, pageNum: number, searchType: SearchType = SearchType.FULL): Promise<MessagesSchema[]> {
    Log.info(DOMAIN, TAG, 'searchMoreMessage searchMessage start.');
    // Create search session
    hiTraceMeter.startTrace('search_030201_search_message_create', 31030201);
    const searchSession: search.SearchSession = await this.getSearchSession();
    hiTraceMeter.finishTrace('search_030201_search_message_create', 31030201);
    let size:number = 100;
    // Build query clause
    const queryClause: search.SimpleQueryClause = {
      query: queryText,
      searchFields: ['content'],
      queryType: 'match'
    };
    // Setting the Sort mode
    const querySort: search.Sort = {
      type: 'FIELD',
      field: 'createDate',
      sortType: 'DESC'
    };
    // Build filter.
    let filterArr: search.SimpleFilterClause[] = [];
    switch (searchType) {
      case SearchType.NOTIFICATION:
        filterArr.push(NOTIFICATION_FILTER);
        break;
    }
    const filterClause: search.LogicalFilterClause = { logicalOperator: 'and', clauses: filterArr };
    // Construct a query statement
    const query: Record<string, Object> = {
      'index': SMS_SEARCH_CLIENT_INDEX,
      'query': queryClause,
      'filter': filterClause,
      'outFields': ['content', 'entityId', 'contactName',
        'contactId', 'createDate', 'sessionId', 'isCollect', 'phoneNumber', 'messageType'],
      'offset': pageNum * size,
      'size': size,
      'sorts': [querySort]
    };
    // Begin query.
    hiTraceMeter.startTrace('search_030202_search_message_activate', 31030202);
    const messageSearchResult: search.SearchResult<MessagesSchema> = await searchSession
      .search(query as Object as search.Query);
    hiTraceMeter.finishTrace('search_030202_search_message_activate', 31030202);
    if (messageSearchResult.records) {
      let messageRecord: MessagesSchema[] = messageSearchResult.records as MessagesSchema[];
      messageRecord = this.dealCollectRecords(messageRecord);
      Log.info(DOMAIN, TAG, 'search more message end. size: ' + messageRecord.length);
      this.sortMessages(messageRecord);
      messageRecord = this.decodeMessages(messageRecord);
      return messageRecord;
    }
    Log.info(DOMAIN, TAG, 'search more message end. size: 0');
    return [];
  }

  public decodeHTMLEntities(str: string): string {
    const htmlEntities: { [key: string]: string } = {
      '&#x2F;': '/',
      '&#x3c;': '<',
      '&#x3e;': '>'
    };

    return str.replace(/&(#x?[0-9a-fA-F]+|[a-zA-Z]+);/gi, (entity) => {
      if (entity.startsWith('&#x')) {
        return String.fromCharCode(parseInt(entity.slice(3, -1), 16));
      } else if (entity.startsWith('&#')) {
        return String.fromCharCode(parseInt(entity.slice(2, -1), 10));
      } else {
        return htmlEntities[entity] || entity;
      }
    });
  }

  public decodeMessages(messageRecords):MessagesSchema[] {
    return messageRecords.map(record => {
      return {
        ...record,
        content: this.decodeHTMLEntities(record.content)
      };
    });
  }

  /**
   * Deal Collected Records,and create a new data record.
   *
   * @param messages
   * @returns messageRecord Array
   */
  public dealCollectRecords(messageRecord): MessagesSchema[] {
    let tmplArr = [];
    messageRecord.forEach((e) => {
      tmplArr.push(e);
      if (e.isCollect === 1) {
        let el = {...e};
        el.isCollect = 0;
        tmplArr.push(el);
      }
    });
    return tmplArr;
  }

  /**
   * Sort message by collect state and create date.
   *
   * @param messages
   */
  public sortMessages(messages: MessagesSchema[]): void {
    messages.sort((a, b) => {
      if (a.isCollect !== b.isCollect) {
        return a.isCollect ? -1 : 1;
      }
      return ((b.createDate ?? 0)) - (a.createDate ?? 0);
    });
  }

  /**
   * Fuzzy query session by text.
   *
   * @param queryText Search Keyword
   * @returns Session Array
   */
  public async searchSession(queryText: string, type: SearchType = SearchType.FULL): Promise<GroupSearchResult[]> {
    Log.info(DOMAIN, TAG, 'searchSession start.');
    // Create search session
    //该文件是ts文件，TRACE_SEARCH_SESSION_FUSION_ID 在ets文件中，没有办法import到ts文件中;
    hiTraceMeter.startTrace('search_030101_search_fusion_session_create', 31030201);
    const searchSession: search.SearchSession = await this.getSearchSession();
    //该文件是ts文件，TRACE_SEARCH_SESSION_FUSION_ID 在ets文件中，没有办法import到ts文件中;
    hiTraceMeter.finishTrace('search_030101_search_fusion_session_create', 31030201);
    // Build query clause
    const groupSearchQueryClause: search.SimpleQueryClause = {
      query: queryText,
      searchFields: ['contactName', 'phoneNumber'],
      queryType: 'match'
    };
    // Setting the Sort mode
    const querySort: search.Sort = {
      type: 'FIELD',
      field: 'createDate',
      sortType: 'DESC'
    };
    // Build filter.
    let filterArr: search.SimpleFilterClause[] = [];
    switch (type) {
      case SearchType.NOTIFICATION:
        filterArr.push(NOTIFICATION_FILTER);
        break;
    }
    const filterClause: search.LogicalFilterClause = {
      logicalOperator: 'and',
      clauses: filterArr
    };
    // Construct a query statement
    const groupSearchQuery: Record<string, Object> = {
      'index': SMS_SEARCH_CLIENT_INDEX,
      'query': groupSearchQueryClause,
      'filter': filterClause,
      'outFields': ['contactName', 'contactId', 'createDate', 'sessionId', 'phoneNumber', 'messageType'],
      'offset': 0,
      'size': SESSION_SEARCH_SIZE,
      'sorts': [querySort]
    };
    //该文件是ts文件，TRACE_SEARCH_SESSION_FUSION_ID 在ets文件中，没有办法import到ts文件中;
    hiTraceMeter.startTrace('search_030102_search_fusion_session_activate', 31030202);
    // Begin query.
    const sessionSearchResult: search.GroupTotalResult<MessagesSchema>[] =
      await searchSession.groupSearch(groupSearchQuery as Object as search.Query,
        ['sessionId'], SESSION_SEARCH_SIZE, true, 1) as search.GroupTotalResult<MessagesSchema>[];
    hiTraceMeter.finishTrace('search_030102_search_fusion_session_activate', 31030202);
    if (sessionSearchResult.length > 0) {
      let resultSet: GroupSearchResult[] = sessionSearchResult[0].groupSearchResult ?? [];
      resultSet.sort((a, b) => {
        return (b.indexDataList[0]?.createDate ?? 0) - (a.indexDataList[0]?.createDate ?? 0);
      });
      Log.info(DOMAIN, TAG, 'searchSession end. size: ' + resultSet.length);
      return resultSet;
    } else {
      Log.info(DOMAIN, TAG, 'searchSession end. size: 0');
      return [];
    }
  }

  /**
   * Fuzzy query contacts by text.
   *
   * @param queryText
   * @returns
   */
  public async searchContact(queryText: string): Promise<ContactsSchema[]> {
    Log.info(DOMAIN, TAG, 'searchContact start.');
    // Create search session
    const searchSession: search.SearchSession = await this.getSearchSession();

    // Build query clause
    const queryClause: search.SimpleQueryClause = {
      query: queryText,
      searchFields: ['name', 'phoneNumbers', 'organization', 'position',
        'emails', 'note', 'familyAddress', 'imInfo', 'groupName', 'nickname'],
      queryType: 'match'
    };

    // Construct a query statement
    const query: search.Query = {
      index: CONTACTS_SEARCH_CLIENT_INDEX,
      query: queryClause,
      filter: NON_DELETED_FILTER,
      outFields: ['name', 'phoneNumbers'],
      offset: 0,
      size: 2000,
    };

    // Begin query.
    let contactSearchResult: search.SearchResult<ContactsSchema> = await searchSession.search(query);
    if (contactSearchResult.records) {
      let contactRecord: ContactsSchema[] = contactSearchResult.records as ContactsSchema[];
      let filterContacts: ContactsSchema[] = this.filterInvalidContacts(contactRecord, queryText);
      let sortedContacts: ContactsSchema[] = this.sortContacts(filterContacts);
      Log.info(DOMAIN, TAG, 'searchContact end. size: ' + sortedContacts.length);
      return sortedContacts;
    }
    Log.info(DOMAIN, TAG, 'searchContact end. size: 0');
    return [];
  }

  /**
   * Sort contacts, Sorting field:
   *  First name, then phone number.
   * Sort by:
   *  Index of a search keyword in the search content.
   *
   * @param contacts
   * @returns
   */
  private sortContacts(contacts: ContactsSchema[]): ContactsSchema[] {
    contacts.sort((a, b) => {
      let aNameScore: number = a.name.indexOf(EM_TAG_START);
      if (aNameScore < 0) {
        aNameScore = Number.MAX_VALUE;
      }
      let bNameScore: number = b.name.indexOf(EM_TAG_START);
      if (bNameScore < 0) {
        bNameScore = Number.MAX_VALUE;
      }
      let compResult: number = aNameScore - bNameScore;
      if (compResult !== 0) {
        return compResult;
      }
      let aNumScore: number = a.phoneNumbers[0]?.value?.indexOf(EM_TAG_START) ?? 0;
      if (aNumScore < 0) {
        aNumScore = Number.MAX_VALUE;
      }
      let bNumScore: number = b.phoneNumbers[0]?.value?.indexOf(EM_TAG_START) ?? 0;
      if (bNumScore < 0) {
        bNumScore = Number.MAX_VALUE;
      }
      return aNumScore - bNumScore;
    });
    return contacts;
  }

  /**
   * Filter invalid contacts:
   *  1.The result for dialer search
   *  2.The unmatched phone for multiple-numbers
   *
   * @param contacts
   * @param searchKey
   * @returns
   */
  private filterInvalidContacts(contacts: ContactsSchema[], searchKey: string): ContactsSchema[] {
    searchKey = searchKey.replace(new RegExp('[\\s]', 'g'), '');
    let isNumber = !isNaN(parseInt(searchKey));
    if (!isNumber) {
      return contacts;
    }
    let filterContacts: ContactsSchema[] = [];
    let emTagReg: RegExp = new RegExp(`${EM_TAG_START}|${EM_TAG_END}`, 'g');
    contacts.forEach((item) => {
      let isNameMatched: boolean = (item.nameExt ?? '').indexOf(searchKey) !== -1;
      if (!isNameMatched) {
        // Remove name highlight. (Close dialer search)
        item.name = (item.name ?? '').replace(emTagReg, '');
        // Remove unmatched phone. (Single contact with multiple numbers)
        item.phoneNumbers = (item.phoneNumbers ?? []).filter((item: IdLabelValueSchema) => {
          return (item.value.includes(EM_TAG_START) && item.value.includes(EM_TAG_END)) || item.value.includes(searchKey);
        }) ?? [];
      }
      let isPhoneMatched: boolean = item.phoneNumbers.length > 0;
      // Push valid data.
      if (isNameMatched || isPhoneMatched) {
        filterContacts.push(item);
      }
    });
    return filterContacts;
  }

  public async initSearchService(): Promise<void> {
    if (!this.isInit) {
      this.isInit = true;
      search.createService();
    }
  }

  // 初始化化SearchSession(搜索框获焦时就初始化,提高搜索效率)
  public async initSearchSession(): Promise<void> {
    Log.info(DOMAIN, TAG, 'searchMessage start.');
    if (!this._searchSession) {
      Log.info(DOMAIN, TAG, 'beginSearch.');
      this._searchSession = await search.beginSearch([]);
    }
  }

  // 获取搜索SearchSession对象
  public async getSearchSession(): Promise<search.SearchSession> {
    if (!this._searchSession) {
      this._searchSession = await search.beginSearch([]);
    }
    return this._searchSession;
  }
  public releaseService():void {
    search.releaseService();
    this._searchSession = undefined;
    this.isInit = false;
  }
}

export default new SearchUtil();

/**
 * Schema for contact
 */
export interface ContactsSchema {
  entityId: string;
  entityName: string;
  name: string;
  nameExt: string;
  namePinyin: string;
  organization: string;
  title: string;
  icon: string;
  phoneNumbers: IdLabelValueSchema[];
  emails: IdLabelValueSchema[];
  note: string;
  detailUri: string;
  familyAddress: string;
  imInfo: IdLabelValueSchema[];
  imUri: string;
  groupInfo: string;
  nickname: string;
  meeTimeUri: string;
  callUri: string;
  smsUri: string;
  position: string;
}

/**
 * Schema for contact phones
 */
export interface IdLabelValueSchema {
  id: string;
  label: string;
  value: string;
}

/**
 * Schema for message
 */
export interface MessagesSchema {
  entityId: string;
  entityName: string;
  content: string;
  messageType: number;
  createDate: number;
  phoneNumber: string;
  contactId: string;
  contactName: string;
  direction: number;
  state: number;
  sessionId: string;
  isCollect: number;
  hasYellowPageIcon: string;
}

/**
 * Splitting Grouped Messages
 *
 * @returns
 */
export function splitMessagesSchema(msgSchema: MessagesSchema): MessagesSchema[] {
  let separator: string = '|';
  if (msgSchema.phoneNumber.indexOf(separator) === -1) {
    separator = ',';
  }
  if (!msgSchema.phoneNumber ||
    msgSchema.phoneNumber === null ||
    msgSchema.phoneNumber.trim() === '' ||
    msgSchema.phoneNumber.indexOf(separator) === -1) {
    return [msgSchema];
  } else {
    let phones: string[] = msgSchema.phoneNumber.split(separator);
    let contactIds: string[] = msgSchema.contactId.split(separator);
    let contactNames: string[] = msgSchema.contactName.split(separator);
    let messages: MessagesSchema[] = [];
    let maxLen: number = Math.max(phones.length, contactIds.length, contactNames.length);
    for (let i = 0; i < maxLen; i++) {
      let phone: string = phones[i] ?? '';
      if (!phone || phone === null || phone.trim() === '') {
        continue;
      }
      let contactId: string = contactIds[i] ?? '';
      let contactName: string = contactNames[i] ?? '';
      // Object.assign restricted on the new SDK.
      let msg: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: msgSchema.entityId,
        entityName: msgSchema.entityName,
        content: msgSchema.content,
        messageType: msgSchema.messageType,
        createDate: msgSchema.createDate,
        phoneNumber: msgSchema.phoneNumber,
        contactId: msgSchema.contactId,
        contactName: msgSchema.contactName,
        direction: msgSchema.direction,
        state: msgSchema.state,
        sessionId: msgSchema.sessionId,
        isCollect: msgSchema.isCollect,
      };
      msg.phoneNumber = phone;
      msg.contactId = contactId;
      msg.contactName = contactName;
      messages.push(msg);
    }
    return messages;
  }
}

/**
 * Group result for session
 */
export interface GroupSearchResult {
  readonly value: string;
  readonly count: number;
  indexDataList: MessagesSchema[];
}

/**
 * Search type
 */
export enum SearchType {
  FULL, NOTIFICATION
}