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
import LooseObject from '../data/LooseObject';
import HiLog from './HiLog';
import TelephoneUtil from './TelephoneUtil';
import { accessibility } from '@kit.AccessibilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';
import MmsPreferences from './MmsPreferences';
import common from '../data/commonData';
import { DetectResult } from '../pages/conversation/ConversationData';

const TAG = 'AccessibilityUtil ';
const ESIM = 'esim';

class AccessibilityUtil {
  private sendFailed: string = '';
  private draft: string = '';
  private loaded: boolean = false;

  /**
   * 获取sim/esim卡图标对应的无障碍朗读
   *
   * @param slotId 卡槽id
   * @param context 上下文
   * @returns 对应的无障碍朗读
   */
  public getSimIconAccessibilityText(slotId: number, context: Context): string {
    try {
      let slotType = MmsPreferences.getInstance().getTypeOfSlot(slotId);
      let slotIndex = MmsPreferences.getInstance().getIndexOfSlot(slotId);
      HiLog.i(TAG, `getSimIconAccessibilityText ${slotId},${slotType},${slotIndex}`);
      if (slotType === common.simType.ESIM) {
        return ESIM + slotIndex;
      } else {
        return context.resourceManager.getStringSync($r('app.string.sim').id) + slotIndex;
      }
    } catch (err) {
      HiLog.e(TAG, `getSimIconAccessibilityText failed, code is ${err?.code}, message is ${err?.message}`);
    }
    return '';
  }

  /**
   * 获取sim/esim卡图标对应的无障碍朗读
   *
   * @param slotType 卡槽类型
   * @param slotIndex 卡槽index
   * @param context 上下文
   * @returns 对应的无障碍朗读
   */
  public getSimIconAccessibilityTextByType(slotType: number, slotIndex: number, context: Context): string {
    HiLog.i(TAG, `getSimIconAccessibilityTextByType ,${slotType},${slotIndex}`);
    try {
      if (slotType === common.simType.ESIM) {
        return ESIM + slotIndex;
      } else {
        return context.resourceManager.getStringSync($r('app.string.sim').id) + slotIndex;
      }
    } catch (err) {
      HiLog.e(TAG, `getSimIconAccessibilityTextByType failed, code is ${err?.code}, message is ${err?.message}`);
    }
    return '';
  }

  /**
   * 获取文本短信是否含有内嵌链接的操作文本
   *
   * @param detectResContent 识别内容
   * @param context 上下文
   * @returns 对应的无障碍操作朗读
   */
  public getBubbleTextAccessibilityStrBy(detectResContent: string, context: Context): string {
    let detectResJson: DetectResult;
    try {
      detectResJson = JSON.parse(detectResContent);
      if (detectResJson?.entity == '') {
        return context.resourceManager.getStringSync($r('app.string.hint_long_clickable').id);
      } else {
        return context.resourceManager.getStringSync($r('app.string.hint_inline_links').id) +
        context.resourceManager.getStringSync($r('app.string.hint_long_clickable').id);
      }
    } catch (error) {
      HiLog.e(TAG, `parse json returned by ai detect error, code is:${error?.code},message is ${error?.message}`);
    }
    return '';
  }

  public getAccessibilitySwitchState() {
    AppStorage.setOrCreate('isScreenReaderOpen', accessibility.isScreenReaderOpenSync());
    accessibility.on('screenReaderStateChange', this.handleAccessibilityStateChange);
  }

  private handleAccessibilityStateChange(isAccessibilityStateChanged: boolean) {
    HiLog.i(TAG, `isOpenAccessibility: ${isAccessibilityStateChanged}`);
    AppStorage.setOrCreate('isScreenReaderOpen', isAccessibilityStateChanged);
  }

  public releaseAccessibility() {
    HiLog.i(TAG, 'releaseAccessibility...')
    accessibility.off('screenReaderStateChange', this.handleAccessibilityStateChange);
  }
  private initResourceString() {
    if (!this.loaded) {
      this.sendFailed = getContext(this).resourceManager.getStringSync($r('app.string.message_send_failed').id);
      this.draft = getContext(this).resourceManager.getStringSync($r('app.string.draft').id);
      this.loaded = true;
    }
  }

  private getItemTime(item: LooseObject): string {
    let time = '';
    if (item.itemTime > 0) {
      try {
        time = getContext(this)
          .resourceManager
          .getPluralStringValueSync(item.time.id, item.itemTime);
      } catch (error) {
        HiLog.e(TAG, 'getItemTime error : ' + JSON.stringify(error));
      }
    } else {
      try {
        time = getContext(this).resourceManager.getStringSync(item.time.id);
      } catch (error) {
        HiLog.e(TAG, 'getItemTime error : ' + JSON.stringify(error));
      }
    }
    return time;
  }

  private getItemContent(item: LooseObject): string {
    let content = '';
    if (item.sendingFailed as boolean && !(item.isDraft as boolean)) {
      this.initResourceString();
      content = this.sendFailed;
    } else {
      if (item.isDisplayDraftText as boolean) {
        this.initResourceString();
        content = this.draft;
      }
      if (typeof item.content == 'string') {
        content += item.content;
      } else {
        try {
          content += getContext(this).resourceManager.getStringSync(item.content.id);
        } catch (error) {
          HiLog.e(TAG, 'getItemContext error : ' + JSON.stringify(error));
        }
      }
    }
    return content;
  }

  getItemContext(item: LooseObject, context: Context, showName?: string) {
    let unReadTitle = '';
    if (item.countOfUnread > 0) {
      unReadTitle = context.resourceManager
        .getPluralStringValueSync($r('app.plural.unread_messages').id, item.countOfUnread);
      unReadTitle = unReadTitle.replace(/ /g, '');
      unReadTitle += ' ';
    }
    let msgTitle: string = showName !== '' ? showName : item.name !== '' ? item.name :
    TelephoneUtil.formatDisplayPhoneNum(item.telephoneFormat);
    msgTitle += ' ';
    let timeTitle: string = '';
    if (typeof item.time == 'string') {
      timeTitle = item.time;
    } else {
      timeTitle = this.getItemTime(item);
    }
    timeTitle += ' ';
    let content = this.getItemContent(item);
    let pinContent = '';
    if (item.pinningTime > 0) {
      pinContent = context.resourceManager.getStringSync($r('app.string.msg_pin').id);
      pinContent += ' ';
    }
    return pinContent + unReadTitle + msgTitle + timeTitle + content;
  }

  /**
   * 无障碍发送主动播报的内容事件
   *
   * @param announceText 主动播报的内容
   */
  announceForAccessibility(announceText: string): boolean {
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.mms',
      triggerAction: 'click',
      textAnnouncedForAccessibility: announceText
    });
    try {
      accessibility.sendAccessibilityEvent(eventInfo).then(() => {
        HiLog.i(TAG, 'announceForAccessibility succeeded in send event');
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, 'announceForAccessibility failed to send event' + err.message);
      });
      return true;
    } catch (exception) {
      HiLog.e(TAG, `[announceForAccessibility] failed to send event because ${exception?.message}`);
    }
    return false;
  }

  /**
   * 无障碍重新设置组件获焦
   *
   * @param componentId 重新获焦的组件id
   */
  requestFocusForAccessibility(componentId: string): boolean {
    let eventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibility',
      bundleName: 'com.ohos.mms',
      triggerAction: 'common',
      customId: componentId
    });
    try {
      accessibility.sendAccessibilityEvent(eventInfo).then(() => {
        HiLog.i(TAG, 'requestFocusForAccessibility succeeded in send event');
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, 'requestFocusForAccessibility failed to send event' + err.message);
      });
      return true;
    } catch (exception) {
      HiLog.e(TAG, `[requestFocusForAccessibility] failed to send event because ${exception?.message}`);
    }
    return false;
  }

  /**
   * 无障碍重新设置组件获焦不打断原有朗读
   *
   * @param componentId 重新获焦的组件id
   */
  requestFocusForAccessibilityNotInterrupt(componentId: string): boolean {
    let eventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibilityNotInterrupt',
      bundleName: 'com.ohos.mms',
      triggerAction: 'common',
      customId: componentId
    });
    try {
      accessibility.sendAccessibilityEvent(eventInfo).then(() => {
        HiLog.i(TAG, 'requestFocusForAccessibilityNotInterrupt succeeded in send event');
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, 'requestFocusForAccessibilityNotInterrupt failed to send event' + err.message);
      });
      return true;
    } catch (exception) {
      HiLog.e(TAG, `[requestFocusForAccessibilityNotInterrupt] failed to send event because ${exception?.message}`);
    }
    return false;
  }

  /**
   * 获取长按和点击事件的无障碍操作朗读文本
   *
   * @param context 上下文
   * @returns 对应的无障碍操作朗读文本
   */
  public getOnClickAndLongPressEventsDes(context: Context): string {
    return context.resourceManager.getStringSync($r('app.string.double_click_operation').id) +  '\n' +
    context.resourceManager.getStringSync($r('app.string.hint_long_clickable').id);
  }
}

export default new AccessibilityUtil();