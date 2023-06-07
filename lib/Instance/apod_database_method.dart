import 'package:flutter/material.dart';
import 'package:flutter_apod/interface/i_database_method.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

///
///實作sqflite基本方法
///
class ApodDatabaseMethod implements IDatabaseMethod {
  @override
  late Database db;

  @override
  Future<void> openDB(String dbPath, String excuteStr) async {
    debugPrint('open db');
    if (Platform.isWindows || Platform.isLinux) {
      var dbFactory = databaseFactoryFfi;
      db = await dbFactory.openDatabase(dbPath,
          options: OpenDatabaseOptions(
              onCreate: (db, version) {
                return db.execute(excuteStr);
              },
              version: 1));
    } else {
      db = await openDatabase(
        dbPath,
        onCreate: (db, version) {
          return db.execute(excuteStr);
        },
        version: 1,
      );
    }
  }

  @override
  Future<void> closeDB() async {
    debugPrint('closed db');
    await db.close();
  }

  @override
  Future<void> insert(String table, Map<String, Object?> data) async {
    await db.insert(table, data);
  }

  @override
  Future<int> update(String table, String where, List<Object?> whereArgs,
      Map<String, Object?> data) async {
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  @override
  Future<List<Map<String, Object?>>> select(
      String table, String where, List<Object?> whereArgs) async {
    return await db.query(table, where: where, whereArgs: whereArgs);
  }
}
