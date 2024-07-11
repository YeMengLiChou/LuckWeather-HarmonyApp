import { IconButton } from '../components/IconButton'
import { CityModel } from '../model/CityModel'
import { CityWeather } from './CityWeather/CityWeather'
import { distributedKVStore } from '@kit.ArkData'
import { getWeatherKvStore } from '../utils/WeatherKvStore'
import { KEY_CITIES_INFO } from '../common/constants'
import { BusinessError } from '@kit.BasicServicesKit'
import * as constants from '../common/constants'
import { SearchPageWeatherData } from './Search/SearchPage'
import { KVStoreCachedModel } from '../model/KVStoreCachedModel'
import { ForecastWeatherDayResult, RealWeatherResult } from '../network/type'
import { JSON } from '@kit.ArkTS'

@Builder
export function IndexBuilder() {
    Index()
}

@Entry
@Component
struct Index {
    @Provide pageStack: NavPathStack = new NavPathStack()
    private weatherKvStore?: distributedKVStore.DeviceKVStore
    @State
    private citiesInfo: Array<CityModel> = []

    /**
     * 跳转到搜索页面
     * */
    private navigateToSearchPage() {
        this.loadWeatherData()
            .then((res: Array<SearchPageWeatherData>) => {
                this.pageStack.pushDestinationByName("search", res)
            })
            .catch((error: Error) => {
                const err = error as BusinessError
                console.error(`loadWeatherData failed: (${err.code})`, error.message)
            })
    }

    /**
     * 从数据库中加载天气数据
     * */
    private async loadWeatherData() {
        const data: Array<SearchPageWeatherData> = []
        for (let item of this.citiesInfo) {
            const weatherData: KVStoreCachedModel<RealWeatherResult> =
                JSON.parse(
                    await this.weatherKvStore!.get(constants.getRealWeatherDataKey(item.locationID)) as string
                ) as KVStoreCachedModel<RealWeatherResult>
            const forecastData: KVStoreCachedModel<ForecastWeatherDayResult> =
                JSON.parse(
                    await this.weatherKvStore!.get(constants.getForecastWeatherDayDataKey(item.locationID)) as string
                ) as KVStoreCachedModel<ForecastWeatherDayResult>
            data.push({
                temp: parseInt(weatherData.data.now.temp),
                tempMax: parseInt(forecastData.data.daily[0].tempMax),
                tempMin: parseInt(forecastData.data.daily[0].tempMin),
                desc: weatherData.data.now.text,
                locationID: item.locationID
            })
        }
        return data
    }

    /**
     * 从本地数据库加载城市信息
     * */
    private loadCitiesInfoFromKvStore() {
        this.weatherKvStore!.get(KEY_CITIES_INFO)
            .then((res) => {
                const citiesInfo = JSON.parse(res as string) as CityModel[]
                // 将定位城市排到第一位
                citiesInfo.sort((a, b) => {
                    if (a.isLocationCity) {
                        return -1
                    }
                    if (b.isLocationCity) {
                        return 1
                    }
                    return 0
                })
                this.citiesInfo.push(...citiesInfo)
            })
            .catch((error: BusinessError) => {
                console.error('getWeatherKvStore failed!', JSON.stringify(error))
            })

        // 监听数据是否发生变化
        this.weatherKvStore!.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL, (data) => {
            // 应用最开始进入时，会插入数据
            const inserted = data.insertEntries.find((item) => {
                return item.key === KEY_CITIES_INFO;
            })
            if (inserted) {
                this.citiesInfo = JSON.parse(inserted.value.value as string) as CityModel[]
                return
            }
            // 其他使用更新的数据
            const updated = data.updateEntries.find((item) => {
                return item.key === KEY_CITIES_INFO;
            });
            if (updated) {
                this.citiesInfo = JSON.parse(updated.value.value as string) as CityModel[]
            }
        })
    }

    aboutToAppear(): void {
        getWeatherKvStore(getContext(this))
            .then((store) => {
                this.weatherKvStore = store
                this.loadCitiesInfoFromKvStore()
            })
            .catch((error: Error) => {
                console.error('getWeatherKvStore failed!', JSON.stringify(error))
            })
    }

    aboutToDisappear(): void {
        this.weatherKvStore?.off('dataChange')
    }

    @Builder
    tabBuilder(index: number, name: string) {
        Column() {
            Text(name)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(500)
                .id(index.toString())
        }.width('100%')
    }


    build() {
        Navigation(this.pageStack) {
            RelativeContainer() {
                // 添加地区按钮
                Row() {
                    IconButton({
                        options: {
                            iconRes: $r('app.media.icon_add'),
                            iconColor: Color.Black,
                            buttonColor: Color.Transparent
                        }
                    })
                        .onClick(() => {
                            this.navigateToSearchPage()
                        })
                }
                .height(56)
                .padding({ left: 12 })
                .zIndex(5)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignSelf(ItemAlign.Center)
                .alignRules({
                    top: { anchor: '__container__', align: VerticalAlign.Top },
                    left: { anchor: '__container__', align: HorizontalAlign.Start }
                })

                // 主体内容区域
                Tabs({
                    barPosition: BarPosition.Start,
                }) {
                    ForEach(this.citiesInfo, (item: CityModel, index: number) => {
                        TabContent() {
                            CityWeather({
                                options: {
                                    location: item.locationID
                                }
                            })
                        }
                        .tabBar(this.tabBuilder(index, `${item.provinceName} · ${item.cityName}`))
                    })
                }
                .barWidth('70%')
                .barMode(BarMode.Scrollable)

            }
            .height('100%')
            .width('100%')

        }
        .hideTitleBar(true)
        .height('100%')
        .width('100%')
        .onAppear(() => {
            console.log('index page show')
            // TODO: 获取要跳转的位置
        })
        .onDisAppear(() => {
            console.log('index page hided')
        })
    }
}

