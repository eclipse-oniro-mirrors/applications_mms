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

/**
 * MMS message types
 */
export class ChatbotCardContentType {
  /**
   * The text vcard type
   */
  public static readonly TEXT_VCARD = 'text/x-vCard';

  /**
   * Indicates whether the type is image.
   *
   * @param contentType Check Type
   * @return Whether the type is image.
   */
  public static isImageType(contentType: string): boolean {
    return Boolean(contentType) && contentType.startsWith('image/');
  }

  /**
   * Indicates whether the type is video.
   *
   * @param contentType Check Type
   * @return Whether the type is video.
   */
  public static isVideoType(contentType: string): boolean {
    return Boolean(contentType) && contentType.startsWith('video/');
  }

  /**
   * Indicates whether the type is audio.
   *
   * @param contentType Check Type
   * @return Whether the type is audio.
   */
  public static isAudioType(contentType: string): boolean {
    return Boolean(contentType) && contentType.startsWith('audio/');
  }


  /**
   * Whether is the vcard type
   *
   * @param contentType the content type
   * @return true is vcard type
   */
  public static isVCardType(contentType: string): boolean {
    return Boolean(contentType) && contentType.toLowerCase() === ChatbotCardContentType.TEXT_VCARD.toLowerCase();
  }
}