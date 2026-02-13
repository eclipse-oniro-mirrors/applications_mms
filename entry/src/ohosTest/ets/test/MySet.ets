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
import { DataShareResultSet, DataType } from '@kit.ArkData';

export default class MySet implements DataShareResultSet {
  flag = 1;
  columnNames: string[] = [];
  columnCount: number = 0;
  rowCount: number = 0;
  isClosed: boolean = false;



  goToFirstRow(): boolean {
    return true;
  }

  goToLastRow(): boolean {
    return true;
  }

  goToNextRow(): boolean {
    if (this.flag > 10) {
      return false;
    }
    this.flag++;
    return true;
  }

  goToPreviousRow(): boolean {
    return true;
  }

  goTo(offset: number): boolean {
    return true;
  }

  goToRow(position: number): boolean {
    return true;
  }

  getBlob(columnIndex: number): Uint8Array {
    return new Uint8Array(6);
  }

  getString(columnIndex: number): string {
    return "";
  }

  getLong(columnIndex: number): number {
    return 1;
  }

  getDouble(columnIndex: number): number {
    return 1;
  }

  close() {
  }

  getColumnIndex(columnName: string): number {
    return 1;
  }

  getColumnName(columnIndex: number): string {
    return "";
  }

  getDataType(columnIndex: number): DataType {
    return 0 as DataType;
  }
}