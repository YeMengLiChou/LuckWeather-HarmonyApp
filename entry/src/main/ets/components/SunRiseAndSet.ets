export interface SunRiseAndSetOptions {
    sunrise: string,
    sunset: string,
}

class Point {
    x: number
    y: number

    constructor(x: number, y: number) {
        this.x = x;
        this.y = y;
    }
}

interface PointWithT {
    t: number,
    point: Point,
}

// 计算二次贝塞尔曲线上 t 处的点 (0 < t < 1)
function calculateQuadraticBezierPoint(t: number, startPoint: Point, controlPoint: Point, endPoint: Point): Point {
    const x = (1 - t) * (1 - t) * startPoint.x + 2 * (1 - t) * t * controlPoint.x + t * t * endPoint.x;
    const y = (1 - t) * (1 - t) * startPoint.y + 2 * (1 - t) * t * controlPoint.y + t * t * endPoint.y;
    return new Point(x, y);
}

// 计算二次贝塞尔曲线与 y = mx + b 相交的点
function findIntersectionPoints(startPoint: Point, controlPoint: Point, endPoint: Point, m: number, b: number) {
    const a = (startPoint.y - 2 * controlPoint.y + endPoint.y) - m * (startPoint.x - 2 * controlPoint.x + endPoint.x);
    const b_coef = 2 * (controlPoint.y - startPoint.y) - m * 2 * (controlPoint.x - startPoint.x);
    const c = startPoint.y - m * startPoint.x - b;

    const discriminant = b_coef * b_coef - 4 * a * c;

    if (discriminant < 0) {
        return []; // 没有交点
    }

    const t1 = (-b_coef + Math.sqrt(discriminant)) / (2 * a);
    const t2 = (-b_coef - Math.sqrt(discriminant)) / (2 * a);

    const points: Array<PointWithT> = [];
    if (0 <= t1 && t1 <= 1) {
        points.push({
            t: t1,
            point: calculateQuadraticBezierPoint(t1, startPoint, controlPoint, endPoint)
        });
    }
    if (0 <= t2 && t2 <= 1) {
        points.push({
            t: t2,
            point: calculateQuadraticBezierPoint(t2, startPoint, controlPoint, endPoint)
        });
    }

    return points;
}


function parseTimeString(str: string) {
    const hour = parseInt(str.slice(0, 2))
    const minute = parseInt(str.slice(3))
    const date = new Date()
    date.setHours(hour)
    date.setMinutes(minute)
    date.setSeconds(0)
    return date
}


@Component
export struct SunRiseAndSet {
    @Require
    @State
    options?: SunRiseAndSetOptions = undefined
    private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))
    private readonly lineWidth = 1.2
    private readonly lineColor = Color.Gray
    private readonly baselineColor = "#e0e0e0"

    private calTimeRatio(start: string, end: string) {
        const startDate = parseTimeString(start)
        const endDate = parseTimeString(end)

        const now = Date.now()
        // const now = 1720731502337 // 5: 00
        // const now = 1720735102337 // 6:00
        // const now = 1720756702337 // 12:00

        // 在日出前面
        if (now < startDate.getTime()) {
            // 从日出时间的前3个小时开始计算
            const startPre3 = new Date()
            startPre3.setHours(startDate.getHours() - 3)
            startPre3.setMinutes(0)
            startPre3.setSeconds(0)
            if (now < startPre3.getTime()) {
                return -1
            } else {
                return -(startDate.getTime() - now) / (3 * 60 * 60 * 1000)
            }
        } else if (now < endDate.getTime()) {
            // 在日落前面
            const dis = now - startDate.getTime()
            return dis / (endDate.getTime() - startDate.getTime())
        } else {
            // 在日落后三个小时开始计算
            const endAfter3 = new Date()
            endAfter3.setHours(endDate.getHours() + 3)
            endAfter3.setMinutes(0)
            endAfter3.setSeconds(0)
            // 过去了
            if (now > endAfter3.getTime()) {
                return 2
            } else {
                return 1 + (endAfter3.getTime() - now) / (3 * 60 * 60 * 1000)
            }
        }
    }

    private draw() {
        const h = this.context.height
        const w = this.context.width
        const padding = Math.min(h, w) * 0.1

        this.context.lineWidth = this.lineWidth
        this.context.strokeStyle = this.lineColor
        const startPoint = new Point(padding, h / 4 * 3)
        const endPoint = new Point(w - padding, startPoint.y)
        const controlPoint = new Point(w / 2, 0)

        // 绘制曲线
        this.context.beginPath()
        this.context.moveTo(startPoint.x, startPoint.y)
        this.context.quadraticCurveTo(controlPoint.x, controlPoint.y, endPoint.x, endPoint.y)
        this.context.stroke()

        this.context.setLineDash([2, 2])
        this.context.strokeStyle = this.baselineColor

        // 地平线位置
        const baselineY = h / 3 * 2
        this.context.beginPath()
        this.context.moveTo(0, baselineY)
        this.context.lineTo(w, baselineY)
        this.context.stroke()

        // 与地平线相交的两个点
        const intersectionPoints =
            findIntersectionPoints(startPoint, controlPoint, endPoint, 0, h / 3 * 2).sort((a, b) => {
                return a.t - b.t
            });


        // 前部分的t
        const preT = intersectionPoints[0].t
        // 后部分的t
        const aftT = intersectionPoints[1].t
        // 当前时间的比例
        const ratio = this.calTimeRatio(this.options!.sunrise, this.options!.sunset)

        // 日出前，绘制左半侧底部
        if (ratio < 0) {
            const t = (ratio + 1) * preT
            console.log(`pre T: ${t}  ratio: ${ratio}`)
            const p = calculateQuadraticBezierPoint(t, startPoint, controlPoint, endPoint)
            this.drawPoint(p, true)
        } else if (ratio > 1) {
            // 日落后
            const t = aftT + (1 - aftT) * (ratio - 1)
            console.log(`after T: ${t}`)
            const p = calculateQuadraticBezierPoint(t, startPoint, controlPoint, endPoint)
            this.drawPoint(p, true)
        } else {
            // 正中间
            const t = (1 - preT) * ratio + preT
            console.log(`mid T: ${t} ${ratio}}`)
            const p = calculateQuadraticBezierPoint(t, startPoint, controlPoint, endPoint)
            this.drawPoint(p, false)
        }
    }

    private drawPoint(point: Point, dark: boolean) {
        if (dark) {
            this.context.strokeStyle = "#37474f"
        } else {
            this.context.strokeStyle = "#f57c00"
        }
        this.context.beginPath()
        this.context.arc(point.x, point.y, 4, 0, 360)
        this.context.stroke()

        if (dark) {
            this.context.fillStyle = "#37474f"
        } else {
            this.context.fillStyle = "#f57c00"
        }

        this.context.fill()
    }

    build() {
        Canvas(this.context).onReady(() => {
            this.draw()
        })
    }
}


@Component
@Preview
struct SunRiseAndSetPreview {
    build() {

        Column() {
            SunRiseAndSet({
                options: {
                    sunrise: '05:55',
                    sunset: "19:33"
                }
            })
        }
    }
}