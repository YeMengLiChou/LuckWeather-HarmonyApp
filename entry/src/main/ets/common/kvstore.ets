import { distributedKVStore } from '@kit.ArkData';


/**
 * 创建一个 [KVManager] 实例
 * @param context
 * @param bundleName 包名
 * */
export function createKvManager(context: Context, bundleName: string): distributedKVStore.KVManager {
    return distributedKVStore.createKVManager({
        bundleName,
        context
    });
}


export interface KVStoreOptions {
    createIfMissing?: boolean,
    encrypt?: boolean,
    backup?: boolean,
    autoSync?: boolean
}

/**
 * 创建并获取 [SingleKVStore] 的实例
 * @param kvManager
 * @param storeId
 * @param createIfMissing
 * @param encrypt
 * @param backup
 * @param autoSync
 * @param securityLevel
 * */
export function getSingleKVStore(
    kvManager: distributedKVStore.KVManager,
    storeId: string,
    securityLevel: distributedKVStore.SecurityLevel,
    options?: KVStoreOptions
): Promise<distributedKVStore.SingleKVStore> {
    return kvManager.getKVStore(storeId, {
        createIfMissing: options?.createIfMissing,
        encrypt: options?.encrypt,
        backup: options?.backup,
        autoSync: options?.autoSync,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel
    })
}

/**
 * 创建并获取 [DeviceKVStore] 的实例
 * @param kvManager
 * @param storeId
 * @param createIfMissing
 * @param encrypt
 * @param backup
 * @param autoSync
 * @param securityLevel
 * */
export function getDeviceKVStore(
    kvManager: distributedKVStore.KVManager,
    storeId: string,
    securityLevel: distributedKVStore.SecurityLevel,
    options?: KVStoreOptions
): Promise<distributedKVStore.DeviceKVStore> {
    return kvManager.getKVStore(storeId, {
        createIfMissing: options?.createIfMissing,
        encrypt: options?.encrypt,
        backup: options?.backup,
        autoSync: options?.autoSync,
        kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
        securityLevel
    })
}


export function booleanEntry(
    key: string,
    value: boolean
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.BOOLEAN,
            value
        }
    }
}

export function strEntry(
    key: string,
    value: string
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.STRING,
            value
        }
    }
}

export function intEntry(
    key: string,
    value: number
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.INTEGER,
            value
        }
    }
}

export function floatEntry(
    key: string,
    value: number
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.FLOAT,
            value
        }
    }
}

export function doubleEntry(
    key: string,
    value: number
): distributedKVStore.Entry {
    return {
        key,
        value: {
            type: distributedKVStore.ValueType.DOUBLE,
            value
        }
    }
}


export enum ChangeType {
    INSERT,
    UPDATE,
    DELETE,
}

/**
 * 监听
 * */
export function watch(
    kvStore: distributedKVStore.SingleKVStore | distributedKVStore.DeviceKVStore,
    key: string,
    subscribeType: distributedKVStore.SubscribeType,
    callback: (type: ChangeType, value: distributedKVStore.Value) => void
) {
    kvStore.on('dataChange', subscribeType, (data) => {
        data.insertEntries.forEach((item) => {
            if (item.key === key) {
                callback(ChangeType.INSERT, item.value)
            }
        })
        data.updateEntries.forEach((item) => {
            if (item.key === key) {
                callback(ChangeType.UPDATE, item.value)
            }
        })
        data.deleteEntries.forEach((item) => {
            if (item.key === key) {
                callback(ChangeType.DELETE, item.value)
            }
        })
    })
}