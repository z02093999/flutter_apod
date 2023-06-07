import 'package:flutter/material.dart';
import 'package:flutter_apod/main.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:flutter_apod/provider/apod_setting_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks(
    [MockSpec<ApodSettingProvider>(), MockSpec<ApodDataProvider>()])
import 'main_page_widget_test.mocks.dart';

class ApodPageFutureTest extends StatelessWidget {
  const ApodPageFutureTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('today');
  }
}

class FavoritePageTest extends StatelessWidget {
  const FavoritePageTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('favorite');
  }
}

class CalendarPageTest extends StatelessWidget {
  const CalendarPageTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('calendar');
  }
}

class SettingPageTest extends StatelessWidget {
  const SettingPageTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('setting');
  }
}

void main() {
  group('Main Page Widget Test', () {
    final mockApodSettingProvider = MockApodSettingProvider();
    when(mockApodSettingProvider.initSharedPreferences())
        .thenAnswer((realInvocation) async {});
    when(mockApodSettingProvider.getBaseData())
        .thenAnswer((realInvocation) async {});
    when(mockApodSettingProvider.isFirstSetting).thenReturn(true);

    final mockApodDataProvider = MockApodDataProvider();
    when(mockApodDataProvider.openDatabase())
        .thenAnswer((realInvocation) async {});
    when(mockApodDataProvider.closeDatabase())
        .thenAnswer((realInvocation) async {});

    final app = MultiProvider(
      providers: [
        ChangeNotifierProvider<ApodSettingProvider>.value(
            value: mockApodSettingProvider),
        ChangeNotifierProvider<ApodDataProvider>.value(
            value: mockApodDataProvider)
      ],
      child: MaterialApp(
          title: 'APOD',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const MyHomePage(
            pageList: [
              ApodPageFutureTest(),
              FavoritePageTest(),
              CalendarPageTest(),
              SettingPageTest()
            ],
          )),
    );

    testWidgets('Main Page Test Start FirstSetting is true',
        (widgetTester) async {
      await widgetTester.pumpWidget(app);

      //略過 FutureBuilder
      await widgetTester.pumpAndSettle();
      //啟動時無設定資料要設定在setting pagg
      expect(find.text('setting'), findsOneWidget);

      await widgetTester.tap(find.byIcon(Icons.home));
      await widgetTester.pump();
      //如果尚未設定完成，無法移動到其他 page
      expect(find.text('setting'), findsOneWidget);

      when(mockApodSettingProvider.isFirstSetting).thenReturn(false);

      //移動到today
      await widgetTester.tap(find.byIcon(Icons.home));
      await widgetTester.pump();
      expect(find.text('today'), findsOneWidget);

      //移動到favorite
      await widgetTester.tap(find.byIcon(Icons.star));
      await widgetTester.pump();
      expect(find.text('favorite'), findsOneWidget);

      //移動到calendar
      await widgetTester.tap(find.byIcon(Icons.calendar_month));
      await widgetTester.pump();
      expect(find.text('calendar'), findsOneWidget);

      //移動到setting
      await widgetTester.tap(find.byIcon(Icons.settings));
      await widgetTester.pump();
      expect(find.text('setting'), findsOneWidget);
    });

    testWidgets('Main Page Test Start FirstSetting is false',
        (widgetTester) async {
      await widgetTester.pumpWidget(app);

      when(mockApodSettingProvider.isFirstSetting).thenReturn(false);
      //略過 FutureBuilder
      await widgetTester.pumpAndSettle();

      //初始位置在today
      expect(find.text('today'), findsOneWidget);

      //移動到favorite
      await widgetTester.tap(find.byIcon(Icons.star));
      await widgetTester.pump();
      expect(find.text('favorite'), findsOneWidget);

      //移動到calendar
      await widgetTester.tap(find.byIcon(Icons.calendar_month));
      await widgetTester.pump();
      expect(find.text('calendar'), findsOneWidget);

      //移動到setting
      await widgetTester.tap(find.byIcon(Icons.settings));
      await widgetTester.pump();
      expect(find.text('setting'), findsOneWidget);

      //移動到today
      await widgetTester.tap(find.byIcon(Icons.home));
      await widgetTester.pump();
      expect(find.text('today'), findsOneWidget);
    });
  });
}
