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
import deviceInfo from "@ohos.deviceInfo";
import HiLog from "./HiLog";

const TAG = "DeviceUtil";

export default class DeviceUtil {
    private static readonly DEVICE_TYPE = deviceInfo.deviceType;
    constructor() {
    }

    /**
    * Querying the Device Type
    *
    * default：Smartphones
    * tablet：flat plate
    * tv：Smart screen
    * wearable：Smart Wear
    * liteWearable：Lightweight intelligent wearable
     * smartVision：Smart Vision Devices
    */
    static getDeviceType(): string {
        HiLog.i(TAG, "deviceType is " + this.DEVICE_TYPE)
        return this.DEVICE_TYPE;
    }

    static isTablet(): boolean{
        let deviceType = DeviceUtil.getDeviceType()
        return deviceType === "tablet";
    }
}