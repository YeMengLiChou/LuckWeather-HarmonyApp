export interface CityModel {
    /** 城市名字 */
    cityName: string,

    /** id */
    locationID: string,

    /** 所属省份 */
    provinceName: string,

    /** 经度 */
    longitude: number,

    /** 纬度 */
    latitude: number,

    /** 定位城市 */
    isLocationCity: boolean

    createTimestamp:string
}