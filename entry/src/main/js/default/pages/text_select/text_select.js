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
import mmsLog from '../../../default/utils/MmsLog.js';
import router from '@system.router';
// JS公共常量
import common from '../common_constants.js'
import {commonPasteboard} from '../../utils/Pasteboard.js';

// 选中状态的文字颜色
const COLOR_SELECT_BG = '#440023EB';
// 画布宽度
const EL_WIDTH = 620;
const IMG_CURSOR_WIDTH = 48;
// 状态值0
const MESSAGE_CODE_STATUS_ZERO = 0;
// 状态值0
const MESSAGE_CODE_STATUS_ONE = 1;
// 状态值2
const MESSAGE_CODE_STATUS_TWO = 2;

function MyCharacter(x, y, cw, idx, line, index, text) {
    // 左上角坐标,相对于画布的
    this.x = x;
    this.y = y;
    // 宽度/位置/第几行/第几个/内容/是否选中
    this.charWidth = cw;
    this.allIndex = idx;
    this.line = line;
    // 当前行第几个
    this.index = index;
    this.text = text;
}

// 定义对象
function MyPoint(x, y) {
    this.x = x;
    this.y = y
}

function LineChat(chats, idx, text) {
    this.chats = chats;
    // 第几行
    this.lineIndex = idx;
    this.text = text;
}

export default {
    data: {
        // 字体颜色
        fontFamily: 'sans-serif',
        // 字体大小
        fontSize: 42,
        // 42+13 行高=fontSize+行间距
        lineHeight: 55,
        // CanvasRenderingContext2D
        ctx: null,
        // 文本内容
        content: '',
        // 所有行的集合
        lineList: null,
        // 重点文本
        textPoint: null,
        // 选择文本的起点
        startPoint: null,
        // 选择文本的终点
        endPoint: null,
        // 水滴图片之前的位置
        beforeImg: null,
        // 下标图片
        curImg: null,
        // 起始字符
        startChat: null,
        // 上一个字符
        beforeChat: null,
        // 0 默认状态, 1移动状态 ,2 选中状态
        textSelectStatus: 0,
        // 全选
        isSelectAllStatus: true,
        // 拖拽图标宽度
        cursorWidth: IMG_CURSOR_WIDTH,
    },
    onInit() {
        mmsLog.info('txtSelect onInit');
        this.startPoint = new MyPoint(20, 20);
        this.endPoint = new MyPoint(40, 40);
        this.beforeImg = new MyPoint(0.0, 0.0);
        this.curImg = new MyPoint(0.0, 0.0);
        // 计算文本高度,用于内容居中显示
        let contentHeight = this.content.length * this.lineHeight / 30;
        this.textPoint = new MyPoint(0, 640 - contentHeight);
    },
    onShow() {
        mmsLog.info('txtSelect el handleClick:');
        this.ctx = this.$refs.canvas1.getContext('2d');
        // 文本字体
        this.ctx.font = this.fontSize + 'px ' + this.fontFamily;
        this.lineList = this.initLineList(this.content, this.ctx);
        this.ctx.fillStyle = COLOR_SELECT_BG;
        this.setSelectAll();
        mmsLog.info('txtSelect onShow end=====');
    },
    singleMsgBack() {
        router.back();
    },
    // measureText字符宽度,初始化lineList数组
    initLineList(content, ctx) {
        // 存储所有行的集合
        let lineList = new Array();
        // 每行的字符集合
        let chatList = new Array();
        let contentArray = Array.from(content);
        contentArray.push(' ');
        // 记录行号
        let lineIndex = 0;
        // 当前行宽度
        let curWidth = 0;
        // 当前行第几个
        let curIndex = 0;
        // 当前行内容
        let curText = common.string.EMPTY_STR;
        for (let index = 0; index < contentArray.length; index++) {
            let textWidth = ctx.measureText(contentArray[index]).width;
            if (curWidth + textWidth > EL_WIDTH) {
                curWidth = 0;
                curIndex = 0;
                // 创建行对象,存入所有行的集合
                lineList[lineIndex] = new LineChat(chatList, lineIndex, curText);
                lineIndex++;
                chatList = new Array();
                curText = '';
            }
            // 创建字符对象,存入每行的字符集合
            chatList[curIndex] = new MyCharacter(this.textPoint.x + curWidth, this.textPoint.y +
            lineIndex * this.lineHeight, textWidth, index, lineIndex, curIndex, contentArray[index]);
            curWidth += textWidth;
            if (index < contentArray.length) {
                curText += contentArray[index];
            }
            curIndex++;
        }
        lineList[lineIndex] = new LineChat(chatList, lineIndex, curText);
        return lineList;
    },
    getChatByPoint(point) {
        let curEl = null;
        let lineIndex = parseInt((point.y - this.textPoint.y) * 1.0 / this.lineHeight);
        mmsLog.info('txtSelect lineIndex:' + lineIndex);
        let chatArray = this.lineList[lineIndex].chats;
        mmsLog.info('txtSelect chatArray:' + chatArray);
        for (let index = 0; index < chatArray.length; index++) {
            curEl = chatArray[index];
            if (curEl.x + curEl.charWidth > point.x) {
                break;
            }
        }
        return curEl;
    },
    // 根据起始点字符,在画布上划出对应矩形
    showSelectArea(ctx, startChat, endChat) {
        mmsLog.info('txtSelect showSelectArea');
        ctx.fillStyle = COLOR_SELECT_BG;
        let delta = endChat.line - startChat.line;
        // 同一行
        if (delta === MESSAGE_CODE_STATUS_ZERO) {
            let width = endChat.x - startChat.x;
            ctx.fillRect(startChat.x, startChat.y, width, this.lineHeight);
            return;
        }
        // 多行
        ctx.fillRect(startChat.x, startChat.y, EL_WIDTH - startChat.x, this.lineHeight);
        ctx.fillRect(0, endChat.y, endChat.x + endChat.charWidth, this.lineHeight);
        if (delta > 1) {
            ctx.fillRect(0, startChat.y + this.lineHeight, EL_WIDTH, this.lineHeight * (delta - 1));
        }
        mmsLog.info('txtSelect showSelectArea');
    },
    // 清空文本区域 画布内容
    clearTextArea() {
        this.ctx.clearRect(this.textPoint.x, this.textPoint.y, EL_WIDTH, this.lineList.length * this.lineHeight);
    },
    // 判断是否全选
    isSelectAll(startChat, endChat) {
        return startChat.allIndex == 0 && endChat.allIndex == this.lineList.length - 1
    },
    setSelectAll() {
        this.startChat = this.lineList[0].chats[0];
        this.startPoint.x = this.startChat.x;
        this.startPoint.y = this.startChat.y;
        let chatList = this.lineList[this.lineList.length - 1].chats;
        this.beforeChat = chatList[chatList.length - 1];
        this.endPoint.x = this.beforeChat.x + this.beforeChat.charWidth;
        this.endPoint.y = this.beforeChat.y;
        this.textSelectStatus = MESSAGE_CODE_STATUS_TWO;
        this.isSelectAllStatus = true;
        this.showSelectArea(this.ctx, this.startChat, this.beforeChat);
    },
    // 单击画布响应
    canvasClick() {
        mmsLog.info('txtSelect canvasClick :');
        this.textSelectStatus = MESSAGE_CODE_STATUS_ZERO;
        this.clearTextArea();
    },
    canvasStart(e) {
        mmsLog.info('txtSelect canvasStart :');
        this.textSelectStatus = MESSAGE_CODE_STATUS_ZERO;
        this.startPoint.x = e.touches[0].localX;
        this.startPoint.y = e.touches[0].localY;
        mmsLog.info('txtSelect canvasStart rawX:' + this.startPoint.x + ' y:' + this.startPoint.y);
        this.startChat = this.getChatByPoint(this.startPoint);
        this.startPoint.x = this.startChat.x;
        this.startPoint.y = this.startChat.y;
        this.beforeChat = this.startChat;
    },
    canvasMove(e) {
        this.textSelectStatus = MESSAGE_CODE_STATUS_ONE;
        this.endPoint.x = e.touches[0].localX;
        this.endPoint.y = e.touches[0].localY;
        this.refreshEndSelect();
    },
    refreshEndSelect() {
        let curChat = this.getChatByPoint(this.endPoint);
        // 位置没变化
        if (this.beforeChat.allIndex == curChat.allIndex) {
            return;
        }
        // 最少选中一个字符
        if (curChat.allIndex <= this.startChat.allIndex) {
            return;
        }
        // 清空之前绘制内容
        this.clearTextArea();
        // 重新绘制
        this.showSelectArea(this.ctx, this.startChat, curChat);
        // 是否全选
        this.isSelectAllStatus = this.isSelectAll(this.startChat, curChat);
        this.beforeChat = curChat;
        this.endPoint.x = curChat.x;
        this.endPoint.y = curChat.y;
    },
    refreshStartSelect() {
        let curChat = this.getChatByPoint(this.startPoint);
        // 位置没变化
        if (this.startChat.allIndex == curChat.allIndex) {
            return;
        }
        // 最少选中一个字符
        if (curChat.allIndex >= this.beforeChat.allIndex) {
            return;
        }
        // 清空之前绘制内容
        this.clearTextArea();
        // 重新绘制
        this.showSelectArea(this.ctx, curChat, this.beforeChat);
        // 是否全选
        this.isSelectAllStatus = this.isSelectAll(curChat, this.beforeChat);
        this.startChat = curChat;
        this.startPoint.x = curChat.x;
        this.startPoint.y = curChat.y;
    },
    canvasEnd() {
        mmsLog.info('txtSelect canvasEnd :');
        if (this.textSelectStatus == MESSAGE_CODE_STATUS_ZERO) {
            return;
        }
        // 显示菜单
        this.textSelectStatus = MESSAGE_CODE_STATUS_TWO;
        mmsLog.info('txtSelect canvasEnd rawX:' + this.startPoint.x + ' y:' + this.startPoint.y);
        mmsLog.info('txtSelect canvasEnd rawX:' + this.endPoint.x + ' y:' + this.endPoint.y);
    },
    imgStart(isStart, e) {
        if (this.textSelectStatus != MESSAGE_CODE_STATUS_TWO) {
            return;
        }
        this.curImg.x = e.touches[0].localX;
        this.curImg.y = e.touches[0].localY;
        mmsLog.info('txtSelect imgMove  curImg:' + this.curImg.x);
        mmsLog.info('txtSelect imgMove  curImg:' + this.curImg.y);
    },
    imgMove(isStart, e) {
        if (this.textSelectStatus != MESSAGE_CODE_STATUS_TWO) {
            return;
        }
        this.beforeImg.x = this.curImg.x;
        this.beforeImg.y = this.curImg.y;
        this.curImg.x = e.touches[0].localX;
        this.curImg.y = e.touches[0].localY;
        let changeX = this.curImg.x - this.beforeImg.x;
        let changeY = this.curImg.y - this.beforeImg.y;
        if (isStart) {
            // 开始图标
            this.startPoint.x = this.startPoint.x + changeX;
            this.startPoint.y = this.startPoint.y + changeY;
            this.refreshStartSelect();
        } else {
            // 结束图标
            this.endPoint.x = this.endPoint.x + changeX;
            this.endPoint.y = this.endPoint.y + changeY;
            this.refreshEndSelect();
        }
    },
    pasteMenu(index) {
        mmsLog.info('txtSelect pasteMenu :' + index);
        switch (index) {
            case 0:
            // 复制
                this.txtCopy();
                break;
            case 1:
            // 全选
                this.clearTextArea();
                this.setSelectAll();
                break;
            case 2:
            // 分享
                this.txtShare();
                break;
            case 3:
            // 更多
                this.txtMore();
                break;
            default:
                mmsLog.info('pasteMenu, code is not exit');
        }
    },
    // 分享
    txtShare() {
        this.textSelectStatus = MESSAGE_CODE_STATUS_ZERO;
        this.isSelectAllStatus = MESSAGE_CODE_STATUS_ZERO;
        this.clearTextArea();
    },
    // 复制
    txtCopy() {
        this.textSelectStatus = MESSAGE_CODE_STATUS_ZERO;
        this.clearTextArea();
        mmsLog.info('txtCopy beforeChat.allIndex :' + this.beforeChat.allIndex);
        let strTxt = this.content.slice(this.startChat.allIndex, this.beforeChat.allIndex);
        commonPasteboard.setPasteboard(strTxt);
        router.back();
    },
    txtMore() {
        this.textSelectStatus = MESSAGE_CODE_STATUS_ZERO;
        this.$element('more_menu').show({
            x: EL_WIDTH / 2,
            y: this.startPoint.y - this.lineHeight * 4
        });
    },
    // 更多菜单
    moreMenu(e) {
        mmsLog.info('moreMenu, allIndex :' + e.value);
        switch(e.value) {
            case '0':
                this.searchText();
                this.textSelectStatus = MESSAGE_CODE_STATUS_ZERO;
                this.isSelectAllStatus = MESSAGE_CODE_STATUS_ZERO;
                this.clearTextArea();
                break;
            case '1':
                this.textSelectStatus = MESSAGE_CODE_STATUS_TWO;
                this.$element('more_menu').close();
                break;
            default:
                mmsLog.info('moreMenu index is not exiting');
        }
    },
    // 搜索输入框输入的文本内容，需要跳转至'浏览器'app
    searchText() {
        if (this.content == common.string.EMPTY_STR || this.content == null) {
            return;
        }
        let messageCode = common.route.MESSAGE_CODE_JUMP_TO_BROWSER_TO_SEARCH;
        let actionData = {};
        actionData.content = this.content;
        // 这里需要跳转值浏览器app
    }
}
