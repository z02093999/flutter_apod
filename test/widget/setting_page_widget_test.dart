import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_apod/common/apod_api_key.dart';
import 'package:flutter_apod/page/setting_page.dart';
import 'package:flutter_apod/provider/apod_setting_open_url_provider.dart';
import 'package:flutter_apod/provider/apod_setting_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks(
    [MockSpec<ApodSettingProvider>(), MockSpec<ApodSettingOpenUrlProvider>()])
import 'setting_page_widget_test.mocks.dart';

void main() {
  //path_provider模擬用
  const testMockStorage = './test/fixtures/core';
  const apiKeyTest = 'personalKey';
  //path_provider模擬用
  const channel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  group('Setting Page', () {
    bool isFirstSettingTest = true;
    apodApiKey = 'Demo';

    final mockApodSettingProvider = MockApodSettingProvider();
    when(mockApodSettingProvider.isFirstSetting).thenReturn(isFirstSettingTest);
    when(mockApodSettingProvider.setApodApiKey(any))
        .thenAnswer((realInvocation) async {
      apodApiKey = apiKeyTest;
    });
    when(mockApodSettingProvider.setIsFirstSetting(any))
        .thenAnswer((realInvocation) async {
      isFirstSettingTest = false;
    });

    final mockApodSettingOpenUrlProvider = MockApodSettingOpenUrlProvider();
    when(mockApodSettingOpenUrlProvider.launchApiUrl(any))
        .thenAnswer((realInvocation) async {});

    final page = MultiProvider(
      providers: [
        ChangeNotifierProvider<ApodSettingProvider>.value(
            value: mockApodSettingProvider),
        ChangeNotifierProvider<ApodSettingOpenUrlProvider>.value(
            value: mockApodSettingOpenUrlProvider)
      ],
      child: MaterialApp(
          title: 'Test Setting Page',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('test'),
            ),
            body: const SettingPage(),
          )),
    );

    testWidgets('First Setting', (widgetTester) async {
      //path_provider模擬用
      widgetTester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (message) async {
        return testMockStorage;
      });

      await widgetTester.pumpWidget(page);

      for (int i = 0; i < 3; i++) {
        await widgetTester.runAsync(() async {
          await Future.delayed(const Duration(seconds: 1));
        });

        await widgetTester.pump();
      }
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('$testMockStorage\\images'), findsOneWidget);
      expect(find.text('settingPage.apiKeyApplyMsg'), findsOneWidget);

      await widgetTester.tap(find.byType(TextButton));
      verify(mockApodSettingOpenUrlProvider.launchApiUrl(any)).called(1);

      await widgetTester.enterText(find.byType(TextField).first, apiKeyTest);
      await widgetTester.pump();
      expect(find.text(apiKeyTest), findsOneWidget);

      await widgetTester.tap(find.byType(ElevatedButton));
      expect(apodApiKey, apiKeyTest);
      expect(isFirstSettingTest, false);
    });
  });
}
