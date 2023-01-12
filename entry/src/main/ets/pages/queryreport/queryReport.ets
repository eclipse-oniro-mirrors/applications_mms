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
import DeviceUtil from "../../utils/DeviceUtil";
import router from "@system.router";
import QueryReportController from "./queryReportController";
import WantUtil from "../../utils/WantUtil";

@Entry
@Component
struct queryReport {
    @StorageLink("QueryReportController") queryReportController: QueryReportController = QueryReportController.getInstance();
    private gridColumns: GridRowColumnOption = { sm: 4, md: 8, lg: 12 };
    private girdSpan: GridColColumnOption = { sm: 4, md: 8, lg: 12 };
    private gridGutter: string = "24vp";
    private gridMargin: string = "24vp";

    onPageShow(): void  {
        this.queryReportController.onShow();
        WantUtil.getWant();
    }

    aboutToAppear(): void {
        this.queryReportController.onInit()
    }

    build() {
        GridRow({ columns: this.gridColumns, gutter: this.gridGutter }) {
            GridCol({ span: this.girdSpan }) {
                Row() {
                    Image($rawfile('icon/ic_message_back.svg'))
                        .width(24)
                        .height(24)
                        .onClick(() => {
                            router.back()
                        })
                    Text($r("app.string.send_reports"))
                        .margin({ left: 16 })
                        .fontSize(20)
                        .fontWeight(FontWeight.Bold)
                        .lineHeight(28)
                }
                .alignItems(VerticalAlign.Center)
                .height(56)
            }
            GridCol({ span: this.girdSpan }) {
                Column() {
                    Text() {
                        Span($r("app.string.putAddresser")).fontSize(16)
                        Span(this.queryReportController.telephone).fontSize(16)
                    }
                    .fontSize(16)
                    .height(48)
                    .fontWeight(FontWeight.Medium)
                    .lineHeight(22)

                    Text() {
                        Span($r("app.string.Status")).fontSize(16)
                        Span(this.queryReportController.sendStatusDesc).fontSize(16)
                    }
                    .fontSize(16)
                    .height(48)
                    .fontWeight(FontWeight.Medium)
                    .lineHeight(22)

                    if (!this.queryReportController.isMsm && this.queryReportController.sendStatus != 2) {
                        Text() {
                            Span($r("app.string.Delivered")).fontSize(16)
                            Span(this.queryReportController.mmsTime).fontSize(16)
                            Span(" ")
                            Span(this.queryReportController.specificTime).fontSize(16)
                        }
                        .fontSize(16)
                        .height(48)
                        .fontWeight(FontWeight.Medium)
                        .lineHeight(22)
                    }
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 12, right: 12 })
            }
        }
        .width("100%")
        .height("100%")
        .margin({ left: this.gridMargin, right: this.gridMargin })
    }
}