import { Chip } from '@kit.ArkUI'
import { MaxAndMinTemperature } from '../../components/MaxAndMinTemperature'

export interface RealTemperatureOptions {
    /** 当前温度 */
    curTemp: number,

    /** 当前空气指数 */
    airQualityIndex: number,

    /** 当前空气质量文本描述 */
    airQualityDesc: string,

    /** 降雨量 */
    rain: number,

    /** 天气描述 */
    weatherText: string,

    /** 最高温 */
    highTemp: number,

    /** 最低温 */
    lowTemp: number
}

@Component
export struct RealTemperature {
    @Require @State options?: RealTemperatureOptions = undefined

    build() {
        RelativeContainer() {
            Text(`${this.options!.curTemp!}`)
                .font({
                    size: 100,
                    weight: 500,
                })
                .id('text_temp')
                .alignRules({
                    center: { anchor: '__container__', align: VerticalAlign.Center },
                    middle: { anchor: '__container__', align: HorizontalAlign.Center, },
                })


            Text('℃')
                .font({
                    weight: 500,
                    size: 20
                })
                .margin({ left: 6 })
                .alignRules({
                    left: { anchor: 'text_temp', align: HorizontalAlign.End },
                    top: { anchor: 'text_temp', align: VerticalAlign.Top }
                })


            Row({ space: 20 }) {
                // 描述文本
                Text(this.options!.weatherText)
                // 最高温度/最低温度
                MaxAndMinTemperature({
                    options: {
                        tempMax: this.options!.highTemp,
                        tempMin: this.options!.lowTemp
                    }
                })
            }
            .id('row_bottom')
            .alignRules({
                top: { anchor: 'text_temp', align: VerticalAlign.Bottom },
                middle: { anchor: 'text_temp', align: HorizontalAlign.Center }
            })

            Row({ space: 20 }) {
                Chip({
                    label: {
                        text: `空气 ${this.options!.airQualityDesc} ${this.options!.airQualityIndex}`,
                        fontSize: 14,

                    },
                    allowClose: false,
                    prefixIcon: {
                        src: $r('app.media.icon_leaves'),
                        size: { width: 20, height: 20 }
                    }
                })

                Chip({
                    label: {
                        text: this.options!.rain === 0 ? '暂无降水' : `降雨量 ${this.options!.rain}mm`,
                        fontSize: 14,
                    },
                    allowClose: false,
                    prefixIcon: {
                        src: $r('app.media.icon_rainy'),
                        size: { width: 20, height: 20 }
                    }
                })
            }
            .margin({ top: 10 })
            .alignRules({
                top: { anchor: 'row_bottom', align: VerticalAlign.Bottom },
                middle: { anchor: 'row_bottom', align: HorizontalAlign.Center }
            })
        }
        .width('100%')
        .height('50%')
    }
}