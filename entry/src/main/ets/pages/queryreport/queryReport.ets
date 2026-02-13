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
import QueryReportController from './queryReportController';
import WantUtil from '../../utils/WantUtil';
import { EditableLeftIconType, EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import LooseObject from '../../data/LooseObject';
import myCommon from '@ohos.app.ability.common';
import { i18n } from '@kit.LocalizationKit';

@Builder
export function queryReportLoader(param: LooseObject): void {
    queryReport();
}

/*
 * 1 when user send message to group
 * 2 long press message item
 * 3 press more
 * 4 read send report
 * */
@Component
export struct queryReport {
    private context = getContext(this) as myCommon.UIAbilityContext;
    @Consume('pageInfos') pageInfos: NavPathStack
    @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding = {};
    @StorageLink('QueryReportController') queryReportController: QueryReportController = QueryReportController.getInstance();

    destinationShow(): void {
        this.queryReportController.onShow();
        WantUtil.getWant(this.context, this.pageInfos);
    }

    destinationAppear(): void {
        this.queryReportController.onInit(this.pageInfos);
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                EditableTitleBar({
                    leftIconStyle: EditableLeftIconType.Back,
                    title: $r('app.string.send_reports'),
                    onCancel: () => {
                        this.pageInfos.pop();
                    },
                    isSaveIconRequired: false
                })

                Column() {
                    Row() {
                        Text($r('app.string.putAddresser'))
                            .fontSize(16)
                            .height('auto')
                            .fontWeight(FontWeight.Medium)
                            .lineHeight(22)
                        Text(this.queryReportController.telephone)
                            .fontSize(16)
                            .height('auto')
                            .fontWeight(FontWeight.Medium)
                            .lineHeight(22)
                            .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
                            .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Ltr : Direction.Auto)
                    }

                    Text() {
                        Span($r('app.string.message_status', this.queryReportController.sendStatusDesc)).fontSize(16)
                    }
                    .fontSize(16)
                    .constraintSize({ minHeight: 48 })
                    .fontWeight(FontWeight.Medium)
                    .lineHeight(22)

                    if (!this.queryReportController.isMsm && this.queryReportController.sendStatus != 2) {
                        Text($r('app.string.Delivered', this.queryReportController.mmsTime,
                          this.queryReportController.specificTime))
                        .fontSize(16)
                        .constraintSize({ minHeight: 48 })
                        .fontWeight(FontWeight.Medium)
                        .lineHeight(22)
                    }
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 12, right: 12 })

            }.width('100%').height('100%')
            .margin({ top: this.fullScreenPadding ? (this.fullScreenPadding.top as number) : 0,
                left: 24, right: 24 })
        }
        .onShown(() => {
            this.destinationShow();
        })
        .onAppear(() => {
            this.destinationAppear();
        })
        .hideTitleBar(true)
    }
}