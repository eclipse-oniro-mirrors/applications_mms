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

export namespace ContactInfo {
  /**
   * Provides common type enumeration for contact information
   */
  export enum ContactCommonType {
    HOME = 'HOME',
    WORK= 'WORK'
  }
  /**
   * Provides attributes for email information
   */
  export class Email {
    /**
     * Indicates the email address.
     */
    public email: string | null = null;
    /**
     * Indicates type of address label.
     */
    public labelName: string | null = null;
  }

  /**
   * Provides attributes for address information
   */
  export class Address {
    /**
     * Indicates the address info.
     */
    public address: string | null = null;
    /**
     * Indicates type of address label.
     */
    public labelName: string | null = null;
  }
}
