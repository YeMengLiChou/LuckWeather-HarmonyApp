import { HourlyWeatherResult } from '../../../network/type'

export interface ForecastHourItemOptions {
    data: HourlyWeatherResult,
    tempMax: number,
    tempMin: number,
    leftTemp?: number,
    rightTemp?: number,
    index: number
}

function getHourText(time: number | string, index: number) {
    const date = new Date(time)
    const now = new Date()
    if (now.getHours() == date.getHours()&& now.getDate() == date.getTime() || index == 0) {
        return '现在'
    } else if (date.getHours() == 0) {
        return `${date.getMonth() + 1}月${date.getDate()}日`
    } else {
        const hourText = `0${date.getHours()}`

        return `${hourText.slice(hourText.length - 2)}:00`
    }
}


@Component
export struct ForecastHourItem {
    private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))
    @Require
    @State
    options?: ForecastHourItemOptions = undefined
    private readonly textSize = '14vp'

    private calRatio(temp: number) {
        const maxTemp = this.options!.tempMax
        const minTemp = this.options!.tempMin
        return (temp - minTemp) / (maxTemp - minTemp)
    }

    private shouldDrawPoint() {
        return this.options!.index == 0
    }

    private calAxisY(h: number, paddingH: number, textHeight: number, ratio: number) {
        const useHeight = h - 2 * paddingH - textHeight
        return paddingH + textHeight + (1 - ratio) * useHeight
    }

    private drawTemperatureLine() {
        const w = this.context.width
        const h = this.context.height
        const paddingHeight = h * 0.1

        const curTemp = parseInt(this.options!.data.temp)

        const curRatio = this.calRatio(curTemp)

        this.context.font = this.textSize
        const tempText = `${this.options!.data.temp}°`
        const textMeasure = this.context.measureText(tempText)

        const pointX = w / 2
        const pointY = this.calAxisY(h, paddingHeight, textMeasure.height, curRatio)

        // 绘制温度文本
        this.context.fillText(tempText, pointX - textMeasure.width / 2, pointY - textMeasure.height / 2)

        // 绘制线
        this.context.lineWidth = 1
        this.context.strokeStyle = "#80000000"

        // 左侧有点，绘制线
        if (!this.options!.leftTemp) {
            this.options!.leftTemp = curTemp
        }

        const leftRatio = this.calRatio(this.options!.leftTemp!)
        const leftPX = -w / 2
        const leftPY = this.calAxisY(h, paddingHeight, textMeasure.height, leftRatio)

        this.context.beginPath()
        this.context.moveTo(pointX, pointY)
        this.context.lineTo(leftPX, leftPY)
        this.context.stroke()


        if (!this.options!.rightTemp) {
            this.options!.rightTemp = curTemp
        }
        // 右侧有点，绘制线
        const rightRatio = this.calRatio(this.options!.rightTemp!)
        const rightPX = w + w / 2
        const rightPY = this.calAxisY(h, paddingHeight, textMeasure.height, rightRatio)

        this.context.beginPath()
        this.context.moveTo(pointX, pointY)
        this.context.lineTo(rightPX, rightPY)
        this.context.stroke()


        this.context.lineWidth = 0.5
        this.context.beginPath()
        // 绘制实点
        if (this.shouldDrawPoint()) {
            this.context.strokeStyle = "#039be5"
            this.context.fillStyle = "#039be5"
            this.context.arc(pointX, pointY, 2, 0, 360)
        } else {
            this.context.fillStyle = "#fff"
            this.context.arc(pointX, pointY, 2, 0, 360)
        }

        this.context.fill()
        this.context.stroke()

        if (this.shouldDrawPoint()) {
            this.context.strokeStyle = "#039be5"
            this.context.lineWidth = 1
            this.context.setLineDash([2, 2])
            this.context.beginPath()
            this.context.moveTo(pointX, pointY)
            this.context.lineTo(pointX, pointY + 10)
            this.context.stroke()
        }
    }

    @Builder
    private DataInfo(icon: PixelMap | ResourceStr | DrawableDescriptor, text: string) {
        Row({ space: 2 }) {
            Image(icon)
                .size({ height: 16, width: 16 })
            Text(text)
                .font({
                    size: 12,
                    weight: 300
                })
                .width('60%')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
    }

    build() {
        Column({ space: 8 }) {
            Canvas(this.context)
                .height('35%')
                .width('100%')
                .onReady(() => {
                    this.drawTemperatureLine()
                })

            Column({ space: 8 }) {
                Image($r(`app.media.qweather_icon_${this.options!.data.icon}_fill`))
                    .size({ height: 24, width: 24 })
                    .opacity(0.8)
                    .fillColor("#151d29")

                Text(this.options!.data.text)
                    .font({
                        size: 12,
                        weight: 400
                    })

                // 风级
                this.DataInfo($r('app.media.icon_air'), `${this.options!.data.windScale}`)
                // 湿度
                this.DataInfo($r("app.media.icon_humidity_mid"), `${this.options!.data.humidity}%`)
                // 降雨概率
                this.DataInfo($r("app.media.icon_rainy"), `${this.options!.data.pop}%`)

                Text(getHourText(this.options!.data.fxTime, this.options!.index))
                    .font({
                        size: 12,
                        weight: 300
                    })

            }
            .padding({ left: 4, right: 4 })
            .width("100%")
            .alignItems(HorizontalAlign.Center)
        }.width('100%')
    }
}


@Entry
@Component
struct ItemPreview {
    private mockData: Array<ForecastHourItemOptions> = [{
        data: {
            "fxTime": "2024-07-11T22:00+08:00",
            "temp": "30",
            "icon": "305",
            "text": "小雨",
            "wind360": "36",
            "windDir": "东北风",
            "windScale": "1-3",
            "windSpeed": "11",
            "humidity": "63",
            "pop": "55",
            "precip": "0.4",
            "pressure": "994",
            "cloud": "36",
            "dew": "20"
        },
        leftTemp: undefined,
        rightTemp: 30,
        tempMax: 33,
        tempMin: 24,
        index: 0,
    },
        {
            data: {
                "fxTime": "2024-07-11T23:00+08:00",
                "temp": "30",
                "icon": "305",
                "text": "小雨",
                "wind360": "44",
                "windDir": "东北风",
                "windScale": "1-3",
                "windSpeed": "9",
                "humidity": "61",
                "pop": "70",
                "precip": "0.45",
                "pressure": "994",
                "cloud": "19",
                "dew": "20"
            },
            leftTemp: 30,
            rightTemp: 29,
            tempMax: 33,
            tempMin: 24,
            index: 1,
        },
        {
            data: {
                "fxTime": "2024-07-12T00:00+08:00",
                "temp": "29",
                "icon": "151",
                "text": "多云",
                "wind360": "40",
                "windDir": "东北风",
                "windScale": "1-3",
                "windSpeed": "9",
                "humidity": "63",
                "pop": "7",
                "precip": "0.0",
                "pressure": "994",
                "cloud": "38",
                "dew": "20"
            },
            leftTemp: 30,
            rightTemp: undefined,
            tempMax: 33,
            tempMin: 24,
            index: 2,
        }
    ]

    build() {
        List() {
            ForEach(this.mockData, (item: ForecastHourItemOptions) => {
                ListItem() {
                    ForecastHourItem({
                        options: item
                    })
                }.width('15%')
            })
        }.width('100%')
        .height('auto')
        .listDirection(Axis.Horizontal)
    }
}