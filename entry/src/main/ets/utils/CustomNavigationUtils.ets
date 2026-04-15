/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

const customTransitionMap: Map<number, AnimateCallback> = new Map()

// 自定义接口，用来保存某个页面相关的转场动画回调和参数
export interface AnimateCallback {
  finish: ((isPush: boolean, isExit: boolean) => void | undefined) | undefined;
  start: ((isPush: boolean, isExit: boolean) => void | undefined) | undefined;
  onFinish: ((isPush: boolean, isExit: boolean) => void | undefined) | undefined;
  timeout: (number | undefined) | undefined;
}

export class CustomNavigationUtils {
  private constructor() {

  }

  private static delegate = new CustomNavigationUtils();

  static getInstance() {
    return CustomNavigationUtils.delegate;
  }

  // 注册某个页面的动画回调
  // startCallback：用来设置动画开始时页面的状态
  // endCallback：用来设置动画结束时页面的状态
  // onFinish：用来执行动画结束后页面的其他操作
  // timeout：转场结束的超时时间
  registerNavParam(name: number, startCallback: (operation: boolean, isExit: boolean) => void,
    endCallback:(operation: boolean, isExit: boolean) => void,
    onFinish: (opeation: boolean, isExit: boolean) => void, timeout: number): void {

    if (customTransitionMap.has(name)) {
      let param = customTransitionMap.get(name);
      if (param != undefined) {
        param.start = startCallback;
        param.finish = endCallback;
        param.timeout = timeout;
        param.onFinish = onFinish;
        return;
      }
    }
    let params: AnimateCallback = {timeout: timeout, start: startCallback, finish: endCallback, onFinish: onFinish};
    customTransitionMap.set(name, params);
  }

  unRegisterNavParam(name: number): void {
    customTransitionMap.delete(name);
  }

  getAnimateParam(name: number): AnimateCallback {
    let result: AnimateCallback = {
      start: customTransitionMap.get(name)?.start,
      finish: customTransitionMap.get(name)?.finish,
      timeout: customTransitionMap.get(name)?.timeout,
      onFinish: customTransitionMap.get(name)?.onFinish
    };
    return result;
  }
}