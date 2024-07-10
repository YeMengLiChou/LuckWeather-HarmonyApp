import { createKvManager, getDeviceKVStore } from '../common/kvstore'
import { Context } from '@kit.AbilityKit'
import { BUNDLE_NAME, STORE_ID_WEATHER } from '../common/config'
import { distributedKVStore } from '@kit.ArkData'

export function getWeatherKvStore(context: Context): Promise<distributedKVStore.DeviceKVStore>
{
  return getDeviceKVStore(
    createKvManager(context, BUNDLE_NAME),
    STORE_ID_WEATHER,
    distributedKVStore.SecurityLevel.S3, {
    encrypt: true,
    createIfMissing: true,
    backup: true,
  })

}