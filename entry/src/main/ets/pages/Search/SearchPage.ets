import { CityManagerList } from '../../viewmodel/CityManagerViewModel'
import { CityMangerModel2, CityWeatherVO, WeatherData } from '../../model/CityManagerModel2'
import { getWeatherKvStore } from '../../utils/WeatherKvStore'
import { distributedKVStore } from '@kit.ArkData'
import { KEY_CITIES_INFO } from '../../common/constants'
import { CityModel } from '../../model/CityModel'
import { BusinessError } from '@kit.BasicServicesKit'
import { SearchLink } from './SearchLink'


export interface SearchPageWeatherData {
    temp: number,
    tempMax: number,
    tempMin: number,
    desc: string,
    locationID: string,
}


@Builder
export function SearchPageBuilder() {
    SearchPage()
}


@Entry
@Component
struct SearchPage {
    @Provide({allowOverride: 'pathStack'})
    private pageStack: NavPathStack = new NavPathStack()
    @State
    private dataList: CityMangerModel2[] = CityManagerList //测试本地数据
    @State
    private tureDataList: CityWeatherVO[] = [] //真实的从主页获取来的数据
    private weatherKvStore?: distributedKVStore.DeviceKVStore
    @State
    private citiesInfo: CityModel[] = []
    @State citiesData: WeatherData[] = []

    aboutToAppear(): void {
        getWeatherKvStore(getContext(this))
            .then((store) => {
                this.weatherKvStore = store
                // 从本地获取 citiesInfo
                this.weatherKvStore!.get(KEY_CITIES_INFO)
                    .then((res) => {
                        const citiesInfo = JSON.parse(res as string) as CityModel[]
                        this.citiesInfo.push(...citiesInfo)
                        // 从路由传参中获取天气数据
                        const weatherData = this.pageStack.getParamByName("search")[0] as SearchPageWeatherData[]
                        weatherData.forEach(dataItem => {
                            this.citiesInfo.forEach(infoItem => {
                                if (dataItem.locationID === infoItem.locationID) {
                                    this.tureDataList.push(
                                        {
                                            city: infoItem,
                                            data: {
                                                temp: dataItem.temp,
                                                tempMax: dataItem.tempMax,
                                                tempMin: dataItem.tempMin,
                                                text: dataItem.desc
                                            }
                                        }
                                    )
                                }
                            })
                        })
                    })
                    .catch((err: BusinessError) => {
                        console.log('错误码：' + err.code)
                        console.log('错误信息：' + err.message)
                    })
            })
    }

    build() {
        NavDestination() {
            Column() {
                // 搜索框
                SearchLink({ dataList: this.dataList, tureDataList: this.tureDataList, citiesInfo: this.citiesInfo })
            }
            .width('100%')
            .height('100%')
        }
        .height('100%')
        .width('100%')
        .onReady((context) => {
            this.pageStack = context.pathStack
        })
        .title('城市管理')
    }
}


