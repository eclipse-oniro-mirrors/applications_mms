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
import hiLog from '../../utils/HiLog';
import commonData from '../../data/commonData';
import MMCameraInvocation from './MMCameraInvocation'
import MMPictureController from '../../views/AttachmentArea/MMPictureController'
import DeviceUtil from '../../utils/DeviceUtil';
import ReceiveController from '../receive/receiveController';
import ConversationController, {
  itemType,
  rcsFileInfo
} from '../../pages/conversation/conversationController';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import { contact } from '@kit.ContactsKit';
import HiLog from '../../utils/HiLog';
import { ContactType } from '../../utils/TypesUtils';
import MMMapController from './MMMapController'
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { SplitInfoModel, SplitScreenManager } from '../../utils/SplitScreenManager';
import CreateNewConversationViewModle from '../../pages/conversation/CreateNewConversationViewModle';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { seleteParam } from '../../utils/MmsDot/DotCommon';
import LooseObject from '../../data/LooseObject';
import ConversationService from '../../service/ConversationService';
import { util } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import DateUtil from '../../utils/DateUtil';
import FileUtil from '../../utils/FileUtil';
import myCommon from '@ohos.app.ability.common';
import common from '../../data/commonData';

const TAG = 'EnhancedInfoTabs';
const MIN_MM_PICKER_HEIGHT: number = 112;

@Component
export default struct EnhancedInfoTabs {
  @Link fullHeightMMPicker: boolean;
  @Link topMMContentPicker: number;
  @Link heightMMContentPicker: number;
  @Link currentIndex: number;
  @Link textareaFocusable: boolean;
  @Link showMMContentPicker: boolean;
  @Link recorderPermission: boolean;
  @Link picturePermission: boolean;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @LocalStorageProp('windowHeight') windowHeight: number = 0;
  @State mmPictureController: MMPictureController = MMPictureController.getInstance()
  @State isShow: boolean = false;
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  @Prop isRcs?: boolean = false;
  @State mReceiveController: ReceiveController = ReceiveController.getInstance();
  singleContacts: itemType = new itemType();
  selectContacts: itemType[] = [this.singleContacts];
  @State mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @State mapController: MMMapController = MMMapController.getInstance();
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @ObjectLink mCreateNewConversationViewModle: CreateNewConversationViewModle;
  //是否是新建信息
  @Prop mIsNew: boolean = false;
  private scaledDensity = DeviceUtil.getDeviceScaledDensity();
  @State splitInfoModel: SplitInfoModel = SplitScreenManager.getInstance().infoModel;
  onAudioTouch: (e: TouchEvent) => void = () => {
  };
  @Prop isChatbotConversation: boolean = false
  /**
   * 新建会话页面中处理收件人的逻辑,主要是校验收件人输入框数据和给收件人赋值
   */
  public handleReceiveContactsData = async () => {
  }

  @Builder
  GridItemContent(icon: Resource, name: ResourceStr, index: number) {
    Column() {
      SymbolGlyph(icon)
        .width('24vp')
        .height('24vp')
        .draggable(false)
        .margin({ bottom: 4 })
        .fontColor([$r('sys.color.ohos_id_color_secondary')])
        .fontSize('24vp');
      Text(name)
        .height(14)
        .fontSize(this.fontSizeScale <= 1.75 ? this.fontSizeScale * 10 + 'vp' : 1.75 * 10 + 'vp')
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
    }
    .backgroundColor($r('sys.color.ohos_id_color_hover'))
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .borderRadius('16vp')
    .padding({ top: 19, bottom: 15 })
    .width(`${76 * this.scaledDensity}px`)
    .height(`${80 * this.scaledDensity}px`)
    .constraintSize({
      maxWidth: '100%',
      maxHeight: '100%'
    })
  }

  aboutToAppear(): void {
    hiLog.i(TAG, 'aboutToAppear');
  }

  isEmptyTxt: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.messageSendFailed'),
      content: $r('app.string.rcs_ft_file_size_zero_error', 0),
      primaryButton: {
        value: $r('app.string.msg_know'),
        action: () => {
        }
      },
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  })
  async onContactClick(context: Context) {
    HiLog.i(TAG, 'onContactClick');
    if (this.mIsNew) {
      this.mCreateNewConversationViewModle.changeVCardJumpBack();
    } else {
      this.mConversationCtrl.changeVCardJumpBack();
    }
    if (this.isChatbotConversation) {
      AppStorage.setOrCreate('isNeedHideSuggestions', true);
    }
    let contacts: void | contact.Contact[] = await this.mReceiveController.selectContactsByPicker();
    if (!contacts || contacts.length === 0) {
      HiLog.iw(TAG, `onContactClick: selectContactsByPicker No selection`);
      this.mConversationCtrl.changeVCardJumpBackNeedFresh();
      return;
    }

    await this.handleReceiveContactsData();
    let contactIds: number[] = [];
    let afterContacts: ContactType[] = contacts.map(contact => {
      let telephonesStr = contact.phoneNumbers ? contact.phoneNumbers.map(v => (v.phoneNumber)).join(',') : '';
      // 联系人应用中，联系人号码id和联系人号码类型的对应关系
      const labelMap: LooseObject = {
        1: common.PHONE_NUMBER_TYPE.CELL,
        2: common.PHONE_NUMBER_TYPE.HOME,
        3: common.PHONE_NUMBER_TYPE.WORK,
        4: common.PHONE_NUMBER_TYPE.WORK_FAX,
        5: common.PHONE_NUMBER_TYPE.HOME_FAX,
        6: common.PHONE_NUMBER_TYPE.PAGER,
        7: common.PHONE_NUMBER_TYPE.VOICE,
        12: common.PHONE_NUMBER_TYPE.PREF,
      }
      let telephoneTypes = contact.phoneNumbers ? contact.phoneNumbers.map((v) => ((v?.labelId) ? labelMap[v.labelId] as string : '')).join(',') : '';
      if (contact.id) {
        contactIds.push(contact.id);
      }
      return {
        contactName: contact.name?.fullName || '',
        headImage: contact.portrait?.uri || '',
        telephone: telephonesStr,
        telephoneFormat: telephonesStr,
        select: true,
        id: contact.id,
        telephoneType: telephoneTypes,
      } as ContactType;
    })
    ConversationService.getInstance().queryContactsAvatarInContactDataDataBase(context, Array.from(new Set(contactIds)),
      async (res: LooseObject) => {
      let mapContactIdToAvatarBase64Encoded: Map<number, Uint8Array> = res?.abilityResult || new Map();
      for (let i = 0; (mapContactIdToAvatarBase64Encoded.size > 0 && i < afterContacts.length); i++) {
        if (!afterContacts[i]?.id) {
          continue;
        }
        let mapContactsBit = mapContactIdToAvatarBase64Encoded.get(afterContacts[i].id as number);
        let imageSource = image.createImageSource(mapContactsBit?.buffer);
        if (imageSource) {
          let pixelMap: PixelMap = await imageSource.createPixelMap({ desiredSize: { height: 128, width: 128 } });
          imageSource.release();
          let mapImgName: string = `PART_CONTACTS_${DateUtil.getTimeWithCount()}${'.jpg'}`;
          if (pixelMap) {
            let jpegPath = '/data/storage/el2/base/haps/entry/files/' + mapImgName;
            await FileUtil.packPixelMapToSandBox(this.context, jpegPath, pixelMap, mapImgName);
            pixelMap.release();
            afterContacts[i].photoPath = jpegPath;
          }
        }
        let base64Helper: util.Base64Helper = new util.Base64Helper();
        afterContacts[i].avatarBase64Encoded =
          mapContactsBit ? base64Helper.encodeToStringSync(mapContactsBit, util.Type.BASIC) : '';
      }
      this.selectContacts = afterContacts;
      await this.mmAreaController.setVcard(this.context, this.selectContacts);
      if (this.mmAreaController.rcsDisplaySource.length > 0) {
        if (this.mIsNew) {
          this.mCreateNewConversationViewModle.sendAudio();
        } else {
          this.mConversationCtrl.sendAudio(this.context);
        }
      }
    })
  }
  onFolderClick = async (event: ClickEvent) => {
    if (this.mIsNew) {
      this.mCreateNewConversationViewModle.changeVCardJumpBack();
    } else {
      this.mConversationCtrl.changeVCardJumpBack();
    }
    if (this.isChatbotConversation) {
      AppStorage.setOrCreate('isNeedHideSuggestions', true);
    }
    this.mReceiveController.jumpToFileManagementForResultForMore(this.mIsNew, this.mCreateNewConversationViewModle,
      this.mConversationCtrl,
      async (receiverData: rcsFileInfo) => {
        if (receiverData.isAMRAudioFile) { //从文件中发送增强信息语音消息(.amr文件)的场景
          this.mmAreaController.handleAndSendAudioFile(this.context, receiverData, this.mIsNew, () => {
            HiLog.i(TAG, `onFolderClick: handleAndSendAudioFile callback`);
            this.mCreateNewConversationViewModle.sendAudio();
          });
          return;
        }
        if (this.mIsNew) {
          this.mCreateNewConversationViewModle.sendAudio();
          await this.mmAreaController.setFileInfo(receiverData);
        } else {
          await this.mmAreaController.setFileInfo(receiverData);
          this.mConversationCtrl.sendAudio(this.context);
        }
      }, async () => {
        this.isEmptyTxt.open()
      }, this.handleReceiveContactsData);
  }

  // 判断当前彩信附件区存在vcard后，弹框询问是否替换现有附件
  needReplaceVcard: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.attachment_replace_tip'),
      content: $r('app.string.attachment_replace_dialog_tip'),
      primaryButton: {
        value: $r('app.string.cancel'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          this.needReplaceVcard?.close();
        },
      },
      secondaryButton: {
        value: $r('app.string.ok'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          this.mmAreaController.replaceVcard(this.context, () => {
            MMCameraInvocation.handlePickerRes(this.context)
          })
        }
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
  });

  build() {
    if (this.splitInfoModel.isSmall && (!DeviceUtil.isTablet())) {
      Swiper() {
        Grid() {
          GridItem() {
            this.GridItemContent($r('sys.symbol.camera_fill'), $r('app.string.msg_take_photos'), 0)
          }.onClick(() => {
            hiLog.i(TAG, `CAMERA_index:${0}`);
            this.currentIndex = 0;
            this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.CAMERA
            MMCameraInvocation.invokeCamera(this.context, this.isRcs??false, () => {
              this.needReplaceVcard.open()
            });
          })
          .columnStart(DeviceUtil.isTablet() ? 1 : 0)
          .columnEnd(DeviceUtil.isTablet() ? 1 : 0)
          GridItem() {
            this.GridItemContent($r('sys.symbol.picture_fill'), $r('app.string.msg_picture'), 1);
          }.onClick(() => {
            this.currentIndex = 1;
            this.fullHeightMMPicker = false;
            this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
            hiLog.i(TAG, `PICTURE_index:${1}`);
            this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.GALLERY
            this.mmPictureController.jumpToGalleryOfRCS(this.context, () => {
              this.needReplaceVcard.open()
            });
          })

          GridItem() {
            this.GridItemContent($r('sys.symbol.local_fill'), $r('app.string.msg_location'), 2);
          }
          .onClick(() => {
            // Open map
            this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.MAP
            this.mapController.getLocationAndOpenMap(this.context, () => {
              this.needReplaceVcard.open()
            });
          })

          GridItem() {
            this.GridItemContent($r('sys.symbol.person_2_fill'), $r('app.string.attach_contacts'), 3);
          }.onTouch(e => {
            e.stopPropagation();
          })
          .onClick(() => {this.onContactClick(this.context)})
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .scrollBar(BarState.Off)
        .columnsGap('8vp')
        .rowsGap(8)
        .margin({
          left: 16,
          right: 16
        })
        .height('100%');

        Grid() {
          GridItem() {
            this.GridItemContent($r('sys.symbol.folder_fill'), $r('app.string.attach_anyfile'), 4);
          }.onTouch(e => {
            e.stopPropagation();
          })
          .onClick(this.onFolderClick)

        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .scrollBar(BarState.Off)
        .columnsGap('8vp')
        .rowsGap(8)
        .margin({
          left: 16,
          right: 16
        })
        .height('100%')
      }
    } else {
      Grid() {
        GridItem() {
          this.GridItemContent($r('sys.symbol.camera_fill'), $r('app.string.msg_take_photos'), 0)
        }.onClick(() => {
          seleteParam.SELECT_STATE = 1;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.ADD_ATTACHMENT_RCS);
          hiLog.i(TAG, `CAMERA_index:${0}`);
          this.currentIndex = 0;
          this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.CAMERA
          MMCameraInvocation.invokeCamera(this.context, this.isRcs??false, () => {
            this.needReplaceVcard.open()
          });
        })
        .columnStart(DeviceUtil.isTablet() ? 1 : 0)
        .columnEnd(DeviceUtil.isTablet() ? 1 : 0)

        GridItem() {
          this.GridItemContent($r('sys.symbol.picture_fill'), $r('app.string.msg_picture'), 1);
        }.onClick(() => {
          seleteParam.SELECT_STATE = 2;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.ADD_ATTACHMENT_RCS);
          this.currentIndex = 1;
          this.fullHeightMMPicker = false;
          this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
          hiLog.i(TAG, `PICTURE_index:${1}`);
          this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.GALLERY
          this.mmPictureController.jumpToGalleryOfRCS(this.context, () => {
            this.needReplaceVcard.open()
          });
        })

        GridItem() {
          this.GridItemContent($r('sys.symbol.local_fill'), $r('app.string.msg_location'), 2);
        }
        .onClick(() => {
          seleteParam.SELECT_STATE = 3;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.ADD_ATTACHMENT_RCS);
          // Open map
          this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.MAP
          this.mapController.getLocationAndOpenMap(this.context, () => {
            this.needReplaceVcard.open()
          });
        })

        GridItem() {
          this.GridItemContent($r('sys.symbol.person_2_fill'), $r('app.string.attach_contacts'), 3);
        }.onTouch(e => {
          if (e.type == TouchType.Up) {
            seleteParam.SELECT_STATE = 4;
            DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.ADD_ATTACHMENT_RCS);
          }
          e.stopPropagation();
        })
        .onClick(() => {this.onContactClick(this.context)})

        GridItem() {
          this.GridItemContent($r('sys.symbol.folder_fill'), $r('app.string.attach_anyfile'), 4);
        }.onTouch(e => {
          if (e.type == TouchType.Up) {
            seleteParam.SELECT_STATE = 5;
            DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.ADD_ATTACHMENT_RCS);
          }
          e.stopPropagation();
        })
        .onClick(this.onFolderClick);
      }
      .rowsTemplate(DeviceUtil.isTablet() ? '1fr' : '1fr 1fr')
      .columnsTemplate(DeviceUtil.isTablet() ? '1fr 1fr 1fr 1fr 1fr' : '1fr 1fr 1fr 1fr')
      .columnsGap('8vp')
      .rowsGap(8)
      .padding({ top: 16, bottom: 16 })
      .margin({
        left: 16,
        right: 16
      })
      .height('100%')
    }
  }
}