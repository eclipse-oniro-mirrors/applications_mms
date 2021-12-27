/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

export default {
    props: {
        texts: {
            default: 'wo sdf  sdf  86 sdfsfa'
        },
        searchText: {
            default: ''
        }
    },
    computed: {
        textSpans() {
            this.textSpans = []
            let arrays = [this.texts]
            let that = this
            arrays = this.splitText(arrays, this.searchText)
            let returnArray = []
            let i = 0
            arrays.forEach(element => {
                if (i > 4) {
                    return
                }
                if (element !== that.searchText) {
                    if (element.length > 9) {
                        element = element.slice(0, 6) + '...'
                    }
                }
                returnArray.push(element)
                i++
            });
            return returnArray
        }
    },
    splitText(arr, value) {
        let arrays = [];
        arr.forEach((item, index) => {
            item += '';
            let temp = item.split(value)
            temp.forEach((x, y, z) => {
                arrays.push(x)
                if (y < temp.length - 1) {
                    arrays.push(value)
                }
            })
        })
        return arrays;
    }
}
