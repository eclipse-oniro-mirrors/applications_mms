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

import common from '../data/commonData';
import { sim } from '@kit.TelephonyKit';
import HiLog from './HiLog';
import MmsPreferences from './MmsPreferences';

const TAG = 'SimSlotIdUtils';

class SimSlotIdUtils {
  /**
   * slotId是否有效
   *
   * @param slotId
   * @return true:有效, false:无效
   */
  public static isSimSlotIdAvailable(slotId: number): boolean {
    if (slotId === common.int.SIM_ONE || slotId === common.int.SIM_TWO) {
      return true;
    }
    return false;
  }

  /**
   * 获取有效的slotId
   *
   * @param slotId
   * @return 返回当前可用的slotId
   */
  public static getAvailableSlotId(slotId: number = -1): number {
    if (SimSlotIdUtils.isSimSlotIdAvailable(slotId)) {
      return slotId;
    }
    let isCardReady1: sim.SimState = sim.getSimStateSync(common.int.SIM_ONE);
    if (isCardReady1 == sim.SimState.SIM_STATE_READY || isCardReady1 == sim.SimState.SIM_STATE_LOADED) {
      return common.int.SIM_ONE;
    }
    HiLog.w(TAG, `SIM1 not available`);
    let isCardReady2: sim.SimState = sim.getSimStateSync(common.int.SIM_TWO);
    if (isCardReady2 == sim.SimState.SIM_STATE_READY || isCardReady2 == sim.SimState.SIM_STATE_LOADED) {
      return common.int.SIM_TWO;
    }
    HiLog.w(TAG, `SIM2 not available`);
    return common.int.SIM_ONE;
  }

  /**
   * 获取激活的sim卡数量
   *
   * @returns 激活的sim卡数量
   */
  public static getCountOfActiveSim(): number {
    let activeCardNum: number = 0;
    let isCardOneActive = sim.isSimActiveSync(common.int.SIM_ONE);
    let isCardTwoActive = sim.isSimActiveSync(common.int.SIM_TWO);
    if (isCardOneActive && isCardTwoActive) {
      activeCardNum = 2;
    } else if (!isCardOneActive && !isCardTwoActive) {
      activeCardNum = 0;
    } else {
      activeCardNum = 1;
    }
    return activeCardNum;
  }
}

export default SimSlotIdUtils;