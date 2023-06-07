import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:flutter_apod/provider/apod_setting_open_url_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ApodPage extends StatelessWidget {
  const ApodPage(this.dbData, {super.key});

  final ApodDbData dbData;

  Future<void> _launchUrl(String urlStr, BuildContext context) async {
    if (!urlStr.contains('https') && !urlStr.contains('http')) {
      if (urlStr.contains('//')) {
        urlStr = 'https:$urlStr';
      } else {
        urlStr = 'https://$urlStr';
      }
    }

    context.read<ApodSettingOpenUrlProvider>().launchApiUrl(urlStr);
  }

  Widget _getShowVideoButton(BuildContext context) {
    final String buttonText;
    if (dbData.videoUrl != '' && dbData.videoUrl != 'error') {
      buttonText = tr('showVideo');
      return Center(
          child: TextButton(
              onPressed: () {
                _launchUrl(dbData.videoUrl, context);
              },
              child: Text(buttonText)));
    } else {
      return const Center();
    }
  }

  Widget _getApodExplanationWidget(ApodDbData data) {
    if (!data.title.contains('HTTP Status Code')) {
      return SelectableText(
        dbData.explanation,
        style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
      );
    } else {
      return HtmlWidget(dbData.explanation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<ApodDataProvider>(
                    builder: (context, value, child) {
                      if (dbData.favorite == 0) {
                        return IconButton(
                            onPressed: () async {
                              await context
                                  .read<ApodDataProvider>()
                                  .changeFavorite(dbData);
                              (context as Element).markNeedsBuild();
                            },
                            icon: const Icon(Icons.star, color: Colors.grey));
                      } else {
                        return IconButton(
                            onPressed: () async {
                              await context
                                  .read<ApodDataProvider>()
                                  .changeFavorite(dbData);
                              (context as Element).markNeedsBuild();
                            },
                            icon: const Icon(Icons.star, color: Colors.amber));
                      }
                    },
                  ),
                  Text(
                    dbData.date,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
              Image.file(
                File(dbData.hdImagePath),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
                scale: 1, //縮放 越大越小
              ),
              _getShowVideoButton(context),
              Center(
                child: SelectableText(dbData.title,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
              ),
              Center(
                child: SelectableText(
                  dbData.copyright.isNotEmpty
                      ? '${tr('copyright')}：${dbData.copyright}'
                      : '',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _getApodExplanationWidget(dbData),
          ),
        ],
      ),
    );
  }
}
