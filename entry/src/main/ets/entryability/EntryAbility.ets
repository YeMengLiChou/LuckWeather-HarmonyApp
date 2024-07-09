import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, window } from '@kit.ArkUI';
import { openPermissionsInSystemSettings, requirePermission } from '../common/permission';
import { requestLocation } from '../common/location';
import { createKvManager, getDeviceKVStore } from '../common/kvstore';
import { BUNDLE_NAME, STORE_ID_WEATHER } from '../common/config';
import distributedKVStore from '@ohos.data.distributedKVStore';
import { JSON } from '@kit.ArkTS';
import { fetchCityByLatitudeAndLongitude } from '../network/api';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { KEY_CURRENT_CITY_INFO } from '../common/constants';

export default class EntryAbility extends UIAbility {
    private weatherStore: Optional<distributedKVStore.DeviceKVStore>

    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    }

    onDestroy(): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    }

    async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

        windowStage.loadContent('pages/Index', (err) => {
            if (err.code) {
                hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s',
                    JSON.stringify(err) ?? '');
                return;
            }
            hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
        });

        // 检查定位权限是否申请
        requirePermission(
            ["ohos.permission.LOCATION", "ohos.permission.APPROXIMATELY_LOCATION"],
            this.context,
            () => {
                this.requestLocation()
            },
            () => {
                promptAction.showToast({
                    message: '未授予定位权限，无法获取当前天气信息！',
                    showMode: promptAction.ToastShowMode.TOP_MOST
                })
                openPermissionsInSystemSettings(this.context, 'cn.li.luck_weather')
            })
    }


    private requestLocation() {
        requestLocation()
            .then(res => {
                if (res) {
                    console.log('requested location info', JSON.stringify(res))
                    this.fetchCurrentCityInfo(res)
                }
            })
            .catch((err: BusinessError) => {
                console.error('requestLocation failed', err.message)
                promptAction.showToast({
                    message: '定位信息获取失败！'
                })
            })
    }

    /**
     * 根据所给的定位信息获取到当前城市的信息，并存储到 KvStore 中
     * */
    private fetchCurrentCityInfo(locationInfo: geoLocationManager.Location) {
        fetchCityByLatitudeAndLongitude(
            locationInfo.longitude,
            locationInfo.latitude
        )
            .then((res) => {
                getDeviceKVStore(createKvManager(this.context, BUNDLE_NAME), STORE_ID_WEATHER,
                    distributedKVStore.SecurityLevel.S3, {
                        encrypt: true,
                        createIfMissing: true,
                        backup: true,
                    })
                    .then(store => {
                        this.weatherStore = store
                        store.put(KEY_CURRENT_CITY_INFO, JSON.stringify(res.location[0]))
                    })
            })
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
