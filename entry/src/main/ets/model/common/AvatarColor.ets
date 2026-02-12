/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

class AvatarColor {
  background: Record<string, Resource[]> = {
    'Color': [$r('sys.color.ohos_id_color_special1'),
      $r('sys.color.ohos_id_color_special2'),
      $r('sys.color.ohos_id_color_special4'),
      $r('sys.color.ohos_id_color_special11'),
      $r('sys.color.ohos_id_color_special9'),
      $r('sys.color.ohos_id_color_special7')],
  }
}

export default new AvatarColor()



