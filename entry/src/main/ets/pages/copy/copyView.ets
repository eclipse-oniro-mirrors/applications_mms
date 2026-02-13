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

import HiLog from '../../utils/HiLog';
import { EditableLeftIconType, EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import LooseObject from '../../data/LooseObject';
import DeviceUtil from '../../utils/DeviceUtil';
//import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit'
import TitleBarUtil from '../../utils/TitleBarUtil';
import { SymbolGlyphModifier } from '@kit.ArkUI';

const TAG = 'CopyView';

class Info {
  public info: string = '';
  public isFromConversation: boolean = false;
}

@Builder
export function CopyViewLoader(param: LooseObject): void {
  CopyView();
}

@Component
export struct CopyView {
  @Consume('pageInfos') pageInfos?: NavPathStack
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null=null;
  @State transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.TITLE;
  @State isPad: boolean = false;

  info: string = ''

  isFromConversation: boolean = false 

  textId: string = 'CopyText';
  scroller: Scroller = new Scroller();

  aboutToAppear() {
    let obj: Array<Info> = this.pageInfos?.getParamByName('CopyView') as Array<Info>;
    this.info = obj[0].info;
    this.isFromConversation = obj[0].isFromConversation;
    this.isPad = DeviceUtil.isTablet();
  }

  destinationAppear() {
    let obj: Array<Info> = this.pageInfos?.getParamByName('CopyView') as Array<Info>;
    this.info = obj[0].info;
    this.isFromConversation = obj[0].isFromConversation;
  }

  destinationShow() {
    if (this.isFromConversation) {
      this.isFromConversation = false;
    }
  }

  onBackPress = () => {
    HiLog.i(TAG, 'onBackPress');
    this.transitionType = NavigationSystemTransitionType.DEFAULT;
    this.pageInfos?.pop();
    return true;
  }

  build() {
    //HdsNavDestination() {
    NavDestination() {
      Column() {
        Scroll(this.scroller) {
          Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            Text(this.info)
              .fontSize(24)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Start)
              .copyOption(CopyOptions.LocalDevice)
              .selection(0, this.info?.length)
              .id(this.textId)
          }
          .width('100%')
          .flexBasis('auto')
          .padding({ left: 18, right: 18, bottom: 20 })
        }
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_secondary'))
        .scrollBarColor(0xe5e6e8)
        .scrollable(ScrollDirection.Vertical)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: this.isPad ? 8 : 0, right: this.isPad ? 8 : 0 })
    }
    .onAppear(() => {
      this.destinationAppear();
    })
    .onShown(() => {
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
      this.destinationShow();
    })
    .onBackPressed(this.onBackPress)
    .padding({ bottom: 32 })
    .hideTitleBar(false)
    .onBackPressed(() => {
      return this.onBackPress();
    })
    // .titleBar(TitleBarUtil.getTitleBar({
    //   enableComponentSafeArea: true,
    //   callback: this.onBackPress //ҳ�淵�ذ�ť�ĵ���¼�
    // }))
    .backgroundColor($r('sys.color.background_secondary'))
    .systemTransition(this.transitionType)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP])
  }
}