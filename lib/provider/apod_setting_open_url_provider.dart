import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApodSettingOpenUrlProvider extends ChangeNotifier {
  Future<void> launchApiUrl(String urlStr) async {
    final url = Uri.parse(urlStr);
    launchUrl(url);
  }
}
