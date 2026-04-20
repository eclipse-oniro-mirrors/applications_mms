/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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


import commonData from '../data/commonData';
import { mmsListType } from '../pages/conversation/conversationController';
import { messageType } from '../pages/conversationlist/conversationListController';
import HiLog from './HiLog';
import { i18n } from '@kit.LocalizationKit';
import LooseObject from '../data/LooseObject';
import dotCommon,{ dotNoNeedParmas } from './MmsDot/DotCommon';
import DotUtil from './MmsDot/DotUtils';

const TAG = 'PanGestureUtil';
const CHECKBOX_WIDTH = 48
const SPEED_FLAG = 350

export interface PanGestureAction {
  type: string,
  event: GestureEvent,
  scroller: ListScroller | Scroller,
  isMultipleSelectState: boolean,
  switchNumber: number,
  mmsList?: messageType[] | mmsListType[] | LooseObject[],
  callback?: Function,
  listHeight?: number,
  // List显示区域内最后一个子组件的索引值
  scrollEndIndex?: number,
  // List显示区域内第一个子组件的索引值
  scrollStartIndex?: number
}

class PanGestureUtil {
  private selectStart: number = -1
  private selectEnd: number = -1
  private startCbChecked: boolean = false
  private timeoutChecked: boolean = true
  // 为了保障第一项选后状态不变，需要重新声明一个变量去对应其他项的状态
  private isCbChecked: boolean = true
  // 用于存储当前选已选择的多选框下标
  private currentlySelect: number[] = []
  // 用来判断当前滑动经过的index是否存在于上次已选中的index
  private fixedSelect: number[] = []

  /**
   * 滑动多选
   */
  panGestureAction(params: PanGestureAction) {
    let type: string = params.type
    let event: GestureEvent = params.event
    let scroller: ListScroller | Scroller = params.scroller
    let isMultipleSelectState: boolean = params.isMultipleSelectState
    let switchNumber: number = params.switchNumber
    let mmsList: messageType[] | mmsListType[] | LooseObject[] | undefined = params.mmsList
    let callback: Function | undefined = params.callback
    let listHeight: number | undefined = params.listHeight
    let scrollEndIndex: number | undefined = params.scrollEndIndex
    let scrollStartIndex: number | undefined = params.scrollStartIndex
    if (!scroller || !isMultipleSelectState) {
      HiLog.e(TAG, `panGestureAction, scroller undefined or isMultipleSelectState is false`);
      return;
    }
    if (event.fingerList[0] != undefined && event.fingerList[0].localX != undefined &&
      event.fingerList[0].localY != undefined) {
      let index = scroller.getItemIndex(event.fingerList[0].localX, event.fingerList[0].localY)
      index = index - switchNumber
      switch (type) {
        case commonData.SLIDE_ACTION_TYPE.START: {
          if (mmsList == undefined) {
            return
          }
          if (index >= 0 && index < mmsList.length) {
            this.selectStart = index
            this.startCbChecked = !mmsList[this.selectStart].isCbChecked
            this.isCbChecked = this.startCbChecked
          }
          break;
        }
        case commonData.SLIDE_ACTION_TYPE.UPDATE: {
          if (mmsList == undefined || callback == undefined || listHeight == undefined) {
            HiLog.e(TAG, `panGestureAction, callback or listHeight is undefined`);
            return
          }
          // 设置一个阀门，只有当手势移到下一个index的位置时才会调用回调函数
          let isFlag: number = this.selectEnd
          if (index >= 0 && index < mmsList.length) {
            this.selectEnd = index
          } else if (index < 0 && (event.fingerList[0].localY > listHeight || event.fingerList[0].localY < 0)) {
            // 获取当前索引的大小及位置
            try {
              const item: RectResult = scroller.getItemRect(this.selectEnd)
              if (!item || !scrollEndIndex || scrollStartIndex === undefined) {
                return
              }
              scrollEndIndex = scrollEndIndex - switchNumber
              this.panGestureBottom(item, scrollEndIndex, scrollStartIndex, event)
            } catch (err) {
              HiLog.i(TAG, `Failed to getItemRect, Code is ${err.code}, message is ${err.message}`);
            }
          }
          if (this.selectEnd >= mmsList.length || isFlag >= mmsList.length) {
            return
          }
          if (this.selectStart >= 0 && this.selectEnd >= 0 && isFlag != this.selectEnd) {
            this.getSelectState(isFlag, this.selectEnd, callback);
          }
          if (this.timeoutChecked) {
            if (event.fingerList[0].localY > listHeight) {
              this.timeoutChecked = false
              scroller.scrollEdge(Edge.Bottom, {
                velocity: SPEED_FLAG
              })
            } else if (event.fingerList[0].localY < 0) {
              this.timeoutChecked = false
              scroller.scrollEdge(Edge.Top, {
                velocity: SPEED_FLAG
              })
            }
          }
          if (event.fingerList[0].localY > 0 && event.fingerList[0].localY < listHeight) {
            scroller.scrollBy(0, 0);
            this.timeoutChecked = true
          }
          break;
        }
        case commonData.SLIDE_ACTION_TYPE.END: {
          DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.PANGESTURE_MULTIPLE_SELECT);
          // 手势结束时，需要将当前选中的多选框下标存入数组中
          const start = Math.min(this.selectStart, this.selectEnd);
          const end = Math.max(this.selectStart, this.selectEnd);
          for (let i = start; i <= end; i++) {
            this.addFirstSelect(i, this.startCbChecked)
          }
          this.fixedSelect = this.currentlySelect.map(item => item)
          this.timeoutChecked = true
          this.selectStart = -1
          this.selectEnd = -1
          scroller.scrollBy(0, 0);
          break;
        }
        default: {
        }
      }
    }
  }

  /**
   * 当前滑动多选规格：来回滑动可撤销，起始状态不变
   * 1.第一次滑动：其他选项的状态与第一项选后(已选/未选)保持一致
   * 2.二次及以上滑动经过，第一项选后状态不改变，其他选项状态恢复上一次状态
   * 3.如果滑动前有已选择的项：
   *       滑动起始项处于未选择状态，则本次滑动选择只针对新选中的项进行操作
   *       滑动起始项处于选择状态，则会改变新选中的项和上次已选择的项的状态
   *
   * 获取当前手势滑动选择的多选框数量，并改变对应的状态
   */
  private getSelectState(isFlag: number, index: number, callback: Function) {
    const beginIndex = isFlag === -1 ? this.selectStart : isFlag;
    let start = Math.min(beginIndex, index);
    let end = Math.max(beginIndex, index);
    if (this.selectStart < this.selectEnd) {
      // 起始点小于结束点，手势向上滑动，特殊情况
      if (isFlag > this.selectEnd) {
        this.isCbChecked = !this.startCbChecked;
        // 与正常滑动不同，这种情况需要在手势滑到 index - 1 的时候再去改变当前index选中状态
        start = start + 1;
        // 起始点小于结束点，手势向下滑动，正常情况，当手势刚刚滑动到index时，立即改变index状态
      } else if (isFlag < this.selectEnd) {  
        this.isCbChecked = this.startCbChecked;
      }
    } else if (this.selectStart > this.selectEnd) {
      // 起始点大于结束点，手势向上滑动，正常情况
      if (isFlag > this.selectEnd) {
        this.isCbChecked = this.startCbChecked;
      } else if (isFlag < this.selectEnd) { // 起始点小于结束点，手势向下滑动，特殊情况
        this.isCbChecked = !this.startCbChecked;
        // 与正常滑动不同，这种情况需要在手势滑到 index + 1 的时候再去改变当前index选中状态
        end = end - 1;
      }
    } else {
      this.isCbChecked = !this.startCbChecked;
    }
    for (let i = start; i <= end; i++) {
      // 如果当前起始点存在于上次选中的多选框之内，则向下或向上滑动会改变上次选中的多选框的状态
      if (this.fixedSelect.includes(this.selectStart) && this.fixedSelect.includes(i)) {
        // 第一项选后状态始终保持不变，其他选项状态随着滑动经过与否改变或恢复上一次状态
        if (i === this.selectStart) {
          callback(i, this.startCbChecked);
        } else {
          callback(i, this.isCbChecked);
        }
        this.addFirstSelect(i, this.isCbChecked);
      // 如果当前起始点不存在于当前已选的项之内，则本次滑动只针对新选中的项进行操作
      } else if (this.fixedSelect.includes(i) && !this.fixedSelect.includes(this.selectStart)) {
        callback(i, true);
      } else {
        if (i == this.selectStart || !this.startCbChecked) {
          callback(i, this.startCbChecked);
        } else {
          callback(i, this.isCbChecked);
        }
      }
    }
  }

  /**
   * 滑动多选手势在最底部或最顶部导航栏
   */
  panGestureBottom(item: RectResult, scrollEndIndex: number, scrollStartIndex: number, event: GestureEvent) {
    // 向下滚动: 只要手指y轴超过当前index索引组件的y+height，并且当前index非最大值，就提供下一个index
    if (event.fingerList[0].localY > item.y + item.height && this.selectEnd < scrollEndIndex) {
        this.selectEnd = this.selectEnd + 1;
    }
    // 向上滚动: 手指y轴小于当前index索引组件的y，并且当前索引大于最小值，就提供上一个index
    if (event.fingerList[0].localY < item.y && this.selectEnd > scrollStartIndex) {
      this.selectEnd = this.selectEnd - 1;
    }
  }

  /**
   * 滑动多选拦截手势
   */
  gestureRecognizerJudgeBegin(event: BaseGestureEvent, current: GestureRecognizer,
    isMultipleSelectState: boolean, listWidth: number): number {
    if (isMultipleSelectState && current.isBuiltIn() && current.getType() == GestureControl.GestureType.PAN_GESTURE &&
      (i18n.isRTL(i18n.System.getSystemLanguage()) ? event.fingerList[0]?.localX < CHECKBOX_WIDTH :
        event.fingerList[0]?.localX > listWidth - CHECKBOX_WIDTH)) {
      return GestureJudgeResult.REJECT;
    }
    return GestureJudgeResult.CONTINUE;
  }

  /**
   * 用于存储上一次手势选中的多选框下标
   */
  addFirstSelect(index: number, isCbChecked: boolean, isOnClick?: boolean, listLength?: number) {
    // 点击全选按钮时，直接通过for循环去给数组添加数据，防止重复调用addFirstSelect方法
    if (listLength) {
      this.currentlySelect = []
      for(let i = 0; i < listLength; i++) {
        this.currentlySelect.push(i)
      }
    } else {
      if (!this.currentlySelect.includes(index) && isCbChecked) {
        this.currentlySelect.push(index)
      } else if (this.currentlySelect.includes(index) && !isCbChecked) {
        this.currentlySelect.splice(this.currentlySelect.indexOf(index), 1)
      }
    }
    if (isOnClick) {
      this.fixedSelect = this.currentlySelect.map(item => item)
    }
  }

  /**
   * 取消多选时，重置存储数组
   */
  refresh() {
    HiLog.i(TAG, `PanGestureUtile refresh`);
    this.currentlySelect = []
    this.fixedSelect = []
  }
}

export default new PanGestureUtil()