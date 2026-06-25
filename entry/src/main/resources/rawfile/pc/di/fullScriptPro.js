/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

window.focus();

function flattingUrlToText(tileExtLink) {
    if (tileExtLink) {
        let hyperLinkList = document.querySelectorAll('a[href]');
        for (var i = 0; i < hyperLinkList.length; i++) {
            if (hyperLinkList[i].getAttribute('href').search('^#') === -1) {
                let toRemove = hyperLinkList[i];
                let parent = toRemove.parentNode;
                let text = document.createElement('span');
                text.innerHTML += toRemove.innerHTML;
                text.innerHTML += ' (';
                text.innerHTML += toRemove.getAttribute('href');
                text.innerHTML += ') ';
                parent.insertBefore(text, toRemove);
                parent.removeChild(toRemove);
                parent.normalize();
            }
        }
    }
}


function agreementV3() {
    let paramsInfo = null;
    let host = null;
    let tileExtLinkPara = null;
    let tileExtLink = false;
    if (window.localStorage && window.localStorage.getItem) {
        if (window.localStorage.getItem('paramsInfo')) {
            paramsInfo = JSON.parse(window.localStorage.getItem('paramsInfo'));
            if (paramsInfo && paramsInfo.tileExtLink) {
                tileExtLinkPara = paramsInfo.tileExtLink;
            }
        }
        if (window.localStorage.getItem('host')) {
            host = window.localStorage.getItem('host');
        }
    }
    if (window.agrattr && window.agrattr.tileExtLink) {
        if (window.agrattr.tileExtLink() === true || window.agrattr.tileExtLink() === false) {
            tileExtLink = window.agrattr.tileExtLink();
        } else {
            tileExtLink = false;
        }
    } else if (tileExtLinkPara) {
        if (paramsInfo && paramsInfo.tileExtLink) {
            tileExtLink = JSON.parse(paramsInfo.tileExtLink);
        }
    }

    if (document.getElementsByTagName('img')) {
        let imgs = document.getElementsByTagName('img');
        if (paramsInfo && paramsInfo.imgAlt) {
            for (var i = 0; i < imgs.length; i++) {
                if (imgs[i].getAttribute('alt') == '') {
                    imgs[i].alt = paramsInfo.imgAlt;
                } else {
                    imgs[i].alt = paramsInfo.imgAlt;
                }
            }
        }
    }
    flattingUrlToText(tileExtLink);
    if (document.getElementsByTagName('a')) {
        let aList = document.getElementsByTagName('a');
        let contenttagList = ['di', '3rdsdk', '3rdshare'];

        function isTransfer(url) {
            let par = url.slice(0, url.indexOf('.htm')).split('/');
            let agrname = par[par.length - 1];
            let servicename = par[par.length - 2];
            if (paramsInfo && paramsInfo.agrname && paramsInfo.serviceName) {
                if (agrname === paramsInfo.agrname && servicename === paramsInfo.serviceName) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        function isParamsValid(url) {
            let reg = /country/;
            if (reg.test(url)) {
                url = url.replace('country', 'code');
            }
            let params = url.split('?')[1].split('&');
            let result = true;
            let extendObj = {};
            let codeArray = url.match(new RegExp('[?&]code=([^&]*)(&|$)'));
            let branchidArray = url.match(new RegExp('[?&]branchid=([^&]*)(&|$)'));
            let versionArray = url.match(new RegExp('[?&]version=([^&]*)(&|$)'));
            let subVersionArray = url.match(new RegExp('[?&]subVersion=([^&]*)(&|$)'));
            let languageArray = url.match(new RegExp('[?&]language=([^&]*)(&|$)'));
            let contenttagArray = url.match(new RegExp('[?&]contenttag=([^&]*)(&|$)'));
            let ctypeArray = url.match(new RegExp('[?&]ctype=([^&]*)(&|$)'));
            let bgmodeArray = url.match(new RegExp('[?&]bgmode=([^&]*)(&|$)'));
            let tileExtLinkArray = url.match(new RegExp('[?&]tileExtLink=([^=&]*)(&|$)'));
            let pInfo = {
                tenantName: '',
                serviceName: '',
                agrname: '',
                code: '',
                branchid: '',
                version: '',
                subVersion: '',
                contenttag: '',
                language: '',
                ctype: '',
                bgmode: '',
                imgAlt: '',
                tileExtLink: ''
            };
            for (let i = 0; i < params.length; i++) {
                var item = params[i].split('=');
                if (pInfo[item[0]] != '') {
                    extendObj[item[0]] = item[1];
                }
            }
            if (languageArray && languageArray[1]) {
                for (let i = 0; i < languageArray.length; i++) {
                    languageArray[i] = fn(languageArray[i]);
                }
            }
            if (tileExtLinkArray && tileExtLinkArray[1]) {
                if (tileExtLinkArray[1] === 'true') {
                    tileExtLink = 'true';
                } else if (tileExtLinkArray[1] === 'false') {
                    tileExtLink = 'false';
                }
            } else {
                tileExtLink = 'false';
            }

            function fn(x) {
                x = x.toLowerCase();
                x = x.replace(/_/g, '-');
                return x;
            }

            if (codeArray && codeArray[1]) {
                checkCode(codeArray[1]);
            }
            if (branchidArray && branchidArray[1]) {
                checkBranchid(branchidArray[1]);
            }
            if (versionArray && versionArray[1]) {
                checkVersion(versionArray[1]);
            }
            if (subVersionArray && subVersionArray[1]) {
                checkSubVersion(subVersionArray[1]);
            }
            if (contenttagArray && contenttagArray[1]) {
                checkContenttag(contenttagArray[1]);
            }
            if (languageArray && languageArray[1]) {
                checkLanguage(languageArray[1]);
            }
            if (ctypeArray && ctypeArray[1]) {
                checkCtype(ctypeArray[1]);
            }
            if (bgmodeArray && bgmodeArray[1]) {
                checkBgmode(bgmodeArray[1]);
            }
            if (tileExtLinkArray && tileExtLinkArray[1]) {
                checktileExtLink(tileExtLinkArray);
            }
            if (extendObj) {
                for (let i in extendObj) {
                    checkextendParam(extendObj[i]);
                }
            }

            function checkCode(param) {
                let re = new RegExp('^[a-zA-Z]{1,16}$');
                if (result) {
                    result = re.test(param);
                    code = param.toLowerCase();
                }
            }

            function checkBranchid(param) {
                let re = new RegExp('^[0-9]{1,10}$');
                if (result) {
                    result = re.test(param);
                    branchid = param;
                }
            }

            function checkVersion(param) {
                let re = new RegExp('^[0-9]{1,9}$');
                if (result) {
                    result = re.test(param);
                    version = param;
                }
            }

            function checkSubVersion(param) {
                let re = new RegExp('^[0-9]{1,8}$');
                if (result) {
                    result = re.test(param);
                    subVersion = param;
                }
            }

            function checkContenttag(param) {
                let re = new RegExp('^[a-zA-Z0-9]{1,32}$');
                if (result) {
                    result = re.test(param);
                }
            }

            function checkLanguage(param) {
                let re = new RegExp('^[a-z](?=.*[a-z])(?=.*-)[a-z-]{1,15}$');
                if (result) {
                    result = re.test(param);
                }
            }

            function checkCtype(param) {
                let re = new RegExp('^[a-zA-Z0-9]{1,32}$');
                if (result) {
                    result = re.test(param);
                }
            }

            function checkBgmode(param) {
                let re = new RegExp('^[a-zA-Z0-9]{1,32}$');
                if (result) {
                    result = re.test(param);
                }
            }

            function checktileExtLink(param) {
                if (param && param[1]) {
                    if (result) {
                        if (param[1] === 'true' || param[1] === 'false') {
                            result = true;
                        } else {
                            result = false;
                        }
                    }
                }
            }

            function checkextendParam(param) {
                let re = new RegExp('^[a-zA-Z0-9_-]{1,32}$');
                if (result) {
                    result = re.test(param);
                }
            }

            return result;
        }

        function replaceUrl(url) {
            let versionArray = url.match(new RegExp('[?&]version=([^&]*)(&|$)'));
            let subVersionArray = url.match(new RegExp('[?&]subVersion=([^&]*)(&|$)'));
            let languageArray = url.match(new RegExp('[?&]language=([^&]*)(&|$)'));
            if (paramsInfo && paramsInfo.version) {
                if (versionArray) {
                    if (versionArray[1]) {
                        url = url.replace('version=' + versionArray[1], 'version=' + paramsInfo.version);
                    } else {
                        url = url.replace('version=', 'version=' + paramsInfo.version);
                    }
                } else {
                    url = url + '&version=' + paramsInfo.version;
                }
            }
            if (paramsInfo && paramsInfo.subVersion) {
                if (subVersionArray) {
                    if (subVersionArray[1]) {
                        url = url.replace('subVersion=' + subVersionArray[1], 'subVersion=' + paramsInfo.subVersion);
                    } else {
                        url = url.replace('subVersion=', 'subVersion=' + paramsInfo.subVersion);
                    }
                } else {
                    url = url + '&subVersion=' + paramsInfo.subVersion;
                }
            }
            if (paramsInfo && paramsInfo.language) {
                if (languageArray) {
                    if (languageArray[1]) {
                        url = url.replace('language=' + languageArray[1], 'language=' + paramsInfo.language);
                    } else {
                        url = url.replace('language=', 'language=' + paramsInfo.language);
                    }
                } else {
                    url = url + '&language=' + paramsInfo.language;
                }
            }
            if (host) {
                url = url.replace(/^https:\/\/[^/]+\//, host + '/');
            }
            return url;
        }

        for (let n = 0; n < aList.length; n++) {
            let contenttagAry = aList[n].href.match(new RegExp('[?&]contenttag=([^&]*)(&|$)'));
            if (contenttagAry && contenttagAry[1]) {
                if (contenttagList.indexOf(contenttagAry[1]) != -1) {
                    if (aList[n].getAttribute('class').indexOf('privacylist-nottransfer') == -1) {
                        if (isTransfer(aList[n].href) && isParamsValid(aList[n].href) && aList[n].href.indexOf('minisite') == -1) {
                            aList[n].setAttribute("href", replaceUrl(aList[n].href));
                        }
                    }
                }
            }
        }
    }
}

agreementV3();

function getQueryVariable(variable) {
    let query = window.location.search.substring(1);
    let vars = query.split('&');
    for (let i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');
        if (pair[0] == variable) {
            return pair[1];
        }
    }
    return null;
}

function dp2px(dp) {
    let scale = 1;
    return dp * scale;
}

function getGridColumn(screenWidth) {
    let fourEndPoint = dp2px(520);
    let eightEndPoint = dp2px(840);
    let column = 0;
    if (screenWidth < fourEndPoint) {
        column = 4;
    } else if (screenWidth < eightEndPoint) {
        column = 8;
    } else {
        column = 12;
    }
    return column;
}

function getGridColumnWidth(margin, gutter, column, screenWidth) {
    return (screenWidth - 2 * margin + gutter) / column - gutter;
}

function parseWidthDesc(desc, columnWidth, gutter) {
    let arr = desc.split('+');
    let w = 0;
    let cn = parseInt(arr[0].replace('C', ''));
    w = cn * columnWidth + (cn - 1) * gutter;
    if (arr.length > 1) {
        let gn = parseInt(arr[1].replace('Gutter', ''));
        w += gn * gutter;
    }
    return w;
}

function dealWithWindowResize() {
    let CONTENT_TYPE_GRID = {
        4: {
            margin: 24,
            gutter: 24,
            widthDesc: '4C'
        },
        8: {
            margin: 24,
            gutter: 24,
            widthDesc: '6C'
        },
        12: {
            margin: 24,
            gutter: 24,
            widthDesc: '8C'
        }
    };
    let BUTTON_TYPE_GRID = {
        4: {
            margin: 24,
            gutter: 24,
            widthDesc: '2C+2Gutter'
        },
        8: {
            margin: 24,
            gutter: 24,
            widthDesc: '3C'
        },
        12: {
            margin: 24,
            gutter: 24,
            widthDesc: '4C'
        }
    };
    let screenWidth = document.body.clientWidth;
    let column = getGridColumn(screenWidth);
    let contentGrid = CONTENT_TYPE_GRID[column];
    let gridColumnWidth = getGridColumnWidth(contentGrid.margin, contentGrid.gutter, column, screenWidth);
    let contentWidth = parseWidthDesc(contentGrid.widthDesc, gridColumnWidth, contentGrid.gutter);
    setContainerMargin(contentWidth, screenWidth);

    let buttonGrid = BUTTON_TYPE_GRID[column];
    let gridColumnWidth2 = getGridColumnWidth(buttonGrid.margin, buttonGrid.gutter, column, screenWidth);
    let buttonWidth = parseWidthDesc(buttonGrid.widthDesc, gridColumnWidth2, buttonGrid.gutter);
    setButtonWidth(buttonWidth);
}

function setButtonWidth(buttonWidth) {
    let moreBtn = document.getElementById('moreBtn');
    if (moreBtn) {
        moreBtn.style.width = buttonWidth + 'px';
    }

    let stopBtn = document.getElementById('stopBtn');
    if (stopBtn) {
        stopBtn.style.width = buttonWidth + 'px';
    }

}

function setContainerMargin(contentWidth, screenWidth) {
    let margin = Math.round((screenWidth - contentWidth) / 2);
    let container = document.getElementById('container');
    if (container) {
        container.style.marginTop = container.style.marginBottom = 0 + 'px';
        container.style.marginRight = container.style.marginLeft = margin + 'px';
    }
}

function appendThemeClass(clsName, key) {
    let nodes = document.getElementsByClassName(clsName);
    if (nodes && nodes.length !== 0) {
        [].forEach.call(nodes, function (element) {
            element.className += ' ' + clsName + '-' + key;
        });
    }
}

function initThemeClass(backgroundMode) {
    let clsNames = ['title', 'caption', 'firstTitle', 'secondTitle', 'thirdTitleMain', 'thirdTitleSub',
        'firstContent', 'secondContent', 'thirdContent', 'contentText', 'list'];
    let key = 'light-text';
    let linkClass = ' link link-light-text';
    let bgClass = ' light_bg_color';
    let logoClass = 'logo_light';
    let moreBtnClass = ' textBtnLight';
    let stopBtnClass = ' normalBtnLight';
    let tdClass = ' light';
    if (backgroundMode === 'black') {
        key = 'dark-text';
        linkClass = ' link link-dark-text';
        bgClass = ' dark_bg_color';
        logoClass = 'logo_dark';
        moreBtnClass = ' textBtnDark';
        stopBtnClass = ' normalBtnDark';
        tdClass = ' dark';
    } else if (backgroundMode === 'gray') {
        bgClass = ' light_sub_bg_color';
    }
    clsNames.forEach(function (clsName) {
        appendThemeClass(clsName, key);
    });
    let aNodes = document.getElementsByTagName('a');
    if (aNodes && aNodes.length != 0) {
        [].forEach.call(aNodes, function (element) {
            element.className += linkClass;
        });
    }
    let tdNodes = document.getElementsByTagName('td');
    if (tdNodes && tdNodes.length != 0) {
        [].forEach.call(tdNodes, function (element) {
            element.className += tdClass;
        });
    }
    document.getElementsByTagName('body')[0].className += bgClass;
    document.getElementsByTagName('html')[0].className += bgClass;

    let nodes = document.getElementsByClassName('fixedBottom');
    if (nodes && nodes.length !== 0) {
        [].forEach.call(nodes, function (element) {
            element.className += bgClass;
        });
    }

    let logo = document.getElementById('default_logo');
    if (logo) {
        logo.classList.add(logoClass);
    }

    let moreBtn = document.getElementById('moreBtn');
    if (moreBtn) {
        moreBtn.className += moreBtnClass;
    }

    let stopBtn = document.getElementById('stopBtn');
    if (stopBtn) {
        stopBtn.className += stopBtnClass;
    }
}

function getBackgroundMode() {
    let backgroundMode = '${defaultTheme}';
    let bgModeQS = getQueryVariable('bgmode') || getQueryVariable('themeName');
    if (bgModeQS) {
        switch (bgModeQS) {
            case 'light':
                backgroundMode = 'white';
                break;
            case 'white':
                backgroundMode = 'white';
                break;
            case 'dark':
                backgroundMode = 'black';
                break;
            case 'black':
                backgroundMode = 'black';
                break;
            case 'gray':
                backgroundMode = 'gray';
                break;
            default:
                backgroundMode = 'black';
                break;
        }
    }
    if (backgroundMode.startsWith('$')) {
        backgroundMode = 'white';
    }
    if (window.agrattr && window.agrattr.getBackgroundMode) {
        backgroundMode = window.agrattr.getBackgroundMode();
    }
    return backgroundMode;
}

function isSupportHarmonyFont() {
    let targets = ['span.X1', 'span.X2', 'span.X21', 'span.X31', 'span.X41', 'span.X6', 'span.Heading4NoNumber',
        'span.a7', 'span.X10', 'span.ab', 'span.af2', 'span.af3', ' span.X19', 'span.X2d', 'span.X3c', 'span.X73',
        'span.affc', 'span.X1b', 'span.Cover2', 'span.Cover4', 'span.commandkeywords', 'span.Char', 'span.X3Char'];
    let font = new FontFace('MyFont', 'local(黑体 medium)');
    font.load().then(function (loadedFont) {
        document.fonts.add(loadedFont);
        console.log('黑体 medium is available');
        dealWithHarmonyFont(targets);
    }).catch(function (error) {
        console.log('黑体 medium is not available');
        let detection = document.getElementById('font-detection');
        let f = window.getComputedStyle(detection).getPropertyValue('font-family');
        console.log('default font-family:' + f);
        if (f === 'sans-serif') {
            dealWithHarmonyFont(targets);
        } else {
            dealWithNoHarmonyFont(targets);
        }
    });
    let regularFont = new FontFace('regularFont', 'local(黑体)');
    regularFont.load().then(function (loadedFont) {
        document.fonts.add(loadedFont);
        console.log('regular is available');
    }).catch(function (error) {
        console.log('regular is not available');
    });
}

function dealWithHarmonyFont(targets) {
    console.log('dealWithHarmonyFont');
    targets.forEach(function (target) {
        let ns = document.querySelectorAll(target);
        [].forEach.call(ns, function (element) {
            element.classList.add('medium');
        });
    });
}

function dealWithNoHarmonyFont(targets) {
    console.log('dealWithNoHarmonyFont');
    let nodes = document.getElementsByClassName('medium');
    [].forEach.call(nodes, function (element) {
        element.style.fontWeight = 'bold';
    });

    targets.forEach(function (target) {
        let ns = document.querySelectorAll(target);
        [].forEach.call(ns, function (element) {
            element.style.fontWeight = 'bold';
        });
    });
}

function setBlackBg() {
    let bg = getQueryVariable('bg');
    if (bg === 'true') {
        let body = document.getElementsByTagName('body')[0];
        body.style.backgroundColor = '#000000';
    }
}

function setTransparent() {
    let transparent = getQueryVariable('trsp');
    let transparentColor = '#00000000';
    if (transparent === 'true') {
        let body = document.getElementsByTagName('body')[0];
        body.style.backgroundColor = transparentColor;
        body.style.backgroundImage = 'none';
        document.getElementsByTagName('html')[0].style.backgroundColor = transparentColor;
        let nodes = document.getElementsByClassName('fixedBottom');
        if (nodes && nodes.length !== 0) {
            [].forEach.call(nodes, function (element) {
                element.style.backgroundColor = transparentColor;
            });
        }
    }
}

function isGridLayout() {
    let len = document.styleSheets.length;
    if (len && document.styleSheets[1] && document.styleSheets[1].cssRules && document.styleSheets[1].cssRules.length) {
        let arr = [...document.styleSheets[1].cssRules];
        let enableGridLayout = arr.some(function (e) {
            return e.selectorText === '.gridLayout';
        });
        if (enableGridLayout) {
            for (let i = 0; i < arr.length; i++) {
                if (arr[i].selectorText === '.gridLayout') {
                    if (arr[i].style && arr[i].style.display) {
                        if (arr[i].style.display === 'grid') {
                            dealWithWindowResize();
                        }
                    }
                }
            }
        } else {
            dealWithWindowResize();
        }

    }
}

function loadFn() {
    isGridLayout();
    document.body.style.opacity = 1;
    let backgroundMode = getBackgroundMode();
    initThemeClass(backgroundMode);
    setBlackBg();
    setTransparent();
    let moreBtn = document.getElementById('moreBtn');
    if (moreBtn) {
        if (window.checkMore) {
            if (window.checkMore.needDisplay && window.checkMore.needDisplay()) {
                moreBtn.style.cssText = 'display:block;';
                moreBtn.style.marginTop = '0.52rem';
                moreBtn.style.marginBottom = '1.2rem';
            } else {
                moreBtn.style.cssText = 'display:none;';
            }
        }
        moreBtn.onclick = function () {
            if (window.checkMore && window.checkMore.agreementCheckMore) {
                window.checkMore.agreementCheckMore();
            }
        };
    }
    if (window.localStorage && window.localStorage.getItem) {
        if (window.localStorage.getItem('paramsInfo')) {
            let paramsInfoJson = JSON.parse(window.localStorage.getItem('paramsInfo'));
            if (paramsInfoJson.anchorTo) {
                window.location.hash = paramsInfoJson.anchorTo;
            }
        }
    }
    let anchorTo = getQueryVariable('anchorTo');
    if (anchorTo) {
        window.location.hash = anchorTo;
    }
    isSupportHarmonyFont();
}

window.onresize = function () {
    isGridLayout();
};

document.body.style.opacity = 0;
window.onload = function () {
    loadFn();
};
let scrollStyle = '<style>.active::-webkit-scrollbar{display: none;}</style>';
window.addEventListener('message', function (e) {
    if (e.data === 'loaded') {
        loadFn();
    }
    if (e.data.operType === 'modifyCss' || e.data.operType === 'resize') {
        let div = document.createElement('div');
        let body = document.getElementsByTagName('html')[0];
        let container = document.getElementsByClassName('container')[0];
        let darkBgColor = document.getElementsByClassName('dark_bg_color');
        let lightBgColor = document.getElementsByClassName('light_bg_color');

        if (e.data.chooseType === 'phone') {
            if (body) {
                body.style.fontSize = '16px';
            }
            if (container) {
                container.style.margin = '0 0.6rem';
            }
        }
        if (e.data.chooseType === 'folderScreen') {
            if (body) {
                body.style.fontSize = '16px';
            }
            if (container) {
                container.style.margin = '0 3.8rem';
            }
        }
        if (e.data.chooseType === 'pc') {
            if (body) {
                body.style.fontSize = '16px';
            }
        }
        if (e.data.chooseType === 'car') {
            if (lightBgColor.length !== 0) {
                Object.values(lightBgColor).forEach(function (item) {
                    item.style.backgroundColor = '#E8EAEE';
                })
            }
        }
        if (darkBgColor.length !== 0 && e.data.chooseType !== 'car') {
            Object.values(darkBgColor).forEach(function (item) {
                item.style.backgroundColor = 'rgb(25,25,25)';
            })
        }
        body.className = 'active';
        div.innerHTML = scrollStyle;
        body.appendChild(div);
    }
});