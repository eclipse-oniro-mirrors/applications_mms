/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

const TAG: string = 'PatternControl';

export default class PatternControl {

  private static sInstance: PatternControl;
  // 控制条件
  // 隐私空间模式（子用户场景）
  private isSubUser: boolean = false;
  // 分布式通信模式（子用户场景）
  private isDistributed: boolean = false;
  private isDistributedWithITLaptop = false;
  private isNonMmsMode = false;
  private isOverseaMode = false;

  // 二级控制
  // 是否走骚扰拦截流程
  public needGoBlocked: boolean = true;
  public needGoSms: boolean = true;
  public needGoMms: boolean = true;
  public needGoRcs: boolean = true;

  static getInstance() {
    if (PatternControl.sInstance == null) {
      HiLog.i(TAG, 'getInstance');
      PatternControl.sInstance = new PatternControl();
    }
    return PatternControl.sInstance;
  }

  public setSubUser(isSubUser: boolean) {
    this.isSubUser = isSubUser;
    HiLog.i(TAG, 'setSubUser isSubUser : ' + this.isSubUser);
    this.syncState();
  }

  public setRPC(isDistributed: boolean) {
    this.isDistributed = isDistributed;
    HiLog.i(TAG, 'setRPC isDistributed : ' + this.isDistributed);
    this.syncState();
  }

  private syncState() {
    this.clearState();
    this.setSubUserState();
    this.setRPCState();
  }

  private setRPCState() {
    if (this.isDistributed) {
      this.needGoBlocked = false;
      this.needGoMms = false;
      this.needGoRcs = false;
    }
  }

  private setSubUserState() {
    if (this.isSubUser) {
      this.needGoBlocked = false;
    }
  }

  private clearState() {
    this.needGoBlocked = true;
    this.needGoSms = true;
    this.needGoMms = true;
    this.needGoRcs = true;
  }
}