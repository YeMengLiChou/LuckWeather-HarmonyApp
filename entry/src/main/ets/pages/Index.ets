import { IconButton } from '../components/IconButton'
import { CityModel } from '../model/CityModel'
import { CityWeather } from './CityWeather/CityWeather'
import { distributedKVStore } from '@kit.ArkData'
import { getWeatherKvStore } from '../utils/WeatherKvStore'
import { KEY_CITIES_INFO } from '../common/constants'
import { BusinessError } from '@kit.BasicServicesKit'


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
            const updated = data.updateEntries.find((item) => {
                return item.key === KEY_CITIES_INFO
            });
            if (updated) {
                this.citiesInfo = JSON.parse(updated.value.value as string)
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
    }
}

