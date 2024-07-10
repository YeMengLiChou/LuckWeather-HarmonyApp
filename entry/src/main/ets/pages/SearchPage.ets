import { LocationBean } from '../model/LocationModel'
import { fetchCityInfoByKeyWord } from '../network/api'
import { Location, LocationResult } from '../network/type'
import LocationList from '../viewmodel/LocaotionViewModel'

@Entry
@Component
struct SearchPage {
  build() {
    Column() {
      //1. 标头

      //2.搜索框
      SearchLink()
      //3. 搜索结果列表
    }
    .height('100%')
    .width('100%')
  }
}

/*
 * 标头
 * */
@Component
struct WetherChart {
  build() {

  }
}

/*
 * 搜索框
 * */
@Component
struct SearchLink {
  result?: LocationResult
  @State locations: LocationBean[]=[]

  build() {
    Column() {
      Row() {
        Search({ placeholder: '搜索位置' })
          .width('70%')
          .onSubmit(value => {
            fetchCityInfoByKeyWord(value).then(value1 => {
              console.log('响应结果为：', value1.code)
              this.result = value1
              this.locations = value1.location
            })
            console.log(this.result?.code)
          })
      }
        SearchResult({locations:this.locations})
    }
    .height('100%')
    .alignItems(HorizontalAlign.Center)

  }
}

/*
 * 搜索结果列表
 * */
@Component
struct SearchResult {
  @Prop locations: LocationBean[]

  build() {
    Column() {
      List() {
        ForEach(
          this.locations,
          (item: LocationBean, index: number) => {
            ListItem(){
              Row(){
                Text(`${item.name}-${item.adm2}市-${item.adm1}-${item.country}`)
                Image($r('app.media.icon_add'))
                  .width(20)
                  .height(20)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .card()
          }
        )
      }
      //.alignListItem(ListItemAlign.Center)
      .width('100%')
    }
    .height('100%')
  }
}

/*
 * 城市管理
 * */
@Component
struct CityManager{
  build() {

  }
}


//统一的卡片样式

@Styles
function card() {
  .width('100%')
  .padding(20)
  .backgroundColor(Color.White)
  .borderRadius(15)
  .shadow({
    radius: 0,
    color: '#1F000000',
    offsetX: 2,
    offsetY: 4
  })
}
