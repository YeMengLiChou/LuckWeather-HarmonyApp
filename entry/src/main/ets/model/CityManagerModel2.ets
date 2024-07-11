import { CityModel } from './CityModel'

export interface CityMangerModel2 {
    cityName: string, //城市名
    temp: string //当前温度
    text: string //天气情况描述
    tempMin: string //当天最低温度
    tempMax: string //当天最高温度
}

export interface Options {
    data: WeatherData[]
}

export interface WeatherData {
    temp: number //当前温度
    text: string //天气情况描述
    tempMin: number //当天最低温度
    tempMax: number //当天最高温度
}

export interface CityWeatherVO {
    city: CityModel,
    data: WeatherData
}
