import 'package:flutter_apod/common/date_relevant.dart';
import 'package:flutter_apod/interface/i_apod_json_get.dart';
import 'package:flutter_apod/interface/i_json_get.dart';
import 'package:flutter_apod/model/apod_api_data.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/provider/apod_calendar_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<ApodDbData>> _getMonthDataByDbTest(int year, int month) async {
  final List<ApodDbData> list = [
    ApodDbData('2023-01-01', 'title1', 'path1', '', 'image', 'copyright1',
        'explanation1', 0),
    ApodDbData('2023-01-02', 'title2', 'path2', '', 'image', 'copyright2',
        'explanation2', 1),
    ApodDbData('2023-01-03', 'title3', 'path3', '', 'image', 'copyright3',
        'explanation3', 1),
    ApodDbData('2023-01-04', 'title4', 'path4', '', 'image', 'copyright4',
        'explanation4', 1),
    ApodDbData('2023-01-05', 'title5', 'path5', '', 'image', 'copyright5',
        'explanation5', 1),
    ApodDbData('2023-01-06', 'title6', 'path6', '', 'image', 'copyright6',
        'explanation6', 1),
    ApodDbData('2023-01-07', 'title7', 'path7', '', 'image', 'copyright7',
        'explanation7', 0),
    ApodDbData('2023-01-08', 'title8', 'path8', '', 'image', 'copyright8',
        'explanation8', 0),
    ApodDbData('2023-01-09', 'title9', 'path9', '', 'image', 'copyright9',
        'explanation9', 0),
    ApodDbData('2023-01-10', 'title10', '', 'videoUrl', 'video', 'copyright10',
        'explanation10', 1),
  ];

  return list;
}

Future<ApodDbData> _saveApiDataFuncTest(ApodApiData data) async {
  return ApodDbData(data.date, data.title, data.hdurl, data.url, data.mediaType,
      data.copyright, data.explanation, 0);
}

class ApodApiDataGetterTestNormal implements IApodApiDataGet {
  @override
  late IJsonGetter jsonGetter;

  @override
  Future<ApodApiData> getApodTodayData() async {
    return ApodApiData('copyright', '2023-01-01', 'explanation', 'hdurl',
        'image', 'serviceVersion', 'title', 'url', 'thumbnailUrl');
  }

  @override
  Future<List<ApodApiData>> getApodByDateData(
      String startDate, String endDate) async {
    final List<ApodApiData> list = [
      ApodApiData('copyright', '2023-01-01', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-02', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-03', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-04', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-05', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-06', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-07', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-08', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-09', 'explanation', 'hdurl', 'image',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-10', 'explanation', 'hdurl', 'video',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-11', 'explanation', 'hdurl', 'video',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-12', 'explanation', 'hdurl', 'video',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
      ApodApiData('copyright', '2023-01-13', 'explanation', 'hdurl', 'video',
          'serviceVersion', 'title', 'url', 'thumbnailUrl'),
    ];

    return list;
  }
}

class ApodApiDataGetterTestError implements IApodApiDataGet {
  @override
  late IJsonGetter jsonGetter;

  @override
  Future<ApodApiData> getApodTodayData() async {
    return ApodApiData('error', '404', '404', 'error', 'image',
        'serviceVersion', 'title', 'url', 'thumbnailUrl');
  }

  @override
  Future<List<ApodApiData>> getApodByDateData(
      String startDate, String endDate) async {
    final List<ApodApiData> list = [
      ApodApiData('error', 'error', 'error', 'error', 'error', 'error', 'error',
          'error', 'error'),
    ];

    return list;
  }
}

void main() {
  group('apod calendar provider test.', () {
    var calendarProvider = ApodCalendarProvider(_getMonthDataByDbTest,
        _saveApiDataFuncTest, ApodApiDataGetterTestNormal());
    final today = DateTime.now();
    final todayStr = formater.format(today);
    final futureDate = today.add(const Duration(days: 10));
    final futureDateStr = formater.format(futureDate);

    test('checkApiData function input date is past time test ', () {
      final dates = calendarProvider.checkApiDate(['2023-01-01', '2023-01-31']);
      var merge = '${dates[0]}/${dates[1]}';
      expect(merge, '2023-01-01/2023-01-31');
    });
    test('checkApiData function input date is future time test ', () {
      final dates =
          calendarProvider.checkApiDate([futureDateStr, futureDateStr]);
      expect(dates[0], 'error');
    });

    test('checkApiData function input last date is future time test ', () {
      final dates =
          calendarProvider.checkApiDate(['2023-01-01', futureDateStr]);
      var merge = '${dates[0]}/${dates[1]}';
      expect(merge, '2023-01-01/$todayStr');
    });

    test('GoGetMonthData Test ApiData Success', () async {
      calendarProvider.goGetMonthData(2023, 01);
      await Future.delayed(const Duration(seconds: 2)); //等待資料處理完成

      int checkCount = 0;
      final List<String> checkDates = [
        '2023-01-11',
        '2023-01-12',
        '2023-01-13'
      ];

      for (var s in checkDates) {
        if (calendarProvider.apodDataMap.containsKey(s)) checkCount++;
      }

      //apidata為13筆資料，database為10筆資料，會依照日期去比對資料庫裡是否有資料，
      //有的會不會再存入資料庫，所以這裡只會剩3筆資料
      expect(checkCount, 3);
    });

    test('GoGetMonthData Test ApiData 404 Error', () async {
      calendarProvider = ApodCalendarProvider(_getMonthDataByDbTest,
          _saveApiDataFuncTest, ApodApiDataGetterTestError());
      calendarProvider.goGetMonthData(2023, 01);
      await Future.delayed(const Duration(seconds: 1)); //等待資料處理完成

      expect(calendarProvider.apodDataMap.length, 0);
    });
  });
}
