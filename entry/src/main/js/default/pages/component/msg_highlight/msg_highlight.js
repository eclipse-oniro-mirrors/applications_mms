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

const URL_REG = /(((ht|f)tps?):\/\/)?(www\.)?[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.[a-zA-Z0-9\&\.\/\?\:@\-_=#]+)?/g;
const EMAIL_REG = /[\d\w]+\b@[a-zA-ZA-z0-9]+(\.[com,cn,net]{1,3})+/g;
const TEL_REG = /((\+?86[\s]?)?(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\s?\d{4}\s?\d{4})|(0[\d]{2,3}[-]?[\d]{7,8}|400[-]?[\d]{3}[-]?[\d]{4})|(?<![0-9]+)100(86|10|00|01|85)(?![0-9]+)/g;
const DATE_REG = /(?<![0-9]+)(?:(?:(?:[0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})([-\/.]?)(?:(?:(?:0?[13578]|1[02])\1(?:0?[1-9]|[12][0-9]|3[01]))|(?:(?:0?[469]|11)\1(?:0?[1-9]|[12][0-9]|30))|(?:02\1(?:0[1-9]|[1][0-9]|2[0-8]))))|(?:(?:(?:[0-9]{2})(?:0[48]|[2468][048]|[13579][26])|(?:(?:0[48]|[2468][048]|[3579][26])00))([-\/.]?)02\2(?:29)))\s+((((上午)|(中午)|(下午)|(晚上))?[01]?[0-9]|2[0-3])(:|：)[0-5]?[0-9]((:|：)[0-5]?[0-9])?)|((\d{4}年)?\d{1,2}月\d{1,2}日\s+(((上午)|(中午)|(下午)|(晚上))?[01]?[0-9]|2[0-3])(:|：)[0-5]?[0-9]((:|：)[0-5]?[0-9])?)/g;
const DATE_NO_TIME_REG = /(?<![0-9]+)(?:(?:(?:[0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})([-\/.])(?:(?:(?:0?[13578]|1[02])\1(?:0?[1-9]|[12][0-9]|3[01]))|(?:(?:0?[469]|11)\1(?:0?[1-9]|[12][0-9]|30))|(?:02\1(?:0[1-9]|[1][0-9]|2[0-8]))))|(?:(?:(?:[0-9]{2})(?:0[48]|[2468][048]|[13579][26])|(?:(?:0[48]|[2468][048]|[3579][26])00))([-\/.])02\2(?:29)))(?![0-9]+)|((\d{4}年)?\d{1,2}月\d{1,2}日)/g;
const DATE_CH_REG = /((\d{4}年)?(\d{1,2}月)?\d{1,2}日)?\s?(((上午)|(中午)|(下午)|(晚上))?[01]?[0-9]|2[0-4])(时|点半?)([0-5]?[0-9]分)?([0-5]?[0-9]秒)?/g;
const DATE_EN_REG = /(?:(((Jan(uary)?|Ma(r(ch)?|y)|Jul(y)?|Aug(ust)?|Oct(ober)?|Dec(ember)?)\ 31)|((Jan(uary)?|Ma(r(ch)?|y)|Apr(il)?|Ju((ly?)|(ne?))|Aug(ust)?|Oct(ober)?|(Sept|Nov|Dec)(ember)?)\ (0?[1-9]|([12]\d)|30))|(Feb(ruary)?\ (0?[1-9]|1\d|2[0-8]|(29(?=,\ ((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)))))))\,\ ((1[6-9]|[2-9]\d)\d{2}))/g;
const TIME_REG = /(([1-9]|1[0-2]|0[1-9]){1}(:[0-5][0-9][aApP][mM]){1})|((((上午)|(下午)|(晚上))?[01]?[0-9]|2[0-3])(:|：)[0-5]?[0-9]((:|：)[0-5]?[0-9])?)/g;
const NUM_REG = /(验证码：)\b(\d{4}|\d{6})\b/g;

import common from '../../common_constants.js';

export default {
    props: ['text','keyword'],
    data() {
        return {
        }
    },
    computed: {
        highlights() {
            let msg = [];
            if (!this.text || this.text.trim() === '') {
                let nullObj = {
                    value: ' ',
                    type: common.HIGHLIGHT_TYPE.NORMAL
                };
                msg.push(nullObj);
            } else {
                msg = this.getHighlights();
            }
            return msg;
        }
    },
    createObj(item, type, position) {
        let obj = {};
        obj.value = item;
        obj.type = type;
        obj.start = this.text.indexOf(item, position);
        obj.hasBold = false;
        obj.extra = [];
        return obj;
    },
    sortMsg(messages) {
        return messages.sort((a, b) => {
            return a.start - b.start;
        });
    },
    getItemPositions(value, item, start) {
        let positions = [];
        let index = value.indexOf(item);
        while(index !== -1) {
            positions.push(index + start);
            index = value.indexOf(item, index + item.length);
        }
        return positions;
    },
    getHighlights() {
        // 根据正则表达式，从数据源中筛选出对应的数据，并生成对象。筛选顺序：网址，邮件，电话，日期，验证码
        let messages = [];
        let regs = [
            EMAIL_REG, URL_REG, TEL_REG, DATE_REG, DATE_CH_REG,
            DATE_EN_REG, DATE_NO_TIME_REG, TIME_REG, NUM_REG
        ];
        let lastStr = this.text;
        regs.forEach((reg, index) => {
            let matchArr = lastStr.match(reg);
            if (matchArr) {
                this.dealMatchArr(matchArr, index, regs, messages);
                // 获取去除特殊数据后的字串
                lastStr = lastStr.replace(reg, common.string.EMPTY_STR);
            }
        });
        let texts = [];
        if (messages.length === 0) {
            texts = [
                {
                    value: this.text,
                    type: 0,
                    start: 0,
                    hasBold: false,
                    extra: []
                }
            ];
        } else {
            messages = this.sortMsg(messages);
            texts = this.addNormals(messages);
        }
        return this.getTextOverstriking(texts, this.keyword);
    },
    getTextOverstriking(texts, keyword) {
        if (keyword === null || keyword === common.string.EMPTY_STR) {
            return texts;
        }
        let newTexts = [];
        for (let text of texts) {
            if (text.type === 0) {
                this.dealText(text, newTexts, keyword);
            } else {
                let resultTexts = [];
                this.dealText(text, resultTexts, keyword);
                text.extra = resultTexts;
                newTexts.push(text);
            }
        }
        return newTexts;
    },
    formatValue(value, keyword) {
        if (value === common.string.EMPTY_STR || keyword === common.string.EMPTY_STR) {
            return value;
        }
        let index = value.indexOf(keyword);
        if (index === -1) {
            return value;
        }
        let hasOneDeal = true;
        let valueStr = common.string.EMPTY_STR;
        for (let i = 0; i < value.length; i++) {
            if (i >= index && i < index + keyword.length) {
                if (hasOneDeal) {
                    valueStr = valueStr + common.string.SEMICOLON;
                    hasOneDeal = false;
                }
            } else {
                valueStr = valueStr + value[i];
            }
        }
        return this.formatValue(valueStr, keyword);
    },
    dealText(text, newTexts, keyword) {
        let oldValue = text.value;
        let newValue = this.formatValue(oldValue, keyword);
        for (let value of newValue) {
            if (value === common.string.SEMICOLON) {
                newTexts.push(this.getText(text, true, keyword));
            } else {
                newTexts.push(this.getText(text, false, value));
            }
        }
    },
    getText(text, hasBold, value) {
        let newText = {
            value: value,
            type: text.type,
            start: text.start,
            hasBold: hasBold,
            extra: []
        };
        return newText;
    },
    putText(text, hasBold, value, newTexts) {
        newTexts.push(this.getText(text, hasBold, value));
    },
    dealMatchArr(matchArr, index, regs, messages) {
        matchArr.forEach((item, matchIdx) => {
            let type = common.HIGHLIGHT_TYPE.NORMAL;
            if (index >= 3 && index <= regs.length - 2) {
                type = common.HIGHLIGHT_TYPE.DATE;
            } else if (index === regs.length - 1) {
                type = common.HIGHLIGHT_TYPE.NUM;
                item = item.substring(4);
            } else {
                type = index + 1;
            }
            let position = this.dealHighlight(type, messages, matchIdx, item);
            let obj = this.createObj(item, type, position);
            messages.push(obj);
        });
    },
    dealHighlight(type, messages, matchIdx, item) {
        let position = 0;
        // 由于url中有可能包含有电话号码如10086，所以做特殊处理
        if (type === common.HIGHLIGHT_TYPE.TEL && messages.length !== 0) {
            let telPositions = [];
            // 查找已匹配信息中是否包含电话号码，记录位置
            messages.forEach((msg) => {
                telPositions = telPositions.concat(this.getItemPositions(msg.value, item, msg.start));
            });
            if (telPositions.length === 0) {
                if (matchIdx !== 0) {
                    let pre = messages[messages.length - 1];
                    position = pre.start + pre.value.length;
                }
            } else {
                // 获取item在字符串中的所有位置
                let positions = this.getItemPositions(this.text, item, 0);
                // 去除在已匹配信息中包含item的位置
                this.dealTelPositions(telPositions, positions);
                position = positions[0];
            }
        } else if (matchIdx !== 0) {
            let pre = messages[messages.length - 1];
            position = pre.start + pre.value.length;
        }
        return position;
    },
    dealTelPositions(telPositions, positions) {
        telPositions.forEach((tel) => {
            let telIdx = positions.indexOf(tel);
            if (telIdx >= 0) {
                positions.splice(telIdx, 1);
            }
        });
    },
    addNormals(messages) {
        // 获取除特殊数据外的所有普通数据，并生成对象
        let copyMsg = JSON.parse(JSON.stringify(messages));
        messages.forEach((msg, index) => {
            let start = msg.start;
            let subStr = '';
            let obj = {};
            if (index === 0) {
                subStr = this.text.substring(0, start);
                obj = this.createObj(subStr, common.HIGHLIGHT_TYPE.NORMAL);
            } else {
                let preItem = messages[index - 1];
                let idx = preItem.start + preItem.value.length;
                subStr = this.text.substring(idx, start);
                obj = this.createObj(subStr, common.HIGHLIGHT_TYPE.NORMAL, idx);
            }
            copyMsg.push(obj);
            if (index === messages.length - 1) {
                subStr = this.text.substring(start + msg.value.length);
                obj = this.createObj(subStr, common.HIGHLIGHT_TYPE.NORMAL);
                copyMsg.push(obj);
            }
        });
        return this.sortMsg(copyMsg);
    },
    clickTextAction(type, value) {
        if (type === common.HIGHLIGHT_TYPE.NUM) {
            return;
        }
        this.$emit('clickHighlights', {
            type: type,
            value: value
        });
    }
}