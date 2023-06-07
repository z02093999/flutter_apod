import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_apod/common/date_relevant.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/page/calendar_page.dart';
import 'package:flutter_apod/provider/apod_calendar_provider.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks(
    [MockSpec<ApodCalendarProvider>(), MockSpec<ApodDataProvider>()])
import 'calendar_page_widget_test.mocks.dart';

final today = DateTime.now();

final apodDbDataList = [
  ApodDbData(
      formater.format(today.subtract(const Duration(days: 3))),
      'title1',
      'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
      '',
      'image',
      'copyright1',
      'explanation1',
      1),
  ApodDbData(
      formater.format(today.subtract(const Duration(days: 2))),
      'title2',
      'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
      '',
      'image',
      'copyright2',
      'explanation2',
      1),
  ApodDbData(
      formater.format(today.subtract(const Duration(days: 1))),
      'title3',
      'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
      '',
      'image',
      'copyright3',
      'explanation3',
      1),
  ApodDbData(
      formater.format(today),
      'title4',
      'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
      'https://youtu.be/8GnSFAZD8YY',
      'video',
      'copyright4',
      'explanation4',
      1)
];

final Map<String, ApodDbData> apodMap = {};

void creatApodMap() {
  for (int i = 0; i < apodDbDataList.length; i++) {
    apodMap.addAll({apodDbDataList[i].date: apodDbDataList[i]});
  }
}

void main() {
  creatApodMap();
  final mockApodCalendarProvider = MockApodCalendarProvider();
  when(mockApodCalendarProvider.apodDataMap).thenReturn(apodMap);

  final mockApodDataProvider = MockApodDataProvider();
  when(mockApodDataProvider.getAllData()).thenAnswer((realInvocation) async {
    return apodDbDataList;
  });

  final page = MultiProvider(
      providers: [
        ChangeNotifierProvider<ApodCalendarProvider>.value(
            value: mockApodCalendarProvider),
        ChangeNotifierProvider<ApodDataProvider>.value(
            value: mockApodDataProvider),
      ],
      child: MaterialApp(
        title: 'Carlendar Test',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Calendar Test'),
          ),
          body: const CalendarPage(),
        ),
      ));

  group('Calendar Test', () {
    testWidgets('Calendar Test', (tester) async {
      await tester.pumpWidget(page);
      await tester.pumpAndSettle();

      when(mockApodCalendarProvider.goGetMonthData(any, any)).thenReturn(true);
      await tester.tap(find.text('calendarPage.downloadMonth'));
      await tester.pumpAndSettle();

      expect(find.text('calendarPage.startDownload'), findsOneWidget);

      await tester.tap(find.text('calendarPage.close'));
      await tester.pumpAndSettle();

      expect(find.text('calendarPage.startDownload'), findsNothing);

      when(mockApodCalendarProvider.goGetMonthData(any, any)).thenReturn(false);
      await tester.tap(find.text('calendarPage.downloadMonth'));
      await tester.pumpAndSettle();

      expect(find.text('calendarPage.downloading'), findsOneWidget);

      await tester.tap(find.text('calendarPage.close'));
      await tester.pumpAndSettle();

      expect(find.text('calendarPage.downloading'), findsNothing);

      String todayStr = formater.format(today);
      final splitTodayStr = todayStr.split('-');

      //day
      await tester.tap(find.text(splitTodayStr[2]).first);
      await tester.pumpAndSettle();

      expect(find.image(FileImage(File('test\\picture\\Black_hole_M87.jpg'))),
          findsOneWidget);
      expect(find.text('title4'), findsOneWidget);
    });
  });
}
