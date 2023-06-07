import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apod/Instance/apod_api_json_getter.dart';
import 'package:flutter_apod/Instance/apod_db_sql_cmd.dart';
import 'package:flutter_apod/Instance/picture_saver.dart';
import 'package:flutter_apod/provider/apod_calendar_provider.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:flutter_apod/provider/apod_setting_open_url_provider.dart';
import 'package:flutter_apod/provider/apod_setting_provider.dart';
import 'package:provider/provider.dart';
import 'page/apod_page_today.dart';
import 'page/calendar_page.dart';
import 'page/favorite_page.dart';
import 'page/setting_page.dart';
import 'Instance/apod_api_data_get.dart';
import 'Instance/apod_database_method.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  //確保您有一個 WidgetsBinding 實例，這是使用平台通道調用本機代碼所必需的
  //WidgetFlutterBinding用於與 Flutter 引擎交互。
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  if (!Platform.isAndroid && !Platform.isIOS) {
    debugPrint('set window size');
    await DesktopWindow.setWindowSize(const Size(600, 900));
  }

  final apodDataProvider = ApodDataProvider(
      ApodApiDataGet(ApodApiJsonGetter()),
      ApodDbSqlCmd(ApodDatabaseMethod(), dbPathJoin),
      PictureSaver(),
      getPictureSavePath,
      getPicture,
      compressPictureToSmall);

  runApp(
    EasyLocalization(
        path: 'assets/translations',
        supportedLocales: const [Locale('en'), Locale('zh', 'TW')],
        fallbackLocale: const Locale('en'),
        assetLoader: JsonAssetLoader(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => apodDataProvider),
            ChangeNotifierProvider(
                create: (context) => ApodCalendarProvider(
                    apodDataProvider.getMonthDataByDataBase,
                    apodDataProvider.saveApiData,
                    ApodApiDataGet(ApodApiJsonGetter()))),
            ChangeNotifierProvider(create: (_) => ApodSettingProvider()),
            ChangeNotifierProvider(create: (_) => ApodSettingOpenUrlProvider())
          ],
          child: const MyApp(),
        )),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APOD',
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        pageList: [
          ApodPageFuture(),
          FavoritePage(),
          CalendarPage(),
          SettingPage()
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      //頁面List
      required this.pageList});

  final List<Widget> pageList;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //瀏覽頁面index
  int _selectedIndex = 0;

  @override
  void deactivate() {
    context.read<ApodDataProvider>().closeDatabase();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: context
          .read<ApodSettingProvider>()
          .initSharedPreferences()
          .whenComplete(() => context.read<ApodSettingProvider>().getBaseData())
          .whenComplete(() => context.read<ApodDataProvider>().openDatabase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            if (context.read<ApodSettingProvider>().isFirstSetting) {
              _selectedIndex = 3;
            }
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(tr('appTitle')),
              ),
              body: widget.pageList[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.home), label: 'menu.today'.tr()),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.star),
                      label: 'menu.favorite'.tr()),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.calendar_month),
                      label: 'menu.calendar'.tr()),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.settings),
                      label: 'menu.setting'.tr()),
                ],
                currentIndex: _selectedIndex,
                onTap: (int index) {
                  if (!context.read<ApodSettingProvider>().isFirstSetting) {
                    _selectedIndex = index;
                    (context as Element).markNeedsBuild();
                  }
                },
                selectedItemColor: Colors.blue,
                selectedFontSize: 14,
                unselectedFontSize: 14,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
              ),
            );
          }
        } else {
          return Container(
            color: Colors.white,
            child: const Center(
                child: SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(),
            )),
          );
        }
      },
    );
  }
}
