export interface CompassOptions {
    angle: number,
    borderColor?: string | number | Color,
    pointerColor?: string | number | Color,
}

@Entry
@Component
struct Preview {
    build() {
        Column() {
            Compass({
                options: {
                    angle: 240,

                }
            }).size({ width: 100, height: 100 })
        }.width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Center)
    }
}


@Component
export struct Compass {
    @Require
    options?: CompassOptions
    private settings: RenderingContextSettings = new RenderingContextSettings(true)
    private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
    private readonly compassBorderColor: string = "#000"
    private readonly textSize: string = "8vp"
    private readonly compassPointerColor = "#000"

    private drawCompass() {
        const h = this.context.height
        const w = this.context.width

        const centerX = h / 2
        const centerY = w / 2
        const radius = w / 3

        this.context.strokeStyle = this.options?.borderColor ?? this.compassBorderColor
        this.context.fillStyle = this.options?.borderColor ?? this.compassBorderColor
        this.context.lineWidth = 1.5
        this.context.beginPath()
        this.context.arc(centerX, centerY, radius, 0, 360)
        this.context.stroke()

        this.context.font = this.textSize

        const text = "北"
        const textMeasure = this.context.measureText(text)

        // 北的位置
        const northPointX = centerX - textMeasure.width / 2
        const northPointY = centerY - radius + textMeasure.height
        this.context.fillText('北', northPointX, northPointY)

        // 南的位置
        const southPointX = centerX - textMeasure.width / 2
        const southPointY = centerY + radius - textMeasure.height / 2
        this.context.fillText('南', southPointX, southPointY)

        // 西的位置
        const westPointX = centerX - radius + textMeasure.width / 2
        const westPointY = centerY + textMeasure.height / 2
        this.context.fillText('西', westPointX, westPointY)

        // 东的位置
        const eastPointX = centerX + radius - textMeasure.width * 3 / 2
        const eastPointY = centerY + textMeasure.height / 2
        this.context.fillText('东', eastPointX, eastPointY)

        // 旋转指定角度，准备绘制指针
        this.context.translate(centerX, centerY)
        this.context.rotate(this.options!.angle * Math.PI / 180)
        this.context.translate(-centerX, -centerY)

        const lineStartPX = centerX
        const lineStartPY = centerY + radius - textMeasure.height * 2
        const lineEndPX = centerX
        const lineEndPY = centerY - radius + textMeasure.height * 2

        // 绘制指针
        this.context.lineJoin = "miter"
        this.context.lineCap = "round"
        this.context.lineWidth = 2
        this.context.strokeStyle = this.options?.pointerColor ?? this.compassPointerColor
        this.context.beginPath()
        // 主轴绘制
        this.context.moveTo(lineStartPX, lineStartPY)
        this.context.lineTo(lineEndPX, lineEndPY)
        // 箭头绘制
        this.context.moveTo(lineEndPX - 1.5, lineEndPY + radius / 4)
        this.context.lineTo(lineEndPX, lineEndPY)
        this.context.lineTo(lineEndPX + 1.5, lineEndPY + radius / 4)
        this.context.stroke()

    }

    build() {
        Canvas(this.context)
            .onReady(() => {
                this.drawCompass()
            })
    }
}