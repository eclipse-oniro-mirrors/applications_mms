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
@Component
export struct SearchResultPage {
    build() {
        List() {
            ListItem() { //Number of Searched Sessions
                Text("找到2个会话").fontSize(10).fontColor(Color.Black).margin({ left: 24, top: 24 })

            }

            ListItem() { //Searched session item
                SearchItem()
            }

            ListItem() { //Searched session item
                SearchItem()
            }

            ListItem() { //Number of Searched Information
                Text("找到2条信息").fontSize(10).fontColor(Color.Black).margin({ left: 24, top: 24 })
            }

            ListItem() { //Information item
                SearchItem()
            }

            ListItem() { //Information item
                SearchItem()
            }
        }

    }
}

@Component
struct SearchItem {
    build() {
        Column() {
            Row() {
                Image($rawfile("icon/user_avatar_full_fill.svg"))
                    .height(40)
                    .width(40)
                Column() {
                    Row() {
                        Text("电话").fontSize(16).fontColor(Color.Black)
                        Blank()
                        Text("时间").fontSize(12).fontColor(Color.Gray)
                    }.width("100%")

                    Row() {
                        Text("内容").fontSize(14).fontColor(Color.Gray)

                    }.width("100%")
                }.layoutWeight(1).margin({ left: 12 })
            }.height(64).width("100%").padding({ left: 24, right: 24 })
        }
    }
}