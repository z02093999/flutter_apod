import 'package:flutter_apod/common/api_json_key.dart' as jsonKey;
import 'package:flutter_apod/interface/i_apod_json_get.dart';
import 'package:flutter_apod/model/apod_api_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_apod/interface/i_json_get.dart';
import 'package:flutter_apod/common/apod_api_key.dart';

///
///實作apod api data get
///
class ApodApiDataGet implements IApodApiDataGet {
  //介面注入 json getter
  @override
  IJsonGetter jsonGetter;

  ApodApiDataGet(this.jsonGetter);

  ApodApiData? _errorDataGetter(List<Map<String, dynamic>> maps) {
    if (maps[0].containsKey('error')) {
      //api error
      String errMsg =
          'Code：${maps[0]['error']['code']}\nMessage：${maps[0]['error']['message']}';
      return ApodApiData('error', 'error', errMsg, 'error', 'error', 'error',
          'error', 'error', 'error');
    } else if (!maps[0].containsKey('title')) {
      // responsed error
      return ApodApiData('error', 'error', maps[0].values.first as String,
          'error', 'error', 'error', maps[0].keys.first, 'error', 'error');
    }
    return null;
  }

  ApodApiData _jsonToApodApiData(Map<String, dynamic> parsedMap) {
    ApodApiData apodData;
    if (parsedMap[jsonKey.mediaType] == 'video') {
      if (parsedMap.containsKey('copyright')) {
        apodData = ApodApiData(
            parsedMap[jsonKey.copyright],
            parsedMap[jsonKey.date],
            parsedMap[jsonKey.explanation],
            '',
            parsedMap[jsonKey.mediaType],
            parsedMap[jsonKey.serviceVersion],
            parsedMap[jsonKey.title],
            parsedMap[jsonKey.url],
            parsedMap[jsonKey.thumbnailUrl]);
      } else {
        apodData = ApodApiData(
            '',
            parsedMap[jsonKey.date],
            parsedMap[jsonKey.explanation],
            '',
            parsedMap[jsonKey.mediaType],
            parsedMap[jsonKey.serviceVersion],
            parsedMap[jsonKey.title],
            parsedMap[jsonKey.url],
            parsedMap[jsonKey.thumbnailUrl]);
      }
    } else {
      if (parsedMap.containsKey('copyright')) {
        apodData = ApodApiData(
            parsedMap[jsonKey.copyright],
            parsedMap[jsonKey.date],
            parsedMap[jsonKey.explanation],
            parsedMap[jsonKey.hdurl],
            parsedMap[jsonKey.mediaType],
            parsedMap[jsonKey.serviceVersion],
            parsedMap[jsonKey.title],
            parsedMap[jsonKey.url],
            '');
      } else {
        apodData = ApodApiData(
            '',
            parsedMap[jsonKey.date],
            parsedMap[jsonKey.explanation],
            parsedMap[jsonKey.hdurl],
            parsedMap[jsonKey.mediaType],
            parsedMap[jsonKey.serviceVersion],
            parsedMap[jsonKey.title],
            parsedMap[jsonKey.url],
            '');
      }
    }
    return apodData;
  }

  ///取得當日APOD
  @override
  Future<ApodApiData> getApodTodayData() async {
    ApodApiData apodData;
    final parsedMap = await jsonGetter
        .getJson(http.Client(), ['thumbs', 'api_key'], ['true', apodApiKey]);

    final ApodApiData? errorData = _errorDataGetter(parsedMap);

    if (errorData == null) {
      apodData = _jsonToApodApiData(parsedMap[0]);
    } else {
      apodData = errorData;
    }
    return apodData;
  }

  ///取得APOD,依日期
  @override
  Future<List<ApodApiData>> getApodByDateData(
      String startDate, String endDate) async {
    List<ApodApiData> datas = [];
    final parsedMap = await jsonGetter.getJson(
        http.Client(),
        ['thumbs', 'start_date', 'end_date', 'api_key'],
        ['true', startDate, endDate, apodApiKey]);

    final ApodApiData? errorData = _errorDataGetter(parsedMap);

    if (errorData == null) {
      for (var element in parsedMap) {
        if (element.containsKey('copyright')) {
          datas.add(_jsonToApodApiData(element));
        } else {
          datas.add(_jsonToApodApiData(element));
        }
      }
    } else {
      datas.add(errorData);
    }

    return datas;
  }
}
