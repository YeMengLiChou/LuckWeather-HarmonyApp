import { IconButton } from '../components/IconButton'
import { fetchForecast7DayWeather, fetchRealWeather } from '../network/api'
import { CityWeather } from './CityWeather'

@Entry
@Component
struct Index {
    @Provide pageStack: NavPathStack = new NavPathStack()
    @State currentIndex: number = 0


    @Builder
    tabBuilder(index: number, name: string) {
        Column() {
            Text(name)
                .fontSize(16)
                .fontColor(this.currentIndex === index ? '#007DFF' : '#182431')
                .fontWeight(this.currentIndex === index ? 500 : 400)
                .id(index.toString())
        }.width('100%')
    }

    build() {
        Navigation(this.pageStack) {
            RelativeContainer() {
                // 添加地区按钮
                Row() {
                    IconButton({
                        options: {
                            iconRes: $r('app.media.icon_add'),
                            iconColor: Color.Black,
                            buttonColor: Color.Transparent
                        }
                    })
                }
                .height(56)
                .padding({ left: 12 })
                .zIndex(5)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignSelf(ItemAlign.Center)
                .alignRules({
                    top: { anchor: '__container__', align: VerticalAlign.Top },
                    left: { anchor: '__container__', align: HorizontalAlign.Start }
                })

                // 主体内容区域
                Tabs({
                    barPosition: BarPosition.Start,
                }) {
                    TabContent() {
                        CityWeather({
                            cityWeatherOptions: {
                                location: '123'
                            }
                        })
                    }
                }
                .barWidth('70%')
                .barMode(BarMode.Scrollable)

            }
            .height('100%')
            .width('100%')

        }
        .hideTitleBar(true)
        .height('100%')
        .width('100%')
    }
}

