import { CityMangerModel2, CityWeatherVO } from '../../model/CityManagerModel2'
import { CityModel } from '../../model/CityModel'
import { fetchForecast7DayWeather } from '../../network/api'
import { ForecastWeatherDayResult, Location, RealWeatherResult } from '../../network/type'
import {
    fetchAndCachedForecast24HourWeather,
    fetchAndCachedForecast7DayWeather,
    fetchAndCachedNowAirData,
    fetchAndCachedRealWeatherData,
    getWeatherKvStore,
    updateCitiesInfo
} from '../../utils/WeatherKvStore'
import { distributedKVStore } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { IconButton } from '../../components/IconButton'
import { DayTrendPageNavParam } from '../DayTrend/DayTrendPage'
import { BusinessError } from '@kit.BasicServicesKit'


function transformToCityWeatherVO(
    cityInfo: Location,
    realData: RealWeatherResult,
    forecastData: ForecastWeatherDayResult
): CityWeatherVO {
    return {
        city: {
            cityName: cityInfo.name,
            locationID: cityInfo.id,
            isLocationCity: false,
            createTimestamp: Date.now(),
            provinceName: cityInfo.adm1,
            latitude: parseFloat(cityInfo.lat),
            longitude: parseFloat(cityInfo.lon)
        },
        data: {
            temp: parseInt(realData.now.temp),
            tempMax: parseInt(forecastData.daily[0].tempMax),
            tempMin: parseInt(forecastData.daily[0].tempMin),
            text: realData.now.text,

        }
    }
}

//搜索结果卡片样式

@Styles
function searchCard() {
    .width('100%')
    .backgroundColor(Color.Transparent)
    .padding({ top: 12, bottom: 12 })
}


/*
 * 搜索结果列表
 * */
@Component
export struct SearchResult {
    @Consume pathStack: NavPathStack
    /**
     * 搜索结果列表
     * */
    @Link
    locations: Location[]
    @Link
    dataList: CityMangerModel2[]
    @Link
    tureDataList: CityWeatherVO[]
    @Link
    citiesInfo: CityModel[]
    private weatherKvStore?: distributedKVStore.DeviceKVStore

    private async fetchCityWeatherData(item: Location) {
        try {
            const realData = await fetchAndCachedRealWeatherData(item.id, this.weatherKvStore!)
            const forecastData = await fetchAndCachedForecast7DayWeather(item.id, this.weatherKvStore!)
            fetchAndCachedNowAirData(item.id, this.weatherKvStore!)
            fetchAndCachedForecast24HourWeather(item.id, this.weatherKvStore!)
            //更新VO数组
            this.tureDataList.push(transformToCityWeatherVO(item, realData, forecastData))
            // 更新citiesInfo数组
            this.citiesInfo.push({
                cityName: item.name,
                locationID: item.id,
                provinceName: item.adm1,
                longitude: parseFloat(item.lon),
                latitude: parseFloat(item.lat),
                isLocationCity: false,
                createTimestamp: Date.now()
            })
            //新增信息后更新本地数据库
            updateCitiesInfo(this.weatherKvStore!, this.citiesInfo)
        } catch (error) {
            console.error('fetchCityWeatherData failed!', JSON.stringify(error))
            promptAction.showToast({
                message: "网络出错！添加该城市失败!"
            })
        }
    }

    private getCityName(cityName: string, adm1: string, adm2: string, countryName: string) {
        if (adm1.slice(0, adm1.length - 1) === adm2 || adm1 === adm2) {
            return `${cityName} · ${adm1} · ${countryName}`
        } else {
            return `${cityName} · ${adm2} · ${adm1} · ${countryName}`
        }
    }

    /**
     * 跳转到7天趋势页面
     * */
    private navigateToTrendPage(locationID: string, cityName: string, location: Location) {
        fetchForecast7DayWeather(locationID)
            .then((res) => {
                const data: DayTrendPageNavParam = {
                    added: this.citiesInfo.find((item) => item.locationID == locationID) !== undefined,
                    locationID: locationID,
                    shouldShowNavigation: true,
                    cityName: cityName,
                    data: res,
                    location: location
                }
                this.pathStack.pushDestinationByName("day_trend", data)
            })
            .catch((err: BusinessError) => {
                console.error(`navigateToTrend failed! (${err.code})`, err.message)
            })
    }

    aboutToAppear(): void {
        getWeatherKvStore(getContext(this))
            .then((store) => {
                this.weatherKvStore = store
            })
    }

    build() {
        Column() {
            List() {
                ForEach(
                    this.locations,
                    (item: Location) => {
                        ListItem() {
                            Row() {
                                Text(this.getCityName(item.name, item.adm1, item.adm2, item.country))
                                    .lineBreakStrategy(LineBreakStrategy.HIGH_QUALITY)
                                    .width('80%')
                                if (
                                    !this.citiesInfo.some((existed) => {
                                        return existed.locationID === item.id
                                    })
                                ) {
                                    IconButton({
                                        options: {
                                            iconRes: $r('app.media.icon_add'),
                                            iconColor: Color.Gray,
                                            buttonColor: Color.Transparent
                                        }
                                    })
                                        .onClick(() => {
                                            this.fetchCityWeatherData(item)
                                        })
                                } else {
                                    Row({ space: 6 }) {
                                        Text("已添加")
                                            .height(36)
                                            .font({ size: 14, weight: 300 })
                                            .fontColor(Color.Gray)

                                        Image($r("app.media.icon_right_arrow"))
                                            .size({ height: 20, width: 20 })
                                    }
                                    .alignItems(VerticalAlign.Center)
                                }
                            }
                            .width('100%')
                            .justifyContent(FlexAlign.SpaceBetween)
                            .alignItems(VerticalAlign.Center)
                        }
                        .searchCard()
                        .onClick(() => {
                            this.navigateToTrendPage(item.id, item.name, item)
                        })
                    }
                )
            }
            .scrollBar(BarState.Off)
            .height('100%')
            .width('100%')
        }
        .backgroundColor(Color.White)
        .height('100%')
    }
}
