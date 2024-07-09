import { abilityAccessCtrl, bundleManager, Permissions, UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@ohos.arkui.UIContext';
import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';

/**
 * 检查权限是否已经授予
 * */
export async function checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
    let grantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED

    let tokenId: number = 0
    try {
        let bundleInfo =
            await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
        let appInfo = bundleInfo.appInfo
        tokenId = appInfo.accessTokenId
    } catch (err) {
        const e = err as BusinessError
        console.error(`CheckPermissionGrant-->AccessTokenId fetch failed! ${e.code} ${e.message}`)
    }

    try {
        grantStatus = await atManager.checkAccessToken(tokenId, permission)
    } catch (err) {
        const e = err as BusinessError
        console.error(`CheckPermissionGrant-->checkAccessToken failed! ${e.code} ${e.message}`)
    }

    return grantStatus
}

export interface RequestPermissionsResult {
    granted: boolean,
    authResult: number[]
}

/**
 * 申请权限
 * */
export function requestPermission(permissions: Array<Permissions>, context: Context) {
    const atManager = abilityAccessCtrl.createAtManager()
    return new Promise<RequestPermissionsResult>((resolve, reject) => {
        atManager.requestPermissionsFromUser(context, permissions)
            .then((data) => {
                console.log('request permissions result', JSON.stringify(data));
                let grantedStatus = data.authResults
                let length = grantedStatus.length
                let granted = true
                for (let i = 0; i < length; i++) {
                    if (grantedStatus[i] === -1) {
                        granted = false
                        break
                    }
                }
                resolve({
                    granted: granted,
                    authResult: grantedStatus
                })
            })
            .catch((err: BusinessError) => {
                reject(err)
            })
    })
}


/**
 * 打开指定应用的设置页面，引导其开启权限
 * @param {UIAbilityContext} context
 * @param {string} bundleName 应用的包名
 * */
export function openPermissionsInSystemSettings(context: common.UIAbilityContext, bundleName: string) {
    const wantInfo: Want = {
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: {
            pushParams: bundleName // 打开指定应用的详情页面
        }
    }
    return context.startAbility(wantInfo)
}

/**
 * 申请权限，当权限全部授予时，才执行 action 操作，否则调用 onPermissionReject
 *
 * */
export function requirePermission(
    permissions: Permissions[],
    context: common.UIAbilityContext,
    action: () => void,
    onPermissionReject: () => void = () => {
    },
) {
    requestPermission(permissions, context)
        .then((res) => {
            if (res.granted) {
                action()
            } else {
                // 权限拒绝
                if (onPermissionReject) {
                    onPermissionReject!()
                }
            }
        })
}