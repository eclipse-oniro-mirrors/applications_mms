REM /**
REM  * Copyright (c) 2025 Huawei Device Co., Ltd.
REM  * Licensed under the Apache License, Version 2.0 (the "License");
REM  * you may not use this file except in compliance with the License.
REM  * You may obtain a copy of the License at
REM  *
REM  *     http://www.apache.org/licenses/LICENSE-2.0
REM  *
REM  * Unless required by applicable law or agreed to in writing, software
REM  * distributed under the License is distributed on an "AS IS" BASIS,
REM  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM  * See the License for the specific language governing permissions and
REM  * limitations under the License.
REM  */

set HOME=%~dp0
hdc shell mount -o remount,rw /

hdc shell rm system/app/com.ohos.mms/Mms.hap
hdc file send %HOME%entry\build\default\outputs\default\entry-default-signed.hap /system/app/com.ohos.mms/Mms.hap

hdc shell rm -rf /data/*
hdc shell chown root:root system/app/com.ohos.mms/Mms.hap
hdc shell setenforce 0
hdc shell sync
hdc shell sync /system/bin/udevadm trigger
hdc shell reboot
