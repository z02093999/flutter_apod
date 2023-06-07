import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_apod/interface/i_apod_json_get.dart';
import 'package:flutter_apod/interface/i_database_sql.dart';
import 'package:flutter_apod/interface/i_picture_saver.dart';
import 'package:flutter_apod/model/apod_api_data.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:flutter_apod/common/date_relevant.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getPictureSavePath(
  String todayStr,
  String subFolder,
) async {
  final directory = await getApplicationDocumentsDirectory(); //取得文件儲存路徑
  final filePathName =
      join(directory.path, 'images', subFolder, '$todayStr.jpg'); //apod圖片save路徑

  return filePathName;
}

Future<Response> getPicture(String url) async {
  final response = await get(Uri.parse(url));
  return response;
}

///HD pictrue to small
Future<Uint8List> compressPictureToSmall(Uint8List picList) async {
  Uint8List smallPic;

  if (Platform.isAndroid || Platform.isIOS) {
    smallPic = await FlutterImageCompress.compressWithList(picList,
        minHeight: 480, minWidth: 480, quality: 96);
  } else {
    //其他平台還沒找到轉檔套件
    smallPic = picList;
  }

  return smallPic;
}

class ApodDataProvider extends ChangeNotifier {
  final IApodApiDataGet apodApiDataGetter;
  final IApodDbSqlCmd apodDbSqlCmd;
  final IPictureSaver pictureSaver;

  ///圖片儲存路徑function
  final Future<String> Function(String todayStr, String subFolder)
      _getPictureSavePathFunc;
  //取得圖片get function
  final Future<Response> Function(String url) _getPictureFunc;

  final Future<Uint8List> Function(Uint8List picList)
      _compressPictureToSmallFunc;

  late ApodDbData _apodDbData;

  ApodDataProvider(
      this.apodApiDataGetter,
      this.apodDbSqlCmd,
      this.pictureSaver,
      this._getPictureSavePathFunc,
      this._getPictureFunc,
      this._compressPictureToSmallFunc);

  ///當天apod data
  ApodDbData get apodDbData => _apodDbData;

  Future<void> openDatabase() async {
    await apodDbSqlCmd.openDB(); //openDb
  }

  Future<void> closeDatabase() async {
    await apodDbSqlCmd.closeDB(); //closeD
  }

  ///取得當天資料
  Future<void> getTodayData() async {
    final DateTime today = DateTime.now();
    final String todayStr = formater.format(today);
    final DateTime yesterday = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 1));
    final String yesterdayStr = formater.format(yesterday);

    final todayData =
        await apodDbSqlCmd.selectByDate(todayStr, todayStr); //取得當天資料

    if (todayData.isNotEmpty) {
      _apodDbData = todayData[0]; //當天資料
      debugPrint('當天資料由Database取得');
    } else {
      final apiData =
          await apodApiDataGetter.getApodTodayData(); //取得apodApiData

      if (apiData.hdurl != 'error') {
        //時差關係可能會是昨天資料
        if (apiData.date == yesterdayStr) {
          final yesterdayData = await apodDbSqlCmd.selectByDate(
              yesterdayStr, yesterdayStr); //取得昨天資料
          if (yesterdayData.isNotEmpty) {
            _apodDbData = yesterdayData[0];
          } else {
            _apodDbData = await saveApiData(apiData);
            debugPrint('當天資料由APi取得');
          }
        } else {
          _apodDbData = await saveApiData(apiData);
          debugPrint('當天資料由APi取得');
        }
      } else {
        _apodDbData = ApodDbData(
            apiData.date,
            apiData.title,
            apiData.hdurl,
            apiData.url,
            apiData.mediaType,
            apiData.copyright,
            apiData.explanation,
            0); //回傳api發生錯誤訊息
      }
    }
  }

  Future<ApodDbData> saveApiData(ApodApiData apiData) async {
    if (apiData.mediaType == 'video') {
      return await _saveApiVideoData(apiData);
    } else {
      //image
      return await _saveApiImageData(apiData);
    }
  }

  Future<ApodDbData> _saveApiVideoData(ApodApiData apiData) async {
    Response picResponse = await _getPictureFunc(apiData.thumbnailUrl);
    if (picResponse.statusCode == 200) {
      final filePathNameHd =
          await _getPictureSavePathFunc(apiData.date, 'hd'); //取得Hd存放路徑
      final filePathNameSmall =
          await _getPictureSavePathFunc(apiData.date, 'small'); //取得Small存放路徑

      final dbData = ApodDbData(
          apiData.date,
          apiData.title,
          '$filePathNameHd;$filePathNameSmall',
          apiData.url, //video url
          apiData.mediaType,
          apiData.copyright,
          apiData.explanation,
          0); //db data
      await pictureSaver.save(filePathNameHd, picResponse.bodyBytes); //儲存HD圖片
      await pictureSaver.save(
          filePathNameSmall, picResponse.bodyBytes); //儲存small圖片

      await apodDbSqlCmd.insert(dbData); //新增至DB
      return dbData;
    } else {
      return ApodDbData(
          'error',
          picResponse.statusCode.toString(),
          apiData.hdurl,
          'error',
          'error',
          'error',
          picResponse.body,
          0); //回傳圖片發生錯誤訊息
    }
  }

  Future<ApodDbData> _saveApiImageData(ApodApiData apiData) async {
    Response picResponse = await _getPictureFunc(apiData.hdurl);
    //如果回傳正常才存檔
    if (picResponse.statusCode == 200) {
      final filePathNameHd =
          await _getPictureSavePathFunc(apiData.date, 'hd'); //取得Hd存放路徑
      final filePathNameSmall =
          await _getPictureSavePathFunc(apiData.date, 'small'); //取得Small存放路徑

      final dbData = ApodDbData(
          apiData.date,
          apiData.title,
          '$filePathNameHd;$filePathNameSmall',
          '', //video url
          apiData.mediaType,
          apiData.copyright,
          apiData.explanation,
          0); //db data

      await pictureSaver.save(filePathNameHd, picResponse.bodyBytes); //儲存HD圖片

      Uint8List smallPic;

      if (Platform.isAndroid || Platform.isIOS) {
        smallPic = await _compressPictureToSmallFunc(picResponse.bodyBytes);
      } else {
        Response smallPictureResponse = await _getPictureFunc(apiData.url);

        if (smallPictureResponse.statusCode == 200) {
          //成功取得
          smallPic = smallPictureResponse.bodyBytes;
        } else {
          smallPic = picResponse.bodyBytes;
        }
      }

      await pictureSaver.save(filePathNameSmall, smallPic); //儲存small圖片

      await apodDbSqlCmd.insert(dbData); //新增至DB

      return dbData;
    } else {
      return ApodDbData(
          'error',
          picResponse.statusCode.toString(),
          apiData.hdurl,
          'error',
          'error',
          'error',
          picResponse.body,
          0); //回傳圖片發生錯誤訊息
    }
  }

  ///從資料庫取得每月資料
  Future<List<ApodDbData>> getMonthDataByDataBase(int year, int month) async {
    final days = getMonthFirstDayAndLastDay(year, month);

    final datas = await apodDbSqlCmd.selectByDate(days[0], days[1]);

    return datas;
  }

  //取得全部資料
  Future<List<ApodDbData>> getAllData() async {
    final firstDay = DateTime(1990, 01, 01);
    final lastDay = DateTime(2099, 12, 31);
    final firstDayStr = formater.format(firstDay);
    final lastDayStr = formater.format(lastDay);

    final datas = await apodDbSqlCmd.selectByDate(firstDayStr, lastDayStr);

    return datas;
  }

  ///取得最愛資料
  Future<List<ApodDbData>> getFavorite() async {
    final datas = await apodDbSqlCmd.selectByFavorite();

    return datas;
  }

  ///設定為最愛或取消最愛
  Future<void> changeFavorite(ApodDbData data) async {
    data.favorite = data.favorite == 0 ? 1 : 0;
    await apodDbSqlCmd.update(data);
  }
}
