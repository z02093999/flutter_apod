import 'package:flutter_apod/interface/i_json_get.dart';
import 'package:flutter_apod/Instance/apod_api_data_get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_apod/model/apod_api_data.dart';

class ApodApiJsonTester200 implements IJsonGetter {
  @override
  Future<List<Map<String, dynamic>>> getJson(
      http.Client client, List<String> parameter, List<String> value) async {
    return [
      {
        'copyright': 'copyright',
        'date': 'date',
        'explanation': 'explanation',
        'hdurl': 'hdurl',
        'media_type': 'mediaType',
        'service_version': 'serviceVersion',
        'title': 'title',
        'url': 'url'
      }
    ];
  }
}

class ApodApiJsonTester200ByDate implements IJsonGetter {
  @override
  Future<List<Map<String, dynamic>>> getJson(
      http.Client client, List<String> parameter, List<String> value) async {
    return [
      {
        'copyright': 'copyright',
        'date': 'date',
        'explanation': 'explanation',
        'hdurl': 'hdurl',
        'media_type': 'mediaType',
        'service_version': 'serviceVersion',
        'title': 'title',
        'url': 'url'
      },
      {
        'copyright': 'copyright',
        'date': 'date',
        'explanation': 'explanation',
        'hdurl': 'hdurl',
        'media_type': 'mediaType',
        'service_version': 'serviceVersion',
        'title': 'title',
        'url': 'url'
      },
    ];
  }
}

class ApodApiJsonTester200Error implements IJsonGetter {
  @override
  Future<List<Map<String, dynamic>>> getJson(
      http.Client client, List<String> parameter, List<String> value) async {
    return [
      {
        'error': {'code': 'api', 'message': 'api not found'}
      }
    ];
  }
}

class ApodApiJsonTester404 implements IJsonGetter {
  @override
  Future<List<Map<String, dynamic>>> getJson(
      http.Client client, List<String> parameter, List<String> value) async {
    return [
      {'404': 'Not Found'}
    ];
  }
}

void main() {
  group('ApodApiDataProvider Test', () {
    //today
    test('test ApodApiDataProvider GetApodTodayData Successfully', () async {
      final provider = ApodApiDataGet(ApodApiJsonTester200());
      ApodApiData data = await provider.getApodTodayData();
      expect(data, isA<ApodApiData>());
    });

    test(
        'test ApodApiDataProvider GetApodTodayData Successfully Return API Error',
        () async {
      final provider = ApodApiDataGet(ApodApiJsonTester200Error());
      ApodApiData data = await provider.getApodTodayData();
      expect(data, isA<ApodApiData>());
    });

    test('test ApodApiDataProvider GetApodTodayData Other Error', () async {
      final provider = ApodApiDataGet(ApodApiJsonTester404());
      ApodApiData data = await provider.getApodTodayData();
      expect(data, isA<ApodApiData>());
    });

    //byDate
    String startDate = '2023-01-01';
    String endDate = '2023-01-31';
    test('test ApodApiDataProvider GetApodByDateData Successfully', () async {
      final provider = ApodApiDataGet(ApodApiJsonTester200ByDate());
      List<ApodApiData> datas =
          await provider.getApodByDateData(startDate, endDate);
      expect(datas, isA<List<ApodApiData>>());
    });

    test(
        'test ApodApiDataProvider GetApodByDateData Successfully Return API Error',
        () async {
      final provider = ApodApiDataGet(ApodApiJsonTester200Error());
      List<ApodApiData> datas =
          await provider.getApodByDateData(startDate, endDate);
      expect(datas, isA<List<ApodApiData>>());
    });

    test('test ApodApiDataProvider GetApodByDateData Other Error', () async {
      final provider = ApodApiDataGet(ApodApiJsonTester404());
      List<ApodApiData> datas =
          await provider.getApodByDateData(startDate, endDate);
      expect(datas[0].title, '404');
    });
  });
}
