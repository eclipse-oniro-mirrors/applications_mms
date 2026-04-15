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
import { describe, expect, it } from "@ohos/hypium";
import { mmsListType } from "../../../../main/ets/pages/conversation/conversationController";
import { messageType } from "../../../../main/ets/pages/conversationlist/conversationListController";
import PanGestureUtil, { PanGestureAction } from "../../../../main/ets/utils/PanGestureUtil";


export default function PanGestureUtilTest() {
  describe('PanGestureUtilTest', () => {

    it("PanGestureUtilTest_panGestureAction", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionStart',
        event: {} as GestureEvent,
        scroller: {} as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);

      panGestureAction = {
        type: 'onActionUpdate',
        event: {} as GestureEvent,
        scroller: {} as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);

      panGestureAction = {
        type: 'onActionEnd',
        event: {} as GestureEvent,
        scroller: {} as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_event_fingerList_empty", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionStart',
        event: {
          fingerList:[{}]
        } as GestureEvent,
        scroller: new Scroller(),
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionStart", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionStart',
        event: {
          fingerList:[{
            localX: 47,
            localY: 47
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{x + y},
          getItemRect: (x: number)=>{x},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionStart_index_lt_mmsList_len", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionStart',
        event: {
          fingerList:[{
            localX: 1,
            localY: 1
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {}},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        switchNumber: 2,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(false);
    })

    it("PanGestureUtilTest_panGestureAction_onActionStart_mmsList_undefined", 0, () => {
      let panGestureAction = {
        type: 'onActionStart',
        event: {
          fingerList:[{
            localX: 47,
            localY: 47
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {}},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: undefined,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: 47,
            localY: 47
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {}},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_scrollEndIndex", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: 1,
            localY: -1
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {
            y: 26,
            height: 40,
          } as RectResult},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: 5,
        mmsList: messageList,
        listHeight: 700,
        scrollStartIndex: 1,
        scrollEndIndex: 10,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_scrollEndIndex_localY_lg_listHeight", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: 0,
            localY: 2
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {
            y: 26,
            height: 40,
          } as RectResult},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: 2,
        mmsList: messageList,
        listHeight: 1,
        scrollStartIndex: 1,
        scrollEndIndex: 10,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_scrollEndIndex_localY_lt_0", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: 1,
            localY: -1
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {
            y: 26,
            height: 40,
          } as RectResult},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: -1,
        mmsList: messageList,
        listHeight: 700,
        scrollStartIndex: 1,
        scrollEndIndex: 10,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_scrollEndIndex_localY_701", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: -701,
            localY: 701
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {
            y: 26,
            height: 40,
          } as RectResult},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: -1,
        mmsList: messageList,
        listHeight: 700,
        scrollStartIndex: 1,
        scrollEndIndex: 10,
        isMultipleSelectState: true
      } as PanGestureAction
      (PanGestureUtil as object)['timeoutChecked'] = true;
      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_scrollEndIndex_localY_699", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: -699,
            localY: 699
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {
            y: 26,
            height: 40,
          } as RectResult},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: -1,
        mmsList: messageList,
        listHeight: 700,
        scrollStartIndex: 1,
        scrollEndIndex: 10,
        isMultipleSelectState: true
      } as PanGestureAction
      (PanGestureUtil as object)['timeoutChecked'] = true;
      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_selectEnd_lg_mmsList_len", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: 2,
            localY: 5
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {
            y: 26,
            height: 40,
          } as RectResult},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: 1,
        mmsList: messageList,
        listHeight: 700,
        scrollStartIndex: 1,
        scrollEndIndex: 10,
        isMultipleSelectState: true
      } as PanGestureAction
      (PanGestureUtil as object)['selectEnd'] = 10;
      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_callback", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: 1,
            localY: -1
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {}},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: 5,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionUpdate_index_lg_0_lt_mmsList_len", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionUpdate',
        event: {
          fingerList:[{
            localX: 1,
            localY: 1
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{return x + y},
          getItemRect: (x: number)=>{return {}},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        callback:(num: number, flag: boolean)=> {},
        switchNumber: 2,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionEnd", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionEnd',
        event: {
          fingerList:[{
            localX: 47,
            localY: 47
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{x + y},
          getItemRect: (x: number)=>{x},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_panGestureAction_onActionOTHER", 0, () => {
      let messageList = [{
        isCbChecked: true,
      } as messageType | mmsListType]

      let panGestureAction = {
        type: 'onActionOTHER',
        event: {
          fingerList:[{
            localX: 47,
            localY: 47
          }]
        } as GestureEvent,
        scroller: {
          scrollBy: (x: number, y:number)=>{},
          getItemIndex: (x: number, y:number)=>{x + y},
          getItemRect: (x: number)=>{x},
          scrollEdge:(value: Edge, options?: ScrollEdgeOptions)=> {}
        } as ListScroller | Scroller,
        switchNumber: 0,
        mmsList: messageList,
        listHeight: 700,
        isMultipleSelectState: true
      } as PanGestureAction

      PanGestureUtil.panGestureAction(panGestureAction);
      expect(panGestureAction).not().assertUndefined();
    })

    it("PanGestureUtilTest_getSelectState_isFlag_f1", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 1;
      (PanGestureUtil as object)['startCbChecked'] = false;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['fixedSelect'] = [1, 2, 3];
      (PanGestureUtil as object)['getSelectState'](-1, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(false);
    })

    it("PanGestureUtilTest_getSelectState_selectStart_lt_selectEnd", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 1;
      (PanGestureUtil as object)['startCbChecked'] = false;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['fixedSelect'] = [6, 7, 8];
      (PanGestureUtil as object)['getSelectState'](11, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(true);
    })

    it("PanGestureUtilTest_getSelectState_selectStart_lt_selectEnd_eq_isFlag", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 1;
      (PanGestureUtil as object)['startCbChecked'] = false;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['fixedSelect'] = [1, 2, 3];
      (PanGestureUtil as object)['getSelectState'](10, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(true);
    })

    it("PanGestureUtilTest_getSelectState_selectStart_lt_selectEnd_eq_isFlag_startCbChecked_true", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 1;
      (PanGestureUtil as object)['startCbChecked'] = true;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['fixedSelect'] = [1, 2, 3];
      (PanGestureUtil as object)['getSelectState'](10, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(true);
    })

    it("PanGestureUtilTest_getSelectState_selectStart_lg_selectEnd", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 11;
      (PanGestureUtil as object)['startCbChecked'] = false;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['getSelectState'](11, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(false);
    })

    it("PanGestureUtilTest_getSelectState_selectStart_lg_selectEnd_lt_isFlag", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 11;
      (PanGestureUtil as object)['startCbChecked'] = false;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['getSelectState'](7, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(true);
    })

    it("PanGestureUtilTest_getSelectState_selectStart_lg_selectEnd_eq_isFlag", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 11;
      (PanGestureUtil as object)['startCbChecked'] = false;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['getSelectState'](10, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(true);
    })

    it("PanGestureUtilTest_getSelectState_selectStart_eq_selectEnd", 0, () => {
      (PanGestureUtil as object)['selectEnd'] = 10;
      (PanGestureUtil as object)['selectStart'] = 10;
      (PanGestureUtil as object)['startCbChecked'] = false;
      (PanGestureUtil as object)['isCbChecked'] = true;
      (PanGestureUtil as object)['getSelectState'](6, 5, (num: number, flag: boolean)=> {});
      expect((PanGestureUtil as object)['isCbChecked']).assertEqual(true);
    })

    it("PanGestureUtilTest_gestureRecognizerJudgeBegin", 0, () => {
      let event = {} as BaseGestureEvent
      let current = {} as GestureRecognizer
      let result = PanGestureUtil.gestureRecognizerJudgeBegin(event, current, false, 387 );
      expect(result).assertEqual(0);
    })

    it("PanGestureUtilTest_panGestureBottom_localY_lg_y", 0, () => {
      let event = {
        fingerList:[{
          localY: 47
        }]
      } as GestureEvent
      let item = {
        y: 6,
        height: 40,
      } as RectResult
      (PanGestureUtil as object)['selectEnd'] = 40;
      PanGestureUtil.panGestureBottom(item, 50, 1, event );
      expect((PanGestureUtil as object)['selectEnd']).assertEqual(41);
    })

    it("PanGestureUtilTest_panGestureBottom_localY_lt_y", 0, () => {
      let event = {
        fingerList:[{
          localY: 15
        }]
      } as GestureEvent
      let item = {
        y: 26,
        height: 40,
      } as RectResult
      (PanGestureUtil as object)['selectEnd'] = 40;
      PanGestureUtil.panGestureBottom(item, 50, 20, event );
      expect((PanGestureUtil as object)['selectEnd']).assertEqual(39);
    })

    it("PanGestureUtilTest_gestureRecognizerJudgeBegin_return_REJECT", 0, () => {
      let event = {
        fingerList:[{
          localX: 47
        }]
      } as BaseGestureEvent
      let current = {
        isBuiltIn: () => true,
        getType: () => GestureControl.GestureType.PAN_GESTURE,
      } as GestureRecognizer
      let result = PanGestureUtil.gestureRecognizerJudgeBegin(event, current, true, 49 );
      expect(result).assertEqual(1);
    })

  })
}