import { fetchCityByLatitudeAndLongitude, fetchRealWeather } from '../network/api';
import { hilog } from '@kit.PerformanceAnalysisKit'
import { RealWeatherResult } from '../network/type';
import { webview } from '@kit.ArkWeb';
import { Prompt } from '@kit.ArkUI';
import EntryAbility from '../entryability/EntryAbility';

@Preview
@Entry
@Component
 struct RealTimeWeather {
  @State res :RealWeatherResult = {
    "code": "200",
    "updateTime": "2024-07-11T00:03+08:00",
    "fxLink": "https://www.qweather.com/weather/guilin-101300501.html",

    "now": {
      "obsTime": "2024-07-11T00:00+08:00",
      "temp": "31",
      "feelsLike": "34",
      "icon": "151",
      "text": "多云",
      "wind360": "147",
      "windDir": "东南风",
      "windScale": "1",
      "windSpeed": "2",
      "humidity": "64",
      "precip": "0.0",
      "pressure": "987",
      "vis": "30",
      "cloud": "91",
      "dew": "26"
    },
    "refer": {
      "sources": [
        "QWeather"
      ],
      "license": [
        "CC BY-SA 4.0"
      ]
    }
  }
@State sunrise:string = '06:33'
  @State sunset:string = '19:33'
   @State  realWeatherResult: RealWeatherResult | null = null;
 @State uvIndex:string = '3'
  build() {
    Row() {
      Column() {

        component4({windDir:this.res.now.windDir,windScale:this.res.now.windScale})
        component5({sunrise:this.sunrise,sunset:this.sunset})
      }
      component6({humidity:this.res.now.humidity,
        feelsLike:this.res.now.feelsLike,
        uvIndex:this.uvIndex,
        presssure:this.res.now.pressure})
    }

    }

  }

@Component
struct component4 {
  @Prop windDir:string
  @Prop windScale:string

  build() {
    Row() {
      Column() {
        Text(this.windDir)
          .fontColor('#fcfdfd')
          .fontSize("15")
          .margin({bottom:2})
        Text(this.windScale+'级')
          .fontSize("15")
          .fontColor('#fcfdfd')
      }
      .margin({ left:10,right:5})
      Image($r('app.media.compass'))
        .width(63)
        .margin({left:18,top:2})
        .borderWidth(0)

    }
    .borderWidth(1)
    .margin(10)
    .borderRadius(20)
    .width("45%")
    .height("11%")
    .backgroundColor('#6788b7')
  }
}
@Component
struct component5 {

  @Prop sunrise:string
  @Prop sunset:string
  build() {
    Row() {
      Row() {
        Column() {
          Text(this.sunrise)
            .fontSize("15")
            .fontColor('#fcfdfd')
            .margin({ bottom: 5 })
          Text(this.sunset)
            .fontColor('#fcfdfd')
            .margin({ bottom: 5 })

        }
        Column() {
          Text('日出')
            .fontSize("14")
            .fontColor('#abbfd8')
            .margin({ bottom: 5 })
            // .margin({right:5})
          Text('日落')
            .fontColor('#abbfd8')
            .fontSize("14")
            .margin({ bottom: 5 })
        }
      }
      .margin({left:15})
      Image($r('app.media.sunset_sunriseImg'))
        .width(60)
        .margin({left:5,top:5})
        .borderWidth(0)
    }
    .borderWidth(1)
    .margin(10)
    .borderRadius(20)
    .width("45%")
    .height("11%")
    .backgroundColor('#6788b7')
  }

}
@Component
struct component6 {
  @Prop humidity:string
  @Prop feelsLike:string
  @Prop uvIndex:string
  @Prop presssure:string

  build() {
    Column() {
      Row(){
        Text("湿度")
          // .margin({right:60,top:20})
          .fontColor('#c5d2e4')
          .fontSize('13')
        Text(this.humidity+'%')
          // .margin({top:23})
          .fontColor('#fcfdfd')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('80%')
      .margin({top:23})
      Divider()
        .strokeWidth(2)
        .color('#6e8fba')
        .margin({top:1})
        .width('80%')
      Row(){
        Text("体感")
          // .margin({right:60,top:20})
          .fontColor('#c5d2e4')
          .fontSize('13')
        Text(this.feelsLike+"°")
          // .margin({top:23})
          .fontColor('#fcfdfd')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('80%')
      .margin({top:23})
      Divider()
        .strokeWidth(2)
        .color('#6e8fba')
        .margin({top:1})
        .width('80%')
      Row(){
        Text("紫外线")
          // .margin({right:60,top:20})
          .fontColor('#c5d2e4')
          .fontSize('13')
        Text(this.uvIndex)
          // .margin({top:23})
          .fontColor('#fcfdfd')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('80%')
      .margin({top:23})
      Divider()
        .strokeWidth(2)
        .color('#6e8fba')
        .margin({top:1})
        .width('80%')
      Row(){
        Text("气压")
          // .margin({right:60,top:20})
          .fontColor('#c5d2e4')
          .fontSize('13')
        Text(this.presssure+'hpa')
          // .margin({top:23})
          .fontColor('#fcfdfd')
          .margin({right:0})

      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('80%')
      .margin({top:23})
      Divider()
        .strokeWidth(2)
        .color('#6e8fba')
        .margin({top:1})
        .width('80%')
    }
    .borderWidth(1)
    .margin({ right:10,left:1.5 })
    .borderRadius(20)
    .width("47%")
    .height("25%")
    .backgroundColor('#6788b7')
  }


}






