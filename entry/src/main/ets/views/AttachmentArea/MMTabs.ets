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
import MMRecorder from './MMRecorder';
import HiLog from '../../utils/HiLog';
import commonData from '../../data/commonData';
import MMCameraInvocation from './MMCameraInvocation'
import MpictureController from '../../views/AttachmentArea/MMPictureController'
import MMRecorderController, { PermissionContainDialogShown } from '../../views/AttachmentArea/MMRecorderController';
import lazy { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import DeviceUtil from '../../utils/DeviceUtil';
import { PermissionDialog } from '../../views/PermissionDialogs';
import dotCommon, { onlyStateParam, seleteParam, seleteFailParam } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import myCommon from '@ohos.app.ability.common';
import ReceiveController from '../receive/receiveController';
import { SelectContactDialog } from './SelectContactDialog'
import { contact } from '@kit.ContactsKit';
import { SystemMode } from '../../utils/SystemMode';
import { AddressInfo } from '../../utils/TypesUtils';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import TelephoneUtil from '../../utils/TelephoneUtil';
import LocationUtil from '../../utils/LocationUtil';
import display from '@ohos.display';
import { NetUtils } from '../../utils/NetUtils';
import geoLocationManager from '@ohos.geoLocationManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { bundleManager } from '@kit.AbilityKit';
import { geoLocationManager  as GLM} from '@kit.LocationKit';


export class LocationInfoStruct {
  public isSuccess: boolean = false;
  public data: string | undefined = '';
  public hasPermission?: boolean = true;
}

const TAG = 'MMTabs ';
const MIN_MM_PICKER_HEIGHT: number = 112;

@Component
export default struct MMTabs {
  @Link fullHeightMMPicker: boolean;
  @Link topMMContentPicker: number;
  @Link heightMMContentPicker: number;
  @Link currentIndex: number;
  @Link textareaFocusable: boolean;
  @Link showMMContentPicker: boolean;
  @Link recorderPermission: boolean;
  @State recorderPermissionDialogShown : boolean = false;
  @Link picturePermission: boolean;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @LocalStorageProp('windowHeight') windowHeight: number = 0;
  @State mPictureController: MpictureController = MpictureController.getInstance()
  @State recorderController: MMRecorderController = MMRecorderController.getInstance()
  @StorageLink('recorderIsShow') isShow: boolean = false;
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  @Prop isRcs: boolean;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  private isEnableMessage: boolean = SystemMode.getInstance().isEnableMessage;
  private mReceiveController: ReceiveController = ReceiveController.getInstance();
  private mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  private contacts: contact.Contact[] = [];
  private onTextValueChange: (value:string) => void = () => {};
  @StorageProp('displayOrientation') displayOrientation: number = 0;
  @State longitude:string=''//经度
  @State latitude:string=''//维度
  @State canSearchLocation:boolean=true//能否获取位置

  /**
   * 彩信位置消息的位置数据
   */
  private address: undefined | AddressInfo = undefined;

  @Builder
  recorderBuilder(){
    Row(){
      MMRecorder({
        textareaFocusable: $textareaFocusable,
        showMMContentPicker: $showMMContentPicker,
        recorderPermission: $recorderPermission,
        isShow: $isShow,
        replaceVcardCallBack:() => {
          this.needReplaceVcard.open()
        }
      })
        .width('100%')
        .height('100%')
    }.width('100%')
    .height('100%')
  }
  recorderPermissonDialogCtrl: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.message_requires_access_to_microphone'),
      content: $r('app.string.open_microphone_permission_info'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          this.recorderPermissonDialogCtrl.close();
          onlyStateParam.STATE = 2;
          DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.RECORDER_PERMISSION_BUTTON);
        },
      },
      secondaryButton: {
        value: $r('app.string.go_setting'),
        action: () => {
          HiLog.i(TAG, 'recorderPermissonDialogCtrl confirm');
          this.recorderController.permissionOnSetting(getContext(this));
          this.recorderPermissonDialogCtrl.close();
          onlyStateParam.STATE = 1;
          DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.RECORDER_PERMISSION_BUTTON);
        }
      },
    }),
    backgroundColor:$r('sys.color.ohos_id_color_dialog_bg'),
    autoCancel: false,
    alignment: DialogAlignment.Center
  })

  @Styles listItemNormalStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_hover'))
  }
  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect') )
  }
  @Builder
  GridItemContent(icon: Resource, name: ResourceStr, index: number) {
    Row() {
      Blank()
      Column() {
        SymbolGlyph(icon)
          .width('24vp')
          .height('24vp')
          .draggable(false)
          .margin({ bottom: 3 })
          .margin({ bottom: 4 })
          .fontColor([$r('sys.color.ohos_id_color_secondary')])
          .fontSize('24vp')
        Text(name)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .textAlign(TextAlign.Center)
      }
      .backgroundColor($r('sys.color.ohos_id_color_hover'))
      .height('100%')
      .width('76vp')
      .justifyContent(FlexAlign.Center)
      .borderRadius('16vp')
      .stateStyles({
        normal: this.listItemNormalStyles,
        pressed: this.pressedStyles
      })
      .constraintSize({
        maxWidth: '100%',
        maxHeight: '100%'
      })
      Blank()
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    HiLog.i(TAG, 'aboutToAppear');
  }
  aboutToDisappear(): void {
    this.locationOff()
  }

  private mmSelectContactDialog: CustomDialogController = new CustomDialogController({
    builder: SelectContactDialog({
      contacts: this.contacts,
      onTextValueChange: this.onTextValueChange,
    }),
    autoCancel: true,
    cancel: () => {
      this.mmSelectContactDialog?.close();
    },
    alignment: DialogAlignment.Center,
    offset: {
      dx: 0, dy: $r('app.float.new_dialog_bottom_margin')
    },
  })

  async onContactClick() {
    let contacts: void | contact.Contact[] = await this.mReceiveController.selectContactsByPicker();
    if (!contacts || contacts.length === 0) {
      HiLog.i(TAG, `onContactClick: selectContactsByPicker No selection`);
      return;
    }
    // 写信息——添加附件——事件打点
    seleteParam.SELECT_STATE = commonData.int.TYPE_STATE_VCARD;
    DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.WRITE_ATTACHMENTS_AREA);
    this.contacts = contacts
    this.mmSelectContactDialog.open()
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
          this.mmAreaController.resetMmsAndDeleteSource(this.context);
          // 添加附件的操作，是否来自替换附件弹框
          let fromReplace: boolean = true
          if (this.mmAreaController.curMmsAttachmentType === commonData.MM_SELECT_ATTACHMENT_TYPE.GALLERY) {
            this.mPictureController.handlePhotoSelectResult(this.context, fromReplace)
          } else if (this.mmAreaController.curMmsAttachmentType === commonData.MM_SELECT_ATTACHMENT_TYPE.CAMERA) {
            MMCameraInvocation.handlePickerRes(this.context, fromReplace)
          } else if (this.mmAreaController.curMmsAttachmentType === commonData.MM_SELECT_ATTACHMENT_TYPE.RECORD) {
            this.recorderController.handleStopRecording(this.context, fromReplace)
          } else if (this.mmAreaController.curMmsAttachmentType === commonData.MM_SELECT_ATTACHMENT_TYPE.MAP) {
            this.mmAreaController.handleLocationOfMms(this.getUIContext()?.getHostContext(), this.getUIContext(),
              this.address, fromReplace);
          }
        }
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
  });

  async  getTokenId(callback: Function) {
    let tokenId: number;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
      callback(tokenId);
    } catch (err) {
      HiLog.e(TAG, `Failed to get bundle info for self. Code is ${(err as BusinessError).code}` +
        `, message is ${(err as BusinessError).message}`);
    }
  }

  checkLocationPermission(callback: (res: boolean) => void) {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
    this.checkAccessToken(permissions[0], (grantStatus:ESObject) => {
      HiLog.i(TAG, `grantStatus:` + grantStatus);
      if (!grantStatus) {
        callback(true);
      } else {
        callback(false);
      }
    });
  }

  checkAccessToken(permission: Permissions, callback: (result: abilityAccessCtrl.GrantStatus) => void) {
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus;
    try {
      this.getTokenId((tokenId: number) => {
        grantStatus = atManager.verifyAccessTokenSync(tokenId, permission);
        HiLog.i(TAG, `checkAccessToken success, data->${grantStatus}`);
        callback(grantStatus);
      });
    } catch (err) {
      HiLog.e(TAG, `getBundleInfoForSelf failed, code is ${err.code}, message is ${err.message}`);
      callback(-1);
    }
  }
  // 定义持续定位参数
  request: GLM.ContinuousLocationRequest= {
    'interval': 1,
    'locationScenario': GLM.UserActivityScenario.NAVIGATION
  }
  // 持续定位回调函数
  locationCallback = (location:GLM.Location):void => {
    // this.getUIContext().getPromptAction().showToast({message:'开启成功'+JSON.stringify(location)})
    HiLog.i(TAG,'locationCallback: data: ' + JSON.stringify(location));
  };
  //卫星监听回调函数
  gnssStatusCb = (satelliteStatusInfo:GLM.SatelliteStatusInfo):void => {
    HiLog.i(TAG,'satelliteStatusChange: ' + JSON.stringify(satelliteStatusInfo));
    // this.getUIContext().getPromptAction().showToast({message:'卫星数量：'+satelliteStatusInfo.satellitesNumber})
  }

  locationOn() {
    // 开启位置监听（持续定位）和卫星监听
    try {
      GLM.on('locationChange', this.request, this.locationCallback);
      GLM.on('satelliteStatusChange', this.gnssStatusCb);
    } catch (err) {
      HiLog.e(TAG, "errCode:" + JSON.stringify(err));
    }
  }

  locationOff() {
    // 关闭位置监听和卫星监听
    GLM.off('locationChange', this.locationCallback);
    GLM.off('satelliteStatusChange', this.gnssStatusCb);
    this.canSearchLocation=true
  }

  getPermissionOfLocation() {
    this.canSearchLocation = false
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      // 上下文为空直接返回失败
      if (!this.context) {
        HiLog.e(TAG, '上下文获取失败，无法申请权限');
        this.canSearchLocation = true
        return;
      }
      // 1. 先检查权限
      this.checkLocationPermission((grantStatus: boolean) => {
        HiLog.i(TAG, '当前权限状态 grantStatus: ' + grantStatus);
        // 有权限 → 直接获取位置
        if (grantStatus) {
          this.locationOn()
          this.getBlurredLocationInfo();
          return;
        }
        // 无权限 → 申请权限
        const permissions: Array<Permissions> = [
          'ohos.permission.APPROXIMATELY_LOCATION',
          'ohos.permission.LOCATION'
        ];
        atManager.requestPermissionsFromUser(this.context, permissions)
          .then((data) => {
            HiLog.i(TAG, '权限申请结果 authResults: ' + JSON.stringify(data.authResults));
            // 只要有一个权限授权成功（0=授权成功）
            const hasPermission = data.authResults.some(result => result === 0);
            if (hasPermission) {
              this.locationOn()
              this.getBlurredLocationInfo();
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: '获取位置权限失败请重试',
              });
              this.canSearchLocation = true
            }
          })
          .catch((err: BusinessError) => {
            HiLog.e(TAG, `申请权限失败 errCode:${err.code}, errMsg:${err.message}`);
            this.canSearchLocation = true
          });
      });
    } catch (err) {
      this.canSearchLocation = true
      const businessError = err as BusinessError;
      HiLog.e(TAG, `getPermissionOfLocation 异常 errCode:${businessError.code}, errMsg:${businessError.message}`);

    }
  }

  /**
   * get blurred location info
   *
   * @param {function} callback - callback of location info
   */
  getBlurredLocationInfo() {
    let requestInfo: geoLocationManager.CurrentLocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,
    };
    let locationChange = (err: BusinessError, location: geoLocationManager.Location) => {
      if (err || !location) {
        this.canSearchLocation = true
        if (err.code===3301100) {
          this.getUIContext().getPromptAction().showToast({
            message: '请打开通知栏位置开关',
          });
        }else{
          this.getUIContext().getPromptAction().showToast({
            message: '获取位置失败请重试 ',
          });
        }
        HiLog.i(TAG, 'getBlurredLocationInfo: err=' + JSON.stringify(err));
        return;
      }
      HiLog.i(TAG, 'getBlurredLocationInfo: '+JSON.stringify(location));
      this.longitude = location.longitude.toString()
      this.latitude = location.latitude.toString()
      this.dealLocationToInputText(this.longitude,this.latitude)
      this.locationOff()
    };
    try {
      geoLocationManager.getCurrentLocation(requestInfo, locationChange);
    } catch (err) {
      HiLog.i(TAG, 'getBlurredLocationInfo catch errCode:' +
      (err as BusinessError).code + ',errMessage:' + (err as BusinessError).message);
      this.locationOff()
    }
  }

  dealLocationToInputText(longitude:string,latitude:string){
    if (!latitude && !longitude) {
      HiLog.i(TAG, 'onContactClick: no LocationToInputText');
      return;
    }
    const text ='经度：'+longitude+'\n'+'维度：'+latitude
    // 赋值最终文本
    this.onTextValueChange(text);
  }

  /**
   * 点击附件功能区里的位置
   */
  onLocationButtonClick = async () => {
    HiLog.i(TAG, 'onLocationButtonClick');
    // 写信息——添加附件——事件打点
    seleteParam.SELECT_STATE = 5;
    seleteParam.MODE_NAME = SystemMode.getInstance().mode;
    DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.WRITE_ATTACHMENTS_AREA);

    try {
      const context = this.getUIContext()?.getHostContext();
      if (!context) {
        HiLog.e(TAG, 'onLocationButtonClick: context empty');
        return;
      }

      //若之前的附件数已达20则提示超出附件上限，不添加该位置消息
      if (this.mmAreaController.isAttachmentUpperLimit()) {
        HiLog.e(TAG, 'onLocationButtonClick: isAttachmentUpperLimit');
        return;
      }
      if (this.canSearchLocation) {
        this.getPermissionOfLocation();
      }
      this.currentIndex = commonData.TAB_TYPE.MAP;
      this.fullHeightMMPicker = false;
      this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;

      // 调用chooseLocation接口拉起 地图服务的地点选取控件
      this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.MAP;
      AppStorage.setOrCreate('selectPicFromGalleryDone', false);

      // this.address = await LocationUtil.chooseLocation(null, context, () => {
      //   // 写信息——添加附件——添加位置-获取地理位置失败
      //   seleteFailParam.MODE_NAME = SystemMode.getInstance().mode;
      //   DotUtil.getInstance().reportEvent(seleteFailParam, dotCommon.eventName.ADD_ATTACHMENT_GET_LOCATION_FAIL);
      // });

      // this.address = new AddressInfo(
      //   30.5928,    // latitude 纬度
      //   114.3055,   // longitude 经度
      //   '武汉',     // name 地点名
      //   '湖北省武汉市xxx地址' // address 详细地址
      // );
      // HiLog.i(TAG, 'onLocationButtonClick: choose address success');
      // const uiContext = this.getUIContext();
      // if (this.mmAreaController.hasNeedReplaceVcard() && this.address) { //处理当前附件待发区有彩信vCard的场景
      //   const netConnectType = await NetUtils.getNetConnectType();
      //   HiLog.i(TAG, 'onLocationButtonClick netConnectType: ' + netConnectType);
      //   if (netConnectType === 'noNet') { //判断网络状态
      //     uiContext.getPromptAction().showToast({
      //       message: $r('app.string.net_no_connection'),
      //       duration: 2000,
      //     });
      //     return;
      //   }
      //   this.needReplaceVcard.open();
      // } else {
      //   this.mmAreaController.handleLocationOfMms(this.getUIContext()?.getHostContext(), uiContext,
      //     this.address);
      // }
    } catch (e) {
      HiLog.e(TAG, `onLocationButtonClick error: ${e?.code} ${e?.message}`);
    }
  }

  build() {
    Grid() {
      /* 根据系统模式展示对应组件 */
      if (this.isEnableMessage) {
        GridItem() {
          this.GridItemContent($r('sys.symbol.camera_fill'), $r('app.string.msg_take_photos'), 0)
        }.onClick(async () => {
          HiLog.i(TAG, `CAMERA_index:${0}`);
          // 写信息——添加附件——事件打点
          seleteParam.SELECT_STATE = 1;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.WRITE_ATTACHMENTS_AREA);
          this.currentIndex = 0;
          this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.CAMERA
          await MMCameraInvocation.invokeCamera(this.context, this.isRcs, () => {
            this.needReplaceVcard.open()
          });
        })
        //平板分为5格，只有3格时，从第二格开始，实现居中显示的效果。
        .columnStart(!this.isEnableMessage && this.mmAreaController.tabsColumnsTemplateValue(
          this.displayOrientation, this.curBp) != '1fr 1fr 1fr' ? 1 : 0)
        .columnEnd(!this.isEnableMessage && this.mmAreaController.tabsColumnsTemplateValue(
          this.displayOrientation, this.curBp) != '1fr 1fr 1fr' ? 1 : 0)

        GridItem() {
          this.GridItemContent($r('sys.symbol.picture_fill'), $r('app.string.msg_picture'), 1);
        }.onClick(async () => {
          this.currentIndex = 1;
          this.fullHeightMMPicker = false;
          this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
          HiLog.i(TAG, `PICTURE_index:${1}`);
          this.mmAreaController.curMmsAttachmentType = commonData.MM_SELECT_ATTACHMENT_TYPE.GALLERY
          this.mPictureController.jumpToGallery(this.context, () => {
            this.needReplaceVcard.open()
          });
          // 写信息——添加附件——事件打点
          seleteParam.SELECT_STATE = 2;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.WRITE_ATTACHMENTS_AREA);
        })

        this.locationGridItem()
        this.loadRecorderGridItem();
        this.contactGridItem();
      } else {
        this.contactGridItem();
      }
    }
    .padding({ top: 16, bottom: 16 })
    .columnsTemplate(this.mmAreaController.tabsColumnsTemplateValue(this.displayOrientation, this.curBp))
    .rowsTemplate(this.mmAreaController.tabsRowsTemplateValue(this.displayOrientation, this.curBp))
    .layoutDirection(GridDirection.Row)
    .maxCount(1)
    .columnsGap('8vp')
    .rowsGap('8vp')
    .margin({
      left: DeviceUtil.isTablet() ? this.padMargin : 16,
      right: DeviceUtil.isTablet() ? this.padMargin : 16
    })
    .height('100%')

  }

  @Builder
  locationGridItem() {
    if (DeviceUtil.isCellularTablet() || DeviceUtil.isCellularPhone()) {
    GridItem() {
      this.GridItemContent($r('sys.symbol.local_fill'), $r('app.string.msg_location'), 2);
    }
    // .visibility((DeviceUtil.isCellularTablet() || DeviceUtil.isCellularPhone())
    //   ? Visibility.Visible : Visibility.Hidden)
    .onClick(this.onLocationButtonClick);
    }
  }

  @Builder
  loadRecorderGridItem(){
    GridItem() {
      this.GridItemContent($r('sys.symbol.mic_fill'), $r('app.string.msg_record'), 2);
    }.onClick(async () => {
      AppStorage.setOrCreate(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD, true);
      this.currentIndex = 2;
      let permissionResults: PermissionContainDialogShown = await this.recorderController
        .initPermissionContainDialogShown('ohos.permission.MICROPHONE');
      this.recorderPermission = permissionResults.authResults === 0;
      this.recorderPermissionDialogShown = permissionResults.dialogShownResults;
      HiLog.i(TAG, 'recorderPermission:' + this.recorderPermission + ',PermissionDialogShown:' + this.recorderPermissionDialogShown)
      if (this.recorderPermission) {
        this.isShow = true;
        // 写信息——添加附件——事件打点
        seleteParam.SELECT_STATE = 3;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.WRITE_ATTACHMENTS_AREA);
      } else if (!this.recorderPermissionDialogShown) {
        this.recorderPermissonDialogCtrl.open();
      }
    })
    .bindSheet(this.isShow, this.recorderBuilder(), {
      height: this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ? 463 : SheetSize.LARGE,
      preferType: SheetType.CENTER,
      showClose: false,
      blurStyle: BlurStyle.Thick,
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        sheetDismiss.dismiss();
        this.isShow = false;
        AppStorage.setOrCreate(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD, false);
      }
    })
  }

  /* 附件区联系人组件 */
  @Builder
  contactGridItem() {
    GridItem() {
      this.GridItemContent($r('sys.symbol.person_2_fill'), $r('app.string.attach_contacts'), 3);
    }.onClick(() => {
      this.onContactClick()
    })
  }
}