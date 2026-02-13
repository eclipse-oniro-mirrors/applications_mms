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

import HiLog from '../../utils/HiLog';
import { image } from '@kit.ImageKit';
import { curves } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { fileUri } from '@kit.CoreFileKit';

const TAG = 'ImagePreviewBuilder';
type ImageType = image.PixelMap | ResourceStr | DrawableDescriptor;

export class ImagePreviewData {
    public images?: ImageType[];
    public showImage: boolean = false;
    public imageSwiperController: SwiperController = new SwiperController();

    getGeometryID(): string {
        let geoId = util.getHash(this);
        return geoId.toString();
    }

    //Get the uri from the file's path in app sandbox
    static handleImagePath(paths: string[]): string[] {
        let imageList: string[] = [];
        paths.forEach((value) => {
            if (value.indexOf('file') === 0) {
                imageList.push(value);
            } else {
                imageList.push(fileUri.getUriFromPath(value));
            }
        });
        return imageList;
    }

    imagePreviewShow(): void {
        HiLog.i(TAG, 'ImagePreviewShow');
        animateTo({
            curve: curves.interpolatingSpring(0, 1, 328, 32)
        }, () => {
            this.showImage = true;
        })
    }

    imagePreviewHide(): void {
        HiLog.i(TAG, 'ImagePreviewClose')
        animateTo({
            curve: curves.interpolatingSpring(0, 1, 328, 32)
        }, () => {
            this.showImage = false;
        })
    }
}

@Builder
export function imagePreviewBuilder(imageData: ImagePreviewData) {
    Stack() {
        Swiper(imageData.imageSwiperController) {
            ForEach(imageData.images, (item: ImageType, index: number) => {
                Stack() {
                    Image(item)
                        .syncLoad(true)
                        .objectFit(ImageFit.Contain)
                        .width('100%')
                        .autoResize(true)
                        .constraintSize({
                            maxHeight: '100%',
                            maxWidth: '100%'
                        })
                        .geometryTransition(imageData.getGeometryID())
                }
                .size({ width: '100%', height: '100%' })
            }, (item: string) => item)
        }
        .size({ width: '100%', height: '100%' })
        .indicator(false)
        .onChange((index: number) => {
        })
        .onClick(() => {
            imageData.imagePreviewHide()
        })
    }
    .size({ width: '100%', height: '100%' })
    .id('imagePreviewBuilder')
    .backgroundColor(Color.Black)
    .transition(TransitionEffect.OPACITY)
}