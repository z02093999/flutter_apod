import 'package:sqflite/sqflite.dart';

class IDatabaseMethod {
  late Database db;

  Future<void> openDB(
    String dbPath,
    String excuteStr,
  ) async =>
      {};
  Future<void> closeDB() async => {};
  Future<void> insert(String table, Map<String, Object?> data) async => {};
  Future<int> update(String table, String where, List<Object?> whereArgs,
          Map<String, Object?> data) async =>
      0;
  Future<List<Map<String, Object?>>> select(
          String table, String where, List<Object?> whereArgs) async =>
      [];
}
