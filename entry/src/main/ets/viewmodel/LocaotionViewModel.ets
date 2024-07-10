import {LocationBean} from  '../model/LocationModel'

export class LocationList{
  getDataList(){
    let array:LocationBean[]=[]
    array.push(
      new LocationBean(
        '北京',
        '101010100',
        '39.9042',
        '116.4074',
        '北京',
        '北京',
        '中国',
        'Asia/Shanghai',
        '8',
        '0',
        '',
        '',
        'https://www.example.com/city/beijing'
      )
    );

    array.push(
      new LocationBean(
        '上海',
        '101020100',
        '31.2304',
        '121.4737',
        '上海',
        '上海',
        '中国',
        'Asia/Shanghai',
        '8',
        '0',
        '',
        '',
        'https://www.example.com/city/shanghai'
      )
    );

    array.push(
      new LocationBean(
        '广州',
        '101280101',
        '23.1291',
        '113.2644',
        '广东',
        '广东',
        '中国',
        'Asia/Shanghai',
        '8',
        '0',
        '',
        '',
        'https://www.example.com/city/guangzhou'
      )
    );

    array.push(
      new LocationBean(
        '深圳',
        '101280601',
        '22.5431',
        '114.0579',
        '广东',
        '广东',
        '中国',
        'Asia/Shanghai',
        '8',
        '0',
        '',
        '',
        'https://www.example.com/city/shenzhen'
      )
    );


    return array
  }
}

export default new LocationList()