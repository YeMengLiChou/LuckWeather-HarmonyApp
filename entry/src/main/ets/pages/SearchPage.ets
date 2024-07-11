import { LocationBean } from '../model/LocationModel'
import { fetchCityInfoByKeyWord,fetchRealWeather,fetchForecast7DayWeather } from '../network/api'
import { Location, LocationResult } from '../network/type'
import LocationList from '../viewmodel/LocaotionViewModel'
import { CityManagerList } from '../viewmodel/CityManagerViewModel'
import { CityMangerModel2, CityWeatherVO, WeatherData } from '../model/CityManagerModel2'
import  {getWeatherKvStore} from  '../utils/WeatherKvStore'
import { distributedKVStore } from '@kit.ArkData'
import { getDeviceKVStore } from '../common/kvstore'
import { KEY_CITIES_INFO, KEY_CURRENT_CITY_INFO } from '../common/constants'
import { CityModel } from '../model/CityModel'
import { BusinessError } from '@kit.BasicServicesKit'

@Builder
export function SearchPageBuilder() {
  SearchPage()
}



@Entry
@Component
struct SearchPage {
  @Provide pageStack: NavPathStack = new NavPathStack()
  @State dataList:CityMangerModel2[]=CityManagerList //测试本地数据

  @State tureDataList:CityWeatherVO[]=[]    //真实的从主页获取来的数据

   weatherKvStore?:distributedKVStore.DeviceKVStore
  @State citiesInfo:CityModel[]=[]
  @State citiesData:WeatherData[]=[]
  aboutToAppear(): void {
    getWeatherKvStore(getContext(this))
      .then((store)=>{
        this.weatherKvStore=store
        //从本地获取 citiesInfo
        this.loadCitiesInfoFromKvStore()
        //TODO 从主界面获取citiesData
        //this.citiesData=
        this.citiesData.forEach(dataItem=>{
          this.citiesInfo.forEach(infoItem=>{
            if(dataItem.locationID === infoItem.locationID){
              this.tureDataList.push(
                {
                  city:infoItem,
                  data: dataItem
                }
              )
            }
          })
        })

      })
  }
  build() {
    NavDestination() {
      Column() {

        //1..搜索框
        SearchLink({dataList:this.dataList,tureDataList:this.tureDataList,citiesInfo:this.citiesInfo})
        //2.. 城市管理列表
        //CityManager()
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .width('100%')
    .onReady((context) => {
      this.pageStack = context.pathStack
    })
    .title('城市管理')

    // .hideTitleBar(true)
  }

  /*
   * 从本地数据库加载城市信息
   * */
  private loadCitiesInfoFromKvStore(){
    this.weatherKvStore!.get(KEY_CURRENT_CITY_INFO)
      .then((res)=>{
        const citiesInfo = JSON.parse(res as string) as CityModel[]
        this.citiesInfo.push(...citiesInfo)
      })
      .catch((err:BusinessError)=>{
        console.log('错误码：'+err.code)
        console.log('错误信息：'+err.message)
      })
  }
}

//
//   /*
//    * 标头
//    * */
//   @Component
//   struct
//   MyHeader
//   {
//   build() {
//
//     Row() {
//
//       Image($r('app.media.icon_back'))
//         .height(40)
//
//       Text('城市管理')
//         .fontSize(30)
//
//     }
//     .width('100%')
//
//   }
// }


/*
 * 搜索
 * */
@Component
struct SearchLink {
  result?: LocationResult
  @State locations: Location[] = []
  @State isShow: boolean = false
  @Link dataList:CityMangerModel2[]
  @Link tureDataList:CityWeatherVO[]
  @Link citiesInfo:CityModel[]
  private searchDebounceId = -1

  build() {
    Column() {
      //搜索框
      Row() {
        Search({ placeholder: '搜索位置' })
          .width('70%')
          .onChange(value => {
            if (value) {
              console.log(value);
              if (this.searchDebounceId != -1) {
                clearTimeout(this.searchDebounceId)
              }
              this.searchDebounceId = setTimeout(() => {
                fetchCityInfoByKeyWord(value).then(value1 => {
                  console.log('响应结果为：', value1.code)
                  this.result = value1
                  this.locations = value1.location
                  this.isShow = true
                })
              }, 300)

            } else {
              clearTimeout(this.searchDebounceId)
              this.searchDebounceId = -1
              this.isShow = false
            }
            console.log(this.result?.code)
          })
      }

      //搜索结果列表
      Stack() {
        CityManager({dataList:this.dataList,trueDataList:this.tureDataList,citiesInfo:this.citiesInfo})
        if (this.isShow) {
          SearchResult({ locations: this.locations ,dataList:this.dataList,tureDataList:this.tureDataList,citiesInfo:this.citiesInfo})
        }
      }

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
  @Link locations: Location[]
  @Link dataList:CityMangerModel2[]
  @Link tureDataList:CityWeatherVO[]
  @Link citiesInfo:CityModel[]
  weatherKvStore?:distributedKVStore.DeviceKVStore
  aboutToAppear(): void {
    getWeatherKvStore(getContext(this))
      .then((store)=>{
        this.weatherKvStore=store
      })
  }
  build() {
    Column() {
      List() {
        ForEach(
          this.locations,
          (item: Location, index: number) => {
            ListItem() {
              Row() {
                Text(`${item.name}-${item.adm2}市-${item.adm1}-${item.country}`)
                Image($r('app.media.icon_add'))
                  .width(20)
                  .height(20)
                  .onClick(()=>{
                    fetchRealWeather(item.id).then(value1=>{
                      fetchForecast7DayWeather(item.id).then(value2=>{

                        //更新VO数组
                        this.tureDataList.push(
                          {
                            city:
                            {
                            cityName:item.name,
                            locationID:item.id,
                            provinceName:item.adm1,
                            longitude:parseFloat(item.lon),
                            latitude:parseFloat(item.lat),
                            isLocationCity:false,
                            createTimestamp:new Date(Date.now()).toString()
                          },
                            data:
                            {
                            cityName:item.name,
                            temp:value1.now.temp,
                            text:value1.now.text,
                            tempMin:value2.daily[0].tempMin,
                            tempMax: value2.daily[0].tempMax,
                            locationID:value1.code
                          }
                          }

                        )
                        // 更新citiesInfo数组
                        this.citiesInfo.push({
                          cityName:item.name,
                          locationID:item.id,
                          provinceName:item.adm1,
                          longitude:parseFloat(item.lon),
                          latitude:parseFloat(item.lat),
                          isLocationCity:false,
                          createTimestamp:new Date(Date.now()).toString()
                        })
                      })
                    })

                    //新增信息后更新本地数据库
                    this.weatherKvStore?.put(KEY_CITIES_INFO,JSON.stringify(this.citiesInfo))
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

            }
            .searchCard()

          }
        )
      }
      .height('100%')
      //.alignListItem(ListItemAlign.Center)
      .width('100%')
    }
    .backgroundColor(Color.White)
    .height('100%')
  }


}

/*
 * 城市管理
 * */
@Component
struct CityManager {
  @Link dataList:CityMangerModel2[]
  @Link trueDataList:CityWeatherVO[]
  @Link citiesInfo:CityModel[]
  weatherKvStore?:distributedKVStore.DeviceKVStore
  aboutToAppear(): void {
    getWeatherKvStore(getContext(this))
      .then((store)=>{
        this.weatherKvStore=store
      })
  }
  build() {
    Column() {
      List({ space: 20 }) {
        ForEach(
          this.trueDataList,
          (item: CityWeatherVO, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.data.cityName)
                    .fontColor(Color.White)
                    .fontSize(22)
                    .margin({ bottom: 5 })
                  Text(`${item.data.text}  ${item.data.tempMin}℃/${item.data.tempMax}℃`)
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
            .swipeAction({ end: this.deleteButton(index) })
          }
        )
      }
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)

    }
    .margin({ top: 20 })
  }

  @Builder
  deleteButton(index: number) {
    Button() {
      Image($r('app.media.icon_delete'))
        .fillColor(Color.White)
        .width(20)
    }
    .margin({left:10,right:10})
    .width(40)
    .height(40)
    .type(ButtonType.Circle)
    .backgroundColor(Color.Red)
    .onClick(() => {
      this.trueDataList.splice(index, 1)
      // 删除一条数据后更新本地数据库
      this.weatherKvStore?.put(KEY_CITIES_INFO,JSON.stringify(this.citiesInfo))
    })
  }
}


//搜索结果卡片样式

@Styles
function searchCard() {
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

//城市管理卡片样式

@Styles
function cityCard() {
  .width('90%')
  .padding(20)
  .backgroundColor('#a62381d8')
  .borderRadius(15)
  .shadow({
    radius: 10,
    color: '#666666',
    offsetX: 2,
    offsetY: 4
  })
}



