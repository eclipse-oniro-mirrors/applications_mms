/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import HiLog from './HiLog';

const FULL_CONTENT_HEIGHT: number = 756;
const MIN_MM_PICKER_HEIGHT: number = 112;
const SPEED_LIMIT_NUMBER: number = 800;
const DISTANCE_LIMIT_NUMBER: number = 150;

const TAG = 'TabUtil ';

export default class TabUtil {
  private static sInstance: TabUtil;
  showMMContentPicker: boolean = false;
  resizing: boolean = false;
  scrolling: boolean = false;
  heightMMContentPicker: number = MIN_MM_PICKER_HEIGHT;
  animationIterations: number = 0;
  topMMContentPicker: number = FULL_CONTENT_HEIGHT - MIN_MM_PICKER_HEIGHT;
  perTouchData?: TouchObject;
  startTouchData: Record<string, number> = {};
  fullHeightMMPicker: boolean = false;

  static getInstance() {
    if (TabUtil.sInstance == null) {
      TabUtil.sInstance = new TabUtil();
    }
    return TabUtil.sInstance;
  }

  touchEndMMPicker(event: TouchEvent): Record<string, boolean | number> {
    if (this.resizing) {
      let curTouchData: TouchObject = event.touches[0];
      if (!curTouchData) {
        return this.getObj();
      }
      if (!this.perTouchData) {
        return this.getObj();
      }
      let distance = this.perTouchData.y - curTouchData.y;
      let totalDistance = this.startTouchData.y - curTouchData.y
      let absDistance = Math.abs(totalDistance);
      let speed = absDistance / (event.timestamp - this.startTouchData.timestamp) * 1e9;
      if (speed > SPEED_LIMIT_NUMBER) {
        if (totalDistance > 0) {
          if (!this.fullHeightMMPicker) {
            this.heightMMContentPicker = FULL_CONTENT_HEIGHT;
            this.topMMContentPicker = 0;
            this.fullHeightMMPicker = true;
          }
          return this.getObj();
        } else if (totalDistance < 0) {
          if (this.fullHeightMMPicker) {
            this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
            this.topMMContentPicker = FULL_CONTENT_HEIGHT - MIN_MM_PICKER_HEIGHT;
            this.fullHeightMMPicker = false;
            if (absDistance > DISTANCE_LIMIT_NUMBER) {
              this.animationIterations = 0;
              this.showMMContentPicker = false;
            }
          } else {
            this.animationIterations = 0;
            this.showMMContentPicker = false;
          }
          return this.getObj(true);
        }
      }
      let tempHeight = Math.ceil(this.heightMMContentPicker + distance);
      let limitHeight = FULL_CONTENT_HEIGHT * 0.6;
      if (tempHeight < limitHeight) {
        this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
        this.topMMContentPicker = FULL_CONTENT_HEIGHT - MIN_MM_PICKER_HEIGHT;
        this.fullHeightMMPicker = false;
      } else if (tempHeight >= limitHeight) {
        this.heightMMContentPicker = FULL_CONTENT_HEIGHT;
        this.topMMContentPicker = 0;
        this.fullHeightMMPicker = true;
      }
      this.resizing = false;
    } else {
      this.scrolling = false;
    }
    return this.getObj();
  }

  touchMoveMMPicker(event: TouchEvent): Record<string, boolean | number> {
    if (!this.perTouchData) {
      this.perTouchData = event.touches[0];
      return this.getObj();
    }
    let curTouchData = event.touches[0];
    if (!curTouchData) {
      return this.getObj();
    }
    if (this.scrolling) {
      return this.getObj();
    } else if (this.resizing) {
      let distance = this.perTouchData?.y - curTouchData.y;
      let tempHeight = Math.ceil(this.heightMMContentPicker + distance);
      HiLog.i(TAG, 'onTouch move: tempHeight: ' + tempHeight);
      if (tempHeight < MIN_MM_PICKER_HEIGHT) {
        this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
        this.topMMContentPicker = FULL_CONTENT_HEIGHT - MIN_MM_PICKER_HEIGHT;
      } else if (tempHeight > FULL_CONTENT_HEIGHT) {
        this.heightMMContentPicker = FULL_CONTENT_HEIGHT;
        this.topMMContentPicker = 0;
      } else {
        this.heightMMContentPicker = tempHeight;
        this.topMMContentPicker = FULL_CONTENT_HEIGHT - tempHeight;
      }
    } else {
      let distanceX = curTouchData.x - this.perTouchData?.x;
      let distanceY = curTouchData.y - this.perTouchData?.y;
      if (!distanceX && !distanceY) {
        return this.getObj();
      }
      let direction = Math.abs(distanceX) - Math.abs(distanceY);
      HiLog.i(TAG, 'onTouch move: judge: ' + direction);
      if (direction < 0) {
        this.resizing = true;
        this.animationIterations = 1;
      } else {
        this.scrolling = true;
      }
    }
    this.perTouchData = curTouchData;
    return this.getObj();
  }

  getObj(isContentPicker?: boolean): Record<string, boolean | number> {
    let obj: Record<string, boolean | number> = {
      'resizing': this.resizing,
      'fullHeightMMPicker': this.fullHeightMMPicker,
      'heightMMContentPicker': this.heightMMContentPicker,
      'topMMContentPicker': this.topMMContentPicker
    }
    if (isContentPicker) {
      obj['showMMContentPicker'] = this.showMMContentPicker;
    }
    return obj;
  }

  setTabUtilData(heightMMContentPicker: number, fullHeightMMPicker: boolean, topMMContentPicker: number) {
    this.heightMMContentPicker = heightMMContentPicker;
    this.fullHeightMMPicker = fullHeightMMPicker;
    this.topMMContentPicker = topMMContentPicker;
  }
}