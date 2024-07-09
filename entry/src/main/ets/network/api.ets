import { API_KEY } from '../common/config'
import { request } from '../common/request'
import {
    ForecastWeatherDayResult,
    ForecastWeatherHourResult,
    LocationParam,
    LocationResult,
    RealWeatherResult,
    WeatherParam
} from './type'

/**
 * 通过经纬度查询当前城市信息
 * @param {string} lat 经度
 * @param {string} lon 纬度
 * */
export function fetchCityByLatitudeAndLongitude(lat: string, lon: string): Promise<LocationResult> {
    return request<LocationParam, LocationResult>('https://geoapi.qweather.com/v2/city/lookup', {
        useBaseUrl: false,
        param: {
            key: API_KEY,
            location: `${lat},${lon}`,
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