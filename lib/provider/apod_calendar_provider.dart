import 'dart:collection';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_apod/common/date_relevant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apod/interface/i_apod_json_get.dart';
import 'package:flutter_apod/model/apod_api_data.dart';
import 'package:flutter_apod/model/apod_db_data.dart';

class ApodCalendarProvider extends ChangeNotifier {
  final _apodEventDataMap = HashMap<String, ApodDbData>();
  final Future<List<ApodDbData>> Function(int year, int month)
      _getMonthDataByDbFunc;

  final Future<ApodDbData> Function(ApodApiData apiData) _saveApiDataFunc;

  final IApodApiDataGet _apodApiDataGetter;

  Future<void> Function(String title, String msg)? showDialogFunc;

  ///進度條進度
  double _progressValue = 0;

  ///下載Month資料的處理鎖
  bool _monthDataDownloadLocker = false;

  ///進度條進度
  double get progressValue => _progressValue;

  ///下載Month資料的處理鎖
  bool get monthDataDownLoadLocker => _monthDataDownloadLocker;

  ApodCalendarProvider(this._getMonthDataByDbFunc, this._saveApiDataFunc,
      this._apodApiDataGetter);

  Map<String, ApodDbData> get apodDataMap => _apodEventDataMap;

  ///true:開始下載 false:已經下載中
  bool goGetMonthData(int year, int month) {
    if (_monthDataDownloadLocker == false) {
      _getMonthDataByApi(year, month);
      return true;
    } else {
      return false;
    }
  }

  ///用於檢查傳入時間是否為未來時間
  ///input apiDays[0] is start date; apiDays[1] is last date
  ///回傳data[0]是error代表傳入時間是未來時間
  List<String> checkApiDate(List<String> apiDays) {
    final today = DateTime.now();
    final todayStr = formater.format(today);
    //檢查時間
    //今天時間小於月份開始時間(開始時間是未來時間)
    if (todayStr.compareTo(apiDays[0]) == -1) {
      apiDays[0] = 'error';
    } else if (todayStr.compareTo(apiDays[1]) == -1) {
      //今天時間小於月份結束時間(結束時間是未來時間)
      //更新成今天時間
      apiDays[1] = todayStr;
    }

    return apiDays;
  }

  ///由Api取得每月資料
  //然後 要排除資料庫已有的資料
  Future<void> _getMonthDataByApi(int year, int month) async {
    _monthDataDownloadLocker = true;

    var apiDays = getMonthFirstDayAndLastDay(year, month);

    //=============
    apiDays = checkApiDate(apiDays);
    if (apiDays[0] == 'error') {
      _monthDataDownloadLocker = false;
      if (showDialogFunc != null) {
        showDialogFunc!(
            tr('calendarPage.timeError'), tr('calendarPage.timeErrorMsg'));
      }
      notifyListeners();
      return;
    }

    _progressValue = 0; //初始化進度條
    notifyListeners();

    final List<ApodApiData> apiDatas =
        await _apodApiDataGetter.getApodByDateData(apiDays[0], apiDays[1]);
    final List<ApodDbData> dbDatas = [];

    if (apiDatas.isNotEmpty && apiDatas[0].hdurl != 'error') {
      //用於檢查資料庫是否已有資料
      final hadCheckDatas = await _getMonthDataByDbFunc(year, month);
      var hs = HashSet<String>();
      for (ApodDbData d in hadCheckDatas) {
        hs.add(d.date);
      }

      double eachPluse = 1 / apiDatas.length; //進度條每一次進度
      for (ApodApiData d in apiDatas) {
        if (!hs.contains(d.date)) {
          //資料庫無資料才新增
          final data = await _saveApiDataFunc(d);
          dbDatas.add(data);
        }
        _progressValue += eachPluse;
        notifyListeners();
      }
    } else {
      if (apiDatas.isNotEmpty) {
        //回傳api發生錯誤訊息
        if (showDialogFunc != null) {
          showDialogFunc!(apiDatas[0].title, apiDatas[0].explanation);
        }
      }
    }
    _progressValue = 0;
    _monthDataDownloadLocker = false;
    addEventData(dbDatas);
    if (showDialogFunc != null) {
      showDialogFunc!(
          tr('calendarPage.finishTitle'), tr('calendarPage.finishMsg'));
    }
    notifyListeners();
  }

  ///ApodEventDataMap增加資料
  void addEventData(List<ApodDbData> datas) {
    for (var data in datas) {
      if (!_apodEventDataMap.containsKey(data.date)) {
        _apodEventDataMap.addAll({data.date: data});
      }
    }
  }
}
