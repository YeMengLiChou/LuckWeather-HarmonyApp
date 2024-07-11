import { createKvManager, getDeviceKVStore } from '../common/kvstore'
import { Context } from '@kit.AbilityKit'
import { BUNDLE_NAME, STORE_ID_WEATHER } from '../common/config'
import { distributedKVStore } from '@kit.ArkData'
import {
    getForecastWeatherDayDataKey,
    getForecastWeatherHourDataKey,
    getRealWeatherAirDataKey,
    getRealWeatherDataKey,
    KEY_CITIES_INFO
} from '../common/constants'
import { CityModel } from '../model/CityModel'

export function getWeatherKvStore(context: Context): Promise<distributedKVStore.DeviceKVStore> {
    return getDeviceKVStore(
        createKvManager(context, BUNDLE_NAME),
        STORE_ID_WEATHER,
        distributedKVStore.SecurityLevel.S3, {
        encrypt: true,
        createIfMissing: true,
        backup: true,
    })
}

/***
 * 删除与 locationID 相关的数据
 * */
export function deleteCityRelatedData(store: distributedKVStore.DeviceKVStore, locationID: string) {
    store.deleteBatch([
        getRealWeatherDataKey(locationID),
        getRealWeatherAirDataKey(locationID),
        getForecastWeatherDayDataKey(locationID),
        getForecastWeatherHourDataKey(locationID)
    ])
}

/**
 * 更新城市信息
 * */
export function updateCitiesInfo(store: distributedKVStore.DeviceKVStore, citiesInfo: Array<CityModel>) {
    store.put(KEY_CITIES_INFO, JSON.stringify(citiesInfo))
}

/**
 * 获取城市信息
 * */
export async function getCitiesInfo(store: distributedKVStore.DeviceKVStore) {
    return JSON.parse(await store.get(KEY_CITIES_INFO) as string) as Array<CityModel>
}


