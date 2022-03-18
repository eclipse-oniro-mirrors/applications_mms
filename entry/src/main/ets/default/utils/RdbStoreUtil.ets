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
import ohosDataRdb from '@ohos.data.rdb';
import HiLog from './HiLog';
import mmsTable from '../data/tableData';

const TAG = 'RdbStoreUtil';

export default {
    /**
     * 创建数据库表
     */
    async createTable(table) {
        let rdbStore = await ohosDataRdb.getRdbStore(mmsTable.DB.MMSSMS.config, mmsTable.DB.MMSSMS.version)
        return await rdbStore.executeSql(table, null);
    },

    /**
     * 查询接口
     * @param predicates 查询条件
     * @return
     */
    async query(predicates) {
        let rdbStore = await ohosDataRdb.getRdbStore(mmsTable.DB.MMSSMS.config, mmsTable.DB.MMSSMS.version);
        let resultSet = await rdbStore.query(predicates);
        return resultSet;
    },

    /**
     * 新增数据
     */
    async insert(tableName, valueBucket) {
        let rdbStore = await ohosDataRdb.getRdbStore(mmsTable.DB.MMSSMS.config, mmsTable.DB.MMSSMS.version);
        let insertPromise = rdbStore.insert(tableName, valueBucket);
        let rowId = 0;
        insertPromise.then((ret) => {
            HiLog.i(TAG, 'insert, first done: ' + rowId);
            rowId = ret;
        }).catch((err) => {
            HiLog.e(TAG, 'insert, first fail: ' + JSON.stringify(err.message));
        })
        await insertPromise;
        return rowId;
    },

    /**
     * 更新接口
     * @param predicates 更新条件
     * @param predicates 更新值
     * @return
     */
    async update(predicates, valueBucket) {
        let rdbStore = await ohosDataRdb.getRdbStore(mmsTable.DB.MMSSMS.config, mmsTable.DB.MMSSMS.version);
        let changedRows = await rdbStore.update(valueBucket, predicates);
        HiLog.i(TAG, 'update, changedRows=' + changedRows);
    },

    /**
     * 删除接口
     * @param predicates 删除条件
     * @return
     */
    async deleteItem(predicates) {
        let rdbStore = await ohosDataRdb.getRdbStore(mmsTable.DB.MMSSMS.config, mmsTable.DB.MMSSMS.version);
        let deletedRows = await rdbStore.delete(predicates);
        HiLog.i(TAG, 'deleteItem, deletedRows=' + deletedRows);
    },

    /**
     * 获取查询条件的对象
     * @param tableName 表名
     * @return
     */
    getRdbPredicates(tableName){
        let predicates = new ohosDataRdb.RdbPredicates(tableName);
        return predicates;
    }
}