import { CityMangerModel2, CityWeatherVO } from '../../model/CityManagerModel2'
import { CityModel } from '../../model/CityModel'
import { distributedKVStore } from '@kit.ArkData'
import { deleteCityRelatedData, getWeatherKvStore, updateCitiesInfo } from '../../utils/WeatherKvStore'


/*
 * 城市管理
 * */
@Component
export struct CityManager {
    @Link dataList: CityMangerModel2[]
    @Link trueDataList: CityWeatherVO[]
    @Link citiesInfo: CityModel[]
    weatherKvStore?: distributedKVStore.DeviceKVStore

    private deleteCity(locationID: string) {
        const index = this.citiesInfo.findIndex((item) => {
            return item.locationID === locationID
        });
        if (index !== -1) {
            this.trueDataList.splice(index, 1)
            this.citiesInfo.splice(index, 1)
            updateCitiesInfo(this.weatherKvStore!, this.citiesInfo)
            deleteCityRelatedData(this.weatherKvStore!, locationID)
        }
    }

    @Builder
    deleteButton(locationID: string) {
        Button() {
            Image($r('app.media.icon_delete'))
                .fillColor(Color.White)
                .width(20)
        }
        .margin({ left: 10, right: 10 })
        .width(40)
        .height(40)
        .type(ButtonType.Circle)
        .role(ButtonRole.ERROR)
        .onClick(() => {
            this.deleteCity(locationID)
        })
    }

    aboutToAppear(): void {
        getWeatherKvStore(getContext(this))
            .then((store) => {
                this.weatherKvStore = store
            })
    }

    build() {
        Column() {
            List({ space: 20 }) {
                ForEach(
                    this.trueDataList,
                    (item: CityWeatherVO) => {
                        ListItem() {
                            Row() {
                                Column() {
                                    Text(item.city.cityName)
                                        .fontColor(Color.White)
                                        .fontSize(22)
                                        .margin({ bottom: 5 })
                                    Text(`${item.data.text}  ${item.data.tempMin}° / ${item.data.tempMax}°`)
                                        .fontColor(Color.White)
                                }
                                .alignItems(HorizontalAlign.Start)

                                Column() {
                                    Text(item.data.temp + '℃')
                                        .foregroundColor(Color.White)
                                        .fontSize(30)
                                }
                            }
                            .cityCard()
                            .justifyContent(FlexAlign.SpaceBetween)
                        }
                        .swipeAction({ end: this.deleteButton(item.city.locationID) })
                        .onClick(() => {
                            // TODO: navigate to main page
                        })
                    }
                )
            }
            .width('100%')
            .height('100%')
            .alignListItem(ListItemAlign.Center)

        }
        .margin({ top: 20 })
        .width('100%')
        .height('100%')
    }
}


//城市管理卡片样式

@Styles
function cityCard() {
    .width('100%')
    .backgroundColor('#a62381d8')
    // .backgroundColor(Color.White)
    .padding(16)
    .borderRadius(14)
    .shadow({
        radius: 4,
        color: '#f0f0f0',
        offsetX: 2,
        offsetY: 4
    })
}


