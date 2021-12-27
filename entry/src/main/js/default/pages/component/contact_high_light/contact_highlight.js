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

const NORMAL_TYPE = 0;
const BRIGHT_TYPE = 1;
export default {
    props: {
        texts: {
            default: 'wo sdf  sdf  86 sdfsfa'
        },
        search: {
            default: ''
        }
    },
    computed: {
        textSpans() {
            if (this.search.trim() === '') {
                let mapNormal = {}
                mapNormal.text = this.texts
                mapNormal.type = NORMAL_TYPE
                return [mapNormal]
            }
            this.textSpans = []
            let arrays = [this.texts]
            let pattern = ''
            if (this.search.length > 1) {
                for (let i = 0; i < this.search.length; i++) {
                    pattern += this.search.charAt(i)
                    if (i < this.search.length - 1) {
                        pattern += '(\\s)*'
                    }
                }
            }
            let result = [this.search]
            if (pattern != '') {
                try {
                    let rule = new RegExp(pattern, 'g')
                    result = rule.exec(this.texts)
                } catch (e) {
                    this.hitLog('error:' + JSON.stringify(e))
                }
            }
            if (!result) {
                let mapNormal = {}
                mapNormal.text = this.texts
                mapNormal.type = NORMAL_TYPE
                return [mapNormal]
            }
            let that = this
            arrays = this.splitText(arrays, result[0])
            let returnArray = []
            let i = 0
            arrays.forEach(element => {
                let text = element.text
                if (text !== '') {
                    returnArray.push(element)
                    i++
                }
            });
            return returnArray
        }
    },
    splitText(arr, val) {
        let finalArrays = []
        arr.forEach((value, index) => {
            value += ''
            let temp = value.split(val)
            temp.forEach((x, y, z) => {
                let mapNormal = {}
                mapNormal.text = x
                mapNormal.type = NORMAL_TYPE
                finalArrays.push(mapNormal)
                if (y < temp.length - 1) {
                    let mapHigh = {}
                    mapHigh.text = val
                    mapHigh.type = BRIGHT_TYPE
                    finalArrays.push(mapHigh)
                }
            })
        })
        return finalArrays
    }
}