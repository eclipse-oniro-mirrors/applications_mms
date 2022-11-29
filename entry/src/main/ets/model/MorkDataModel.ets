/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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


var savedImageInfo = {
    filePath: ''
};

var pictureListFromGallery = [
    {
        path: "/common/icon/add.png",
        checkedValue: false,
        fileSize: 55.6, // Unit:KB
        type: 1 // 1 image, 3 video
    },
    {
        path: "/common/icon/up.png",
        checkedValue: false,
        fileSize: 95.6,
        type: 1
    },
    {
        path: "/common/icon/vmall.png",
        checkedValue: false,
        fileSize: 75.6,
        type: 1
    },
    {
        path: "/common/icon/pin.png",
        checkedValue: false,
        fileSize: 55.6,
        type: 1
    },
    {
        path: "/common/icon/delete.png",
        checkedValue: false,
        fileSize: 55.6,
        type: 1
    },
    {
        path: "/common/icon/ikea.png",
        checkedValue: false,
        fileSize: 55.6,
        type: 1
    }
];

export default class MorkModel {
    saveImage() {
        return savedImageInfo;
    }

    queryFromGallery() {
        return pictureListFromGallery;
    }
}