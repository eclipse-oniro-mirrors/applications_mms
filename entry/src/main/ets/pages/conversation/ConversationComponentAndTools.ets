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

import ConversationController, { mmsListType, mmsListType as MmsListType } from './conversationController';
import dotCommon, { seleteParam, } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import commonData from '../../data/commonData';
import MmsUtil, {
  getIsMmsMapMessageByMmsSource,
  //getMmsMapLinkShareData,
  isMmsMapMessageByMmsListType, parseAddressInfo } from '../../utils/MmsUtil';
import ConversationDataSource from '../../model/ConversationDataSource';
import HiLog from '../../utils/HiLog';
//import { systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import { Context } from '@kit.AbilityKit';
import myCommon from '@ohos.app.ability.common';
import utd from '@ohos.data.uniformTypeDescriptor';
import DeviceUtil from '../../utils/DeviceUtil';
import { JSON } from '@kit.ArkTS';
import { Stack } from '@kit.ArkTS';
import StringUtil from '../../utils/StringUtil';
import { VCardUtil } from '../../utils/VCardUtil';
import { AddressInfo, ShareExtraData } from '../../utils/TypesUtils';

const TAG = 'ConversationComponentAndTools';


class MenuBuilderObj {
  public mmsListItem: MmsListType = new MmsListType();
  public mConversationCtrl: ConversationController = ConversationController.getInstance();
  public textDirection: string = '';
  //cancelMultiStatus方法执行回调
  public cancelMultiStatusAction: Function = () => {
  };
  //updateBackIcon方法执行回调
  public updateBackIconAction: Function = () => {
  };
  //弹窗执行回调
  public showDialogController: Function = () => {
  };
  // 查看vcard详情的弹窗执行回调
  public showVcardDetailsDialogController?: Function = () => {
  };
  // 保存vcard弹窗执行回调
  public showSaveVcardDialogController?: Function = () => {
  };
}

class MmsItemShareParam {
  public type: number = -1;
  public path: string = '';
  public duration: string = '';
  public ct: string | undefined = '';
  public title: string | undefined = '';
  public originalCt: string | undefined = '';
  public isRcs: number | undefined = undefined;
  public text: string | undefined = '';
}

@Builder
function copyMenuItem(context: Context, data: MenuBuilderObj) {
  // Copy the text
  MenuItem({ content: $r('app.string.msg_copy') })
    .onClick(() => {
      data.mConversationCtrl.longPressSelected(context, 0);
      data.cancelMultiStatusAction();
      // 更多-更多组件打点
      seleteParam.SELECT_STATE = 1;
      DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_MORE_EVENT);
    })
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .enabled(!(data.mmsListItem.isMsm || data.mmsListItem.isMsm && data.mmsListItem.content) ||
    getIsMmsMapMessageByMmsSource(Boolean(data.mmsListItem.isRcs), data.mmsListItem?.mmsSource))
    .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
    .contentFont({ weight: FontWeight.Medium })
    .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
}

@Builder
function showVcardMenuItem(context: Context, data: MenuBuilderObj) {
  MenuItem({ content: data.mmsListItem.isSender === 1 ? $r('app.string.save_to_contacts')
    : $r('app.string.view_vCard_details')})
    .onClick(() => {
      if (data.showVcardDetailsDialogController && data.mmsListItem.isSender === 0) {
        data.showVcardDetailsDialogController();
      }
      if (data.showSaveVcardDialogController && data.mmsListItem.isSender === 1) {
        data.showSaveVcardDialogController();
      }
    })
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .contentFont({ weight: FontWeight.Medium })
    .enabled(VCardUtil.isVcard(data.mmsListItem))
    .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
    .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
  Divider().strokeWidth('app.float.settings_divider_strokeWidth')
    .color($r('sys.color.ohos_id_color_list_separator')).margin({ left: 12, right: 12 })
}

@Builder
function makeMenuItemList(context: Context, data: MenuBuilderObj) {
  copyMenuItem(context, data);
  Divider().strokeWidth('app.float.settings_divider_strokeWidth')
    .color($r('sys.color.ohos_id_color_list_separator')).margin({ left: 12, right: 12 })

  MenuItem({ content: $r('app.string.share') })
    .onChange(() => {
      HiLog.i(TAG, 'onConversationShareOptionClick');
      let target: mmsListType | undefined =
        data.mConversationCtrl.mmsList.find((item: mmsListType) => item.isCbChecked === true)
      shareMessage(target, context);
      data.cancelMultiStatusAction();
      seleteParam.SELECT_STATE = 2;
      DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_MORE_EVENT);
    })
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .contentFont({ weight: FontWeight.Medium })
    .visibility(DeviceUtil.isPC() ? Visibility.None : Visibility.Visible)
    .enabled(
      !(!data.mConversationCtrl.getMmsCount() && !data.mConversationCtrl.hasRcsFileNotDownload) ||
        (data.mmsListItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD ||
        data.mmsListItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.FILE ||
        data.mmsListItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE ||
        MmsUtil.isSlideType(data.mmsListItem.contentType) ||
        data.mmsListItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.MAP ||
        data.mmsListItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD)
        ? false : true)
    .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
    .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
  Divider().strokeWidth('app.float.settings_divider_strokeWidth')
    .color($r('sys.color.ohos_id_color_list_separator')).margin({ left: 12, right: 12 })
    .visibility(DeviceUtil.isPC() ? Visibility.None : Visibility.Visible)

  // Select this text
  MenuItem({ content: $r('app.string.msg_select_text') })
    .onClick(() => {
      data.mConversationCtrl.longPressSelected(context, 3);
      data.cancelMultiStatusAction();
      // 更多-更多组件打点
      seleteParam.SELECT_STATE = 3;
      DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_MORE_EVENT);
    })
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .contentFont({ weight: FontWeight.Medium })
    .enabled(!(data.mmsListItem.isMsm || data.mmsListItem.isMsm && data.mmsListItem.content) ||
    getIsMmsMapMessageByMmsSource(Boolean(data.mmsListItem.isRcs), data.mmsListItem?.mmsSource))
    .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
    .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
  Divider().strokeWidth('app.float.settings_divider_strokeWidth')
    .color($r('sys.color.ohos_id_color_list_separator')).margin({ left: 12, right: 12 })

  // 查看 vCard 详情
  if (VCardUtil.isVcard(data.mmsListItem)) {
    showVcardMenuItem(context, data)
  }

  MenuItem({ content: $r('app.string.query_details') })
    .onChange(() => {
      data.showDialogController();
      data.cancelMultiStatusAction();
      // 更多-更多组件打点
      seleteParam.SELECT_STATE = 4;
      DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_MORE_EVENT);
    })
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
    .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
    .contentFont({ weight: FontWeight.Medium })
}

@Builder
export function MenuBuilder(context: Context, data: MenuBuilderObj) {
  if (ConversationDataSource.getInstance().selectList.length === 1) {
    Column() {
      makeMenuItemList(context, data)
      if (data.mConversationCtrl.hasReport) {
        Divider().strokeWidth('app.float.settings_divider_strokeWidth')
          .color($r('sys.color.ohos_id_color_list_separator')).margin({ left: 12, right: 12 })
        MenuItem({ content: $r('app.string.query_report') })
          .onClick(() => {
            data.mConversationCtrl.moreSelected(context, 6);
            data.updateBackIconAction();
          })
          .width('100%')
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
          .contentFont({ weight: FontWeight.Medium })
          .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
          .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
      }
    }
    .width(216)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
    .onAppear(() => {
      seleteParam.SELECT_STATE = 5;
      DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
    })
  } else if (ConversationDataSource.getInstance().selectList.length > 1) {
    Column() {
      // Copy the text
      MenuItem({ content: $r('app.string.msg_copy') })
        .onClick(() => {
          data.mConversationCtrl.copyMultipeText();
          data.cancelMultiStatusAction();
        })
        .width('100%')
        .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        .enabled(data.mConversationCtrl.mmsCount > 0 ? false : true)
        .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
        .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
        .contentFont({ weight: FontWeight.Medium })
    }.borderRadius($r('sys.float.ohos_id_corner_radius_card'))
    .width(216)
    .alignItems(HorizontalAlign.Start)
    .onAppear(() => {
      seleteParam.SELECT_STATE = 5;
      DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
    })
  }
}

class MaliciousWebObj {
  public mmsListItem: MmsListType = new MmsListType();
  public textDirection: string = '';
  public riskUrlSwitch: boolean = false;
}

@Builder
export function BuildMaliciousWebWarning(data: MaliciousWebObj) {
  // if (data.riskUrlSwitch && (data.mmsListItem?.riskUrlBody === safetyDetect.UrlThreatType.MALWARE.toString() ||
  //   data.mmsListItem?.riskUrlBody === safetyDetect.UrlThreatType.PHISHING.toString() ||
  //   data.mmsListItem?.riskUrlBody === safetyDetect.UrlThreatType.OTHERS.toString())
  // ) {
  //   Flex({
  //     alignItems: ItemAlign.Center,
  //     justifyContent: data.mmsListItem.isReceive ? FlexAlign.Start : FlexAlign.End,
  //   }) {
  //     Row() {
  //       SymbolGlyph($r('sys.symbol.exclamationmark_circle'))
  //         .width(20)
  //         .height(16)
  //         .fontSize('16vp')
  //         .fontColor([$r('sys.color.ohos_id_color_warning')])
  //         .padding(data.textDirection === 'rtl' ? { left: 4 } : { right: 4 })
  //       Text($r('app.string.malicious_web_url'))
  //         .fontSize(10)
  //         .fontColor($r('sys.color.ohos_id_color_text_secondary'))
  //
  //     }
  //     .padding({ top: 8, bottom: 4 })
  //     .margin(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
  //   }
  // }
}

/**
 * 会话页面中分享消息
 * @param target 消息数据
 * @returns
 */
export function shareMmsMessage(target: mmsListType) {
  HiLog.i(TAG, 'shareMmsMessage');
  //是否是彩信位置消息
  let isMmsMapMessage = isMmsMapMessageByMmsListType(Boolean(target?.isRcs), target);
  //let data: systemShare.SharedData | undefined = undefined;
  let mmsShareParamSet: Set<MmsItemShareParam> = new Set<MmsItemShareParam>();
  for (let i = 0; i < target.mmsSource?.length; i++) {
    if (target.mmsSource[i].type != 0) {
      let paramItem = new MmsItemShareParam();
      paramItem.type = target.mmsSource[i].type;
      paramItem.path = target.mmsSource[i].path;
      paramItem.duration = target.mmsSource[i].duration;
      paramItem.originalCt = target.mmsSource[i].ct;
      paramItem.isRcs = target.isRcs;
      paramItem.text = target.mmsSource[i].text;
      if (target.mmsSource[i].ct !== undefined && target.mmsSource[i].ct != '') {
        paramItem.ct = target.mmsSource[i].ct?.split('/')[1];
      }
      if (target.mmsSource[i].content != '') {
        paramItem.title = target.mmsSource[i].content;
      }
      mmsShareParamSet.add(paramItem);
    }
  }
 // let shareRecordStack: Stack<systemShare.SharedRecord> = new Stack();
  mmsShareParamSet.forEach(item => {
    let uri: string = fileUri.getUriFromPath(item.path);
    if (isMmsMapMessage && item.title && typeof item.title === 'string') { //增加位置链接分享选项
      //shareRecordStack.push(getMmsMapLinkShareData(item.title));
    } else if (item.title) {
      // shareRecordStack.push({
      //   utd: utd.UniformDataType.PLAIN_TEXT,
      //   content: item.title as string
      // });
    }
    // 如果分享后的彩信存数据库后字段ct为空.如果特殊的资源文件（无后缀名称）在短信分享后再次分享时MmsUtil.getFileUTD无法获取fileUtd，
    // 会无法拉起分享-使用mmsShareTransferMmsCt 存储于 systemShare.SharedRecord 中的 extraData 字段中由短信接收分享处解析使用
    let extraData: Record<string, string | number | boolean | Array<string | number | boolean>> = {
      'mmsShareTransferMmsCt': ''
    };
    if (!StringUtil.isEmpty(item.originalCt)) {
      HiLog.i(TAG, `shareMessage original ct is: ${item.originalCt}`);
      extraData.mmsShareTransferMmsCt = item.originalCt ?? '';
    }

    let fileUtd = MmsUtil.getFileUTD(item.path, item.ct);
    if (fileUtd != '') {
      if (MmsUtil.isAudio(item.type)) {
        HiLog.i(TAG, 'shareMessage type Audio');
        // shareRecordStack.push({
        //   utd: fileUtd,
        //   uri: uri,
        //   content: item.duration,
        //   extraData: extraData
        // });
      } else if (isMmsMapMessage && MmsUtil.isMmsMapAttach(Boolean(item.isRcs), item.type)) { //彩信位置消息
        HiLog.i(TAG, 'shareMessage type mmsMapMessage ');
        const addressInfo: AddressInfo = parseAddressInfo(item.text) || new AddressInfo(0, 0, '', '');
        // 以下extraData的属性用于将彩信位置消息分享给信息应用的场景
        extraData[ShareExtraData.MESSAGE_TYPE] = commonData.MM_ATTACHMENT_TYPE.MAP;
        extraData[ShareExtraData.MESSAGE_IS_RCS] = Number(item.isRcs);
        extraData[ShareExtraData.MESSAGE_CONTENT] = item.title ?? '';
        extraData[ShareExtraData.MESSAGE_LONGITUDE] = addressInfo.longitude;
        extraData[ShareExtraData.MESSAGE_LATITUDE] = addressInfo.latitude;
        // shareRecordStack.push({
        //   utd: fileUtd,
        //   uri: uri,
        //   extraData: extraData
        // });
      } else if (MmsUtil.isImage(item.type) || MmsUtil.isVideo(item.type) || MmsUtil.isVcard(item.type)) {
        HiLog.i(TAG, 'shareMessage type image or video');
        // shareRecordStack.push({
        //   utd: fileUtd,
        //   uri: uri,
        //   extraData: extraData
        // });
      }
    }
  })

  // if (shareRecordStack.isEmpty()) {
  //   HiLog.i(TAG, 'shareMmsMessage error');
  //   return;
  // }

//  let sharedData = new systemShare.SharedData(shareRecordStack.pop());
//   if (!shareRecordStack.isEmpty()) {
//     shareRecordStack.forEach((item) => {
//       //sharedData.addRecord(item);
//     })
//   }
 // return sharedData;
}

export async function shareMessage(target: mmsListType | undefined, context: Context) {
  HiLog.i(TAG, 'shareMessage start share');
  if (target == undefined) {
    HiLog.e(TAG, 'shareMessage error');
    return;
  }
  try {
    //let data: systemShare.SharedData | undefined = undefined;
    if (target.isMsm) {
     // data = shareMmsMessage(target);
    } else {
      let length = (target.content as string).length;
      let desc = context.resourceManager.
      getPluralStringValueSync($r('app.plural.share_description').id, length);
      // data = new systemShare.SharedData({
      //   utd: utd.UniformDataType.PLAIN_TEXT,
      //   content: target.content as string,
      //   description: desc
      // });
    }
    // if (data != null) {
    //   HiLog.i(TAG, 'shareMessage add data');
    //   let controller: systemShare.ShareController = new systemShare.ShareController(data);
    //   controller.show(context as myCommon.UIAbilityContext, {
    //     previewMode: systemShare.SharePreviewMode.DETAIL,
    //     selectionMode: systemShare.SelectionMode.SINGLE
    //   });
    // }
  } catch (err) {
    HiLog.i(TAG, `message share` + JSON.stringify(err));
  }
}
