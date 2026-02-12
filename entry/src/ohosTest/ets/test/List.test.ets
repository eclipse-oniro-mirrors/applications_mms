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
import UserUtilTest from './utils/UserUtil.test'
import JudgeNetWorkTest from './service/JudgeNetWork.test'
import PasteboardTest from './data/Pasteboard.test'
import ScreenAdapterUtilsTest from './utils/ScreenAdapterUtils.test'
import el1PreferencesHelperTest from './utils/el1PreferencesHelper.test'
import WantUtilToolsTest from './utils/WantUtilTools.test'
import QuerySmsMmsInfoActionDataTest from './model/type/QuerySmsMmsInfoActionData.test'
import MmsUriGrantStubTest from './ServiceExtension/servers/stub/MmsUriGrantStub.test'
import UnlockConversationListServiceTest from './service/UnlockConversationListService.test'
import SystemModeTest from './utils/SystemMode.test'
import LowMemoryCameraControllerTest from './pages/lowMemoryCamera/LowMemoryCameraController.test'
import NextDbHelperTest from './backup/copyData/NextDbHelper.test'
import DbHelperTest from './backup/copyData/DbHelper.test'
import VCardUtilTest from './utils/VCardUtil.test'
import MmsDownloadModelTest from './model/MmsDownloadModel.test'
import SystemSoundManagerUtilTest from './utils/SystemSoundManagerUtil.test'
import BackupRestoreRpcTest from './ServiceExtension/BackupRestoreRpc.test'
import TimeUtilsTest from './pages/smc/utils/TimeUtils.test'
import SystemDateTimeUtilTest from './utils/SystemDateTimeUtil.test'
import MMsFileDeleteUtilTest from './utils/MMsFileDeleteUtil.test'
import SlidePreviewListDataSourceTest from './model/SlidePreviewListDataSource.test'
import DatabaseMaintainTest from './DatabaseMaintain.test'
import GlobalHelperTest from './model/GlobalHelper.test'
import SplitScreenManagerTest from './utils/SplitScreenManager.test'
import MmsDownloadServiceTest from './service/MmsDownloadService.test'
import StorageMessageTimeoutTest from './pages/conversation/StorageMessageTimeout.test'
import DeskDialogProxyTest from './flashMessage/DeskDialogProxy.test'
import DeskDialogExtensionAbilityTest from './flashMessage/DeskDialogExtensionAbility.test'
import DeskDialogConnectionTest from './flashMessage/DeskDialogConnection.test'
import DataServiceTest from './service/DataService.test'
import SsmUtilsTest from './utils/SsmUtils.test'
import DraftUtilsTest from './utils/DraftUtils.test'
import EnhancedInfoTemporaryDataSourceTest from './model/EnhancedInfoTemporaryDataSource.test'
import sendMsgServiceDTTest from './service/SendMsgService.test'
import SearchUtilTest from './utils/SearchUtil.test'
import ConversationListModelTest from './model/ConversationListModel.test'
import ConversationListServiceTest from './service/ConversationListService.test'
import NotificationServiceTest from './service/NotificationService.test'
import ImageUtilTest from './utils/ImageUtil.test'
import MMAttachmentAreaControllerTest from './views/AttachmentArea/MMAttachmentAreaController.test'
import ConversationListInfoTest from './model/ConversationListInfo.test'
import MmsSearchListDataSourceTest from './model/MmsSearchListDataSource.test'
import ConversationListDataSourceTest from './model/ConversationListDataSource.test'
import ConversationDataSourceTest from './model/ConversationDataSource.test'
import CardModelTest from './model/CardModel.test'
import BaseModelTest from './model/BaseModel.test'
import BaseDataSourceTest from './model/BaseDataSource.test'
import SettingModelTest from './model/SettingsModel.test'
import MmsModelTest from './backup/MmsModel.test'
import MmsAvatarControllerTest from './views/MmsAvatar/MmsAvatarController.test'
import MmsSearchServiceTest from './service/MmsSearchService.test'
import SettingServiceTest from './service/SettingService.test'
import MmsPresenterTest from './backup/MmsPresenter.test'
import HighlightTest from './utils/Highlight.test'
import DeviceUtilTest from './utils/DeviceUtil.test'
import DateUtilTest from './utils/DateUtil.test'
import TelephoneUtilTest from './utils/TelephoneUtil.test'
import StringUtilTest from './utils/StringUtil.test'
import DataWorkerTaskTest from './workers/dataWorkerTask.test'
import groupContactListControllerTest from './pages/groupcontactlist/groupContactListController.test'
import IndexControllerTest from './pages/indexController.test'
import FileUtilTest from './utils/FileUtil.test'
import MmsUtilTest from './utils/MmsUtil.test'
import SmilFileTest from './utils/SmilFile.test'
import WantUtilTest from './utils/WantUtil.test'
import DoubleClickUtilTest from './utils/DoubleClickUtil.test'
import ConversationServiceTest from './service/ConversationService.test'
import MessageUtilTest from './cust/utils/MessageUtil.test'
import OperatorConfigUtilTest from './cust/utils/OperatorConfigUtil.test';
import ContactsServiceTest from './service/ContactService.test'
import MMPictureControllerTest from './views/AttachmentArea/MMPictureController.test'
import MMRecorderControllerTest from './views/AttachmentArea/MMRecorderController.test'
import AudioPlayerServiceTest from './service/AudioPlayService.test'
import MmsReceiveTest from './views/MmsReceive/mmsReceiveMain.test'
import DataShareHelperTest from './model/repository/DataShareHelper.test'
import transmitMsgControllerTest from './pages/transmitmsg/transmitMsgController.test'
import queryReportControllerTest from './pages/queryreport/queryReportController.test'
import groupDetailControllerTest from './pages/groupdetail/groupDetailController.test'
import transmitSearchMsgControllerTest from './pages/transmitmsg/transmitSearchMsgController.test'
import favoriteControllerTest from './pages/favoritepage/favoriteController.test'
import TabUtilTest from './utils/TabUtil.test'
import PreferenceUtilTest from './backup/PreferenceUtil.test'
import BackupExtensionTest from './backup/BackupExtension.test'
import ImageBoundsUtilTest from './utils/ImageBoundsUtil.test'
import CopyDbDataHelperTest from './backup/CopyDbDataHelper.test'
import FileUtilsTest from './utils/FileUtils.test'
import cardMmsListDataSourceTest from './model/CardMmsListDataSource.test'
import contactsModelTest from './model/ContactsModel.test'
import conversationModelTest from './model/ConversationModel.test'
import mMPictureDataSourceTest from './model/MMPictureDataSource.test'
import morkDataModelTest from './model/MorkDataModel.test'
import transmitMsgDataSourceTest from './model/TransmitMsgDataSource.test'
import transmitSearchListDataSourceTest from './model/TransmitSearchListDataSource.test'
import yellowPageModelTest from './model/YellowPageModel.test'
import groupDetailServiceTest from './service/GroupDetailService.test'
import simCardServiceTest from './service/SimCardService.test'
import blockedClientProxyTest from './ServiceExtension/servers/proxy/BlockedClientProxy.test'
import blockedServiceProxyTest from './ServiceExtension/servers/proxy/BlockedServiceProxy.test'
import blockedListExtAbilityTest from './uiExtensionAbility/BlockedListExtAbility.test'
import smartMmsServiceRpcServiceTest from './ServiceExtension/servers/smartRpc/SmartMmsServiceRpcService.test'
import receiveServiceTest from './StaticSubscriber/ReceiveService.test'
import mmsStaticSubscriberTest from './StaticSubscriber/MmsStaticSubscriber.test'
import serviceExtAbilityTest from './StaticSubscriber/ServiceExtAbility.test'
import checkUtilTest from './utils/CheckUtil.test'
import dynamicLoaderTest from './utils/DynamicLoader.test'
import dotUtilTest from './utils/MmsDot/DotUtil.test'
import sharedPreferencesUtilsTest from './utils/SharedPreferencesUtils.test'
import windowsManagerTest from './utils/MmsWindowsManager.test'
import workFactoryTest from './workers/WorkFactory.test'
import mainAbilityTest from './MainAbility/MainAbility.test'
import conversationLCtrPart1Test from './pages/conversationlist/conversationListController.part1.test'
import conversationLCtrPart2Test from './pages/conversationlist/conversationListController.part2.test'
import fullImageDisplayControlerTest from './pages/FullImage/FullImageDisplayControler.test'
import manageSimControllerTest from './pages/managesim/ManageSimController.test'
import infoMsgControllerTest from './pages/infomsg/InfoMsgControllerTest.test'
import settingsControllerTest from './pages/settings/settingsController.test'
import oobeResultTest from './oobe/oobeResult.test'
import audioRecorderServiceTest from './service/AudioRecorderService.test'
import callServiceTest from './service/CallService.test'
import commonServiceTest from './service/CommonService.test'
import yellowPageServiceTest from './service/YellowPageService.test'
import advancedSettingsControllerTest from './pages/settings/advancedSettings/AdvancedSettingsController.test'
import oobeStatementAbilityPrivacyTest from './oobe/oobeStatementAbilityPrivacy.test'
import dataCleanerServiceTest from './service/DataCleanerService.test'
import receiveControllerTest from './views/receive/receiveController.test'
import MMMapControllerTest from './views/AttachmentArea/MMMapController.test'
import LocationUtilTest from './utils/LocationUtil.test'
import imageCompressionTest from './utils/ImageCompression.test'
import reportParameterHelperTest from './report/common/ReportParameterHelper.test'
import reportConnectCloudCallbackTest from './report/hsdr/callback/ReportConnectCloudCallback.test'
import connectionCloudHandlerTest from './report/request/ConnectionCloudHandler.test'
import encryptionHandlerTest from './report/request/EncryptionHandler.test'
import signatureHandlerTest from './report/request/SignatureHandler.test'
import mmsPreferencesTest from './utils/MmsPreferences.test'
import conversationControllerPart1Test from './pages/conversation/conversationControllerPat1.test'
import conversationControllerPart2Test from './pages/conversation/conversationControllerPat2.test'
import conversationControllerPart3Test from './pages/conversation/conversationControllerPat3.test'
import conversationControllerPart4Test from './pages/conversation/conversationControllerPat4.test'
import conversationControllerPart5Test from './pages/conversation/conversationControllerPat5.test'
import conversationControllerPart6Test from './pages/conversation/conversationControllerPat6.test'
import conversationControllerPart7Test from './pages/conversation/conversationControllerPat7.test'
import mmsContactServiceExtAbilityTest from './ServiceExtension/servers/MmsContactServiceExtAbility.test'
import mmsContactClientProxyTest from './ServiceExtension/servers/proxy/MmsContactClientProxy.test'
import mmsContactDataClientProxyTest from './ServiceExtension/servers/proxy/MmsContactDataClientProxy.test'
import mmsContactDataProxyTest from './ServiceExtension/servers/proxy/MmsContactDataProxy.test'
import mmsContactProxyTest from './ServiceExtension/servers/proxy/MmsContactProxy.test'
import mmsContactHandlerTest from './ServiceExtension/servers/service/MmsContactHandler.test'
import customNavigationUtilsTest from './utils/CustomNavigationUtils.test'
import uRLRegexRecognizerTest from './utils/URLRegexRecognizer.test'
import hiFaultEventUtilTest from './report/event/HiFaultEventUtil.test'
import reportSpamMessageManagerTest from './report/ReportSpamMessageManager.test'
import PatternControlTest from './pages/PatternControl.test'
import deskDialogAbilityTest from './flashMessage/DeskDialogAbility.test'
import SlidePreviewControllerTest from './pages/slidePreview/SlidePreviewController.test'
import TimeLockTest from './utils/Locks/TimeLock.test'
import CreateNewConversationViewModleTest from './pages/conversation/CreateNewConversationViewModle.test'
import AccessibilityUtilTest from './utils/AccessibilityUtil.test'
import ConversationMessageTimeoutTest from './pages/conversation/ConversationMessageTimeout.test'
import VibrationUtilsTest from './utils/VibrationUtils.test'
import UserPhotoUtilTest from './utils/UserPhotoUtil.test'
import FilingNoTest from './pages/private/FilingNo.test'
import StringBuilderTest from './utils/StringBuilder.test'
import VCardPropertyTest from './utils/VCardProperty.test'
import TransmitMessageUtilsTest from './utils/TransmitMessageUtils.test'
import NetUtilsTest from './utils/NetUtils.test'
import IdlServiceProxyTest from './report/hsdr/model/IdlServiceProxy.test'
import VCardParserTest from './utils/VCardParser.test'
import ConversationListToolTest from './pages/conversationlist/conversationListTool.test'
import DragUtilTest from './utils/DragUtil.test'
import UnLockedNotifyServiceTest from './utils/UnLockedNotifyService.test'
import dotStateFuncTest from './utils/MmsDot/dotStateFunc.test'
import UnlockConversationServiceTest from './service/UnlockConversationService.test'
import MmsUriGrantHandlerTest from './ServiceExtension/servers/service/MmsUriGrantHandler.test'
import AiFaceChangeUtilsTest from './utils/AiFaceChangeUtils.test'
import UnlockConversationModelTest from './model/UnlockConversationModel.test'
import RcsLoginUtilTest from './utils/RcsLoginUtil.test'
import PanGestureUtilTest from './utils/PanGestureUtil.test'
import conversationControllerPart8Test from './pages/conversation/conversationControllerPat8.test';
import conversationIpServiceTest from './service/ConversationIpService.test';
import DistributedUtilTest from './utils/DistributedUtil.test'
import LogConductTest from './log/LogConduct.test';
import LoggerTest from './log/Logger.test';
import CheckerUnitTest from './log/Checker.test';
import DateUtilUnitTest from './log/DateUtil.test';

export default function testsuite() {
  serviceExtAbilityTest()
  BackupExtensionTest()
  MmsModelTest()
  MmsUriGrantHandlerTest()
  PanGestureUtilTest()
  ScreenAdapterUtilsTest()
  sharedPreferencesUtilsTest()
  DbHelperTest()
  el1PreferencesHelperTest()
  NextDbHelperTest()
  ConversationListDataSourceTest()
  DeskDialogConnectionTest()
  ConversationMessageTimeoutTest()
  NotificationServiceTest()
  mmsStaticSubscriberTest()
  MMAttachmentAreaControllerTest()
  StringUtilTest()
  TelephoneUtilTest()
  DateUtilTest()
  DeviceUtilTest()
  HighlightTest()
  MmsPresenterTest()
  DataWorkerTaskTest()
  groupContactListControllerTest()
  IndexControllerTest()
  callServiceTest()
  commonServiceTest()
  SettingServiceTest()
  MmsSearchServiceTest()
  FileUtilTest()
  FileUtilsTest()
  MmsUtilTest()
  SmilFileTest()
  WantUtilTest()
  mmsPreferencesTest()
  MmsAvatarControllerTest()
  BaseDataSourceTest()
  SettingModelTest()
  BaseModelTest()
  CardModelTest()
  ConversationDataSourceTest()
  MmsSearchListDataSourceTest()
  ConversationListInfoTest()
  DoubleClickUtilTest()
  ImageUtilTest()
  OperatorConfigUtilTest()
  MessageUtilTest()
  ConversationListServiceTest()
  settingsControllerTest()
  ConversationListModelTest()
  SearchUtilTest()
  sendMsgServiceDTTest()
  ContactsServiceTest()
  MMPictureControllerTest()
  MMRecorderControllerTest()
  AudioPlayerServiceTest()
  MmsReceiveTest()
  DataShareHelperTest()
  CopyDbDataHelperTest()
  transmitMsgControllerTest()
  transmitSearchMsgControllerTest()
  queryReportControllerTest()
  groupDetailControllerTest()
  ConversationServiceTest()
  favoriteControllerTest()
  TabUtilTest()
  PreferenceUtilTest()
  ImageBoundsUtilTest()
  EnhancedInfoTemporaryDataSourceTest()
  cardMmsListDataSourceTest()
  contactsModelTest()
  conversationModelTest()
  mMPictureDataSourceTest()
  morkDataModelTest()
  transmitMsgDataSourceTest()
  transmitSearchListDataSourceTest()
  yellowPageModelTest()
  conversationIpServiceTest();
  groupDetailServiceTest()
  simCardServiceTest()
  blockedClientProxyTest()
  blockedServiceProxyTest()
  blockedListExtAbilityTest()
  smartMmsServiceRpcServiceTest()
  receiveServiceTest()
  checkUtilTest()
  dynamicLoaderTest()
  dotUtilTest()
  windowsManagerTest()
  workFactoryTest()
  mainAbilityTest()
  conversationLCtrPart1Test()
  conversationLCtrPart2Test()
  fullImageDisplayControlerTest()
  manageSimControllerTest()
  infoMsgControllerTest()
  oobeResultTest()
  audioRecorderServiceTest()
  yellowPageServiceTest()
  advancedSettingsControllerTest()
  oobeStatementAbilityPrivacyTest()
  dataCleanerServiceTest()
  receiveControllerTest()
  MMMapControllerTest()
  LocationUtilTest()
  imageCompressionTest()
  reportParameterHelperTest()
  reportConnectCloudCallbackTest()
  connectionCloudHandlerTest()
  encryptionHandlerTest()
  signatureHandlerTest()
  SystemModeTest()
  LowMemoryCameraControllerTest()
  conversationControllerPart1Test()
  conversationControllerPart2Test()
  conversationControllerPart3Test()
  conversationControllerPart4Test()
  conversationControllerPart5Test()
  conversationControllerPart6Test()
  conversationControllerPart7Test()
  conversationControllerPart8Test();
  mmsContactServiceExtAbilityTest()
  mmsContactClientProxyTest()
  mmsContactDataClientProxyTest()
  mmsContactDataProxyTest()
  mmsContactProxyTest()
  mmsContactHandlerTest()
  DraftUtilsTest()
  customNavigationUtilsTest()
  uRLRegexRecognizerTest()
  hiFaultEventUtilTest()
  reportSpamMessageManagerTest()
  PatternControlTest()
  deskDialogAbilityTest()
  SsmUtilsTest()
  SlidePreviewControllerTest()
  TimeLockTest()
  DataServiceTest()
  DeskDialogExtensionAbilityTest()
  DeskDialogProxyTest()
  StorageMessageTimeoutTest()
  MmsDownloadServiceTest()
  SplitScreenManagerTest()
  NetUtilsTest()
  TransmitMessageUtilsTest()
  GlobalHelperTest()
  DatabaseMaintainTest()
  CreateNewConversationViewModleTest()
  AccessibilityUtilTest()
  SlidePreviewListDataSourceTest()
  SystemDateTimeUtilTest()
  MMsFileDeleteUtilTest()
  TimeUtilsTest()
  FilingNoTest()
  VibrationUtilsTest()
  UserPhotoUtilTest()
  StringBuilderTest()
  VCardPropertyTest()
  BackupRestoreRpcTest()
  SystemSoundManagerUtilTest()
  IdlServiceProxyTest()
  VCardParserTest()
  VCardUtilTest()
  MmsDownloadModelTest()
  ConversationListToolTest()
  DragUtilTest()
  UnLockedNotifyServiceTest()
  dotStateFuncTest()
  UnlockConversationServiceTest()
  UnlockConversationListServiceTest()
  MmsUriGrantStubTest()
  QuerySmsMmsInfoActionDataTest()
  UnlockConversationModelTest()
  AiFaceChangeUtilsTest()
  RcsLoginUtilTest()
  WantUtilToolsTest()
  DistributedUtilTest()
  PasteboardTest()
  JudgeNetWorkTest()
  UserUtilTest()
  LogConductTest()
  LoggerTest()
  CheckerUnitTest()
  DateUtilUnitTest()
}