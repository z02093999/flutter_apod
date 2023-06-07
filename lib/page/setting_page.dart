import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apod/common/apod_api_key.dart';
import 'package:flutter_apod/common/init_picture_save_folder.dart';
import 'package:flutter_apod/provider/apod_setting_open_url_provider.dart';
import 'package:flutter_apod/provider/apod_setting_provider.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _formKey = GlobalKey<FormState>();
  String _apiKey = apodApiKey;

  Widget _getFirstSettingMsg(BuildContext context) {
    if (context.read<ApodSettingProvider>().isFirstSetting) {
      var msg = tr('settingPage.apiKeyApplyMsg');
      return Text(msg);
    }
    return const Text('');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getPictureSaveFolder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('settingPage.setting'),
                        style: const TextStyle(fontSize: 20),
                      ),
                      TextFormField(
                        initialValue: _apiKey,
                        decoration: const InputDecoration(labelText: 'ApiKey'),
                        onSaved: (newValue) {
                          _apiKey = newValue!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return tr('settingPage.enterApiKey');
                          }
                          return null;
                        },
                      ),
                      TextButton(
                          onPressed: () {
                            context
                                .read<ApodSettingOpenUrlProvider>()
                                .launchApiUrl('https://api.nasa.gov/');
                          },
                          child: Text(
                            tr('settingPage.apiKeyApply'),
                            style: const TextStyle(fontSize: 12),
                          )),
                      TextFormField(
                        initialValue: snapshot.data,
                        decoration: InputDecoration(
                            labelText: tr('settingPage.imageSavePath')),
                        readOnly: true,
                      ),
                      _getFirstSettingMsg(context),
                      Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      context
                                          .read<ApodSettingProvider>()
                                          .setApodApiKey(_apiKey);
                                      context
                                          .read<ApodSettingProvider>()
                                          .setIsFirstSetting(false);
                                    }
                                  },
                                  child: Text(tr('settingPage.confirm')))))
                    ],
                  ));
            }
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
