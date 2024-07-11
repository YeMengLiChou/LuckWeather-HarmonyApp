import { RealWeatherResult } from '../network/type'

export const RealWeatherResultList: RealWeatherResult[] = [
    {
        code: '300',

        /**
         * 最近更新时间
         * */
        updateTime: new Date(),

        /** 当前数据的响应式页面 */
        fxLink: 'string',
        now: {
            /** 数据观测时间 */
            obsTime: "string",
            /** 温度，默认单位摄氏度 */
            temp: '30',
            /** 体感温度 */
            feelsLike: "string",
            /** 图标代码 */
            icon: 'string',
            /** 天气描述 */
            text: 'string',
            /** 风向360角 */
            wind360: 'string',
            /** 风向 */
            windDir: 'string',
            /** 风力等级 */
            windScale: 'string',
            /** 风速 km/h */
            windSpeed: 'string',
            /** 湿度 % */
            humidity: 'string',
            /** 当前小时累计降水量，mm */
            precip: 'string',
            /** 大气压强，百帕 */
            pressure: 'string',
            /** 能见度， km */
            vis: 'string',
        },
        refer: {
            sources: [],
            license: []
        }
    }

]