import { IconButton } from '../../components/IconButton'
import { ForecastWeatherDayResult, Location, LocationResult } from '../../network/type'
import { getCitiesInfo, getWeatherKvStore, updateCitiesInfo } from '../../utils/WeatherKvStore'
import { DayTrend } from './DayTrend'
import { distributedKVStore } from '@kit.ArkData'

export interface WeatherTrendVO {
    date: number,
    tempDay: number,
    iconDay: string,
    descDay: string,
    tempNight: number,
    iconNight: string,
    descNight: string,
    windDir: number,
    windSpeed: number,
    humidity: number,
    sunrise?: string,
    sunset?: string,
    moonrise?: string,
    moonset?: string,
    moonPhase: string,
    moonPhaseIcon: string,
}


function parse2Timestamp(time: string) {
    return new Date(time).getTime()
}

function transformWeatherTrendVO(result: ForecastWeatherDayResult): Array<WeatherTrendVO> {
    const now = new Date()
    const nowIsNight = now.getHours() >= 18 || now.getHours() <= 6

    return result.daily.map((item): WeatherTrendVO => {
        return {
            date: parse2Timestamp(item.fxDate),
            tempDay: parseInt(item.tempMax),
            tempNight: parseInt(item.tempMin),
            windDir: parseInt(nowIsNight ? item.wind360Night : item.wind360Day),
            windSpeed: parseInt(nowIsNight ? item.windSpeedNight : item.windSpeedDay),
            iconDay: item.iconDay,
            iconNight: item.iconNight,
            descDay: item.textDay,
            descNight: item.textNight,
            humidity: parseInt(item.humidity),
            sunrise: item.sunrise,
            sunset: item.sunset,
            moonrise: item.moonrise,
            moonset: item.moonset,
            moonPhase: item.moonPhase,
            moonPhaseIcon: item.moonPhaseIcon
        }
    }).sort((a, b) => {
        return a.date - b.date
    })
}

@Builder
export function DayTrendPageBuilder() {
    DayTrendPage()
}

export interface DayTrendPageNavParam {
    locationID: string,
    shouldShowNavigation: boolean,
    added: boolean
    cityName: string,
    data: ForecastWeatherDayResult,
    location?: Location
}

@Component
@Entry
struct DayTrendPage {
    @Provide({ allowOverride: 'pathStack' })
    private pageStack: NavPathStack = new NavPathStack()
    @State
    private data: Array<WeatherTrendVO> = []
    @State
    private param: Optional<DayTrendPageNavParam> = undefined
    private store?: distributedKVStore.DeviceKVStore

    /** 从 NavPathStack 获取展示数据 */
    private getParamFromPathStack() {
        this.param = this.pageStack.getParamByName("day_trend")[0] as DayTrendPageNavParam
        console.log('DayTrendPage navigation param',)
        this.data = transformWeatherTrendVO(this.param.data)
    }

    private navigateToMainPage() {
        AppStorage.setOrCreate("showLocationID", this.param!.locationID)
        this.pageStack.clear(true)
    }

    private addToCitiesInfo() {
        getCitiesInfo(this.store!)
            .then((info) => {
                info.push({
                    locationID: this.param!.location!.id,
                    longitude: parseFloat(this.param!.location!.lon),
                    latitude: parseFloat(this.param!.location!.lat),
                    cityName: this.param!.location!.name,
                    createTimestamp: Date.now(),
                    provinceName: this.param!.location!.adm1,
                    isLocationCity: false,
                })
                updateCitiesInfo(this.store!, info)
                this.param!.added = true
            })
    }

    aboutToAppear(): void {
        getWeatherKvStore(getContext(this))
            .then((store) => {
                this.store = store

            })
    }

    build() {
        NavDestination() {
            Column() {
                DayTrend({
                    options: {
                        data: this.data
                    }
                }).height("80%")


                Column({ space: 8 }) {
                    if (!this.param?.added) {
                        IconButton({
                            options: {
                                buttonSize: { height: 48, width: 48 },
                                iconSize: { height: 36, width: 36 },
                                iconRes: $r('app.media.icon_add'),
                                iconColor: Color.White
                            }
                        }).onClick(() => {
                            this.addToCitiesInfo()
                        })
                        Text("添加到主页")
                    } else if (this.param?.shouldShowNavigation) {
                        IconButton({
                            options: {
                                buttonSize: { height: 48, width: 48 },
                                iconRes: $r('app.media.icon_right_arrow'),
                                iconSize: { height: 36, width: 36 },
                                iconColor: Color.White
                            }
                        }).onClick(() => {
                            this.navigateToMainPage()
                        })
                        Text("去主页查看")
                    }

                }
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .opacity(0.8)

            }
        }
        .title(`${this.param?.cityName ?? ''}7天趋势预报`)
        .height('100%')
        .width('100%')
        .onReady((context) => {
            this.pageStack = context.pathStack
            this.getParamFromPathStack()
        })
    }
}