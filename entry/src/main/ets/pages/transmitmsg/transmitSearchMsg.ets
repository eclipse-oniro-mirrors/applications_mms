/**
 * Copyright (c) 2023-2024 Huawei Device Co., Ltd.
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

import LooseObject from '../../data/LooseObject';
import AvatarColor from '../../model/common/AvatarColor';
import FavoriteController from '../../pages/favoritepage/favoriteController'
import TransmitSearchMsgPage from './transmitSearchMsgPage';

export class MySearch {
  public detailInfo: string = ''
  public displayName: string = ''
  public id: number = -1
  public portraitColor: Resource = AvatarColor.background.Color[0]
  public firstName: string = ''
  public nameHighlights: Array<MyText> = []
  public infoHighlights: Array<MyText> = []
  public rawContactId?: string = ''
  public contactId?: string = ''
}

export class MyText {
  public text: string = ''
  public type: number = -1
}

const TAG = 'TransmitSearchMsg';

@Builder
export function TransmitSearchMsgLoader(param: LooseObject): void {
  TransmitSearchMsg();
}

@Component
export default struct TransmitSearchMsg {
  @Provide show: boolean = true;
  @Provide index: number = 1;
  @Provide mFavoriteCtrl: FavoriteController = FavoriteController.getInstance();

  build() {
    TransmitSearchMsgPage()
  }
}
