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
import common from '../data/commonData';
import HiLog from './HiLog';
import call from '@ohos.telephony.call';

const TAG = 'TelephoneUtil';
/**
 *  log package tool class
 */
const infoMegTelephone = [
    '1065796709202', '1065502043202', '1065902090202', '1069055999202',
    '106579670915', '106550204315', '106590209015', '106905599915',
    '106', '400', '111', '100', '118', '116', '12306', '12329', '12345',
    '12122', '12321', '12580', '12520', '12583', '02512329', '053287003810',
    '1258319559899', '1019', '12583110086', '000000', '95', '96',
];
export default {

    /**
     * 判断手机号是否是通知信息
     * @param telephone 手机号
     * @return 是或不是
     */
    judgeIsInfoMsg(telephone) {
        let result = false;
        if (telephone == null || telephone == common.string.EMPTY_STR) {
            return result;
        }
        for (let item of infoMegTelephone) {
            if (telephone.indexOf(item) == 0) {
                result = true;
            }
        }
        return result;
    },

    formatTelephone(telephone) {
        if(telephone == null || telephone == common.string.EMPTY_STR) {
            return common.string.EMPTY_STR;
        }
        if(telephone.indexOf('+86') >= 0) {
            return telephone.substring(3);
        }
        return telephone;
    },

    dealSelectContactsSort(selectContacts) {
        if(selectContacts.length == 0) {
            return;
        }
        let result = [];
        let telephone = common.string.EMPTY_STR;
        let contactsMap = new Map();
        for(let item of selectContacts) {
            telephone = telephone + item.telephone + common.string.COMMA;
            if(!contactsMap.has(item.telephone)) {
                contactsMap.set(item.telephone, item);
            }
        }
        telephone = this.dealTelephoneSort(telephone.substring(0, telephone.length - 1));
        let telephones = telephone.split(common.string.COMMA);
        for(let element of telephones) {
            if(contactsMap.has(element)) {
                result.push(contactsMap.get(element));
            }
        }
        return result;
    },

    /**
     * 手机号,从小到大进行排序
     * @param telephone
     * @return
     */
    dealTelephoneSort(telephone){
        if(telephone == null || telephone == common.string.EMPTY_STR) {
            return common.string.EMPTY_STR;
        }
        let result = common.string.EMPTY_STR;
        let telephones = telephone.split(common.string.COMMA);
        // 如果只有一个手机号，不需要进行排序
        if(telephones.length == 1) {
            return telephone;
        }
        let telephoneMap = new Map();
        let indexs = [];
        let count = 0;
        // 分组
        for(let item of telephones) {
            if(telephoneMap.has(item.length)) {
                let strings = telephoneMap.get(item.length);
                strings.push(item);
            } else {
                let strings = [];
                strings.push(item);
                telephoneMap.set(item.length, strings);
                indexs[count++] = item.length;
            }
        }
        // 从大到小排序
        this.bubbleSort(indexs, count);
        for(let index of indexs) {
            let arrs = telephoneMap.get(index);
            this.bubbleSort(arrs, arrs.length);
            for (let arr of arrs) {
                result = result + arr + common.string.COMMA;
            }
        }
        // 取出对应的结果及进行配对
        return result.substring(0, result.length - 1);
    },

    /**
     * 冒泡排序, 从小到大排序
     * @param arr
     * @param length
     * @return
     */
    bubbleSort(arr, length) {
        // 每次从后往前冒一个最小值，且每次能确定一个数在序列中的最终位置
        for (let i = 0; i < length - 1; i++){
            // 冒泡的改进，若在一趟中没有发生逆序，则该序列已有序
            for (let j = length-1; j >i; j--){
                // 每次从后边冒出一个最小值
                if (arr[j] < arr[j - 1]) {
                    // 发生逆序，则交换
                    let temple = arr[j];
                    arr[j] = arr[j - 1];
                    arr[j - 1] = temple;
                }
            }
        }
    },
    async formatPhoneNumber(phoneNumber) {
        if (phoneNumber == null || phoneNumber === common.string.EMPTY_STR) {
            HiLog.w(TAG, 'formatPhoneNumber, param is null');
            return common.string.EMPTY_STR;
        }
        let promise = call.formatPhoneNumber(phoneNumber);
        let formatPhoneNumber = common.string.EMPTY_STR;
        promise.then((value) => {
            formatPhoneNumber = value;
        }).catch((err) => {
            HiLog.e(TAG, 'formatPhoneNumber, error: ' + JSON.stringify(err.message));
        });
        await promise;
        return formatPhoneNumber;
    }
};