
export class LocationBean {
  /** 城市名称 */
  name: string;
  /** 城市id， location要用的 */
  id: string;
  /** 城市经度 */
  lat: string;
  /** 城市纬度 */
  lon: string;
  /** 上级行政区划名称 */
  adm2: string;
  /** 所属一级形成区域 */
  adm1: string;
  /** 所属国家名称 */
  country: string;
  /** 所处时区 */
  tz: string;
  /** UTC事件偏移的小时数 */
  utcOffset: string;
  /** 是否处于夏令时，1是0否 */
  isDst: string;
  /** 城市属性 */
  type: string;
  /** 地区评分 */
  rank: string;
  /** 该城市的天气预报网页链接 */
  fxLink: string;

  constructor(
    name: string,
    id: string,
    lat: string,
    lon: string,
    adm2: string,
    adm1: string,
    country: string,
    tz: string,
    utcOffset: string,
    isDst: string,
    type: string,
    rank: string,
    fxLink: string
  ) {
    this.name = name;
    this.id = id;
    this.lat = lat;
    this.lon = lon;
    this.adm2 = adm2;
    this.adm1 = adm1;
    this.country = country;
    this.tz = tz;
    this.utcOffset = utcOffset;
    this.isDst = isDst;
    this.type = type;
    this.rank = rank;
    this.fxLink = fxLink;
  }
}