import  { Forecast3DWeatherDayResult } from  '../../viewmodel/Fetch3dayViewmodel'
import { DailyWeatherResult } from '../../network/type'
import router from '@ohos.router';
@Entry
@Component

  //主页面中的显示近3天天气
struct Fetch3dayWeather {
  @State @Require  dataList: DailyWeatherResult[] = Forecast3DWeatherDayResult.daily
  build() {
    Column(){
      Column(){
        days({dataList:this.dataList})
        //点击按钮进入详细查看7天天气
        Button("查看近7日天气")
          .width("80%")
          .height("40")
          .margin({top:40})
          .backgroundColor("#50FFFFFF")
          // .onClick(()=>{
          //   router.pushUrl({
          //     url:'./Nearly7day'
          //   })
          // })
      }
      .borderRadius(20)
      .width('90%')
      .backgroundColor('#300066cc')
      .height(250)
    }
    .width('100%')
  }

}
@Component
struct  days{
  @Prop dataList:DailyWeatherResult[]
  build() {
    Row(){
      List(){
        ForEach(
          this.dataList,
          (item:DailyWeatherResult,index:number) =>{
            if (index<3)
            ListItem(){
              Row() {
                Image(this.getImageForWeather(item.textDay))
                  .width(20)
                  .margin({left:10})
                Text(new Date(item.fxDate).getMonth()
                  +'月'+new Date(item.fxDate).getDate()
                  +'日'
                  + '  '
                  + item.textDay)
                  .width(120)
                  .margin({left:2})
                  .fontColor('#FFFFFF')
                Text("优")
                  .padding(4)
                  .fontColor('#FFFFFF')
                  .borderRadius(5)
                  .backgroundColor("#30FFFFFF")
                Text(item.tempMax + '℃/' + item.tempMin + '℃')
                  .fontColor('#FFFFFF')
              }
              .width(280)
              .margin({ top: 20 })
              .justifyContent(FlexAlign.SpaceBetween)
            }
          })
      }

    }
  }
  private getImageForWeather(weather: string): Resource {
    switch (weather) {
      case '多云':
        return  $r('app.media.qweather_icon_9998');
      case '雨天':
        return $r('app.media.qweather_icon_2426');
      case '晴天':
        return  $r('app.media.qweather_icon_2424');
      case '雷阵雨':
        return  $r('app.media.qweather_icon_2381');
      default:
        return  $r('app.media.qweather_icon_qweather_fill');
    }
  }
}


