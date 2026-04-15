/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import LocationUtil from '../../utils/LocationUtil';
import { AddressInfo, Mms } from '../../utils/TypesUtils';
import fileuri from '@ohos.file.fileuri';
import { isObjectJSONString } from '../../utils/StringUtil';
import HiLog from '../../utils/HiLog';

const TAG = 'MmsMapOfAttachmentArea';

/**
 * The UI for Location Message show in the attachment area.
 */
@Component
export struct MmsMapOfAttachmentArea {
  /**
   * 位置附件数据
   */
  item?: Mms;
  @Link textareaFocusable: boolean;
  /**
   * 位置附件图片Uri
   */
  @State locationImageUri: string = '';

  aboutToAppear(): void {
    if (this.item?.path) {
      this.locationImageUri = fileuri.getUriFromPath(this.item.path);
    }
    //若此时彩信位置附件的address为空，可从text属性使用JSON解析出来
    if (this.item && !this.item.address && isObjectJSONString(this.item.text)) {
      this.item.address = JSON.parse(this.item.text as string) as AddressInfo;
    }
  }

  @Builder
  renderLocationImage() {
    if (this.item?.pixelMap || this.locationImageUri) {
      Stack({ alignContent: Alignment.BottomStart }) {
        // Location Message's image.
        Image(this.item?.pixelMap ? this.item?.pixelMap : this.locationImageUri)
          .width(80)
          .height(80)
          .borderRadius(8)

        Image($rawfile('icon/icon_mask_layer.svg'))
          .width(80)
          .height(40)
          .borderRadius({ bottomLeft: 8, bottomRight: 8 })
          .draggable(false)
      }
    } else {
      Stack() {
        Stack()
          .width(80)
          .height(80)
          .borderRadius(8)
          .backgroundColor($r('sys.color.comp_background_secondary'))

        SymbolGlyph($r('sys.symbol.local_fill'))
          .fontColor([$r('sys.color.ohos_id_color_warning')])
          .width('12vp')
          .height('12vp')
          .draggable(false)
          .fontSize('12vp')
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.renderLocationImage()
      // Text for address info
      Text(this.item?.address?.address ?? '')
        .fontSize($r('sys.float.Caption_M'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_on_primary'))
        .lineHeight(13)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(72)
        .maxLines(1)
        .margin({ left: 4, right: 4, bottom: 4 })
        .maxFontScale(1.45)
    }
    .onClick(() => {
      this.textareaFocusable = false;
      if (this.item?.address) { //拉起地图Kit的位置详情展示器Picker
        LocationUtil.queryLocation(this.item?.address)
      }
    })
  }
}