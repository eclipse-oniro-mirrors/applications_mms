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
import HiLog from "./HiLog";
import mmsTable from "../data/tableData";
import ohosDataRdb from "@ohos.data.rdb";

const TAG = "MmsDatabaseHelper";

export default class MmsDatabaseHelper {
    public static TABLE = {
        SESSION: "session"
    };
    private static sInstance: MmsDatabaseHelper;
    private mRdbStore = null;


    static getInstance() {
        if (MmsDatabaseHelper.sInstance == null) {
            MmsDatabaseHelper.sInstance = new MmsDatabaseHelper();
        }
        return MmsDatabaseHelper.sInstance;
    }

    /**
     * Creating Database Tables
     */
    async createTable() {
        if (this.mRdbStore == null) {
            this.mRdbStore = await ohosDataRdb.getRdbStore(globalThis.mmsContext,
                { name: mmsTable.DB.MMSSMS.config.name }, mmsTable.DB.MMSSMS.version);

            await this.mRdbStore.executeSql(mmsTable.table.session, null);
            HiLog.i(TAG, "create session table finish");
        } else {
            HiLog.i(TAG, " this.mRdbStore !== null ");
        }
    }

    /**
     * Query Interface
     * @param predicates     Search criteria
     * @return
     */
    async query(predicates) {
        if (this.mRdbStore !== null) {
            return await this.mRdbStore.query(predicates);
        } else {
            HiLog.w(TAG, "mRdbStore is null, query fail.");
            return null;
        }
    }

    /**
     * New data
     */
    async insert(tableName, valueBucket) {
        let rowId = 0;
        if (this.mRdbStore !== null) {
            let insertPromise = this.mRdbStore.insert(tableName, valueBucket);
            insertPromise.then((ret) => {
                HiLog.i(TAG, "insert, first done: " + rowId);
                rowId = ret;
            }).catch((err) => {
                HiLog.e(TAG, "insert, first fail: " + JSON.stringify(err.message));
            })
            await insertPromise;
        } else {
            HiLog.w(TAG, "mRdbStore is null, insert fail.");
        }
        return rowId;
    }

    /**
     * Update Interface
     * @param predicates
     * @param predicates
     * @return
     */
    async update(predicates, valueBucket) {
        if (this.mRdbStore !== null) {
            let changedRows = await this.mRdbStore.update(valueBucket, predicates);
            HiLog.i(TAG, "update, changedRows=" + changedRows);
        } else {
            HiLog.w(TAG, "mRdbStore is null, update fail.");
        }
    }

    /**
     * Deleting an Interface
     * @param predicates
     * @return
     */
    async deleteItem(predicates) {
        if (this.mRdbStore !== null) {
            let deletedRows = await this.mRdbStore.delete(predicates);
            HiLog.i(TAG, "deleteItem, deletedRows=" + deletedRows);
        } else {
            HiLog.w(TAG, "mRdbStore is null, delete item fail.");
        }
    }
}