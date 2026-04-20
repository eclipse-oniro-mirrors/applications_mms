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
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import HiLog from './HiLog';
import { BusinessError } from '@ohos.base';
import taskpool from '@ohos.taskpool';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import common from '../data/commonData';
import dataShare from '@ohos.data.dataShare';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import DataShareHelper from '../model/repository/DataShareHelper';
import { buffer } from '@kit.ArkTS';

const TAG: string = 'UserPhoto';

export const getPixelMapFromFile = (id: string, loadFromDB: boolean, callback?: Function, context?: Context) => {
  const contactsPhotoMap: Record<string, PixelMap> = AppStorage.get('contactsPhotoMap') || {};
  if (contactsPhotoMap[id]) {
    if (callback) {
      callback(contactsPhotoMap[id]);
    }
    // 更新数据库及缓存
    if (loadFromDB) {
      let task = new taskpool.Task(getPixelMapFromDB, id, context ? context : GlobalContext.getContext()
        .getObject('mmsContext'));
      taskpool.execute(task).then((pixelMap: Object) => {
        HiLog.i(TAG, `init pixelMap from db blod_data: ${pixelMap ? (pixelMap as PixelMap).getPixelBytesNumber() : -1}`);
        isSameImage(contactsPhotoMap, id, pixelMap as PixelMap, callback);
      });
    }

  } else {
    let task = new taskpool.Task(getPixelMapFromDB, id, context ? context : GlobalContext.getContext()
      .getObject('mmsContext'));
    taskpool.execute(task).then((pixelMap:Object) => {
      HiLog.i(TAG, `pixelMap from db blod_data: ${pixelMap ? (pixelMap as PixelMap).getPixelBytesNumber() : -1}`);
      contactsPhotoMap[id] = pixelMap as PixelMap;
      AppStorage.setOrCreate('contactsPhotoMap', contactsPhotoMap);
      if (loadFromDB) { // The image has not been loaded
        AppStorage.setOrCreate('contactPhotoChanged', id + '-' + new Date().getTime());
      }
      if (callback) {
        callback(pixelMap);
      }
    });
  }
}

async function isSameImage(contactsPhotoMap: Record<string, PixelMap>, index: string,
  pixelMap: PixelMap, callback?: Function) {
  if (pixelMap === null && callback) {
    contactsPhotoMap[index] = pixelMap;
    callback(pixelMap);
  }
  let imageBase64Cache: string = await getBase64ByImage(contactsPhotoMap[index]);
  let imageBase64Cur: string = await getBase64ByImage(pixelMap);

  if (imageBase64Cache !== imageBase64Cur && callback) {
    contactsPhotoMap[index] = pixelMap;
    callback(pixelMap);
  }
}

async function getBase64ByImage(pixelMap: PixelMap): Promise<string> {
  const imagePackerApi: image.ImagePacker = image.createImagePacker();
  let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
  let imageBase64: string = '';

  await imagePackerApi.packing(pixelMap as PixelMap, packOpts).then((data: ArrayBuffer) => {
    let buf: buffer.Buffer = buffer.from(data);
    imageBase64 = 'data:image/jpeg;base64,' + buf.toString('base64', 0, buf.length);
    imagePackerApi.release()
  });

  return imageBase64;
}

@Concurrent
export async function getPixelMapFromDB(contactId: string, context: Context): Promise<PixelMap | null> {
  try {
    HiLog.i('UserPhoto  ', `getPixelMapFromDB contactId: ${contactId}`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo('contact_id', contactId);
    conditionArgs.equalTo('type_id', 8);

    let dataShareHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataShareHelper) {
      HiLog.e('UserPhoto  ', '[getPixelMapFromDB] createDataShareHelper fail');
      return null;
    }
    let resultSet = await dataShareHelper.query(common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI, conditionArgs, ['blob_data']);
    if (resultSet.rowCount === 0) {
      resultSet.close();
      return null;
    }
    resultSet.goToFirstRow();
    let blobData = resultSet.getBlob(resultSet.getColumnIndex('blob_data'));
    resultSet.close();
    HiLog.i('UserPhoto  ', blobData.byteLength + '');
    let imageSource = image.createImageSource(blobData.buffer);
    if (imageSource !== undefined) {
      let pixelMap = await imageSource.createPixelMap({desiredSize: {height: 128, width: 128}});
      imageSource.release().catch((error: BusinessError) => {
        HiLog.e('UserPhoto  ', 'release imagesource error: ' + JSON.stringify(error.message));
      })
      return pixelMap;
    }
  } catch(error) {
    HiLog.e('UserPhoto  ', 'getPixelMapFromDB error: ' + JSON.stringify(error));
  }
  return null;
}