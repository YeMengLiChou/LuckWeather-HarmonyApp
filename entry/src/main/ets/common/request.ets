import axios, {
    AxiosHeaders,
    AxiosInstance,
    AxiosRequestConfig,
    AxiosResponse,
    InternalAxiosRequestConfig
} from '@ohos/axios';
import { BASE_URL } from './config';

/**
 * 请求方法
 * */
export type RequestMethod = "GET" | "PUT" | "DELETE" | "POST" | "HEAD" | "OPTIONS" | "TRACE" | "CONNECT"


/**
 * 请求参数
 * */
export interface RequestOptions<T> {
    /**
     * 请求方法，默认为 GET
     * */
    method?: RequestMethod,

    /**
     * 请求查询参数
     * */
    param?: T,

    /**
     * 请求体数据
     *
     * */
    data?: object,

    /**
     * 验证响应码， 默认 code >= 200 && code < 300
     * */
    verifyCode?: (code: number) => boolean,

    /**
     * 请求头
     * */
    header?: AxiosHeaders,

    /**
     * 是否使用 baseUrl，默认为使用；设置为false则单独使用url
     * */
    useBaseUrl?: boolean
}

const config: AxiosRequestConfig = {
    baseURL: BASE_URL,
    timeout: 10_000,
}

const Axios = axios.create(config)

Axios.interceptors.request.use(
    (config: InternalAxiosRequestConfig) => {
        console.info(`Axios request -> ${config.url} `
            + "\n\t--> params: " + JSON.stringify(config.params)
            + "\n\t--> data: " + JSON.stringify(config.data)
        )
        return config
    },
    (error: Error) => {
        return Promise.reject(error)
    }
)

Axios.interceptors.response.use(
    (response: AxiosResponse) => {
        console.info(`Axios response -> ${response.config.url} (${response.status})` +
            "\n\t --> data: " + JSON.stringify(response.data)
        )
        return response
    },
    (error: Error) => {
        return Promise.reject(error)
    }

)

export function request<R, T>(url: string, options?: RequestOptions<R>) {
    if (!options) {
        options = {
            method: "GET",
            useBaseUrl: true
        }
    } else {
        if (!options!.method) {
            options.method = 'GET'
        }
        if (!options!.useBaseUrl) {
            options.useBaseUrl = true
        }
    }

    // 验证响应码
    if (!options!.verifyCode) {
        options!.verifyCode = (code: number) => {
            return code >= 200 && code < 300
        }
    }


    let instance: AxiosInstance
    if (options!.useBaseUrl) {
        instance = Axios
    } else {
        instance = axios
    }

    return new Promise<T>((resolve, reject) => {
        instance.request<T>({
            url: url,
            params: options!.param,
            data: options!.data,
            validateStatus: options!.verifyCode,
            headers: options!.header
        })
            .then((res: AxiosResponse<T>) => {
                resolve(res.data)
            })
            .catch((err: Error) => {
                reject(err)
            })
    })
}