/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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


import DatabaseMaintain from '../DatabaseMaintain/DatabaseMaintain'
import DataShareHelper from '../model/repository/DataShareHelper';
import OobeResult from '../oobe/oobeResult';
import FavoriteController from './favoritepage/favoriteController';
import InfoMsgController from './infomsg/InfoMsgController';
import QueryReportController from './queryreport/queryReportController';
import SettingsController from './settings/settingsController';
import TransmitSearchController from './transmitmsg/transmitSearchMsgController';
import HiLog from '../utils/HiLog';
const TAG = 'IndexReleaseTools';
/*
 * 温启动后，有一些静态资源变量不释放，需要手工释放。
 * */
export function globalReleaseAppResource() {
    HiLog.w(TAG, '[globalReleaseAppResource] start');
    DatabaseMaintain.release();
    DataShareHelper.release();
    FavoriteController.release();
    InfoMsgController.release();
    OobeResult.release();
    QueryReportController.release();
    TransmitSearchController.release();
    HiLog.w(TAG, '[globalReleaseAppResource] end');
}