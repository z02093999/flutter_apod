import 'i_json_get.dart';
import 'package:flutter_apod/model/apod_api_data.dart';

class IApodApiDataGet {
  late IJsonGetter jsonGetter;

  Future<ApodApiData> getApodTodayData() async {
    return ApodApiData('copyright', 'date', 'explanation', 'hdurl', 'mediaType',
        'serviceVersion', 'title', 'url', 'thumburl');
  }

  Future<List<ApodApiData>> getApodByDateData(
      String startDate, String endDate) async {
    return [];
  }
}
