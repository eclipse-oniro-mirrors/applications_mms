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
export default class TraceConstant {

  // 短信发送trace
  public static readonly TRACE_SEND_MSG: string = 'mms_trace_send_msg_insert_db';
  public static readonly TRACE_SEND_MSG_ID: number = 1;

  // 删除短信trace
  public static readonly TRACE_DEL_MSG: string = 'mms_trace_del_msg';
  public static readonly TRACE_DEL_MSG_ID: number = 2;

  // 查询短信列表trace
  public static readonly TRACE_QUERY_CONVERSION_LIST : string = 'mms_trace_query_con_list';
  public static readonly TRACE_QUERY_CONVERSION_LIST_ID : number = 3;

  // session数据库查询解析数据trace
  public static readonly TRACE_DB_PARSE_SESSION_DATA : string = 'mms_trace_parse_session_data';
  public static readonly TRACE_DB_PARSE_SESSION_DATA_ID : number = 4;

  // 短信发送newSend check
  public static readonly TRACE_NEW_SEND_CHECK: string = 'mms_trace_send_msg_check';
  public static readonly TRACE_NEW_SEND_CHECK_ID: number = 5;

  // 短信发送刷新到会话框trace
  public static readonly TRACE_SEND_MSG_REFRESH: string  = 'mms_trace_send_msg_refresh_to_list';
  public static readonly TRACE_SEND_MSG_REFRESH_ID: number = 6;

  // 短信发送后输入框内容清空trace
  public static readonly TRACE_SEND_MSG_CLEAN_TEXT: string  = 'mms_trace_send_msg_clean_text_box';
  public static readonly TRACE_SEND_MSG_CLEAN_TEXT_ID: number = 7;

  // 首页trace点
  public static readonly TRACE_INDEX_ABORT_TO_APPEAR :string  = 'index_about_to_appear';
  public static readonly TRACE_INDEX_ABORT_TO_APPEAR_ID :number  = 8;

  public static readonly TRACE_INDEX_ON_PAGE_SHOW :string  = 'index_on_page_show';
  public static readonly TRACE_INDEX_ON_PAGE_SHOW_ID :number  = 9;

  public static readonly TRACE_INDEX_ON_PAGE_HIDE :string  = 'index_on_page_hide';
  public static readonly TRACE_INDEX_ON_PAGE_HIDE_ID :number  = 10;

  public static readonly TRACE_INDEX_ON_NAV_BAR_CHANGE :string  = 'index_on_nav_bar_state_change';
  public static readonly TRACE_INDEX_ON_NAV_BAR_CHANGE_ID :number  = 11;

  public static readonly TRACE_DB_INIT :string = 'sms_db_init';
  public static readonly TRACE_DB_INIT_ID :number = 12;
  public static readonly TRACE_CONTACT_DB_INIT :string = 'contact_db_init';
  public static readonly TRACE_CONTACT_DB_INIT_ID :number = 13;
  public static readonly TRACE_MAINABILITY_CREATE :string = 'mainability_create';
  public static readonly TRACE_MAINABILITY_CREATE_ID :number = 14;
  public static readonly TRACE_YELLOW_PAGE_DB_INIT: string = 'yellow_page_db_init';
  public static readonly TRACE_YELLOW_PAGE_DB_INIT_ID: number = 15;
  public static readonly TRACE_SATELLITED_DB_INIT: string = 'satellited_db_init';
  public static readonly TRACE_SATELLITED_DB_INIT_ID: number = 16;
  public static readonly TRACE_DB_SESSION_INIT :string = 'sms_db_init_silence';
  public static readonly TRACE_DB_SESSION_INIT_ID :number = 17;
  public static readonly TRACE_CONTACT_DB_INIT_SLIENCE :string = 'contact_db_init_slience';
  public static readonly TRACE_CONTACT_DB_INIT_SLIENCE_ID :number = 18;

  //conversation会话页面trace点
  public static readonly TRACE_CONVERSATION_ABOUT_TO_APPEAR :string  = 'conversation_about_to_appear';
  public static readonly TRACE_CONVERSATION_ABOUT_TO_APPEAR_ID :number  = 1001;

  public static readonly TRACE_CONVERSATION_ABOUT_TO_DISAPPEAR :string  = 'conversation_about_to_disappear';
  public static readonly TRACE_CONVERSATION_ABOUT_TO_DISAPPEAR_ID :number  = 1002;

  public static readonly TRACE_CONVERSATION_DESTINATION_SHOW :string  = 'conversation_destination_show';
  public static readonly TRACE_CONVERSATION_DESTINATION_SHOW_ID :number  = 1003;

  public static readonly TRACE_CONVERSATION_DESTINATION_HIDE :string  = 'conversation_destination_hide';
  public static readonly TRACE_CONVERSATION_DESTINATION_HIDE_ID :number  = 1004;

  public static readonly TRACE_CONVERSATION_CONTROLLER_ON_HIDE :string = 'conversation_controller_on_hide';
  public static readonly TRACE_CONVERSATION_CONTROLLER_ON_HIDE_ID:number = 1005;

  public static readonly TRACE_CONVERSATION_CONTROLLER_ON_INIT :string = 'conversation_controller_on_init';
  public static readonly TRACE_CONVERSATION_CONTROLLER_ON_INIT_ID:number = 1006;

  public static readonly TRACE_CONVERSATION_CONTROLLER_ON_SHOW :string = 'conversation_controller_on_show';
  public static readonly TRACE_CONVERSATION_CONTROLLER_ON_SHOW_ID:number = 1007;

  public static readonly TRACE_QUERY_ALL_INFO_SIZE :string = 'query_All_Info_Size';
  public static readonly TRACE_QUERY_ALL_INFO_SIZE_ID:number = 1008;

  // 联系人数据库交互trace点
  public static readonly TRACE_QUERY_CONTRACT_DATA_BY_CONDITION :string = 'query_contact_data_by_condition';
  public static readonly TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID:number = 1101;

  public static readonly TRACE_QUERY_CALL_LOG_BY_CONDITION :string = 'query_call_log_by_condition';
  public static readonly TRACE_QUERY_CALL_LOG_BY_CONDITION_ID:number = 1102;

  public static readonly TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION :string = 'query_contact_data_size_by_condition';
  public static readonly TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION_ID:number = 1103;

  public static readonly TRACE_QUERY_CONTACT_BY_CONDITION :string = 'query_contact_by_condition';
  public static readonly TRACE_QUERY_CONTACT_BY_CONDITION_ID:number = 1104;

  public static readonly TRACE_QUERY_CONTACT_SIZE_BY_CONDITION :string = 'query_contact_size_by_condition';
  public static readonly TRACE_QUERY_CONTACT_SIZE_BY_CONDITION_ID:number = 1105;

  public static readonly TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION :string = 'query_raw_contact_size_by_condition';
  public static readonly TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION_ID:number = 1106;

  public static readonly TRACE_QUERY_RECENT_CONTACT_BY_ROW :string = 'query_recent_contact_by_row';
  public static readonly TRACE_QUERY_RECENT_CONTACT_BY_ROW_ID:number = 1107;

  public static readonly TRACE_QUERY_CONTACT_VIEW_BY_CONDITION :string = 'query_contact_view_by_condition';
  public static readonly TRACE_QUERY_CONTACT_VIEW_BY_CONDITION_ID:number = 1108;

  //conversationList 会话列表trace点
  public static readonly TRACE_CONVERSATION_LIST_CONTROLLER_ON_INIT :string = 'conversation_list_controller_on_init';
  public static readonly TRACE_CONVERSATION_LIST_CONTROLLER_ON_INIT_ID:number = 2001;

  public static readonly TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW :string = 'conversation_list_controller_on_show';
  public static readonly TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW_ID:number = 2002;

  public static readonly TRACE_CONVERSATION_LIST_ABOUT_TO_APPEAR :string = 'conversation_list_about_to_appear';
  public static readonly TRACE_CONVERSATION_LIST_ABOUT_TO_APPEAR_ID:number = 2003;

  public static readonly TRACE_CONVERSATION_LIST_ON_PAGE_SHOW :string = 'conversation_list_on_page_show';
  public static readonly TRACE_CONVERSATION_LIST_ON_PAGE_SHOW_ID:number = 2004;

  public static readonly TRACE_CONVERSATION_LIST_ABOUT_TO_DISAPPEAR :string = 'conversation_list_about_to_disappear';
  public static readonly TRACE_CONVERSATION_LIST_ABOUT_TO_DISAPPEAR_ID:number = 2005;

  public static readonly TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE :string = 'conversation_list_query_first_page';
  public static readonly TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE_ID:number = 2006;

  public static readonly TRACE_CONVERSATION_SEND :string = 'conversation_mms_send';
  public static readonly TRACE_CONVERSATION_SEND_ID:number = 3001;

  public static readonly TRACE_CONVERSATION_INIT_MMS :string = 'conversation_mms_init_mms_item';
  public static readonly TRACE_CONVERSATION_INIT_MMS_ID:number = 3002;

  public static readonly TRACE_CONVERSATION_SEND_INTERVAL :string = 'conversation_mms_send_interval';
  public static readonly TRACE_CONVERSATION_SEND_INTERVAL_ID:number = 3003;

  public static readonly TRACE_CONVERSATION_INSERT_INIT_DATA :string = 'conversation_mms_insert_init_data';
  public static readonly TRACE_CONVERSATION_INSERT_INIT_DATA_ID:number = 3004;

  public static readonly TRACE_CONVERSATION_SEND_MMS_MESSAGE :string = 'conversation_mms_send_mms_message';
  public static readonly TRACE_CONVERSATION_SEND_MMS_MESSAGE_ID:number = 3005;

  public static readonly TRACE_CONVERSATION_UPDATE_MMS_SESSION :string = 'conversation_mms_update_session';
  public static readonly TRACE_CONVERSATION_UPDATE_MMS_SESSION_ID:number = 3006;

  public static readonly TRACE_CONVERSATION_SMS_SEND_MMS :string = 'conversation_sms_send_mms';
  public static readonly TRACE_CONVERSATION_SMS_SEND_MMS_ID:number = 3007;

  public static readonly TRACE_CONVERSATION_INSERT_SESSION_DETAIL :string = 'conversation_insert_session_detail';
  public static readonly TRACE_CONVERSATION_INSERT_SESSION_DETAIL_ID:number = 3008;

  public static readonly TRACE_QUERY_SATELLITE_DATA_BY_CONDITION :string = 'query_Satellite_data_by_condition';
  public static readonly TRACE_QUERY_SATELLITE_DATA_BY_CONDITION_ID:number = 1101;
  //搜索相关TRACE ,下标统一以31开始
  public static readonly TRACE_SEARCH_MAIN_PROCESS: string = 'search_00_main_process'
  public static readonly TRACE_SEARCH_MAIN_PROCESS_ID: number = 3100;
  public static readonly TRACE_SEARCH_TRIGGERING: string = 'search_01_triggering'
  public static readonly TRACE_SEARCH_TRIGGERING_ID: number = 3101;
  public static readonly TRACE_SEARCH_ACTIVE_TRIGGERING: string = 'search_02_active_triggering';
  public static readonly TRACE_SEARCH_ACTIVE_TRIGGERING_ID: number = 3102;
  public static readonly TRACE_AFTER_SEARCH_FUSION: string = 'search_03_fusion';
  public static readonly TRACE_AFTER_SEARCH_FUSION_ID: number = 3103;
  public static readonly TRACE_SEARCH_FUSION_SESSION: string = 'search_0301_search_fusion_session';
  public static readonly TRACE_SEARCH_FUSION_SESSION_ID: number = 310301;
  public static readonly TRACE_SEARCH_MESSAGE: string = 'search_0302_search_message';
  public static readonly TRACE_SEARCH_MESSAGE_ID: number = 310302;
  public static readonly TRACE_SEARCH_MESSAGE_CREATE: string = 'search_030201_search_message_create';
  public static readonly TRACE_SEARCH_MESSAGE_CREATE_ID: number = 31030201;
  public static readonly TRACE_SEARCH_MESSAGE_ACTIVATE: string = 'search_030201_search_message_create';
  public static readonly TRACE_SEARCH_MESSAGE_ACTIVATE_ID: number = 31030202;
}

