export interface CityWeatherOptions {
    location: string,
}

/**
 * 城市天气的主要组件
 * */
@Component
export struct CityWeather {
    @Prop cityWeatherOptions: CityWeatherOptions
    mock: number[] = []

    aboutToAppear(): void {
        for (let i = 0; i < 100; i++) {
            this.mock.push(i)
        }
    }

    build() {
        Scroll() {
            Column() {
                ForEach(this.mock, (item: number) => {
                    Text(`${item}`)
                })
            }
        }
        .height('100%')
        .width('100%')
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)

    }
}