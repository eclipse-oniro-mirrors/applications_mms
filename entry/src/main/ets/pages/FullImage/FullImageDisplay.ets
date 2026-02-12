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
import { PictureListData } from '../../utils/TypesUtils';
import MMPictureController from '../../views/AttachmentArea/MMPictureController';
import FullImageDisplayControler from './FullImageDisplayControler';
import myCommon from '@ohos.app.ability.common';

const TAG = 'FullImageDisplay ';

@Builder
export function FullImageDisplayLoader(param: LooseObject): void {
  FullImageDisplay();
}

@Component
export default struct FullImageDisplay {
  private swiperController: SwiperController = new SwiperController()
  @State pictureCtrl: MMPictureController = MMPictureController.getInstance();
  @State fullIamgeCtrl: FullImageDisplayControler = FullImageDisplayControler.getInstance();
  @Consume('pageInfos') pageInfos: NavPathStack
  @State swiperList: Array<PictureListData> = [];
  @State isChecked: boolean = false
  @State currentIdex: number = 0
  @State currentItemIsChecked: boolean = false
  @State titleText: string = ''
  @State showPlayVideoIcon: boolean = true
  private context = getContext(this) as myCommon.UIAbilityContext;
  videoController: VideoController = new VideoController()

  aboutToAppear() {
    this.fullIamgeCtrl.onInit(this.pageInfos);
    this.currentIdex = this.fullIamgeCtrl.showIdx
    this.titleText = this.fullIamgeCtrl.showIdx + '/' + (this.pictureCtrl.pictureList.length - 1);
    if (this.pictureCtrl.pictureList.length > 0 && this.pictureCtrl.pictureList[this.currentIdex]) {
      this.currentItemIsChecked = this.pictureCtrl.pictureList[this.currentIdex].selected
    }

  }
  stopPlayVideo(){
    this.videoController.stop();
    this.showPlayVideoIcon = true;
  }
  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            Swiper(this.swiperController) {
              ForEach(this.pictureCtrl.pictureList, (item: PictureListData, index) => {
                if (index === 0) {
                  Text('')
                    .width('100%')
                    .height('100%')
                    .visibility(Visibility.None)
                } else {
                  if (item.photoType === 1) {
                    Column() {
                      Image(item.mediaUri ? item.mediaUri : '')
                        .draggable(false)
                    }
                    .width('100%')
                    .height('100%')
                    .alignItems(HorizontalAlign.Center)
                  } else {
                    Stack({ alignContent: Alignment.Center }){
                      Video({
                        src: item.mediaUri,
                        previewUri: item.pixelMap,
                        controller: this.videoController
                      })
                        .width('100%')
                        .height('100%')
                        .autoPlay(false)
                        .controls(false)
                        .onPause(() => {
                          this.showPlayVideoIcon = true
                        })
                        .onStart(()=>{
                          this.showPlayVideoIcon = false
                        })
                        .onFinish(() => {
                          this.showPlayVideoIcon = true
                        })

                      SymbolGlyph($r('sys.symbol.play_circle_fill'))
                        .width(60).height(60).opacity(0.6)
                        .fontColor([$r('sys.color.white'), $r('sys.color.black')])
                        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                        .draggable(false)
                        .visibility(this.showPlayVideoIcon ? Visibility.Visible : Visibility.None)
                        .onClick(() => {
                          this.videoController.start();
                        })
                    }

                  }
                }

              })
            }
            .index(this.fullIamgeCtrl.showIdx)
            .loop(false)
            .indicator(false)
            .curve(Curve.Ease)
            .displayCount('auto')
            .onChange((index: number) => {
              this.stopPlayVideo()
              this.currentIdex = (index == 0) ? 1 : index;
              if (index > 0) {
                this.currentItemIsChecked = this.pictureCtrl.pictureList[index].selected
                this.titleText = this.currentIdex + '/' + (this.pictureCtrl.pictureList.length - 1)
              }
            })
          }

          Row() {
            Row() {
              SymbolGlyph($r('sys.symbol.chevron_backward'))
                .fontColor([$r('sys.color.ohos_id_color_primary')])
                .fontSize('24vp').width('24vp').height('24vp').draggable(false)
                .onClick(() => {
                  this.pageInfos?.pop()
                })

              Text(this.titleText)
                .fontSize(24)
                .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
                .fontWeight(FontWeight.Medium)
                .margin({ left: 20 })
            }


            Row() {
              Stack({ alignContent: Alignment.Center }) {
                ForEach(this.pictureCtrl.pictureList, (item: PictureListData, index) => {
                  Checkbox()
                    .select(item.selected)
                    .visibility(index === this.currentIdex ? Visibility.Visible : Visibility.Hidden)
                    .onChange((value: boolean) => {
                      this.fullIamgeCtrl.checkBoxChange(this.context, value, this.currentIdex)
                    })
                })
              }

            }

          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.SpaceBetween)
          .flexShrink(0)
          .padding({ left: '24vp', right: '24vp' })
          .margin(38)
          .zIndex(2)
        }
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .onShown(() => {
    })
    .onHidden(() => {
    })
  }
}