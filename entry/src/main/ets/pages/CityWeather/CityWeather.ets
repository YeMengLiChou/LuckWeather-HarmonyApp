import log from '../../common/log'
import { promptAction } from '@kit.ArkUI'
import {
    ForecastWeatherDayResult,
    ForecastWeatherHourResult,
    NowAirResult,
    RealWeatherResult
} from '../../network/type'
import { distributedKVStore } from '@kit.ArkData'
import {
    checkDataValidate,
    fetchAndCachedForecast24HourWeather,
    fetchAndCachedForecast7DayWeather,
    fetchAndCachedNowAirData,
    fetchAndCachedRealWeatherData,
    getWeatherKvStore
} from '../../utils/WeatherKvStore'
import * as constants from '../../common/constants'
import { RealTemperature } from './RealTemperature'
import { Fetch3dayWeather } from './Fetch3dayWeather'
import { DayTrendPageNavParam } from '../DayTrend/DayTrendPage'
import { Forecast24HourWetherComponent } from './Forecast24Hour/Forecast24HourWeather'
import { RealTimeWeather } from './RealTimeWeather'
import { BusinessError } from '@kit.BasicServicesKit'

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
    @State
    private refreshingText: string = '刷新中...'

    private kvStore?: distributedKVStore.DeviceKVStore = undefined
    /** 实时天气数据 */
    @State
    @Watch('updateRealTemperatureVOData')
    private realWeatherData?: RealWeatherResult = undefined
    /** 7天预测数据 */
    @State
    @Watch('updateRealTemperatureVOData')
    private forecastDayWeatherData?: ForecastWeatherDayResult = undefined
    /** 24小时预测数据 */
    @State
    private forecastHourWeatherData?: ForecastWeatherHourResult = undefined
    /** 空气数据 */
    @State
    @Watch('updateRealTemperatureVOData')
    private airQualityData?: NowAirResult = undefined
    /** 实时天气数据VO */
    @State
    private realTemperatureVOData?: RealTemperatureVO = undefined


    private updateRealTemperatureVOData(pro: string) {
        if (pro === 'realWeatherData' || pro === 'forecastDayWeatherData' || pro === 'airQualityData') {
            if (this.realWeatherData && this.forecastDayWeatherData && this.airQualityData) {
                this.realTemperatureVOData = transformRealTemperatureVO(this.realWeatherData, this.airQualityData, this.forecastDayWeatherData)
            }
        }
    }
    /**
     * 开始刷新操作
     * */
    private startRefreshing() {
        this.refreshing = true
        this.refreshingCounter++
        this.refreshingText = "刷新中..."
    }

    /**
     * 刷新完毕操作
     * */
    private completedRefreshing() {
        this.refreshingCounter--;
        if (this.refreshingCounter === 0) {
            this.refreshingText = "刷新成功！"
            setTimeout(() => {
                this.refreshing = false
            }, 500)
        }
    }

    /**
     * 刷新实时天气数据(实时温度、空气数据、7天数据)
     * */
    private async fetchAndCachedRealWeatherData() {
        this.startRefreshing()
        try {
            this.realWeatherData = await fetchAndCachedRealWeatherData(this.options.location, this.kvStore!)
            this.airQualityData = await fetchAndCachedNowAirData(this.options.location, this.kvStore!)
            this.forecastDayWeatherData = await fetchAndCachedForecast7DayWeather(this.options.location, this.kvStore!)

            // 更新状态变量
            this.realTemperatureVOData =
                transformRealTemperatureVO(this.realWeatherData, this.airQualityData, this.forecastDayWeatherData)

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
        console.log('fetchAndCachedRealAirData kv store', this.kvStore)

        this.startRefreshing()
        fetchAndCachedNowAirData(this.options!.location, this.kvStore!)
            .then((res) => {
                this.airQualityData = res
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
        fetchAndCachedForecast7DayWeather(this.options!.location, this.kvStore!)
            .then((res) => {
                this.forecastDayWeatherData = res
            })
            .catch((err: Error) => {
                log.error("fetchForecastWeatherDayData failed", err)
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
        console.log('fetchForecastHourWeatherData kv store', this.kvStore)
        fetchAndCachedForecast24HourWeather(this.options!.location, this.kvStore!)
            .then((res) => {
                this.forecastHourWeatherData = res
            })
            .catch((err: Error) => {
                log.error("fetchForecastHourWeatherData failed", err)
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
                console.log(`checkDataValidate<RealWeatherResult> need refresh: ${res === undefined}`)
                if (res) {
                    this.realWeatherData = res
                } else {
                    this.fetchAndCachedRealWeatherData()
                }
            })
            .catch((err: BusinessError) => {
                console.error(`checkDataValidate<RealWeatherResult> failed: (${err.code}) ${err.message}`)
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
                console.log(`checkDataValidate<NowAirResult> need refresh: ${res === undefined}`)
                if (res) {
                    this.airQualityData = res
                } else {
                    this.fetchAndCachedRealAirData()
                }
            })
            .catch((err: BusinessError) => {
                console.error(`checkDataValidate<NowAirResult> failed: (${err.code}) ${err.message}`)
            })
            .finally(() => {
                this.completedRefreshing()
            })

        // 当前7天天气数据
        this.startRefreshing()
        checkDataValidate<ForecastWeatherDayResult>(
            this.kvStore!,
            constants.getForecastWeatherDayDataKey(this.options.location),
            10 * 60 * 1000,
        )
            .then((res) => {

                console.log(`checkDataValidate<ForecastWeatherDayResult> need refresh: ${res === undefined}`)
                if (res) {
                    this.forecastDayWeatherData = res
                } else {
                    this.fetchAndCachedForecastDayWeatherData()
                }
            })

            .catch((err: BusinessError) => {
                console.error(`checkDataValidate<ForecastWeatherDayResult> failed: (${err.code}) ${err.message}`)
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
                console.log(`checkDataValidate<ForecastWeatherHourResult> need refresh: ${res === undefined}`)
                if (res) {
                    this.forecastHourWeatherData = res
                } else {
                    this.fetchAndCachedForecastHourWeatherData()
                }
            })
            .catch((err: BusinessError) => {
                console.error(`checkDataValidate<ForecastWeatherHourResult> failed: (${err.code}) ${err.message}`)
            })
            .finally(() => {
                this.completedRefreshing()
            })
    }

    private navigateToTrendPage() {
        const data: DayTrendPageNavParam = {
            shouldShowNavigation: false,
            added: true,
            locationID: this.options.location,
            cityName: '',
            data: this.forecastDayWeatherData!
        }
        this.pathStack.pushDestinationByName("day_trend", data, true)
    }

    aboutToAppear(): void {
        // 获取本地数据库
        getWeatherKvStore(getContext(this))
            .then((store) => {
                this.kvStore = store
                this.loadDataFromKvStore()
            })
    }

    build() {
        Refresh({ refreshing: $$this.refreshing, promptText: this.refreshingText }) {
            Scroll() {

                Column({ space: 24 }) {
                    if (this.realTemperatureVOData) {
                        Column({ space: 24 }) {
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

                            Fetch3dayWeather({
                                options: {
                                    dataList: this.forecastDayWeatherData!.daily,
                                    onNavigate: () => {
                                        this.navigateToTrendPage()
                                    }
                                }
                            })
                        }
                        .alignItems(HorizontalAlign.Center)
                        .justifyContent(FlexAlign.SpaceBetween) // 保证分开两部分
                        .width('100%')
                        .height('100%')


                        Column({ space: 24 }) {
                            Forecast24HourWetherComponent({
                                dataList: this.forecastHourWeatherData?.hourly
                            })
                                .height(300)

                            RealTimeWeather({
                                options: {
                                    sunset: this.forecastDayWeatherData!.daily[0].sunset ?? '',
                                    sunrise: this.forecastDayWeatherData!.daily[0].sunrise ?? '',
                                    moonrise: this.forecastDayWeatherData!.daily[0].moonrise ?? '',
                                    moonset: this.forecastDayWeatherData!.daily[0].moonset ?? '',
                                    uvIndex: this.forecastDayWeatherData!.daily[0].uvIndex,
                                    realData: this.realWeatherData!
                                }
                            })
                        }
                    }
                }
                .width("100%")
                .padding({ left: 16, right: 16 })
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


