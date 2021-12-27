/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import mmsLog from '../utils/MmsLog.js';

const TAG = 'RdbStoreUtil.js->';

// 数据库名称
const STORE_CONFIG = {
    name: 'mmssms.db',
}

// 数据库实例对象
var rdbStore = undefined;

/**
 * 创建数据库
 */
var getRdbStore = async function () {
    if (rdbStore == null) {
        rdbStore = await ohosDataRdb.getRdbStore(STORE_CONFIG, 1);
    }
    return rdbStore;
}
export default {

    /**
     * 创建数据库
     */
    async createRdbStore() {
        mmsLog.log(TAG + ' createRdbStore start');
        rdbStore = await ohosDataRdb.getRdbStore(STORE_CONFIG, 1);
        mmsLog.log(TAG + ' createRdbStore end');
    },

    /**
     * 创建数据库表
     */
    async createTable(table) {
        await rdbStore.executeSql(table, null);
    },

    /**
     * 新增数据
     */
    async insert(tableName, valueBucket) {
        let insertPromise = rdbStore.insert(tableName, valueBucket);
        let rowId = 0;
        insertPromise.then((ret) => {
            mmsLog.log(TAG + ' insert first done: ' + rowId);
            rowId = ret;
        }).catch((err) => {
            mmsLog.log(TAG + ' insert first done: ' + err);
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
        let changedRows = await rdbStore.update(valueBucket, predicates);
        mmsLog.log(TAG + 'updated row count: ' + changedRows);
    },

    /**
     * 删除接口
     * @param predicates 删除条件
     * @return
     */
    async deleteItem(predicates) {
        let deletedRows = await rdbStore.delete(predicates);
        mmsLog.log(TAG + 'deleted row count: ' + deletedRows);
    },

    /**
     * 获取查询条件的对象
     * @param tableName 表名
     * @return
     */
    getRdbPredicates(tableName){
        let predicates = new ohosDataRdb.RdbPredicates(tableName);
        return predicates;
    },

    /**
     * 获取数据库实例
     * @param tableName 表名
     * @return
     */
    getRdbStore() {
        return rdbStore;
    }
}