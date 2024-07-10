import { ForecastWeatherHourResult } from '../network/type'
import { Forecast24HourWeatherViewModel } from '../viewmodel/Forecast24HourWeatherViewModel'
import { HourlyWeatherResult } from '../network/type'


@Component
struct Forecast24HourWetherComponent {
  @State @Require  dataList: HourlyWeatherResult[] = Forecast24HourWeatherViewModel.hourly
  build() {
    Column() {
      Column() {
        //1.标头
        MyHeader()
        //2. 数据
        DateList({dataList:this.dataList})
      }
      .card()
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .backgroundColor(Color.White)
    .height('100%')
    .width('100%')
    .margin({top:10})

  }
}


/*
 * 标头
 * */
@Component
struct MyHeader {
  build() {
    Row() {
      Image($r('app.media.icon_clock'))
        .width(20)
        .fillColor('#a0b5d4')

      Text('24小时预报')
        .margin({ left: 10 })
        .fontColor('#a0b5d4')
    }
    .margin({bottom:15})
  }
}

/*
 * 24小时预报列表
 * */
@Component
struct DateList {
  @Prop dataList: HourlyWeatherResult[]

  build() {
    Column() {
      List() {
        ForEach(
          this.dataList,
          (item: HourlyWeatherResult, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.temp + "°")
                    .fontWeight(FontWeight.Bold)
                    .fontSize(22)
                    .fontColor('#f8ffffff')
                }


                Column({ space: 10 }) {
                  Text(item.windScale + '级')
                    .fontSize(13)
                    .fontColor('#ffffff')
                  Text(item.text)
                    .textAlign(TextAlign.Center)
                    .fontColor('#ffffff')
                    .width(25)
                    .height(25)
                    .padding(1)
                    .backgroundColor('#7e99c4')
                    .borderRadius(5)

                  Text(new Date(item.fxTime).getHours().toString() + ':00')
                    .fontSize(12)
                    .fontColor('#c3d2ea')
                }

              }
              .justifyContent(FlexAlign.SpaceBetween)
              .height('100%')
              .margin({ right: 20 })
            }
          }
        )
      }
      .listDirection(Axis.Horizontal)
      .height('20%')
    }
  }
}

//城市管理卡片样式

@Styles
function card() {
  .width('95%')
  .padding(20)
  .backgroundColor('#6585b8')
  //.opacity(0.4)
  .borderRadius(15)
  .shadow({
    radius: 10,
    color: '#666666',
    offsetX: 2,
    offsetY: 4
  })
}