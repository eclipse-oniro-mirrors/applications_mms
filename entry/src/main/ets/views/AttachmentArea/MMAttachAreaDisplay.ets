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

import LooseObject from '../../data/LooseObject';
import HiLog from '../../utils/HiLog';
import commonData from '../../data/commonData';
import { MMAudio, MMPictureDisplay, MMVideo, MMMap } from './MMAttachAreaDisplayContent';
import { MMVcard } from './MMVcard'
import MMAttachmentAreaController from './MMAttachmentAreaController';
import MMPictureController from './MMPictureController';
import MMPictureDataSource from '../../model/MMPictureDataSource';
import { Mms } from '../../utils/TypesUtils';
import curves from '@ohos.curves';
import HashMap from '@ohos.util.HashMap';
import DeviceUtil from '../../utils/DeviceUtil';
import myCommon from '@ohos.app.ability.common';
import { Configuration, LengthMetrics } from '@kit.ArkUI';
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import { MmsMapOfAttachmentArea } from '../MmsMap/MmsMapOfAttachmentArea';

const TAG = 'MMAttachAreaDisplay ';

@Component
export default struct MMAttachAreaDisplay {
  @State mAttachAreaCtrl: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  @State displayList: Array<Mms> = [];
  private context = getContext(this) as myCommon.UIAbilityContext;
  scroller: Scroller = new Scroller();
  @StorageLink('isAreaDisplayChange') @Watch('displayChangedEvent') isAreaDisplayChange: boolean = false;
  @State pictureCtrl: MMPictureController = MMPictureController.getInstance();
  @State isRefresh: boolean = false;
  @Link textareaFocusable: boolean;
  @Prop isDraft: boolean;
  @State first: boolean = this.displayList.length == 1;
  /* 设备是否为pad */
  @State isPad: boolean = false;
  @State padTwoSide: number = 16;
  @State isOverWidth: number = 0;
  @State isMulContacts: boolean = false;
  @Prop addButtonId: string;

  displayChangedEvent() {
    HiLog.i(TAG, 'displayChangedEvent');
    this.displayList = this.mAttachAreaCtrl.mmDisplaySource;
    this.first = this.displayList.length == 1;
    this.scroller.scrollToIndex(this.displayList.length - 1);
    this.scroller.scrollEdge(Edge.End);
  }



  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.displayChangedEvent()
    this.isPad = DeviceUtil.isTablet();
  }

  build() {
    Row() {
      Scroll(this.scroller) {
        Row() {
          Blank().width(8)
          ForEach((this.displayList), (item: Mms, index) => {
            this.displayItem(this.context, item)
          }, (item:Mms, index:number) => {return JSON.stringify(item)})
          Blank().width(16)
        }
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .constraintSize({ minWidth: '100%' })
        .clip(false)
        .margin({ top: this.displayList.length > 0 ? 12 : 0, bottom: this.displayList.length > 0 ? 8 : 0 })
        .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
          this.onVisibleAreaChangeMethod(isVisible, currentRatio);
        })
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .padding({ left: 0, right: this.isPad ? 8 : 0 })
    .clip(true)
  }

  private onVisibleAreaChangeMethod(isVisible: boolean, currentRatio: number) {
    if (this.isOverWidth != this.displayList.length) {
      this.isOverWidth = this.displayList.length;
      if (isVisible && currentRatio >= 1.0) {
        this.padTwoSide = 16;
      } else {
        this.padTwoSide = 0;
      }
    }
  }

  @Builder
  displayItem(context: Context, item: Mms) {
    Row() {
      Stack({ alignContent: (item.type === commonData.MM_ATTACHMENT_TYPE.AUDIO || this.isMulContacts) ? 
      Alignment.End : Alignment.TopEnd }) {
        Row() {
          if (!item.isRcs && item.type === commonData.MM_ATTACHMENT_TYPE.MAP) {
            MmsMapOfAttachmentArea({ item: item, textareaFocusable: this.textareaFocusable })
          } else if (item.type === commonData.MM_ATTACHMENT_TYPE.IMAGE ||
            item.type === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
            MMPictureDisplay({ item: item, textareaFocusable: $textareaFocusable, displayList: this.displayList})
          } else if (item.type === commonData.MM_ATTACHMENT_TYPE.AUDIO) {
            MMAudio({ item: item, displayList: this.displayList})
          } else if (item.type === commonData.MM_ATTACHMENT_TYPE.VIDEO ||
            item.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
            MMVideo({item: item, textareaFocusable: $textareaFocusable, displayList: this.displayList})
          } else if (item.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP) {
            MMMap({item: item, textareaFocusable: $textareaFocusable})
          } else if (item.type === commonData.MM_ATTACHMENT_TYPE.VCARD) {
            MMVcard({item: item, isMulContacts: (isMulContacts: boolean) => {
              this.isMulContacts = isMulContacts
            }})
          }
        }
        .id('attachment_area_content_id')
        this.deleteItem(context, item);
      }
      .transition(
        TransitionEffect.asymmetric(
          this.first ?
            this.isDraft ?
            TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Sharp, delay: 150 }) :
            TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.Sharp, delay: 150 }) :
          TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.Sharp, delay: 150 })
            .combine(
              TransitionEffect.move(TransitionEdge.BOTTOM).animation({
                curve: curves.interpolatingSpring(0, 1, 228, 30)})
            ),
          TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.Sharp })
            .combine(TransitionEffect.move(TransitionEdge.BOTTOM).animation({
              curve: curves.interpolatingSpring(0, 1, 228, 30)}))
        )
      )
      .clip(false)
      .border({
        width: '1px',
        radius: '8vp',
        color: '#33A1A4B3'
      })
    }
    .clip(false)
    .margin({ left: 8 })
  }

  @Builder
  deleteItem(context: Context, item: Mms) {
    Stack({ alignContent: Alignment.Center }) {
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontColor(['#ffffffff'])
        .draggable(false)
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_S'))
        .id('attachment_area_cancel_id')
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.delete_button').id))
        .backgroundColor('#66000000')
        .padding(4)
        .borderRadius(50)
        .maxFontScale(item.type === commonData.MM_ATTACHMENT_TYPE.VCARD ? 2 : 1.75)
        .margin(4)
    }
    .onClick(() => {
      let resList = this.displayList.map(item => {
        return item.path;
      });
      let idx = resList.indexOf(item.path);
      this.pictureCtrl.selectedMsgCount--;
      animateTo({duration:250, curve: Curve.Sharp}, () => {
        this.displayList.splice(idx, 1);
      })
      this.reloadAccessibilitySequence(idx);
      this.mAttachAreaCtrl.deleteTabDisplay(context, item);
      if (item.type !== commonData.MM_ATTACHMENT_TYPE.AUDIO) {
        if (item.galleryPath) {
          this.pictureCtrl.changeCheckBox(item.galleryPath, false);
        }
      }
    })
  }

  private reloadAccessibilitySequence(idx: number) {
    let indexId: string = this.addButtonId;
    if (this.displayList.length > 0) {
      let deleteDone: string = getContext(this)
        .resourceManager
        .getStringSync($r('app.string.msg_attachments').id) + (idx + 1) + getContext(this)
        .resourceManager
        .getStringSync($r('app.string.msg_attachments_deleted').id);
      AccessibilityUtil.announceForAccessibility(deleteDone)
      // 删除某个后焦点重新聚焦到上一个
      let index = idx - 1 > 0 ? idx - 1 : 0;
      if (this.displayList.length - 1 >= index) {
        indexId = this.displayList[index].path;
      }
    }
    setTimeout(() => {
      AccessibilityUtil.requestFocusForAccessibilityNotInterrupt(indexId);
    }, 50);

    let isChanged: boolean = AppStorage.get('isDisplayListChange') as boolean;
    AppStorage.setOrCreate('isDisplayListChange', !isChanged);
  }
}