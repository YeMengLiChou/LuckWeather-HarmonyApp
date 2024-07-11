export interface MaxMinTemperatureOptions {
    tempMax: number,
    tempMin: number,
    textColor?: string,
}

@Component
export struct MaxAndMinTemperature {
    @State
    @Require
    options?: MaxMinTemperatureOptions = undefined

    build() {
        Row({ space: 4 }) {
            Text(`${this.options!.tempMax}°`)
                .fontColor(this.options?.textColor ?? '#000')
            Text('/').opacity(0.4)
            Text(`${this.options!.tempMin}°`)
                .fontColor(this.options?.textColor ?? '#000')
        }
    }
}