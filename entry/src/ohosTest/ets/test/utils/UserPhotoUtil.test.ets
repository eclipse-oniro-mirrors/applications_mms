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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium';
import { dataShare, dataSharePredicates, DataShareResultSet, DataType } from '@kit.ArkData';
import { DTGlobalContext } from '../../testability/TestAbility';
import { getPixelMapFromDB, getPixelMapFromFile } from '../../../../main/ets/utils/UserPhotoUtil';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';

export default function UserPhotoUtilTest() {
  let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
  describe('UserPhotoUtilTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('UserPhotoUtilTest_getPixelMapFromFile', 0, () => {
      getPixelMapFromFile('test_01', false, () => {},context);
      expect(context).not().assertUndefined();
    });

    it('UserPhotoUtilTest_getPixelMapFromFile_loadFromDB_false', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(AppStorage, AppStorage.get))(ArgumentMatchers.any).afterReturn({'test_01': {'': 1 }});
      getPixelMapFromFile('test_01', false, () => {},context);
      expect(context).not().assertUndefined();
    });

    it('UserPhotoUtilTest_getPixelMapFromFile_loadFromDB_true', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(AppStorage, AppStorage.get))(ArgumentMatchers.any).afterReturn({'test_01': {'': 1 }});
      getPixelMapFromFile('test_01', true, () => {},context);
      expect(context).not().assertUndefined();
    });

    it('UserPhotoUtilTest_getPixelMapFromDB', 0, async () => {
      let result = await getPixelMapFromDB('test_DB', context);
      expect(result).assertEqual(null);
    });

    it('UserPhotoUtilTest_getPixelMapFromDB_resultSet', 0, async () => {
      let resultSet: DataShareResultSet = {
        columnNames: [],
        columnCount: 0,
        rowCount: 7,
        isClosed: false,
        goToFirstRow: (): boolean => {
          return true;
        },
        goToLastRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToNextRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goToPreviousRow: (): boolean => {
          throw new Error('Function not implemented.');
        },
        goTo: (offset: number): boolean => {
          throw new Error('Function not implemented.');
        },
        goToRow: (position: number): boolean => {
          throw new Error('Function not implemented.');
        },
        getBlob: (columnIndex: number): Uint8Array => {
          return new Uint8Array;
        },
        getString: (columnIndex: number): string => {
          throw new Error('Function not implemented.');
        },
        getLong: (columnIndex: number): number => {
          throw new Error('Function not implemented.');
        },
        getDouble: (columnIndex: number): number => {
          throw new Error('Function not implemented.');
        },
        close: (): void => {
          return;
        },
        getColumnIndex: (columnName: string): number => {
          return 1;
        },
        getColumnName: (columnIndex: number): string => {
          throw new Error('Function not implemented.');
        },
        getDataType: (columnIndex: number): DataType => {
          throw new Error('Function not implemented.');
        }
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(
          {
            async query(
              uri: string,
              predicates: dataSharePredicates.DataSharePredicates,
              columns: Array<string>
            ): Promise<DataShareResultSet> {
              return resultSet;
            }
          });
      let result = await getPixelMapFromDB('test_DB', context);
      expect(result).assertEqual(null);
    });

    it('UserPhotoUtilTest_getPixelMapFromDB_catch', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterThrow('catch')
      let result = await getPixelMapFromDB('test_DB', context);
      expect(result).assertEqual(null);
    });

    it('UserPhotoUtilTest_getPixelMapFromDB_dataShareHelper_null', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(null)
      let result = await getPixelMapFromDB('test_dataShareHelper', context);
      expect(result).assertEqual(null);
    });
  })
}