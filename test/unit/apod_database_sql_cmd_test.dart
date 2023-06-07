import 'package:flutter_apod/Instance/apod_database_method.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/Instance/apod_db_sql_cmd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//path_provider測試需要import這兩個
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

//依賴注入 Fake Path Provider 實例
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String kTemporaryPath = 'temporaryPath';
  final String kApplicationSupportPath = inMemoryDatabasePath;
  final String kDownloadsPath = 'downloadsPath';
  final String kLibraryPath = 'libraryPath';
  final String kApplicationDocumentsPath = 'applicationDocumentsPath';
  final String kExternalCachePath = 'externalCachePath';
  final String kExternalStoragePath = 'externalStoragePath';

  @override
  Future<String?> getTemporaryPath() async {
    return kTemporaryPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return kLibraryPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return kExternalStoragePath;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[kExternalCachePath];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[kExternalStoragePath];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return kDownloadsPath;
  }
}

String dataMerge(ApodDbData data) {
  return data.date +
      data.title +
      data.hdImagePath +
      data.copyright +
      data.explanation +
      data.favorite.toString();
}

String dataListMerge(List<ApodDbData> list) {
  String r = '';
  for (var d in list) {
    r += dataMerge(d);
  }
  return r;
}

Future main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Database Test', () {
    late ApodDbSqlCmd dbProvider;
    setUpAll(() {
      PathProviderPlatform.instance = FakePathProviderPlatform();
      sqfliteFfiInit();
      dbProvider = ApodDbSqlCmd(ApodDatabaseMethod(), (path) => path);
    });

    test('Open Test', () async {
      await dbProvider.openDB();
    });

    test('Insert Test', () async {
      var data = ApodDbData('2023-01-01', 'Test', 'TestPath', '', 'image',
          'TestCopyright', 'TestExplanation', 1);
      await dbProvider.insert(data);
      var searchData =
          await dbProvider.selectByDate('2023-01-01', '2023-01-01');

      expect(dataMerge(searchData[0]), dataMerge(data));
    });

    test('Update Test', () async {
      var data = ApodDbData('2023-01-01', 'Test2', 'TestPath2', '', 'image',
          'TestCopyright2', 'TestExplanation2', 0);
      await dbProvider.update(data);
      var searchData =
          await dbProvider.selectByDate('2023-01-01', '2023-01-01');

      expect(dataMerge(searchData[0]), dataMerge(data));
    });

    test('Select By Date Test', () async {
      var data1 = ApodDbData('2023-01-01', 'Test2', 'TestPath2', '', 'image',
          'TestCopyright2', 'TestExplanation2', 0);
      var data2 = ApodDbData('2023-07-07', 'Test3', '', 'videoPath', 'video',
          'TestCopyright3', 'TestExplanation3', 1);
      var data3 = ApodDbData('2024-12-31', 'Test4', 'TestPath4', '', 'image',
          'TestCopyright4', 'TestExplanation4', 1);
      var dataList = [data1, data2, data3];

      await dbProvider.insert(data2);
      await dbProvider.insert(data3);
      var searchData =
          await dbProvider.selectByDate('2023-01-01', '2024-12-31');

      expect(dataListMerge(searchData), dataListMerge(dataList));
    });

    test('Select by Favorite', () async {
      var data2 = ApodDbData('2023-07-07', 'Test3', '', 'videoPath', 'video',
          'TestCopyright3', 'TestExplanation3', 1);
      var data3 = ApodDbData('2024-12-31', 'Test4', 'TestPath4', '', 'image',
          'TestCopyright4', 'TestExplanation4', 1);
      var dataList = [data2, data3];

      var searchData = await dbProvider.selectByFavorite();

      expect(dataListMerge(searchData), dataListMerge(dataList));
    });

    test('Close Test', () async {
      await dbProvider.closeDB();
    });
  });
}
