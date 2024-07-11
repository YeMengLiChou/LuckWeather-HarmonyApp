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

@Component
@Entry
struct DayTrendPage {
    pageStack: NavPathStack = new NavPathStack()
    @State
    private data: Array<WeatherTrendVO> = []

    /** 从 NavPathStack 获取展示数据 */
    private getParamFromPathStack() {
        const params: ForecastWeatherDayResult =
            this.pageStack.getParamByName("day_trend")[0] as ForecastWeatherDayResult
        this.data = transformWeatherTrendVO(params)
    }

    build() {
        NavDestination() {
            Column() {
                Text('7天趋势预报')
                    .font({
                        size: 30
                    })
                    .width('100%')
                    .padding(20)

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