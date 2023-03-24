import AbilityStage from "@ohos.app.ability.UIAbility"
import notification from "@ohos.notificationManager";
import HiLog from "../utils/HiLog";

const TAG = "MyAbilityStage"

export default class MyAbilityStage extends AbilityStage {
    onCreate() {
        HiLog.i(TAG, "AbilityStage onCreate");
        globalThis.AbilityStageConstant = this.context;
        notification.setNotificationEnable({
            bundle: "com.ohos.mms"
        }, true, (err, data) => {
            if (err) {
                HiLog.i(TAG, "enableNotification err: " + JSON.stringify(err));
            }
        })
    }
}