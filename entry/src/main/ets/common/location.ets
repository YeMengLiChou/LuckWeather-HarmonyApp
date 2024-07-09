import { geoLocationManager } from '@kit.LocationKit'
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 获取位置信息
 *
 * */
export async function requestLocation(
    validateTime: number = 5 * 60 * 1000
) {
    let location: Optional<geoLocationManager.Location> = undefined
    try {
        location = geoLocationManager.getLastLocation()
        // 如果大于5min，则使用实时的
        if (new Date().getTime() - location.timeStamp >= validateTime) {
            const nowLocation = await requestAccuracyLocation()
            if (nowLocation) {
                location = nowLocation
            }
        }
    } catch (error) {
        const e = error as BusinessError
        console.error(`requestLocation failed and try to use accuracy location! ${e.code} ${e.message}! `)
        const nowLocation = await requestAccuracyLocation()
        if (nowLocation) {
            location = nowLocation
        }
    }
    return location
}

async function requestAccuracyLocation() {
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
