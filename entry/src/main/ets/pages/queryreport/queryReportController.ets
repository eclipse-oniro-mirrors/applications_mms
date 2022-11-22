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
import common from "../../data/commonData";
import dateUtil from "../../utils/DateUtil";
import router from "@system.router";
import HiLog from "../../utils/HiLog"

const TAG = "QueryReportController";

let queryReportCtrl;

export default class QueryReportController {
    // MMS or not
    isMsm: boolean = true;
    // Sending Status Description
    sendStatusDesc: Resource;
    // Sending Status
    sendStatus: number = 0;
    // Time
    mmsTime: Resource;
    // Specific morning and afternoon time
    specificTime: Resource;
    // Timestamp
    timeMillisecond: string = "0";
    // telephoneNo
    telephone: string = '';

    static getInstance() {
        if (queryReportCtrl == null) {
            queryReportCtrl = new QueryReportController();
            AppStorage.SetAndLink("QueryReportController", queryReportCtrl);
        }
        return queryReportCtrl;
    };

    onInit() {
        HiLog.i(TAG, "onInit")
        this.isMsm = router.getParams().isMsm == undefined ? true : Boolean(router.getParams().isMsm);
        this.sendStatus = router.getParams().sendStatus == undefined ? 0 : Number(router.getParams().sendStatus);
        this.timeMillisecond =
            router.getParams().timeMillisecond == undefined ? "0" : String(router.getParams().timeMillisecond);
        this.telephone = router.getParams().telephone == undefined ? '' : String(router.getParams().telephone)
    };

    onShow() {
        HiLog.i(TAG, "onShow")
        // The status is changed to Chinese description.
        this.dealSendStatus();
        // Time Conversion
        this.dealTime();
    };

    dealSendStatus() {
        HiLog.i(TAG, "dealSendStatus sendStatus=" + this.sendStatus)
        if (this.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            this.sendStatusDesc = $r("app.string.received");
        } else if (this.sendStatus == common.int.SEND_MESSAGE_FAILED) {
            this.sendStatusDesc = this.isMsm ? $r("app.string.refused") : $r("app.string.failed");
        } else {
            this.sendStatusDesc = $r("app.string.rending");
        }
    };

    dealTime() {
        this.mmsTime = dateUtil.convertTimeStampDate(this.timeMillisecond);
        this.specificTime = dateUtil.convertTimeStampTime(this.timeMillisecond, false)
    }
}