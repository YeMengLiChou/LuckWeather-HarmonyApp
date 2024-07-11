/**
 * 查询城市信息参数
 * */
export interface LocationParam {
  /** 查询信息：经纬度lat,lon、  locationID、 文字（拼音） */
  location: string,
  key: string,

  /** 上级行政划分，拼音 */
  adm?: string,

  /** 返回数量，默认为10， 1-20 */
  number?: number,

  /** 搜索范围，默认为搜索所有城市，可以设置为cn仅搜索国内 */
  range?: string,
}

/**
 * 城市信息结果
 * */
export interface LocationResult {
  code: string;
  location: Location[];
  refer: Refer;
}

export interface Location {
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
}


export interface Refer {
  sources: string[],
  license: string[],
}


/** 天气API请求参数 */
export interface WeatherParam {
  key: string,
  location: string
}


/** 实时天气响应类型 */
export interface RealWeatherResult {
  code: string,

  /**
   * 最近更新时间
   * */
  updateTime: Date,

  /** 当前数据的响应式页面 */
  fxLink: string,
  now: {
    /** 数据观测时间 */
    obsTime: string,
    /** 温度，默认单位摄氏度 */
    temp: string,
    /** 体感温度 */
    feelsLike: string,
    /** 图标代码 */
    icon: string,
    /** 天气描述 */
    text: string,
    /** 风向360角 */
    wind360: string,
    /** 风向 */
    windDir: string,
    /** 风力等级 */
    windScale: string,
    /** 风速 km/h */
    windSpeed: string,
    /** 湿度 % */
    humidity: string,
    /** 当前小时累计降水量，mm */
    precip: string,
    /** 大气压强，百帕 */
    pressure: string,
    /** 能见度， km */
    vis: string,
    /** 云量，百分比，可能为空 */
    cloud?: string,
    /** 露点温度，可能为空 */
    dew?: string,
  },
  refer: Refer
}


export interface DailyWeatherResult {
  /** 预测日期 */
  fxDate: Date;

  /** 日出时间，高纬度地区可能为空 */
  sunrise?: string;

  /** 日落时间，高纬度地区可能为空 */
  sunset?: string;

  /** 当天月升时间，可能为空 */
  moonrise?: string;

  /** 当前月落时间，可能为空 */
  moonset?: string;

  /** 月相名称 */
  moonPhase: string;

  /** 月相图标代码 */
  moonPhaseIcon: string;

  /** 当天最高温度 */
  tempMax: string;

  /** 当天最低温度 */
  tempMin: string;

  /** 白天图标代码 */
  iconDay: string;

  /** 白天天气状况描述 */
  textDay: string;

  /** 夜间图标代码 */
  iconNight: string;

  /** 夜间天气状况描述 */
  textNight: string;

  /** 白天风向360角度 */
  wind360Day: string;

  /** 白天风向 */
  windDirDay: string;

  /** 白天风力 */
  windScaleDay: string;

  /** 白天风速 */
  windSpeedDay: string;

  /** 夜间风向360角度 */
  wind360Night: string;

  /** 夜间风向 */
  windDirNight: string;

  /** 夜间风力 */
  windScaleNight: string;

  /** 夜间风速 */
  windSpeedNight: string;

  /** 湿度 */
  humidity: string;

  /** 当天降水量 */
  precip: string;

  /** 大气压强 */
  pressure: string;

  /** 能见度 */
  vis: string;

  /** 云量 */
  cloud?: string;

  /** 紫外线强度 */
  uvIndex: string;
}


export interface ForecastWeatherDayResult {
  code: string;
  updateTime: string;
  fxLink: string;
  daily: DailyWeatherResult[];
  refer: Refer;
}


export interface ForecastWeatherHourResult {
  code: string;
  updateTime: string;
  fxLink: string;
  hourly: HourlyWeatherResult[];
  refer: Refer;
}

export interface HourlyWeatherResult {
  fxTime: string;
  temp: string;
  icon: string;
  text: string;
  wind360: string;
  windDir: string;
  windScale: string;
  windSpeed: string;
  humidity: string;
  pop: string;
  precip: string;
  pressure: string;
  cloud: string;
  dew: string;
}
