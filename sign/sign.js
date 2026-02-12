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

const fs = require('fs-extra');
const path = require('path');
const execa = require('execa');
const childProcess = require('child_process');

const projectRootPath = process.cwd();
const userName = process.env.ONLINE_USERNAME;
const password = process.env.ONLINE_PASSWD;
const onlineSignServer = '';
const hapSignTool = 'hap-sign-tool.jar';
const hapSignOnlinePlugin = 'hapsign-online-plugin.jar';
const p7bFileName = 'mms.p7b';
const keyAlias = 'Mms';

const signMaterialPath = path.resolve(projectRootPath, 'sign');
const signToolFile = path.resolve(signMaterialPath, hapSignTool);
const SIGNTOOL_PATH = process.env.SIGNTOOL_PATH;

fs.exists(signToolFile, function(exists) {
  if (!exists) {
    childProcess.execFile('local.bat', null, {cwd: signMaterialPath}, function(error, stdout, stderr) {
      if (error !== null) {
        console.log('exec error' + error);
      } else {
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
      }
    });
  }
});

// 调用签名工具执行签名的具体逻辑,需要根据各自需求和场景自行实现
// Tips: 在IDE场景下,在线签名工具生成的签名后的hap必须默认仍然放置到/build/default/outputs/default/目录下,且包名以signed.hap为后缀
function executeOnlineSign(inputFile, outputFile) {
  const signToolFile = path.resolve(signMaterialPath, hapSignTool);
  const p7bFile = path.resolve(signMaterialPath, p7bFileName);
  const hapSignOnlinePlugin = path.resolve(SIGNTOOL_PATH, 'hapsign-online-plugin.jar');

  const command = [
    '-jar',
    signToolFile,
    'sign-app',
    '-mode',
    'remoteSign',
    '-signServer',
    onlineSignServer,
    '-signerPlugin',
    hapSignOnlinePlugin,
    '-onlineAuthMode',
    'account',
    '-username',
    userName,
    '-userPwd',
    password,
    '-profileFile',
    p7bFile,
    '-compatibleVersion',
    '8',
    '-signAlg',
    'SHA256withECDSA',
    '-keyAlias',
    keyAlias,
    '-inFile',
    inputFile,
    '-outFile',
    outputFile
  ];

  execa.sync('java', command);
}

module.exports = {
  executeOnlineSign: executeOnlineSign
};
