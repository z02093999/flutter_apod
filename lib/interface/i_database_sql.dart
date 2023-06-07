import 'package:flutter_apod/model/apod_db_data.dart';
import 'i_database_method.dart';

class IApodDbSqlCmd {
  late IDatabaseMethod dbMethod;

  ///
  ///打開創建DB
  ///
  Future<void> openDB() async {}

  ///
  ///關閉DB
  ///
  Future<void> closeDB() async {}

  ///
  ///新增資料
  ///
  Future<void> insert(ApodDbData data) async {}

  ///
  ///更新資料
  ///
  Future<int> update(ApodDbData data) async {
    return 1;
  }

  ///
  ///依照日期搜尋資料
  ///
  Future<List<ApodDbData>> selectByDate(
      String startDate, String endDate) async {
    return [];
  }

  ///
  ///搜尋最愛資料
  ///
  Future<List<ApodDbData>> selectByFavorite() async {
    return [];
  }
}
