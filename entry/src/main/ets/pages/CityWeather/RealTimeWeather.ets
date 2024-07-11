import { Compass } from '../../components/Compass';
import { RealWeatherResult } from '../../network/type';
import { LengthMetrics } from '@kit.ArkUI';
import { LengthUnit } from '@ohos.arkui.node';
import { COMPONENT_BACKGROUND_COLOR } from '../../common/constants';
import { SunRiseAndSet } from '../../components/SunRiseAndSet';


export interface RealTimeWeatherOptions {
    uvIndex: string,
    sunrise: string,
    sunset: string,
    moonrise: string,
    moonset: string,
    realData: RealWeatherResult,
}

const textColor = "#000"


@Component
export struct RealTimeWeather {
    @State
    @Require
    options?: RealTimeWeatherOptions = undefined

    build() {
        Flex({
            direction: FlexDirection.Row, alignItems: ItemAlign.Center, space: {
                main: new LengthMetrics(8, LengthUnit.VP), cross: new LengthMetrics(8, LengthUnit.VP)
            }
        }) {
            Flex({
                direction: FlexDirection.Column, alignItems: ItemAlign.Center, space: {
                    main: new LengthMetrics(8, LengthUnit.VP), cross: new LengthMetrics(8, LengthUnit.VP)
                }
            }) {
                // 风向信息
                WindInfoComponent({
                    windDir: this.options!.realData.now.windDir,
                    windScale: this.options!.realData.now.windScale,
                    windDir360: parseInt(this.options!.realData!.now.wind360)
                })
                    .layoutWeight(1)

                SunTimeInfo({ sunrise: this.options!.sunrise, sunset: this.options!.sunset })
                    .layoutWeight(1)
            }
            .layoutWeight(1)

            OtherWeatherInfoComponent({
                humidity: this.options!.realData.now.humidity,
                feelsLike: this.options!.realData.now.feelsLike,
                uvIndex: this.options!.uvIndex,
                presssure: this.options!.realData!.now.pressure
            })
                .layoutWeight(1)
        }
        .height(200)
    }
}

/**
 * 风向、风级信息组件
 * */
@Component
struct WindInfoComponent {
    @Prop windDir: string
    @Prop windScale: string
    @Prop windDir360: number

    build() {
        Row({ space: 10 }) {
            Column({ space: 12 }) {
                Text(this.windDir)
                    .fontColor(textColor)
                    .fontSize(16)
                    .margin({ bottom: 2 })

                Text(this.windScale + '级')
                    .fontSize(16)
                    .fontColor(textColor)
            }
            .width("40%")
            .alignItems(HorizontalAlign.Center)
            .padding({ left: 16 })

            Compass({
                options: {
                    angle: this.windDir360
                }
            })
                .width('60%')
                .aspectRatio(1)
        }
        .width("100%")
        .borderRadius(16)
        .backgroundColor(COMPONENT_BACKGROUND_COLOR)
        .backdropBlur(10)
    }
}


/**
 * 日出日落时间信息
 * */
@Component
struct SunTimeInfo {
    @Prop sunrise: string
    @Prop sunset: string

    build() {
        Row() {
            Column({ space: 4 }) {
                Row({ space: 2 }) {
                    Text(this.sunrise)
                        .fontColor(textColor)
                        .fontSize(16)
                    Text("日出")
                        .fontColor(textColor)
                        .opacity(0.8)
                        .fontSize(14)
                }

                Row({ space: 2 }) {
                    Text(this.sunset)
                        .fontColor(textColor)
                        .fontSize(16)
                    Text("日落")
                        .fontColor(textColor)
                        .opacity(0.8)
                        .fontSize(14)
                }
            }
            .width('50%')
            .height('100%')
            .justifyContent(FlexAlign.Center)

            SunRiseAndSet({
                options: {
                    sunrise: this.sunrise,
                    sunset: this.sunset
                }
            })
                .width('50%')
                .height('100%')
                .offset({ top: -8 })
        }
        .padding({
            left: 8,
            right: 8
        })
        .width('100%')
        .borderRadius(16)
        .backgroundColor(COMPONENT_BACKGROUND_COLOR)
        .backdropBlur(10)
    }
}

@Component
struct OtherWeatherInfoComponent {
    @Prop humidity: string
    @Prop feelsLike: string
    @Prop uvIndex: string
    @Prop presssure: string

    build() {
        Column() {
            List() {
                ForEach([
                    ["湿度", `${this.humidity}%`],
                    ["体感", `${this.feelsLike}°`],
                    ["紫外线", this.uvIndex],
                    ["气压", `${this.presssure}hPa`]
                ],
                    (item: Array<string>) => {
                        ListItem() {
                            Row() {
                                Text(item[0])
                                    .fontColor(textColor)
                                    .opacity(0.8)
                                    .fontSize(16)
                                Text(item[1])
                                    .fontColor(textColor)
                                    .opacity(1)
                                    .fontSize(18)
                            }
                            .height('25%')
                            .width("100%")
                            .alignItems(VerticalAlign.Center)
                            .justifyContent(FlexAlign.SpaceBetween)
                        }
                    })
            }
            .divider({
                strokeWidth: 1,
                color: "#e0e0e0",
            })
            .width("100%")
            .height("auto")
            .scrollBar(BarState.Off)
        }
        .padding({
            top: 16,
            bottom: 16,
            left: 8,
            right: 8
        })
        .borderRadius(16)
        .width('100%')
        .backgroundColor(COMPONENT_BACKGROUND_COLOR)
        .backdropBlur(10)
    }
}






