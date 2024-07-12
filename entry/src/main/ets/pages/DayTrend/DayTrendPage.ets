import { IconButton } from '../../components/IconButton'
import { ForecastWeatherDayResult } from '../../network/type'
import { DayTrend } from './DayTrend'

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
    cityName: string,
    data: ForecastWeatherDayResult,
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

    /** 从 NavPathStack 获取展示数据 */
    private getParamFromPathStack() {
        this.param = this.pageStack.getParamByName("day_trend")[0] as DayTrendPageNavParam
        console.log('DayTrendPage navigation param', )
        this.data = transformWeatherTrendVO(this.param.data)
    }

    build() {
        NavDestination() {
            Column() {
                Row() {
                    Text(`${this.param?.cityName ?? ''}7天趋势预报`)
                        .font({
                            size: 30
                        })
                        .width('100%')
                        .padding(20)

                    if (this.param?.shouldShowNavigation) {
                        Row() {
                            Text("去主页查看")
                            IconButton({
                                options: {
                                    iconRes: $r('app.media.icon_right_arrow'),
                                    buttonSize: { height: 48, width: 48 },
                                    iconSize: { height: 36, width: 36 },
                                    buttonColor: '#e0e0e0',
                                }
                            })
                        }
                        .alignItems(VerticalAlign.Center)
                        .onClick(() => {

                        })
                    }
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)

                DayTrend({
                    options: {
                        data: this.data
                    }
                })
            }
        }
        .height('100%')
        .width('100%')
        .onReady((context) => {
            this.pageStack = context.pathStack
            this.getParamFromPathStack()
        })
    }
}