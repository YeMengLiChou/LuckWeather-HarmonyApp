import log from '../../common/log'
import { fetchForecast24HourWeather, fetchForecast7DayWeather, fetchNowAir, fetchRealWeather } from '../../network/api'
import { promptAction } from '@kit.ArkUI'
import {
    ForecastWeatherDayResult,
    ForecastWeatherHourResult,
    NowAirResult,
    RealWeatherResult
} from '../../network/type'
import { distributedKVStore } from '@kit.ArkData'
import { getWeatherKvStore } from '../../utils/WeatherKvStore'
import * as constants from '../../common/constants'
import { RealTemperature } from './RealTemperature'
import { KVStoreCachedModel } from '../../model/KVStoreCachedModel'
import { Fetch3dayWeather } from './Fetch3dayWeather'
import { DayTrendPageNavParam } from '../DayTrend/DayTrendPage'
import { Forecast24HourWetherComponent } from './Forecast24HourWeather'

export interface CityWeatherOptions {
    location: string,
}

interface RealTemperatureVO {
    curTemp: number
    weatherDesc: string
    airQualityIndex: number
    airQualityDesc: string,
    rain: number,
    highestTemp: number,
    lowestTemp: number,
}

function transformRealTemperatureVO(
    realWeatherData: RealWeatherResult,
    airData: NowAirResult,
    forecastData: ForecastWeatherDayResult
) {
    const vo: RealTemperatureVO = {
        curTemp: parseInt(realWeatherData.now.temp),
        weatherDesc: realWeatherData.now.text,
        airQualityIndex: parseInt(airData.now.aqi),
        airQualityDesc: airData.now.category,
        rain: parseFloat(realWeatherData.now.precip),
        highestTemp: parseInt(forecastData.daily[0].tempMax),
        lowestTemp: parseInt(forecastData.daily[0].tempMin),

    }
    return vo
}


/***
 * 检查数据是否已经过期
 * */
async function checkDataValidate<T>(
    store: distributedKVStore.DeviceKVStore,
    key: string,
    validateTime: number
): Promise<Optional<T>> {
    try {
        const model = JSON.parse(await store.get(key) as string) as KVStoreCachedModel<T>
        if ((Date.now() - model.cachedTime) < validateTime) {
            return model.data
        }
        return undefined
    } catch (err) {
        return undefined
    }
}

/***
 * 将数据缓存到数据库中
 * */
async function cacheDataTo<T>(store: distributedKVStore.DeviceKVStore, key: string, data: T) {
    const cachedModel: KVStoreCachedModel<T> = {
        cachedTime: Date.now(),
        data: data
    }
    await store.put(key, JSON.stringify(cachedModel))
}


/**
 * 城市天气的主要组件
 * 主要逻辑：
 * 1. 从本地缓存中获取历史数据，使用该数据，如果超过过期时间，进行更新~
 * 2. 下拉刷新操作
 * */
@Component
export struct CityWeather {
    @Consume("pageStack") pathStack: NavPathStack
    @Prop options: CityWeatherOptions
    /** 刷新状态 */
    @State
    private refreshing: boolean = false
    /** 当前刷新完成数 */
    @State
    private refreshingCounter: number = 0
    private kvStore?: distributedKVStore.DeviceKVStore = undefined
    /** 实时天气数据 */
    @State
    private realWeatherData?: RealWeatherResult = undefined
    /** 7天预测数据 */
    @State
    private forecastDayWeatherData?: ForecastWeatherDayResult = undefined
    /** 24小时预测数据 */
    @State
    private forecastHourWeatherData?: ForecastWeatherHourResult = undefined
    /** 空气数据 */
    @State
    private airQualityData?: NowAirResult = undefined
    /** 实时天气数据VO */
    @State
    private realTemperatureVOData?: RealTemperatureVO = undefined

    /**
     * 开始刷新操作
     * */
    private startRefreshing() {
        this.refreshing = true
        this.refreshingCounter++
    }

    /**
     * 刷新完毕操作
     * */
    private completedRefreshing() {
        this.refreshingCounter--;
        if (this.refreshingCounter === 0) {
            this.refreshing = false
        }
    }

    /**
     * 刷新实时天气数据(实时温度、空气数据、7天数据)
     * */
    private async fetchAndCachedRealWeatherData() {
        this.startRefreshing()
        try {
            const realWeatherData = await fetchRealWeather(this.options.location)
            const airData = await fetchNowAir(this.options.location)
            const forecastData = await fetchForecast7DayWeather(this.options.location)

            // 更新状态变量
            this.realTemperatureVOData = transformRealTemperatureVO(realWeatherData, airData, forecastData)
            this.realWeatherData = realWeatherData
            this.airQualityData = airData
            this.forecastDayWeatherData = forecastData

            // 缓存到数据库
            cacheDataTo(this.kvStore!, constants.getRealWeatherDataKey(this.options.location), realWeatherData)
            cacheDataTo(this.kvStore!, constants.getRealWeatherAirDataKey(this.options.location), airData)
            cacheDataTo(this.kvStore!, constants.getForecastWeatherDayDataKey(this.options.location), forecastData)

        } catch (error) {
            promptAction.showToast({
                message: '网络错误！请重新刷新！'
            })
            log.error('fetchRealWeatherData', error)
        } finally {
            this.completedRefreshing()
        }
    }

    private fetchAndCachedRealAirData() {
        this.startRefreshing()
        fetchNowAir(this.options!.location)
            .then((res) => {
                this.airQualityData = res
                cacheDataTo(this.kvStore!, constants.getRealWeatherAirDataKey(this.options.location), res)
            })
            .catch((err: Error) => {
                log.error('fetchAndCachedAirData Failed!', JSON.stringify(err))
                promptAction.showToast({
                    message: '获取数据失败，请检查网络！'
                })
            })
            .finally(() => {
                this.completedRefreshing()
            })
    }

    /**
     * 获取未来7天的数据
     * */
    private fetchAndCachedForecastDayWeatherData() {
        this.startRefreshing()
        fetchForecast7DayWeather(this.options!.location)
            .then((res) => {
                this.forecastDayWeatherData = res
                cacheDataTo(this.kvStore!, constants.getForecastWeatherDayDataKey(this.options.location), res)
            })
            .catch((err: Error) => {
                log.error("fetchForecastWeatherDayData", err)
                promptAction.showToast({
                    message: '获取数据失败，请检查网络！'
                })
            })
            .finally(() => {
                this.completedRefreshing()
            })
    }

    /**
     * 获取未来24小时的数据
     * */
    private fetchAndCachedForecastHourWeatherData() {
        this.startRefreshing()
        fetchForecast24HourWeather(this.options!.location)
            .then((res) => {
                this.forecastHourWeatherData = res
                cacheDataTo(this.kvStore!, constants.getForecastWeatherHourDataKey(this.options.location), res)
            })
            .catch((err: Error) => {
                log.error("fetchForecastHourWeatherData", err)
                promptAction.showToast({
                    message: '获取数据失败，请检查网络！'
                })
            })
            .finally(() => {
                this.completedRefreshing()
            })
    }

    /** 刷新所有天气数据 */
    private refreshAllWeatherData() {
        this.loadDataFromKvStore()
    }

    /**
     * 从本地读取缓存的数据，如果没有或者过期，则执行刷新操作
     * */
    private async loadDataFromKvStore() {
        // 当前实时天气
        this.startRefreshing()
        checkDataValidate<RealWeatherResult>(
            this.kvStore!,
            constants.getRealWeatherDataKey(this.options.location),
            5 * 60 * 1000,
        )
            .then((res) => {
                if (res) {
                    this.realWeatherData = res
                } else {
                    this.fetchAndCachedRealWeatherData()
                }
            })
            .finally(() => {
                this.completedRefreshing()
            })

        // 当前空气质量数据
        this.startRefreshing()
        checkDataValidate<NowAirResult>(
            this.kvStore!,
            constants.getRealWeatherAirDataKey(this.options.location),
            5 * 60 * 1000,
        )
            .then((res) => {
                if (res) {
                    this.airQualityData = res
                } else {
                    this.fetchAndCachedRealAirData()
                }
            })
            .finally(() => {
                this.completedRefreshing()
            })

        // 当前7天天气数据
        this.startRefreshing()
        checkDataValidate<ForecastWeatherDayResult>(
            this.kvStore!,
            constants.getRealWeatherAirDataKey(this.options.location),
            10 * 60 * 1000,
        )
            .then((res) => {
                if (res) {
                    this.forecastDayWeatherData = res
                } else {
                    this.fetchAndCachedForecastDayWeatherData()
                }
            })
            .finally(() => {
                this.completedRefreshing()
            })

        this.startRefreshing()
        checkDataValidate<ForecastWeatherHourResult>(
            this.kvStore!,
            constants.getForecastWeatherHourDataKey(this.options.location),
            10 * 60 * 1000,
        )
            .then((res) => {
                if (res) {
                    this.forecastHourWeatherData = res
                } else {
                    this.fetchAndCachedForecastHourWeatherData()
                }
            })
            .finally(() => {
                this.completedRefreshing()
            })
    }

    private navigateToTrendPage() {
        const data: DayTrendPageNavParam = {
            shouldShowNavigation: false,
            locationID: this.options.location,
            cityName: '',
            data: this.forecastDayWeatherData!
        }
        this.pathStack.pushPathByName("day_trend", data, true)
    }

    aboutToAppear(): void {
        this.refreshing = true
        // 获取本地数据库
        getWeatherKvStore(getContext(this))
            .then((store) => {
                this.kvStore = store
                this.loadDataFromKvStore()
            })
    }

    build() {
        Refresh({ refreshing: $$this.refreshing, promptText: '刷新中' }) {
            Scroll() {
                if (this.realTemperatureVOData) {
                    Column() {
                        RealTemperature({
                            options: {
                                curTemp: this.realTemperatureVOData!.curTemp,
                                weatherText: this.realTemperatureVOData!.weatherDesc,
                                highTemp: this.realTemperatureVOData!.highestTemp,
                                lowTemp: this.realTemperatureVOData!.lowestTemp,
                                rain: this.realTemperatureVOData!.rain,
                                airQualityIndex: this.realTemperatureVOData!.airQualityIndex,
                                airQualityDesc: this.realTemperatureVOData!.airQualityDesc,
                            }
                        })
                            .margin({ top: 40, bottom: 40 })

                        Fetch3dayWeather({
                            options: {
                                dataList: this.forecastDayWeatherData!.daily,
                                onNavigate: () => {
                                    this.navigateToTrendPage()
                                }
                            }
                        })

                        Forecast24HourWetherComponent({
                            dataList: this.forecastHourWeatherData?.hourly
                        })
                    }
                    .width('100%')
                }
            }
            .height('100%')
            .width('100%')
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
        }
        .height('100%')
        .width('100%')
        .onRefreshing(() => {
            this.refreshAllWeatherData()
        })
    }
}


