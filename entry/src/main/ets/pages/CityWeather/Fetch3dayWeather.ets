import { MaxAndMinTemperature } from '../../components/MaxAndMinTemperature'
import { DailyWeatherResult } from '../../network/type'
import { getWeekendText } from '../../utils/TimeUtils'


export interface Fetch3DayWeatherOptions {
    dataList: Array<DailyWeatherResult>,
    onNavigate: () => void
}

//主页面中的显示近3天天气
@Component
export struct Fetch3dayWeather {
    @State @Require
    options?: Fetch3DayWeatherOptions = undefined
    private readonly textColor = '#000'

    build() {
        Column() {
            Column() {
                DaysWeather({ dataList: this.options!.dataList })
                //点击按钮进入详细查看7天天气
                Button("查看近7日天气")
                    .width("100%")// .backgroundColor("#50FFFFFF")
                    .margin({ top: 12 })
                    .padding({ top: 12, bottom: 12 })
                    .fontColor('#fff')
                    .onClick(() => {
                        this.options!.onNavigate()
                    })
            }
            .padding({
                top: 10,
                left: 12,
                right: 12,
                bottom: 12
            })
            .borderRadius(20)
            .width('90%')
            // .backgroundColor('#300066cc')
            .backgroundColor(Color.Transparent)
        }
        .width('100%')
    }
}

@Component
struct DaysWeather {
    private readonly textColor = '#000'
    @Prop dataList: DailyWeatherResult[]

    build() {
        Row() {
            List() {
                ForEach(
                    this.dataList,
                    (item: DailyWeatherResult, index: number) => {
                        if (index < 3)
                        ListItem() {
                            Flex({
                                justifyContent: FlexAlign.SpaceAround,
                                direction: FlexDirection.Row,
                                alignItems: ItemAlign.Center
                            }) {
                                Image($r(`app.media.qweather_icon_${item.iconDay}_fill`))
                                    .width(24)
                                    .height(24)

                                Text(getWeekendText(item.fxDate))
                                    .fontColor(this.textColor)

                                Text(item.textDay)
                                    .width('30%')

                                Text("优")
                                    .padding(4)
                                    .fontColor(this.textColor)
                                    .borderRadius(5)
                                    .backgroundColor("#30FFFFFF")


                                MaxAndMinTemperature({
                                    options: {
                                        tempMax: parseInt(item.tempMax),
                                        tempMin: parseInt(item.tempMin),
                                        // textColor:
                                    }
                                })
                            }
                            .margin({ top: 20, bottom: 10 })

                        }
                    })
            }
            .width('100%')
            .height('auto')
        }
    }
}


