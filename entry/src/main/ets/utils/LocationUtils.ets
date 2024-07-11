import { openPermissionsInSystemSettings, requirePermission } from '../common/permission'
import { getWeatherKvStore } from './WeatherKvStore'
import { geoLocationManager } from '@kit.LocationKit'
import { requestLocation } from '../common/location';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { fetchCityByLatitudeAndLongitude } from '../network/api';
import { Location } from '../network/type';
import { distributedKVStore } from '@kit.ArkData';
import { CityModel } from '../model/CityModel';
import { KEY_CITIES_INFO } from '../common/constants';

/**
 * 检查当前定位是否与先前数据匹配
 *
 * 流程：
 * 1. 检查当前定位信息
 * 2. 比较当前定位信息和已有的定位信息比较是否变化
 *      - 如果变化则更新到键值对数据库中
 *      - 如果没有变化则无事发生
 * */
export function checkLocation(context: common.UIAbilityContext) {
    // 检查定位权限是否申请
    requirePermission(
        ["ohos.permission.LOCATION", "ohos.permission.APPROXIMATELY_LOCATION"],
        context,
        () => {
            console.log('requireLocationPermission success, do actions!')
            requestLocationAndCheck(context)
        },
        () => {
            console.error('requireLocationPermission failed, nothing to do!')
            promptAction.showToast({
                message: '未授予定位权限，无法获取当前天气信息！',
                showMode: promptAction.ToastShowMode.TOP_MOST
            })
            openPermissionsInSystemSettings(context, 'cn.li.luck_weather')
        })
}


/**
 * 请求定位数据，并按照比较情况存储到数据库中
 * */
async function requestLocationAndCheck(context: common.UIAbilityContext) {
    let locationInfo: Optional<geoLocationManager.Location> = undefined
    // 获取当前定位信息
    try {
        locationInfo = await requestLocation()
        console.log('requestLocation success', JSON.stringify(locationInfo))
    } catch (err) {
        // 无法获取定位信息，直接返回
        console.error('requestLocation failed', err.message)
        promptAction.showToast({
            message: '定位信息获取失败！'
        })
        return
    }

    // 获取该定位信息对应的城市信息
    let fetchLocationInfo: Optional<Location> = undefined
    try {
        fetchLocationInfo = (await fetchCityByLatitudeAndLongitude(
            locationInfo!.longitude,
            locationInfo!.latitude
        )).location[0]
        console.log('fetch API Location Info success!', JSON.stringify(fetchLocationInfo))
    } catch (err) {
        console.error('fetchCityByLatitudeAndLongitude failed', err.message)
        promptAction.showToast({
            message: '获取定位城市信息失败！'
        })
        return
    }

    // 获取数据库对象
    let weatherStore: Optional<distributedKVStore.DeviceKVStore> = undefined
    try {
        weatherStore = await getWeatherKvStore(context)
    } catch (error) {
        console.error(`getWeatherKvStore failed! code:${error.code} message: ${error.message}`)
        return
    }

    // 从数据库中读取已有信息
    let preCitiesInfo: Optional<CityModel[]> = undefined
    try {
        preCitiesInfo = JSON.parse(
            await weatherStore.get(KEY_CITIES_INFO) as string
        ) as CityModel[]
        // 没数据，执行 catch 部分操作
        if (preCitiesInfo.length == 0) {
            throw new Error()
        }
        console.log(`load cities info from kvStore, total ${preCitiesInfo.length} cities`)
    } catch (err) {
        // 数据库无该数据，则将当前定位信息存进去
        console.log('there is no data in kvStore, save the latest cities info')
        const citiesInfo: Array<CityModel> = [createCityModel(fetchLocationInfo)]
        weatherStore.put(KEY_CITIES_INFO, JSON.stringify(citiesInfo))
        return
    }

    // 存在先前数据
    const locateCities = preCitiesInfo.filter((item) => {
        return item.isLocationCity
    })
    if (locateCities.length != 1) {
        throw new Error(`存在 ${locateCities.length} 个已定位城市`)
    }

    console.log(`current located city ${locateCities[0].cityName}, previous saved located city ${fetchLocationInfo.name}`)

    // 当前获取到的定位信息和存储的定位信息不符，重新存储
    if (locateCities[0].locationID != fetchLocationInfo.id) {
        console.log(`current located city is different from previous saved located city`)
        const index = preCitiesInfo.findIndex((item) => {
            return item.isLocationCity
        })
        preCitiesInfo.splice(index, 1)
        preCitiesInfo.push(createCityModel(fetchLocationInfo))
        weatherStore.put(KEY_CITIES_INFO, JSON.stringify(preCitiesInfo))
    }

}


function createCityModel(fetchLocationInfo: Location): CityModel {
    return {
        cityName: fetchLocationInfo.name,
        provinceName: fetchLocationInfo.adm1,
        createTimestamp: Date.now(),
        locationID: fetchLocationInfo.id,
        isLocationCity: true,
        latitude: parseFloat(fetchLocationInfo.lat),
        longitude: parseFloat(fetchLocationInfo.lon)
    }
}