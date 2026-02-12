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
import common from '../../data/commonData';
import lazy { DateUtil } from '../../utils/DateUtil';
import HiLog from '../../utils/HiLog'

const TAG = 'QueryReportController';

let queryReportCtrl: QueryReportController;

class RouterParams {
    isMsm: boolean = false;
    telephone: string = '';
    sendStatus: number = -1; //0：已送达
    timeMillisecond: number = 0;
}

export default class QueryReportController {
    // MMS or not
    public isMsm: boolean = true;
    // Sending Status Description
    public sendStatusDesc: Resource | string = ''
    // Sending Status
    public sendStatus: number = 0;
    // Time
    public mmsTime: Resource | string = '';
    // Specific morning and afternoon time
    public specificTime: Resource | string = '';
    // Timestamp
    public timeMillisecond: string = '0';
    // telephoneNo
    public telephone: string = '';
    public pageInfos: NavPathStack | null = null;
    private static sInstance: QueryReportController | undefined = undefined;

    public static release() {
        QueryReportController.sInstance = undefined;
    }

    public static getInstance(): QueryReportController {
        if (!QueryReportController.sInstance) {
            QueryReportController.sInstance = new QueryReportController();
            AppStorage.SetAndLink('QueryReportController', QueryReportController.sInstance);
        }
        return QueryReportController.sInstance as QueryReportController;
    };

    onInit(pageInfos: NavPathStack) {
        HiLog.i(TAG, 'onInit')
        this.pageInfos = pageInfos;
        let routerParams: Array<RouterParams> = this.pageInfos.getParamByName('queryReport') as Array<RouterParams>;
        this.isMsm = routerParams[0]?.isMsm == undefined ? true : Boolean<Object>(routerParams[0]?.isMsm);
        this.sendStatus = routerParams[0]?.sendStatus == undefined ? 0 : Number(routerParams[0]?.sendStatus);
        this.timeMillisecond =
            routerParams[0]?.timeMillisecond == undefined ? '0' : String(routerParams[0]?.timeMillisecond);
        this.telephone = routerParams[0]?.telephone == undefined ? '' : String(routerParams[0]?.telephone)
    };

    onShow() {
        HiLog.i(TAG, 'onShow')
        // The status is changed to Chinese description.
        this.dealSendStatus();
        // Time Conversion
        this.dealTime();
    };

    dealSendStatus() {
        HiLog.i(TAG, 'dealSendStatus sendStatus=' + this.sendStatus)
        if (this.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            this.sendStatusDesc = $r('app.string.received');
        } else if (this.sendStatus == common.int.SEND_MESSAGE_FAILED) {
            this.sendStatusDesc = this.isMsm ? $r('app.string.refused') : $r('app.string.failed');
        } else {
            this.sendStatusDesc = $r('app.string.rending');
        }
    };

    dealTime() {
        this.mmsTime = DateUtil.convertTimeStampDate(Number(this.timeMillisecond));
        this.specificTime = DateUtil.convertTimeStampTime(Number(this.timeMillisecond));
    }
}