import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, window } from '@kit.ArkUI';
import { openPermissionsInSystemSettings, requestPermission } from '../common/permission';
import { geoLocationManager } from '@kit.LocationKit'
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    }

    onDestroy(): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    }

    onWindowStageCreate(windowStage: window.WindowStage): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

        windowStage.loadContent('pages/Index', (err) => {
            if (err.code) {
                hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s',
                    JSON.stringify(err) ?? '');
                return;
            }
            hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
        });

        // 申请定位权限
        requestPermission([
            'ohos.permission.LOCATION'
        ], this.context)
            .then((res) => {
                // 权限未授予
                if (!res.granted) {
                    promptAction.showToast({
                        message: '未授予定位权限，无法获取当前天气信息！'
                    })
                    openPermissionsInSystemSettings(this.context, 'cn.li.luck_weather')
                } else {

                    try {

                    } catch (error) {

                    }
                }
            })
    }


    private async requestLocation() {
        let location: Optional<geoLocationManager.Location> = undefined
        try {
            location = geoLocationManager.getLastLocation()
            // 如果大于5min，则使用实时的
            if (new Date().getTime() - location.timeStamp >= 5 * 60 * 1000) {
                const nowLocation = await this.requestAccuracyLocation()
                if (nowLocation) {
                    location = nowLocation
                }
            }
        } catch (error) {
            const e = error as BusinessError
            console.error(`requestLocation failed and try to use accuracy location! ${e.code} ${e.message}! `)
            const nowLocation = await this.requestAccuracyLocation()
            if (nowLocation) {
                location = nowLocation
            }
        }
        return location
    }

    private async requestAccuracyLocation() {
        let request: geoLocationManager.SingleLocationRequest = {
            locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
            locatingTimeoutMs: 5000
        }
        try {
            return await geoLocationManager.getCurrentLocation(request)
        } catch (error) {
            const e = error as BusinessError
            console.error(`requestAccuracyLocaion failed! ${e.code} ${e.message}`)
        }
        return undefined
    }

    onWindowStageDestroy(): void {
        // Main window is destroyed, release UI related resources
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    }

    onForeground(): void {
        // Ability has brought to foreground
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    }

    onBackground(): void {
        // Ability has back to background
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
    }
}
