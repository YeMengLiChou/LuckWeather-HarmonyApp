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
import { KVStoreCachedModel } from '../model/KVStoreCachedModel'
import { fetchForecast24HourWeather, fetchForecast7DayWeather, fetchNowAir, fetchRealWeather } from '../network/api'
import * as constants from '../common/constants'

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


/**
 * 检查数据是否已经过期
 * */
export async function checkDataValidate<T>(
    store: distributedKVStore.DeviceKVStore,
    key: string,
    validateTime: number
): Promise<Optional<T>> {
    try {
        const model = JSON.parse(await store.get(key) as string) as KVStoreCachedModel<T>
        if ((Date.now() - model.cachedTime) < validateTime) {
            return model.data
        }
        return undefined
    } catch (err) {
        return undefined
    }
}

/**
 * 将数据缓存到数据库中
 * */
export async function cacheDataTo<T>(store: distributedKVStore.DeviceKVStore, key: string, data: T) {
    const cachedModel: KVStoreCachedModel<T> = {
        cachedTime: Date.now(),
        data: data
    }
    await store.put(key, JSON.stringify(cachedModel))
}

/**
 * 获取数据并存储到数据库中
 * */
export async function fetchAndCachedRealWeatherData(locationID: string, kvStore: distributedKVStore.DeviceKVStore) {
    const data = await fetchRealWeather(locationID)
    await cacheDataTo(kvStore, constants.getRealWeatherDataKey(locationID), data)
    return data
}


/**
 * 获取数据并存储到数据库中
 * */
export async function fetchAndCachedNowAirData(locationID: string, kvStore: distributedKVStore.DeviceKVStore) {
    const data = await fetchNowAir(locationID)
    await cacheDataTo(kvStore, constants.getRealWeatherAirDataKey(locationID), data)
    return data
}


/**
 * 获取数据并存储到数据库中
 * */
export async function fetchAndCachedForecast7DayWeather(locationID: string, kvStore: distributedKVStore.DeviceKVStore) {
    console.log('utils fetchAndCachedForecast7DayWeather', kvStore)
    const data = await fetchForecast7DayWeather(locationID)
    await cacheDataTo(kvStore, constants.getForecastWeatherDayDataKey(locationID), data)
    return data
}


export async function fetchAndCachedForecast24HourWeather(locationID: string,
    kvStore: distributedKVStore.DeviceKVStore) {
    const data = await fetchForecast24HourWeather(locationID)
    await cacheDataTo(kvStore, constants.getForecastWeatherHourDataKey(locationID), data)
    return data
}
