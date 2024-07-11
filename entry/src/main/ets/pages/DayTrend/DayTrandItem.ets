import { WeatherTrendVO } from './DayTrendPage'

/** DayTrendItem 选项设置 */
export interface DayTrendItemOptions {
    /** 单个Item的数据 */
    data: WeatherTrendVO,

    /** 一系列数据中日间最低温度 */
    lowestTempDay: number,

    /** 一系列数据中日间最高温度 */
    highestTempDay: number,

    /** 一系列数据中夜间最高温度 */
    highestTempNight: number,

    /** 一系列数据中夜间最低温度 */
    lowestTempNight: number,

    /** 左侧子项日间温度，第一项则为空 */
    leftTempDay?: number,

    /** 右侧子项日间温度，最后一项则为空 */
    rightTempDay?: number,

    /** 左侧子项夜间温度，第一项则为空 */
    leftTempNight?: number,

    /** 右侧子项夜间温度，最后一项则为空 */
    rightTempNight?: number,
}

/**
 * 格式化时间戳
 * */
function formatTimestamp(time: number) {
    const date = new Date(time)
    return `${date.getMonth() + 1}月${date.getDate()}日`
}

/**
 * 获取周x文本
 * */
function getWeekendText(time: number) {
    const date = new Date(time)
    const now = new Date()
    if (date.getDate() == now.getDate()) {
        return '今天'
    } else if (date.getDate() == now.getDate() + 1) {
        return '明天'
    }
    const day = date.getDay()
    switch (day) {
        case 0:
            return '周日';
        case 1:
            return '周一';
        case 2:
            return '周二';
        case 3:
            return '周三';
        case 4:
            return '周四';
        case 5:
            return '周五';
        case 6:
            return '周六';
    }
    return ''
}


@Extend(Text)
function smallText() {
    .font({
        size: 12,
        weight: 300
    })
    .fontColor(Color.Gray)
    .textAlign(TextAlign.Center)
    .width('100%')
}

@Component
export struct DayTrendItem {
    @Prop
    private options: DayTrendItemOptions
    @State
    private isToday: boolean = false
    private readonly canvasPaddingHeight = 20
    private readonly canvasTopRatio = 0.15
    private readonly canvasBottomRatio = 0.15
    private readonly lineColor = "#D6D6D6"
    private readonly pointColor = "#b8b8b8"
    private readonly temperatureTextColor = "#000000"
    private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(
        new RenderingContextSettings(true)
    )

    /**
     * 计算顶部点的Y坐标
     * */
    private calTopPointY(textHeight: number, topHeight: number, ratioDay: number): number {
        return this.canvasPaddingHeight + textHeight + topHeight * (1 - ratioDay)
    }

    /**
     * 计算底部点的Y坐标
     * */
    private calBottomPointY(textHeight: number, bottomHeight: number, ratioNight: number): number {
        return this.canvasContext.height - this.canvasPaddingHeight - textHeight - bottomHeight * (ratioNight)
    }

    /**
     * 计算日间温度所占百分比
     * */
    private calDayTempRatio(temp: number) {
        return (temp - this.options.lowestTempDay) / (this.options.highestTempDay - this.options.lowestTempDay)
    }

    /**
     * 计算夜间温度所占百分比
     * */
    private calNightTempRatio(temp: number) {
        return (temp - this.options.lowestTempNight) / (this.options.highestTempNight - this.options.lowestTempNight)
    }

    /**
     * 绘制圆点
     * */
    private drawPoint(x: number, y: number, fillColor?: string | number | CanvasGradient | CanvasPattern) {
        this.canvasContext.lineWidth = 1.5
        this.canvasContext.strokeStyle = this.pointColor
        this.canvasContext.beginPath()
        this.canvasContext.arc(x, y, 3, 0, 360)
        if (fillColor) {
            this.canvasContext.fillStyle = fillColor
            this.canvasContext.fill()
        }
        this.canvasContext.stroke()

    }

    /**
     * 绘制温度折线图
     * */
    private drawTemperatureLine() {
        const w = this.canvasContext.width
        const h = this.canvasContext.height

        this.canvasContext.font = `14vp`
        this.canvasContext.lineWidth = 1.5
        this.canvasContext.strokeStyle = Color.Gray

        // 绘制文本
        const dayTempText = `${this.options.data.tempDay}°`
        const nightTempText = `${this.options.data.tempNight}°`
        const dayTempTextMeasure = this.canvasContext.measureText(dayTempText)
        const nightTempTextMeasure = this.canvasContext.measureText(nightTempText)

        // 计算所占高度
        const topHeight = h * this.canvasTopRatio
        const bottomHeight = h * this.canvasBottomRatio

        // 确定最高温度部分的所占百分比
        const ratioDay = this.calDayTempRatio(this.options.data.tempDay)

        // 确定最低温度部分的所占百分比
        const ratioNight = this.calNightTempRatio(this.options.data.tempNight)

        // 确定上部分圆点的绘制位置
        const topPointX = w / 2
        const topPointY = this.calTopPointY(dayTempTextMeasure.height, topHeight, ratioDay)

        this.canvasContext.fillStyle = this.temperatureTextColor

        // 绘制文本
        this.canvasContext.fillText(dayTempText, topPointX - dayTempTextMeasure.width / 2,
            topPointY - dayTempTextMeasure.height)

        // 绘制上部分圆点
        this.drawPoint(topPointX, topPointY)

        // 确认下部分圆点的绘制位置
        const bottomPointX = w / 2
        const bottomPointY = this.calBottomPointY(nightTempTextMeasure.height, bottomHeight, ratioNight)

        // 绘制下部分圆点
        this.drawPoint(bottomPointX, bottomPointY)

        this.canvasContext.fillStyle = this.temperatureTextColor
        // 绘制下部分圆点
        this.canvasContext.fillText(nightTempText, bottomPointX - nightTempTextMeasure.width / 2,
            bottomPointY + nightTempTextMeasure.height + 10)

        // 计算到左侧上部分圆点的位置
        if (this.options.leftTempDay && this.options.leftTempNight) {
            this.drawLeftLine(topPointX, topPointY, bottomPointX, bottomPointY, this.options.leftTempDay,
                this.options.leftTempNight)
        }
        // 计算到右侧上部分圆点的位置
        if (this.options.rightTempDay && this.options.rightTempNight) {
            this.drawRightLine(topPointX, topPointY, bottomPointX, bottomPointY, this.options.rightTempDay,
                this.options.rightTempNight)
        }

        // 将绘制的圆内部交叉线段覆盖掉
        this.drawPoint(topPointX, topPointY, "#ffffff")
        this.drawPoint(bottomPointX, bottomPointY, "#fffffff")
    }

    /**
     * 绘制到左侧的圆点的线段
     * */
    private drawLeftLine(
        topPx: number, topPy: number, bottomPx: number, bottomPy: number,
        leftTempDay: number, leftTempNight: number
    ) {
        const w = this.canvasContext.width
        const h = this.canvasContext.height

        this.canvasContext.lineWidth = 1
        this.canvasContext.strokeStyle = this.lineColor

        // 计算左侧上部分的圆点位置
        const leftRatioDay = this.calDayTempRatio(leftTempDay)
        const leftTopPointX = -w / 2
        const leftTopPointY = this.calTopPointY(
            this.canvasContext.measureText(`${leftTempDay}°`).height,
            h * this.canvasTopRatio,
            leftRatioDay
        )

        // 绘制线段
        this.canvasContext.beginPath()
        this.canvasContext.moveTo(topPx, topPy)
        this.canvasContext.lineTo(leftTopPointX, leftTopPointY)
        this.canvasContext.stroke()

        const leftRatioNight = this.calNightTempRatio(leftTempNight)
        const leftBottomPointX = -w / 2
        const leftBottomPointY = this.calBottomPointY(
            this.canvasContext.measureText(`${leftTempNight}°`).height,
            h * this.canvasBottomRatio,
            leftRatioNight
        )
        // 绘制线段
        this.canvasContext.beginPath()
        this.canvasContext.moveTo(bottomPx, bottomPy)
        this.canvasContext.lineTo(leftBottomPointX, leftBottomPointY)
        this.canvasContext.stroke()
    }

    /**
     * 绘制到右侧的圆点的线段
     * */
    private drawRightLine(
        topPx: number, topPy: number, bottomPx: number, bottomPy: number,
        rightTempDay: number, rightTempNight: number
    ) {
        const w = this.canvasContext.width
        const h = this.canvasContext.height

        this.canvasContext.lineWidth = 1
        this.canvasContext.strokeStyle = this.lineColor

        // 计算左侧上部分的圆点位置
        const rightRatioDay = this.calDayTempRatio(rightTempDay)
        const rightTopPointX = w + w / 2
        const rightTopPointY = this.calTopPointY(
            this.canvasContext.measureText(`${rightTempDay}°`).height,
            h * this.canvasTopRatio,
            rightRatioDay
        )

        this.canvasContext.beginPath()
        this.canvasContext.moveTo(topPx, topPy)
        this.canvasContext.lineTo(rightTopPointX, rightTopPointY)
        this.canvasContext.stroke()


        const rightRatioNight = this.calNightTempRatio(rightTempNight)
        const rightBottomPointX = w + w / 2
        const rightBottomPointY = this.calBottomPointY(
            this.canvasContext.measureText(`${rightTempNight}°`).height,
            h * this.canvasBottomRatio,
            rightRatioNight
        )
        // 绘制线段
        this.canvasContext.beginPath()
        this.canvasContext.moveTo(bottomPx, bottomPy)
        this.canvasContext.lineTo(rightBottomPointX, rightBottomPointY)
        this.canvasContext.stroke()
    }

    /**
     * 获取湿度对应的图标
     * */
    private getHumidityIcon(humidity: number) {
        if (humidity >= 45 && humidity <= 60) {
            return $r('app.media.icon_humidity_mid')
        } else if (humidity < 45) {
            return $r('app.media.icon_humidity_low')
        } else {
            return $r('app.media.icon_humidity_high')
        }
    }

    /**
     * 给 “今天” 子项强调下
     * */
    @Styles
    private emphasisToday() {
        .backgroundColor(this.isToday ? '#80f0F0F0' : Color.White)
        .borderRadius(this.isToday ? 16 : 0)
    }

    /**
     * 天气图标
     * */
    @Builder
    private weatherIcon(icon: string) {
        Image($r(`app.media.qweather_icon_${icon}_fill`))
            .size({ width: 28, height: 28 })
            .fillColor(Color.Gray)
            .margin({ top: 20, bottom: 10 })
    }

    aboutToAppear(): void {
        this.isToday = getWeekendText(this.options.data.date) === '今天'
    }

    build() {
        Column() {
            // 日期 + 日间温度
            Column() {
                // 日期
                Text(getWeekendText(this.options.data.date))
                    .font({
                        size: 14,
                        weight: 400,
                    })
                    .fontColor(Color.Gray)
                Text(formatTimestamp(this.options.data.date))
                    .font({
                        size: 12,
                        weight: 400,
                    })
                    .fontColor(Color.Gray)
                    .margin({ top: 4 })

                Text(this.options.data.sunrise ? `日出:${this.options.data.sunrise}` : ' ')
                    .smallText()
                    .margin({ top: 8 })
                Text(this.options.data.sunset ? `日落:${this.options.data.sunset}` : ' ')
                    .smallText()


                // 图标
                this.weatherIcon(this.options.data.iconDay)
                // 天气描述
                Text(this.options.data.descDay)
                    .font({
                        size: 14,
                        weight: 450
                    })
            }
            .margin({ left: 20, right: 20, top: 20 })


            // 温度折线
            Canvas(this.canvasContext)
                .height('25%')
                .width('100%')
                .onReady(() => {
                    this.drawTemperatureLine()
                })

            // 夜间部分
            Column() {
                // 图标
                this.weatherIcon(this.options.data.iconDay)
                // 天气描述
                Text(this.options.data.descNight)
                    .font({
                        size: 14,
                        weight: 450
                    })
                // 月出月落
                Text(this.options.data.moonrise ? `月出:${this.options.data.moonrise}` : ' ')
                    .smallText()
                    .margin({ top: 10 })
                Text(this.options.data.moonset ? `月落:${this.options.data.moonset}` : ' ')
                    .smallText()
            }
            .alignItems(HorizontalAlign.Center)

            // 其他信息
            Column() {
                // 月相
                Row({ space: 4 }) {
                    Image($r(`app.media.qweather_icon_${this.options.data.moonPhaseIcon}`))
                        .size({ width: 14, height: 14 })
                        .fillColor(Color.Gray)
                        .margin({ top: 4 })
                        .offset({top: -2})
                    Text(this.options.data.moonPhase)
                        .fontSize(14)
                        .fontWeight(300)
                        .fontColor(Color.Gray)
                }
                .margin({ top: 10 })
                .alignItems(VerticalAlign.Center)

                // 风向/风速
                Row({ space: 4 }) {
                    Image($r("app.media.icon_navigation"))
                        .rotate({
                            centerX: '50%',
                            centerY: '50%',
                            angle: this.options.data.windDir
                        })
                        .size({
                            width: 14,
                            height: 14
                        })
                    Text(`${this.options.data.windSpeed}级`)
                        .fontSize(14)
                        .fontWeight(300)
                        .fontColor(Color.Gray)
                }
                .margin({ top: 20 })
                .alignItems(VerticalAlign.Center)

                // 湿度
                Row({ space: 4 }) {
                    Image(this.getHumidityIcon(this.options.data.humidity))
                        .size({
                            width: 14,
                            height: 14
                        })
                    Text(`${this.options.data.humidity}%`)
                        .fontSize(14)
                        .fontWeight(300)
                        .fontColor(Color.Gray)
                }
                .margin({ top: 10 })
                .alignItems(VerticalAlign.Center)
            }

        }
        .alignSelf(ItemAlign.Center)
        .emphasisToday()
        .width(100)
        .padding({ top: 10, bottom: 10 })
    }
}