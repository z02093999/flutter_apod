import 'package:flutter/material.dart';
import 'package:flutter_apod/common/apod_api_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApodSettingProvider extends ChangeNotifier {
  bool _isInit = true;
  late final SharedPreferences _prefs;
  late bool _isFirstSetting;
  final String _firstSettingSaveKey = 'firstSetting';
  final String _apiKeySaveKey = 'apiKey';
  String _apiKey = 'DEMO_KEY';

  bool get isFirstSetting => _isFirstSetting;

  Future<void> initSharedPreferences() async {
    if (_isInit) {
      _prefs = await SharedPreferences.getInstance();
      _isInit = false;
    }
  }

  Future<void> getBaseData() async {
    final bool? firstSetting = _prefs.getBool(_firstSettingSaveKey);
    final String? key = _prefs.getString(_apiKeySaveKey);

    if (firstSetting == null) //建立資料
    {
      await _prefs.setBool(_firstSettingSaveKey, true);
      await _prefs.setString(_apiKeySaveKey, 'DEMO_KEY');
      _isFirstSetting = true;
      _setApiKey('DEMO_KEY');
      return;
    }

    _isFirstSetting = firstSetting;
    _setApiKey(key!);
  }

  Future<void> setApodApiKey(String key) async {
    await _prefs.setString(_apiKeySaveKey, key);
    _setApiKey(key);
  }

  Future<void> setIsFirstSetting(bool b) async {
    await _prefs.setBool(_firstSettingSaveKey, b);
    _isFirstSetting = b;
  }

  void _setApiKey(String key) {
    _apiKey = key;
    apodApiKey = _apiKey;
  }
}
