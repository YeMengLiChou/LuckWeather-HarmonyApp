/**
 * 所有城市信息，对象类型为 CityModel[]
 * */
export const KEY_CITIES_INFO = "cities_info"


/**
 * 实时天气数据KEY前缀
 * */
const KEY_REAL_WEATHER_DATA_PREFIX = "real_weather_data_"

/**
 * 获取指定城市location实时数据的KEY
 * */
export function getRealWeatherDataKey(location: string) {
    return KEY_REAL_WEATHER_DATA_PREFIX + location
}

/**
 * 当前空气质量数据KEY前缀
 * */
const KEY_REAL_WEATHER_AIR_PREFIX = "real_weather_air_"

export function getRealWeatherAirDataKey(location: string) {
    return KEY_REAL_WEATHER_AIR_PREFIX + location
}

/**
 * 指定城市location的日预报天气的数据KEY
 * */
const KEY_FORECAST_WEATHER_DAY_PREFIX = "forecast_weather_day_"

export function getForecastWeatherDayDataKey(location: string) {
    return KEY_FORECAST_WEATHER_DAY_PREFIX + location
}

/**
 * 24小时天气预测数据KEY前缀
 * */
const KEY_FORECAST_WEATHER_HOUR_PREFIX = "forecast_weather_hour_"

/**
 * 指定城市location的小时预测数据的KEY
 * */
export function getForecastWeatherHourDataKey(location: string) {
    return KEY_FORECAST_WEATHER_HOUR_PREFIX + location
}





