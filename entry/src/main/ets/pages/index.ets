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
import mediaquery from '@ohos.mediaquery';
import IndexController from "./indexController"
import ConversationList from "./conversationlist/conversationList"
import ConListController from "./conversationlist/conversationListController";
import DeviceUtil from "../utils/DeviceUtil";
import MmsPreferences from "../utils/MmsPreferences";
import HiLog from "../utils/HiLog"
import WantUtil from "../utils/WantUtil";

const TAG = "Index";

@Entry
@Component
struct Index {
  @State mIndexCtrl: IndexController = IndexController.getInstance();
  @State mConListCtrl: ConListController = ConListController.getInstance();
  private gridColumns: GridRowColumnOption = { sm: 4, md: 8, lg: 12 };
  private girdSpan: GridColColumnOption = { sm: 4, md: 8, lg: 12 };
  private gridGutter: string = "24vp";
  private gridMargin: string = "24vp";
  private smListener: mediaquery.MediaQueryListener;
  private mdListener: mediaquery.MediaQueryListener;
  private lgListener: mediaquery.MediaQueryListener;

  isBreakpointSM = (mediaQueryResult) => {
    if (mediaQueryResult.matches) {
      AppStorage.SetOrCreate('curBp', 'sm')
    }
  }
  isBreakpointMD = (mediaQueryResult) => {
    if (mediaQueryResult.matches) {
      AppStorage.SetOrCreate('curBp', 'md')
    }
  }
  isBreakpointLG = (mediaQueryResult) => {
    if (mediaQueryResult.matches) {
      AppStorage.SetOrCreate('curBp', 'lg')
    }
  }

  /**
   * The function executes after a new instance of the custom component is created and before its build function
   * is executed.
   * Allows state variables to be changed in the aboutToAppear function, and these changes will take effect in
   * subsequent executions of the build function.
   */
  aboutToAppear() {
    this.mIndexCtrl.onInit();
    this.mConListCtrl.onInit();
    this.smListener = mediaquery.matchMediaSync('(320vp<width<=520vp)');
    this.smListener.on("change", this.isBreakpointSM);
    this.mdListener = mediaquery.matchMediaSync('(520vp<width<=840vp)');
    this.mdListener.on("change", this.isBreakpointMD);
    this.lgListener = mediaquery.matchMediaSync('(840vp<width)');
    this.lgListener.on("change", this.isBreakpointLG);
  }

  /**
   * Function executes before custom component destructor consumption.
   * Changing state variables in the aboutToDisappear function is not allowed, especially changes to the @Link
   * variable may cause unstable application behavior.
   */
  aboutToDisappear() {
    this.mConListCtrl.onDestroy();
    this.mIndexCtrl.onDestroy();
    this.smListener.off("change", this.isBreakpointSM);
    this.mdListener.off("change", this.isBreakpointMD);
    this.lgListener.off("change", this.isBreakpointLG);
  }

  /**
   * Triggers once when this page is displayed. In scenarios such as routing and application access to the foreground
   * and background, only customized components modified by @Entry take effect.
   */
  async onPageShow() {
    WantUtil.getWant();
    await MmsPreferences.getInstance().initPreferences();
    this.mIndexCtrl.onShow();
    this.mConListCtrl.onShow();
  }

  /**
   * Triggers once when this page disappears. In scenarios such as routing and application access to the foreground
   * and background, only customized components modified by @Entry take effect.
   */
  onPageHide() {
    this.mConListCtrl.onHide();
    this.mIndexCtrl.onHide();
  }

  /**
   * Triggered when a user clicks the back button. Only the customized component modified by @Entry takes effect.
   * If true is returned, the page processes the return logic and does not route the page.
   * If false is returned, the default return logic is used.
   * If no value is returned, the value is treated as false.
   */
  onBackPress() {
    if (this.mIndexCtrl.showConList) {
      return this.mConListCtrl.onBackPress();
    }
    return false;
  }

  build() {
    Column() {
      GridRow({ columns: this.gridColumns, gutter: this.gridGutter }) {
        GridCol({ span: this.girdSpan }) {
          if (this.mIndexCtrl.showConList) {
            Flex() {
              ConversationList({
                mConListCtrl: $mConListCtrl
              })
            }
            .width("100%")
            .height("100%")
          }
        }
      }
      .height('100%')
//      .margin({ left: this.gridMargin, right: this.gridMargin })
    }
    .padding({ left: this.gridMargin, right: this.gridMargin })
    .width("100%")
    .height("100%")
  }
}