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
        var hyperLinkList = document.querySelectorAll("a[href]");
        for (var i = 0; i < hyperLinkList.length; i++) {
            if (hyperLinkList[i].getAttribute('href').search("^#") === -1) {
                var toRemove = hyperLinkList[i];
                var parent = toRemove.parentNode;
                var text = document.createElement("span");
                text.innerHTML += toRemove.innerHTML;
                text.innerHTML += " (";
                text.innerHTML += toRemove.getAttribute('href');
                text.innerHTML += ") ";
                parent.insertBefore(text, toRemove);
                parent.removeChild(toRemove);
                parent.normalize();
            }
        }
    }
}


function agreementV3() {
    var paramsInfo = null;
    var host = null;
    var tileExtLinkPara = null;
    var tileExtLink = false;
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
        var imgs = document.getElementsByTagName('img');
        if (paramsInfo && paramsInfo.imgAlt) {
            for (var i = 0; i < imgs.length; i++) {
                if (imgs[i].getAttribute("alt") == '') {
                    imgs[i].alt = paramsInfo.imgAlt;
                } else {
                    imgs[i].alt = paramsInfo.imgAlt;
                }
            }
        }
    }
    flattingUrlToText(tileExtLink);
    if (document.getElementsByTagName('a')) {
        var aList = document.getElementsByTagName('a');
        var contenttagList = ['di', '3rdsdk', '3rdshare'];

        function isTransfer(url) {
            var par = url.slice(0, url.indexOf('.htm')).split('/');
            var agrname = par[par.length - 1];
            var servicename = par[par.length - 2];
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
            var reg = /country/;
            if (reg.test(url)) {
                url = url.replace('country', 'code');
            }
            var params = url.split('?')[1].split('&');
            var result = true;
            var extendObj = {};
            var codeArray = url.match(new RegExp('[?&]code=([^&]*)(&|$)'));
            var branchidArray = url.match(new RegExp('[?&]branchid=([^&]*)(&|$)'));
            var versionArray = url.match(new RegExp('[?&]version=([^&]*)(&|$)'));
            var subVersionArray = url.match(new RegExp('[?&]subVersion=([^&]*)(&|$)'));
            var languageArray = url.match(new RegExp('[?&]language=([^&]*)(&|$)'));
            var contenttagArray = url.match(new RegExp('[?&]contenttag=([^&]*)(&|$)'));
            var ctypeArray = url.match(new RegExp('[?&]ctype=([^&]*)(&|$)'));
            var bgmodeArray = url.match(new RegExp('[?&]bgmode=([^&]*)(&|$)'));
            var tileExtLinkArray = url.match(new RegExp("[?&]tileExtLink=([^=&]*)(&|$)"));
            var pInfo = {
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
            for (var i = 0; i < params.length; i++) {
                var item = params[i].split('=');
                if (pInfo[item[0]] != '') {
                    extendObj[item[0]] = item[1];
                }
            }
            if (languageArray && languageArray[1]) {
                for (var i = 0; i < languageArray.length; i++) {
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
                for (var i in extendObj) {
                    checkextendParam(extendObj[i]);
                }
            }

            function checkCode(param) {
                var re = new RegExp('^[a-zA-Z]{1,16}$');
                if (result) {
                    result = re.test(param);
                    code = param.toLowerCase();
                }
            }

            function checkBranchid(param) {
                var re = new RegExp('^[0-9]{1,10}$');
                if (result) {
                    result = re.test(param);
                    branchid = param;
                }
            }

            function checkVersion(param) {
                var re = new RegExp('^[0-9]{1,9}$');
                if (result) {
                    result = re.test(param);
                    version = param;
                }
            }

            function checkSubVersion(param) {
                var re = new RegExp('^[0-9]{1,8}$');
                if (result) {
                    result = re.test(param);
                    subVersion = param;
                }
            }

            function checkContenttag(param) {
                var re = new RegExp('^[a-zA-Z0-9]{1,32}$');
                if (result) {
                    result = re.test(param);
                }
            }

            function checkLanguage(param) {
                var re = new RegExp('^[a-z](?=.*[a-z])(?=.*-)[a-z-]{1,15}$');
                if (result) {
                    result = re.test(param);
                }
            }

            function checkCtype(param) {
                var re = new RegExp('^[a-zA-Z0-9]{1,32}$');
                if (result) {
                    result = re.test(param);
                }
            }

            function checkBgmode(param) {
                var re = new RegExp('^[a-zA-Z0-9]{1,32}$');
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
                var re = new RegExp('^[a-zA-Z0-9_-]{1,32}$');
                if (result) {
                    result = re.test(param);
                }
            }

            return result;
        }

        function replaceUrl(url) {
            var versionArray = url.match(new RegExp('[?&]version=([^&]*)(&|$)'));
            var subVersionArray = url.match(new RegExp('[?&]subVersion=([^&]*)(&|$)'));
            var languageArray = url.match(new RegExp('[?&]language=([^&]*)(&|$)'));
            if (paramsInfo && paramsInfo.version) {
                if (versionArray) {
                    if (versionArray[1]) {
                        url = url.replace("version=" + versionArray[1], "version=" + paramsInfo.version);
                    } else {
                        url = url.replace("version=", "version=" + paramsInfo.version);
                    }
                } else {
                    url = url + '&version=' + paramsInfo.version;
                }
            }
            if (paramsInfo && paramsInfo.subVersion) {
                if (subVersionArray) {
                    if (subVersionArray[1]) {
                        url = url.replace("subVersion=" + subVersionArray[1], "subVersion=" + paramsInfo.subVersion);
                    } else {
                        url = url.replace("subVersion=", "subVersion=" + paramsInfo.subVersion);
                    }
                } else {
                    url = url + '&subVersion=' + paramsInfo.subVersion;
                }
            }
            if (paramsInfo && paramsInfo.language) {
                if (languageArray) {
                    if (languageArray[1]) {
                        url = url.replace("language=" + languageArray[1], "language=" + paramsInfo.language);
                    } else {
                        url = url.replace("language=", "language=" + paramsInfo.language);
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

        for (var n = 0; n < aList.length; n++) {
            var contenttagAry = aList[n].href.match(new RegExp('[?&]contenttag=([^&]*)(&|$)'));
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
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split("=");
        if (pair[0] == variable) {
            return pair[1];
        }
    }
    return null;
}

function dp2px(dp) {
    var scale = 1;
    return dp * scale;
}

function getGridColumn(screenWidth) {
    var fourEndPoint = dp2px(520);
    var eightEndPoint = dp2px(840);
    var column = 0;
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
    var arr = desc.split("+");
    var w = 0;
    var cn = parseInt(arr[0].replace("C", ""));
    w = cn * columnWidth + (cn - 1) * gutter;
    if (arr.length > 1) {
        var gn = parseInt(arr[1].replace("Gutter", ""));
        w += gn * gutter;
    }
    return w;
}

function dealWithWindowResize() {
    var CONTENT_TYPE_GRID = {
        4: {
            margin: 24,
            gutter: 24,
            widthDesc: "4C"
        },
        8: {
            margin: 24,
            gutter: 24,
            widthDesc: "6C"
        },
        12: {
            margin: 24,
            gutter: 24,
            widthDesc: "8C"
        }
    };
    var BUTTON_TYPE_GRID = {
        4: {
            margin: 24,
            gutter: 24,
            widthDesc: "2C+2Gutter"
        },
        8: {
            margin: 24,
            gutter: 24,
            widthDesc: "3C"
        },
        12: {
            margin: 24,
            gutter: 24,
            widthDesc: "4C"
        }
    };
    var screenWidth = document.body.clientWidth;
    var column = getGridColumn(screenWidth);
    var contentGrid = CONTENT_TYPE_GRID[column];
    var gridColumnWidth = getGridColumnWidth(contentGrid.margin, contentGrid.gutter, column, screenWidth);
    var contentWidth = parseWidthDesc(contentGrid.widthDesc, gridColumnWidth, contentGrid.gutter);
    setContainerMargin(contentWidth, screenWidth);

    var buttonGrid = BUTTON_TYPE_GRID[column];
    var gridColumnWidth2 = getGridColumnWidth(buttonGrid.margin, buttonGrid.gutter, column, screenWidth);
    var buttonWidth = parseWidthDesc(buttonGrid.widthDesc, gridColumnWidth2, buttonGrid.gutter);
    setButtonWidth(buttonWidth);
}

function setButtonWidth(buttonWidth) {
    var moreBtn = document.getElementById("moreBtn");
    if (moreBtn) {
        moreBtn.style.width = buttonWidth + 'px';
    }

    var stopBtn = document.getElementById("stopBtn");
    if (stopBtn) {
        stopBtn.style.width = buttonWidth + 'px';
    }

}

function setContainerMargin(contentWidth, screenWidth) {
    var margin = Math.round((screenWidth - contentWidth) / 2);
    var container = document.getElementById('container');
    if (container) {
        container.style.marginTop = container.style.marginBottom = 0 + 'px';
        container.style.marginRight = container.style.marginLeft = margin + 'px';
    }
}

function appendThemeClass(clsName, key) {
    var nodes = document.getElementsByClassName(clsName);
    if (nodes && nodes.length !== 0) {
        [].forEach.call(nodes, function (element) {
            element.className += ' ' + clsName + '-' + key;
        });
    }
}

function initThemeClass(backgroundMode) {
    var clsNames = ["title", "caption", "firstTitle", "secondTitle", "thirdTitleMain", "thirdTitleSub",
        "firstContent", "secondContent", "thirdContent", "contentText", "list"];
    var key = "light-text";
    var linkClass = " link link-light-text";
    var bgClass = " light_bg_color";
    var logoClass = "logo_light";
    var moreBtnClass = " textBtnLight";
    var stopBtnClass = " normalBtnLight";
    var tdClass = " light";
    if (backgroundMode === 'black') {
        key = "dark-text";
        linkClass = " link link-dark-text";
        bgClass = " dark_bg_color";
        logoClass = "logo_dark";
        moreBtnClass = " textBtnDark";
        stopBtnClass = " normalBtnDark";
        tdClass = " dark";
    } else if (backgroundMode === 'gray') {
        bgClass = " light_sub_bg_color";
    }
    clsNames.forEach(function (clsName) {
        appendThemeClass(clsName, key);
    });
    var aNodes = document.getElementsByTagName('a');
    if (aNodes && aNodes.length != 0) {
        [].forEach.call(aNodes, function (element) {
            element.className += linkClass;
        });
    }
    var tdNodes = document.getElementsByTagName('td');
    if (tdNodes && tdNodes.length != 0) {
        [].forEach.call(tdNodes, function (element) {
            element.className += tdClass;
        });
    }
    document.getElementsByTagName('body')[0].className += bgClass;
    document.getElementsByTagName('html')[0].className += bgClass;

    var nodes = document.getElementsByClassName("fixedBottom");
    if (nodes && nodes.length !== 0) {
        [].forEach.call(nodes, function (element) {
            element.className += bgClass;
        });
    }

    var logo = document.getElementById("default_logo");
    if (logo) {
        logo.classList.add(logoClass);
    }

    var moreBtn = document.getElementById("moreBtn");
    if (moreBtn) {
        moreBtn.className += moreBtnClass;
    }

    var stopBtn = document.getElementById("stopBtn");
    if (stopBtn) {
        stopBtn.className += stopBtnClass;
    }
}

function getBackgroundMode() {
    var backgroundMode = "${defaultTheme}";
    var bgModeQS = getQueryVariable("bgmode") || getQueryVariable("themeName");
    if (bgModeQS) {
        switch (bgModeQS) {
            case "light":
                backgroundMode = "white";
                break;
            case "white":
                backgroundMode = "white";
                break;
            case "dark":
                backgroundMode = "black";
                break;
            case "black":
                backgroundMode = "black";
                break;
            case "gray":
                backgroundMode = "gray";
                break;
            default:
                backgroundMode = "black";
                break;
        }
    }
    if (backgroundMode.startsWith("$")) {
        backgroundMode = "white";
    }
    if (window.agrattr && window.agrattr.getBackgroundMode) {
        backgroundMode = window.agrattr.getBackgroundMode();
    }
    return backgroundMode;
}

function isSupportHarmonyFont() {
    var targets = ['span.X1', 'span.X2', 'span.X21', 'span.X31', 'span.X41', 'span.X6', 'span.Heading4NoNumber',
        'span.a7', 'span.X10', 'span.ab', 'span.af2', 'span.af3', ' span.X19', 'span.X2d', 'span.X3c', 'span.X73',
        'span.affc', 'span.X1b', 'span.Cover2', 'span.Cover4', 'span.commandkeywords', 'span.Char', 'span.X3Char'];
    var font = new FontFace('MyFont', 'local(黑体 medium)');
    font.load().then(function (loadedFont) {
        document.fonts.add(loadedFont);
        console.log('黑体 medium is available');
        dealWithHarmonyFont(targets);
    }).catch(function (error) {
        console.log('黑体 medium is not available');
        var detection = document.getElementById("font-detection");
        var f = window.getComputedStyle(detection).getPropertyValue("font-family");
        console.log("default font-family:" + f);
        if (f === 'sans-serif') {
            dealWithHarmonyFont(targets);
        } else {
            dealWithNoHarmonyFont(targets);
        }
    });
    var regularFont = new FontFace("regularFont", 'local(黑体)');
    regularFont.load().then(function (loadedFont) {
        document.fonts.add(loadedFont);
        console.log('regular is available');
    }).catch(function (error) {
        console.log('regular is not available');
    });
}

function dealWithHarmonyFont(targets) {
    console.log("dealWithHarmonyFont");
    targets.forEach(function (target) {
        var ns = document.querySelectorAll(target);
        [].forEach.call(ns, function (element) {
            element.classList.add('medium');
        });
    });
}

function dealWithNoHarmonyFont(targets) {
    console.log("dealWithNoHarmonyFont");
    var nodes = document.getElementsByClassName("medium");
    [].forEach.call(nodes, function (element) {
        element.style.fontWeight = 'bold';
    });

    targets.forEach(function (target) {
        var ns = document.querySelectorAll(target);
        [].forEach.call(ns, function (element) {
            element.style.fontWeight = 'bold';
        });
    });
}

function setBlackBg() {
    var bg = getQueryVariable("bg");
    if (bg === 'true') {
        var body = document.getElementsByTagName('body')[0];
        body.style.backgroundColor = '#000000';
    }
}

function setTransparent() {
    var transparent = getQueryVariable("trsp");
    var transparentColor = '#00000000';
    if (transparent === 'true') {
        var body = document.getElementsByTagName('body')[0];
        body.style.backgroundColor = transparentColor;
        body.style.backgroundImage = "none";
        document.getElementsByTagName('html')[0].style.backgroundColor = transparentColor;
        var nodes = document.getElementsByClassName("fixedBottom");
        if (nodes && nodes.length !== 0) {
            [].forEach.call(nodes, function (element) {
                element.style.backgroundColor = transparentColor;
            });
        }
    }
}

function isGridLayout() {
    var len = document.styleSheets.length;
    if (len && document.styleSheets[1] && document.styleSheets[1].cssRules && document.styleSheets[1].cssRules.length) {
        var arr = [...document.styleSheets[1].cssRules];
        var enableGridLayout = arr.some(function (e) {
            return e.selectorText === '.gridLayout';
        });
        if (enableGridLayout) {
            for (var i = 0; i < arr.length; i++) {
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
    var backgroundMode = getBackgroundMode();
    initThemeClass(backgroundMode);
    setBlackBg();
    setTransparent();
    var moreBtn = document.getElementById('moreBtn');
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
            var paramsInfoJson = JSON.parse(window.localStorage.getItem('paramsInfo'));
            if (paramsInfoJson.anchorTo) {
                window.location.hash = paramsInfoJson.anchorTo;
            }
        }
    }
    var anchorTo = getQueryVariable("anchorTo");
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
var scrollStyle = '<style>.active::-webkit-scrollbar{display: none;}</style>';
window.addEventListener('message', function (e) {
    if (e.data === 'loaded') {
        loadFn();
    }
    if (e.data.operType === "modifyCss" || e.data.operType === "resize") {
        var div = document.createElement("div");
        var body = document.getElementsByTagName('html')[0];
        var container = document.getElementsByClassName('container')[0];
        var darkBgColor = document.getElementsByClassName('dark_bg_color');
        var lightBgColor = document.getElementsByClassName('light_bg_color');

        if (e.data.chooseType === "phone") {
            if (body) {
                body.style.fontSize = '16px';
            }
            if (container) {
                container.style.margin = '0 0.6rem';
            }
        }
        if (e.data.chooseType === "folderScreen") {
            if (body) {
                body.style.fontSize = '16px';
            }
            if (container) {
                container.style.margin = '0 3.8rem';
            }
        }
        if (e.data.chooseType === "pc") {
            if (body) {
                body.style.fontSize = '16px';
            }
        }
        if (e.data.chooseType === "car") {
            if (lightBgColor.length !== 0) {
                Object.values(lightBgColor).forEach(function (item) {
                    item.style.backgroundColor = '#E8EAEE';
                })
            }
        }
        if (darkBgColor.length !== 0 && e.data.chooseType !== "car") {
            Object.values(darkBgColor).forEach(function (item) {
                item.style.backgroundColor = 'rgb(25,25,25)';
            })
        }
        body.className = 'active';
        div.innerHTML = scrollStyle;
        body.appendChild(div);
    }
});