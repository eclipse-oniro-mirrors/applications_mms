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
import { describe, beforeEach, it, expect, MockKit, when } from '@ohos/hypium';
import TabUtil from '../../../../main/ets/utils/TabUtil';

export default function TabUtilTest() {
  describe('TabUtilTest', () => {

    let tab: TabUtil;

    beforeEach(() => {
      tab = TabUtil.getInstance()
    })

    it('TabUtilTest_touchEndMMPicker_curTouchData_undefined', 0, () => {
      let event: TouchEvent = {
        touches: [],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': 900 * 1e9
      };
      tab.showMMContentPicker = true;
      tab.resizing = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>)
      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchEndMMPicker_perTouchData_undefined', 0, () => {
      let event: TouchEvent = {
        touches: [{
          x: 0, y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': 900 * 1e9
      };
      tab.perTouchData = undefined;
      tab.resizing = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>)
      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchEndMMPicker_totalDistance', 0, () => {
      let event: TouchEvent = {
        touches: [{
          x: 0, y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': 900 * 1e9
      };
      tab.perTouchData = {
        'y': 0
      } as TouchObject;
      tab.showMMContentPicker = true;
      tab.resizing = true;
      tab.fullHeightMMPicker = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);

      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);

      tab.fullHeightMMPicker = true;
      res = tab.touchEndMMPicker(event);
      expect(res.resizing).assertTrue();
      mocker.clear(tab);
    })

    it('TabUtilTest_touchEndMMPicker_totalDistance_minus0', 0, () => {
      let event: TouchEvent = {
        touches: [{
          x: 0, y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': -900 * 1e9
      };
      tab.perTouchData = {
        'y': 0
      } as TouchObject;
      tab.showMMContentPicker = true;
      tab.resizing = true;
      tab.fullHeightMMPicker = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))(true).afterReturn({} as Record<string, number | boolean>);

      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);

      tab.fullHeightMMPicker = true;
      res = tab.touchEndMMPicker(event);
      expect(res.resizing).assertTrue();
      mocker.clear(tab);
    })

    it('TabUtilTest_touchEndMMPicker_absDistance_lessThan_DISTANCE_LIMIT_NUMBER', 0, () => {
      let event: TouchEvent = {
        touches: [{
          x: 0, y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': -81
      };
      tab.perTouchData = {
        'y': 0
      } as TouchObject;
      tab.showMMContentPicker = true;
      tab.resizing = true;
      tab.fullHeightMMPicker = true;
      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(res.resizing).assertTrue();

      tab.resizing = true;
      tab.fullHeightMMPicker = false;
      res = tab.touchEndMMPicker(event);
      expect(res.resizing).assertTrue();
    })

    it('TabUtilTest_touchEndMMPicker_tempHeight_lessThan_limitHeight', 0, () => {
      let event: TouchEvent = {
        touches: [{
          x: 0, y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': 0
      };
      tab.showMMContentPicker = true;
      tab.resizing = true;
      tab.fullHeightMMPicker = false;
      tab.perTouchData = {
        type: TouchType.Down, x: 0, y: 0
      } as TouchObject;
      tab.heightMMContentPicker = 765 * 0.5;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);

      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');

      tab.heightMMContentPicker = 765 * 0.6;
      res = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchEndMMPicker_tempHeight_moreThan_limitHeight', 0, () => {
      let event: TouchEvent = {
        touches: [{
          x: 0, y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': 0
      };
      tab.showMMContentPicker = true;
      tab.resizing = true;
      tab.fullHeightMMPicker = false;
      tab.perTouchData = {
        type: TouchType.Down, x: 0, y: 756
      } as TouchObject;
      tab.heightMMContentPicker = 765 * 0.5;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);

      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');

      tab.heightMMContentPicker = 765 * 0.6;
      res = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchEndMMPicker_resizing_false', 0, () => {
      let event: TouchEvent = {
        touches: [{
          x: 0, y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.startTouchData = {
        'timestamp': 0, 'y': 0
      };
      tab.showMMContentPicker = true;
      tab.resizing = false;
      tab.fullHeightMMPicker = false;
      tab.perTouchData = {
        type: TouchType.Down, x: 0, y: 0
      } as TouchObject;
      tab.heightMMContentPicker = 765 * 0.5;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);

      let res: Record<string, boolean | number> = tab.touchEndMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_perTouchData_undefined', 0, () => {
      let event: TouchEvent = {
        touches: [{} as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = undefined;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_curTouchData_undefined', 0, () => {
      let event: TouchEvent = {
        touches: [],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {} as TouchObject;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_scrolling_true', 0, () => {
      let event: TouchEvent = {
        touches: [{} as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {} as TouchObject;
      tab.scrolling = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_resizing_true_tempHeight_10', 0, () => {
      let event: TouchEvent = {
        touches: [{
          y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {
        y: 0
      } as TouchObject;
      tab.scrolling = false;
      tab.resizing = true;
      tab.heightMMContentPicker = 10;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_resizing_true_tempHeight_800', 0, () => {
      let event: TouchEvent = {
        touches: [{
          y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {
        y: 0
      } as TouchObject;
      tab.scrolling = false;
      tab.resizing = true;
      tab.heightMMContentPicker = 800;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_resizing_true_tempHeight_300', 0, () => {
      let event: TouchEvent = {
        touches: [{
          y: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {
        y: 0
      } as TouchObject;
      tab.scrolling = false;
      tab.resizing = true;
      tab.heightMMContentPicker = 300;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_resizing_false_distanceX_0', 0, () => {
      let event: TouchEvent = {
        touches: [{
          y: 0,
          x: 0
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {
        y: 0, x: 0
      } as TouchObject;
      tab.scrolling = false;
      tab.resizing = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_resizing_false_direction_0', 0, () => {
      let event: TouchEvent = {
        touches: [{
          y: 1,
          x: 1
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {
        y: 0, x: 0
      } as TouchObject;
      tab.scrolling = false;
      tab.resizing = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_touchMoveMMPicker_resizing_false_direction_minus0', 0, () => {
      let event: TouchEvent = {
        touches: [{
          y: 10,
          x: 1
        } as TouchObject],
        timestamp: 1,
        type: TouchType.Down,
        changedTouches: [],
        stopPropagation: (): void => {
          throw new Error('Function not implemented.');
        },
        getHistoricalPoints: (): HistoricalPoint[] => {
          throw new Error('Function not implemented.');
        },
        preventDefault: (): void => {
          throw new Error('Function not implemented.');
        },
        target: {} as EventTarget,
        source: SourceType.Unknown,
        pressure: 0,
        tiltX: 0,
        tiltY: 0,
        sourceTool: SourceTool.Unknown
      };
      tab.perTouchData = {
        y: 0, x: 0
      } as TouchObject;
      tab.scrolling = false;
      tab.resizing = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(tab, tab.getObj))().afterReturn({} as Record<string, number | boolean>);
      let res: Record<string, boolean | number> = tab.touchMoveMMPicker(event);
      expect(JSON.stringify(res)).assertEqual('{}');
      mocker.clear(tab);
    })

    it('TabUtilTest_getObj', 0, () => {
      tab.showMMContentPicker = true;
      let res: Record<string, boolean | number> = tab.getObj(true);
      expect(res['showMMContentPicker']).assertTrue();
      tab.showMMContentPicker = false;
      res = tab.getObj(false);
      expect(res['showMMContentPicker']).assertUndefined();
    })

    it('TabUtilTest_setTabUtilData', 0, () => {
      tab.setTabUtilData(1, true, 1);
      expect(tab.topMMContentPicker).assertEqual(1);
    })

  })
}