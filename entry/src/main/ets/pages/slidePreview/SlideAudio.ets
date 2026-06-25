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
import { AudioPlayerService } from '../../service/AudioPlayerService';
import { DateUtil } from '../../utils/DateUtil';
import { SlideMmsItem } from '../../utils/TypesUtils';
import commonData from '../../data/commonData';

const TAG = 'SlideAudio';

@Component
export struct SlideAudio {
  @Prop audioItem: SlideMmsItem;
  @Prop audioId: string;
  @Prop isAutoPlay: boolean = false;
  @Prop @Watch('slidePageHidden') isPageHide: boolean = false;
  @State @Watch('audioPlayStateChanged') audioPlayState: string | undefined = commonData.MEDIA_STATUS.STOPPED;
  @State progressValue: number = 0;
  @State @Watch('audioPlayerStatusChanged') audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  // 定时器id
  timerId: number = -1;
  // 音频时长
  timeSecond: number = 0;

  aboutToAppear() {
    this.timeSecond = DateUtil.getDuration(this.audioItem.duration);
    if (this.isAutoPlay) {
      setTimeout(() => {
        this.onAudioFilePlayClick()
      })
    }
  }

  slidePageHidden() {
    if (this.isPageHide) {
      AudioPlayerService.setAudioFilePlayState(this.audioId, 'stopped');
      this.audioPlayerService.stopAudio();
    }
  }

  audioPlayerStatusChanged() {
    this.audioPlayState = this.audioPlayerService.playState;
  }

  audioPlayStateChanged() {
    if (this.audioPlayState === commonData.MEDIA_STATUS.PLAYING) {
      this.timerId = setInterval(() => {
        this.progressValue += 1
        if (this.progressValue > this.timeSecond) {
          this.progressValue = 0
        }
      }, 1000)
    } else {
      clearInterval(this.timerId);
      this.progressValue = 0;
    }

  }

  @Builder
  renderFileName() {
    Text(decodeURIComponent(this.audioItem.name))
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .fontFamily('HarmonyHeiTi')
      .fontSize($r('sys.float.ohos_id_text_size_body1'))
      .textAlign(TextAlign.Start)
      .id('text_file_name')
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .lineHeight(21)
  }

  @Builder
  renderPlayIcon() {
    Image(this.audioPlayState === commonData.MEDIA_STATUS.PLAYING ? $rawfile('icon/ic_public_pause_norm.svg') :
    $rawfile('icon/ic_public_play_norm.svg'))
      .fillColor($r('sys.color.icon_emphasize'))
      .width(32)
      .height(32)
      .margin({ top: 12 })
      .draggable(false)
      .onTouch(this.onAudioFilePlayButtonTouch)
      .onClick(this.onAudioFilePlayClick);
  }

  @Builder
  renderProgress() {
    Row() {
      Progress({ value: 0, total: this.timeSecond, type: ProgressType.Linear })
        .height($r('app.float.space_24'))
        .style({ enableSmoothEffect: false })
        .value(this.progressValue)
    }
    .margin({ top: $r('app.float.settings_items_margin_top') })
    .padding({ left: $r('app.float.space_16'), right: $r('app.float.space_16') })
    .width('100%')

    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Text('00:00').lineHeight(16)
      Text(this.audioItem.duration).lineHeight(16)
    }
    .margin({ top: $r('app.float.settings_item_padding_top') })
    .padding({ left: $r('app.float.space_16'), right: $r('app.float.space_16') })
    .width('100%')
  }

  private onAudioFilePlayButtonTouch(e: TouchEvent) {
    e.stopPropagation();
  }

  public onAudioFilePlayClick = async (event?: ClickEvent) => {
    if (this.audioPlayState === 'stopped') {
      AudioPlayerService.setAudioFilePlayState(this.audioId, 'playing')
    } else {
      AudioPlayerService.setAudioFilePlayState(this.audioId, 'stopped')
    }
    this.audioPlayerService.playAudio(this.audioItem, () => {
      AudioPlayerService.setAudioFilePlayState(this.audioId, 'stopped')
    });
  }

  build() {
    Row() {
      Column() {
        this.renderFileName();
        this.renderPlayIcon();
        this.renderProgress()
      }
    }
    .width('100%')
  }
}
