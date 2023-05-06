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

import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import telephoneUtil from '../utils/TelephoneUtil';
import LooseObject from '../data/LooseObject';
import ContactsModel from '../model/ContactsModel';

const TAG = "ContactsService";

export default class ContactsService {
    private static instance: ContactsService;
    private contactsModel = new ContactsModel();

    private constructor() {
    }

    public static getInstance(): ContactsService {
        if (ContactsService.instance == null) {
            ContactsService.instance = new ContactsService();
        }
        return ContactsService.instance;
    }

    public async queryContactDataByCondition(actionData, callback, context): Promise<void> {
        let mmsContext = context ? context : globalThis.mmsContext;
        if (globalThis.DataWorker != null) {
            globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.queryContactDataByCondition, {
                actionData: actionData,
                context: mmsContext
            }, res => {
                callback(res);
            });
        } else {
            this.contactsModel.queryContactDataByCondition(actionData, callback, mmsContext);
        }

    }

    public async queryContactDataSizeByCondition(actionData, callback, context): Promise<void> {
        let mmsContext = context ? context : globalThis.mmsContext;
        if (globalThis.DataWorker != null) {
            globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.queryContactDataSizeByCondition, {
                actionData: actionData,
                context: mmsContext
            }, res => {
                callback(res);
            });
        } else {
            this.contactsModel.queryContactDataSizeByCondition(actionData, callback, mmsContext);
        }
    }

    public async queryContactByCondition(actionData, callback, context): Promise<void> {
        let mmsContext = context ? context : globalThis.mmsContext;
        if (globalThis.DataWorker != null) {
            globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.queryContactByCondition, {
                actionData: actionData,
                context: mmsContext
            }, res => {
                callback(res);
            });
        } else {
            this.contactsModel.queryContactByCondition(actionData, callback, mmsContext);
        }
    }

    public async queryContactSizeByCondition(actionData, callback, context): Promise<void> {
        let mmsContext = context ? context : globalThis.mmsContext;
        if (globalThis.DataWorker != null) {
            globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.queryContactSizeByCondition, {
                actionData: actionData,
                context: mmsContext
            }, res => {
                callback(res);
            });
        } else {
            this.contactsModel.queryContactSizeByCondition(actionData, callback, mmsContext);
        }
    }

    public async queryRawContactSizeByCondition(actionData, callback, context): Promise<void> {
        let mmsContext = context ? context : globalThis.mmsContext;
        if (globalThis.DataWorker != null) {
            globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.queryRawContactSizeByCondition, {
                actionData: actionData,
                context: mmsContext
            }, res => {
                callback(res);
            });
        } else {
            this.contactsModel.queryRawContactSizeByCondition(actionData, callback, mmsContext);
        }
    }

    public async queryContactViewByCondition(actionData, callback, context): Promise<void> {
        let mmsContext = context ? context : globalThis.mmsContext;
        if (globalThis.DataWorker != null) {
            globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.queryContactViewByCondition, {
                actionData: actionData,
                context: mmsContext
            }, res => {
                callback(res);
            });
        } else {
            this.contactsModel.queryContactViewByCondition(actionData, callback, mmsContext);
        }
    }

    public queryContact(actionData, callback, context): void {
        this.queryContactByCondition(actionData, res => {
            if (res.code == common.int.FAILURE) {
                callback(res);
                return;
            }
            actionData.contactIds = res.abilityResult[0];
            this.queryContactDataByCondition(actionData, res => {
                if (res.code == common.int.FAILURE) {
                    callback(res);
                    return;
                }
                let contactList: Array<LooseObject> = this.buildContactList(res.abilityResult);
                let result: LooseObject = {};
                result.code = common.int.SUCCESS;
                result.response = contactList;
                callback(result);
            }, context);
        }, context);
    }

    public dealContactParams(contactObjects): LooseObject {
        let contactParams: LooseObject = {};
        if (contactObjects && contactObjects != common.string.EMPTY_STR) {
            let params: Array<LooseObject> = [];
            try {
                params = JSON.parse(contactObjects);
            } catch (Error) {
                HiLog.i(TAG, `JSON.parse error ${Error}`);
                return contactParams;
            }
            let contactsNumber: string = common.string.EMPTY_STR;
            let contactsName: string = common.string.EMPTY_STR;
            let contactsNumberFormat: string = common.string.EMPTY_STR;
            let length: number = params.length;
            for (let item of params) {
                contactsNumber = contactsNumber + item.telephone + common.string.COMMA;
                contactsNumberFormat = contactsNumberFormat + item.telephone + common.string.COMMA;
                if (item.contactsName) {
                    contactsName += (item.contactsName + common.string.COMMA);
                } else if (length > 1) {
                    contactsName += (item.telephone + common.string.COMMA);
                }
            }
            let telephone: string = contactsNumber.substring(0, contactsNumber.length - 1);
            contactsNumber = telephoneUtil.dealTelephoneSort(telephone);
            contactParams.strContactsNumber = contactsNumber;
            contactParams.strContactsNumberFormat = contactsNumber;
            contactParams.strContactsName = contactsName.substring(0, contactsName.length - 1);
            contactParams.contactsNum = length;
        }
        return contactParams;
    }

    public judgeContactExist(actionData, callback, context): void {
        this.queryContactDataSizeByCondition(actionData, res => {
            let isContactExist: boolean = false;
            if (res.code == common.int.FAILURE) {
                HiLog.e(TAG, "judgeProfileExit fail!");
                callback(isContactExist);
            } else {
                if (res.abilityResult > 0) {
                    isContactExist = true;
                }
                callback(isContactExist);
            }
        }, context);
    }

    private buildContactList(contacts): Array<LooseObject> {
        let contactList: Array<LooseObject> = [];
        for (let contact of contacts) {
            let item: LooseObject = {};
            item.contactName = contact.displayName;
            item.headImage = "icon/user_avatar_full_fill.svg";
            item.telephone = contact.detailInfo;
            item.telephoneFormat = contact.detailInfo;
            item.select = false;
            contactList.push(item);
        }
        return contactList;
    }
}
