import 'package:flutter_apod/interface/i_database_method.dart';
import 'package:flutter_apod/interface/i_database_sql.dart';
import 'package:path/path.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:path_provider/path_provider.dart';

///
///合併db路徑function,為了unit test 用注入方式
///
String dbPathJoin(String path) => join(path, 'apod.db');

///
///實作ApodDb Sql 相關操作
///
class ApodDbSqlCmd implements IApodDbSqlCmd {
  @override
  IDatabaseMethod dbMethod;
  dynamic dbPathJoinFunc;

  ApodDbSqlCmd(this.dbMethod, this.dbPathJoinFunc);

  ///
  ///打開創建DB
  ///
  @override
  Future<void> openDB() async {
    String path;
    final directory = await getApplicationSupportDirectory();
    path = directory.path;
/*
    if (Platform.isWindows || Platform.isLinux) {
      final directory = await getApplicationSupportDirectory();
      path = directory.path;
    } else {
      path = await getDatabasesPath();
    }
*/

    final String dbPath = dbPathJoinFunc(path);
    await dbMethod.openDB(dbPath,
        'CREATE TABLE $tableName($pkField TEXT PRIMARY KEY,title TEXT,imagePath TEXT,videoUrl TEXT,mediaType TEXT,copyright TEXT,explanation TEXT,$favoriteField INTEGER)');
  }

  ///
  ///關閉DB
  ///
  @override
  Future<void> closeDB() async {
    await dbMethod.closeDB();
  }

  ///
  ///新增資料
  ///
  @override
  Future<void> insert(ApodDbData data) async {
    await dbMethod.insert(tableName, data.toMap());
  }

  ///
  ///更新資料
  ///
  @override
  Future<int> update(ApodDbData data) async {
    return await dbMethod.update(
        tableName, '$pkField=?', [data.date], data.toMap());
  }

  ///
  ///依照日期搜尋資料
  ///
  @override
  Future<List<ApodDbData>> selectByDate(
      String startDate, String endDate) async {
    List<Map<String, dynamic>> mapList = await dbMethod
        .select(tableName, '$pkField between ? and ?', [startDate, endDate]);

    List<ApodDbData> apodList = [];
    for (Map<String, dynamic> map in mapList) {
      apodList.add(ApodDbData.fromDbMap(map));
    }

    return apodList;
  }

  ///
  ///搜尋最愛資料
  ///
  @override
  Future<List<ApodDbData>> selectByFavorite() async {
    List<Map<String, dynamic>> mapList =
        await dbMethod.select(tableName, '$favoriteField=?', [1]);

    List<ApodDbData> apodList = [];
    for (Map<String, dynamic> map in mapList) {
      apodList.add(ApodDbData.fromDbMap(map));
    }

    return apodList;
  }
}
