import { API_KEY } from '../common/config'
import { request } from '../common/request'
import {
    ForecastWeatherDayResult,
    ForecastWeatherHourResult,
    LocationParam,
    LocationResult,
    NowAirResult,
    RealWeatherResult,
    WeatherIndexResult,
    WeatherParam
} from './type'

/**
 * 通过经纬度查询当前城市信息
 * @param {string} lon 经度，十进制最多两位小数
 * @param {string} lat 纬度，十进制最多两位小数
 * */
export function fetchCityByLatitudeAndLongitude(lon: number, lat: number): Promise<LocationResult> {
    return request<LocationParam, LocationResult>('https://geoapi.qweather.com/v2/city/lookup', {
        useBaseUrl: false,
        param: {
            key: API_KEY,
            location: `${lon.toFixed(2)},${lat.toFixed(2)}`,
            range: 'cn',
            number: 20,
        }
    })
}


/**
 * 获取到实时天气
 * */
export function fetchRealWeather(
    location: string,
): Promise<RealWeatherResult> {
    return request<WeatherParam, RealWeatherResult>('/v7/weather/now', {
        param: {
            key: API_KEY,
            location: location
        }
    })
}

/**
 * 获取未来3天天气预报
 * */
export function fetchForecast3DayWeather(
    location: string
): Promise<ForecastWeatherDayResult> {
    return request<WeatherParam, ForecastWeatherDayResult>('/v7/weather/3d', {
        param: {
            key: API_KEY,
            location: location
        }
    })
}

/**
 * 获取未来7天天气预报
 * */
export function fetchForecast7DayWeather(
    location: string
): Promise<ForecastWeatherDayResult> {
    return request<WeatherParam, ForecastWeatherDayResult>('/v7/weather/7d', {
        param: {
            key: API_KEY,
            location: location
        }
    })
}


/**
 * 获取未来24小时天气预报
 * */
export function fetchForecast24HourWeather(
    location: string
): Promise<ForecastWeatherHourResult> {
    return request<WeatherParam, ForecastWeatherHourResult>('/v7/weather/24h', {
        param: {
            key: API_KEY,
            location: location
        }
    })
}

/**
 * 获取空气质量数据
 * */
export function fetchNowAir(
    location: string,
): Promise<NowAirResult> {
    return request<WeatherParam, NowAirResult>('/v7/air/now', {
        param: {
            key: API_KEY,
            location: location
        }
    })
}

/**
 * 获取天气指数
 * */
export function fetchWeatherIndices(
    location: string,
): Promise<WeatherIndexResult> {
    return request<WeatherParam, WeatherIndexResult>('/v7/indices/1d', {
        param: {
            key: API_KEY,
            location: location
        }
    })

}