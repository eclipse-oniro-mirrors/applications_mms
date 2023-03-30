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
import common from "../data/commonData";
import HiLog from "./HiLog";
import call from "@ohos.telephony.call";

const TAG = "TelephoneUtil";
/**
 *  log package tool class
 */
const infoMegTelephone = [
    "1065796709202", "1065502043202", "1065902090202", "1069055999202",
    "106579670915", "106550204315", "106590209015", "106905599915",
    "106", "400", "111", "100", "118", "116", "12306", "12329", "12345",
    "12122", "12321", "12580", "12520", "12583", "02512329", "053287003810",
    "1258319559899", "1019", "12583110086", "000000", "95", "96",
];

export default {

    /**
     * Check whether the mobile number is notification information.
     * @param telephone
     * @return Yes or no
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
        let formatTelephone: string = telephone;
        if (telephone == null || telephone == common.string.EMPTY_STR) {
            formatTelephone = common.string.EMPTY_STR;
        }
        if (formatTelephone.startsWith("+86")) {
            formatTelephone = formatTelephone.substring(3);
        } else if(formatTelephone.startsWith("86")) {
            formatTelephone = formatTelephone.substring(2);
        }
        return formatTelephone;
    },

    dealSelectContactsSort(selectContacts) {
        if (selectContacts.length == 0) {
            return;
        }
        let result = [];
        let telephone = common.string.EMPTY_STR;
        let contactsMap = new Map();
        for (let item of selectContacts) {
            telephone = telephone + item.telephone + common.string.COMMA;
            if (!contactsMap.has(item.telephone)) {
                contactsMap.set(item.telephone, item);
            }
        }
        telephone = this.dealTelephoneSort(telephone.substring(0, telephone.length - 1));
        let telephones = telephone.split(common.string.COMMA);
        for (let element of telephones) {
            if (contactsMap.has(element)) {
                result.push(contactsMap.get(element));
            }
        }
        return result;
    },

    /**
     * Mobile number, sorted in ascending order.
     * @param telephone
     * @return
     */
    dealTelephoneSort(telephone) {
        if (telephone == null || telephone == common.string.EMPTY_STR) {
            return common.string.EMPTY_STR;
        }
        let result = common.string.EMPTY_STR;
        let telephones = telephone.split(common.string.COMMA);
        // If there is only one mobile number, no sorting is required.
        if (telephones.length == 1) {
            return telephone;
        }
        let telephoneMap = new Map();
        let indexs = [];
        let count = 0;
        // grouping
        for (let item of telephones) {
            if (telephoneMap.has(item.length)) {
                let strings = telephoneMap.get(item.length);
                strings.push(item);
            } else {
                let strings = [];
                strings.push(item);
                telephoneMap.set(item.length, strings);
                indexs[count++] = item.length;
            }
        }
        // Sort from Large to Small
        this.bubbleSort(indexs, count);
        for (let index of indexs) {
            let arrs = telephoneMap.get(index);
            this.bubbleSort(arrs, arrs.length);
            for (let arr of arrs) {
                result = result + arr + common.string.COMMA;
            }
        }
        // Obtain the corresponding results and pair them.
        return result.substring(0, result.length - 1);
    },

    /**
     * Bubble sort, sorted in ascending order.
     * @param arr
     * @param length
     * @return
     */
    bubbleSort(arr, length) {
        // A minimum value is generated from the back to the front at a time, and the final position of a number
        // in the sequence can be determined at a time.
        for (let i = 0; i < length - 1; i++) {
            // Improvement of bubbling so that the sequence is ordered if no reversal occurs in one pass
            for (let j = length - 1; j > i; j--) {
                // A minimum value pops up from the back at a time.
                if (arr[j] < arr[j - 1]) {
                    // Reverse order occurs, then swap
                    let temple = arr[j];
                    arr[j] = arr[j - 1];
                    arr[j - 1] = temple;
                }
            }
        }
    },
    async formatPhoneNumber(phoneNumber) {
        if (phoneNumber == null || phoneNumber === common.string.EMPTY_STR) {
            HiLog.w(TAG, "formatPhoneNumber, param is null");
            return common.string.EMPTY_STR;
        }
        let promise = call.formatPhoneNumber(phoneNumber);
        let formatPhoneNumber = common.string.EMPTY_STR;
        promise.then((value) => {
            formatPhoneNumber = value;
        }).catch((err) => {
            HiLog.e(TAG, "formatPhoneNumber, error: " + JSON.stringify(err.message));
        });
        await promise;
        return formatPhoneNumber;
    }
};