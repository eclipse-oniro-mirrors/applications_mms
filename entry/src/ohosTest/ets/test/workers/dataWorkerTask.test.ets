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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from "@ohos/hypium";
import DataWorkerWrapper, { DataWorkerTask } from "../../../../main/ets/workers/DataWorkerWrapper";
import worker, { ThreadWorkerGlobalScope } from "@ohos.worker";
import LooseObject from "../../../../main/ets/data/LooseObject";
import DataShareHelper from "../../../../main/ets/model/repository/DataShareHelper";
import { dataShare } from "@kit.ArkData";
import { WorkerType } from '../../../../main/ets/workers/WorkFactory';

export default function dataWorkerTaskTest() {
  describe("dataWorkerTaskTest", () => {

    let workerPort: ThreadWorkerGlobalScope = worker.workerPort;
    let dataWorkerTask: DataWorkerTask;

    beforeEach(() => {
      dataWorkerTask = DataWorkerTask.getInstance(workerPort);
    })

    it('dataWorkerTaskTest_DataWorkerWrapper', 0, () => {
      expect(DataWorkerWrapper.getInstance().getWorkerType()).assertEqual(WorkerType.DataWorker);
    })

    it("dataWorkerTaskTest_runInWorker", 0, () => {
      let callBack = (res: LooseObject) => {
        res.code ? expect(res.code).assertEqual(-1) :
          res.length ? expect(res.length).assertEqual(0) :
            res.response ? expect(JSON.stringify(res.response)).assertEqual('[]') :
            expect(JSON.stringify(res)).assertEqual('[]');
      };
      let param: Record<string, Object> = {
        "actionData": {
          telephone: ""
        } as LooseObject
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      let request: string = "queryContactDataByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryContactDataSizeByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryContactByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryContactSizeByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryRawContactSizeByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryContactViewByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryRecentContactByRow";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryCallLogByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "insertSmsMmsInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteSmsMmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteRcsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateSmsMmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateRcsMmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateRcsMmsInfoMarkRead";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateRcsReceivedMmsInfoByRcsId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "querySmsMmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "querySmsMmsInfoByConditionAll";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMmsInfoByFavoriteCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryAllInfoByFavoriteCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryRcsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "querySmsMmsInfoSlotIdByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryRcsInfoSlotIdByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "querySmsMmsInfoSizeByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMaxGroupId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMaxGroupIdRcs";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "statisticalData";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "insertMmsInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMmsInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteMmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "insertSession";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteSessionByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateSessionByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "querySessionByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "querySessionResultByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "querySessionSizeByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "markAsReadFromReceive";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "markAsReadFromReceiveRcs";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryNetInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "insertRcsMmsInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMaxGroupIdInMmsInfoTable";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryRcsInfoSizeByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMmsNotDownloadInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "fetchRecentContactsAndBatchUpdateSession";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryBlockedAllInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryBlockedInfoByPhoneNumberCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateBlockedSmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateBlockedRcsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteBlockedRcsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteBlockedSmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteBlockedMmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateAccessInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryContactBlockList";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "insertAccessInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteBlockInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryLocationData";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryYellowPageInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "fetchDeleteContactsAndUpdateSession";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryYellowPageListInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "selectInfoCount";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryBlockedMmsInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "selectContactId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateSessionUnReadBySessionId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateSmsIsReadBySessionId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateRcsIsReadBySessionId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "batchUpdateSessionByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateRecentUstTime";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryChatbotPermissions";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateChatbotPermissions";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateRcsServiceKindMsgCodeByRcsId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryFavoriteAllInfoByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryRcsIdByMsgId";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateMmsPartById";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "deleteSessionSlice";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryBlockedInfoByBatchPhoneNumberCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryBlockedInfoByPrefPhoneNumber";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryContactBlockListByPrefPhoneNumber";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryNumberData";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryBlockedFromSmsInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateSmsInfoSmsTypeBySessionIds";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateRcsInfoIsSenderBySessionIds";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateAttachmentByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateAttachmentByCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMmsInfoLastReadCondition";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryMmsPartInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "queryBlockedFromRcsInfo";
      dataWorkerTask.runInWorker(request, callBack, param);

      request = "updateSessionPinningTimeBySessionId";
      dataWorkerTask.runInWorker(request, callBack, param);

      mocker.clear(DataShareHelper.getInstance());
    })
  })
}