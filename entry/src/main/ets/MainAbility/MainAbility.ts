import Ability from '@ohos.app.ability.UIAbility'
import Window from '@ohos.window'

import HiLog from "../utils/HiLog";
import MmsPreferences from "../utils/MmsPreferences";
import MmsDatabaseHelper from "../utils/MmsDatabaseHelper";
import WantUtil from "../utils/WantUtil";
import simCardService from "../service/SimCardService";

const TAG = "app";

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        HiLog.i(TAG, "Ability onCreate com.ohos.mms version: 1.0.0.40");
        globalThis.mmsContext = this.context;
        globalThis.abilityWant = want;
        globalThis.MmsDatabaseHelper = new MmsDatabaseHelper();
        globalThis.MmsDatabaseHelper.createTable();
        globalThis.needToUpdate = true;
        MmsPreferences.getInstance().initPreferences();
    }

    onNewWant(want, launchParam) {
        HiLog.i(TAG, 'Application onNewWant');
        globalThis.abilityWant = want;
    }

    onWindowStageCreate(windowStage: Window.WindowStage) {
        // Main window is created, set main page for this ability
        windowStage.loadContent('pages/index', (err, data) => {
            if (err.code) {
                HiLog.e(TAG, 'testTag', 'Failed to load the content.');
                return;
            }
            HiLog.i(TAG, 'testTag', 'Succeeded in loading the content. Data: %{public}s');
        });
    }

    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        HiLog.i(TAG, 'Ability onWindowStageDestroy');
    }

    onForeground() {
        // Ability has brought to foreground
        HiLog.i(TAG, 'Ability onForeground');
        simCardService.init();
    }

    onBackground() {
        // Ability has back to background
        HiLog.i(TAG, 'Ability onBackground');
        simCardService.deInit();
    }

}
