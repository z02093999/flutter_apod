import 'package:flutter/foundation.dart';
import 'package:flutter_apod/Instance/apod_database_method.dart';
import 'package:flutter_apod/Instance/picture_saver.dart';
import 'package:flutter_apod/interface/i_database_sql.dart';
import 'package:flutter_apod/interface/i_json_get.dart';
import 'package:flutter_apod/interface/i_picture_saver.dart';
import 'package:flutter_apod/model/apod_api_data.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_apod/interface/i_database_method.dart';
import 'package:flutter_apod/Instance/apod_api_json_getter.dart';
import 'package:flutter_apod/interface/i_apod_json_get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart';

class ApodApiImageDataGetSuccessTest implements IApodApiDataGet {
  @override
  IJsonGetter jsonGetter;

  ApodApiImageDataGetSuccessTest(this.jsonGetter);

  @override
  Future<ApodApiData> getApodTodayData() async {
    return ApodApiData(
        'copyright',
        '2023-01-26',
        'explanation',
        'https://apod.nasa.gov/apod/image/2304/MoonArc_zanarello_1365.jpg',
        'image',
        'v1',
        'title',
        'https://apod.nasa.gov/apod/image/2304/MoonArc_zanarello_1365.jpg',
        '');
  }

  @override
  Future<List<ApodApiData>> getApodByDateData(
      String startDate, String endDate) async {
    return [
      ApodApiData(
          'copyright',
          '2023-01-26',
          'explanation',
          'https://apod.nasa.gov/apod/image/2304/MoonArc_zanarello_1365.jpg',
          'image',
          'v1',
          'title',
          'https://apod.nasa.gov/apod/image/2304/MoonArc_zanarello_1365.jpg',
          '')
    ];
  }
}

class ApodApiVideoDataGetSuccessTest implements IApodApiDataGet {
  @override
  IJsonGetter jsonGetter;

  ApodApiVideoDataGetSuccessTest(this.jsonGetter);

  @override
  Future<ApodApiData> getApodTodayData() async {
    return ApodApiData(
        'copyright',
        '2023-01-26',
        'explanation',
        '',
        'video',
        'v1',
        'title',
        'https://www.youtube.com/embed/wfzz8FUD4TM?rel=0',
        'https://img.youtube.com/vi/wfzz8FUD4TM/0.jpg');
  }

  @override
  Future<List<ApodApiData>> getApodByDateData(
      String startDate, String endDate) async {
    return [
      ApodApiData(
          'copyright',
          '2023-01-26',
          'explanation',
          '',
          'video',
          'v1',
          'title',
          'https://www.youtube.com/embed/wfzz8FUD4TM?rel=0',
          'https://img.youtube.com/vi/wfzz8FUD4TM/0.jpg')
    ];
  }
}

class ApodApiDataGetErrorTest implements IApodApiDataGet {
  @override
  IJsonGetter jsonGetter;

  ApodApiDataGetErrorTest(this.jsonGetter);

  @override
  Future<ApodApiData> getApodTodayData() async {
    return ApodApiData('error', 'error', 'error', 'error', 'error', 'error',
        'error', 'error', 'error');
  }

  @override
  Future<List<ApodApiData>> getApodByDateData(
      String startDate, String endDate) async {
    return [
      ApodApiData(
          'copyright',
          '2023-01-26',
          'explanation',
          'https://apod.nasa.gov/apod/image/2304/MoonArc_zanarello_1365.jpg',
          'image',
          'v1',
          'title',
          'https://apod.nasa.gov/apod/image/2304/MoonArc_zanarello_1365.jpg',
          '')
    ];
  }
}

class ApodDbSqlCmdDataHaveTest implements IApodDbSqlCmd {
  @override
  IDatabaseMethod dbMethod;
  ApodDbSqlCmdDataHaveTest(this.dbMethod);

  @override
  Future<void> closeDB() async {}

  @override
  Future<void> insert(ApodDbData data) async {}

  @override
  Future<void> openDB() async {}

  @override
  Future<List<ApodDbData>> selectByDate(
      String startDate, String endDate) async {
    return [
      ApodDbData(startDate, 'test', 'path', 'videoUrl', 'image', 'copyright',
          'explanation', 0),
      ApodDbData(endDate, 'test', 'path', 'videoUrl', 'image', 'copyright',
          'explanation', 0)
    ];
  }

  @override
  Future<List<ApodDbData>> selectByFavorite() async {
    return [
      ApodDbData('2023_01_01', 'test', 'path', 'videoUrl', 'image', 'copyright',
          'explanation', 1)
    ];
  }

  @override
  Future<int> update(ApodDbData data) {
    throw UnimplementedError();
  }
}

class ApodDbSqlCmdNoDataTest implements IApodDbSqlCmd {
  @override
  IDatabaseMethod dbMethod;
  ApodDbSqlCmdNoDataTest(this.dbMethod);

  @override
  Future<void> closeDB() async {}

  @override
  Future<void> insert(ApodDbData data) async {}

  @override
  Future<void> openDB() async {}

  @override
  Future<List<ApodDbData>> selectByDate(
      String startDate, String endDate) async {
    return [];
  }

  @override
  Future<List<ApodDbData>> selectByFavorite() async {
    return [];
  }

  @override
  Future<int> update(ApodDbData data) {
    throw UnimplementedError();
  }
}

class PictureSaverTest implements IPictureSaver {
  @override
  Future<void> save(String filePathWithName, Uint8List bytes) async {}
}

///取得圖片存儲路徑Test Function
///需自行替換路徑
Future<String> getPictureSavePathTest(String todayStr, String subFolder) async {
  const folder = 'C:\\Users\\TOPVME\\Documents';
  final filePath = join(folder, 'images', subFolder, '$todayStr.jpg');
  return filePath;
}

Future<Response> getPicture404Test(String path) async {
  return http.Response("Not Found", 404);
}

Future<Response> getPictureTest(String path) async {
  return http.Response("test", 200);
}

Future<Uint8List> compressPictureToSmallTest(Uint8List pic) async {
  return Uint8List(0);
}

void main() {
  group('ApodDataProvider Test', () {
    test('Get Today Data Test By Database', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiImageDataGetSuccessTest(ApodApiJsonGetter()),
          ApodDbSqlCmdDataHaveTest(ApodDatabaseMethod()),
          PictureSaver(),
          getPictureSavePath,
          getPicture,
          compressPictureToSmallTest);

      await apodDataProvider.getTodayData();

      expect(apodDataProvider.apodDbData, isA<ApodDbData>());
    });

    test('Get Today Data Test By Api Error', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiDataGetErrorTest(ApodApiJsonGetter()),
          ApodDbSqlCmdNoDataTest(ApodDatabaseMethod()),
          PictureSaver(),
          getPictureSavePath,
          getPicture,
          compressPictureToSmallTest);

      await apodDataProvider.getTodayData();

      expect(apodDataProvider.apodDbData.title, 'error');
    });

    test('Get Today Data Test By Response 404', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiImageDataGetSuccessTest(ApodApiJsonGetter()),
          ApodDbSqlCmdNoDataTest(ApodDatabaseMethod()),
          PictureSaver(),
          getPictureSavePath,
          getPicture404Test,
          compressPictureToSmallTest); //response 404

      await apodDataProvider.getTodayData();

      expect(apodDataProvider.apodDbData.title, '404');
    });

    test('Get Today Image Data Test By Api Success And Save Picture', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiImageDataGetSuccessTest(ApodApiJsonGetter()),
          ApodDbSqlCmdNoDataTest(ApodDatabaseMethod()), //這邊不測試資料庫相關操作
          PictureSaverTest(), //替換Saver功能
          getPictureSavePathTest, //替換成test function不然要做fake path provider
          getPictureTest,
          compressPictureToSmallTest); //替換不走網路

      final picSavePath =
          await getPictureSavePathTest('2023-01-26', 'hd'); //替換成test function

      await apodDataProvider.getTodayData();

      expect(apodDataProvider.apodDbData.hdImagePath, picSavePath);
    });

    test('Get Today Video Data Test By Api Success And Save Picture', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiVideoDataGetSuccessTest(ApodApiJsonGetter()),
          ApodDbSqlCmdNoDataTest(ApodDatabaseMethod()), //這邊不測試資料庫相關操作
          PictureSaverTest(), //替換Saver功能
          getPictureSavePathTest, //替換成test function不然要做fake path provider
          getPictureTest,
          compressPictureToSmallTest); //替換不走網路

      final picSavePath =
          await getPictureSavePathTest('2023-01-26', 'hd'); //替換成test function

      await apodDataProvider.getTodayData();

      expect(apodDataProvider.apodDbData.hdImagePath, picSavePath);
    });

    test('Get Month Data Test', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiImageDataGetSuccessTest(ApodApiJsonGetter()),
          ApodDbSqlCmdDataHaveTest(ApodDatabaseMethod()),
          PictureSaver(),
          getPictureSavePathTest,
          getPictureTest,
          compressPictureToSmallTest);

      final datas = await apodDataProvider.getMonthDataByDataBase(2023, 01);

      expect(datas, isA<List<ApodDbData>>());
    });

    test('Get All Data Test', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiImageDataGetSuccessTest(ApodApiJsonGetter()),
          ApodDbSqlCmdDataHaveTest(ApodDatabaseMethod()),
          PictureSaver(),
          getPictureSavePathTest,
          getPictureTest,
          compressPictureToSmallTest);

      final datas = await apodDataProvider.getAllData();

      expect(datas, isA<List<ApodDbData>>());
    });

    test('Get Favorite Data Test', () async {
      final apodDataProvider = ApodDataProvider(
          ApodApiImageDataGetSuccessTest(ApodApiJsonGetter()),
          ApodDbSqlCmdDataHaveTest(ApodDatabaseMethod()),
          PictureSaver(),
          getPictureSavePathTest,
          getPictureTest,
          compressPictureToSmallTest);

      final datas = await apodDataProvider.getFavorite();

      expect(datas, isA<List<ApodDbData>>());
    });
  });
}
