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

import HiLog from "../utils/HiLog";
import simCardService from "../service/SimCardService";

const TAG = "IndexController";

let sIndexController;

export default class IndexController {
    showConList: boolean = true;

    static getInstance() {
        if (sIndexController == null) {
            sIndexController = new IndexController();
        }
        return sIndexController;
    }

    onInit() {
        HiLog.i(TAG, "onInit");
        // Obtains simCount.
        this.initSimCardNum();
        // Carrier for obtaining the card
        this.simInfoProcessor();
    }

    onShow() {
        HiLog.i(TAG, "onShow");
    }

    onHide() {
        HiLog.i(TAG, "onHide");
    }

    onDestroy() {
        HiLog.i(TAG, "onDestroy");
    }

    initSimCardNum() {
        simCardService.initSimCardNum();
    }

    // Processes SIM card-related information, including the number of SIM cards and the name of the carrier.
    simInfoProcessor() {
        simCardService.simInfoHandler();
    }
}