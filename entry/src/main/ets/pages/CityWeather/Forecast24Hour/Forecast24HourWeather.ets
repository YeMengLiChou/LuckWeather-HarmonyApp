import { Forecast24HourWeatherViewModel } from '../../../viewmodel/Forecast24HourWeatherViewModel'
import { HourlyWeatherResult } from '../../../network/type'
import { COMPONENT_BACKGROUND_COLOR } from '../../../common/constants'
import { ForecastHourItem, ForecastHourItemOptions } from './ForecastHourItem'
import { max, min } from '../../../utils/MathUtils'
import { checkLast } from '../../../utils/ArrayUtils'

function transformForecastHourItemOptions(
    res: HourlyWeatherResult[],
): Array<ForecastHourItemOptions> {


    const tempMin = min((item) => {
        return parseInt(item.temp)
    }, ...res)

    const tempMax = max((item) => {
        return parseInt(item.temp)
    }, ...res)

    const result: Array<ForecastHourItemOptions> = res.map((item, index): ForecastHourItemOptions => {
        return {
            data: item,
            tempMax: tempMax,
            tempMin: tempMin,
            leftTemp: index != 0 ? parseInt(res[index - 1].temp) : undefined,
            rightTemp: !checkLast(index, res) ? parseInt(res[index + 1].temp) : undefined,
            index: index,
        }
    })
    return result
}


@Component
export struct Forecast24HourWetherComponent {
    @State @Require
    dataList: HourlyWeatherResult[] = Forecast24HourWeatherViewModel.hourly

    build() {
        Column({ space: 8 }) {
            // header
            Row({ space: 8 }) {
                Image($r('app.media.icon_clock'))
                    .width(20)
                    .fillColor(Color.Gray)
                Text('24小时预报')
                    .fontColor(Color.Gray)
            }
            .width('100%')

            List() {
                ForEach(
                    transformForecastHourItemOptions(this.dataList),
                    (item: ForecastHourItemOptions) => {
                        ListItem() {
                            ForecastHourItem({
                                options: item
                            })
                        }
                        .width('20%')
                    }
                )
            }
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
            .height('100%')
        }
        .padding({
            top: 12,
            bottom: 12,
            left: 12,
            right: 12
        })
        .borderRadius(16)
        .backgroundColor(COMPONENT_BACKGROUND_COLOR)
        .backdropBlur(10)
        .height('100%')
        .width('100%')

    }
}
