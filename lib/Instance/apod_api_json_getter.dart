import 'dart:convert';
import 'package:flutter_apod/interface/i_json_get.dart';
import 'package:http/http.dart' as http;
import "package:flutter_apod/model/apod_api_data.dart";

///實作Json Get方法
class ApodApiJsonGetter implements IJsonGetter {
  @override

  ///APOD API Parameter：
  ///Parameter；Type；Default；Description
  ///date；YYYY-MM-DD；today；The date of the APOD image to retrieve
  ///start_date；YYYY-MM-DD；none；The start of a date range, when requesting date for a range of dates. Cannot be used with date.
  ///end_date；YYYY-MM-DD；today；The end of the date range, when used with start_date.
  ///count；int；none；If this is specified then count randomly chosen images will be returned. Cannot be used with date or start_date and end_date.
  ///thumbs；bool；False；Return the URL of video thumbnail. If an APOD is not a video, this parameter is ignored.
  ///api_key；string；DEMO_KEY；api.nasa.gov key for expanded usage
  Future<List<Map<String, dynamic>>> getJson(
      http.Client client, List<String> parameter, List<String> value) async {
    String paraMerge = '';
    for (int i = 0; i < parameter.length; i++) {
      paraMerge += ('${parameter[i]}=${value[i]}');
      if (i < parameter.length - 1) paraMerge += '&';
    }

    Uri apiUrl = Uri.parse('$apodApiUrl?$paraMerge');
    final response = await client.get(apiUrl, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    });

    switch (response.statusCode) {
      case 200:
        final map = jsonDecode(response.body);

        if (map.runtimeType.toString() == '_Map<String, dynamic>') {
          return [map];
        } else {
          List<Map<String, dynamic>> result = [];

          for (Map<String, dynamic> m in map) {
            result.add(m);
          }

          return result;
        }
      default:
        var errorMap = <String, dynamic>{};
        errorMap.putIfAbsent(
            "HTTP Status Code：${response.statusCode}", () => response.body);
        return [errorMap];
    }
  }
}
